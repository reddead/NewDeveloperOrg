public class NGD_CommunityMyProfileController {
	public String dataResultsJSON{get;set;}

	public NGD_CommunityMyProfileController(NGD_DataController dataCtrl){
		Map<String,String> dataResults = new Map<String,String>();

		Map<String, String> mapWhereClause = new Map<String, String>();
		Set<String> customFields = new Set<String>();

		//contact
		mapWhereClause.clear();
		customFields.clear();
		mapWhereClause.put('Id=', NGD_Utility.getCurrentContactId());

    sObject contact=(sObject)NGD_Utility.getObjectWithFields('Contact', mapWhereClause, null,null, customFields, NGD_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS)[0];
		dataResults.put('contactJSON',JSON.serialize(contact));

		//application
	  mapWhereClause.clear();
	  customFields.clear();
	  mapWhereClause.put('Id=', NGD_Utility.getActiveApplicationId());

		sObject application=(sObject)NGD_Utility.getObjectWithFields('Application__c', mapWhereClause, null,null, customFields, NGD_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS)[0];
		dataResults.put('applicationJSON',JSON.serialize(application));

		//contactDescribe
		dataResults.put('contactDescribeJSON',NGD_DataController.describe('Contact'));

		dataResults.put('namespacePrefix',NGD_DataController.namespacePrefix);
		dataResults.put('namespacePrefixClass',NGD_DataController.namespacePrefixClass);
		dataResultsJSON=String.escapeSingleQuotes(JSON.serialize(dataResults));
	}
 }