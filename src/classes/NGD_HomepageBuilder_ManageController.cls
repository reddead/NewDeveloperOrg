public class NGD_HomepageBuilder_ManageController {
  public String dataJson{get;set;}

    public NGD_HomepageBuilder_ManageController (NGD_DataController dataController){
        Id hlId=ApexPages.currentPage().getParameters().get('id');

        if(!String.isBlank(hlId)){
            Map<String,String> data = new Map<String,String>();
            Map<String, String> mapWhereClause = new Map<String, String>();
            Set<String> customFields = new Set<String>();

            //selected layout
            mapWhereClause.put('Id=',hlId);
            Homepage_Widget_Layout__c hl=(Homepage_Widget_Layout__c)NGD_Utility.getObjectWithFields(NGD_Constant.HOMEPAGE_LAYOUT, mapWhereClause, null,null, customFields, NGD_Constant.RequiredFieldTypes.ALL_FIELDS)[0];
            data.put('hlJson',JSON.serialize(hl));

            //template related to the selected layout  //(Id)hl.get('Homepage_Template__c')
            List<Homepage_Template__c> htList=[select Id,Header__c,Footer__c from Homepage_Template__c where Id=:hl.Homepage_Template_Preview__c];
            if(htList.size()!=0){
              data.put('htJson',JSON.serialize(htList[0]));
            }

            //widget map
      			List<Homepage_Widget__c> hwlist=[select Id from Homepage_Widget__c];
      			if(hwlist.size()!=0){
      				Map<String,Boolean> hwIdMap=new Map<String,Boolean>();
      				for(Homepage_Widget__c hw:hwlist)
  				    hwIdMap.put(hw.Id,true);

      				String hwIdMapJson=JSON.serialize(hwIdMap);//get all existing hw id in current org
              data.put('hwIdMapJson',hwIdMapJson);
      			}

            data.put('criteriaObjectList',NGD_DataController.criteriaObjectList);
      			data.put('describesJson',NGD_DataController.describesJson);
      			data.put('namespacePrefix',NGD_DataController.namespacePrefix);
      			data.put('namespacePrefixClass',NGD_DataController.namespacePrefixClass);

      			dataJson=String.escapeSingleQuotes(JSON.serialize(data));
            dataJson=dataJson.replace('</script>','<\\/script>');//fix the closing </script> tag escape issue
        }
    }
 }