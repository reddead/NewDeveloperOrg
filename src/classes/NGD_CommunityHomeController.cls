public class NGD_CommunityHomeController{
    public String dataJson{get;set;}

    public Map<String,String> data;
    public Map<String,Set<String>> ObjectName_CustomFields;

    public static String contactId=NGD_Utility.getCurrentContactId();
    public static String applicationId=NGD_Utility.getActiveApplicationId();

    public NGD_CommunityHomeController(NGD_DataController dataController){
        data = new Map<String,String>();
        ObjectName_CustomFields=new Map<String,Set<String>>();
        try{
            getHomepageTemplate();
            SObject hl= getHomepageLayout();
            if(hl!=null)
                getHomepageWidgets(hl);
            getContact();
            getApplication();

            data.put('namespacePrefix',NGD_DataController.namespacePrefix);
            data.put('namespacePrefixClass',NGD_DataController.namespacePrefixClass);
            dataJson=String.escapeSingleQuotes(JSON.serialize(data));
            dataJson=dataJson.replace('</script>','<\\/script>');//fix the closing </script> tag escape issue
        }
        catch(Exception e){
            ///ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.ERROR,e.getMessage()));
            String errorMessage='Environment Error For Current User<br/>'+e.getMessage();
            data.put('errorMessage',errorMessage);
            dataJson=String.escapeSingleQuotes(JSON.serialize(data));
            dataJson=dataJson.replace('</script>','<\\/script>');//fix the closing </script> tag escape issue
        }
    }

    private SObject getHomepageLayout(){
        Map<String, String> mapWhereClause = new Map<String, String>();
        mapWhereClause.put('Is_Active__c=','true');
        List<SObject> hlList=NGD_Utility.getObjectWithFields(NGD_Constant.HOMEPAGE_LAYOUT, mapWhereClause,
        'ORDER BY Name',null, null, NGD_Constant.RequiredFieldTypes.ALL_FIELDS);

        if(hlList.size()!=0){
          NGD_HomepageCriteriaParser hcp=new NGD_HomepageCriteriaParser(hlList,NGD_Constant.HOMEPAGE_LAYOUT,contactId,applicationId);
          System.debug('>>>hcp.sobjList.size(): '+hcp.sobjList.size());
          //no layout available
          if(hcp.sobjList.size()==0){
            String errorMessage='Homepage Layout Not Found<br/>Please make sure layout active and/or meet the display criteria';
            data.put('errorMessage',errorMessage);
          }
          //correct layout found
          else if(hcp.sobjList.size()==1){
              data.put('hlJson',JSON.serialize(hcp.sobjList[0]));
              return hcp.sobjList[0];
          }
          //more than one layout found
          else if(hcp.sobjList.size()>1){
            String errorMessage = 'Mutiple Layouts Found <br/><ul style=\'padding-left: 118px;\'>';
            for(SObject hl:hcp.sobjList){
              errorMessage += '<li style=\'word-break: break-word;text-align: left;\'>Name:' + hl.get('Name') + '</li>';
            }
            errorMessage += '</ul>';
            data.put('errorMessage',errorMessage);
          }
        }
        return null;
    }

    private SObject getHomepageTemplate(){
        Map<String, String> mapWhereClause = new Map<String, String>();
        mapWhereClause.put('Is_Active__c=','true');
        List<SObject> htList=NGD_Utility.getObjectWithFields(NGD_Constant.HOMEPAGE_TEMPLATE, mapWhereClause,
        'ORDER BY Name',null, null, NGD_Constant.RequiredFieldTypes.ALL_FIELDS);

        System.debug('>>>htList.size(): '+htList.size());

        if(htList.size()!=0){
          NGD_HomepageCriteriaParser hcp=new NGD_HomepageCriteriaParser(htList,NGD_Constant.HOMEPAGE_TEMPLATE,contactId,applicationId);
          //no layout available
          if(hcp.sobjList.size()==0){
            String errorMessage='Homepage Template Not Found<br/>Please make sure template active and/or meet the display criteria';
            data.put('errorMessage',errorMessage);
          }
          //correct template found
          else if(hcp.sobjList.size()==1){
              data.put('htJson',JSON.serialize(hcp.sobjList[0]));
              return hcp.sobjList[0];
          }
          //more than one template found
          else if(hcp.sobjList.size()>1){
            String errorMessage = 'Mutiple Templates Found <br/><ul style=\'padding-left: 118px;\'>';
            for(SObject ht:hcp.sobjList){
              errorMessage += '<li style=\'word-break: break-word;text-align: left;\'>Name:' + ht.get('Name') + '</li>';
            }
            errorMessage += '</ul>';
            data.put('errorMessage',errorMessage);
          }
        }
        return null;
    }

    private void getHomepageWidgets(SObject hl){
        Map<String, String> mapWhereClause = new Map<String, String>();
        mapWhereClause.put('Is_Active__c=','true');
        mapWhereClause.put('Number__c IN ', getWidgetNumbers((String)hl.get('Grid_Data__c')));
        List<SObject> hwList=NGD_Utility.getObjectWithFields(NGD_Constant.HOMEPAGE_WIDGET, mapWhereClause,
        'ORDER BY Name',null, null, NGD_Constant.RequiredFieldTypes.ALL_FIELDS);

        if(hwList.size()!=0){
            NGD_HomepageCriteriaParser hcp=new NGD_HomepageCriteriaParser(hwList,NGD_Constant.HOMEPAGE_WIDGET,contactId,applicationId);
            String widgetNumbers='';
            for(String widgetNumber:hcp.hwMap.keySet()){
                widgetNumbers+=widgetNumber+',';
                data.put('widgetNumbers',widgetNumbers);

                system.debug('### hcp.hwMap.get(widgetNumber): '+hcp.hwMap.get(widgetNumber));
                //no widget available
                if(hcp.hwMap.get(widgetNumber).size()==0){
                  String content='<div style="color:red">Error: Widget - ' + widgetNumber + ' Not Found<br/>Please make sure widget active and/or meet the display criteria</div>';
                  content='<div class="grid-stack-item"><div class="grid-stack-item-content"><div class="widget-content">' + content + '</div></div></div>';
                  data.put(widgetNumber,content);
                }
                //correcty widget found
                else if(hcp.hwMap.get(widgetNumber).size()==1){
                    String content=(String)hcp.hwMap.get(widgetNumber)[0].get(NGD_DataController.namespacePrefix + 'Content__c');
                    content='<div class="grid-stack-item"><div class="grid-stack-item-content"><div class="widget-content">' + content + '</div></div></div>';
                    data.put(widgetNumber,content);

                    String lookupFields=(String)hcp.hwMap.get(widgetNumber)[0].get(NGD_DataController.namespacePrefix + 'Lookup_Fields__c');
                    if(lookupFields!=null)
                    setMapObjectName_CustomFields(lookupFields);
                }
                //multiple widgets found
                else if(hcp.hwMap.get(widgetNumber).size()>1){
                  String content = '<div style="color:red">Error: Mutiple Widgets Found </div><ul>';
                  for(SObject hw: hcp.hwMap.get(widgetNumber))
                  content += '<li style="word-break: break-word;">Name: ' + hw.get('Name') + '</li>';
                  content += '</ul>';
                  content='<div class="grid-stack-item"><div class="grid-stack-item-content"><div class="widget-content">' + content + '</div></div></div>';
                  data.put(widgetNumber,content);
                }
            }
        }
    }

    private void getContact(){
        Map<String, String> mapWhereClause = new Map<String, String>();
        mapWhereClause.put('Id=', contactId);
        SObject contact=NGD_Utility.getObjectWithFields(NGD_Constant.CONTACT, mapWhereClause, null,null, ObjectName_CustomFields.get(NGD_Constant.CONTACT), NGD_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS)[0];

        data.put('contactJson',JSON.serialize(contact));
    }

    private void getApplication(){
        Map<String, String> mapWhereClause = new Map<String, String>();
        mapWhereClause.put('Id=', applicationId);
        SObject application=NGD_Utility.getObjectWithFields(NGD_Constant.APPLICATION, mapWhereClause, null,null, ObjectName_CustomFields.get(NGD_Constant.APPLICATION), NGD_Constant.RequiredFieldTypes.ALL_FIELDS_WITH_CUSTOM_FIELDS)[0];

        data.put('applicationJson',JSON.serialize(application));
    }

    private void setMapObjectName_CustomFields(String lookupFields){
        for(String lookupField:lookupFields.split(';')){
            String finalizedLookupField=lookupField.substring(lookupField.indexOf('.') + 1, lookupField.length());
            if(lookupField.toLowerCase().contains('contact.')){
                if(!ObjectName_CustomFields.containsKey(NGD_Constant.CONTACT)){
                    ObjectName_CustomFields.put(NGD_Constant.CONTACT,new Set<String>());
                    ObjectName_CustomFields.get(NGD_Constant.CONTACT).add(finalizedLookupField);
                }
                else
                ObjectName_CustomFields.get(NGD_Constant.CONTACT).add(finalizedLookupField);
            }
            else if(lookupField.toLowerCase().contains('application.')){
                if(!ObjectName_CustomFields.containsKey(NGD_Constant.APPLICATION)){
                    ObjectName_CustomFields.put(NGD_Constant.APPLICATION,new Set<String>());
                    ObjectName_CustomFields.get(NGD_Constant.APPLICATION).add(finalizedLookupField);
                }
                else
                ObjectName_CustomFields.get(NGD_Constant.APPLICATION).add(finalizedLookupField);
            }
        }
    }

    private String getWidgetNumbers(String gridDataJson){
        String widgetNumbers='';
        gridDataJson=gridDataJson.replace('"number":','"widgetNumber":');
        List<GridData> gridData =  (List<GridData>)JSON.deserialize(gridDataJson,List<NGD_CommunityHomeController.GridData>.class);
        for(GridData item:gridData){
            widgetNumbers += '\'' +item.widgetNumber + '\',';
        }
        widgetNumbers = widgetNumbers.substring(0, widgetNumbers.length() - 1);
        return widgetNumbers;
    }

    Class GridData{
        String x;
        String y;
        String width;
        String height;
        String widgetNumber;
        String preview;
        String content;
    }
}