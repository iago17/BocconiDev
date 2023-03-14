import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class JK_SelectCombobox extends LightningElement 
{
    @api field;
    @api matchingFields
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
		
		this.matchingFieldsList = matchingFields;
        
		console.log('matchingFieldsList:', this.matchingFieldsList);
		console.log('matchingFields:', matchingFields);

        return matchingFields.sort();
    }

    handleInputChange(event) 
	{
		console.log('event value: ', event.target.value);
        this.searchTerm = event.target.value;
    }
}