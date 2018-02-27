({
	doInit: function(component) {
		  var config=component.get('v.config');
			var nameSpacePrefix=config.nameSpacePrefix;
			var configurations = JSON.parse(config.configurationsJson);
			var objectNames=component.get('v.objectNames');
			objectNames=[];
			configurations.forEach(function(configuration) {
				var item={};
				item.label=configuration[nameSpacePrefix+'Related_To__c'];
				item.value=item.label;
				objectNames.push(item);
			});
			component.set('v.objectNames',objectNames);
	},

	changeHandler: function(component) {
    var changeEvent = component.getEvent("onchange");
    changeEvent.setParams({
      "value": component.get("v.selectedValue")
    });
    changeEvent.fire();
  }
})