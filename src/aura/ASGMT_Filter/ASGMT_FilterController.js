({
  searchKeyChangeHandler: function(component, event, helper) {
    var filterChangeEvent = $A.get("e.c:ASGMT_FilterEvt");
    var objectName=component.get('v.objectName');
    filterChangeEvent.setParams({
      "objectName": objectName,
      "Name": event.getParam("value")
    });
    filterChangeEvent.fire();
  },

  relatedObjectChangeHandler: function(component, event, helper) {
    var filterChangeEvent = $A.get("e.c:ASGMT_FilterEvt");
    var objectName=component.get('v.objectName');
    filterChangeEvent.setParams({
      "objectName": objectName,
      "Related_Object__c": event.getParam("value")
    });
    filterChangeEvent.fire();
  },
  setObjectName: function(component, event, helper) {
		var tabId = event.getParam('tabId');//tabId is set to objectName
    component.set('v.objectName',tabId);
	}
})