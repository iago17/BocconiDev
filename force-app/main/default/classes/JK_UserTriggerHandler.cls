public class JK_UserTriggerHandler implements JK_TriggerHandler
{
    public Boolean isDisabled()  
    {
		Trigger__c dflt = Trigger__c.getOrgDefaults();
		Trigger__c prfl = Trigger__c.getInstance(Userinfo.getProfileId()); 
		Trigger__c user = Trigger__c.getInstance(UserInfo.getUserId());
		return dflt.SkipAllTrigger__c || dflt.SkipUserTrigger__c 
			|| prfl.SkipAllTrigger__c || prfl.SkipUserTrigger__c
			|| user.SkipAllTrigger__c || user.SkipUserTrigger__c;  
    }
      
    public void beforeInsert(List<SObject> newItems) {}
  
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
  
    public void beforeDelete(Map<Id, SObject> oldItems) {}
  
    public void afterInsert(Map<Id, SObject> newItems) 
    {
        Map<Id, User> userNew = (Map<Id,User>) newItems;
        JK_UserTriggerUtil.addPermissionSetGroup(userNew);
    }
  
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
	{
		Map<Id, user> userNew = (Map<Id,user>) newItems;
		Map<Id, user> userOld = (Map<Id,user>) oldItems;
		JK_UserTriggerUtil.UpdateProfile(userNew, userOld);
    }
  
    public void afterDelete(Map<Id, SObject> oldItems) {}
  
    public void afterUndelete(Map<Id, SObject> oldItems) {}
  
}