({
	keyupHandler: function(component, event, helper) {
		var changeEvent = component.getEvent("onchange");
		changeEvent.setParams({
			"value": event.target.value
		});
		changeEvent.fire();

		//Directly call parent event, also works
		// var ruleFilterChangeEvent = $A.get("e.c:ASGMT_FilterEvt");
		// ruleFilterChangeEvent.setParams({
		// 	"searchKey": event.target.value
		// });
		// ruleFilterChangeEvent.fire();
	},
	clearHandler: function(component, event, helper) {
		component.find("searchInput").getElement().value = "";
		var changeEvent = component.getEvent("onchange");
		changeEvent.setParams({
			"value": ""
		});
		changeEvent.fire();
	},
	resetFilterName:function(component, event, helper) {
		var searchInput=component.find("searchInput").getElement();
		if(searchInput)
			searchInput.value = "";
	}

})