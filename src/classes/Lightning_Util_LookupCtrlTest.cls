@isTest
private class Lightning_Util_LookupCtrlTest {
    @isTest static void testSearch() {
        // Create some accounts
        Account abc = new Account(Name = 'ABC Account');
        Account xyz = new Account(Name = 'XYZ Account');

        List<Account> accounts = new List<Account> { abc, xyz };

        insert accounts;

        Id[] fixedSearchResults = new Id[] { xyz.Id };
        Test.setFixedSearchResults(fixedSearchResults);
        List<Lightning_Util_LookupCtrl.Result> results = Lightning_Util_LookupCtrl.lookup('xy', 'Account', '', '', '');

        Lightning_Util_LookupCtrl.lookup('', 'Account', 'Name=\'xy\'', '', '');

        String rawSOQL = 'Select Id From Account Where Name=\'searchString\'';
        Lightning_Util_LookupCtrl.lookup('xy', 'Account', '', rawSOQL, '');
        Lightning_Util_LookupCtrl.lookup('xy', 'Account', '', rawSOQL, 'UnitTest');

        System.assertEquals(1, results.size());
        System.assertEquals(xyz.Name, results[0].SObjectLabel);
        System.assertEquals(xyz.Id, results[0].SObjectId);

   }
}