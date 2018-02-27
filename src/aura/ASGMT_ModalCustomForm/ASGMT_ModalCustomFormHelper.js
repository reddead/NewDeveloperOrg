({
	nameSpacePrefix: '',
	objectName: '',
	parentRecord: null,
	record: null,
	Util_Notify: null,
	Util_Spinner: null,

	doInit: function(component) {
		var self=this;
		this.nameSpacePrefix = component.get('v.config').nameSpacePrefix;
		this.objectName = component.get('v.objectName');
		this.parentRecord = component.get('v.parentRecord');
		this.record = component.get('v.record');
		this.Util_Notify = component.find('Util_Notify');
		this.Util_Spinner = component.find('Util_Spinner');

		if ($A.util.isEmpty(this.record))
			this.getNewRecord(component);

		//set relatedObject picklistOptions
		if (this.objectName.indexOf('Assignment_Rule__c') != -1){
	      var config=component.get('v.config');
	      var configurations = JSON.parse(config.configurationsJson);
				var relatedObjectOptions=component.get('v.relatedObjectOptions');
				relatedObjectOptions=[];
	      configurations.forEach(function(configuration) {
					var item={};
					item.label=configuration[self.nameSpacePrefix+'Related_To__c'];
					item.value=configuration[self.nameSpacePrefix+'Related_To__c'];
					relatedObjectOptions.push(item);
				});
				component.set('v.relatedObjectOptions',relatedObjectOptions);
		}

		if (this.objectName.indexOf('Assignment_Rule_Entry__c') != -1)
			component.set("v.cssStyle", ".forceStyle .viewport .oneHeader.slds-global-header_container {z-index:0;}");
		else
			component.set("v.cssStyle", ".forceStyle .viewport .oneHeader.slds-global-header_container {z-index:0;} .forceStyle.desktop .viewport{overflow:hidden}");
	},

	defaultCloseAction: function(component) {
		component.set('v.open', false);
		window.setTimeout(
			$A.getCallback(function() {
				component.destroy();
			}), 500);
	},


	getNewRecord: function(component) {
		var self = this;
		component.find("recordCreator").getNewRecord(
			this.nameSpacePrefix + this.objectName, // sObject type (entityAPIName)
			null, // recordTypeId
			false, // skip cache?
			$A.getCallback(function() {
				//must set open to true first to dynamically create assignTo lookup
				component.set("v.open", true);

				var simpleRecord = component.get('v.simpleRecord');

				//Assignment_Rule__c
				if (self.objectName.indexOf('Assignment_Rule__c') != -1) {
					simpleRecord[self.nameSpacePrefix + 'Active__c'] = true;
					component.set('v.simpleRecord', simpleRecord);
				}
				//Assignment_Rule_Entry__c
				else if (self.objectName.indexOf('Assignment_Rule_Entry__c') != -1) {
					if (!$A.util.isEmpty(self.parentRecord))
						simpleRecord[self.nameSpacePrefix + 'Assignment_Rule__c'] = self.parentRecord.Id;

					if (!simpleRecord[self.nameSpacePrefix + 'Assign_To_Object__c']) {
						simpleRecord[self.nameSpacePrefix + 'Assign_To_Object__c'] = 'User';
					}
					component.set('v.simpleRecord', simpleRecord);
					self.createAssignToField(component, false);
				}
				//Assignment_Queue__c
				else if (self.objectName.indexOf('Assignment_Queue__c') != -1) {
					simpleRecord[self.nameSpacePrefix + 'Active__c'] = true;
					component.set('v.simpleRecord', simpleRecord);
				}
				//Assignment_Queue_Member__c
				else if (self.objectName.indexOf('Assignment_Queue_Member__c') != -1) {
					if (!$A.util.isEmpty(self.parentRecord))
						simpleRecord[self.nameSpacePrefix + 'Assignment_Queue__c'] = self.parentRecord.Id;

					simpleRecord[self.nameSpacePrefix + 'Member_Active__c'] = true;
					component.set('v.simpleRecord', simpleRecord);
				}

			})
		);
	},

	handleRecordUpdated: function(component, event) {
		var eventParams = event.getParams();
		if (eventParams.changeType === "LOADED") {
			// this.record is loaded (render other component which needs this.record data value)
			var simpleRecord = component.get('v.simpleRecord');
			if (this.objectName.indexOf('Assignment_Rule__c') != -1 && !$A.util.isEmpty(this.record)) {

				//fix simpleRecord does not reload issue
				simpleRecord[this.nameSpacePrefix + 'Active__c'] = this.record[this.nameSpacePrefix + 'Active__c'];
				simpleRecord[this.nameSpacePrefix + 'Description__c'] = this.record[this.nameSpacePrefix + 'Description__c'];
				simpleRecord[this.nameSpacePrefix + 'Fire_On_Update__c'] = this.record[this.nameSpacePrefix + 'Fire_On_Update__c'];
				simpleRecord[this.nameSpacePrefix + 'Related_Object__c'] = this.record[this.nameSpacePrefix + 'Related_Object__c'];

				component.set('v.simpleRecord', simpleRecord);
				component.set("v.open", true);
			} else if (this.objectName.indexOf('Assignment_Rule_Entry__c') != -1 && !$A.util.isEmpty(this.record)) {
				//fix simpleRecord does not reload issue
				if (simpleRecord[this.nameSpacePrefix + 'Assign_To_User__c']) {
					simpleRecord[this.nameSpacePrefix + 'Assign_To_Object__c'] = 'User';
					simpleRecord[this.nameSpacePrefix + 'Assign_To__c'] = this.record[this.nameSpacePrefix + 'Assign_To_User__c'];
					simpleRecord[this.nameSpacePrefix + 'Assign_To_Name__c'] = this.record[this.nameSpacePrefix + 'Assign_To_User__r'].Name;
				} else if (simpleRecord[this.nameSpacePrefix + 'Assign_To_Queue__c']) {
					simpleRecord[this.nameSpacePrefix + 'Assign_To_Object__c'] = this.nameSpacePrefix + 'Assignment_Queue__c';
					simpleRecord[this.nameSpacePrefix + 'Assign_To__c'] = this.record[this.nameSpacePrefix + 'Assign_To_Queue__c'];
					simpleRecord[this.nameSpacePrefix + 'Assign_To_Name__c'] = this.record[this.nameSpacePrefix + 'Assign_To_Queue__r'].Name;
				} else {
					simpleRecord[this.nameSpacePrefix + 'Assign_To_Object__c'] = 'User';
					simpleRecord[this.nameSpacePrefix + 'Assign_To__c'] = '';
					simpleRecord[this.nameSpacePrefix + 'Assign_To_Name__c'] = '';
				}

				simpleRecord[this.nameSpacePrefix + 'Criteria_Logic__c'] = this.record[this.nameSpacePrefix + 'Criteria_Logic__c'];
				simpleRecord[this.nameSpacePrefix + 'Criteria_Set__c'] = this.record[this.nameSpacePrefix + 'Criteria_Set__c'];
				simpleRecord[this.nameSpacePrefix + 'Description__c'] = this.record[this.nameSpacePrefix + 'Description__c'];
				simpleRecord[this.nameSpacePrefix + 'Order__c'] = this.record[this.nameSpacePrefix + 'Order__c'];
				simpleRecord[this.nameSpacePrefix + 'Send_Email__c'] = this.record[this.nameSpacePrefix + 'Send_Email__c'];

				component.set("v.oldOrder", simpleRecord[this.nameSpacePrefix + 'Order__c']);
				component.set('v.simpleRecord', simpleRecord);
				component.set("v.open", true);
				this.createAssignToField(component, false);
			} else
				component.set("v.open", true);

			//fix IE display null issue
			if(simpleRecord.hasOwnProperty(this.nameSpacePrefix + 'Description__c')){
				if (!simpleRecord[this.nameSpacePrefix + 'Description__c'])
					simpleRecord[this.nameSpacePrefix + 'Description__c'] = '';
			}
		} else if (eventParams.changeType === "CHANGED") {
			// this.record is changed
		} else if (eventParams.changeType === "REMOVED") {
			// this.record is deleted
		} else if (eventParams.changeType === "ERROR") {
			// there’s an error while loading, saving, or deleting the this.record
		}
	},

	clearCustomFieldError: function(component) {
		if (this.objectName.indexOf('Assignment_Rule__c') != -1) {
			var relatedObjectField = component.find('field')[1];
			relatedObjectField.set('v.pattern', null);

		} else if (this.objectName.indexOf('Assignment_Rule_Entry__c') != -1) {
			var orderField = component.find('field')[1];
			orderField.set('v.pattern', null);
		} else if (this.objectName.indexOf('Assignment_Queue_Member__c') != -1) {
			var lastAssignmentField = component.find('dateField');
			lastAssignmentField.set('v.errors', null);
		}
	},

	clearAssignTo: function(component) {
		var assignTo = component.find('assignTo').get('v.body');
		var assignTofield = assignTo[1];
		assignTofield.destroy();
		assignTo.splice(1, 1);

		this.createAssignToField(component, true);
	},

	createAssignToField: function(component, clearValue) {
		var simpleRecord = component.get('v.simpleRecord');
		var sObjectAPIName = component.get('v.simpleRecord.Assign_To_Object__c');
		var whereClause = '';
		if (sObjectAPIName == 'User')
			whereClause = "(UserType='Standard' OR UserType='PowerPartner') AND IsActive=true";
		$A.createComponent(
			//NameSpacePrefix issue
			"c:Util_Lookup", {
				'aura:id': 'lookupField',
				'config': component.getReference('v.config'),
				'sObjectAPIName': component.getReference('v.simpleRecord.Assign_To_Object__c'),
				'value': component.getReference('v.simpleRecord.Assign_To__c'),
				'lookupNameValue': component.getReference('v.simpleRecord.Assign_To_Name__c'),
				'class': 'slds-grow',
				'whereClause': whereClause
			},
			function(assignToFieldComponent, status) {
				if (status === "SUCCESS") {
					if (clearValue) {
						assignToFieldComponent.set('v.searchString', '');
						assignToFieldComponent.set('v.value', '');
						assignToFieldComponent.set('v.lookupNameValue', '');
						// Hide the Lookup pill
						var lookupPill = assignToFieldComponent.find('lookup-pill');
						$A.util.addClass(lookupPill, 'slds-hide');
						// MO: fix for slds202
						$A.util.removeClass(lookupPill, 'slds-show');

						// Show the Input Element
						var inputElement = assignToFieldComponent.find('lookup');
						$A.util.removeClass(inputElement, 'slds-hide');
						// MO: fix for slds202
						$A.util.addClass(inputElement, 'slds-show');

						// Lookup Div has no selection
						inputElement = assignToFieldComponent.find('lookup-div');
						// MO: fix for slds202
						$A.util.removeClass(inputElement, 'slds-has-selection');
					}

					var targetCmp = component.find('assignTo');
					var body = targetCmp.get("v.body");
					body.push(assignToFieldComponent);
					targetCmp.set("v.body", body);
				}
			}
		);
	},

	save: function(component) {
		this.Util_Notify.set('v.show', false);
		this.Util_Spinner.set('v.show', true);

		var self = this;
		var ASGMT_ModalEvt = component.getEvent('ASGMT_ModalEvt');
		var simpleRecord = component.get('v.simpleRecord');

		var fields = component.find('field');
		var dateFields = component.find('dateField');
		var lookupFields;
		if (this.objectName.indexOf('Assignment_Rule_Entry__c') != -1)
			lookupFields = component.find('assignTo').get('v.body')[1];
		else
			lookupFields = component.find('lookupField');

		var validFields = this.validateFields(fields);
		var validDateFields = this.validateDateFields(dateFields);
		var validLookupFields = this.validateLookupFields(lookupFields);

		if (!validFields || !validDateFields || !validLookupFields) {
			this.Util_Notify.set('v.show', true);
			this.Util_Spinner.set('v.show', false);
			return;
		}

		//Save Assignment_Rule__c
		if (this.objectName.indexOf('Assignment_Rule__c') != -1) {
			// var relatedObjectField = component.find('field')[1];
			//
			// var action = component.get('c.validateRelatedObject');
			// action.setParams({
			// 	"relatedObject": simpleRecord[this.nameSpacePrefix + 'Related_Object__c'],
			// });
			// action.setCallback(this, function(response) {
			// 	var isValid = response.getReturnValue();
			// 	if (isValid) {
			// 		if (this.record != null)
			// 			self.saveRecord(component, ASGMT_ModalEvt, self, 'recordEditor');
			// 		else
			// 			self.saveRecord(component, ASGMT_ModalEvt, self, 'recordCreator');
			// 	} else {
			// 		//force it to display custom error
			// 		relatedObjectField.set('v.pattern', 'Incorrect object API name');
			// 		relatedObjectField.set('v.messageWhenPatternMismatch', 'Incorrect object API name');
			// 		relatedObjectField.showHelpMessageIfInvalid();
			// 		this.Util_Notify.set('v.show', true);
			// 		this.Util_Spinner.set('v.show', false);
			// 	}
			// });
			// $A.enqueueAction(action);
			if (this.record != null)
				self.saveRecord(component, ASGMT_ModalEvt, self, 'recordEditor');
			else
				self.saveRecord(component, ASGMT_ModalEvt, self, 'recordCreator');
		}
		//Save Assignment_Rule_Entry__c
		else if (this.objectName.indexOf('Assignment_Rule_Entry__c') != -1) {

			//if order not defined, set it to 10000 to make sure it sets to maxOrder in server side
			var order = simpleRecord[this.nameSpacePrefix + 'Order__c'];
			if (!order)
				simpleRecord[this.nameSpacePrefix + 'Order__c'] = 10000;

			////
			if (simpleRecord[this.nameSpacePrefix + 'Assign_To_Object__c'] == 'User') {
				simpleRecord[this.nameSpacePrefix + 'Assign_To_User__c'] = simpleRecord[this.nameSpacePrefix + 'Assign_To__c'];
				simpleRecord[this.nameSpacePrefix + 'Assign_To_Queue__c'] = null;
			} else {
				simpleRecord[this.nameSpacePrefix + 'Assign_To_Queue__c'] = simpleRecord[this.nameSpacePrefix + 'Assign_To__c'];
				simpleRecord[this.nameSpacePrefix + 'Assign_To_User__c'] = null;
			}

			////

			if (this.record != null)
				self.saveRecord(component, ASGMT_ModalEvt, self, 'recordEditor');
			else
				self.saveRecord(component, ASGMT_ModalEvt, self, 'recordCreator');

		}
		//Save Assignment_Queue_Member__c
		else if (this.objectName.indexOf('Assignment_Queue_Member__c') != -1) {

			var lastAssignment = simpleRecord[this.nameSpacePrefix + 'Last_Assignment__c'];
			if (!lastAssignment)
				simpleRecord[this.nameSpacePrefix + 'Last_Assignment__c'] = new Date(Date.now());

			var millisecond = simpleRecord[this.nameSpacePrefix + 'Millisecond__c'];
			if (!millisecond)
				simpleRecord[this.nameSpacePrefix + 'Millisecond__c'] = new Date(Date.now()).getUTCMilliseconds();

			//do not set it, otherwise it will cause ui:inputDatetime parse error
			//component.set('v.simpleRecord', simpleRecord);

			if (this.record != null)
				self.saveRecord(component, ASGMT_ModalEvt, self, 'recordEditor');
			else
				self.saveRecord(component, ASGMT_ModalEvt, self, 'recordCreator');
		} else {
			if (this.record != null)
				self.saveRecord(component, ASGMT_ModalEvt, self, 'recordEditor');
			else
				self.saveRecord(component, ASGMT_ModalEvt, self, 'recordCreator');
		}

	},

	saveRecord: function(component, ASGMT_ModalEvt, self, auraId) {
		component.find(auraId).saveRecord($A.getCallback(function(saveResult) {
			if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
				// console.log("Save completed successfully.");

				var title = '';
				var ASGMT_ModalEvtParam = {
					'type': 'RECORD_CHANGE',
					'record': component.get('v.simpleRecord'),
				};

				//Assignment_Rule__c
				if (self.objectName.indexOf('Assignment_Rule__c') != -1) {
					title = 'Assignment Rule "' + component.get('v.simpleRecord.Name') + ' (' + component.get('v.simpleRecord.Id') + ')" was saved.';
				}
				//Assignment_Rule_Entry__c
				else if (self.objectName.indexOf('Assignment_Rule_Entry__c') != -1) {
					title = 'Assignment Rule Entry "' + component.get('v.simpleRecord.Name') + ' (' + component.get('v.simpleRecord.Id') + ')" was saved.';

					ASGMT_ModalEvtParam = {
						'type': 'RECORD_CHANGE',
						'record': component.get('v.simpleRecord'),
						'oldOrder': component.get('v.oldOrder'),
					};
				}
				//Assignment_Queue__c
				else if (self.objectName.indexOf('Assignment_Queue__c') != -1) {
					title = 'Assignment Queue "' + component.get('v.simpleRecord.Name') + ' (' + component.get('v.simpleRecord.Id') + ')" was saved.';
				}
				//Assignment_Queue_Member__c
				else if (self.objectName.indexOf('Assignment_Queue_Member__c') != -1) {
					var record = component.get('v.simpleRecord');
					title = 'Assignment Queue Member "' + record[self.nameSpacePrefix + 'User_Name__c'] + ' (' + component.get('v.simpleRecord.Id') + ')" was saved.';
				}

				// record is saved successfully
				var resultsToast = $A.get("e.force:showToast");
				if (resultsToast) {
					resultsToast.setParams({
						"title": title,
						"message": ' ',
						'type': 'success'
					});
					resultsToast.fire();
				}

				ASGMT_ModalEvt.setParams(ASGMT_ModalEvtParam);
				ASGMT_ModalEvt.fire();

				self.defaultCloseAction(component);
			} else if (saveResult.state === "INCOMPLETE") {
				self.Util_Notify.set('v.message', 'User is offline, device doesn\'t support drafts.');
			} else if (saveResult.state === "ERROR") {
				if(saveResult.error)
					self.Util_Notify.set('v.message', JSON.stringify(saveResult.error));
				else
					self.Util_Notify.set('v.message', 'Something weng wrong');
				self.Util_Notify.set('v.show', true);
			}
		}));

	}
})