trigger UserTrigger on User (after insert, after update) {
    if (!UserHelper.isTriggerRun) {
    	if (Trigger.isAfter){
            if(Trigger.isInsert){ 
                UserHelper.afterInsert(Trigger.newMap, Trigger.oldMap);
            }
            if (Trigger.isUpdate) {
                UserHelper.afterUpdate(Trigger.newMap, Trigger.oldMap);
            }
        }    
    }
    UserHelper.isTriggerRun = true;
}