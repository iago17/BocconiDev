/* eslint-disable no-undef */
import { LightningElement, wire, track} from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
/*Load the script to the component*/
import { loadScript } from 'lightning/platformResourceLoader';
/*Read the excel uploaded data*/
import excelFileReader from '@salesforce/resourceUrl/ExcelReaderPlugin';
import retrieveObjPicklist from "@salesforce/apex/JK_MassiveImportController.retrieveObjectsPicklist";
import createHeader from "@salesforce/apex/JK_MassiveImportController.createHeader";
import generateRecord from "@salesforce/apex/JK_MassiveImportController.generateRecord";
import searchFields from "@salesforce/apex/JK_MassiveImportController.searchFields";
import saveRecords from "@salesforce/apex/JK_MassiveImportController.saveRecords";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const STRING_LIST = ['Apple','Ball','Cat','Aero','Base'];
let XLS = {};

export default class JK_MassiveImport extends LightningElement 
{
	/*Accepted formats for the excel file*/
	strAcceptedFormats = ['.xls', '.xlsx'];
	strUploadFileName; //Store the name of the selected file.
	objExcelToJSON; //Javascript object to store the content of the file
	listObj = [];
	@track recordTypeList = [];
	keysList = [];
	openUpload = false;
	showUpload = false;
	openTab = false;
	@track selectedObject;
	@track selectedRecordType;
	spinner = false;
	showRT = false;

	get operations() {
		return [
			{ label: 'Insert', value: 'insert' },
			{ label: 'Callout', value: 'callout' }
		];
	}

	connectedCallback() 
	{
		Promise.all([loadScript(this, excelFileReader)])
		.then(() => 
		{
			XLS = XLSX;
		})
		// eslint-disable-next-line no-unused-vars
		.catch((error) => {

			console.log('An error occurred while processing the file');
		});
	}

	@track listRT = [];
	handleChange(event) 
	{
		console.log('event.target.dataset.id: ', event.target.dataset.id);
		console.log('event.detail.value: ', event.detail.value);

		if(event.target.dataset.id === 'object')
		{
			this.selectedObject = event.detail.value; 
			this.showRT = false;
			this.listRT = [];
		}

		if(event.target.dataset.id === 'recordType')
			this.selectedRecordType = event.detail.value;
		console.log('this.selectedRecordType:', this.selectedRecordType);
		console.log('this.selectedObject:', this.selectedObject);
		
		for(var i=0; i<this.recordTypeList.length; i++)
		{
			
			if(this.recordTypeList[i].objectName === this.selectedObject)
			{
				this.listRT = [...this.listRT, {label: this.recordTypeList[i].recordTypeName, value: this.recordTypeList[i].recordTypeId}];
			}
		}
		if (this.listRT.length>1)
		{
			this.showRT = true;
		}

		if( /*(this.selectedOperation !== '' && this.selectedOperation !== undefined) && */(this.selectedObject !== '' && this.selectedObject !== undefined))
			this.showUpload = true;
	}

	allowToImport()
	{
		this.openUpload = true;
		console.log('obj:', this.selectedObject);
		if(this.selectedObject !== null || this.selectedObject !== '')
		{
			this.importObjMdt();
			/*importObjMdt({}).then(result =>
			{      
				console.log('result:', result);
				this.listObj = result.map(valore => 
				{ 
					return { 
						label: valore, 
						value: valore
					};
				});
				
				console.log('listObj: ', this.listObj);
				//console.log('operationsList: ', this.operationsList);
			}).catch(() => 
			{      
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Oggetti non trovati',
						message: 'Error',
						variant: 'error',
					}),
				);  
			});*/
		}
	}

