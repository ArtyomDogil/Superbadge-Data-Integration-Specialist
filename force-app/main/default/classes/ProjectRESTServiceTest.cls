@isTest
private class ProjectRESTServiceTest {
    @testSetup
    static void testSetupData(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.Type = 'New Project';
        opp.CloseDate = Date.today();
        opp.StageName = 'Prospecting';
        opp.Amount = 100000;
        insert opp;
    }

    @isTest
    static void testServiceFailure(){
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/project';
        RestContext.request = request;

        Test.startTest();
        String response = ProjectRESTService.postProjectData(
            'Test projectRef',
            'Test projectName',
            'broken id',
            Date.today(),
            Date.today().addDays(1),
            100,
            'Running');
        Test.stopTest();

        System.assertEquals('Invalid id: broken id', response);
    }

    @isTest
    static void testServiceSuccess(){
        Opportunity opp = [SELECT Id
                           FROM Opportunity
                           WHERE Name = 'Test Opp'];
        RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.requestURI = '/services/apexrest/project';
        RestContext.request = request;

        Test.startTest();
        String response = ProjectRESTService.postProjectData(
            'Test projectRef',
            'Test projectName',
            opp.id,
            Date.today(),
            Date.today().addDays(1),
            100,
            'Running');
        Test.stopTest();

        opp = [SELECT DeliveryInstallationStatus__c
               FROM Opportunity
               WHERE Id = :opp.Id];
        System.assertEquals('In progress', opp.DeliveryInstallationStatus__c);
        System.assertEquals('OK', response);
    }
}