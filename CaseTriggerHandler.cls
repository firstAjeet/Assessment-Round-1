public class CaseTriggerHandler {
    
    public static Boolean checkCaseAdminPermissionSet(){
        String getCurrentUserId = UserInfo.getUserId();
        PermissionSet caseAdminPerissionId = [SELECT Id FROM PermissionSet WHERE Name =:'Case_Admin' LIMIT 1];
        List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>([SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: getCurrentUserId AND PermissionSetId =: caseAdminPerissionId.Id]);
        
        if(permissionSetAssignmentList.size() > 0){
            return true;
        }
        
        return false;
    }
    
    public static void createNonconformanceRecord(List<Case> caseList){
        List<SQX_Nonconformance__c> nonconformanceList = new List<SQX_Nonconformance__c>();    
        
        if(CaseTriggerHandler.checkCaseAdminPermissionSet()){
            for(Case caseRecord : caseList){
                if(caseRecord.Type == 'Problem'){
                    SQX_Nonconformance__c nonconformanceRecord = new SQX_Nonconformance__c();
                    nonconformanceRecord.Description__c = caseRecord.Description;
                    nonconformanceRecord.Priority__c = caseRecord.Priority;
                    nonconformanceRecord.Title__c = caseRecord.Subject;
                    nonconformanceRecord.QMS_Reference_Number__c = caseRecord.CaseNumber;
                    nonconformanceRecord.SQX_NC_Reference__c = caseRecord.Id;
                    nonconformanceList.add(nonconformanceRecord);
                }
            }
            
            if(!nonconformanceList.isEmpty()){
                Database.insert(nonconformanceList,false);
            }
        }
    }
    
    public static void createNonconformanceRecordWhenCaseUpdate(List<Case> caseList, Map<Id,Case> caseMap){
        List<SQX_Nonconformance__c> nonconformanceList = new List<SQX_Nonconformance__c>();
        Map<Id, List<SQX_Nonconformance__c>> caseIdWithNonconformancMap = new Map<Id, List<SQX_Nonconformance__c>>();
        
        if(CaseTriggerHandler.checkCaseAdminPermissionSet()){
            for(SQX_Nonconformance__c nonconformanceRecord : [SELECT Id, Description__c, Priority__c, Title__c, QMS_Reference_Number__c, SQX_NC_Reference__c FROM SQX_Nonconformance__c WHERE SQX_NC_Reference__c IN : caseList]){
                if(!caseIdWithNonconformancMap.containsKey(nonconformanceRecord.SQX_NC_Reference__c)){
                    caseIdWithNonconformancMap.put(nonconformanceRecord.SQX_NC_Reference__c, new List<SQX_Nonconformance__c>());
                }
                caseIdWithNonconformancMap.get(nonconformanceRecord.SQX_NC_Reference__c).add(nonconformanceRecord);
            }
            
            for(Case caseRecord : caseList){
                if(caseRecord.Type == 'Problem'){
                    if(caseIdWithNonconformancMap.get(caseRecord.id) == null){
                        SQX_Nonconformance__c nonconformanceRecord = new SQX_Nonconformance__c();
                        nonconformanceRecord.Description__c = caseMap.get(caseRecord.Id).Description;
                        nonconformanceRecord.Priority__c = caseMap.get(caseRecord.Id).Priority;
                        nonconformanceRecord.Title__c = caseMap.get(caseRecord.Id).Subject;
                        nonconformanceRecord.QMS_Reference_Number__c = caseMap.get(caseRecord.Id).CaseNumber;
                        nonconformanceRecord.SQX_NC_Reference__c = caseMap.get(caseRecord.Id).Id;
                        nonconformanceList.add(nonconformanceRecord);
                    }
                    else{
                        caseMap.get(caseRecord.Id).addError('Here is already Nonconformance record related to this case please change the Type picklist value expect to "Problem" to update the case.');
                    }
                }
            }
            
            if(!nonconformanceList.isEmpty()){
                Database.insert(nonconformanceList);
            }
        }
    }
}