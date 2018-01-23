@isTest
public class NGD_DataControllerTest{

    public static sObject contact;
    public static sObject app;
    // public static Env__c env;
    public static User adminUser;

    private static String tooLongAccName = 'LOTS OF ' +
                                           'CHARACTERS XXXXXXXXXXXXXXXXXXXXXXXX' +
                                           'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' +
                                           'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' +
                                           'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' +
                                           'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' +
                                           'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' +
                                           'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' +
                                           'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' +
                                           'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' +
                                           'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' +
                                           'XXXXXXXXXXXXXXXX';

    static private void assertError(String jsonResult, String expectedError, String method) {
        system.debug('##################' + jsonResult);
        List<Object> errorArray = (List<Object>)JSON.deserializeUntyped(jsonResult);

        System.assertNotEquals(null, errorArray,
                               'error array missing from ' + method + ' result');
        System.assertNotEquals(0, errorArray.size(),
                               'error array is empty in ' + method + ' result');

        Map<String, Object> error = (Map<String, Object>)errorArray[0];
        String errorCode = (String)error.get('errorCode');
        System.assertNotEquals(null, errorCode,
                               'errorCode property missing from ' + method + ' result');
        System.assertEquals(expectedError, errorCode,
                            'errorCode should be ' + expectedError + ' in ' + method + ' result');
    }

    static testMethod void testDescribe() {
        // Assume we have accounts
        String jsonResult = NGD_DataController.describe('Account');

        System.assertNotEquals(null, jsonResult,
                               'NGD_DataController.describe returned null');

        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);

        System.assertNotEquals(null, result.get('fields'),
                               'fields property missing from NGD_DataController.describe result');

        // TODO - more assertions on describe results

