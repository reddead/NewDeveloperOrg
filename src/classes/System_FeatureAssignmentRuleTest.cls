@isTest
private class System_FeatureAssignmentRuleTest {


	@isTest static void test_method_one() {
		// Implement test code
		prepareData();

		Lead l1=new Lead();
		l1.LastName='unitTestDante';
		l1.Company='UnitTest';
		l1.Status='Closed - Converted';
		insert l1;

		prepareData1();

		Test.startTest();
		l1.Status='Open - Not Contacted';
		update l1;

		Lead l=new Lead();
		l.LastName='unitTestDante';
		l.Company='UnitTest';
		l.Status='Open - Not Contacted';
		insert l;

		l.Status='Closed - Converted';
		update l;

		Test.stopTest();
	}

	@isTest static void test_method_two() {
		// Implement test code
		prepareData();
		prepareData1();

		Test.startTest();

		Contact c= new Contact();
		c.LastName='unitTestDante';
		c.Email='unitTestDante@unitTestDante.com';
		insert c;

		update c;

		Test.stopTest();
	}

	private static void prepareData(){
		Feature_Manager__c fm=new Feature_Manager__c();
		fm.Name='Feature Manager UnitTest';
		fm.AssignmentRule__c=true;
		insert fm;
	}

	private static void prepareData1(){
		Profile p=[select id from Profile where Name='System Administrator' limit 1];

  	User user = new User();
		user.Username ='unitTestDante@unitTestDante.com';
		user.FirstName='unitTestDante';
		user.LastName = 'unitTestDante';
		user.Email = 'unitTestDante@unitTestDante.com';
		user.alias = 'uTest';
		user.TimeZoneSidKey = 'America/Chicago';
		user.LocaleSidKey = 'en_US';
		user.ProfileId=p.id;
		user.EmailEncodingKey = 'ISO-8859-1';
		user.LanguageLocaleKey = 'en_US';
		user.IsActive=true;
  	insert user;

		User user1 = new User();
		user1.Username ='unitTestDante1@unitTestDante1.com';
		user1.FirstName='unitTestDante1';
		user1.LastName = 'unitTestDante1';
		user1.Email = 'unitTestDante1@unitTestDante1.com';
		user1.alias = 'uTest1';
		user1.TimeZoneSidKey = 'America/Chicago';
		user1.LocaleSidKey = 'en_US';
		user1.ProfileId=p.id;
		user1.EmailEncodingKey = 'ISO-8859-1';
		user1.LanguageLocaleKey = 'en_US';
		user.IsActive=true;
  	insert user1;

		Assignment_Queue__c aq=new Assignment_Queue__c();
		aq.Name='Assignment Queue UnitTest';
		aq.Active__c=true;
		insert aq;

		Assignment_Queue_Member__c aqm=new Assignment_Queue_Member__c();
		aqm.User__c=user.Id;
		aqm.User_Name__c=user.Name;
		aqm.Member_Active__c=true;
		aqm.Assignment_Queue__c=aq.Id;
		insert aqm;

		Assignment_Queue_Member__c aqm1=new Assignment_Queue_Member__c();
		aqm1.User__c=user1.Id;
		aqm1.User_Name__c=user1.Name;
		aqm1.Member_Active__c=true;
		aqm1.Assignment_Queue__c=aq.Id;
		insert aqm1;

		Assignment_Rule__c ar=new Assignment_Rule__c();
		ar.Name='Lead Assignment Rule UnitTest';
		ar.Active__c=true;
		ar.Related_Object__c='Lead';
		ar.Fire_On_Update__c=true;
		insert ar;

		Assignment_Rule_Entry__c are=new Assignment_Rule_Entry__c();
		are.Name='Lead Entry A UnitTest';
		are.Assignment_Rule__c=ar.Id;
		are.Order__c=1;
		are.Assign_To_Queue__c=aq.Id;
		are.Assign_To__c=aq.Id;
		are.Assign_To_Name__c=aq.Name;
		are.Assign_To_Object__c='Assignment_Queue__c';
		are.Criteria_Logic__c='1 AND 2';
		are.Criteria_Set__c='[{"order":1,"objectName":"Lead","fieldName":"Status","fieldDisplayName":"[Lead].Status","fieldType":"picklist","operator":"Equals","fieldValue":"Open - Not Contacted","lookupNameValue":"","fieldValueType":"","lastObjectName":"Lead","lastFieldName":"Status","referenceTo":""},{"order":2,"objectName":"Lead","fieldName":"Status","fieldDisplayName":"[Lead].Status","fieldType":"picklist","operator":"Does not equal","fieldValue":"Closed - Converted","lookupNameValue":"","fieldValueType":"","lastObjectName":"Lead","lastFieldName":"Status","referenceTo":""}]';
		insert are;

		Assignment_Rule__c ar1=new Assignment_Rule__c();
		ar1.Name='Conact Assignment Rule UnitTest';
		ar1.Active__c=true;
		ar1.Related_Object__c='Contact';
		ar1.Fire_On_Update__c=false;
		insert ar1;

		Assignment_Rule_Entry__c are1=new Assignment_Rule_Entry__c();
		are1.Name='Contact Entry A UnitTest';
		are1.Assignment_Rule__c=ar1.Id;
		are1.Order__c=1;
		are1.Assign_To_Queue__c=aq.Id;
		are1.Assign_To__c=aq.Id;
		are1.Assign_To_Name__c=aq.Name;
		are1.Assign_To_Object__c='Assignment_Queue__c';
		are1.Criteria_Logic__c='';
		are1.Criteria_Set__c='[{"order":1,"objectName":"Contact","fieldName":"Account.NumberOfEmployees","fieldDisplayName":"[Contact].Account.NumberOfEmployees","fieldType":"integer","operator":"Less than","fieldValue":"1","lookupNameValue":"","fieldValueType":"","lastObjectName":"Account","lastFieldName":"NumberOfEmployees","referenceTo":""},{"order":2,"objectName":"Contact","fieldName":"Account.NumberOfEmployees","fieldDisplayName":"[Contact].Account.NumberOfEmployees","fieldType":"integer","operator":"Less or equal","fieldValue":"1","lookupNameValue":"","fieldValueType":"","lastObjectName":"Account","lastFieldName":"NumberOfEmployees","referenceTo":""},{"order":3,"objectName":"Contact","fieldName":"Account.NumberOfEmployees","fieldDisplayName":"[Contact].Account.NumberOfEmployees","fieldType":"integer","operator":"Greater than","fieldValue":"1","lookupNameValue":"","fieldValueType":"","lastObjectName":"Account","lastFieldName":"NumberOfEmployees","referenceTo":""},{"order":4,"objectName":"Contact","fieldName":"Account.NumberOfEmployees","fieldDisplayName":"[Contact].Account.NumberOfEmployees","fieldType":"integer","operator":"Greater or equal","fieldValue":"1","lookupNameValue":"","fieldValueType":"","lastObjectName":"Account","lastFieldName":"NumberOfEmployees","referenceTo":""},{"order":5,"objectName":"Contact","fieldName":"AssistantName","fieldDisplayName":"[Contact].AssistantName","fieldType":"string","operator":"Starts with","fieldValue":"","lookupNameValue":"","fieldValueType":"","lastObjectName":"Contact","lastFieldName":"AssistantName","referenceTo":""},{"order":6,"objectName":"Contact","fieldName":"AssistantName","fieldDisplayName":"[Contact].AssistantName","fieldType":"string","operator":"Ends with","fieldValue":"","lookupNameValue":"","fieldValueType":"","lastObjectName":"Contact","lastFieldName":"AssistantName","referenceTo":""},{"order":7,"objectName":"Contact","fieldName":"AssistantName","fieldDisplayName":"[Contact].AssistantName","fieldType":"string","operator":"Contains","fieldValue":"","lookupNameValue":"","fieldValueType":"","lastObjectName":"Contact","lastFieldName":"AssistantName","referenceTo":""},{"order":8,"objectName":"Contact","fieldName":"AssistantName","fieldDisplayName":"[Contact].AssistantName","fieldType":"string","operator":"Does not contain","fieldValue":"","lookupNameValue":"","fieldValueType":"","lastObjectName":"Contact","lastFieldName":"AssistantName","referenceTo":""},{"order":9,"objectName":"Contact","fieldName":"Account.AccountSource","fieldDisplayName":"[Contact].Account.AccountSource","fieldType":"picklist","operator":"Equals","fieldValue":"","lookupNameValue":"","fieldValueType":"","lastObjectName":"Account","lastFieldName":"AccountSource","referenceTo":""},{"order":10,"objectName":"Contact","fieldName":"AccountId","fieldDisplayName":"[Contact].AccountId","fieldType":"reference","operator":"Does not equal","fieldValue":"","lookupNameValue":"","fieldValueType":"","lastObjectName":"Contact","lastFieldName":"AccountId","referenceTo":"Account"}]';
		insert are1;

		Assignment_Rule_Entry__c are2=new Assignment_Rule_Entry__c();
		are2.Name='Contact Entry B UnitTest';
		are2.Assignment_Rule__c=ar1.Id;
		are2.Order__c=2;
		are2.Assign_To_User__c=user.Id;
		are2.Assign_To__c=user.Id;
		are2.Assign_To_Object__c='User';
		are2.Criteria_Logic__c='';
		are2.Criteria_Set__c='[{"order":1,"objectName":"Contact","fieldName":"AssistantName","fieldDisplayName":"[Contact].AssistantName","fieldType":"string","operator":"Equals","fieldValue":"","lookupNameValue":"","fieldValueType":"","lastObjectName":"Contact","lastFieldName":"AssistantName","referenceTo":""}]';
		insert are2;
	}

}