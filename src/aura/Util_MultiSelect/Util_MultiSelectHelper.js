({
  init: function(component) {
    //note, we get options and set options_
    //options_ is the private version and we use this from now on.
    //this is to allow us to sort the options array before rendering

    var options = component.get("v.options");
    var tempOptions = [];
    if (options)
      tempOptions = options.slice();

    var selectedOptions = component.get('v.selectedOptions');
    var isAllSelected = true;

    tempOptions.forEach(function(option) {
      option.selected = false;
      for (var i = 0; i < selectedOptions.length; i++) {
        if (selectedOptions[i] === option.value) {
          option.selected = true;
          break;
        }
      }
      if (!option.selected)
        isAllSelected = false;
    });

    tempOptions.splice(0, 0, {
      'label': 'Select All',
      'value': 'Select All'
    });
    tempOptions[0].selected = isAllSelected;

    component.set("v.options_", tempOptions);
    var values = this.getSelectedValues(component);
    this.setInfoText(component, values);
    this.registerDocumentClickEvent(component);
  },
  // setOptions: function(component) {
  // 	var options = component.get("v.options");
  // 	var tempOptions = options.slice();
  // 	tempOptions.splice(0, 0, {
  // 		'label': 'Select All',
  // 		'value': 'Select All'
  // 	});
  //
  // 	component.set("v.options_", tempOptions);
  // 	var values = this.getSelectedValues(component);
  // 	this.setInfoText(component, values);
  // },

  setInfoText: function(component, values) {

    if (values.length == 0) {
      component.set("v.infoText", "--None--");
    }
    if (values.length == 1) {
      component.set("v.infoText", values[0]);
    } else if (values.length > 1) {
      var infoText = '';
      if (values[0] == 'Select All') {
        values.forEach(function(value, index) {
          if (index != 0 && index < 7) //7
            infoText += value + ', ';
        });
        if (values.length - 1 <= 6) {
          infoText = infoText.substr(0, infoText.length - 2);
          infoText += ' (' + (values.length - 1) + ')';
        } else
          infoText += '... (' + (values.length - 1) + ')';
      } else {
        values.forEach(function(value, index) {
          if (index < 6) //6
            infoText += value + ', ';
        });
        if (values.length <= 6) {
          infoText = infoText.substr(0, infoText.length - 2);
          infoText += ' (' + values.length + ')';
        } else
          infoText += '... (' + values.length + ')';
      }
      component.set("v.infoText", infoText);
    }
  },

  registerDocumentClickEvent: function(component) {
    $(document).on("click", $A.getCallback(function(event) {
      if (component.isValid()) {
        var multiSelectButton = component.find('multiSelectButton');
        var mainDiv = component.find('main-div');
        var isDropdownOpen = component.get("v.isDropdownOpen");

        if (event.target.outerHTML && event.target.tagName.toLowerCase() == 'li' && event.target.className.indexOf('Util_MultiSelect') != -1) {
          return;
        } else if (event.target.outerHTML && event.target.tagName.toLowerCase() == 'button' && event.target.className.indexOf('Util_MultiSelect') != -1) {
          if (event.target.getAttribute('data-aura-rendered-by') != multiSelectButton.getGlobalId()) {
            $A.util.removeClass(mainDiv, 'slds-is-open');
            component.set("v.isDropdownOpen", false);
          } else {
            if (component.get("v.isDropdownOpen"))
              $A.util.removeClass(mainDiv, 'slds-is-open');
            component.set("v.isDropdownOpen", isDropdownOpen ? false : true);
          }

        } else {
          if (component.get("v.isDropdownOpen")) {
            $A.util.removeClass(mainDiv, 'slds-is-open');
            component.set("v.isDropdownOpen", false);
          }
        }
      }
    }));
  },

  getSelectedValues: function(component) {
    var options = component.get("v.options_");
    var values = [];
    options.forEach(function(element) {
      if (element.selected && element.value != 'Select All') {
        values.push(element.value);
      }
    });
    return values;
  },

  getSelectedLabels: function(component) {
    var options = component.get("v.options_");
    var labels = [];
    options.forEach(function(element) {
      if (element.selected && element.value != 'Select All') {
        labels.push(element.label);
      }
    });
    return labels;
  },

  despatchSelectChangeEvent: function(component, values) {
    var compEvent = component.getEvent("multiSelectChangeEvt");
    compEvent.setParams({
      "values": values
    });
    compEvent.fire();
  }
})