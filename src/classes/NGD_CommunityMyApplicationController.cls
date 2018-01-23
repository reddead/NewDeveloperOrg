public class NGD_CommunityMyApplicationController{
	//sobject
	public String contactJSON{get;set;}
	public String applicationJSON{get;set;}
	public String applicationsJSON{get;set;}
	public String highSchoolEHJSON{get;set;}
	public String collegesEHJSON{get;set;}
	public String familiesJSON{get;set;}

	//describe
	public String contactDescribeJSON{get;set;}
	public String applicationDescribeJSON{get;set;}
	public String termDescribeJSON{get;set;}
	public String educationHistoryDescribeJSON{get;set;}
	public String familyDescribeJSON{get;set;}

	//record type
    public static Id highSchoolEHRTId{get{return [select id from RecordType where Name='High School' and SobjectType='Education_History__c'].id;}set;}
    public static Id collegeEHRTId{get{return [select id from RecordType where Name='College' and SobjectType='Education_History__c'].id;}set;}
    public static Id highSchoolRTId{get{return [select id from RecordType where Name='High School' and SobjectType='School__c'].id;}set;}
    public static Id collegeRTId{get{return [select id from RecordType where Name='College' and SobjectType='School__c'].id;}set;}

	public NGD_CommunityMyApplicationController(NGD_DataController dataCtrl){
		Map<String, String> mapWhereClause = new Map<String, String>();
		Set<String> customFields = new Set<String>();

		//contact
		mapWhereClause.clear();
		customFields.clear();
		mapWhereClause.put('Id=', NGD_Utility.getCurrentContactId());

    sObject contact=(sObject)NGD_Utility.getObjectWithFields('Contact', mapWhereClause, null,null, customFields, NGD_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS)[0];
		contactJSON=String.escapeSingleQuotes(JSON.serialize(contact));

		//application
	  mapWhereClause.clear();
	  customFields.clear();
		customFields.add('Program_Offered__r.Id');
		customFields.add('Program_Offered__r.Name');
		customFields.add('Term__r.Id');
		customFields.add('Term__r.Name');
		customFields.add('Term__r.Year__c');
		customFields.add('Term__r.INTLSemester__c');
		customFields.add('Term__r.Semester__c');
	  mapWhereClause.put('Contact__c=', (Id)contact.get('Id'));

		List<sObject> applications=(List<sObject>)NGD_Utility.getObjectWithFields('Application__c', mapWhereClause, 'Order By Name',null, customFields, NGD_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS);

    //if application selected
    String appId=ApexPages.currentPage().getParameters().get('id');
    if (!String.isBlank(appId)){
        ////application
			mapWhereClause.clear();
			customFields.clear();
			mapWhereClause.put('Id=', appId);
			customFields.add('Program_Offered__r.Id');
			customFields.add('Program_Offered__r.Name');

			sObject application=(sObject)NGD_Utility.getObjectWithFields('Application__c', mapWhereClause, null,null, customFields, NGD_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS)[0];
			applicationJSON=String.escapeSingleQuotes(JSON.serialize(application));

			////education history
			Education_History__c highSchoolEH;
			List<Education_History__c> collegesEH=new List<Education_History__c>();

			mapWhereClause.clear();
			customFields.clear();
			mapWhereClause.put('Application__c=', appId);
			customFields.add('School__r.Id');
			customFields.add('School__r.Name');
			customFields.add('School__r.School_City__c');
			customFields.add('School__r.School_State__c');
			List<Education_History__c> educationHistories=(List<Education_History__c>)NGD_Utility.getObjectWithFields('Education_History__c', mapWhereClause, 'Order By Name',null, customFields, NGD_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS);

			for (Education_History__c eh:educationHistories){
				if(eh.RecordTypeId==highSchoolEHRTId)
				highSchoolEH=eh;
				if(eh.RecordTypeId==collegeEHRTId)
				collegesEH.add(eh);
			}
			highSchoolEHJSON=String.escapeSingleQuotes(JSON.serialize(highSchoolEH));
			collegesEHJSON=String.escapeSingleQuotes(JSON.serialize(collegesEH));

			//family
			List<Family__c> families=[select Relationship__c,First_Name__c,Last_Name__c,Passport_Country_of_Issue__c,Passport_Number__c,Passport_Expiration_Date__c from Family__c where Application__c=:appId];
			familiesJSON=String.escapeSingleQuotes(JSON.serialize(families));

		}

		//describe
			////contactDescribe
			contactDescribeJSON=String.escapeSingleQuotes(NGD_DataController.describe('Contact'));
			////applicationDescribe
			applicationDescribeJSON=String.escapeSingleQuotes(NGD_DataController.describe('Application__c'));
			////termDescribe
			termDescribeJSON=String.escapeSingleQuotes(NGD_DataController.describe('Term__c'));
			////educationHistoryDescribe
			educationHistoryDescribeJSON=String.escapeSingleQuotes(NGD_DataController.describe('Education_History__c'));
			////familyDescribe
			familyDescribeJSON=String.escapeSingleQuotes(NGD_DataController.describe('Family__c'));

			contactJSON=String.escapeSingleQuotes(JSON.serialize(contact));
			applicationsJSON=String.escapeSingleQuotes(JSON.serialize(applications));

	}
 }