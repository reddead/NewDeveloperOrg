({
	doInit: function(component) {

	},

	handleTabChangeEvt: function(component, event) {
		var tabId = event.getParam('tabId'); //tabId was set to objectName
		component.set('v.objectName', tabId);
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

		if (objectName.indexOf('Assignment_Rule__c') != -1 || objectName.indexOf('Assignment_Queue__c') != -1) {
			$A.createComponent(
	      "c:Util_Notify", {
	        'aura:id': "Util_Notify",
	        'notificaionType': "popup",
	        'popupheader': 'Back to setup',
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