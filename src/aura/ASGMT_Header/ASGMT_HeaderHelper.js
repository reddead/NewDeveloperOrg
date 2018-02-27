({
	doInit: function(component) {
		var isAssignmentManagerActive=component.get('v.isAssignmentManagerActive');
		if(!isAssignmentManagerActive){
      $A.createComponent(
	      "c:Util_Notify", {
	        'aura:id': "Util_Notify",
	        'notificaionType': "popup",
	        'popupheader': 'Back to Setup',
	        'message': 'Please activate Assignment Manager first'
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
    }
	},

	handleASGMT_TabEvt: function(component, event) {
		var tabId = event.getParam('tabId'); //tabId was set to objectName
		var tabMessage = event.getParam('tabMessage')

		if(tabId)
			component.set('v.objectName', tabId);

		if(tabMessage=='No Configuration'){
			$A.createComponent(
	      "c:Util_Notify", {
	        'aura:id': "Util_Notify",
	        'notificaionType': "popup",
	        'popupheader': 'No activated SObject type found',
	        'message': 'please return to assignment setting and activate assignment for SObject type first'
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
		}
	},

	handleNotifyEvt: function(component, event) {
		var notificationMessage = event.getParam('notificationMessage');
		if (notificationMessage == 'Back To Setup Confirmed')
			window.location.href = '/setup/forcecomHomepage.apexp';

  },

	newRecord: function(component) {
		var headerActionEvt = $A.get("e.c:ASGMT_HeaderEvt");
		headerActionEvt.setParams({
			'actionName': 'new'
		});

		headerActionEvt.fire();
	},

	back: function(component) {
		var objectName = component.get('v.objectName');

		if (objectName.indexOf('Assignment_Rule_Entry__c') == -1 && objectName.indexOf('Assignment_Queue_Member__c') == -1) {
			$A.createComponent(
	      "c:Util_Notify", {
	        'aura:id': "Util_Notify",
	        'notificaionType': "popup",
	        'popupheader': 'Back to Setup',
	        'message': 'Are you sure?'
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
		}
		else{
			var headerActionEvt = $A.get("e.c:ASGMT_HeaderEvt");
			headerActionEvt.setParams({
				'actionName': 'back'
			});

			headerActionEvt.fire();
		}
	},
	refresh: function(component) {
		var headerActionEvt = $A.get("e.c:ASGMT_HeaderEvt");
		headerActionEvt.setParams({
			'actionName': 'refresh'
		});

		headerActionEvt.fire();
  },
})
