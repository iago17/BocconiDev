import { LightningElement, api, track} from 'lwc';

export default class AutocompleteDatalist extends LightningElement 
{
	jsonToInsert = {};

    @api options;
    @api objectInfo;
	@api mappingLabel;
    value;
	showOptions = false;
    connectedCallback()
    {
		console.log('connected callback method');
        this.init();
    }
	
    init()
    {
		console.log('init method');
		console.log('mappingLabel: ' , this.mappingLabel);
		console.log('options: ' , this.options);
		if(this.options !== '' && this.options !== null)
			this.showOptions = true;
	}
	
    @track selectedValue;
	showDataList = false;
    @track matchingFields
	handleChange2(event) 
	{
		let inputText = event.target.value;
		console.log('inputText:', inputText);
		if(inputText !== '' )
			this.showDataList = true;
			
		this.showOptions = false;
		/*if(inputText === ''){
			this.showDataList = false;
		}*/
		
		/*let regex = new RegExp(inputText,'gi');
		console.log('regex:', regex);
		this.stringList = this.inputList.filter((row) => regex.exec(row));*/

		//console.log('obj info: ', this.objectInfo);
		const objectFields = Object.keys(this.objectInfo.data.fields);
		//console.log('obj fields: ', objectFields);
		this.matchingFields = objectFields.filter(field =>
			field.toLowerCase().startsWith(inputText.toLowerCase())
		);
		console.log('field list: ' + this.matchingFields);
			
		//this.selectedValue = event.target.options.find(opt => opt.value === event.detail.value).label;
		//console.log('selec value:', this.selectedValue);
	}
	@api valueSelected;
	@track listValue = [];

    handleSelection(event) 
	{	
		let div = this.template.querySelector('.slds-truncate');
        console.log('truncate:', div.title);
        console.log('event target:', event.target);

		if(event.target.getAttribute('title') !== '' && event.target.getAttribute('title') !== null)
		{
			console.log('event target:', event.target.getAttribute('title'));
			this.selectedValue = event.target.getAttribute('title');
		}
		else if(event.target.getAttribute('data-recid') !== '' && event.target.getAttribute('data-recid') !== null)
		{
        	console.log('event data recid:', event.target.getAttribute('data-recid'));
			this.selectedValue = event.target.getAttribute('data-recid');
		}

        //this.selectedValue = div.title;//selectedText;
        //his.selectedValue = event.target.getAttribute('title');//selectedText;
        console.log('selected value:', this.selectedValue);
        this.showDataList = false;

		this.jsonToInsert[this.mappingLabel] = this.selectedValue;
		console.log('jsonToInsert:', this.jsonToInsert);

		const fieldTest = event.target.getAttribute('title');
		const selectedEvent = new CustomEvent('selectedvalue', {
			//detail: fieldTest
			detail: this.jsonToInsert
		});
		console.log('selectedEvent:', selectedEvent);
	
		this.dispatchEvent(selectedEvent);

		//util - insert, callout , sarà richiamata dalla controller (avrà le logiche all'interno)
		//controller 3 if: -cust metad

    }
}