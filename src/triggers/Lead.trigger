trigger Lead on Lead (before insert, before update, after insert, after update) {

		if(System_TriggerControlVariables.lead_ShouldExecute) {
				System_TriggerFactory.createHandler(System_TriggerHandlerLead.class);
		}

}