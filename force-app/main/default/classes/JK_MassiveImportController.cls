public with sharing class JK_MassiveImportController 
{
	
	/*@AuraEnabled
	public static Map<Map<String, String>, List<String>> retrieveObjectsPicklist()
	{
		Map<String, String> mapObj = new Map<String, String>();
		Map<Map<String, String>, List<String>> mapObjRecordType = new Map<Map<String, String>, List<String>>();
		Map<Boolean, String> mapBooleanObject = new Map<Boolean, String>();
		try
		{
			for(ObjectMassiveImport__mdt obj: ObjectMassiveImport__mdt.getAll().values())
			{
				mapObj.put(obj.Label, String.valueOf(obj.ApiName__c));
			}
			System.debug('mapObj: ' + mapObj);

			for(String obj: mapObj.keySet())
			{
				//objectList.add(obj.Label);
				Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
				Schema.DescribeSObjectResult objectDescribe = globalDescribe.get(mapObj.get(obj)).getDescribe();
				List<Schema.RecordTypeInfo> recordTypes = objectDescribe.getRecordTypeInfos();
				List<String> rtList = new List<String>();
				for (Schema.RecordTypeInfo rt : recordTypes) 
				{
					rtList.add(String.valueOf(rt.getDeveloperName()));
				}
				Map<String, String> mapTemp = new Map<String, String>();
				mapTemp.put(obj, mapObj.get(obj));
				mapObjRecordType.put(mapTemp, rtList);
			}
			System.debug('mapObjRecordType: ' + mapObjRecordType);
		}
		catch (Exception e) 
		{
			throw new AuraHandledException(e.getMessage());
		}
		return mapObjRecordType;
	}*/

	@AuraEnabled
	public static Map<String, Object> retrieveObjectsPicklist()
	{
		Map<String, Object> mapResponse = new Map<String, Object>();
		List<wrapperObj> recordTypeList = new List<wrapperObj>();
		try
		{
			List<ObjectMassiveImport__mdt> listMeta = ObjectMassiveImport__mdt.getAll().values();
			System.debug('liste meta: ' + listMeta);
			Set<String> objList = new Set<String>();

			for(ObjectMassiveImport__mdt obj: listMeta)
			{
				objList.add(obj.ApiName__c);
			}
			System.debug('objList: ' + objList);
			System.debug('objList: ' + [SELECT Id, DeveloperName, Name, SobjectType FROM RecordType WHERE SobjectType IN: objList]);


			for(RecordType rt: [SELECT Id, DeveloperName, Name, SobjectType FROM RecordType WHERE SobjectType IN: objList])
			{
				wrapperObj wp = new wrapperObj();
				wp.recordTypeId = rt.Id;
				wp.objectName = rt.SobjectType;
				wp.recordTypeName = rt.Name;
				wp.recordTypeDeveloperName = rt.DeveloperName;
				System.debug('wp: ' + wp);
				
				recordTypeList.add(wp);
			}
			System.debug('recordTypeList: ' + recordTypeList);

			mapResponse.put('Success', true);
			mapResponse.put('objectPicklist', listMeta);
			mapResponse.put('recordTypeList', recordTypeList);

			System.debug('map Response: ' + mapResponse);

		}
		catch (Exception e) 
		{
			throw new AuraHandledException(e.getMessage());
		}

		return mapResponse;
	}

	@AuraEnabled
	public static List<String> chooseRecordType(String selectedObject)
	{
		System.debug('selected Obj: ' + selectedObject);
		List<String> rtList = new List<String>();
		try 
		{
			Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
			Schema.DescribeSObjectResult objectDescribe = globalDescribe.get(selectedObject).getDescribe();
			List<Schema.RecordTypeInfo> recordTypes = objectDescribe.getRecordTypeInfos();
			for (Schema.RecordTypeInfo rt : recordTypes) 
				rtlist.add(String.valueOf(rt.getDeveloperName()));
			System.debug('rtList: ' + rtList);
		} 
		catch (Exception e) 
		{
			throw new AuraHandledException(e.getMessage());
		}
		return rtlist;
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

	@AuraEnabled
	public static Map<String, String> createHeader(Map<String, String> newMappedField, Map<String, String> jsonToInsert)
	{
		System.debug('create Header Method');
		try 
		{
			for(String key: newMappedField.keyset())
			{
				jsonToInsert.put(key, newMappedField.get(key));
			}
			System.debug('jsonToInsert: ' + jsonToInsert);
		} 
		catch (Exception e) 
		{
			throw new AuraHandledException(e.getMessage());
		}
		return jsonToInsert;
	}

	@AuraEnabled
	public static void saveRecords(String fullSheet, Map<String, String> jsonToInsert, String obj, String recordTypeId)
	{
		System.debug('saveRecords Method');
		try 
		{
			List<Object> totalSheet = (List<Object>)JSON.deserializeUntyped(fullSheet);
			System.debug('totalSheet: ' + totalSheet);
			List<Object> columns = (List<Object>)totalSheet[0];

			List<Map<String, String>> objList = new List<Map<String, String>>();
			String headerName;
			String rowValue;
			for(integer i=1; i<totalSheet.size(); i++)
			{
				Map<String, String> objMap = new Map<String, String>();
				List<Object> objData = (List<Object>)totalSheet[i];
				for(integer j=0; j<columns.size(); j++)
				{
					headerName = jsonToInsert.get((String)columns[j]);
					rowValue = String.valueOf(objData[j]);
					objMap.put(headerName, rowValue);
				}
				System.debug('Row of Obj: ' + objMap);
				objList.add(objMap);
			}
			System.debug('Row of Obj: ' + objList);
			//if insert
			JK_Helper.insertRecord(obj, objList);
			//else if callout
			//JK_Helper.calloutRecord(obj, objList);
			generateJsonCallout(obj, );
			
		} 
		catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/*@AuraEnabled
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
    }*/

	@AuraEnabled
	public static string generateJsonCallout(String obj)
	{
		try 
		{
			// Creare un nuovo oggetto JSONGenerator
			JSONGenerator jsonGenerator = JSON.createGenerator(true);

			// Iniziare l'oggetto JSON e aggiungere le proprietà desiderate
			jsonGenerator.writeStartObject();
			jsonGenerator.writeStringField('SObject', 'Account');
			jsonGenerator.writeStringField('RecordType', 'Università');
			jsonGenerator.writeFieldName('Records');

			// Iniziare la lista di record e aggiungere il record desiderato
			jsonGenerator.writeStartArray();
			jsonGenerator.writeStartObject();
			jsonGenerator.writeStringField('Name', 'nome');
			jsonGenerator.writeEndObject();
			jsonGenerator.writeEndArray();

			// Concludere l'oggetto JSON
			jsonGenerator.writeEndObject();

			// Convertire il JSONGenerator in una stringa JSON
			String jsonString = jsonGenerator.getAsString();

			// Stampare la stringa JSON nella console
			System.debug(jsonString);
		} 
		catch (Exception e) 
		{
			throw new AuraHandledException(e.getMessage());
		}
	}

	public class wrapperObj
	{
		@AuraEnabled public String recordTypeId {get;set;}
		@AuraEnabled public String objectName {get;set;}
		@AuraEnabled public String recordTypeName {get;set;}
		@AuraEnabled public String recordTypeDeveloperName {get;set;}
	}



}