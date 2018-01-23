({
	doInit: function(cmp, event, helper) {
		helper.doInit(cmp);
	},

	cancel: function(cmp, event, helper) {
		helper.cancel(cmp);
	},

	delete: function(cmp, event, helper) {
		helper.delete(cmp);
	},

	backToSetup: function(cmp, event, helper) {
		helper.backToSetup(cmp);
	},

	hideNotification: function(cmp, event, helper) {
		cmp.set("v.show", false);
	},

	setModal: function(cmp, event, helper) {
		cmp.set("v.notificaionType", "popup");
		helper.setNotification(cmp, event, helper);
	},

	setBar: function(cmp, event, helper) {
		cmp.set("v.notificaionType", "bar");
		helper.setNotification(cmp, event, helper);
	},

	redirect: function(cmp, event, helper) {
		var redirectUri = cmp.get("v.redirectUri");
		if (!$A.util.isEmpty(redirectUri)) {
			window.open(redirectUri, '_self');
		}
	}
})