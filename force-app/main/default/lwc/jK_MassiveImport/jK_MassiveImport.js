import { LightningElement, wire, track, api} from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
/*Load the script to the component*/
import { loadScript } from 'lightning/platformResourceLoader';
/*Read the excel uploaded data*/
import excelFileReader from '@salesforce/resourceUrl/ExcelReaderPlugin';
import importObjMdt from "@salesforce/apex/JK_MassiveImportController.retrieveObjectsPicklist";
import generateRecord from "@salesforce/apex/JK_MassiveImportController.generateRecord";
import searchFields from "@salesforce/apex/JK_MassiveImportController.searchFields";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

let XLS = {};

export default class JK_MassiveImport extends LightningElement 
{
	/*Accepted formats for the excel file*/
	strAcceptedFormats = ['.xls', '.xlsx'];
	strUploadFileName; //Store the name of the selected file.
	objExcelToJSON; //Javascript object to store the content of the file
	listObj = [];
	operationsList = [];
	keysList = [];
	openUpload = false;
	showUpload = false;
	openTab = false;
	selectedObject
	selectedOperation
	spinner = false;

	get operations() {
        return [
            { label: 'Insert', value: 'insert' },
            { label: 'Callout', value: 'callout' }
        ];
    }

	connectedCallback() {
		setTimeout(
		  ()=>this.template.querySelector('input')
		  .setAttribute('list', this.template.querySelector('datalist').id));
	  }

	handleChange(event) 
	{
		if(event.target.dataset.id === 'object')
			this.selectedObject = event.detail.value; 
			
		/*if(event.target.dataset.id === 'operation')
        	this.selectedOperation = event.detail.value;*/
	
		//console.log('this.selectedOperation:', this.selectedOperation);
		console.log('this.selectedObject:', this.selectedObject);

		if( /*(this.selectedOperation !== '' && this.selectedOperation !== undefined) && */(this.selectedObject !== '' && this.selectedObject !== undefined))
			this.showUpload = true;
    }

	allowToImport()
	{
		this.openUpload = true;
		//console.log('oper:', this.selectedOperation);
		console.log('obj:', this.selectedObject);
		importObjMdt({}).then(result =>
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
		});
	}

	handlePicklistChange(event) 
	{
		console.log('event.target.value:', event.target.value);
		this.selectedObject = event.target.value;
	}

	connectedCallback() 
	{
		Promise.all([loadScript(this, excelFileReader)])
		.then(() => 
		{
			XLS = XLSX;
		})
		.catch((error) => {

			console.log('An error occurred while processing the file');
		});
	}

	handleUploadFinished(event) 
	{
		const strUploadedFile = event.detail.files;
		console.log('strUploadedFile:', strUploadedFile);
		
		if (strUploadedFile.length && strUploadedFile != '') 
		{
			this.strUploadFileName = strUploadedFile[0].name;
			console.log('this.strUploadFileName:', this.strUploadFileName);
			this.handleProcessExcelFile(strUploadedFile[0]);
		}
	}
	
	headerList = [];
	mappingFields = [];

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
			var tempHeaderList = [];
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

			//roa[0].forEach(function(header){this.headerList.push(header);});

			if(this.headerList.length > 0) 
			{
				//loadObjectFields();
				searchFields({headerList : this.headerList, objectName : this.selectedObject}).then(result =>
				{      
					console.log('result:', result);
					//this.mappingFields = result;
					let obj = {};
					for (let key in result) 
					{
						console.log('key:', key);
						console.log('result[key]:', result[key]);
						obj[key] = result[key];
						console.log('obj:', obj);
						this.mappingFields.push({
                            label: key, 
                            value: result[key]
                        });
						
						//this.mappingFields.push({key: key, value : result[key]});
					}
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

    handleInputChange(event) 
	{
		console.log('event value: ', event.target.value);
        this.searchTerm = event.target.value;
    }

	handleSave()
	{
		console.log('this.template.querySelector:', this.template.querySelector('[data-key]'));
		//const inputValue = this.template.querySelector;
		/*saveMapping({}).then(result =>
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