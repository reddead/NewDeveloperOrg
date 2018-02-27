public with sharing class System_TriggerFactory
{

    /**
     * Public static method to create and execute a trigger handler
     *
     * Arguments:   Schema.sObjectType soType - Object type to process (SObject.sObjectType)
     *
     * Throws a TriggerException if no handler has been coded.
     */
    public static void createHandler(Type t)
    {
        if(!checkTriggerRule())
        return;

        // Get a handler appropriate to the object being processed
        System_TriggerHandler handler = getHandler(t);

        // Make sure we have a handler registered, new handlers must be registered in the getHandler method.
        if (handler == null){
            throw new System_TriggerException('No Trigger Handler found named: ' + t.getName());
        }
        // Execute the handler to fulfil the trigger
        execute(handler);
    }

    private static Boolean checkTriggerRule(){
      if(Trigger.isUpdate){
          String sObjectName=Trigger.new[0].getSObjectType().getDescribe().getName();

          System.debug('>>>sObjectName:'+sObjectName);
          System.debug('>>>System_FeatureAssignmentRule.TriggerObjectName_IsARExecuting.get(sObjectName):'+System_FeatureAssignmentRule.TriggerObjectName_IsARExecuting.get(sObjectName));

          if(System_FeatureAssignmentRule.TriggerObjectName_IsARExecuting.get(sObjectName)!=null && System_FeatureAssignmentRule.TriggerObjectName_IsARExecuting.get(sObjectName))
              return false;
      }
      return true;
    }

    /**
     * private static method to control the execution of the handler
     *
     * Arguments:   ITrigger handler - A Trigger Handler to execute
     */
    private static void execute(System_TriggerHandler handler)
    {
        if (Trigger.isBefore) {
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();

            if (Trigger.isDelete) {
                handler.beforeDelete(Trigger.old, Trigger.oldMap);
            }
            else if (Trigger.isInsert) {
                handler.beforeInsert(Trigger.new);
            }
            else if (Trigger.isUpdate)
            {
                handler.beforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
        } else {
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();

            if (Trigger.isDelete) {
                handler.afterDelete(Trigger.old, Trigger.oldMap);
            }
            else if (Trigger.isInsert) {
                handler.afterInsert(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            }
            else if (Trigger.isUpdate) {
                handler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);

            }else if(Trigger.isUnDelete){
                handler.afterUnDelete(Trigger.new, Trigger.newMap);
            }
        }

        // Perform any post processing
        handler.andFinally();
    }

    /**
     * private static method to get the appropriate handler for the object type.
     * Modify this method to add any additional handlers.
     *
     * Arguments:   Schema.sObjectType soType - Object type tolocate (SObject.sObjectType)
     *
     * Returns:     ITrigger - A trigger handler if one exists or null.
     */

    private static System_TriggerHandler getHandler(Type t)
    {

        Object obj = t.newInstance();

        // if its not an instance of System_TriggerHandler return null
        if (!(obj instanceOf System_TriggerHandler))
        {
            return null;
        }

        return (System_TriggerHandler)obj;
    }

}