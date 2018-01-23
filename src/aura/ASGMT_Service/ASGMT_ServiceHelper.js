({
	doInit: function(component) {},

	getDescribe: function(sObjectDescribes, objectName) {
		return sObjectDescribes[objectName];
	},

	getFieldMap: function(sobjectDescribe, fieldType) {
		fieldType = (typeof fieldType !== 'undefined') ? fieldType : null;

		if (sobjectDescribe) {
			var FieldName_Field = {};
			for (var i = 0; i < sobjectDescribe.fields.length; i++) {
				var field = sobjectDescribe.fields[i];
				if (!fieldType || fieldType == 'all')
					FieldName_Field[field.name] = field;
				else if (fieldType.indexOf(field.type) >= 0)
					FieldName_Field[field.name] = field;
			}
			return FieldName_Field;
		} else
			return null;
	},

	getPicklistOptionsMap: function(picklistFieldMap, setDeFaultOption, defaultLabel, defaultValue) {
		defaultLabel = (typeof defaultLabel !== 'undefined') ? defaultLabel : null;
		defaultValue = (typeof defaultValue !== 'undefined') ? defaultValue : null;

		if (picklistFieldMap) {
			var PicklistFieldName_PicklistOptions = {};
			Object.keys(picklistFieldMap).forEach(function(picklistFieldName) {
				var field = picklistFieldMap[picklistFieldName];
				var options = [];

				if (setDeFaultOption) {
					var deFaultOption = {};
					deFaultOption.label = defaultLabel;
					deFaultOption.value = defaultValue;
					deFaultOption.default = true;
					deFaultOption.validFor = null;
					deFaultOption.selected = false;
					options.push(deFaultOption);
				}
				for (var j = 0; j < field.picklistValues.length; j++) {
					var option = {};
					option.label = field.picklistValues[j].label;
					option.value = field.picklistValues[j].value;
					option.default = field.picklistValues[j].defaultValue;
					if (field.picklistValues[j].hasOwnProperty('validFor'))
						option.validFor = field.picklistValues[j].validFor;
					option.selected = false;
					options.push(option);
				}
				options.sort(function compare(a, b) {
					if (a.label < b.label) {
						return -1;
					}
					if (a.label > b.label) {
						return 1;
					}
					return 0;
				});
				PicklistFieldName_PicklistOptions[picklistFieldName] = options;
			});
			return PicklistFieldName_PicklistOptions;
		} else
			return null;
	},

	getFieldOptions: function(sObjectDescribes, objectName, excludeFieldType) {

		excludeFieldType = (typeof excludeFieldType !== 'undefined') ? excludeFieldType : null;

		var fieldOptions = [];
		var self = this;
		sObjectDescribes[objectName].fields.forEach(function(field) {
			if (excludeFieldType) {
				if (excludeFieldType.indexOf(field.type) == -1)
					fieldOptions = self.addFieldOption(fieldOptions, sObjectDescribes, objectName, field);
			} else
					fieldOptions = self.addFieldOption(fieldOptions, sObjectDescribes, objectName, field);
		});
		// fieldOptions.sort(function(a, b) {
		// 	var fieldA = a.fieldName.toLowerCase();
		// 	var fieldB = b.fieldName.toLowerCase();
		// 	if (fieldA < fieldB) //sort string ascending
		// 		return -1;
		// 	if (fieldA > fieldB)
		// 		return 1;
		// 	return 0; //default return value (no sorting)
		// });
		return fieldOptions;
	},

	addFieldOption: function(fieldOptions, sObjectDescribes, objectName, field) {
		var pv = {};
		pv.label = '[' + objectName + '].' + field.name + ' - ' + field.type; //+ ' (' + field.label + ')';
		// if (field.referenceTo)
		//   pv.label += ' >';
		pv.fieldType = field.type;
		pv.objectName = objectName;
		pv.fieldName = field.name;
		pv.relationshipName = field.relationshipName;
		pv.isCustom = field.isCustom;
		pv.referenceTo = field.referenceTo;
		pv.isReferenceTo = false;
		if (field.type === 'reference') {
			//check if referenceOject exists
			if (sObjectDescribes[field.referenceTo]) {
				fieldOptions.push(pv);
				//add  relationship for child field selection
				pv = {};
				pv.label = '[' + objectName + '].' + field.name + ' - ' + field.type + ' >>>';
				// pv.label = '[' + objectName + '].' + field.name + ' >';
				pv.fieldType = field.type;
				pv.objectName = objectName;
				pv.fieldName = field.name;
				pv.relationshipName = field.relationshipName;
				pv.isCustom = field.isCustom;
				pv.referenceTo = field.referenceTo;
				pv.isReferenceTo = true;

				fieldOptions.splice(fieldOptions.length-1,0,pv);
				//fieldOptions.push(pv);
			}
		} else
			fieldOptions.push(pv);

		return fieldOptions;
	},

	validateFields: function(fields) {
		var fieldArray = [];

		if (!fields)
			return true;
		else if (!fields[0]) {
			fieldArray.push(fields);
		} else
			fieldArray = fields;

		return fieldArray.reduce(function(validSoFar, field) {
			if (field.isValid()) {
				field.showHelpMessageIfInvalid();
				return validSoFar && field.get('v.validity').valid;
			} else
				return validSoFar;
		}, true);
	},

	validateDateFields: function(dateFields) {
		var dateFieldArray = [];
		var allValid = true;

		if (!dateFields)
			return true;
		else if (!dateFields[0]) {
			dateFieldArray.push(dateFields);
		} else
			dateFieldArray = dateFields;

		dateFieldArray.forEach(function(dateField) {
			if (dateField.isValid()) {
				var dateValue = dateField.get('v.value');
				if (dateValue) {
					var regexDateTime = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})\.(\d{3})Z$/;
					var regexDate = /^(\d{4})-(\d{2})-(\d{2})$/;
					//var str = `2017-12-22T02:30:00.000Z`;
					if (!regexDateTime.test(dateValue) && !regexDate.test(dateValue)) {
						dateField.set('v.errors', [{
							message: 'Invalid data type'
						}]);
						allValid = false;
					}
				}
			}
		});
		return allValid;
	},

	validateLookupFields: function(lookupFields) {
		var lookupFieldArray = [];
		var allValid = true;

		if (!lookupFields)
			return true;
		else if (!lookupFields[0]) {
			lookupFieldArray.push(lookupFields);
		} else
			lookupFieldArray = lookupFields;

		lookupFieldArray.forEach(function(lookupField) {
			if (lookupField.isValid()) {
				if (!lookupField.get('v.searchString')) {
					lookupField.set('v.error', 'Complete this field');
					allValid = false;
				} else if (!lookupField.get('v.value')) {
					lookupField.set('v.error', 'An invalid option has been chosen');
					allValid = false;
				}
			}
		});
		return allValid;
	},

	validateCriteriaValueLookupFields: function(lookupFields) {
		var lookupFieldArray = [];

		if (!lookupFields)
			return true;
		else if (!lookupFields[0]) {
			lookupFieldArray.push(lookupFields);
		} else
			lookupFieldArray = lookupFields;

		return lookupFieldArray.reduce(function(validSoFar, lookupField) {
			if (lookupField.isValid()) {
				if (lookupField.get('v.searchString') && !lookupField.get('v.value')) {
					lookupField.set('v.error', 'An invalid option has been chosen');
					validSoFar = false;
				}
			}
			return validSoFar;
		}, true);
	},

	validateCriteriaLogic: function(component,criteriaLogicField) {
		var criteriaLogic = criteriaLogicField.get('v.value');
		//if criteriaLogic not empty
		if (criteriaLogic) {
			var re = /(\d+)/g;
			var m;
			var strCriteriaLogic = criteriaLogic;
			strCriteriaLogic = strCriteriaLogic.toLowerCase();
			strCriteriaLogic = strCriteriaLogic.replace(/\s/g, ''); //remove all white space
			var orderList = [];
			while ((m = re.exec(strCriteriaLogic)) !== null) {
				orderList.push(m[1]);
				if (m.index === re.lastIndex) {
					re.lastIndex++;
				}
			}

			orderList = orderList.filter(function(elem, index, self) {
				return index == self.indexOf(elem);
			});

			var orderMap = {};
			var criteriaSet = component.get('v.criteriaSet');
			var _criteriaSet = criteriaSet.slice();
			_criteriaSet.splice(_criteriaSet.length - 1, 1); // delete the last empty one
			_criteriaSet.forEach(function(criteria) {
				//save existing order number into map
				orderMap[criteria.order] = true;
			});

			var criteriaLogicError = '';

			//Step 1 - check invalidOrderNumbers
			var invalidOrderNumbers = '';
			orderList.forEach(function(order) {
				if (!orderMap[order]) {
					invalidOrderNumbers += order + ', ';
				}
			});
			if (invalidOrderNumbers) {
				invalidOrderNumbers = invalidOrderNumbers.substring(0, invalidOrderNumbers.length - 2);
				criteriaLogicError = 'The filter logic references undefined filter order number(s): ' + invalidOrderNumbers;
			}

			//Step 2 - check all exsting order number reference
			if (!criteriaLogicError) {
				if (Object.keys(orderMap).length != orderList.length)
					criteriaLogicError = 'Some filter conditions are defined but not referenced in your filter logic';
			}

			//Step 3 - check parentheses
			if (!criteriaLogicError) {
				var reLeftParentheses = /\([^\(+\d]/;
				var reRightParentheses = /[^\d\)+]\)/;
				if (reLeftParentheses.test(strCriteriaLogic) || reRightParentheses.test(strCriteriaLogic))
					criteriaLogicError = 'Syntax error, your filter is imprecise or incorrect';
			}

			//Step 4 - check Syntax
			if (!criteriaLogicError) {
				orderList.sort(function(a, b) {
					return b - a;
				});
				orderList.forEach(function(order) {
					var orderRegex = new RegExp(order, 'g');
					strCriteriaLogic = strCriteriaLogic.replace(orderRegex, '');
				});
				strCriteriaLogic = strCriteriaLogic.replace(/or/g, '');
				strCriteriaLogic = strCriteriaLogic.replace(/and/g, '');
				// strCriteriaLogic = strCriteriaLogic.replace(/\(\)/g, '');
				while (strCriteriaLogic.indexOf('()') != -1)
					strCriteriaLogic = strCriteriaLogic.replace('()', '');

				if (strCriteriaLogic) //if strCriteriaLogic still not empty --> illegal characters exist
					criteriaLogicError = 'Syntax error, your filter is imprecise or incorrect';
			}

			component.set('v.criteriaLogicError', criteriaLogicError);
			//invalid
			if (criteriaLogicError)
				return false;
			//valid
			else
				return true;
		}
		//else  criteriaLogic empty
		else {
			//valid
			component.set('v.criteriaLogicError', '');
			return true;
		}

	},

})