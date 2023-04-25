trigger CaseTrigger on Case (after insert,before update) {
    
    // When Case is create...
    if(Trigger.isAfter && Trigger.isInsert){
        CaseTriggerHandler.createNonconformanceRecord(Trigger.new);
    }
    
    // When Case is update..
    if(Trigger.isBefore && Trigger.isUpdate){
        CaseTriggerHandler.createNonconformanceRecordWhenCaseUpdate(Trigger.new, Trigger.newMap);
    }
}