public without sharing class JK_UserTriggerUtil 
{    
    public static final String Permission_Set_Assignment = 'No permission to update/insert Permision Sets Group. Please contact your administration.';
    //Method to add permission Set group to a user
    public static Map<String, String> addPermissionSetGroup(Map<Id, User> newItems) 
    {
        Map<String, String> results = new Map<String,String>();
        Savepoint sp = Database.SetSavepoint();
        try 
        {
            if (!Schema.SobjectType.user.isAccessible()     || !Schema.sObjectType.user.fields.profileid.isAccessible() ||
                !Schema.SobjectType.profile.isAccessible()  || !Schema.sObjectType.profile.fields.name.isAccessible()   ||
                !Schema.SobjectType.PermissionSetGroup.isAccessible()
            ) 
            {
                throw new JK_Exception(Permission_Set_Assignment);
            }
            Set <String> profilesName = new Set <String>();

            Map<String, String> PermissionSetGroupMap = new Map <String, String>();
            List<PermissionSetAssignment> allPSGAssignment = new List <PermissionSetAssignment> ();
            List<String> userNotMap = new List <String>();
            List<String> PermissionSetGroupFailed = new List <String>();  

            Set<Id> usersID = new Set<Id>();
            for (User usr :newItems.values())
                usersID.add(usr.id);
       
            for (Profile pr : [SELECT name FROM Profile LIMIT 50000] ) 
            {
                profilesName.add(pr.name);
                profilesName.add(pr.name.deleteWhitespace());
            }

            for (PermissionSetGroup psg : [SELECT id, DeveloperName FROM PermissionSetGroup WHERE DeveloperName IN: profilesName]) 
            {
        
                if (PermissionSetGroupMap.containsKey(psg.DeveloperName.toLowercase()) || PermissionSetGroupMap.containsKey(psg.DeveloperName.deleteWhitespace().toLowercase())) {
                    PermissionSetGroupFailed.add(psg.id);
                } else {
                    PermissionSetGroupMap.put(psg.DeveloperName.toLowercase(), psg.id); 
                }     
            }

            for (user usr : [SELECT id, profile.name FROM user WHERE id in :usersID])
            {          
                if (PermissionSetGroupMap.containsKey(usr.profile.name.toLowercase()))
                {
                    PermissionSetAssignment assignment = new PermissionSetAssignment(
                        PermissionSetGroupId = PermissionSetGroupMap.get(usr.profile.name.toLowercase()),
                        AssigneeId = usr.id
                    );
                    allPSGAssignment.add(assignment);
                    results.put(usr.id, 'success');
                } 
                else if (PermissionSetGroupMap.containsKey(usr.profile.name.deleteWhitespace().toLowercase())) 
                {
                    PermissionSetAssignment assignment = new PermissionSetAssignment(
                        PermissionSetGroupId = PermissionSetGroupMap.get(usr.profile.name.deleteWhitespace().toLowercase()),
                        AssigneeId = usr.id
                    );
                    allPSGAssignment.add(assignment);
                    results.put(usr.id, 'success');
                } 
                else 
                {
                    userNotMap.add(usr.id);
                    results.put(usr.id, 'failed');
                }
            }

            if (userNotMap.size() > 0)
                System.debug('these users are not Mapped : ' + userNotMap);

            if (PermissionSetGroupFailed.size() >0)
                System.debug('these Permission Set Group are not Mapped : '+PermissionSetGroupFailed);
        
            if (allPSGAssignment.size()>0) 
            {
                insert allPSGAssignment;            
                results.put('Add Permission Set group success', 'true');
            } 
            else throw new JK_Exception('no assignments were found');

            return results;
        } 
        catch (Exception ex) 
        {
            Database.rollback( sp );
            System.debug ('Error message: '+ex.getMessage()+' at line: '+ex.getLineNumber()); 
            String errormessage = 'Error message: '+ex.getMessage()+' at line: '+ex.getLineNumber();
            results.put('Add Permission Set group success', 'false');
            results.put('ErrorMessage', errormessage);

            Notification ntf = new Notification();
            ntf.transactionType = 'UserTriggerUtils.addPermissionSetGroup';
            ntf.SetException(ex);
            ntf.send();

            return results;
        }
    }

    //Method to update profile info
    public static Map<String, String> UpdateProfile(Map<Id, user> newItems, Map<Id, user> oldItems) 
    {        
        Map <String,String> results = new Map <String,String>();
        Savepoint sp = Database.SetSavepoint();        
        try 
        {
            Map<Id, user> userInScope = new Map <Id, user>();
            Set <id> userID = new Set <id>();
            Set <id> profileID = new Set <id>();
            Set <String> profilesName = new Set <String>();
            
            for (user usr : newItems.values()) 
            {
                user oldUser = oldItems.get(usr.id);
                if (olduser.profileid != usr.profileid) 
                {
                    userInScope.put(usr.id,usr);
                    userID.add(usr.id);
                    profileID.add(usr.profileID);
                    profileID.add(olduser.profileid);
                }
            }

            if(userInScope.size() == 0) 
            {                
                results.put('Update Permission Set group success', 'no action required');
                return results;
            } 
            else
            {    
                if (!Schema.SobjectType.user.isAccessible()     || !Schema.sObjectType.user.fields.profileid.isAccessible()  ||
                    !Schema.SobjectType.profile.isAccessible()  || !Schema.sObjectType.profile.fields.name.isAccessible() ||
                    !Schema.SobjectType.PermissionSetGroup.isAccessible()
                ) 
                {
                    throw new JK_Exception(Permission_Set_Assignment);
                }

                for(profile pr : [SELECT name FROM Profile WHERE id in :profileID] ) 
                {
                    profilesName.add(pr.name);
                    profilesName.add(pr.name.deleteWhitespace());            
                }
                List <PermissionSetAssignment> deleteProfileAssignment= [SELECT id, AssigneeId , PermissionSetGroup.DeveloperName 
                                                                        FROM PermissionSetAssignment
                                                                        WHERE AssigneeId in :userID and PermissionSetGroup.DeveloperName in :profilesName];
               
                Map <String,String> addAssignment = addPermissionSetGroup(userInScope);
                String firstResult = addAssignment.get('Add Permission Set group success');
                if (firstResult == 'true') 
                {
                    System.debug('----ABOUT TO DELETE----');
                    delete deleteProfileAssignment;
                    results.put('Update Permission Set group success', 'true');
                }
            }                   
            return results;
        } 
        catch (Exception ex) 
        {
            Database.rollback( sp );
            System.debug ('Error message: '+ex.getMessage()+' at line: '+ex.getLineNumber()); 
            String errormessage = 'Error message: '+ex.getMessage()+' at line: '+ex.getLineNumber();
            results.put('Update Permission Set group success', 'false');
            results.put('ErrorMessage', errormessage);

            Notification ntf = new Notification();
            ntf.transactionType = 'UserTriggerUtils.UpdateProfile';
            ntf.SetException(ex);
            ntf.send();

            return results;
        }
    } 
}