        // Invalid object type
        // Hope there isn't a QXZXQZXZQXZQ object type!
        jsonResult = NGD_DataController.describe('QXZXQZXZQXZQ');
        assertError(jsonResult, 'NOT_FOUND', 'NGD_DataController.describe');
    }

    static private void assertRecord(Map<String, Object> record, String accName, String accNumber, String method) {
        Map<String, Object> attributes = (Map<String, Object>)record.get('attributes');
        System.assertNotEquals(null, attributes,
                               'attributes property missing from ' + method + ' result');
        System.assertNotEquals(0, attributes.keySet().size(),
                               'empty attributes object in ' + method + ' result');

        String type = (String)attributes.get('type');
        System.assertNotEquals(null, type,
                               'type property missing from ' + method + ' result');
        System.assertEquals('Account', type,
                            'Wrong type in ' + method + ' result');

        String url = (String)attributes.get('url');
        System.assertNotEquals(null, url,
                               'url property missing from ' + method + ' result');

        Id id = (Id)record.get('Id');
        System.assertNotEquals(null, id,
                               'Id property missing from ' + method + ' result');
        Account account = [SELECT Id, Name FROM Account WHERE Id = :id LIMIT 1];
        System.assertNotEquals(null, account,
                               'Couldn\'t find account record identified by ' + method + ' result');
        System.assertEquals(accName, account.Name,
                            'Account name doesn\'t match in ' + method + ' result');

        String name = (String)record.get('Name');
        System.assertNotEquals(null, name,
                               'Name property missing from ' + method + ' result');
        System.assertEquals(accName, name,
                            'Wrong account name in ' + method + ' result');

        String accountNumber = (String)record.get('AccountNumber');
        System.assertNotEquals(null, name,
                               'AccountNumber property missing from ' + method + ' result');
        System.assertEquals(accNumber, accountNumber,
                            'Wrong account number in ' + method + ' result');
    }


    static private void testDelete(Id id) {
        String jsonResult = NGD_DataController.del('QXZXQZXZQXZQ', id);
        assertError(jsonResult, 'NOT_FOUND', 'NGD_DataController.del');

        jsonResult = NGD_DataController.del('Account', id);
        system.debug('$$$$$$$$$$$$' + jsonResult);
        System.assertEquals(null, jsonResult,
                            'Non-null result from NGD_DataController.del');
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id = :id];
        System.assertEquals(0, accounts.size(),
                            'Account record was not deleted by NGD_DataController.del');

        jsonResult = NGD_DataController.del('Account', id);
        assertError(jsonResult, 'ENTITY_IS_DELETED', 'NGD_DataController.del');
    }

    static testMethod void testCRUD() {
        prepareData();

        Account acc=new Account();
        acc.Name='testDante';
        insert acc;
        testDelete(acc.id);

        Account acc1=new Account();
        acc1.Name='testDante123';
        acc1.accountNumber='testDante123';
        insert acc1;

        Account acc2=new Account();
        acc2.Name='testDante1234';
        acc1.accountNumber='testDante1234';
        insert acc2;

        list<Account> accList=new list<Account>();
        accList.add(acc2);

        NGD_DataController.query('Account','','','Name=\'testDante123\'');
        NGD_DataController.query('Account','Name','CreatedById','Name=\'testDante123\'');


        Contact c=new Contact();
        c.LastName='testDante';
        insert c;

        Homepage_Widget__c hw=new Homepage_Widget__c();
        hw.Name='Test Widget';
        insert hw;

        NGD_DataController.sObjectKlone(c.Id);
        NGD_DataController.sObjectKlone('fakeId');
        NGD_DataController.sObjectKlone(acc1.Id);
        NGD_DataController.sObjectKlone(hw.Id);

        String accJSON=String.escapeSingleQuotes(JSON.serialize(acc1));
        NGD_DataController.upsertData('Account',accJSON);

        String accListJSON=String.escapeSingleQuotes(JSON.serialize(accList));
        NGD_DataController.upsertDataBulk('Account',accListJSON);
    }

    static testMethod void testMisc() {
        prepareData();

        System.runAs(adminUser){
            String namespacePrefixClass=NGD_DataController.namespacePrefixClass;
            String namespacePrefix=NGD_DataController.namespacePrefix;
            String criteriaObjectList=NGD_DataController.criteriaObjectList;
            String describeResultsJSON=NGD_DataController.describesJson;


            List<String> objTypes=new List<String>();
            objTypes.add('Fake_Object');
            NGD_DataController.describes(objTypes);

            NGD_DataController.processChecklistCotents((String)app.get('Id'));//
        }
    }

    public static void prepareData() {

        Account a = new Account(Name='Test Account Name');
        insert a;

        contact=Schema.getGlobalDescribe().get('Contact').getDescribe().getSobjectType().newSObject();
        contact.put('FirstName','testDante');
        contact.put('LastName','testDante');
        contact.put('Email','testDante@testDante.com');
        contact.put('AccountId',a.Id);
        insert contact;

        Profile p=[select id from Profile where Name='System Administrator'];

        adminUser = new User();
        adminUser.Username ='testDanteadminUser@testDante.com';
        adminUser.LastName = 'testDanteadminUser';
        adminUser.Email = 'testDanteadminUser@testDante.com';
        adminUser.alias = 'tadmin';
        adminUser.TimeZoneSidKey = 'America/Chicago';
        adminUser.LocaleSidKey = 'en_US';
        adminUser.ProfileId=p.id;
        adminUser.EmailEncodingKey = 'ISO-8859-1';
        adminUser.LanguageLocaleKey = 'en_US';
        insert adminUser;


        app=Schema.getGlobalDescribe().get('Application__c').getDescribe().getSobjectType().newSObject();
        app.put('Contact__c',contact.Id);
        app.put('Admissions_Status__c','Inquiry');
        insert app;

        Homepage_Widget_Layout__c hwl=new Homepage_Widget_Layout__c();
        hwl.Name='testLayoutDante';
        hwl.Displaying_Application_Status__c='Inquiry';
        hwl.Is_Active__c=true;
        hwl.Field_Reference__c='contact.Name;contact.Active_Enrollment_Opportunity__r.Name;application.Admissions_Status__c;application.Program_of_Interest__r.Name;';
        insert hwl;
        contact.put('Active_Application__c',app.Id);
        update contact;


        Homepage_Widget_Layout__c hwlDefault=new Homepage_Widget_Layout__c();
        hwlDefault.Name='Default';
        hwlDefault.Default__c=true;
        hwlDefault.Displaying_Application_Status__c='Inquiry';
        hwlDefault.Is_Active__c=true;
        hwlDefault.Field_Reference__c='contact.Name;contact.Active_Enrollment_Opportunity__r.Name;application.Admissions_Status__c;application.Program_of_Interest__r.Name;';
        insert hwlDefault;

        Homepage_Widget_Layout__c hwl1=new Homepage_Widget_Layout__c();
        hwl1.Name='Test1';
        hwl1.Displaying_Application_Status__c='Inquiry';
        hwl1.Is_Active__c=true;
        hwl1.Criteria_Filter_Logic__c='( 1 AND 2 AND 3 ) or 4';
        hwl1.Field_Reference__c='contact.Name;contact.Active_Enrollment_Opportunity__r.Name;application.Admissions_Status__c;application.Program_of_Interest__r.Name;';
        hwl1.Criteria__c='[{"order":1,"objectName":"Application__c","fieldName":"Admissions_Status__c","referenceFieldName":"","operator":"equals","value":"Inquiry"},{"order":2,"objectName":"Application__c","fieldName":"Contact__c","referenceFieldName":"FirstName","operator":"contains","value":"Dante","referenceObjectName":"Contact"},{"order":4,"objectName":"Application__c","fieldName":"Contact__c","referenceFieldName":"LastName","operator":"contains","value":"Dante","referenceObjectName":"Contact"},{"order":4,"objectName":"Application__c","fieldName":"Admissions_Status__c","referenceFieldName":"","operator":"not equal to","value":""}]';
        insert hwl1;

        Homepage_Widget_Layout__c hwl2=new Homepage_Widget_Layout__c();
        hwl2.Name='Test2';
        hwl2.Displaying_Application_Status__c='Inquiry';
        hwl2.Is_Active__c=true;
        hwl2.Field_Reference__c='contact.Name;contact.Active_Enrollment_Opportunity__r.Name;application.Admissions_Status__c;application.Program_of_Interest__r.Name;';
        hwl2.Criteria__c='[{"order":1,"objectName":"Application__c","fieldName":"Admissions_Status__c","referenceFieldName":"","operator":"starts with","value":"Inquiry"},{"order":2,"objectName":"Application__c","fieldName":"Contact__c","referenceFieldName":"FirstName","operator":"ends with","value":"Dante","referenceObjectName":"Contact"},{"order":4,"objectName":"Application__c","fieldName":"Contact__c","referenceFieldName":"LastName","operator":"does not contain","value":"Dante","referenceObjectName":"Contact"},{"order":4,"objectName":"Application__c","fieldName":"Admissions_Status__c","referenceFieldName":"","operator":"not equal to","value":""}]';
        insert hwl2;
    }

    public static void prepareData1() {
        Homepage_Widget__c hw1=new Homepage_Widget__c();
        hw1.Name='test HW1';
        hw1.Number__c='W1';
        hw1.Is_Active__c=true;
        insert hw1;
    }

    public static void prepareData2() {
        Homepage_Widget__c hw=new Homepage_Widget__c();
        hw.Name='test Default';
        hw.Default__c=true;
        hw.Number__c='W1';
        hw.Is_Active__c=true;
        insert hw;
    }

    public static void prepareData3() {
        Homepage_Widget__c hw2=new Homepage_Widget__c();
        hw2.Name='test HW2';
        hw2.Number__c='W1';
        hw2.Is_Active__c=true;
        hw2.Criteria__c='[{"order":1,"objectName":"Application__c","fieldName":"Program_Offered__c","referenceFieldName":"Name","operator":"not equal to","value":"","referenceObjectName":"Program_Offered__c"}]';
        insert hw2;
    }

}