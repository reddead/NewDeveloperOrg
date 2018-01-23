public class NGD_HomepageCriteriaParser {
		public List<SObject> sobjList;//store parsed hlList
		public Map<String,List<SObject>> hwMap;//store parsed hwMap
		public SObject contact;
		public SObject application;

		public Map<String,String> Order_EvaluatedExp;

		public NGD_HomepageCriteriaParser(List<sObject> sobjList, String sobjName, String contactId, String applicationId) {
				//init variables
				Order_EvaluatedExp=new Map<String,String>();
				this.sobjList=new List<sObject>();
				hwMap=new Map<String,List<SObject>>();

				execute(sobjList, sobjName,contactId,applicationId);
		}

		private void execute(List<sObject> sobjList, String sobjName, String contactId, String applicationId){
				Map<String,Set<String>> ObjectName_CustomFields=getMapObjectName_CustomFields(sobjList);

				System.debug('>>>ObjectName_CustomFields: '+ObjectName_CustomFields);

				if(ObjectName_CustomFields.containsKey(NGD_Constant.CONTACT)) {
						Map<String, String> mapWhereClause=new Map<String, String>();
						mapWhereClause.put('Id=', contactId);
						contact=NGD_Utility.getObjectWithFields(NGD_Constant.CONTACT, mapWhereClause, null,null, ObjectName_CustomFields.get(NGD_Constant.CONTACT), NGD_Constant.RequiredFieldTypes.ONLY_CUSTOM_FIELDS)[0];
				}

				if(ObjectName_CustomFields.containsKey(NGD_Constant.APPLICATION)) {
						Map<String, String> mapWhereClause=new Map<String, String>();
						mapWhereClause.put('Id=', applicationId);
						application=NGD_Utility.getObjectWithFields(NGD_Constant.APPLICATION, mapWhereClause, null,null, ObjectName_CustomFields.get(NGD_Constant.APPLICATION), NGD_Constant.RequiredFieldTypes.ONLY_CUSTOM_FIELDS)[0];
				}

				if(sobjName==NGD_Constant.HOMEPAGE_LAYOUT || sobjName==NGD_Constant.HOMEPAGE_TEMPLATE) {
						parseCriteria(sobjList,null);
				}
				else if(sobjName==NGD_Constant.HOMEPAGE_WIDGET) {
						Map<String,List<SObject>> WidgetNumber_WidgetList=groupWidgetByNumber(sobjList);

						if(WidgetNumber_WidgetList.keySet().size()!=0) {
								for(String widgetNumber:WidgetNumber_WidgetList.keySet())
										parseCriteria(WidgetNumber_WidgetList.get(widgetNumber),widgetNumber);
						}
				}
		}

		private void parseCriteria(List<SObject> sobjList, String widgetNumber){
				SObject defaultRecord;
				List<SObject> tmpSObjectList=new List<SObject>();

				for(SObject sobj:sobjList) {
						Order_EvaluatedExp.clear();// clear map for new each sobj

						if((Boolean)sobj.get(getFieldNameWithNamespace('Default__c'))) {
								defaultRecord=sobj;
								continue;
						}

						if(String.isBlank((String)sobj.get(getFieldNameWithNamespace('Criteria__c'))))
								continue;


						//categorize by object name
						Map<String,List<NGD_HomepageCriteria>> ObjectName_HCList=getMapObjectName_HCList(sobj);
						for(String objectName:ObjectName_HCList.keySet()) {
								for(NGD_HomepageCriteria hc:ObjectName_HCList.get(objectName))
										getMapOrder_EvaluatedExp(hc.order, objectName, hc.fieldName,hc.operator,hc.fieldValue);
						}

						//re-constructed Criteria_Filter_Logic__c field value
						String criteriaFilterLogic ='';
						if(sobj.get(getFieldNameWithNamespace('Criteria_Filter_Logic__c'))!=null)
								criteriaFilterLogic=String.valueOf(sobj.get(getFieldNameWithNamespace('Criteria_Filter_Logic__c')));
						System.debug('>>>criteriaFilterLogic: '+criteriaFilterLogic);
						if(!String.isBlank(criteriaFilterLogic)) {
								criteriaFilterLogic=criteriaFilterLogic.deleteWhitespace();
								criteriaFilterLogic=criteriaFilterLogic.replaceAll('and','&&');
								criteriaFilterLogic=criteriaFilterLogic.replaceAll('or','||');
								for(String order:Order_EvaluatedExp.keyset())
										criteriaFilterLogic=criteriaFilterLogic.replace(String.valueOf(order),Order_EvaluatedExp.get(order));
						}
						else{//default to all AND
								criteriaFilterLogic=criteriaFilterLogic.deleteWhitespace();
								for(String order:Order_EvaluatedExp.keyset())
										criteriaFilterLogic+=Order_EvaluatedExp.get(order)+'&&';

								criteriaFilterLogic=criteriaFilterLogic.subString(0, criteriaFilterLogic.length() - 2);
						}

						Lightning_EvalEx_Expression expression = new Lightning_EvalEx_Expression(criteriaFilterLogic);
						Boolean result = expression.evalBool();

						System.debug('>>>criteriaFilterLogic: '+criteriaFilterLogic);
						System.debug('>>>result: '+result);

						if(result)
								tmpSObjectList.add(sobj);
				}

				//hw
				if(widgetNumber!=null) {
						if(tmpSObjectList.size()>0)
								this.sobjList.addAll(tmpSObjectList);
						else if(defaultRecord!=null)
								tmpSObjectList.add(defaultRecord);

						if(tmpSObjectList.size()>0)
								hwMap.put(widgetNumber,tmpSObjectList);
				}
				//hl or ht
				else{
						if(tmpSObjectList.size()>0)
								this.sobjList.addAll(tmpSObjectList);
						else if(defaultRecord!=null)
								this.sobjList.add(defaultRecord);
				}

				System.debug('>>>tmpSObjectList: '+tmpSObjectList);
		}

		private Map<String,List<NGD_HomepageCriteria>> getMapObjectName_HCList(sObject sobj){
				list<NGD_HomepageCriteria> hcList=(list<NGD_HomepageCriteria>)JSON.deserialize((String)sobj.get(getFieldNameWithNamespace('Criteria__c')),list<NGD_HomepageCriteria>.class);

				Map<String,List<NGD_HomepageCriteria>> ObjectName_HCList=new Map<String,List<NGD_HomepageCriteria>>();

				//construct  ObjectName_HCList Map
				for(NGD_HomepageCriteria hc:hcList) {
						if(!String.isBlank(hc.objectName)) {
								if(!ObjectName_HCList.containsKey(hc.objectName)) {
										ObjectName_HCList.put(hc.objectName,new List<NGD_HomepageCriteria>());
										ObjectName_HCList.get(hc.objectName).add(hc);
								}
								else
										ObjectName_HCList.get(hc.objectName).add(hc);
						}
				}

				return ObjectName_HCList;
		}

		private Map<String,Set<String>> getMapObjectName_CustomFields(List<sObject> sobjList){
				Map<String,Set<String>> ObjectName_CustomFields=new Map<String,Set<String>>();

				System.debug('>>>sobjList: '+sobjList);

				for(SObject sobj:sobjList) {
						if((Boolean)sobj.get(getFieldNameWithNamespace('Default__c')))
								continue;

						if(String.isBlank((String)sobj.get(getFieldNameWithNamespace('Criteria__c'))))
								continue;

						Map<String,List<NGD_HomepageCriteria>> ObjectName_HCList=getMapObjectName_HCList(sobj);
						System.debug('>>>ObjectName_HCList: '+ObjectName_HCList);
						for(String objectName:ObjectName_HCList.keySet()) {
								if(objectName==NGD_Constant.CONTACT && ObjectName_CustomFields.get(objectName)==null)
										ObjectName_CustomFields.put(objectName,new Set<String>());
								else if(objectName==NGD_Constant.APPLICATION && ObjectName_CustomFields.get(objectName)==null)
										ObjectName_CustomFields.put(objectName,new Set<String>());

								for(NGD_HomepageCriteria hc : ObjectName_HCList.get(objectName))
										ObjectName_CustomFields.get(objectName).add(hc.fieldName);
						}
				}
				return ObjectName_CustomFields;
		}

		private Map<String,List<sObject>> groupWidgetByNumber(List<sObject> sobjList){
				Map<String,List<sObject>> WidgetNumber_WidgetList=new Map<String,List<sObject>>();
				for(SObject sobj:sobjList) {
						string widgetNumber=(String)sobj.get(getFieldNameWithNamespace('Number__c'));
						if(!WidgetNumber_WidgetList.containsKey(widgetNumber)) {
								WidgetNumber_WidgetList.put(widgetNumber,new List<sObject>());
								WidgetNumber_WidgetList.get(widgetNumber).add(sobj);
						}
						else{
								WidgetNumber_WidgetList.get(widgetNumber).add(sobj);
						}
				}
				return WidgetNumber_WidgetList;
		}

		private void getMapOrder_EvaluatedExp(String order, String objectName, String fieldName,String operator,String fieldValue){
				List<String> fieldNameList=fieldName.split('\\.');
				String targetValue;
				String criteriaValue;

				//get targetValue
				sObject tmpSObject=null;
				if(objectName==NGD_Constant.CONTACT)
						tmpSObject=contact;
				if(objectName==NGD_Constant.APPLICATION)
						tmpSObject=application;

				System.debug('>>>fieldNameList: '+fieldNameList);

				for(Integer i=0; i<fieldNameList.size(); i++) {
						if(i==fieldNameList.size()-1 && tmpSObject!=null)
								targetValue=String.valueOf(tmpSObject.get(fieldNameList[i]));
						else if(tmpSObject!=null)
								tmpSObject=tmpSObject.getSObject(fieldNameList[i]);
				}

				//get criteriaValue
				criteriaValue=String.valueOf(fieldValue);

				if(String.isBlank(targetValue))
						targetValue='';
				else{
						//targetValue=targetValue.toLowerCase();
						targetValue=targetValue.trim();
				}
				if(String.isBlank(criteriaValue))
						criteriaValue='';
				else{
						//criteriaValue=criteriaValue.toLowerCase();
						criteriaValue=criteriaValue.trim();
				}

				System.debug('>>>operator: '+operator);
				System.debug('>>>targetValue: '+targetValue);
				System.debug('>>>criteriaValue: '+criteriaValue);

				if(operator==NGD_Constant.EQUALS) {
						Order_EvaluatedExp.put(order,String.valueOf(targetValue==criteriaValue));
				}
				else if(operator==NGD_Constant.DOSE_NOT_EQUAL) {
						Order_EvaluatedExp.put(order,String.valueOf(targetValue!=criteriaValue));
				}
				else if(operator==NGD_Constant.STARTS_WITH) {
						Order_EvaluatedExp.put(order,String.valueOf(targetValue.startsWith(criteriaValue)));
				}
				else if(operator==NGD_Constant.ENDS_WITH) {
						Order_EvaluatedExp.put(order,String.valueOf(targetValue.endsWith(criteriaValue)));
				}
				else if(operator==NGD_Constant.CONTAINS) {
						Order_EvaluatedExp.put(order,String.valueOf(targetValue.contains(criteriaValue)));
				}
				else if(operator==NGD_Constant.DOES_NOT_CONTAIN) {
						Order_EvaluatedExp.put(order,String.valueOf(!targetValue.contains(criteriaValue)));
				}
		}

		public static string getFieldNameWithNamespace(String str) {
				return NGD_DataController.namespacePrefix+str;
		}
}