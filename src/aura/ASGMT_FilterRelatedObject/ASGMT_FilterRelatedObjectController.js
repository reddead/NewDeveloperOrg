({
  doInit: function(component, event, helper) {
    // var objectNames = ['', 'Lead', 'Contact', 'Enrollment_Opportunity__c'];
    // if (objectNames) {
    //   component.set("v.objectNames", objectNames);
    // } else {
    //   helper.loadObjectNames(component);
    // }

    var action = component.get("c.getAssignmentRuleObjectOptions");
    action.setStorable();
    action.setCallback(this, function(response) {
      var result = response.getReturnValue();
      component.set("v.objectNames", result);
    });
    $A.enqueueAction(action);

  },

  changeHandler: function(component, event, helper) {
    var changeEvent = component.getEvent("onchange");
    changeEvent.setParams({
      "value": component.get("v.selectedValue")
    });
    changeEvent.fire();
  }

})