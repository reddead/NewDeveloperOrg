({
  handleOnActive: function(component, event) {
    var objectName=component.get('v.selectedTabId');

    if(objectName.indexOf('Assignment_Rule__c')!=-1){
      var config = component.get('v.config');
      var configurations = JSON.parse(config.configurationsJson);
  		if (configurations.length == 0) {
        this.fireASGMT_TabEvt(component, event, event.getSource().get('v.id'),'No Configuration');
        return;
      }
    }

    this.injectComponentByTab(component, event);
    this.destroyComponentByTab(component, event);

    this.fireASGMT_TabEvt(component, event, event.getSource().get('v.id'),'');
  },

  fireASGMT_TabEvt: function(component, event, tabId, tabMessage) {
    var ASGMT_TabEvt=$A.get("e.c:ASGMT_TabEvt");
    ASGMT_TabEvt.setParams({
      "tabId": tabId,
      "tabMessage": tabMessage
    });
    ASGMT_TabEvt.fire();
  },

  injectComponentByTab: function(component, event) {
    var tab = event.getSource();
    var attributes = {};
    switch (tab.get('v.id')) {
      case 'AssignmentSetting':
        attributes = {
          'config': component.get('v.config')
        };
        this.injectComponent(component, 'c:ASGMT_Setting', tab, attributes);
        break;
      case 'Assignment_Rule__c':
        attributes = {
          'config': component.get('v.config'),
          "filter": {
            Name: '',
            Related_Object__c: ''
          },
          "objectName": 'Assignment_Rule__c'
        };
        this.injectComponent(component, 'c:ASGMT_RecordTileList', tab, attributes);
        break;
      case 'Assignment_Queue__c':
        attributes = {
          'config': component.get('v.config'),
          "filter": {
            Name: ''
          },
          "objectName": 'Assignment_Queue__c'
        };
        this.injectComponent(component, 'c:ASGMT_RecordTileList', tab, attributes);
        break;
    }
  },
  injectComponent: function(component, name, target, attributes) {
    $A.createComponent(name, attributes, function(contentComponent, status, error) {
      if (status === "SUCCESS") {
        target.set('v.body', contentComponent);
      } else {
        throw new Error(error);
      }
    });
  },
  destroyComponentByTab: function(component, event) {
    var tab = event.getSource();
    var cmp;
    var cmp1;
    var activeTab;
    var inactiveTab;
    var parentBody;

    if (tab.get('v.id')) {
      switch (tab.get('v.id')) {
        case 'Assignment_Rule__c':
          inactiveTab = component.find('Assignment_Queue__c'); //destroy inactive tab component
          if (inactiveTab) {
            parentBody = inactiveTab.get('v.body');
            if (parentBody[0])
              cmp = parentBody[0].getConcreteComponent();
          }
          inactiveTab = component.find('AssignmentSetting'); //destroy inactive tab component
          if (inactiveTab) {
            parentBody = inactiveTab.get('v.body');
            if (parentBody[0])
              cmp1 = parentBody[0].getConcreteComponent();
          }
          break;
        case 'Assignment_Queue__c':
          inactiveTab = component.find('Assignment_Rule__c'); //destroy inactive tab component
          if (inactiveTab) {
            parentBody = inactiveTab.get('v.body');
            if (parentBody[0])
              cmp = parentBody[0].getConcreteComponent();
          }
          inactiveTab = component.find('AssignmentSetting'); //destroy inactive tab component
          if (inactiveTab) {
            parentBody = inactiveTab.get('v.body');
            if (parentBody[0])
              cmp1 = parentBody[0].getConcreteComponent();
          }
          break;
        case 'AssignmentSetting':
          inactiveTab = component.find('Assignment_Rule__c'); //destroy inactive tab component
          if (inactiveTab) {
            parentBody = inactiveTab.get('v.body');
            if (parentBody[0])
              cmp = parentBody[0].getConcreteComponent();
          }
          inactiveTab = component.find('Assignment_Queue__c'); //destroy inactive tab component
          if (inactiveTab) {
            parentBody = inactiveTab.get('v.body');
            if (parentBody[0])
              cmp1 = parentBody[0].getConcreteComponent();
          }
          break;
      }
    } else {
      var activeTabId = component.get('v.selectedTabId');
      activeTab = component.find(activeTabId); //destroy active tab component
      if (activeTab) {
        parentBody = activeTab.get('v.body');
        if (parentBody[0])
          cmp = parentBody[0].getConcreteComponent();
      }
    }
    if (cmp)
      cmp.destroy();
    if (cmp1)
      cmp1.destroy();
  }
})