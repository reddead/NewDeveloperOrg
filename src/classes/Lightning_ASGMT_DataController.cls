public with sharing class Lightning_ASGMT_DataController {
		@AuraEnabled
		public static Lightning_Auxiliary.Config getConfig(){
			Lightning_Auxiliary.Config c=new Lightning_Auxiliary.Config();
			c.nameSpacePrefix=Lightning_Utility.nameSpacePrefix;
			c.isAssignmentManagerActive=Feature_Manager__c.getOrgDefaults().AssignmentRule__c;
			c.configurationsJson=Lightning_Utility.getconfigurationsJson();
			c.sObjectNamesJson=Lightning_Utility.getSObjectNamesJson();
			c.sObjectDescribesJson=Lightning_Utility.getSObjectDescribesJson(Lightning_Utility.getAssignmentRuleSObjectNames());
			return c;
		}

		// @AuraEnabled
		// public static List<Lightning_Auxiliary.Option> getPicklistOptions(String sobjectName,String fieldName) {
		//      SObjectType sobjType = Lightning_Utility.schemaMap.get(sobjectName);
		//      Map<String,Schema.SObjectField> fieldMap = sobjType.getDescribe().fields.getMap();
		//      Schema.DescribeFieldResult result=fieldMap.get(fieldName).getDescribe();
		//      List<Schema.PicklistEntry> entries = result.getPicklistValues();
		//
		//      List<Lightning_Auxiliary.Option> picklistOptions=new List<Lightning_Auxiliary.Option>();
		//      picklistOptions.add(new Lightning_Auxiliary.Option('-- None --',''));
		//
		//      for (Schema.PicklistEntry entry: entries) {
		//              picklistOptions.add(new Lightning_Auxiliary.Option(entry.getValue(),entry.getValue()));
		//      }
		//      return picklistOptions;
		// }

		// @AuraEnabled
		// public static List<Lightning_Auxiliary.Option> getAssignmentRuleObjectOptions(){
		// 		List<Lightning_Auxiliary.Option> options=new List<Lightning_Auxiliary.Option>();
		// 		options.add(new Lightning_Auxiliary.Option('-- None --',''));
		//
		// 		for(String sobjectName:Lightning_Utility.getAssignmentRuleSObjectNames())
		// 				options.add(new Lightning_Auxiliary.Option(sobjectName,sobjectName));
		//
		// 		options.sort();
		// 		return options;
		// }

		@AuraEnabled
		public static Lightning_Auxiliary.PagedResult getPagedResult(String objectName,String customFields,String whereClause,String otherClause,String paramsJson) {
				Lightning_Auxiliary.PagedResult pr =  new Lightning_Auxiliary.PagedResult();
				pr.recordCount=Lightning_Utility.getSObjectRecordsCount(objectName,whereClause);
				pr.records=Lightning_Utility.getSObjectRecords(objectName,customFields,whereClause,otherClause,Lightning_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS);

				System.debug('>>>paramsJson: '+paramsJson);
				Map<String, Object> paramMap = (Map<String, Object>)JSON.deserializeUntyped(paramsJson);
				System.debug('>>>paramMap: '+paramMap);

				if(objectName.contains('Assignment_Rule__c')) {
						if(paramMap.containsKey('isRuleActive')) {
							Boolean isRuleActive=(Boolean)paramMap.get('isRuleActive');
							String ruleRelatedObject=(String)paramMap.get('ruleRelatedObject');
							if(isRuleActive) {
									String ruleId=(String)paramMap.get('ruleId');
									Lightning_Utility.setActiveRule(ruleId,ruleRelatedObject);
									pr.records=Lightning_Utility.getSObjectRecords(objectName,customFields,whereClause,otherClause,Lightning_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS);
							}
							else
								Lightning_Utility.setActiveRule('',ruleRelatedObject);
						}
				}
				else if(objectName.contains('Assignment_Rule_Entry__c')) {
						if(paramMap.containsKey('ruleEntryId')) {
								String ruleEntryId=(String)paramMap.get('ruleEntryId');
								if(String.isNotBlank(ruleEntryId)) {
										Decimal ruleEntryOldOrder=Decimal.valueOf((String)paramMap.get('ruleEntryOldOrder'));
										if(Lightning_Utility.reOrderRuleEntry(pr.records,ruleEntryId,ruleEntryOldOrder))
												pr.records=Lightning_Utility.getSObjectRecords(objectName,customFields,whereClause,otherClause,Lightning_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS);
								}
								else
										Lightning_Utility.reOrderRuleEntry(pr.records,null,null);
						}
				}
				else if(objectName.contains('Assignment_Queue_Member__c')) {
					whereClause=paramMap.get('partialWhereClause')+Lightning_Utility.nameSpacePrefix+'Member_Status__c=\'Valid\'';
					otherClause='Order By '+Lightning_Utility.nameSpacePrefix+'Last_Assignment__c,'+Lightning_Utility.nameSpacePrefix+'Millisecond__c limit 1';
					List<SObject> validMembers=Lightning_Utility.getSObjectRecords(objectName,'',whereClause,otherClause,Lightning_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS);

					if(validMembers.size()>0)
						pr.firstValidMember=validMembers[0];
				}
				return pr;
		}

		// @AuraEnabled
		// public static SObject getRecordById(String recordId,String customFields,String whereClause,String otherClause){
		//      String objectName=Lightning_Utility.getObjectNameBasedOnPrefix(recordId);
		//      if(objectName.contains('Assignment_Queue_Member__c')) {
		//              Lightning_Auxiliary.Config config = Lightning_ASGMT_DataController.getConfig();
		//              customFields=config.nameSpacePrefix+'User__r.Name';
		//      }
		//
		//      List<SObject> records = Lightning_Utility.getSObjectRecords(objectName,customFields,whereClause,otherClause,Lightning_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS);
		//
		//      if(records.size()>0)
		//              return records[0];
		//      else
		//              return null;
		// }

		@AuraEnabled
		public static void updateRuleEntryOrder(String recordId, String newOrder){
				Assignment_Rule_Entry__c ruleEntry=[Select Id,Order__c from Assignment_Rule_Entry__c where Id =:recordId];
				ruleEntry.Order__c=Decimal.valueOf(newOrder);
				update ruleEntry;
		}

		@AuraEnabled
		public static Configuration__c insertConfiguration(String objectName){
			List<Configuration__c> configurations=new List<Configuration__c>();
			configurations=[SELECT Related_To__c,Related_To_Value__c FROM Configuration__c WHERE Name =: System_Constant.ASSIGNMENT_MANAGER AND Related_To__c=:objectName AND Related_To_Value__c='true'];

			if(configurations.size()==0){
				Configuration__c pc =new Configuration__c();
				pc.Name=System_Constant.ASSIGNMENT_MANAGER;
				pc.Related_To__c=objectName;
				insert pc;

				Lightning_Utility.setActiveRule('',objectName);

				return pc;
			}

			return null;
		}

		@AuraEnabled
		public static void deleteConfiguration(String deleteConfigurationId){
			List<Configuration__c> configurations=new List<Configuration__c>();
			configurations=[SELECT Related_To__c,Related_To_Value__c FROM Configuration__c WHERE Id=:deleteConfigurationId limit 1];

			if(configurations.size()!=0){
				//check related assignment rules and delete
				List<Assignment_Rule__c> assignmentRules=new List<Assignment_Rule__c>();
				assignmentRules=[SELECT Id from Assignment_Rule__c where Related_Object__c=:configurations[0].Related_To__c];

				if(assignmentRules.size()!=0)
					delete assignmentRules;

				delete configurations[0];
			}
		}

		// @AuraEnabled
		// public static Boolean validateRelatedObject(String relatedObject){
		// 		return Lightning_Utility.validateRelatedObject(relatedObject);
		// }
}