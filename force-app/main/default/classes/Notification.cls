public class Notification 
{
	// Properties
	public string message = '';
	public string description = '';
	public string transactionType = '';

	// Constructors
	public Notification() {}

	// Methods
	public void send() 
    {
		List<String> ccAddress = new List<String>();
		//Settings__c.getOrgDefaults().PartnerEmail__c -> is Address
		sendEmail(
            '----------', new String[] {Settings__c.getOrgDefaults().PartnerEmail__c}, 
            description, message, transactionType, ccAddress
        );
	}

	@future
	public static void sendEmail(String displayName, List<String> addresses, String description, String message, String transactionType, List<String> CCaddresses) 
    {
        Messaging.SingleEmailMessage sem = new Messaging.SingleEmailMessage();
        sem.setSenderDisplayName(displayName);
        sem.setToAddresses(addresses);

        if (CCaddresses.size() > 0)
            sem.setCcAddresses(CCaddresses);

        message = (message.length() < 90)? message : message.substring(0, 90);
        sem.setSubject('insert subject:' + transactionType +' - '+ message);
        sem.setPlainTextBody(description != null ? description : message);
        if (!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { sem });
    }

	public void setException(Exception ex) 
    {
    	this.message = ex.getMessage().split('\n')[0];
    	this.description = ex.getMessage() + '\n' + ex.getTypename() + '\nStacktrace: \n' + ex.getStackTraceString();
    	system.debug('#exception: '  + ex);
    }
}