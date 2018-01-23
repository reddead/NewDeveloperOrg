({
  /**
   * Hide not related elements if value is already assigned
   * on load
   */


  doInit: function(cmp) {
    var sObjectAPIName = cmp.get('v.sObjectAPIName');
    var searchString = cmp.get("v.searchString");
    var value = cmp.get('v.value');
    var lookupNameValue = cmp.get('v.lookupNameValue');
    if (sObjectAPIName && value && lookupNameValue) {
      //init selected item
      searchString = lookupNameValue;
      cmp.set("v.searchString", searchString);
    }

    if (sObjectAPIName) {
      //init icon
      var config = cmp.get("v.config");
      var sObjectDescribes = JSON.parse(config.sObjectDescribesJson);

      var sObjectDescribe=null;
  		if(sObjectAPIName.indexOf('__c')!=-1&& config.nameSpacePrefix &&sObjectAPIName.indexOf(config.nameSpacePrefix)==-1)
      	sObjectDescribe = this.getDescribe(sObjectDescribes, config.nameSpacePrefix + sObjectAPIName);
  		else
  			sObjectDescribe = this.getDescribe(sObjectDescribes, sObjectAPIName);

      cmp.set('v.listIconSVGPath', sObjectDescribe.iconSVGPath);
      if (sObjectDescribe.iconColor)
        cmp.set('v.listIconColor', sObjectDescribe.iconColor);
      else
        cmp.set('v.listIconColor', '6b9ee2');

      cmp.set('v.pluralLabel', sObjectDescribe.sObjectLabelPlural);
    }

    if (!$A.util.isEmpty(searchString)) {
      // Hide the Lookup List
      var lookupList = cmp.find('lookuplist');
      $A.util.addClass(lookupList, 'slds-hide');
      // MO: fix for slds202
      $A.util.removeClass(lookupList, 'slds-show');

      // Hide the Input Element
      var inputElement = cmp.find('lookup');
      $A.util.addClass(inputElement, 'slds-hide');
      // MO: fix for slds202
      $A.util.removeClass(inputElement, 'slds-show');

      // Show the Lookup pill
      var lookupPill = cmp.find('lookup-pill');
      $A.util.removeClass(lookupPill, 'slds-hide');
      // MO: fix for slds202
      $A.util.addClass(lookupPill, 'slds-show');

      // Lookup Div has selection
      inputElement = cmp.find('lookup-div');
      $A.util.addClass(inputElement, 'slds-has-selection');
    }

    this.registerDocumentClickEvent(cmp);

  },
  /**
   * Perform the SObject search via an Apex Controller
   */
  showDefaultOptionList: function(cmp) {
    var searchString = cmp.get('v.searchString');
    var sObjectAPIName = cmp.get('v.sObjectAPIName');

    if (!searchString && !sObjectAPIName) {
      var fieldOptions = cmp.get('v.data');
      cmp.set('v.matches', fieldOptions);

      var lookupList = cmp.find('lookuplist');

      // Show the lookuplist
      $A.util.removeClass(lookupList, 'slds-hide');
      // MO: fix for slds202
      $A.util.addClass(lookupList, 'slds-show');
    } else
      this.doSearch(cmp, true);

  },

  hideOptionList: function(cmp, event) {
    if (event.getSource().get('v.class') == 'slds-input') {
      var lookupList = cmp.find('lookuplist');
      //Hide the lookuplist
      $A.util.addClass(lookupList, 'slds-hide');
      // MO: fix for slds202
      $A.util.removeClass(lookupList, 'slds-show');
    }
  },

  highlightHint: function(testStr, searchString, hFieldName) {
    var regex = new RegExp(searchString, 'gi');
    var m;
    if ((m = regex.exec(testStr)) !== null) {
      var strBefore = '';
      if (m.index != 0)
        strBefore = testStr.substr(0, m.index);
      var str = testStr.substr(m.index, searchString.length);
      var strAfter = '';
      strAfter = testStr.substr(m.index + searchString.length);

      hFieldName += strBefore + '<strong>' + str + '</strong>';
      return this.highlightHint(strAfter, searchString, hFieldName);
    } else {
      if (hFieldName !== testStr)
        hFieldName += testStr;
      return hFieldName;
    }
  },

  doSearch: function(cmp, isOnclick) {
    // Get the search string, input element and the selection container
    //var searchString = cmp.get('v.searchString');
    var inputElement = cmp.find('lookup');
    var searchString = '';
    if (inputElement.getElement())
      searchString = inputElement.getElement().value;
    cmp.set('v.searchString', searchString);

    var lookupList = cmp.find('lookuplist');
    var whereClause = cmp.get('v.whereClause');
    var rawSOQL = cmp.get('v.rawSOQL');
    var context = cmp.get('v.context');

    // Clear any errors and destroy the old lookup items container
    //inputElement.set('v.errors', null);

    // console.log('searchString', searchString);

    // We need at least 2 characters for an effective search
    // if (typeof searchString === 'undefined' || searchString.length < 1) {
    // 	// Hide the lookuplist
    // 	$A.util.addClass(lookupList, 'slds-hide');
    // 	// MO: fix for slds202
    // 	$A.util.removeClass(lookupList, 'slds-show');
    // 	return;
    // }

    // Show the lookuplist
    $A.util.removeClass(lookupList, 'slds-hide');

    // MO: fix for slds202
    $A.util.addClass(lookupList, 'slds-show');

    // Get the API Name
    var sObjectAPIName = cmp.get('v.sObjectAPIName');
    var self = this;

    if (!sObjectAPIName) {
      var fieldOptions = cmp.get('v.data');
      var matches = [];


      fieldOptions.forEach(function(fieldOption) {
        if (!searchString) {
          fieldOption.hLabel = '';
          matches.push(fieldOption);
        }
        //highlight hint
        else {
          var hFieldNameOrigin = fieldOption.fieldName + ' - ' + fieldOption.fieldType;
          var hFieldName = self.highlightHint(hFieldNameOrigin, searchString, '');
          // var hFieldName = self.highlightHint(fieldOption.fieldName, searchString, '');
          if (hFieldName !== hFieldNameOrigin) { //fieldOption.fieldName
            // fieldOption.hLabel = '[' + fieldOption.objectName + '].' + hFieldName + ' - ' + fieldOption.fieldType;
            if (fieldOption.isReferenceTo)
              fieldOption.hLabel = '[' + fieldOption.objectName + '].' + hFieldName + ' >>>';
            else
              fieldOption.hLabel = '[' + fieldOption.objectName + '].' + hFieldName;
            matches.push(fieldOption);
          }
        }
      });
      cmp.set('v.matches', matches);
    } else {
      //remove error when searchString change
      if (!isOnclick)
        cmp.set('v.error', null);

      // Create an Apex action
      var action = cmp.get('c.lookup');

      // Mark the action as abortable, this is to prevent multiple events from the keyup executing
      action.setAbortable();

      // Set the parameters
      action.setParams({
        'searchString': searchString,
        'sObjectAPIName': sObjectAPIName,
        'whereClause': whereClause,
        'rawSOQL': rawSOQL,
        'context': context
      });

      // Define the callback
      action.setCallback(this, function(response) {
        var state = response.getState();
        // console.log('response', response);
        // Callback succeeded
        if (cmp.isValid() && state === 'SUCCESS') {
          // Get the search matches
          var matches = response.getReturnValue();

          // If we have no matches, return nothing
          if (matches.length == 0) {
            cmp.set('v.matches', null);
            return;
          }

          //highlight hint
          matches.forEach(function(match) {
            if (!searchString)
              match.hSObjectLabel = match.SObjectLabel;
            else
              match.hSObjectLabel = self.highlightHint(match.SObjectLabel, searchString, '');
          });

          // Store the results
          cmp.set('v.matches', matches);
        } else if (state === 'ERROR') { // Handle any error by reporting it
          var errors = response.getError();

          if (errors) {
            if (errors[0] && errors[0].message) {
              this.displayToast('Error', errors[0].message);
            }
          } else {
            this.displayToast('Error', 'Unknown error.');
          }
        }
      });

      // Enqueue the action
      $A.enqueueAction(action);
    }
  },

  registerDocumentClickEvent: function(cmp) {
    $(document).on("click", $A.getCallback(function(event) {
      if (cmp.isValid()) {
        var lookupInput = cmp.find('lookup');
        var lookupList = cmp.find('lookuplist');
        var isDropdownOpen = cmp.get("v.isDropdownOpen");

        if (event.target.outerHTML && event.target.tagName.toLowerCase() == 'input' && event.target.className.indexOf('Util_Lookup') != -1) {
          if (event.target.getAttribute('data-aura-rendered-by') != lookupInput.getGlobalId()) {
            $A.util.addClass(lookupList, 'slds-hide');
            // MO: fix for slds202
            $A.util.removeClass(lookupList, 'slds-show');
            cmp.set("v.isDropdownOpen", false);
          } else {
            if (cmp.get("v.isDropdownOpen")) {
              $A.util.addClass(lookupList, 'slds-hide');
              // MO: fix for slds202
              $A.util.removeClass(lookupList, 'slds-show');
            }
            cmp.set("v.isDropdownOpen", isDropdownOpen ? false : true);
          }
        } else {
          if (cmp.get("v.isDropdownOpen")) {
            $A.util.addClass(lookupList, 'slds-hide');
            // MO: fix for slds202
            $A.util.removeClass(lookupList, 'slds-show');
            cmp.set("v.isDropdownOpen", false);
          }
        }
      }
    }));
  },

  /**
   * Handle the Selection of an Item
   */
  handleSelection: function(cmp, event) {
    var Util_LookupEvt = cmp.getEvent('Util_LookupEvt');

    var sObjectAPIName = cmp.get('v.sObjectAPIName');
    if (!sObjectAPIName) {
      var cIsReferenceTo = event.currentTarget.getAttribute('data-isReferenceTo');
      cIsReferenceTo = (cIsReferenceTo == 'true');
      var cReferenceTo = event.currentTarget.getAttribute('data-referenceTo');
      var cFieldType = event.currentTarget.getAttribute('data-cFieldType');
      var cLastObjectName = event.currentTarget.getAttribute('data-cLastObjectName');
      var cLastFieldName = event.currentTarget.getAttribute('data-cLastFieldName');


      Util_LookupEvt.setParams({
        'type': 'LOOKUP_CHANGE',
        "cIsReferenceTo": cIsReferenceTo,
        "cReferenceTo": cReferenceTo,
        "cFieldType": cFieldType,
        "cLastObjectName": cLastObjectName,
        "cLastFieldName": cLastFieldName
      });
      // Fire the event
      Util_LookupEvt.fire();

      // Update the Searchstring with the value
      cmp.set('v.searchString', cLastFieldName);
    } else {
      //remove error when selection made
      cmp.set('v.error', null);

      // Resolve the Object Id from the events Element Id (this will be the <a> tag)
      var objectId = this.resolveId(event.currentTarget.id);

      // The Object label is the inner text)
      var objectLabel = event.currentTarget.text;

      // Get the Instance Id of the Component
      var instanceId = cmp.get('v.instanceId');

      //Get index of component
      var index = cmp.get('v.index');

      // Populate the event with the selected Object Id and Instance Id
      Util_LookupEvt.setParams({
        'sObjectId': objectId,
        'SObjectLabel': objectLabel,
        'instanceId': instanceId,
        'index': index
      });

      // Fire the event
      Util_LookupEvt.fire();

      // Update the Searchstring with the Label
      cmp.set('v.searchString', objectLabel);
      cmp.set('v.value', objectId);
      cmp.set('v.lookupNameValue', objectLabel);

    }

    // Hide the Lookup List
    var lookupList = cmp.find('lookuplist');
    $A.util.addClass(lookupList, 'slds-hide');
    // MO: fix for slds202
    $A.util.removeClass(lookupList, 'slds-show');

    // Hide the Input Element
    var inputElement = cmp.find('lookup');
    $A.util.addClass(inputElement, 'slds-hide');
    // MO: fix for slds202
    $A.util.removeClass(inputElement, 'slds-show');

    // Show the Lookup pill
    var lookupPill = cmp.find('lookup-pill');
    $A.util.removeClass(lookupPill, 'slds-hide');
    // MO: fix for slds202
    $A.util.addClass(lookupPill, 'slds-show');

    // Lookup Div has selection
    var inputElement = cmp.find('lookup-div');
    $A.util.addClass(inputElement, 'slds-has-selection');

  },

  /**
   * Clear the Selection
   */
  clearSelection: function(cmp, event) {
    var sObjectAPIName = cmp.get('v.sObjectAPIName');
    var Util_LookupEvt = cmp.getEvent('Util_LookupEvt');

    if (!sObjectAPIName) {
      Util_LookupEvt.setParams({
        'type': 'LOOKUP_CLEAR',
        'globalId': cmp.getGlobalId()
      });
    } else {
      // Get the Instance Id of the Component
      var instanceId = cmp.get('v.instanceId');
      var index = cmp.get('v.index');


      // Populate the event with the Instance Id
      Util_LookupEvt.setParams({
        'type': 'LOOKUP_CLEAR',
        'instanceId': instanceId,
        'index': index
      });
    }

    // Fire the event
    Util_LookupEvt.fire();

    // Clear the Searchstring
    cmp.set('v.searchString', '');
    cmp.set('v.value', '');
    cmp.set('v.lookupNameValue', '');

    // Hide the Lookup pill
    var lookupPill = cmp.find('lookup-pill');
    $A.util.addClass(lookupPill, 'slds-hide');
    // MO: fix for slds202
    $A.util.removeClass(lookupPill, 'slds-show');

    // Show the Input Element
    var inputElement = cmp.find('lookup');
    $A.util.removeClass(inputElement, 'slds-hide');
    // MO: fix for slds202
    $A.util.addClass(inputElement, 'slds-show');

    // Lookup Div has no selection
    var inputElement = cmp.find('lookup-div');
    // MO: fix for slds202
    $A.util.removeClass(inputElement, 'slds-has-selection');
  },

  /**
   * Resolve the Object Id from the Element Id by splitting the id at the _
   */
  resolveId: function(elmId) {
    var i = elmId.lastIndexOf('_');
    return elmId.substr(i + 1);
  },

  /**
   * Display a message
   */
  displayToast: function(title, message) {
    var toast = $A.get('e.force:showToast');

    // For lightning1 show the toast
    if (toast) {
      //fire the toast event in Salesforce1
      toast.setParams({
        'title': title,
        'message': message
      });

      toast.fire();
    } else { // otherwise throw an alert
      alert(title + ': ' + message);
    }
  }
})