public with sharing class JK_Helper 
{
    @AuraEnabled
    public static void insertRecord(String sObjectType, List<Map<String, String>> objList) 
    {
        try
		{
			List<SObject> listToInsert = new List<SObject>();
			for (Map<String, String> mapTest : objList) 
			{
				SObject record = (Sobject)Type.forName(sObjectType).newInstance();
				for(String header: mapTest.keyset())
				{
					record.put(header, String.valueOf(mapTest.get(header)));
				}
				listToInsert.add(record);
			}
			insert listToInsert;
		}
		catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
    }
}