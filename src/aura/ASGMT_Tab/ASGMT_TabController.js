({
  handleOnActive: function(component, event, helper) {
    helper.injectComponentByTab(component, event);
    helper.destroyComponentByTab(component, event);
    //helper.swithTabContent(component, event);

    var ASGMT_TabEvt=$A.get("e.c:ASGMT_TabEvt");
    ASGMT_TabEvt.setParams({
      "tabId": event.getSource().get('v.id')
    });
    ASGMT_TabEvt.fire();
  },
})