public class NGD_HomepageBuilderController{
	public String dataJson{get;set;}

    public NGD_HomepageBuilderController(NGD_DataController dataController) {
			Map<String,String> data = new Map<String,String>();

			Map<String, String> mapWhereClause=new Map<String, String>();
			Set<String> customFields=new Set<String>();
			List<SObject> hlList=NGD_Utility.getObjectWithFields(NGD_Constant.HOMEPAGE_LAYOUT, mapWhereClause, null,null, customFields, NGD_Constant.RequiredFieldTypes.ALL_FIELDS);

			data.put('hlListJson',JSON.serialize(hlList));
			data.put('criteriaObjectList',NGD_DataController.criteriaObjectList);
			data.put('describesJson',NGD_DataController.describesJson);
			data.put('namespacePrefix',NGD_DataController.namespacePrefix);
			data.put('namespacePrefixClass',NGD_DataController.namespacePrefixClass);
			dataJson=String.escapeSingleQuotes(JSON.serialize(data));
			dataJson=dataJson.replace('</script>','<\\/script>');//fix the closing </script> tag escape issue
    }
}