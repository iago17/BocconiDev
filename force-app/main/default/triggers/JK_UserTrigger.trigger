trigger JK_UserTrigger on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    JK_TriggerDispatcher.Run(new JK_UserTriggerHandler());
}