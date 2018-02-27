global with sharing class System_FeatureManager {

		global static void performTask(Type t){
				Savepoint sp = Database.setSavePoint();
				try {
						// Get a handler appropriate to the object being processed
						System_IFeature objFeature = getFeatureExecutor(t);
						// Make sure we have a handler registered, new handlers must be registered in the getHandler method.
						if (objFeature == null) {
								// Trigger.new[0].addError(aaaa);
								Trigger.new[0].addError('No such feature executor found : ' + t.getName());
								return;
						}

						// check feature permission
						if(!checkPermission(t.getName())) {
								Trigger.new[0].addError('Insufficient privilege to use feature: ' + t.getName());
								return;
						}

						// check feature permission
						if(!checkFeatureRule(t.getName()))
							return;

						// Execute the handler to fulfil the trigger
						objFeature.execute();
				} catch(Exception e) {
						Database.rollback(sp);
				}
		}

		private static Boolean checkFeatureRule(string fnName){

      return true;
    }


		private static Boolean checkPermission(string fmName){

				Feature_Manager__c fm = Feature_Manager__c.getInstance();

				//hirerchical custom setting returns new object
				if(fm == null || (fm != null && fm.Name == null)) {
						Trigger.new[0].addError('No record found within Feature Manager custom settings');
						return false;
				}

				//Getting setting name from class name
				String settingName = (fmName.replaceAll('System_Feature', '') + '__c');
				//system.assert(false, fmName+ '***' +settingName);
				return (Boolean)fm.get(settingName);
		}

		private static System_IFeature getFeatureExecutor(Type t)
		{
				Object obj = t.newInstance();

				// if its not an instance of ITrigger return null
				if (!(obj instanceOf System_IFeature))
				{
						Trigger.new[0].addError('Need to implement System_IFeature for class : ' + t.getName());
						return null;
				}

				return (System_IFeature)obj;
		}
}