@isTest
public class CaseTriggerHandlerTest {
	
    @testSetup
    public static void createRecord(){
        List<Case> caseList = new List<Case>();
        //This case record is with the nonconformance record.
        Case caseRecord1 = new Case(Origin = 'Priority', Description = 'Test Description -1', Subject = 'Test Subject -1', Type = 'Problem');
        //This case record is for the without the nonconformance record.
        Case caseRecord2 = new Case(Origin = 'Priority', Description = 'Test Description -2', Subject = 'Test Subject -2', Type = 'Other');
        caseList.add(caseRecord1);
        caseList.add(caseRecord2);
        
        Database.Insert(caseList,false);
        
        SQX_Nonconformance__c nonconformanceRecord = new SQX_Nonconformance__c();
        nonconformanceRecord.Description__c = caseRecord1.Description;
        nonconformanceRecord.Priority__c = caseRecord1.Priority;
        nonconformanceRecord.Title__c = caseRecord1.Subject;
        nonconformanceRecord.QMS_Reference_Number__c = caseRecord1.CaseNumber;
        nonconformanceRecord.SQX_NC_Reference__c = caseRecord1.Id;
        
        Database.insert(nonconformanceRecord,false);
    }
    
    @isTest
    public static void createNonconformanceRecordWhenCaseUpdateTest(){
        List<Case> caseList = new List<Case>([SELECT Id, Type FROM Case]);
        for(Case caseRecord : caseList){
            caseRecord.Type = 'Problem';
        }
        
        Database.update(caseList,false);
    }
}