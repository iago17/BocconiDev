	public with sharing class JK_MassiveImportController 
	{
	@AuraEnabled
	public static List<String> retrieveObjectsPicklist()
	{
		List<String> objectList = new List<String>();
		try 
		{
			for(ObjectMassiveImport__mdt obj: ObjectMassiveImport__mdt.getAll().values())
				objectList.add(obj.Label);
		} 
		catch (Exception e) 
		{
			throw new AuraHandledException(e.getMessage());
		}
		return objectList;
	}

	@AuraEnabled
	public static void generateRecord(String objExcelToJSON)
	{
		System.debug('objExcelToJSON: ' + objExcelToJSON);
		try 
		{
			
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Map<String, String> searchFields(List<String> headerList, String objectName)
	{
		Map<String, String> mappingFields = new Map<String, String>();
		try 
		{
			System.debug('headerList: ' + headerList);

			Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
			if (objectType != null) 
			{
				Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
				Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
				List<String> matchingFields = new List<String>();
				for(String header: headerList)
				{
					for (String fieldName : fieldMap.keySet()) 
					{
						if (fieldName.toLowerCase().contains(header.toLowerCase())) 
						{
							System.debug('contains: ' + fieldName.toLowerCase().contains(header.toLowerCase()));
							mappingFields.put(header, fieldName);
						}
					}
					if(!mappingFields.containsKey(header))
						mappingFields.put(header, '');
				}
				System.debug('mappingFields: ' + mappingFields);
			}
			else 
			{
				System.debug('Object not found: ' + objectName);
			}
		} 
		catch (Exception e) 
		{
			throw new AuraHandledException(e.getMessage());
		}
		return mappingFields;
	}
}