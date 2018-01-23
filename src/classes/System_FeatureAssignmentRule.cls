global class System_FeatureAssignmentRule implements System_IFeature {
		public Map<Decimal,List<Lightning_Auxiliary.Criteria>> RuleEntryOrder_CriteriaSet=new Map<Decimal,List<Lightning_Auxiliary.Criteria>>();

		//gather SObjectRecords assigned to a queue
		public Map<String,List<sObject>> QueueId_SObjectRecords=new Map<String,List<sObject>>();

		//toUpdateSObjectList for assign rule
		public List<sObject> toUpdateSObjectList=new List<sObject>();

		global Static Boolean isAssignmentRuleRunning =false;
		// public Static Boolean isupdateFired =false;

		public void execute() {
				System_FeatureAssignmentRule.isAssignmentRuleRunning=true;

				//System_FeatureAssignmentRule only fires on after insert and after update
				List<sObject> sObjectList=Trigger.new;
				//get sObjectName for Assignment_Rule__c.Related_Object__c
				String sObjectName=sObjectList[0].getSObjectType().getDescribe().getName();

				List<Assignment_Rule__c> rules=[Select Id, Active__c, Fire_On_Update__c,(Select Id,Criteria_Logic__c,Criteria_Set__c,Order__c,Assign_To_User__c,Assign_To_Queue__c From Assignment_Rule_Entries__r Order By Order__c) From Assignment_Rule__c Where Related_Object__c=: sObjectName And Active__c=true];

				System.debug('>>>sObjectName: '+sObjectName);
				System.debug('>>>Trigger.isBefore: '+Trigger.isBefore);
				System.debug('>>>Trigger.isAfter: '+Trigger.isAfter);
				System.debug('>>>Trigger.isInsert: '+Trigger.isInsert);
				System.debug('>>>Trigger.isUpdate: '+Trigger.isUpdate);

				if(rules.size()!=0) {
						//if Fire_On_Update__c not checked, dont fire assignment rule on update
						if(!rules[0].Fire_On_Update__c && Trigger.isUpdate)
								return;

						List<Assignment_Rule_Entry__c> ruleEntries=rules[0].Assignment_Rule_Entries__r;

						if(ruleEntries.size()!=0) {
								String customFields=getAllCustomFields(ruleEntries);
								String whereClause='Id IN:sObjectList';
								System.debug('>>>customFields: '+customFields);

								//re-query sobjRecords with customFields for criteraiset evaluation
								List<SObject> sobjRecords = Lightning_Utility.getSObjectRecords(sObjectName,customFields,whereClause,null,Lightning_Constant.RequiredFieldTypes.ONLY_CUSTOM_FIELDS,sObjectList);

								System.debug('>>>ruleEntries.size(): '+ruleEntries.size());

								//each sobjRecord, e.g. Lead
								for(SObject sobjRecord:sobjRecords) {
										//each ruleEntry
										for(Assignment_Rule_Entry__c re: ruleEntries) {
												if(evalRuleEntry(re, sobjRecord)) {
														//handleAssignmentPhase1 to re-assign OwnerId and gather SObjectRecords assigned to a queue if any
														handleAssignmentPhase1(re,sobjRecord);
														break;
												}
										}
								}

								System.debug('>>>QueueId_SObjectRecords: '+QueueId_SObjectRecords);

								//if there are any SObjectRecords assigned to a queue
								if(QueueId_SObjectRecords.keySet().size()!=0) {

										List<Assignment_Queue__c> queues=[Select Id, Active__c, (Select Last_Assignment__c,Member_Status__c,Millisecond__c,User__c From Assignment_Queue_Members__r Where Member_Status__c='Valid' ORDER BY Last_Assignment__c, Millisecond__c, User__r.Name) From Assignment_Queue__c Where Id IN:QueueId_SObjectRecords.keySet() And Active__c=true];

										if(queues.size()!=0)
												//round-robin member to re-assign OwnerId and update member last assignment
												handleAssignmentPhase2(queues);
								}

								system.debug('>>>toUpdateSObjectList: '+toUpdateSObjectList);

								//update gathered SObjectList for assignent rule
								if(toUpdateSObjectList.size()!=0)
										update toUpdateSObjectList;
						}
				}
				System_FeatureAssignmentRule.isAssignmentRuleRunning=false;
		}

		//handleAssignmentPhase1 to re-assign OwnerId and  gather SObjectRecords assigned to a queue if any
		void handleAssignmentPhase1(Assignment_Rule_Entry__c rule, SObject sobjRecord){
				system.debug('>>>rule: '+rule);

				//if assigned to a user, set OwnerId to this user
				if(String.isNotBlank(rule.Assign_To_User__c)) {
						system.debug('>>>sobjRecord.get(OwnerId): '+sobjRecord.get('OwnerId'));
						system.debug('>>>rule.Assign_To_User__c: '+rule.Assign_To_User__c);

						sobjRecord.put('OwnerId',rule.Assign_To_User__c);
						toUpdateSObjectList.add(sobjRecord);
				}
				else if(String.isNotBlank(rule.Assign_To_Queue__c)) {
						//gather SObjectRecords assigned to a queue
						if(QueueId_SObjectRecords.containsKey(rule.Assign_To_Queue__c)) {
								List<SObject> tmpList = QueueId_SObjectRecords.get(rule.Assign_To_Queue__c);
								tmpList.add(sobjRecord);
								QueueId_SObjectRecords.put(rule.Assign_To_Queue__c, tmpList);
						}
						else{
								List<SObject> tmpList=new List<SObject>();
								tmpList.add(sobjRecord);
								QueueId_SObjectRecords.put(rule.Assign_To_Queue__c, tmpList);
						}
				}
		}

		//round-robin member and update member last assignment
		void handleAssignmentPhase2(List<Assignment_Queue__c> queues){
				List<Assignment_Queue_Member__c> toUpdateMembers = new List<Assignment_Queue_Member__c>();

				for(Assignment_Queue__c queue:queues) {
						Map<Id,Assignment_Queue_Member__c> MemberId_Member = new Map<Id,Assignment_Queue_Member__c>();
						Map<Id, datetime> MemberId_LastAssignment = new Map<Id,datetime>();
						Integer index = 0;
						for(SObject sobjRecord : QueueId_SObjectRecords.get(queue.Id)) {
								List<Assignment_Queue_Member__c> members=queue.Assignment_Queue_Members__r;

								if(members.size()!=0) {
										//for batch support, loop members
										Assignment_Queue_Member__c member = members[Math.mod(index, members.size())];

										if(Trigger.isInsert) {
												sobjRecord.put('OwnerId',member.User__c);
												toUpdateSObjectList.add(sobjRecord);
										}
										else if(Trigger.isUpdate) {
												//if Trigger.isUpdate and OwnerId already in queue, do not re-assign owner
												Map<String,Boolean> memberUIDMap=new Map<String,Boolean>();
												for(Assignment_Queue_Member__c m:members)
														memberUIDMap.put(m.User__c,true);

												String currentOwnerId=(String)sobjRecord.get('OwnerId');
												if(!memberUIDMap.containsKey(currentOwnerId)) {
														sobjRecord.put('OwnerId',member.User__c);
														toUpdateSObjectList.add(sobjRecord);
												}
												else
														continue;
										}

										//Set last assignment datetime
										Datetime now = Datetime.now();
										member.Last_Assignment__c = now;
										member.Millisecond__c = now.millisecondGMT();

										//save only the latest LastAssignment per member
										if (MemberId_LastAssignment.containsKey(Member.Id)) {
												if(MemberId_LastAssignment.get(Member.Id) < now) {
														MemberId_Member.put(Member.Id, Member);
														MemberId_LastAssignment.put(Member.Id, now);
												}
										} else {
												MemberId_Member.put(Member.Id, Member);
												MemberId_LastAssignment.put(Member.Id,now);
										}

										index++;
								}

						}

						toUpdateMembers.addAll(MemberId_Member.values());
				}

				if (toUpdateMembers.size()>0)
						update toUpdateMembers;
		}

		Boolean evalRuleEntry(Assignment_Rule_Entry__c ruleEntry, SObject sobjRecord){

				System.debug('>>>evalRuleEntry sobjRecord: '+sobjRecord);

				System.debug('>>>evalRuleEntry Trigger.isBefore: '+Trigger.isBefore);
				System.debug('>>>evalRuleEntry Trigger.isAfter: '+Trigger.isAfter);
				System.debug('>>>evalRuleEntry Trigger.isUpdate: '+Trigger.isUpdate);

				if(String.isBlank(ruleEntry.Criteria_Set__c))
						return true;

				Map<Decimal,Boolean> CriteriaOrder_CriteriaEvaluation = new Map<Decimal,Boolean> ();

				for(Lightning_Auxiliary.Criteria criteria:RuleEntryOrder_CriteriaSet.get(ruleEntry.Order__c)) {
						CriteriaOrder_CriteriaEvaluation=getCriteriaOrder_CriteriaEvaluation(CriteriaOrder_CriteriaEvaluation,criteria.order,criteria.fieldName,criteria.fieldType,criteria.operator,criteria.fieldValue,sobjRecord);
				}

				String criteriaLogic='';
				if(!String.isBlank(ruleEntry.Criteria_Logic__c))
						criteriaLogic=ruleEntry.Criteria_Logic__c.toLowerCase();

				if(!String.isBlank(criteriaLogic)) {
						criteriaLogic=criteriaLogic.deleteWhitespace();
						criteriaLogic=criteriaLogic.replaceAll('and','&&');
						criteriaLogic=criteriaLogic.replaceAll('or','||');
						for(Decimal order:CriteriaOrder_CriteriaEvaluation.keyset())
								criteriaLogic=criteriaLogic.replace(String.valueOf(order),String.valueOf(CriteriaOrder_CriteriaEvaluation.get(order)));

						System.debug('>>>criteriaLogic: '+criteriaLogic);
				}
				else{
						criteriaLogic=criteriaLogic.deleteWhitespace();
						for(Decimal order:CriteriaOrder_CriteriaEvaluation.keyset())
								criteriaLogic+=String.valueOf(CriteriaOrder_CriteriaEvaluation.get(order))+'&&';

						criteriaLogic=criteriaLogic.subString(0, criteriaLogic.length() - 2);
				}

				Lightning_EvalEx_Expression expression = new Lightning_EvalEx_Expression(criteriaLogic);
				Boolean result = expression.evalBool();
				System.debug('>>>Assignment_Rule_Entry__c '+ ruleEntry.Order__c +' - criteriaLogic: '+criteriaLogic);
				System.debug('>>>Assignment_Rule_Entry__c '+ ruleEntry.Order__c +' - result: '+result);

				return result;
		}

		Map<Decimal,Boolean> getCriteriaOrder_CriteriaEvaluation(Map<Decimal,Boolean> CriteriaOrder_CriteriaEvaluation, Decimal order, String fieldName,String fieldType, String operator,String fieldValue,SObject sobjRecord){
				if(!String.isBlank(fieldName)) {
						system.debug('>>>sobjRecord: '+sobjRecord);
						system.debug('>>>fieldName: '+fieldName);

						List<String> fieldList=fieldName.split('\\.');
						String targetValue;

						for(Integer i=0; i<fieldList.size(); i++) {
								if(i==fieldList.size()-1) {
										if(sobjRecord!=null)
												targetValue=String.valueOf(sobjRecord.get(fieldList[i]));
								}
								else{
										if(sobjRecord!=null)
												sobjRecord=sobjRecord.getSObject(fieldList[i]);
								}
						}

						String criteriaValue=String.valueOf(fieldValue);

						if(String.isBlank(targetValue))
								targetValue='';
						else{
								targetValue=targetValue.toLowerCase();
								targetValue=targetValue.trim();
						}
						if(String.isBlank(criteriaValue))
								criteriaValue='';
						else{
								criteriaValue=criteriaValue.toLowerCase();
								criteriaValue=criteriaValue.trim();
						}

						Boolean result=doEvaluation(fieldType, operator, targetValue, criteriaValue);
						CriteriaOrder_CriteriaEvaluation.put(order,result);
				}

				return CriteriaOrder_CriteriaEvaluation;
		}

		Boolean doEvaluation(String fieldType, String operator, String targetValue, String criteriaValue){
				operator = operator.toLowerCase();
				if(operator==Lightning_Constant.EQUALS) {
						if(fieldType=='string'||fieldType=='picklist'||fieldType=='phone'||fieldType=='textarea'||fieldType=='email'||fieldType=='double'||fieldType=='url') {
								List<String> criteriaValueList=criteriaValue.split(',');
								Boolean criteriaEvaluation=false;
								for(String cv:criteriaValueList) {
										if(targetValue==cv) {
												criteriaEvaluation=true;
												break;
										}
								}
								return criteriaEvaluation;
						}
						else
								return targetValue==criteriaValue;
				}
				else if(operator==Lightning_Constant.DOSE_NOT_EQUAL) {
						if(fieldType=='string'||fieldType=='picklist'||fieldType=='phone'||fieldType=='textarea'||fieldType=='email'||fieldType=='double'||fieldType=='url') {
								List<String> criteriaValueList=criteriaValue.split(',');
								Boolean criteriaEvaluation=true;
								for(String cv:criteriaValueList) {
										if(targetValue==cv) {
												criteriaEvaluation=false;
												break;
										}
								}
								return criteriaEvaluation;
						}
						else
								return targetValue!=criteriaValue;
				}
				else if(operator==Lightning_Constant.STARTS_WITH) {
						if(fieldType=='string'||fieldType=='picklist'||fieldType=='phone'||fieldType=='textarea'||fieldType=='email'||fieldType=='double'||fieldType=='url') {
								List<String> criteriaValueList=criteriaValue.split(',');
								Boolean criteriaEvaluation=false;
								for(String cv:criteriaValueList) {
										if(targetValue.startsWith(cv)) {
												criteriaEvaluation=true;
												break;
										}
								}
								return criteriaEvaluation;
						}
						else
								return targetValue.startsWith(criteriaValue);
				}
				else if(operator==Lightning_Constant.ENDS_WITH) {
						if(fieldType=='string'||fieldType=='picklist'||fieldType=='phone'||fieldType=='textarea'||fieldType=='email'||fieldType=='double'||fieldType=='url') {
								List<String> criteriaValueList=criteriaValue.split(',');
								Boolean criteriaEvaluation=false;
								for(String cv:criteriaValueList) {
										if(targetValue.endsWith(cv)) {
												criteriaEvaluation=true;
												break;
										}
								}
								return criteriaEvaluation;
						}
						else
								return targetValue.endsWith(criteriaValue);
				}
				else if(operator==Lightning_Constant.CONTAINS) {
						if(fieldType=='string'||fieldType=='picklist'||fieldType=='phone'||fieldType=='textarea'||fieldType=='email'||fieldType=='double'||fieldType=='url') {
								List<String> criteriaValueList=criteriaValue.split(',');
								Boolean criteriaEvaluation=false;
								for(String cv:criteriaValueList) {
										if(targetValue.contains(cv)) {
												criteriaEvaluation=true;
												break;
										}
								}
								return criteriaEvaluation;
						}
						else
								return targetValue.contains(criteriaValue);
				}
				else if(operator==Lightning_Constant.DOES_NOT_CONTAIN) {
						if(fieldType=='string'||fieldType=='picklist'||fieldType=='phone'||fieldType=='textarea'||fieldType=='email'||fieldType=='double'||fieldType=='url') {
								List<String> criteriaValueList=criteriaValue.split(',');
								Boolean criteriaEvaluation=true;
								for(String cv:criteriaValueList) {
										if(!targetValue.contains(cv)) {
												criteriaEvaluation=false;
												break;
										}
								}
								return criteriaEvaluation;
						}
						else
								return !targetValue.contains(criteriaValue);
				}
				else if(operator==Lightning_Constant.LESS_THAN) {
						return targetValue < criteriaValue;
				}

				else if(operator==Lightning_Constant.LESS_OR_EQUAL) {
						return targetValue <= criteriaValue;
				}

				else if(operator==Lightning_Constant.GREATER_THAN) {
						return targetValue > criteriaValue;
				}

				else if(operator==Lightning_Constant.GREATER_OR_EQUAL) {
						return targetValue >= criteriaValue;
				}

				return false;
		}


		String getAllCustomFields(List<Assignment_Rule_Entry__c> ruleEntries){
				String customFields='';
				for(Assignment_Rule_Entry__c re:ruleEntries) {
						if(!String.isBlank(re.Criteria_Set__c)) {
								List<Lightning_Auxiliary.Criteria> criteriaSet=(List<Lightning_Auxiliary.Criteria>)JSON.deserialize(re.Criteria_Set__c,List<Lightning_Auxiliary.Criteria>.class);

								RuleEntryOrder_CriteriaSet.put(re.Order__c,criteriaSet);

								for(Lightning_Auxiliary.Criteria c:criteriaSet) {
										if(!customFields.contains(c.fieldName))
												customFields+=c.fieldName+',';
								}
						}
				}

				if(!String.isBlank(customFields)) {
						if(!customFields.toLowerCase().contains('ownerid'))
								customFields+='OwnerId,';
						customFields = customFields.subString(0, customFields.length() - 1);
				}

				return customFields;
		}
}