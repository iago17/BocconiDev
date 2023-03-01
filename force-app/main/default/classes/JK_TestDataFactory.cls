@isTest
public with sharing class JK_TestDataFactory 
{    
    public static User createUser(String suffix, String profileName)
    {
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];

        User user = new User();
        user.Alias = 'usr';
        user.Email = 'user' + suffix + '@testorg.com';shdushudc
        user.EmailEncodingKey = 'UTF-8';
        user.LastName = 'Testing' + suffix;
        user.LanguageLocaleKey = 'en_US';
        user.LocaleSidKey = 'en_US';
        user.ProfileId = profile.Id;
        user.TimeZoneSidKey = 'America/Los_Angeles';
        user.UserName = 'user' + suffix + '@testorg.com';

        Boolean isSandbox = false;

        isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].isSandbox;

        if (isSandbox)
            user.UserName += '.test';

        return user;
    }

    public static Account insertAccount() 
    { 
        Account testAcc = new Account(); 
        testAcc.Name      = 'TestAcc';
        testAcc.Phone    = '+393473227044'; 

        testAcc.BillingStreet = 'Rua Inácio de Oliveira Campos, 699';
        testAcc.BillingCity = 'São Paulo';
        testAcc.BillingPostalCode = '08450450';
        testAcc.BillingState = 'São Paulo';  

        testAcc.ShippingStreet = 'Rua Inácio de Oliveira Campos, 699';
        testAcc.ShippingCity = 'São Paulo';
        testAcc.ShippingPostalCode = '08450450';
        testAcc.ShippingState = 'São Paulo'; 
        
        testAcc.Phone = '+5515351525213';
        testAcc.AnnualRevenue = 5.0; 

        insert testAcc;
        return testAcc; 
    }
 
    public static Contact insertContact()
    {
        Contact cont = new Contact();
        cont.FirstName = 'TestAcc';
        cont.LastName = 'TestAcc';
        cont.Email = 'test22@email.com.test';
        cont.Phone = '1111111111';
        cont.Birthdate = Date.today();

        insert cont;
        return cont;        
    }
    
    public static Lead insertLead()
    {
        Lead lead = new Lead();
        lead.Status = 'New';
        lead.FirstName = 'Test1';
        lead.LastName = 'Test2';
        lead.Phone = '111111111';
        lead.MobilePhone = '111111111';
        lead.Email = 'test@test.com';
        lead.Phone = '11111111';
        lead.Company = 'EngDB';
        //lead.RecordTypeId = Utils.getRecordTypeId('Guest', 'Lead');

        insert lead;
        return lead;
    }
    
    public static Lead createLead()
    {
        Lead lead = new Lead();
        lead.Status = 'New';
        lead.FirstName = 'Test1';
        lead.LastName = 'Test2';
        lead.Phone = '111111111';
        lead.Email = 'test@test.com';
        lead.Company = 'EngDB';
        //lead.RecordTypeId = Utils.getRecordTypeId('Guest', 'Lead');
        return lead;
    }
    
    public static Pricebook2 createStandardPricebook2()
    {
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true );
        return standardPricebook;
    }

    public static Product2 createProduct2(String name)
    {
        Product2 product2 = new Product2(Name = name, isActive = true);
        return product2;
    }

    public static PricebookEntry createProductEntry(Id product2Id, Id pricebook2Id)
    {
        PricebookEntry pricebookEntry = new PricebookEntry(
            Product2Id = product2Id,
            Pricebook2Id = pricebook2Id,
            UnitPrice = 1.0,
            isActive = true
        );
        return pricebookEntry;
    }

    public static OpportunityLineItem createOpportunityLineItem(Id opportunityId, Id product2Id, Id pricebookEntryId)
    {
        OpportunityLineItem oppLineItem = new OpportunityLineItem(
            Product2Id = product2Id,
            PricebookEntryId = pricebookEntryId,
            OpportunityId = opportunityId,
            Quantity = 1.0,
            UnitPrice = 0.0
        );
        return oppLineItem;
    }

    public static Lead createLead(String lastName, String firstName, String email){
        Lead lead = new Lead();
        lead.FirstName = firstName;
        lead.LastName = lastName;
        lead.Email = email;
        lead.Phone = '11111111';
        lead.Company = 'EngDB';
        return lead;
    }
   
    public static Account createAccount(String name)
    {
        return new Account(Name = name);
    }
   
    public static Contact createContact(String lastName, String firstName, String email)
    {
        Contact ctt = new Contact();
        ctt.LastName = lastName;
        ctt.FirstName = firstName;
        ctt.Email = email;
        return ctt;
    }
    
    /*public static OutboundIntegrationSetting__c createOutboundIntegrationSetting(String endpoint, String method, String servicename, Integer timeout, String name, String headerkey, String headervalue){
        OutboundIntegrationSetting__c outboundintegrationsetting = new OutboundIntegrationSetting__c();
        outboundintegrationsetting.Endpoint__c = endpoint;
        outboundintegrationsetting.Method__c = method;
        outboundintegrationsetting.Service_Name__c   = servicename;
        outboundintegrationsetting.Timeout__c = timeout;
        outboundintegrationsetting.Name = name;
        outboundintegrationsetting.Header_Key__c = headerkey;
        outboundintegrationsetting.Header_Value__c = headervalue; 
        return outboundintegrationsetting;
    }*/
    
    public static Case createCase(String status, String subject, String language, String country)
    {
        Case c = new Case(Status = status, Subject = subject);
        return c;
    }
    
    public static Opportunity createOpportunity(String name, String stage)
    {
        Opportunity opp = new Opportunity();
        opp.Name = name;
        opp.StageName = stage;
        return opp;
    }

}