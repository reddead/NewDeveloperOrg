({
  nameSpacePrefix: '',
  Util_Spinner: null,

  doInit: function(component) {
    this.nameSpacePrefix = component.get('v.config').nameSpacePrefix;
    this.Util_Spinner = component.find('Util_Spinner');

    this.createLookup(component, component.get('v.relatedObject'));

    window.setTimeout(
      $A.getCallback(function() {
        component.set('v.open', true);
      }), 0);

    component.set("v.cssStyle", ".forceStyle .viewport .oneHeader.slds-global-header_container {z-index:0;} .forceStyle.desktop .viewport{overflow:hidden}");
  },

  handleUtil_LookupEvt: function(component, event) {
    var type = event.getParam('type');
    var lookupList;
    if (type == 'LOOKUP_CHANGE') {
      var isReferenceTo = event.getParam('cIsReferenceTo');
      var relatedObject = event.getParam('cReferenceTo');
      if (isReferenceTo) {
        lookupList = component.find('LookupListPlaceHolder').get('v.body');
        var lookupCounter = 0;
        lookupList.forEach(function(lookup) {
          if (lookup.isValid())
            lookupCounter++;
        });

        if (lookupCounter < 6) {
          lookupCounter++;
          this.createLookup(component, relatedObject, lookupCounter);
        }
      }
      //final field selected
      else {
        var cFieldType = event.getParam('cFieldType');
        var cLastObjectName = event.getParam('cLastObjectName');
        var cLastFieldName = event.getParam('cLastFieldName');

        component.set('v.cFieldType', cFieldType);
        if (cFieldType == 'reference')
          component.set('v.cReferenceTo', relatedObject);
        component.set('v.cLastObjectName', cLastObjectName);
        component.set('v.cLastFieldName', cLastFieldName);

        component.find('SaveButton').getElement().disabled = false;
      }

    } else if (type == 'LOOKUP_CLEAR') {
      var globalId = event.getParam('globalId');

      lookupList = component.find('LookupListPlaceHolder').get('v.body');
      var isRight = false;
      lookupList.forEach(function(lookup) {
        if (isRight) {
          lookup.destroy();
        } else if (globalId === lookup.getGlobalId()) {
          isRight = true;
        }
      });
      component.find('SaveButton').getElement().disabled = true;
    }
  },

  defaultCloseAction: function(component) {
    component.set('v.open', false);
    window.setTimeout(
      $A.getCallback(function() {
        component.destroy();
      }), 500);
  },

  save: function(component) {
    this.Util_Spinner.set('v.show', true);

    var cFieldName = '';
    var lookupList = component.find('LookupListPlaceHolder').get('v.body');
    lookupList.forEach(function(lookup) {
      if (lookup.isValid())
        cFieldName += lookup.find('lookup').getElement().value + '.';
    });
    cFieldName = cFieldName.substr(0, cFieldName.length - 1);

    var cIndex = component.get('v.cIndex');
    var cObjectName = component.get('v.relatedObject');
    var cFieldType = component.get('v.cFieldType');
    var cLastObjectName = component.get('v.cLastObjectName');
    var cLastFieldName = component.get('v.cLastFieldName'); //none merge field
    var cReferenceTo = component.get('v.cReferenceTo');

    var criteriaSet = component.get('v.criteriaSet');

    if (cObjectName)
      criteriaSet[cIndex].objectName = cObjectName;
    else
      criteriaSet[cIndex].objectName = '';

    if (cFieldName)
      criteriaSet[cIndex].fieldName = cFieldName;
    else
      criteriaSet[cIndex].fieldName = '';

    if (cObjectName && cFieldName)
      criteriaSet[cIndex].fieldDisplayName = '[' + cObjectName + '].' + cFieldName;
    else
      criteriaSet[cIndex].fieldDisplayName = '';

    if (cFieldType)
      criteriaSet[cIndex].fieldType = cFieldType;
    else
      criteriaSet[cIndex].fieldType = '';

    if (cLastObjectName) {
      criteriaSet[cIndex].lastObjectName = cLastObjectName;
      // criteriaSet[cIndex].lastObjectNameL = cLastObjectName.toLowerCase();
    } else {
      criteriaSet[cIndex].lastObjectName = '';
      // criteriaSet[cIndex].lastObjectNameL = '';
    }

    if (cLastFieldName)
      criteriaSet[cIndex].lastFieldName = cLastFieldName;
    else
      criteriaSet[cIndex].lastFieldName = '';

    if (cFieldType == 'reference') {
      if (cReferenceTo) {
        criteriaSet[cIndex].referenceTo = cReferenceTo;
        // criteriaSet[cIndex].referenceToL = cReferenceTo.toLowerCase();
      }
    } else {
      criteriaSet[cIndex].referenceTo = '';
      // criteriaSet[cIndex].referenceToL = '';
    }

    if (cFieldType == 'picklist' || cFieldType == 'multipicklist')
      criteriaSet[cIndex].options = this.setCriteriaOptions(component, cLastObjectName, cLastFieldName);
    else
      criteriaSet[cIndex].options = '';

    criteriaSet[cIndex].operator = '';
    criteriaSet[cIndex].fieldValue = '';
    criteriaSet[cIndex].lookupNameValue = '';
    criteriaSet[cIndex].toggle = this.setToggle(criteriaSet[cIndex].toggle);

    if (cFieldName && criteriaSet[criteriaSet.length - 1].fieldName)
      criteriaSet = this.newCriteria(component, criteriaSet);

    component.set('v.criteriaSet', criteriaSet);

    this.defaultCloseAction(component);
  },

  createLookup: function(component, relatedObject, lookupCounter) {
    var config = component.get('v.config');
    var sObjectDescribes = JSON.parse(config.sObjectDescribesJson);

    var sObjectDescribe=null;
		if(relatedObject.indexOf('__c')!=-1&&relatedObject.indexOf(config.nameSpacePrefix)==-1)
    	sObjectDescribe = this.getDescribe(sObjectDescribes, config.nameSpacePrefix + relatedObject);
		else
			sObjectDescribe = this.getDescribe(sObjectDescribes, relatedObject);

    var pluralLabel = sObjectDescribe.sObjectLabel;

    var relatedObjectFieldOptions;
    if (lookupCounter == 6)
      relatedObjectFieldOptions = this.getFieldOptions(sObjectDescribes, relatedObject, 'reference');
    else
      relatedObjectFieldOptions = this.getFieldOptions(sObjectDescribes, relatedObject);

    $A.createComponent(
      "c:Util_Lookup", {
        'aura:id': 'type-ahead',
        'class': 'slds-size_1-of-1 slds-medium-size--1-of-3',
        "pluralLabel": pluralLabel + ' Fields',
        "data": relatedObjectFieldOptions
      },
      function(lookupComponent, status) {
        if (status === "SUCCESS") {
          var targetCmp = component.find('LookupListPlaceHolder');
          var body = targetCmp.get("v.body");
          body.push(lookupComponent);
          targetCmp.set("v.body", body);
        }
      }
    );
  },

  setToggle: function(toggle) {
    if (toggle == undefined)
      toggle = true;
    else
      toggle = toggle ? false : true;

    return toggle;
  },

  setCriteriaOptions: function(component, cLastObjectName, cLastFieldName) {
    var config = component.get("v.config");
    var sObjectDescribes = JSON.parse(config.sObjectDescribesJson);

    var sObjectDescribe=null;
		if(cLastObjectName.indexOf('__c')!=-1&& config.nameSpacePrefix &&cLastObjectName.indexOf(config.nameSpacePrefix)==-1)
    	sObjectDescribe = this.getDescribe(sObjectDescribes, config.nameSpacePrefix + cLastObjectName);
		else
			sObjectDescribe = this.getDescribe(sObjectDescribes, cLastObjectName);

    var sObjectFieldMap = this.getFieldMap(sObjectDescribe, 'picklist, multipicklist');
    var sObjectPicklistOptionsMap = this.getPicklistOptionsMap(sObjectFieldMap); //, true, '--None--', ''

    if(cLastFieldName.indexOf('__c')!=-1&& config.nameSpacePrefix &&cLastFieldName.indexOf(config.nameSpacePrefix)==-1)
      return sObjectPicklistOptionsMap[config.nameSpacePrefix + cLastFieldName];
    else
      return sObjectPicklistOptionsMap[cLastFieldName];
  },

  newCriteria: function(component, criteriaSet) {
    var criteria = {};
    criteria.order = criteriaSet.length + 1;
    criteria.objectName = component.get('v.relatedObject');
    criteria.fieldName = '';
    criteria.fieldDisplayName = '';
    criteria.fieldType = '';
    criteria.operator = '';
    criteria.fieldValue = '';
    criteria.lookupNameValue = '';
    criteria.fieldValueType = '';
    criteria.lastObjectName = '';
    criteria.lastFieldName = '';
    criteria.toggle = false;
    criteria.referenceTo = '';
    criteriaSet.push(criteria);
    return criteriaSet;
  },
})