({
	doInit: function(component) {
		var config = component.get("v.config");
		var record = component.get("v.record");
		var objectName = component.get("v.objectName");
		var index = component.get("v.index");

		if (objectName === 'Assignment_Rule__c') {
			if (record) {
				var relatedObject = record[config.nameSpacePrefix + "Related_Object__c"].replace('EnrollmentrxRx__', '');
				relatedObject = relatedObject.replace('__c', '');
				if (relatedObject.length < 8)
					component.set("v.initials", relatedObject);
				else {
					var initialList = relatedObject.split('_');
					var initials = '';
					for (var i = 0; i < initialList.length; i++) {
						initials += initialList[i].substr(0, 1);
					}
					component.set("v.initials", initials);
				}
			}
		} else if (objectName === 'Assignment_Rule_Entry__c')
			component.set("v.initials", 'Entry');
		else if (objectName === 'Assignment_Queue__c')
			component.set("v.initials", 'Queue');
		else if (objectName === 'Assignment_Queue_Member__c') {
			component.set("v.initials", 'Member');


			if (record[config.nameSpacePrefix + 'Member_Status__c'] == 'Invalid')
				component.set("v.memberStatus", 'invalid');
			else if (index > 0 && record[config.nameSpacePrefix + 'Member_Status__c'] == 'Valid') {
				component.set("v.memberStatus", 'inQueue');
				var firstValidMember=component.get('v.firstValidMember');
				if (firstValidMember && firstValidMember.Id==record.Id) {
					component.set("v.memberStatus", 'standby');
				}
			}

			var lastAssignment = {};
			lastAssignment.value = record[config.nameSpacePrefix + 'Last_Assignment__c'];
			if (lastAssignment.value) {
				lastAssignment.value = new Date(lastAssignment.value);
				lastAssignment.timezone = $A.get("$Locale.timezone");

				var version = this.detectIE();
				if (version === false) {
					// other browser
				} else if (version >= 12)
					lastAssignment.timezone = 'UTC';
				else
					lastAssignment.timezone = 'UTC';

				component.set('v.lastAssignment', lastAssignment);
			}
		}
	},

	editRecord: function(component, event, helper) {
		//notify recordTileList to create modal for editing record selected
		var ASGMT_RecordTileEvt = component.getEvent('ASGMT_RecordTileEvt');
		ASGMT_RecordTileEvt.setParams({
			'type': 'RECORD_EDIT',
			'parentRecord': component.get('v.parentRecord'),
			'record': component.get('v.record')
		});
		ASGMT_RecordTileEvt.fire();
	},

	editCriteriaSet: function(component) {
		//notify recordTileList to create modal for editing criteira set
		var ASGMT_RecordTileEvt = component.getEvent('ASGMT_RecordTileEvt');
		ASGMT_RecordTileEvt.setParams({
			'type': 'CRITERIA_SET_EDIT',
			'objectName': component.get('v.objectName'),
			'record': component.get('v.record')
		});
		ASGMT_RecordTileEvt.fire();
	},

	confirmDeletion: function(component, event) {

		var objectName = component.get('v.objectName');

		var recordId = event.target.getAttribute('data-id');
		var name = event.target.getAttribute('data-name');

		var popupheader = '';
		var message = '';
		if (objectName == 'Assignment_Rule__c') {
			popupheader = 'Delete Assignment Rule';
			message = 'Assignment Rule "' + name + ' (' + recordId + ')" will be deleted.<br/>';
			message += '<span style="color:red">All the related Assignment Rule Entries will be deleted as well.</span><br/>Are you sure?';
		} else if (objectName == 'Assignment_Rule_Entry__c') {
			popupheader = 'Delete Assignment Rule Entry';
			message = 'Assignment Rule Entry "' + name + ' (' + recordId + ')" will be deleted.<br/>';
			message += '<span style="color:red">The related Criteria Set will be deleted as well.</span><br/>Are you sure?';
		} else if (objectName == 'Assignment_Queue__c') {
			popupheader = 'Delete Assignment Queue';
			message = 'Assignment Queue "' + name + ' (' + recordId + ')" will be deleted.<br/>';
			message += '<span style="color:red">All the related Assignment Queue Members will be deleted as well.</span><br/>Are you sure?';
		} else if (objectName == 'Assignment_Queue_Member__c') {
			popupheader = 'Delete Assignment Queue Member';
			message = 'Assignment Queue Member "' + name + ' (' + recordId + ')" will be deleted.<br/>Are you sure?';
		}

		$A.createComponent(
			"c:Util_Notify", {
				'aura:id': "Util_Notify",
				'notificaionType': "popup",
				'popupheader': popupheader,
				'message': message
			},
			function(notifyModalComponent, status) {
				if (status === "SUCCESS") {
					var targetCmp = component.find('notifyPlaceholder');
					var body = targetCmp.get("v.body");
					body.push(notifyModalComponent);
					targetCmp.set("v.body", body);
				}
			}
		);
	},

	deleteRecord: function(component, event) {
		var notificationMessage = event.getParam('notificationMessage');
		if (notificationMessage == 'Deletion Confirmed') {
			component.find("recordDelete").deleteRecord($A.getCallback(function(deleteResult) {
				// NOTE: If you want a specific behavior(an action or UI behavior) when this action is successful
				// then handle that in a callback (generic logic when record is changed should be handled in recordUpdated event handler)
				if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") {
					// record is deleted
					// console.log("Record is deleted.");

				} else if (deleteResult.state === "INCOMPLETE") {
					// console.log("User is offline, device doesn't support drafts.");
				} else if (deleteResult.state === "ERROR") {
					// console.log('Problem deleting record, error: ' + JSON.stringify(deleteResult.error));
				} else {
					// console.log('Unknown problem, state: ' + deleteResult.state + ', error: ' + JSON.stringify(deleteResult.error));
				}
			}));
		}

	},

	fireASGMT_RecordTileEvt: function(component, event) {

		var eventParams = event.getParams();
		if (eventParams.changeType === "CHANGED") {
			// record is changed
		} else if (eventParams.changeType === "LOADED") {
			// record is loaded in the cache
		} else if (eventParams.changeType === "REMOVED") {
			var record = component.get('v.record');

			//notify recordTileList to refresh view
			var ASGMT_RecordTileEvt = component.getEvent('ASGMT_RecordTileEvt');
			ASGMT_RecordTileEvt.setParams({
				'type': 'RECORD_DELETE'
			});
			ASGMT_RecordTileEvt.fire();

			var objectName = component.get('v.objectName');
			var title = '';
			if (objectName == 'Assignment_Rule__c') {
				title = 'Assignment Rule "' + record.Name + ' (' + record.Id + ')" was deleted.';
			} else if (objectName == 'Assignment_Rule_Entry__c') {
				title = 'Assignment Rule Entry "' + record.Name + ' (' + record.Id + ')" was deleted.';
			} else if (objectName == 'Assignment_Queue__c') {
				title = 'Assignment Queue "' + record.Name + ' (' + record.Id + ')" was deleted.';
			} else if (objectName == 'Assignment_Queue_Member__c') {
				title = 'Assignment Queue Member "' + record.Name + ' (' + record.Id + ')" was deleted.';
			}

			// record is deleted, show a toast UI message
			var resultsToast = $A.get("e.force:showToast");
			if(resultsToast){
				resultsToast.setParams({
					"type": "success",
					"title": title,
					"message": ' '
				});
				resultsToast.fire();
			}
		} else if (eventParams.changeType === "ERROR") {
			// there’s an error while loading, saving, or deleting the record
		}

	},

	getRelatedList: function(component, event){
	    var objectName = event.target.id;
	    var parentObjectName = component.get("v.objectName");
	    var parentRecordId = component.get("v.record.Id");
	    var parentRecord = component.get("v.record");

	    var ASGMT_RecordTileEvt = component.getEvent("ASGMT_RecordTileEvt");
	    ASGMT_RecordTileEvt.setParams({
				'type':'RELATED_LIST_GET',
	      'objectName': objectName,
	      'parentObjectName': parentObjectName,
	      "parentRecordId": parentRecordId,
	      "parentRecord": parentRecord
	    });
	    ASGMT_RecordTileEvt.fire();

	    var ASGMT_TabEvt = $A.get("e.c:ASGMT_TabEvt");
	    ASGMT_TabEvt.setParams({
	      "tabId": event.target.id
	    });
	    ASGMT_TabEvt.fire();

	},

	detectIE: function() {
		var ua = window.navigator.userAgent;

		// Test values; Uncomment to check result …

		// IE 10
		// ua = 'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)';

		// IE 11
		// ua = 'Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko';

		// Edge 12 (Spartan)
		// ua = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.71 Safari/537.36 Edge/12.0';

		// Edge 13
		// ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2486.0 Safari/537.36 Edge/13.10586';

		var msie = ua.indexOf('MSIE ');
		if (msie > 0) {
			// IE 10 or older => return version number
			return parseInt(ua.substring(msie + 5, ua.indexOf('.', msie)), 10);
		}

		var trident = ua.indexOf('Trident/');
		if (trident > 0) {
			// IE 11 => return version number
			var rv = ua.indexOf('rv:');
			return parseInt(ua.substring(rv + 3, ua.indexOf('.', rv)), 10);
		}

		var edge = ua.indexOf('Edge/');
		if (edge > 0) {
			// Edge (IE 12+) => return version number
			return parseInt(ua.substring(edge + 5, ua.indexOf('.', edge)), 10);
		}

		// other browser
		return false;
	}
})