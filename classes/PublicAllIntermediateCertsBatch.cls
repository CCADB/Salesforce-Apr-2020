// This is the batch job which iterates over all the intermediate cert records
// and populates the  parent root cert id on each intermediate cert
// after the process is complete or in case of any exceptions it sends out an email 
// to the CA manager which is specified on the user record. 


global class PublicAllIntermediateCertsBatch implements Database.Batchable<sObject> , Database.Stateful
{
    Boolean hasErrors = false;
    global String errorStr='';
    global Integer totalNumberOfRecords =0  ;
    global Integer numberOfRecordsProcessed= 0;
    
    // this method fetches the records for which the execute method would be executed. 
    // we fetch all the intermediate cert records here 
    global Database.QueryLocator start(Database.BatchableContext BC){

    String recordTypeName = 'Intermediate Certificate';
    
       // query to get intermediate certs
       String queryStr = 'select Microsoft_CA_Owner_Status__c,Mozilla_CA_Owner_Status__c,Root_Cert_Id__c,Root_Cert_Id__r.Parentid,Root_Cert_Id__r.Parent.Status__c, Root_Cert_Id__r.Parent.Microsoft_Status__c,Mozilla_Root_Status__c,Microsoft_Root_Status__c,CA_Owner_ID__c, parentid From Account where record_type_name__c = :RecordTypeName  order by name  ';                    
       totalNumberOfRecords =   [select count() From Account where record_type_name__c = :RecordTypeName  ];      
       return Database.getQueryLocator(queryStr);
    }
     
    // this method is executed for each batch of records returned by the start() method.
    // we delegate the batch to the helper class which takes care of the logic to 
    // to find the parent root cert for each intermediate cert.
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
         try {
         numberOfRecordsProcessed  = numberOfRecordsProcessed  + PublicAllIntermediateCertsBatchHelper.processInterCerts(scope);
        } catch (Exception ex) {
          errorStr=''; errorStr += ex.getTypeName() + '\n'; errorStr += ex.getMessage() + '\n'; errorStr += ex.getCause() + '\n';
           errorStr += ex.getLineNumber() + '\n';   errorStr += ex.getStackTraceString() + '\n';
           hasErrors = true;
        }
        
      
    }   
    
    // implementation of the finish method. As of now we do not do 
    // any processing once the batch is finished executing
    global void finish(Database.BatchableContext BC)  { 
    
    
    /****** 
    
    String msgBodyStr = '';
    
    if(hasErrors){
     msgBodyStr = 'There was an error during the batch run. Please find below the error details: ' +  errorStr;
    }
    
    else {
      msgBodyStr = '\n Total number of intermediate certs processed by this batch : ' + totalNumberOfrecords + 
                   '\n\n Total number of intermediate certs records updated with root information : ' + numberOfRecordsProcessed;
      //msgBodyStr = '\n PublicAllIntermediateCerts batch job has completed successfully.';
    }
    
    
       Id userId = UserInfo.getUserId();
       List<String> toAddresses = new List<String>();
       List<User> userSoLst = [select email from user where CA_Program_Manager__c = true];
       if(userSoLst!=null && userSoLst.size() > 0 )   {
         toAddresses.add(userSoLst[0].email);
       }
    
       if(toAddresses.size() > 0 && numberOfRecordsProcessed > 0) // do not send email when zero records processed
       {
        Messaging.SingleEmailMessage 
        mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(toAddresses);
        // mail.setCCAddresses( new String[]{'email@company.com'});
        mail.setSenderDisplayName('PublicIntermediateCerts Batch Job Status');

        String subjectStr = 'completed successfully.';
        if(hasErrors)
        {
          subjectStr = ' failed with errors.';
        }
        
        mail.setSubject('PublicAllIntermediateCertBatch has ' + subjectStr);

        mail.setPlainTextBody(msgBodyStr);

        // Add your attachment to the email.

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       }

     ******/

    }




    
   
    

   
}