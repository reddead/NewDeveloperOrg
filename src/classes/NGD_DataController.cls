global class NGD_DataController {
    public static String namespacePrefixClass{
        get{
            namespacePrefixClass='';
            if(String.isBlank(namespacePrefixClass))
            namespacePrefixClass ='';
            else
            namespacePrefixClass=namespacePrefixClass+'.';

            return namespacePrefixClass;
        }
        set;
    }

    public static String namespacePrefix{
        get{
            namespacePrefix='';
            if(String.isBlank(namespacePrefix))
            namespacePrefix ='';
            else
            namespacePrefix=namespacePrefix+'__';

            return namespacePrefix;
        }
        set;
    }


    public static String criteriaObjectList{
        get{
            criteriaObjectList='';
            criteriaObjectList+='Contact,';
            criteriaObjectList+='Application__c,';
            criteriaObjectList=criteriaObjectList.substring(0,criteriaObjectList.length()-1);
            return criteriaObjectList;
        }
        set;
    }

    //get all necessary object describe results
    public static String describesJson{
        get{
            Map<String, Schema.SobjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String,String> objtypeMap=new Map<String,String>();
            for(String objectName:criteriaObjectList.split(',')){
                objtypeMap.put(objectName,objectName);
                Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
                for(Schema.SObjectField sfield : fieldMap.Values()){
                    schema.describeFieldResult dfr = sfield.getDescribe();
                    if(String.valueOf(dfr.getType()).toLowerCase()=='reference'){
                        for(Schema.sObjectType sobjType :dfr.getReferenceTo()){
                            String refObjectName=sobjType.getDescribe().getName();
                            if(refObjectName.toLowerCase()=='group')
                            continue;
                            if(!objtypeMap.containsKey(refObjectName))
                            objtypeMap.put(refObjectName,refObjectName);
                        }
                    }
                }
            }
            describesJson=NGD_DataController.describes(objtypeMap.values());
            return describesJson;
        }
        set;
    }


    @remoteAction
    public static String describe(String objtype) {
        // Just enough to make the sample app work!
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        if (targetType == null) {
            return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
        }

        Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();

        Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();

        List<Object> fields = new List<Object>();
        for (String key : fieldMap.keySet()) {
            Schema.DescribeFieldResult descField = fieldMap.get(key).getDescribe();
            Map<String, Object> field = new Map<String, Object>();

            field.put('type', descField.getType().name().toLowerCase());
            field.put('name', descField.getName());
            field.put('label', descField.getLabel());
            field.put('picklistValues', descField.getPicklistValues());
            field.put('controllerName', String.valueOf(descField.getController()));
            field.put('relationshipName', String.valueOf(descField.getRelationshipName()));
            field.put('isCustom', descField.isCustom());

            List<String> references = new List<String>();
            for (Schema.sObjectType t : descField.getReferenceTo()) {
                String refObjectName=t.getDescribe().getName();
                if(refObjectName.toLowerCase()!='group')
                references.add(refObjectName);
            }
            if (!references.isEmpty()) {
                field.put('referenceTo', references[0]);
            }

            fields.add(field);
        }

        Map<String, Object> result = new Map<String, Object>();
        result.put('fields', fields);
        result.put('objtype', objtype);

        return JSON.serialize(result);
    }


    @remoteAction
    public static String describes(list<String> objtypes) {
        Map<String,Map<String, Object>> describeResults = new Map<String,Map<String, Object>>();
        for(String objtype:objtypes){
            // Just enough to make the sample app work!
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
            if (targetType == null) {
                return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
            }

            Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();

            Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();

            List<Object> fields = new List<Object>();
            for (String key : fieldMap.keySet()) {
                Schema.DescribeFieldResult descField = fieldMap.get(key).getDescribe();
                Map<String, Object> field = new Map<String, Object>();

                field.put('type', descField.getType().name().toLowerCase());
                field.put('name', descField.getName());
                field.put('label', descField.getLabel());
                field.put('picklistValues', descField.getPicklistValues());
                field.put('controllerName', String.valueOf(descField.getController()));
                field.put('relationshipName', String.valueOf(descField.getRelationshipName()));
                field.put('isCustom', descField.isCustom());

                List<String> references = new List<String>();
                for (Schema.sObjectType t : descField.getReferenceTo()) {
                    String refObjectName=t.getDescribe().getName();
                    if(refObjectName.toLowerCase()!='group')
                    references.add(refObjectName);
                }
                if (!references.isEmpty()) {
                    field.put('referenceTo', references[0]);
                }

                fields.add(field);
            }

            Map<String, Object> result = new Map<String, Object>();
            result.put('fields', fields);
            describeResults.put(objtype,result);
        }
        return JSON.serialize(describeResults);
    }

    @remoteAction
    public static String sObjectKlone(String iId) {
        String results;
        try {
            Id id = (id) iId;
            String namespacePrefixLocal=namespacePrefix;
            sObjectType type = id.getSObjectType();
            Schema.DescribeSObjectResult dr = type.getDescribe();
            map<String, Schema.SObjectField> fieldMap = dr.fields.getMap();
            String qs = 'SELECT Id';
            Set<string> querySet = new Set<string>();
            querySet.addAll(fieldMap.keySet());
            querySet.remove('id');
            for (String f : querySet) {
                if(dr.getName()==namespacePrefixLocal+'Homepage_Widget_Layout__c' || dr.getName()==namespacePrefixLocal+'Homepage_Widget__c'){
                    if(f!=namespacePrefixLocal+'Preview__c' && f!=namespacePrefixLocal+'Default__c')
                    qs += ', ' + f;
                }
                else
                qs += ', ' + f;
            }
            qs += ' FROM ' + dr.getName() + ' WHERE id = \'' + id + '\' LIMIT 1';
            sObject toClone = Database.query(qs);
            sObject cloned = toClone.clone(false, true, false, false);
            system.debug('###dr.getName(): '+dr.getName());
            if(dr.getName()!='Contact')
            cloned.put('Name',toClone.get('Name') + ' - Copy');

            upsert cloned;
            results = cloned.id;
        } catch (Exception e) {
            system.debug(e);
            results = e.getMessage();
            system.debug('###e.getMessage(): '+e.getMessage());
        }
        return results;
    }

    //@remoteAction
    //public static String sObjectSuperClone(String sourceId) {
       //String destinationId=sObjectKlone(sourceId);
        //if(!String.isBlank(destinationId)) {
             //String objectName=CloneListUtil.getObjectNameBasedOnPrefix(String.escapeSingleQuotes(sourceId));
             //List<ChildRelationship> childRecords=CloneListUtil.getChildRecordNames(objectName, String.escapeSingleQuotes(sourceId));
             //for(ChildRelationship child : childRecords)
             //child.setSelected(true);

            //CloneListUtil.createCloneChildRecords(String.escapeSingleQuotes(sourceId), String.escapeSingleQuotes(destinationId), childRecords);
        //}
        //return destinationId;
    //}

    @remoteAction
    public static String del(String objtype, String id) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        if (targetType == null) {
            return '[{"message":"The requested resource does not exist","errorCode":"NOT_FOUND"}]';
        }

        SObject obj = targetType.newSObject(id);

        try {
            delete obj;
        } catch (DMLException e) {
            return '[{"message":"' + e.getDmlMessage(0) + '","errorCode":"' + e.getDmlType(0).name() + '"}]';
        }

        return null;
    }

   @remoteAction
    public static String query(String objectName,String fields,String lookupFields, String queryCondition) {
        List<sObject> records;
        String query;

        query = 'SELECT ';

        if(!String.isBlank(fields)){
            query +=fields;
        }else{
            Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            // add the fields from the describe method and append them to the queryString one by one.
            for(String s : objectFields.keySet()) {
               query +=s + ',';
            }
        }
        // Manually add related object's fields that are needed.
        if(!String.isBlank(lookupFields))
        query += lookupFields;

        // Strip off the last comma if it exists.
        if (query.subString(query.Length()-1,query.Length()) == ','){
            query = query.subString(0,query.Length()-1);
        }

        // Add FROM statement
        query += ' FROM ' + objectName;

        // Add on a WHERE/ORDER/LIMIT statement as needed
        if (!String.isBlank(queryCondition)){
            query += ' WHERE ' + queryCondition; //firstName = \'test\''; add condition/
        }

        try {
            records = Database.query(query);
        } catch (QueryException qe) {
            return '[{"message":"' + qe.getMessage() + '","errorCode":"INVALID_QUERY"}]';
        }

        Map<String, Object> result = new Map<String, Object>();
        result.put('records', records);
        result.put('totalSize', records.size());
        result.put('done', true);

        return JSON.serialize(result);
    }

    @remoteAction
    public static SObject upsertData(String objType,String strJSON) {
        SObject sObj=(SObject) JSON.deserialize(strJSON, Type.forName(objType));
        upsert sObj;
        return sObj;
    }

    @remoteAction
    public static List<SObject> upsertDataBulk(String objType,String strJSON) {
        List<SObject> sObjList=(List<SObject>) JSON.deserialize(strJSON, Type.forName('List<' + objType + '>'));
        upsert sObjList;
        return sObjList;
    }

    @remoteAction
    public static Map<String, List<SObject>> processChecklistCotents(String applicationId) {
        Map<String, Schema.SObjectType> gd =Schema.getGlobalDescribe();
        Map<String, List<SObject>> result = new Map<String, List<SObject>>();

        Map<String, String> mapWhereClause = new Map<String, String>();
        Set<String> customFields = new Set<String>();
        mapWhereClause.clear();
        customFields.clear();

        if (gd.get('Education_History__c') != null) {
            mapWhereClause.put('Application__c=', applicationId);
            mapWhereClause.put('Display_to_Applicant__c=', 'true');
            list<sObject> ehList=NGD_Utility.getObjectWithFields('Education_History__c', mapWhereClause,'ORDER BY Display_Order__c',null, customFields, NGD_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS);
            result.put('ehList', ehList);
        }

        if (gd.get('Recommendation__c') != null) {
            list<sObject> recList=NGD_Utility.getObjectWithFields('Recommendation__c', mapWhereClause, 'ORDER BY Display_Order__c',null, customFields, NGD_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS);
            result.put('recList', recList);
        }

        if (gd.get('Test_Score__c') != null) {
            list<sObject> tsList=NGD_Utility.getObjectWithFields('Test_Score__c', mapWhereClause, 'ORDER BY Display_Order__c',null, customFields, NGD_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS);
            result.put('tsList', tsList);
        }

        if (gd.get('Admissions_Document__c') != null) {
            list<sObject> docList=NGD_Utility.getObjectWithFields('Admissions_Document__c', mapWhereClause, 'ORDER BY Display_Order__c',null, customFields, NGD_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS);
            result.put('docList', docList);
        }

        System.debug('### result: '+result);

        if(result.keySet().size()!=0)
        return result;
        else
        return null;

    }

}