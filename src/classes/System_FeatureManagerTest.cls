@isTest
private class System_FeatureManagerTest {

		@isTest static void test_method_one() {

				Feature_Manager__c fm = Feature_Manager__c.getOrgDefaults();
				if (fm == null) {
						fm = new Feature_Manager__c();
				}
				fm.AssignmentRule__c = true;
				upsert fm;
				system.assertEquals(true, fm.AssignmentRule__c);

				//This will execute
				System_FeatureManager.performTask(System_FeatureAssignmentRule.class);

				//This will not execute
				//System_FeatureManager.performTask(.class);

				//A class without implementing Icorefeature
				System_FeatureManager.performTask(System_TriggerHandlerLead.class);

				//Custom setting is not defined
				//System_FeatureManager.performTask(.class);
		}

}