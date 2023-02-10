public class ProjectCalloutService {
    public static final String PROJECT_SERVICE_TOKEN_NAME = 'ProjectServiceToken';

    @invocableMethod(label='Pass the Opportunity ID' description='Pass the Opportunity ID, when an existing opportunity\'s type is a New Project and its stage is changed to Closed Won, to make an outbound RESTful call' category='Opportunity')
	public static void postOpportunityToPMS(List<Id> oppIds){
        if(oppIds.size() > 0){
            System.enqueueJob(new QueueablePMSCall(oppIds));
        }
    }

    public class QueueablePMSCall implements System.Queueable, Database.AllowsCallouts{
        List<Id> oppIdsToProcess;
        public QueueablePMSCall(List<Id> oppIds){
            oppIdsToProcess = oppIds;
        }
        public void execute(System.QueueableContext context) {
            collectRequestForCallout(oppIdsToProcess);
        }
    }

    static void collectRequestForCallout(List<Id> oppIds){
        List<Opportunity> oppsToRequest = [SELECT Id,
                                                  Name,
                                                  Account.Name,
                                                  CloseDate,
                                                  Amount
                                           FROM Opportunity
                                           WHERE Id IN :oppIds];
        if(oppsToRequest.size() > 0){
            makeCallout(oppsToRequest[0], ServiceTokens__c.getInstance(PROJECT_SERVICE_TOKEN_NAME).Token__c);
        }
    }

    static void makeCallout(Opportunity opp, String projectServiceToken){
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('token', projectServiceToken);
        request.setEndpoint('callout:ProjectService');
        request.setBody(JSON.serialize(new CalloutInformationWrapper(opp)));
        HttpResponse response = new Http().send(request);

        if(response.getStatusCode() == 201 && response.getStatus() == 'OK'){
            opp.StageName = 'Submitted Project';
        }
        else if(response.getStatusCode() == 500){
            opp.StageName = 'Resubmit Project';
        }

        update opp;
    }

    public class CalloutInformationWrapper{
        string opportunityId;
        string opportunityName;
        string accountName;
        string closeDate;
        Decimal amount;

        public CalloutInformationWrapper(Opportunity opp){
            this.opportunityId = opp.Id;
            this.opportunityName = opp.Name;
            this.accountName = opp.Account.Name;
            this.closeDate = String.valueOf(opp.CloseDate);
            this.amount = opp.Amount;
        }
    }
}