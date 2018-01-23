({
  /**
   * load selected value in init
   */

  doInit: function(cmp, event, helper) {
    helper.doInit(cmp);
  },

  handleRecordUpdated: function(cmp, event, helper) {
    helper.handleRecordUpdated(cmp,event);
  },
  /**
   * Search an SObject for a match
   */
  search: function(cmp, event, helper) {
    // console.log('in search');
    helper.doSearch(cmp,false);
  },

  showDefaultOptionList: function(cmp, event, helper) {
    helper.showDefaultOptionList(cmp);
  },

  hideOptionList: function(cmp, event, helper) {
    helper.hideOptionList(cmp, event);
  },

  /**
   * Select an SObject from a list
   */
  select: function(cmp, event, helper) {
    // console.log('in select');
    helper.handleSelection(cmp, event);
  },

  /**
   * Clear the currently selected SObject
   */
  clear: function(cmp, event, helper) {
    // console.log('in clear');
    helper.clearSelection(cmp, event);
  },
})