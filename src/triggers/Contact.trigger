Trigger Contact on Contact (before insert, after insert, before update, after update) {

		if(System_TriggerControlVariables.contact_ShouldExecute) {
				if(Trigger.isUpdate&&System_FeatureAssignmentRule.isAssignmentRuleRunning)
						return;

				System_TriggerFactory.createHandler(System_TriggerHandlerContact.class);
		}
}