import { LightningElement, wire, track, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import retrieveCurrentStatus from '@salesforce/apex/JK_PicklistPathController.retrieveCurrentStatus';
import retrievePicklist from '@salesforce/apex/JK_PicklistPathController.retrievePicklist';
import updatePicklist from '@salesforce/apex/JK_PicklistPathController.updatePicklist';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class JK_PicklistPath extends LightningElement 
{
    @api recordId
    @api objectApiName;

    @api field1;
    @api field2;
    @api field3;
    @api field4;
    
    @track currentStep;
    @track fields

    @track listApiNameFields = [];
    @track stepPath = [];
    @track progressIndicators = [];
    //@track mapCurrentStatus = [];

    //mapCurrentStatus = { 'TriennialStatus__c': '1', 'BiennialStatus__c': '2'};

    picklistValues
    //currentvalue = 'Prospect'

    connectedCallback() 
    {
        this.init();
    }

    // Inizializza l'array di progress indicator
    signRow = [];
    mapStatusValue = new Map();
    @track nameField
    //mapValueIndex = new Map();
    init()
    {
        console.log('init Method');
        console.log('objectApiName:', this.objectApiName);
        console.log('fieldApiName:', this.field1);
        console.log('recordId:', this.recordId);
        
        this.field1 ? this.listApiNameFields.push(this.field1) : null;
        this.field2 ? this.listApiNameFields.push(this.field2) : null;
        this.field3 ? this.listApiNameFields.push(this.field3) : null;
        this.field4 ? this.listApiNameFields.push(this.field4) : null;

        //Recupero i valori attuali degli status.
        let actualValueMap = new Map();
        retrieveCurrentStatus({recordId : this.recordId, fieldList : this.listApiNameFields})
        .then(responseStatus => 
        {
            console.log(responseStatus);
            console.log('response:', responseStatus);
            for(let i = 0; i < responseStatus.Contact.length; i++) 
            {
                const contact = responseStatus.Contact[i];
                for(let key in contact) 
                    actualValueMap.set(key, contact[key]);
            }
        })
        .catch(error => {
            console.error(error);
        });
        console.log('actualValueMap:', actualValueMap);

        retrievePicklist({recordId : this.recordId, fieldList: this.listApiNameFields})
        .then(response => 
        {
            console.log('response:', response);
            
            this.mapStatusValue.set('TriennialStatus__c', 'Status Triennio');
            this.mapStatusValue.set('BiennialStatus__c', 'Status Biennio');
            this.mapStatusValue.set('Status__c', 'Status Corso Open SDA');
            this.mapStatusValue.set('MasterSDAStatus__c', 'Status Master SDA');
            this.mapStatusValue.set('GenderIdentity', 'Gender Identity');
            console.log('mapStatusValue:', this.mapStatusValue);

            for (let fieldName in response) 
            {
                console.log('fieldName', fieldName);
                let mapValueIndex = new Map();
                //let this.progressIndicators = [];
                if (response.hasOwnProperty(fieldName)) 
                {
                    let fieldValues = response[fieldName];
                    console.log('fieldValues', fieldValues);
                    let stepPath = [];
                    for (let i = 0; i < fieldValues.length; i++) 
                    {
                        stepPath.push({
                            label: fieldValues[i],
                            value: (i+1).toString()
                        });
                        mapValueIndex.set(fieldValues[i], i+1);
                    }
                    
                    console.log('get actual:', actualValueMap.get(fieldName));
                    console.log('index:', mapValueIndex.get(actualValueMap.get(fieldName)));
                    
                    this.nameField = fieldName;
                    console.log('this.nameField:', this.nameField);

                    this.progressIndicators.push({
                        key: this.nameField,
                        currentValue: (mapValueIndex.get(actualValueMap.get(this.nameField)).toString()), //(mapValueIndex.has(actualValueMap.get(fieldName)) ? mapValueIndex.get(actualValueMap.get(fieldName)) : "3"), // (actualValueMap.has(fieldName) ? actualValueMap.get(fieldName) : "1"),
                        steps: stepPath,
                        label : this.mapStatusValue.get(this.nameField)
                    });
                }
            }
        })
        .catch(error => {
            console.error(error);
        });
    }

    /*retrievePicklist(recordId, fieldList)
    {
        
    }*/

    pathHandler(event) 
    {
        let fieldName = event.target.dataset.fieldname;
        console.log('fieldName: ', fieldName);
        let labelPath = event.target.label;
        console.log('labelPath: ', labelPath);

        updatePicklist({labelPath : labelPath, recordId : this.recordId, fieldName : fieldName})
        .then(() => {
            // Mostra un toast quando il campo viene aggiornato con successo
            const toastEvent = new ShowToastEvent({
                title: 'Aggiornamento avvenuto',
                message: 'Il campo è stato aggiornato correttamente.',
                variant: 'success'
            });
            this.dispatchEvent(toastEvent);
        })
        .catch(error => {
            console.error(error);
        });
        
      }
      
}