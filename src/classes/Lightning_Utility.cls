public with sharing class Lightning_Utility {
		public static Map<String, Schema.SobjectType> schemaMap = Schema.getGlobalDescribe();
		public static Map<String,Schema.DescribeTabResult> tabDescribeMap = getTabDescribeMap();
		public static String nameSpacePrefix=getNameSpacePerfix('__');

		public static String getSObjectName(Schema.sObjectType t){
				return t.getDescribe().getName();
		}


		public static String getObjectNameBasedOnPrefix(String id) {
				String objectName = '';
				if(id.length() == 15 || id.length() == 18) {//Stanard Id size of 15 or 18
						for(Schema.SobjectType schema : schemaMap.values()) {//Loop through Metadata to get object name via prefix
								if(schema.getDescribe().getKeyPrefix() != null && id.startsWith(schema.getDescribe().getKeyPrefix())) {
										objectName = schema.getDescribe().getName();
								}
						}
				}
				return objectName;
		}

		/*******************************************************************************************************
		* @description  Method Returns NameSpacePerfix
		* @return return name space of managed package.
		*******************************************************************************************************/
		public static String getNameSpacePerfix(String prefix){
				String namespace = null;
				List<ApexClass> apxs = [SELECT NameSpacePrefix FROM ApexClass WHERE Name = 'Lightning_Utility' and NameSpacePrefix != null];
				if(apxs.size() > 0) {
						namespace = apxs[0].NameSpacePrefix;
						namespace = prefix+namespace;
				} else {
						namespace = '';
				}
				return namespace;
		}

		public static Set<String> getAssignmentRuleSObjectNames(){
				List<Assignment_Rule__c> assignmentRules=[select Related_Object__c from Assignment_Rule__c where Related_Object__c!=null];

				Set<String> assignmentRuleObjects=new Set<String>();
				for(Assignment_Rule__c ar:assignmentRules)
						assignmentRuleObjects.add(ar.Related_Object__c);

				// if(assignmentRuleObjects.size()==0) {}
				assignmentRuleObjects.add('Account');
				assignmentRuleObjects.add('Lead');
				assignmentRuleObjects.add('Contact');
				assignmentRuleObjects.add(nameSpacePrefix+'Application__c');
				return assignmentRuleObjects;
		}

		public static Map<String,Schema.DescribeTabResult> getTabDescribeMap() {
				List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
				System.debug('>>>tabSetDesc.size(): '+tabSetDesc.size());

				List<Schema.DescribeTabResult> tabDescList = new List<Schema.DescribeTabResult>();
				Map<String,Schema.DescribeTabResult> SobjectName_TabDescribe=new Map<String,Schema.DescribeTabResult>();

				for(Schema.DescribeTabSetResult tsr : tabSetDesc) {
						//if(tsr.getLabel()==('ERX Admissions') || tsr.getLabel()==('ERX Configuration') || tsr.getLabel()=='Sales'|| tsr.getLabel()=='Salesforce Chatter')
						tabDescList.addAll(tsr.getTabs());
				}

				for(Schema.DescribeTabResult tr : tabDescList){
					if(!SobjectName_TabDescribe.containsKey(tr.getSobjectName()))
					SobjectName_TabDescribe.put(tr.getSobjectName(),tr);
				}

				System.debug('>>>SobjectName_TabDescribe.keySet().size(): '+SobjectName_TabDescribe.keySet().size());
				return SobjectName_TabDescribe;
		}

		public static String getSObjectDescribesJson(Set<String> sObjectNames){
				Map<String,Boolean> objectMap=new Map<String,Boolean>();

				//add reference objects for criteria field selection
				for(String sObjectName:sObjectNames) {
						if(schemaMap.containsKey(sObjectName)) {
								objectMap.put(sObjectName,true);
								Map <String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectName).getDescribe().fields.getMap();
								for(Schema.SObjectField sfield : fieldMap.Values()) {
										schema.describeFieldResult dfr = sfield.getDescribe();
										if(String.valueOf(dfr.getType()).toLowerCase()=='reference') {
												for(Schema.sObjectType sobjType :dfr.getReferenceTo()) {
														String refObjectName=sobjType.getDescribe().getName();
														if(refObjectName.toLowerCase()=='group')
																continue;
														sObjectNames.add(refObjectName);
												}
										}
								}
						}
				}

				for(String sObjectName:sObjectNames) {
						if(schemaMap.containsKey(sObjectName)) {
								if(objectMap.get(sObjectName)==null) {
										Map <String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectName).getDescribe().fields.getMap();
										for(Schema.SObjectField sfield : fieldMap.Values()) {
												schema.describeFieldResult dfr = sfield.getDescribe();
												if(String.valueOf(dfr.getType()).toLowerCase()=='reference') {
														for(Schema.sObjectType sobjType :dfr.getReferenceTo()) {
																String refObjectName=sobjType.getDescribe().getName();
																if(refObjectName.toLowerCase()=='group')
																		continue;
																sObjectNames.add(refObjectName);
														}
												}
										}
								}
						}
				}

				//add assignment related objects for avatar icon display
				sObjectNames.add(nameSpacePrefix+'Assignment_Rule__c');
				sObjectNames.add(nameSpacePrefix+'Assignment_Rule_Entry__c');
				//for Assignment_Rule_Entry__c.Assign_To__c
				sObjectNames.add(nameSpacePrefix+'Assignment_Queue__c');
				sObjectNames.add(nameSpacePrefix+'Assignment_Queue_Member__c');
				return getSObjectDescribes(sObjectNames);
		}

		// public static String getSObjectDescribe(String sObjectName) {
		//      // Just enough to make the sample app work!
		//      Schema.SObjectType targetType = schemaMap.get(sObjectName);
		//      if (targetType == null) {
		//              return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
		//      }
		//
		//      Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
		//
		//      Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();
		//
		//      List<Object> fields = new List<Object>();
		//      for (String key : fieldMap.keySet()) {
		//              Schema.DescribeFieldResult descField = fieldMap.get(key).getDescribe();
		//              Map<String, Object> field = new Map<String, Object>();
		//
		//              field.put('type', descField.getType().name().toLowerCase());
		//              field.put('name', descField.getName());
		//              field.put('label', descField.getLabel());
		//              field.put('picklistValues', descField.getPicklistValues());
		//              field.put('controllerName', String.valueOf(descField.getController()));
		//              field.put('relationshipName', String.valueOf(descField.getRelationshipName()));
		//              field.put('isCustom', descField.isCustom());
		//
		//              List<String> references = new List<String>();
		//              for (Schema.sObjectType t : descField.getReferenceTo()) {
		//                      String refObjectName=t.getDescribe().getName();
		//                      if(refObjectName.toLowerCase()!='group')
		//                              references.add(refObjectName);
		//              }
		//              if (!references.isEmpty()) {
		//                      field.put('referenceTo', references[0]);
		//              }
		//
		//              fields.add(field);
		//      }
		//
		//      Map<String, Object> result = new Map<String, Object>();
		//      result.put('fields', fields);
		//      result.put('sObjectName', sObjectName);
		//      return JSON.serialize(result);
		// }

		public static String getSObjectDescribes(Set<String> sObjectNames) {
				Map<String,Map<String, Object>> describeResults = new Map<String,Map<String, Object>>();
				for(String sObjectName:sObjectNames) {
						// Just enough to make the sample app work!
						Schema.SObjectType targetType = schemaMap.get(sObjectName);
						if (targetType == null) {
								return null;
								// return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
						}

						Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();

						Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();

						List<Object> fields = new List<Object>();

						List<String> fieldList= new List<String>();
						fieldList.addAll(fieldMap.keySet());
						fieldList.sort();

						for (String key : fieldList) {
								Schema.DescribeFieldResult descField = fieldMap.get(key).getDescribe();
								Map<String, Object> field = new Map<String, Object>();

								field.put('type', descField.getType().name().toLowerCase());
								field.put('name', descField.getName());
								field.put('label', descField.getLabel());
								field.put('picklistValues', descField.getPicklistValues());
								field.put('controllerName', String.valueOf(descField.getController()));
								field.put('relationshipName', String.valueOf(descField.getRelationshipName()));
								field.put('isCustom', descField.isCustom());

								Map<String,String> referenceMap = new Map<String,String>();
								for (Schema.sObjectType t : descField.getReferenceTo()) {
										String refObjectName=t.getDescribe().getName();
										String refObjectLabel=t.getDescribe().getLabel();
										if(refObjectName.toLowerCase()!='group')
												referenceMap.put(refObjectLabel,refObjectName);
								}
								if (!referenceMap.keySet().isEmpty()) {
										List<String> referenceList=new List<String>();
										referenceList.addAll(referenceMap.keySet());
										field.put('referenceToLabel', referenceList[0]);
										field.put('referenceTo', referenceMap.get(referenceList[0]));
								}

								fields.add(field);
						}

						String iconColor='';
						String iconSVGPath='';
						String iconName='';
						Schema.DescribeTabResult tabResult= tabDescribeMap.get(sObjectName);
						System.debug('>>>sObjectName: '+sObjectName);
						System.debug('>>>tabResult: '+tabResult);

						if(!sobjResult.isCustom()){

							if(tabResult!=null)
								iconColor=tabResult.getColors()[0].getColor();


							iconSVGPath='/resource/'+nameSpacePrefix+'NGD_SLDS/assets/icons/standard-sprite/svg/symbols.svg#'+sObjectName.toLowerCase();
							iconName='standard:'+sObjectName.toLowerCase();
						}
						else if(tabResult!=null) {
								iconColor=tabResult.getColors()[0].getColor();
								String svgName='';
								for (Schema.DescribeIconResult iconResult : tabResult.getIcons()) {
										if (iconResult.getContentType() == 'image/svg+xml') {
												String url = iconResult.getUrl();
												svgName=url.subString(url.lastIndexOf('/')+1,url.lastIndexOf('.'));
												break;
										}
								}
								iconSVGPath='/resource/'+nameSpacePrefix+'NGD_SLDS/assets/icons/custom-sprite/svg/symbols.svg#'+svgName;
								iconName='custom:'+svgName;
						}

						Map<String, Object> result = new Map<String, Object>();
						result.put('fields', fields);
						result.put('sObjectLabel', sobjResult.getLabel());
						result.put('sObjectLabelPlural', sobjResult.getLabelPlural());
						result.put('sObjectName', sObjectName);
						result.put('iconColor', iconColor);
						result.put('iconSVGPath', iconSVGPath);
						result.put('iconName', iconName);

						describeResults.put(sObjectName,result);

						System.debug('>>>describeResults: '+describeResults);
				}
				//return describeResults;
				return JSON.serialize(describeResults);
		}

		public static List<SObject> getSObjectRecords(String objectName,String customFields,String whereClause,String otherClause, Lightning_Constant.RequiredFieldTypes fType) {
				String query = Lightning_Constant.SELECT_CLAUSE;
				try {
						Schema.SObjectType sObjectTypeObj = schemaMap.get(objectName);

						if(fType == Lightning_Constant.RequiredFieldTypes.FIELDSET_FIELDS_CUSTOM_FIELDS || fType == Lightning_Constant.RequiredFieldTypes.ALL_FIELDS || fType == Lightning_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS || fType == Lightning_Constant.RequiredFieldTypes.ONLY_CUSTOM_FIELDS) {
								if(fType == Lightning_Constant.RequiredFieldTypes.ALL_FIELDS || fType == Lightning_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS) {
										Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();
										Map<String,Schema.SObjectField> fields = describeSObjectResultObj.fields.getMap();
										List<Schema.SObjectField> fieldMapValues = fields.values();
										for(Schema.SObjectField field : fieldMapValues) {
												query += field.getDescribe().getName();
												query += ',';
										}
								}
								if(fType == Lightning_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS || fType == Lightning_Constant.RequiredFieldTypes.ONLY_CUSTOM_FIELDS || fType == Lightning_Constant.RequiredFieldTypes.FIELDSET_FIELDS_CUSTOM_FIELDS) {
										if(!String.isBlank(customFields))
												query += customFields+',';
								}
						}
						query = query.subString(0, query.length() - 1);
						query += Lightning_Constant.FROM_CLAUSE + objectName;

						if(!String.isBlank(whereClause)) {
								query += Lightning_Constant.WHERE_CLAUSE;
								query += whereClause;
						}

						if(!String.isBlank(otherClause))
								query+=' '+otherClause;

						system.debug('>>> query: ' + query);
						return Database.query(query);
				} catch(Exception e) {
						system.debug(e.getMessage() + '### query: ' + query);
						return null;
				}
		}

		public static List<SObject> getSObjectRecords(String objectName,String customFields,String whereClause,String otherClause, Lightning_Constant.RequiredFieldTypes fType, List<SObject> sObjectList) {
				String query = Lightning_Constant.SELECT_CLAUSE;
				try {
						Schema.SObjectType sObjectTypeObj = schemaMap.get(objectName);

						if(fType == Lightning_Constant.RequiredFieldTypes.FIELDSET_FIELDS_CUSTOM_FIELDS || fType == Lightning_Constant.RequiredFieldTypes.ALL_FIELDS || fType == Lightning_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS || fType == Lightning_Constant.RequiredFieldTypes.ONLY_CUSTOM_FIELDS) {
								if(fType == Lightning_Constant.RequiredFieldTypes.ALL_FIELDS || fType == Lightning_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS) {
										Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();
										Map<String,Schema.SObjectField> fields = describeSObjectResultObj.fields.getMap();
										List<Schema.SObjectField> fieldMapValues = fields.values();
										for(Schema.SObjectField field : fieldMapValues) {
												query += field.getDescribe().getName();
												query += ',';
										}
								}
								if(fType == Lightning_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS || fType == Lightning_Constant.RequiredFieldTypes.ONLY_CUSTOM_FIELDS || fType == Lightning_Constant.RequiredFieldTypes.FIELDSET_FIELDS_CUSTOM_FIELDS) {
										if(!String.isBlank(customFields))
												query += customFields+',';
								}
						}
						query = query.subString(0, query.length() - 1);
						query += Lightning_Constant.FROM_CLAUSE + objectName;

						if(!String.isBlank(whereClause)) {
								query += Lightning_Constant.WHERE_CLAUSE;
								query += whereClause;
						}

						if(!String.isBlank(otherClause))
								query+=' '+otherClause;

						system.debug('>>> query: ' + query);
						return Database.query(query);
				} catch(Exception e) {
						system.debug(e.getMessage() + '### query: ' + query);
						return null;
				}
		}

		public static Integer getSObjectRecordsCount(String objectName,String whereClause){
				String query = Lightning_Constant.SELECT_CLAUSE+'count()';
				query += Lightning_Constant.FROM_CLAUSE + objectName;

				if(!String.isBlank(whereClause)) {
						query += Lightning_Constant.WHERE_CLAUSE;
						query += whereClause;
				}

				return Database.countQuery(query);
		}

		public static Boolean validateRelatedObject(String relatedObject){
			return schemaMap.containsKey(relatedObject);
		}

		public static Boolean reOrderRuleEntry(List<SObject> ruleEntries, String recordId, Decimal oldOrder){
				Boolean isReordered=false;
				String orderFieldApi=nameSpacePrefix + 'Order__c';
				Integer maxOrder=ruleEntries.size();

				for(Integer i=0; i<ruleEntries.size(); i++) {
						Decimal newOrder=(Decimal)ruleEntries[i].get(orderFieldApi);
						if(!String.isBlank(recordId)) {
								//ruleEntries[i].Id==recordId
								if(ruleEntries[i].Id==recordId) {
										//i!=ruleEntries.size()-1
										if(i!=ruleEntries.size()-1) {
												//if(ruleEntries[i].get(orderFieldApi)==ruleEntries[i+1].get(orderFieldApi) ) {
												//if not last one of list ruleEntries[i] and ruleEntries[i+1] order must be the same
												if(newOrder<=oldOrder) {
														ruleEntries[i].put(orderFieldApi,i+1);
														ruleEntries[i+1].put(orderFieldApi,i+2);
												}
												else{
														ruleEntries[i].put(orderFieldApi,i+2);
														ruleEntries[i+1].put(orderFieldApi,i+1);
												}
												isReordered=true;
												i++;
										}
										else{
												if(newOrder>maxOrder) {
														ruleEntries[i].put(orderFieldApi,maxOrder);
														isReordered=true;
												}
										}
										//ruleEntries[i].Id==recordId END
								}
								else{
										if(ruleEntries[i].get(orderFieldApi)!=i+1) {
												ruleEntries[i].put(orderFieldApi,i+1);
												isReordered=true;
										}
								}
						}
						//RuleEntry delete event, no recordId passed back
						else{
								if(ruleEntries[i].get(orderFieldApi)!=i+1) {
										ruleEntries[i].put(orderFieldApi,i+1);
										isReordered=true;
								}
						}
				}
				if(isReordered)
						update ruleEntries;

				return isReordered;
		}

		public static void setActiveRule( String recordId, String relatedObject){
				List<SObject> rules=[Select Id, Active__c From Assignment_Rule__c Where Related_Object__c=: relatedObject];
				String activeFieldApi=nameSpacePrefix + 'Active__c';
				for(SObject rule:rules) {
						if(rule.get('Id')!=recordId)
								rule.put(activeFieldApi,false);
				}
				update rules;
		}
}