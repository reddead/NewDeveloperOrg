({
  doInit: function(component, event, helper) {
    helper.doInit(component);
  },

  defaultCloseAction: function(component, event, helper) {
    helper.defaultCloseAction(component);
  },

  handleRecordUpdated: function(component, event, helper) {
    helper.handleRecordUpdated(component,event);
  },

  save: function(component, event, helper) {
    helper.save(component);
  },

  selectField: function(component, event, helper) {
    helper.selectField(component, event);
  },

  clearField: function(component, event, helper) {
    helper.clearField(component, event);
  },

  clearCustomFieldError: function(component, event, helper) {
    helper.clearCustomFieldError(component, event);
  },
})