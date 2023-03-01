@IsTest
public with sharing class JK_UserTriggerTest 
{
    @IsTest
    static void insertUser()
    {
        User testUser2 = JK_TestDataFactory.createUser('', 'Standard User');

        List<User> aliasListobj = [SELECT alias,username,CommunityNickname FROM User];
        List<String> aliasListstr = new List<String>();
        List<String> usernameList = new List<String>();
        List<String> CommunityNicknames = new List<String>();
        
        for (user usr : aliasListobj) 
        {
            String alias = usr.alias;
            String addUsername = usr.username.toLowerCase();
            String addNickName = usr.CommunityNickname.toLowerCase();
            aliasListstr.add(alias);
            usernameList.add(addUsername);
            CommunityNicknames.add(addNickName);
        }

        testUser2.FirstName = 'test';
        testUser2.LastName = 'JK';
        testUser2.Email =  'test@test.it';
        testUser2.UserRoleId = [SELECT id FROM UserRole LIMIT 1].id;
        testUser2.IsActive = true;

        testUser2.LocaleSidKey='it_IT'; 
        testUser2.TimeZoneSidKey='Europe/Rome';
        testUser2.EmailEncodingKey='ISO-8859-1';
        testUser2.LanguageLocaleKey ='it';

        integer myindex=1;
        do 
        {
            testUser2.alias = testUser2.FirstName.left(myindex)+testUser2.LastName;
            myindex = myindex+1;
        } 
        while (aliasListstr.contains(testUser2.alias)); 

        do 
        {
            if (myindex == 1)
                testUser2.username = testUser2.firstName+'.'+testUser2.lastName+'@test.net';
            else 
                testUser2.username = testUser2.firstName+'.'+testUser2.lastName+String.valueOf(myindex)+'@test.net';
            testUser2.username = testUser2.username.toLowerCase();
            
            myindex = myindex+1;
        } 
        while (usernameList.contains(testUser2.username)); 

        do 
        {
            if (myindex == 1)
                testUser2.CommunityNickname = testUser2.firstName+'.'+testUser2.lastName;
            else 
                testUser2.CommunityNickname = testUser2.firstName+'.'+testUser2.lastName+String.valueOf(myindex);
            testUser2.CommunityNickname = testUser2.CommunityNickname.toLowerCase();
            
            myindex = myindex+1;
            System.debug('my loop index: '+myindex);

        } 
        while (CommunityNicknames.contains(testUser2.CommunityNickname)); 

        Test.startTest();
        insert testUser2;
        Test.stopTest(); 
        User u = [SELECT Name, Id, Email FROM User WHERE Email = 'test@test.it'];
        system.assertNotEquals(u.Id, null, 'User is not inserted');
    }
    
    @IsTest
    static void insertUserNotInScope()
    {
        List<User> aliasListobj = [SELECT alias,username,CommunityNickname FROM User];
        List<String> aliasListstr = new List<String>();
        List<String> usernameList = new List<String>();
        List<String> CommunityNicknames = new List<String>();

        for (user usr : aliasListobj) 
        {
            String alias = usr.alias;
            String addUsername = usr.username.toLowerCase();
            String addNickName = usr.CommunityNickname.toLowerCase();
            aliasListstr.add(alias);
            usernameList.add(addUsername);
            CommunityNicknames.add(addNickName);
        }

        User testUser2 = JK_TestDataFactory.createUser('', 'Standard User');
                    
        testUser2.FirstName = 'test';
        testUser2.LastName = 'jk';
        testUser2.Email =  'test@test.it';
        testUser2.UserRoleId = [SELECT id FROM UserRole LIMIT 1].id;
        testUser2.IsActive = true;

        testUser2.LocaleSidKey='it_IT'; 
        testUser2.TimeZoneSidKey='Europe/Rome';
        testUser2.EmailEncodingKey='ISO-8859-1';
        testUser2.LanguageLocaleKey ='it';

        integer myindex=1;

        do {
            testUser2.alias = testUser2.FirstName.left(myindex)+testUser2.LastName;
            myindex = myindex+1;
        } while (aliasListstr.contains(testUser2.alias)); 

        do 
        {
            if (myindex == 1){
                testUser2.username = testUser2.firstName+'.'+testUser2.lastName+'@test.net';
            } else {
                testUser2.username = testUser2.firstName+'.'+testUser2.lastName+String.valueOf(myindex)+'@test.net';
            }
            testUser2.username = testUser2.username.toLowerCase();
            
            myindex = myindex+1;
        } 
        while (usernameList.contains(testUser2.username)); 

        do 
        {
            if (myindex == 1){
                testUser2.CommunityNickname = testUser2.firstName+'.'+testUser2.lastName;
            } else {
                testUser2.CommunityNickname = testUser2.firstName+'.'+testUser2.lastName+String.valueOf(myindex);
            }
            testUser2.CommunityNickname = testUser2.CommunityNickname.toLowerCase();
            
            myindex = myindex+1;
            System.debug('my loop index: '+myindex);
        } 
        while (CommunityNicknames.contains(testUser2.CommunityNickname)); 

        Test.startTest();
            insert testUser2;
        Test.stopTest();  
        system.assertNotEquals(testUser2.Id, null, 'User is not inserted');
    }
}