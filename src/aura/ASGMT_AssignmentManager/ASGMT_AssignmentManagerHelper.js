({
  doInit: function(component) {

	},
  handleTabChangeEvt: function(component, event) {
		var objectName=event.getParam('tabId');
		component.set('v.objectName',objectName);
  }
})