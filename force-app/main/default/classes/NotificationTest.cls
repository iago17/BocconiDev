
@IsTest
public with sharing class NotificationTest 
{
    @IsTest
    static void NotificationTest() 
    {
        JK_Exception ex = new JK_Exception('Notification Test Class');
        Test.startTest();
            Notification ntf = new Notification();
            ntf.transactionType = 'NotificationTest';
            ntf.setException(ex);
            ntf.send();
        Test.stopTest();        
    }
}