	importObjMdt()
	{
		retrieveObjPicklist({}).then(result =>
		{      

			console.log('result:', result);
			if(result.Success)
			{
				console.log('result.recordTypeList:', result.recordTypeList);
				this.recordTypeList = result.recordTypeList;
				console.log('result.recordTypeList:', this.recordTypeList);
				console.log('result:', result);
				for(var i=0; i<result.objectPicklist.length; i++)
				{
					console.log('apiName: ', result.objectPicklist[i].ApiName__c);
					console.log('label: ', result.objectPicklist[i].Label__c);
					this.listObj = [...this.listObj, {value: result.objectPicklist[i].ApiName__c, label: result.objectPicklist[i].Label__c}];
					
				}
				console.log('listobj: ', this.listObj);
			}
			
			/*Object.keys(result).forEach(key => {
				console.log('key: ', key);
				for (let obj in key) {
					console.log('obj:', obj);
				}

				const subMap = result[key];
				console.log('subMap: ', subMap);
				// Itera attraverso le chiavi della mappa interna
				Object.keys(subMap).forEach(subKey => {
					console.log('subKey: ', subKey);
				});
			});

			for (let objList in result) 
			{
				console.log('objList:', objList);
	
				const keys = Object.keys(objList);

				
				console.log('keys: ', keys);
				this.listObj = this.listObj.concat(keys);
				console.log('keylist:', keyList);

				//console.log('response[key]:', result[key]);
				/*obj[key] = response[key];
				console.log('obj:', obj);
				this.mappingFields.push({
					label: key, 
					value: response[key]
				});
				
				//this.mappingFields.push({key: key, value : result[key]});
			}*/


			/*this.listObj = result.map(valore => 
			{ 
				return { 
					label: valore, 
					value: valore
				};
			});*/


		}).catch(() => 
		{      
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Oggetti non trovati',
					message: 'Error',
					variant: 'error',
				}),
			);  
		});
	}

	handlePicklistChange(event) 
	{
		console.log('event.target.value:', event.target.value);
		this.selectedObject = event.target.value;
	}

	

	@track strUploadedFile
	handleUploadFinished(event) 
	{
		this.strUploadedFile = event.detail.files;
		console.log('strUploadedFile:', this.strUploadedFile);
		
		if (this.strUploadedFile.length && this.strUploadedFile !== '') 
		{
			this.strUploadFileName = this.strUploadedFile[0].name;
			console.log('this.strUploadFileName:', this.strUploadFileName);
			this.handleProcessExcelFile(this.strUploadedFile[0]);
		}
	}
	
	headerList = [];
	mappingFields = [];
	fullSheet = [];
	handleProcessExcelFile(file) 
	{
		this.spinner = !this.spinner;
		let objFileReader = new FileReader();
		objFileReader.onload = (event) => 
		{
			let objFiledata = event.target.result;
			let workbook = XLS.read(objFiledata, {
				type: 'binary'
			});
						
			var result = {};
			var roa;
			workbook.SheetNames.forEach(function(sheetName) 
			{
				roa = XLS.utils.sheet_to_json(workbook.Sheets[sheetName], {header:1});
				console.log('roa:', roa);
				console.log('roa length:', roa.length);
				if(roa.length) result[sheetName] = roa;
				console.log('result:', result);
			});
			this.headerList = roa[0];
			console.log('this.headerList:', this.headerList);
			console.log('this.headerList length:', this.headerList.length);
			console.log('result:', result);
			console.log('roa 0:', roa[0]);
			this.fullSheet = roa;
			//roa[0].forEach(function(header){this.headerList.push(header);});

			if(this.headerList.length > 0) 
			{
				//loadObjectFields();
				searchFields({headerList : this.headerList, objectName : this.selectedObject}).then(response =>
				{      
					console.log('response:', response);
					//this.mappingFields = result;
					let obj = {};
					// eslint-disable-next-line guard-for-in
					for (let key in response) 
					{
						console.log('key:', key);
						console.log('response[key]:', response[key]);
						obj[key] = response[key];
						console.log('obj:', obj);
						this.mappingFields.push({
							label: key, 
							value: response[key]
						});
						
						//this.mappingFields.push({key: key, value : result[key]});
					}
					this.mappingFields.forEach((field) => {
						if(field.value !== null || field.value !== '')
							this.jsonToInsert[field.label] = field.value;

						console.log('field value:', field.value);
						
					});
					console.log('father jsonToInsert:', this.jsonToInsert);

					this.spinner = !this.spinner;
					this.openTab = true;
					this.showUpload = false;
					//this.mappingFields = obj;
					console.log('mappingFields:', this.mappingFields);
					

				}).catch(() => 
				{      
					this.dispatchEvent(
						new ShowToastEvent({
							title: 'Oggetti non trovati',
							message: 'Error',
							variant: 'error',
						}),
					);  
				});
			}
			console.log('openTab:', this.openTab);
			/*console.log('json stringify:', JSON.stringify(result, 2, 2));
			console.log('sheet1:', objFileWorkbook.Sheets);
			console.log('sheet1:', objFileWorkbook.Sheets[sheetName]);
			this.objExcelToJSON = XLS.utils.sheet_to_row_object_array(objFileWorkbook.Sheets[sheetName]);
			console.log('this.objExcelToJSON.length:', this.objExcelToJSON);
			let sheets = [];
			workbook.SheetNames.forEach(function(sheetName) {
				sheets.push({name:sheetName, sheet:XLSX.utils.sheet_to_row_object_array(workbook.Sheets[sheetName])});
			});
			//Verify if the file content is not blank
			*/
			if (this.objExcelToJSON.length === 0) 
			{
				this.strUploadFileName = '';
				this.dispatchEvent(
					new ShowToastEvent(
					{
						title: 'Error',
						message: 'Kindly upload the file with data',
						variant: 'error'
					})
				);
			}

			if (this.objExcelToJSON.length > 0) 
			{
				console.log('length:', this.objExcelToJSON.length);
				//Remove the whitespaces from the javascript object
				Object.keys(this.objExcelToJSON).forEach((key) => 
				{
					console.log('key:', key);
					const replacedKey = key.trim().toUpperCase().replace(/\s\s+/g, '_');
					console.log('replacedKey:', replacedKey);
					if (key !== replacedKey) 
					{
						this.objExcelToJSON[replacedKey] = this.objExcelToJSON[key];
						delete this.objExcelToJSON[key];
					}
				});
				console.log('this.objExcelToJSON:', this.objExcelToJSON);
				this.keysList = Object.keys(this.objExcelToJSON);
				console.log('jsonDataObj:', this.keysList);

				this.generateRecord();

			}
		};

		
			
		objFileReader.onerror = function (error) 
		{
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Error while reading the file',
					message: error.message,
					variant: 'error'
				})
			);
		};
		objFileReader.readAsBinaryString(file);
	}

	generateRecord()
	{
		generateRecord({objExcelToJSON : JSON.stringify(this.objExcelToJSON)}).then(result =>
		{      
			console.log('result:', result);
			
		}).catch(() => 
		{      
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Oggetti non trovati',
					message: 'Error',
					variant: 'error',
				}),
			);  
		});
	}

	closeUpload()
	{
		this.openUpload = false;
		this.selectedObject = '';
		this.selectedOperation = '';
		this.showUpload = false; 
		this.strUploadedFile = '';
		this.strUploadFileName = '';
		this.headerList = [];
		this.mappingFields = [];
		this.fullSheet = [];
		this.listObj = [];
		this.openTab = false;
		this.listRT = [];
		this.showRT = false;
	}


	searchTerm = '';
	objectFields = [];
	@track matchingFieldsList = [];
	
	@wire(getObjectInfo, { objectApiName: '$selectedObject' })
	objectInfo;

	get matchingFields() 
	{
		if (!this.objectInfo.data || !this.searchTerm) {
			return [];
		}
		console.log('objectInfo:', this.objectInfo);
		console.log('this.searchTerm: ', this.searchTerm);
		const objectFields = Object.keys(this.objectInfo.data.fields);
		const matchingFields = objectFields.filter(field =>
			field.toLowerCase().startsWith(this.searchTerm.toLowerCase())
		);
		
		matchingFields.forEach((field) => {
			console.log('field:', field);
			this.matchingFieldsList.push({
				label: field, 
				value: field
			});
		});
		
		//this.matchingFieldsList = matchingFields;
		
		console.log('matchingFieldsList:', this.matchingFieldsList);
		console.log('matchingFields:', matchingFields);

		return matchingFields.sort();
	}

	/*handleInputChange(event) 
	{
		console.log('event value: ', event.target.value);
		this.searchTerm = event.target.value;
		
	}*/


	/*@track selectedValue;
	inputList = STRING_LIST;
	@track stringList = this.inputList;
	showDataList = false;
	handleChange2(event) 
	{
		console.log('event.target.value:', event.target.value);
		let inputText = event.target.value;
		console.log('inputText:', inputText);
		if(inputText !== '' )
			this.showDataList = true;
			
		if(inputText === ''){
			this.selectedValue = '';
			this.showDataList = false;
		}
		
		let regex = new RegExp(inputText,'gi');
		console.log('regex:', regex);
		this.stringList = this.inputList.filter((row) => regex.exec(row));
		const objectFields = Object.keys(this.objectInfo.data.fields);
		const matchingFields = objectFields.filter(field =>
			field.toLowerCase().startsWith(inputText.toLowerCase())
		);
		console.log('field list: ' + matchingFields);
			
		//this.selectedValue = event.target.options.find(opt => opt.value === event.detail.value).label;
		//console.log('selec value:', this.selectedValue);
	

	}
	handleSelection(event) 
	{
		var selectedText = event.target.getAttribute('data-recid');
		console.log('target:', event.target);
		console.log('data recid:', event.target.getAttribute('data-recid'));
		console.log('select text:', selectedText);
		this.selectedValue = selectedText;
	}*/

	@track jsonToInsert = {};
	handleValueSelectedChange(event) 
	{
		console.log('handleSelectedValueChange Method');
		const newMappedField = event.detail;
		console.log('father selected value:', newMappedField);

		createHeader({newMappedField : newMappedField, jsonToInsert : this.jsonToInsert}).then(result =>
		{      
			console.log('result:', result);
			this.jsonToInsert = result;
			console.log('json updated: ', this.jsonToInsert);
		}).catch(() => 
		{      
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Error',
					message: 'Errore nella mappatura dei campi',
					variant: 'error',
				}),
			);  
		});
		console.log('fullSheet:', this.fullSheet);
	}
	
	saveRecords()
	{
		this.spinner = true;
		console.log('saveRecords Method');
		console.log('fullSheet:', this.fullSheet);
		saveRecords({fullSheet : JSON.stringify(this.fullSheet), jsonToInsert : this.jsonToInsert, obj : this.selectedObject, recordTypeId : this.selectedRecordType}).then(result =>
		{      
			console.log('result:', result);
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Success',
					message: 'Lista record inserita con successo.',
					variant: 'success',
				}),
			);  
			this.closeUpload();
			this.spinner = false;
			this.openTab = !this.openTab;
			
		}).catch(() => 
		{      
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Attenzione',
					message: 'Errore nella mappatura dei campi. Controlla i campi scelti.',
					variant: 'error',
				}),
			);  
		});
	}

}