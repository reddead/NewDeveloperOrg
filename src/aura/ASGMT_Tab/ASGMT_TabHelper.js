({
	// swithTabContent: function(component, event) {
	//   var tab = event.getSource();
	//   var tabId = tab.get('v.id');
	//   component.set('v.selectedTabId', tabId);
	// },
	injectComponentByTab: function(component, event) {
		var tab = event.getSource();
		var attributes = {};
		switch (tab.get('v.id')) {
			case 'Assignment_Rule__c':
				attributes = {
					"filter": {
						Name: '',
						Related_Object__c: ''
					},
					"objectName": 'Assignment_Rule__c'
				};
				this.injectComponent(component, 'c:ASGMT_RecordTileList', tab, attributes);
				break;
			case 'Assignment_Queue__c':
				attributes = {
					"filter": {
						Name: ''
					},
					"objectName": 'Assignment_Queue__c'
				};
				this.injectComponent(component, 'c:ASGMT_RecordTileList', tab, attributes);
				break;
		}
	},
	injectComponent: function(component, name, target, attributes) {
		$A.createComponent(name, attributes, function(contentComponent, status, error) {
			if (status === "SUCCESS") {
				target.set('v.body', contentComponent);
			} else {
				throw new Error(error);
			}
		});
	},
	destroyComponentByTab: function(component, event) {
		var tab = event.getSource();
		var cmp;
		var activeTab;
		var inactiveTab;
		var parentBody;

		if (tab.get('v.id')) {
			switch (tab.get('v.id')) {
				case 'Assignment_Rule__c':
					inactiveTab = component.find('Assignment_Queue__c'); //destroy inactive tab component
					if (inactiveTab) {
						parentBody = inactiveTab.get('v.body');
						if (parentBody[0])
							cmp = parentBody[0].getConcreteComponent();
					}
					//comp=component.find('Assignment_Queue__c').get('v.body')[0].find('AssignmentQueueTileList');
					break;
				case 'Assignment_Queue__c':
					inactiveTab = component.find('Assignment_Rule__c'); //destroy inactive tab component
					if (inactiveTab) {
						parentBody = inactiveTab.get('v.body');
						if (parentBody[0])
							cmp = parentBody[0].getConcreteComponent();
					}
					//component.find('Assignment_Rule__c').get('v.body')[0].find('AssignmentRuleTileList');
					break;
			}
		} else {
			var activeTabId = component.get('v.selectedTabId');
			activeTab = component.find(activeTabId); //destroy active tab component
			if (activeTab) {
				parentBody = activeTab.get('v.body');
				if (parentBody[0])
					cmp = parentBody[0].getConcreteComponent();
			}
		}
		if (cmp)
			cmp.destroy();
	}
})