public with sharing class JK_PicklistPathController 
{
    @AuraEnabled
    public static Map<String, List<SObject>> retrieveCurrentStatus(Id recordId, List<String> fieldList)
    {
        Map<String, List<SObject>> mapCurrentStatus = new Map<String, List<SObject>>();
        try 
        {
            String sObjectType = recordId.getSObjectType().getDescribe().getName();
            String fieldQuery;
            for(String field: fieldList)
            {
                if( fieldQuery == null)
                    fieldQuery = field;
                else
                    fieldQuery += ', ' + field;
            }
            String queryObject = 'Select '+ fieldQuery + ' from ' + sObjectType + ' where Id = \'' + recordId + '\''; 
            System.debug('query: ' + queryObject);
            List<SObject> listObject = Database.query(queryObject);
            mapCurrentStatus.put(sObjectType, listObject);
    
            return mapCurrentStatus;
        }
         catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, List<String>> retrievePicklist(Id recordId, List<String> fieldList)
    {
        try 
        {
            System.debug('fieldList: ' + fieldList);
            String sObjectType = recordId.getSObjectType().getDescribe().getName();
            Map<String, List<String>> picklistMap = new Map<String, List<String>>();
            for(String field: fieldList)
            {
                // Ottieni il campo picklist utilizzando il nome del campo
                Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(sObjectType).getDescribe().fields.getMap().get(field).getDescribe();
                
                // Ottieni i valori possibili della picklist
                List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
                List<String> picklistFieldList = new List<String>();
                // Aggiunto i valori possibili della picklist in una lista per il path
                for(Schema.PicklistEntry picklistValue : picklistValues)
                {
                    System.debug('pick: ' + picklistValue);
                    System.debug('Picklist Value: ' + picklistValue.getLabel());
                    picklistFieldList.add(picklistValue.getLabel());
                }   
                picklistMap.put(field, picklistFieldList);
                System.debug('picklistMap: ' + picklistMap);
            }
            return picklistMap;
        } 
        catch (Exception e) 
        {
            throw new JK_Exception(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updatePicklist(String labelPath, Id recordId, String fieldName)
    {
        try 
        {
            String sObjectType = recordId.getSObjectType().getDescribe().getName();
            SObject obj = (SObject) Type.forName(sObjectType).newInstance();
            obj.put('Id', recordId);
            obj.put(fieldName, labelPath);
            
            Database.SaveResult result = Database.update(obj);
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}