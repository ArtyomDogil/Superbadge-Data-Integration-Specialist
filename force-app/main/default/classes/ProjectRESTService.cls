@RestResource(urlMapping='/project/*')
global class ProjectRESTService {

    @HttpPost
    global static String postProjectData(
        String projectRef,
        String projectName,
        String opportunityId,
        Date startDate,
        Date endDate,
        Double amount,
        String status){

            Savepoint sp = Database.setSavepoint();

            try{
                Project__c proj = new Project__c();
                proj.ProjectRef__c = projectRef;
                proj.Name = projectName;
                proj.Opportunity__c = opportunityId;
                proj.Start_Date__c = startDate;
                proj.End_Date__c = endDate;
                proj.Billable_Amount__c = amount;
                proj.Status__c = status;
                upsert proj;

                Opportunity opp = new Opportunity();
                opp.Id = opportunityId;
                opp.DeliveryInstallationStatus__c = 'In progress';
                update opp;

                return 'OK';

            }catch(Exception e){
                Database.rollback(sp);
                return e.getMessage();
            }
        }
}