trigger ScreeningTrigger on Screening__c (after insert, after update) {
    if (Trigger.isAfter){
        if (Trigger.isUpdate) {
            ScreeningHelper.afterUpdate(Trigger.newMap, Trigger.oldMap);
        } else if (Trigger.isInsert) {
            ScreeningHelper.afterInsert(Trigger.newMap, Trigger.oldMap);
        }
    }
}