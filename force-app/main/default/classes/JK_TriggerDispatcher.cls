public with sharing class JK_TriggerDispatcher 
{
    /*
        Call this method from your Trigger, passing in an instance of a Trigger handler which implements JK_TriggerHandler.
        This method will fire the appropriate methods on the handler depending on the Trigger context.
    */
    public static void Run(JK_TriggerHandler handler) 
    {
        // Check to see if the Trigger has been disabled. If it has, return
        if(handler.IsDisabled()) 
            return; 
             
        // Detect the current Trigger context and fire the relevant methods on the Trigger handler:
 
        // Before Trigger logic
        if(Trigger.IsBefore) 
        {
            if(Trigger.IsInsert)
             handler.BeforeInsert(Trigger.new);

            if(Trigger.IsUpdate)
             handler.BeforeUpdate(Trigger.newMap, Trigger.oldMap);

            if(Trigger.IsDelete)
                handler.BeforeDelete(Trigger.oldMap);
        }
         
        // After Trigger logic
        if(Trigger.IsAfter) 
        {
            if(Trigger.IsInsert)
               handler.AfterInsert(Trigger.newMap);
 
            if(Trigger.IsUpdate)
               handler.AfterUpdate(Trigger.newMap, Trigger.oldMap);
 
            if(Trigger.IsDelete)
               handler.AfterDelete(Trigger.oldMap);
 
            if(Trigger.isUndelete)
                handler.AfterUndelete(Trigger.oldMap);
        }
    }
}