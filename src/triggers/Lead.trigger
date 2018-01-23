trigger Lead on Lead (before insert, before update, after insert, after update) {

		if(System_TriggerControlVariables.lead_ShouldExecute) {
				if(Trigger.isUpdate&&System_FeatureAssignmentRule.isAssignmentRuleRunning)
						return;

				System_TriggerFactory.createHandler(System_TriggerHandlerLead.class);
		}

}