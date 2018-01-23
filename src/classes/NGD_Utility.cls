public class NGD_Utility {
    public static String SELECT_CLAUSE = ' SELECT ';
    public static String WHERE_CLAUSE = ' WHERE ';
    public static String FROM_CLAUSE = ' FROM ';

    public static Id getCurrentContactId() {
        List<User> users = [SELECT user.contactId, Name from User user where user.id = :Userinfo.getUserId() and user.contactId != null];
        if(users.size() > 0){
            return users[0].contactId;
        } else {
            return null;
        }
    }

    public static Id getActiveApplicationId(){
       Id contactId = NGD_Utility.getCurrentContactId();
       if(contactId != null) {
		   String query='select Id, Active_Application__c from Contact where Id =\''+ contactId+'\' limit 1';
		   Contact contact=(Contact)Database.query(query)[0];
		   return (Id)contact.get('Active_Application__c');
       }
       return null;
   }

     /****************************************************************************************
           This method returns list of all fieldSetMembers for passed object.
          @param objectName    Object Name
          @param fieldSetName    fieldset Name
          @return list of fieldset members
     *****************************************************************************************/
    public static List<sObject> getObjectWithFields(String objectName,Map<String,string> mapWhereClause,String OtherClause, List<schema.fieldsetmember> fieldSetValues, Set<String> customFields, NGD_Constant.RequiredFieldTypes fType) {
        String query = SELECT_CLAUSE ;
        try{
            Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
            Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(objectName);

            if(fType == NGD_Constant.RequiredFieldTypes.FIELDSET_FIELDS_CUSTOM_FIELDS || fType == NGD_Constant.RequiredFieldTypes.ALL_FIELDS || fType == NGD_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS || fType == NGD_Constant.RequiredFieldTypes.ONLY_CUSTOM_FIELDS){
                if(fType == NGD_Constant.RequiredFieldTypes.ALL_FIELDS || fType == NGD_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS) {
                    Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj .getDescribe();
                    Map<String,Schema.SObjectField> fields = describeSObjectResultObj.fields.getMap() ;
                    List<Schema.SObjectField> fieldMapValues = fields.values();
                    for(Schema.SObjectField field : fieldMapValues) {
                        query += field.getDescribe().getName();
                        query += ',';
                    }
                }
                if(fType == NGD_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS || fType == NGD_Constant.RequiredFieldTypes.ONLY_CUSTOM_FIELDS || fType == NGD_Constant.RequiredFieldTypes.FIELDSET_FIELDS_CUSTOM_FIELDS) {
                    if(customFields != null) {
                        for(String customeField : customFields) {
                            query += customeField+',';
                        }
                    }
                }
                /*
                if(fType == NGD_Constant.RequiredFieldTypes.FIELDSET_FIELDS_CUSTOM_FIELDS) {
                    for(schema.fieldsetmember f : fieldSetValues) {
                        if(!query.contains(f.getFieldPath()+',')) {
                            query += f.getFieldPath() + ',';
                        }
                    }
                }
                */
            }
            /*
            else if(fType == NGD_Constant.RequiredFieldTypes.ONLY_FIELDSET_FIELDS){
                for(schema.fieldsetmember f : fieldSetValues) {
                    if(!query.contains(f.getFieldPath()+',')) {
                        query += f.getFieldPath() + ',';
                    }
                }
            }
            */
            query = query.subString(0, query.length() - 1);
            query += FROM_CLAUSE + objectName;


            if(mapWhereClause.size() > 0){
                query += WHERE_CLAUSE;
                for(String fieldWithOperator : mapWhereClause.keyset()){
                  if(!String.isBlank(mapWhereClause.get(fieldWithOperator))){
                    if(mapWhereClause.get(fieldWithOperator).toLowerCase()=='true' || mapWhereClause.get(fieldWithOperator).toLowerCase()=='false')
                    query += fieldWithOperator + Boolean.valueOf(mapWhereClause.get(fieldWithOperator)) +' AND ';
                    else if(fieldWithOperator.toLowerCase().contains(' in '))
                    query += fieldWithOperator + '(' +  mapWhereClause.get(fieldWithOperator) + ')' +' AND ';
                    else
                    query += fieldWithOperator  + '\'' + mapWhereClause.get(fieldWithOperator) + '\'' +' AND ';
                  }
         			else{
                    query += fieldWithOperator  + '\'' + mapWhereClause.get(fieldWithOperator) + '\'' +' AND ';
                  }
                }
                query = query.subString(0, query.length() - 4);
            }

            if(!String.isBlank(OtherClause))
            query=query+' '+OtherClause;

			   System.debug('### query: '+query);

            return Database.query(query);
        } catch(Exception e) {
            system.debug(e.getMessage() + '### query: ' + query);
            return null;
        }
    }
}