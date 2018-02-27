({
  doInit: function(component) {
    var action = component.get("c.getConfig");
    // action.setStorable();
    var spinner = component.find('spinner');
    spinner.set('v.show', true);
    action.setCallback(this, function(response) {
      var config = response.getReturnValue();
      component.set("v.config", config);
      spinner.set('v.show', false);
    });
    $A.enqueueAction(action);
  },

  // handleASGMT_HeaderEvt: function(component, event) {
	// 	this.doInit(component);
	// },

  handleTabChangeEvt: function(component, event) {
		var objectName=event.getParam('tabId');
    // if(objectName.indexOf('__c')!=-1)
	  component.set('v.objectName',objectName);
  },

  handleASGMT_SettingEvt: function(component, event) {
    this.doInit(component);
  }
})