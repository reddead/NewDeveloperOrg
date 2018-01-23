@isTest
private class Lightning_ASGMT_DataControllerTest {

		@isTest static void test_method_one() {
				Profile p=[select id from Profile where Name='System Administrator' limit 1];

				User user = new User();
				user.Username ='unitTestDante@unitTestDante.com';
				user.LastName = 'unitTestDante';
				user.Email = 'unitTestDante@unitTestDante.com';
				user.alias = 'uTest';
				user.TimeZoneSidKey = 'America/Chicago';
				user.LocaleSidKey = 'en_US';
				user.ProfileId=p.id;
				user.EmailEncodingKey = 'ISO-8859-1';
				user.LanguageLocaleKey = 'en_US';
				user.isActive=true;
				insert user;

				Assignment_Rule__c ar=new Assignment_Rule__c();
				ar.Name='Assignment Rule UnitTest';
				ar.Related_Object__c='Contact';
				ar.Active__c=true;
				insert ar;

				Assignment_Rule_Entry__c re=new Assignment_Rule_Entry__c();
				re.Order__c=1;
				re.Name='Assignment Rule Entry UnitTest';
				re.Assignment_Rule__c=ar.Id;
				insert re;

				Assignment_Queue__c aq=new Assignment_Queue__c();
				aq.Name='Assignment Queue UnitTest';
				insert aq;

				Assignment_Queue_Member__c aqm=new Assignment_Queue_Member__c();
				aqm.Assignment_Queue__c=aq.Id;
				aqm.Member_Active__c=true;
				aqm.User__c=user.Id;
				insert aqm;

				// Implement test code
				Lightning_ASGMT_DataController.getConfig();

				Lightning_ASGMT_DataController.getAssignmentRuleObjectOptions();

				String paramsJson='{"ruleId":"'+ ar.Id +'","isRuleActive":true,"ruleRelatedObject":"Contact"}';
				Lightning_ASGMT_DataController.getPagedResult(ar.getSObjectType().getDescribe().getName(),null,null,null,paramsJson);

				paramsJson='{"ruleEntryId":"'+ re.Id +'","ruleEntryOldOrder":"2"}';
				Lightning_ASGMT_DataController.getPagedResult(re.getSObjectType().getDescribe().getName(),null,null,null,paramsJson);

				paramsJson='{"partialWhereClause":"'+ Lightning_Utility.nameSpacePrefix +'Assignment_Queue__c=\''+ aq.Id +'\' AND "}';
				Lightning_ASGMT_DataController.getPagedResult(aqm.getSObjectType().getDescribe().getName(),null,null,null,paramsJson);

				Lightning_ASGMT_DataController.updateRuleEntryOrder(re.Id,'2');

				Lightning_ASGMT_DataController.validateRelatedObject('Contact');

				Lightning_Utility.getObjectNameBasedOnPrefix(ar.Id);
				Lightning_Utility.getNameSpacePerfix('__');

				List<SObject> sObjectList=new List<SObject>();
				sObjectList.add(ar);
				Lightning_Utility.getSObjectRecords(ar.getSObjectType().getDescribe().getName(),null,null,null,Lightning_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS,sObjectList);
		}

		@isTest static void test_method_two() {
				// Implement test code
				Lightning_ASGMT_DataController.getConfig();

				Lightning_Auxiliary.Filter filter= new Lightning_Auxiliary.Filter();
				filter.searchKey='test';
				filter.relatedObject ='Contact';

				List<Lightning_Auxiliary.Option> options=new List<Lightning_Auxiliary.Option>();
				options.add(new Lightning_Auxiliary.Option('2','2'));
				options.add(new Lightning_Auxiliary.Option('1','1'));
				options.add(new Lightning_Auxiliary.Option('1','1'));
				options.sort();
		}

}