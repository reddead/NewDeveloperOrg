Trigger Contact on Contact (before insert, after insert, before update, after update) {

		if(System_TriggerControlVariables.contact_ShouldExecute) {
				System_TriggerFactory.createHandler(System_TriggerHandlerContact.class);
		}
}