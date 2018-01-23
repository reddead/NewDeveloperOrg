public with sharing abstract class System_TriggerHandler{

	public virtual void bulkBefore(){}

    /**
     * bulkAfter
     *
     * This method is called prior to execution of an AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public virtual void bulkAfter(){}

    /**
     * beforeInsert
     *
     * This method is called for records during a BEFORE
     * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
     */
    public virtual void beforeInsert(List<Sobject> newList){}
    /**
     * beforeUpdate
     *
     * This method is called for records to be updated during a BEFORE
     * trigger.
     */
    public virtual void beforeUpdate(List<Sobject> oldList, List<Sobject> newList, Map<Id,Sobject> oldMap, Map<Id,Sobject> newMap){}

    /**
     * beforeDelete
     *
     * This method is called for records to be deleted during a BEFORE
     * trigger.
     */
    public virtual void beforeDelete(List<Sobject> oldList, Map<Id, Sobject> oldMap){}

    /**
     * afterInsert
     *
     * This method is called  for records inserted during an AFTER
     * trigger. Always put field validation in the 'After' methods in case another trigger
     * has modified any values. The record is 'read only' by this point.
     */
    public virtual void afterInsert(List<Sobject> oldList, List<Sobject> newList, Map<Id,Sobject> oldMap, Map<Id,Sobject> newMap){}

    /**
     * afterUpdate
     *
     * This method is called for records updated during an AFTER
     * trigger.
     */
    public virtual void afterUpdate(List<Sobject> oldList, List<Sobject> newList, Map<Id,Sobject> oldMap, Map<Id,Sobject> newMap){}

    /**
     * afterDelete
     *
     * This method is called for records deleted during an AFTER
     * trigger.
     */
    public virtual void afterDelete(List<Sobject> oldList, Map<Id, Sobject> oldMap){}

    /**
     * afterUnDelete
     *
     * This method is called after records are undeleted.
     */
    public virtual void afterUnDelete(List<Sobject> newList, Map<Id, Sobject> newMap){}

    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public virtual void andFinally(){}
}