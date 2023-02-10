@isTest
private class ProjectCalloutServiceTest {
    @testSetup
    static void testSetupData(){
        ServiceTokens__c token = new ServiceTokens__c();
        token.Name = ProjectCalloutService.PROJECT_SERVICE_TOKEN_NAME;
        token.Token__c = 'TestToken';
        insert token;

        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        List<Opportunity> lstOpp = new List<Opportunity>();
        Opportunity opp1 = new Opportunity();
        opp1.AccountId = acc.Id;
        opp1.Name = 'Test Opp1';
        opp1.Type = 'New Project';
        opp1.CloseDate = Date.today();
        opp1.StageName = 'Prospecting';
        opp1.Amount = 100000;
        lstOpp.add(opp1);

        Opportunity opp2 = new Opportunity();
        opp2.AccountId = acc.Id;
        opp2.Name = 'Test Opp2';
        opp2.Type = 'New Project';
        opp2.CloseDate = Date.today().addMonths(2);
        opp2.StageName = 'Need Analysis';
        opp2.Amount = 300000;
        lstOpp.add(opp2);
        insert lstOpp;
    }

    @isTest
    static void testPMSCalloutFailure(){
        List<Opportunity> opps = [SELECT Id
                                  FROM Opportunity
                                  WHERE Type = 'New Project'];
        for(Opportunity opp : opps){
            opp.StageName = 'Closed Won';
        }

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());
        update opps;
        Test.stopTest();

        opps = [SELECT Id
                FROM Opportunity
                WHERE StageName = 'Resubmit Project'];
        System.assertEquals(1, opps.size());
    }

    @isTest
    static void testPMSCalloutSuccess(){
        List<Opportunity> opps = [SELECT Id
                                  FROM Opportunity
                                  WHERE Type = 'New Project'];
        for(Opportunity opp : opps){
            opp.StageName = 'Closed Won';
        }

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
        update opps;
        Test.stopTest();

        opps = [SELECT Id
                FROM Opportunity
                WHERE StageName = 'Submitted Project'];
        System.assertEquals(1, opps.size());
    }
}