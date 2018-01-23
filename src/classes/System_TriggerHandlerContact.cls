public class System_TriggerHandlerContact Extends System_TriggerHandler {
    public override void beforeInsert(List<Sobject> newList){

    }

    public override void afterInsert(List<Sobject> oldList, List<Sobject> newList, Map<Id,Sobject> oldMap, Map<Id,Sobject> newMap){
      System_FeatureManager.performTask(System_FeatureAssignmentRule.class);
    }


    public override void beforeUpdate(List<Sobject> oldList, List<Sobject> newList, Map<Id,Sobject> oldMap, Map<Id,Sobject> newMap){

    }

    public override void afterUpdate(List<Sobject> oldList, List<Sobject> newList, Map<Id,Sobject> oldMap, Map<Id,Sobject> newMap){
				System_FeatureManager.performTask(System_FeatureAssignmentRule.class);
		}
}