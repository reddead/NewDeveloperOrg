({
	nameSpacePrefix: '',
	objectName: '',
	record: null,
	Util_Notify: null,
	Util_Spinner: null,

	doInit: function(component) {
		this.nameSpacePrefix = component.get('v.config').nameSpacePrefix;
		this.objectName = component.get('v.objectName');
		this.record = component.get('v.record');
		this.Util_Notify = component.find('Util_Notify');
		this.Util_Spinner = component.find('Util_Spinner');

		if (this.objectName.indexOf('Assignment_Rule_Entry__c') != -1)
		component.set("v.cssStyle", ".forceStyle .viewport .oneHeader.slds-global-header_container {z-index:0;}");
	else
		component.set("v.cssStyle", ".forceStyle .viewport .oneHeader.slds-global-header_container {z-index:0;} .forceStyle.desktop .viewport{overflow:hidden}");
	},

	defaultCloseAction: function(component) {
		$(document).off('click');
		component.set('v.open', false);
		window.setTimeout(
			$A.getCallback(function() {
				component.destroy();
			}), 500);
	},

	handleRecordUpdated: function(component, event, helper) {
		var eventParams = event.getParams();
		if (eventParams.changeType === "LOADED") {
			// this.record is loaded (render other component which needs this.record data value)
			if (!$A.util.isEmpty(this.record)) {
				var simpleRecord = component.get('v.simpleRecord');

				simpleRecord[this.nameSpacePrefix + 'Assign_To__c'] = this.record[this.nameSpacePrefix + 'Assign_To__c'];
				simpleRecord[this.nameSpacePrefix + 'Assign_To_Name__c'] = this.record[this.nameSpacePrefix + 'Assign_To_Name__c'];
				simpleRecord[this.nameSpacePrefix + 'Assign_To_Object__c'] = this.record[this.nameSpacePrefix + 'Assign_To_Object__c'];
				simpleRecord[this.nameSpacePrefix + 'Criteria_Logic__c'] = this.record[this.nameSpacePrefix + 'Criteria_Logic__c'];
				simpleRecord[this.nameSpacePrefix + 'Criteria_Set__c'] = this.record[this.nameSpacePrefix + 'Criteria_Set__c'];
				simpleRecord[this.nameSpacePrefix + 'Description__c'] = this.record[this.nameSpacePrefix + 'Description__c'];
				simpleRecord[this.nameSpacePrefix + 'Order__c'] = this.record[this.nameSpacePrefix + 'Order__c'];
				simpleRecord[this.nameSpacePrefix + 'Send_Email__c'] = this.record[this.nameSpacePrefix + 'Send_Email__c'];

				component.set('v.simpleRecord', simpleRecord);

				var criteriaSetJson = this.record[this.nameSpacePrefix + 'Criteria_Set__c'];
				var criteriaSet = [];
				if (criteriaSetJson) {
					var self=this;
					criteriaSet = JSON.parse(criteriaSetJson);
					criteriaSet.forEach(function(criteria) {
						var i=0;
						if (criteria.fieldType == 'picklist' || criteria.fieldType == 'multipicklist') {
							criteria.options = self.setCriteriaOptions(component, criteria.lastObjectName, criteria.lastFieldName);

							if (criteria.fieldType == 'picklist' && criteria.fieldValue){
								criteria.fieldValue = criteria.fieldValue.split('<#>');
								// for(i=0;i<criteria.fieldValue.length;i++)
								// 	criteria.fieldValue[i]=decodeURIComponent(criteria.fieldValue[i]);
							}
							else if (criteria.fieldType == 'multipicklist' && criteria.fieldValue){
								criteria.fieldValue = criteria.fieldValue.split('<#>');
								// for(i=0;i<criteria.fieldValue.length;i++)
								// 	criteria.fieldValue[i]=decodeURIComponent(criteria.fieldValue[i]);
							}
						}
						if (criteria.fieldType == 'boolean')
							criteria.fieldValue = (criteria.fieldValue == 'true');
						if (criteria.toggle === undefined)
							criteria.toggle = false;
					});
				}

				criteriaSet = this.newCriteria(component, criteriaSet);
				component.set('v.criteriaSet', criteriaSet);

				window.setTimeout(
					$A.getCallback(function() {
						component.set('v.open', true);
					}), 0);

			}
		} else if (eventParams.changeType === "CHANGED") {
			// this.record is changed
		} else if (eventParams.changeType === "REMOVED") {
			// this.record is deleted
		} else if (eventParams.changeType === "ERROR") {
			// there’s an error while loading, saving, or deleting the this.record
		}
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

	save: function(component) {
		this.Util_Notify.set('v.show', false);
		this.Util_Spinner.set('v.show', true);

		var self = this;

		var fields = component.find('field');
		if (fields[0]) {
			fields.splice(-1,1);//remove last empty criteria field
		}
		else{
			this.Util_Spinner.set('v.show', false);
			self.defaultCloseAction(component);
			return;
		}

		var dateFields = component.find('dateField');
		var criteriaValueLookupFields = component.find('criteriaValueLookup');
		var criteriaLogicField = component.find('criteriaLogic');

		var validFields = this.validateFields(fields);
		var validDateFields = this.validateDateFields(dateFields);
		var validCriteriaValueLookupFields = this.validateCriteriaValueLookupFields(criteriaValueLookupFields);
		var validCriteriaLogic = this.validateCriteriaLogic(component, criteriaLogicField);

		if (!validFields || !validDateFields || !validCriteriaValueLookupFields || !validCriteriaLogic) {
			this.Util_Notify.set('v.show', true);
			this.Util_Spinner.set('v.show', false);
			return;
		}

		var criteriaLogicCmp = component.find('criteriaLogic');
		var criteriaSet = component.get('v.criteriaSet');
		var finalCriteriaSet = criteriaSet.slice();

		// delete the last empty one
		finalCriteriaSet.splice(finalCriteriaSet.length - 1, 1);
		finalCriteriaSet.forEach(function(criteria) {
			var fieldValue;

			if (criteria.fieldType == 'boolean')
				criteria.fieldValue = criteria.fieldValue.toString();

			if (criteria.fieldType == 'picklist') {
				if (criteria.fieldValue) {
					fieldValue = '';
					criteria.fieldValue.forEach(function(value) {
						//fieldValue += encodeURIComponent(value) + ',';
						fieldValue += value + '<#>';
					});
					criteria.fieldValue = fieldValue.substr(0, fieldValue.length - 1);
				}
			}

			if (criteria.fieldType == 'multipicklist') {
				if (criteria.fieldValue) {
					fieldValue = '';
					criteria.fieldValue.forEach(function(value) {
						//fieldValue += encodeURIComponent(value) + ';';
						fieldValue += value + '<#>';
					});
					criteria.fieldValue = fieldValue.substr(0, fieldValue.length - 1);
				}
			}

			if (criteria.options !== undefined)
				delete criteria.options;
			if (criteria.toggle !== undefined)
				delete criteria.toggle;
		});

		// update back end Assignment Rule Entry record
		var criteriaRuleEntryUpdate = component.get('v.simpleRecord');
		if (finalCriteriaSet.length > 0) {
			criteriaRuleEntryUpdate[this.nameSpacePrefix + 'Criteria_Set__c'] = JSON.stringify(finalCriteriaSet);
			criteriaRuleEntryUpdate[this.nameSpacePrefix + 'Criteria_Logic__c'] = criteriaLogicCmp.get('v.value');
		} else {
			criteriaRuleEntryUpdate[this.nameSpacePrefix + 'Criteria_Set__c'] = '';
			criteriaRuleEntryUpdate[this.nameSpacePrefix + 'Criteria_Logic__c'] = '';
		}
		component.set("v.simpleRecord", criteriaRuleEntryUpdate);

		component.find("recordSave").saveRecord($A.getCallback(function(result) {
			// NOTE: If you want a specific behavior(an action or UI behavior) when this action is successful
			// then handle that in a callback (generic logic when record is changed should be handled in recordUpdated event handler)
			if (result.state === "SUCCESS" || result.state === "DRAFT") {
				// record is saved successfully
				var resultsToast = $A.get("e.force:showToast");
				if(resultsToast){
					resultsToast.setParams({
						"title": component.get('v.record.Name') + ' - Criteria Set was saved.',
						"message": ' ',
						'type': 'success'
					});
					resultsToast.fire();
				}

				var ASGMT_ModalEvt = component.getEvent('ASGMT_ModalEvt');
				ASGMT_ModalEvt.setParams({
					'type': 'CRITERIA_SET_CHANGE'
				});
				ASGMT_ModalEvt.fire();

				self.defaultCloseAction(component);
			} else if (result.state === "INCOMPLETE") {
				// console.log("User is offline, device doesn't support drafts.");
			} else if (result.state === "ERROR") {
				// console.log('Problem deleting record, error: ' + JSON.stringify(deleteResult.error));
			} else {
				// console.log('Unknown problem, state: ' + deleteResult.state + ', error: ' + JSON.stringify(deleteResult.error));
			}
		}));


	},

	selectField: function(component, event) {
		var self=this;
		this.Util_Spinner.set('v.show', true);
		$A.createComponent(
			"c:ASGMT_ModalSelectField", {
				'type': 'SELECT_FIELD',
				"title": 'Select a field ',
				"config": component.get('v.config'),
				"relatedObject": component.get('v.relatedObject'), //relatedObject
				"cIndex": event.target.getAttribute('data-cIndex'),
				'criteriaSet':component.getReference('v.criteriaSet')
			},
			function(modalComponent, status) {
				if (status === "SUCCESS") {
					var targetCmp = component.find('ModalPlaceholder');
					var body = targetCmp.get("v.body");
					body.push(modalComponent);
					targetCmp.set("v.body", body);
					self.Util_Spinner.set('v.show', false);
				}
			}
		);
	},

	clearField: function(component, event) {
		var cIndex = event.getSource().get('v.value');
		var criteriaSet = component.get('v.criteriaSet');

		//remove lookup component otherwise lookup field validate will go wrong
		if(criteriaSet[cIndex].fieldType=='id'||criteriaSet[cIndex].fieldType=='reference'){
			var criteriaValueLookupFields = component.find('criteriaValueLookup');
			if(criteriaValueLookupFields[0])
				criteriaValueLookupFields[cIndex].destroy();
			else
				criteriaValueLookupFields.destroy();
		}

		//delete criteria
		criteriaSet.splice(cIndex, 1);

		//re-order
		criteriaSet.forEach(function(criteria, index) {
			criteria.order = index + 1;
		});
		component.set('v.criteriaSet', criteriaSet);

	},

	clearCustomFieldError: function(component, event) {
		var field = event.getSource();
		if (field.getLocalId() == 'dateField')
			field.set('v.errors', null);
	},
})
