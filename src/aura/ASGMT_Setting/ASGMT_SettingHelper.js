({
	spinner: null,
	nameSpacePrefix: null,
	sObjectDescribes: null,
	configurations: null,
	deletePackConfigId:'',
	deleteIndex:-1,

	doInit: function(component) {
		this.spinner = component.find('spinner');
		this.getConfig(component);
	},

	getConfig: function(component) {
		var self = this;
		var config = component.get('v.config');
		//get nameSpacePrefix
		this.nameSpacePrefix = config.nameSpacePrefix;

		//get sObjectDescribes
		this.sObjectDescribes = JSON.parse(config.sObjectDescribesJson);

		//get configurations
		this.configurations = JSON.parse(config.configurationsJson);
		if (this.configurations.length > 0) {
			this.configurations.forEach(function(configuration) {
				configuration.objectName = configuration[self.nameSpacePrefix + 'Related_To__c'];
				if (self.sObjectDescribes[configuration.objectName])
					configuration.iconName = self.sObjectDescribes[configuration.objectName].iconName;
				else
					configuration.iconName = "custom:custom9";
			});
			this.configurations = this.setIndex(this.configurations);
			component.set('v.configurations', this.configurations);
		}

		//get sObjectNames
		var sObjectNames = JSON.parse(config.sObjectNamesJson);
		var sObjectNamesArray = [];
		sObjectNames.forEach(function(sObjectName) {
			var item = {};
			item.label = sObjectName;
			item.value = sObjectName;
			sObjectNamesArray.push(item);
		});
		component.set('v.sObjectNames', sObjectNamesArray);
	},

	// handleASGMT_HeaderEvt: function(component, event) {
	// 	var actionName = event.getParam('actionName');
	// 	if (actionName == 'refresh')
	// 		this.doInit(component);
	// },

	pillButtonClicked: function(component, event) {
		var pill = event.getSource();
		var objectName=pill.get('v.label');
		this.deleteIndex = pill.get('v.name');
		this.deleteConfigurationId = this.configurations[this.deleteIndex].Id;

		var popupheader = 'Deactivate Assignment';
		var message = objectName + ' assignment will be deactivated.<br/>';
		message += '<span style="color:red">All Assignment Rules/Rule Entries related to this SObject type will be deleted.</span><br/>Are you sure?';
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

	deactivateAssignment: function(component, event) {
		var action = component.get("c.deleteConfiguration");
		action.setParams({
			"deleteConfigurationId": this.deleteConfigurationId
		});

		this.spinner.set('v.show', true);
		action.setCallback(this, function(response) {
			var ASGMT_SettingEvt=component.getEvent('ASGMT_SettingEvt');
	    ASGMT_SettingEvt.fire();

			this.configurations.splice(this.deleteIndex, 1);
			this.configurations = this.setIndex(this.configurations);
			component.set('v.configurations', this.configurations);
			this.spinner.set('v.show', false);
		});
		$A.enqueueAction(action);
	},

	addConfiguration: function(component, event) {
		var action = component.get("c.insertConfiguration");
		var select = event.getSource();
		var objectName = select.get('v.value');
		if (!objectName) {
			this.spinner.set('v.show', false);
			return;
		}
		action.setParams({
			"objectName": objectName
		});

		this.spinner.set('v.show', true);
		action.setCallback(this, function(response) {
			var configuration = response.getReturnValue();

			if (!configuration) {
				this.spinner.set('v.show', false);
				return;
			}

			var ASGMT_SettingEvt=component.getEvent('ASGMT_SettingEvt');
	    ASGMT_SettingEvt.fire();

			configuration.objectName = configuration[this.nameSpacePrefix + 'Related_To__c'];
			if (this.sObjectDescribes[configuration.objectName])
				configuration.iconName = this.sObjectDescribes[configuration.objectName].iconName;
			else
				configuration.iconName = "custom:custom9";
			this.configurations.push(configuration);
			this.configurations.sort(this.compare);
			this.configurations = this.setIndex(this.configurations);

			component.set('v.configurations', this.configurations);
			this.spinner.set('v.show', false);
		});
		$A.enqueueAction(action);
	},

	setIndex: function(configurations) {
		var n = 0;
		configurations.forEach(function(configuration) {
			configuration.index = n;
			n++;
		});
		return configurations;
	},

	compare: function(a, b) {
		if (a.objectName < b.objectName)
			return -1;
		if (a.objectName > b.objectName)
			return 1;
		return 0;
	}
})