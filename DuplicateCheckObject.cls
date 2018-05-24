public with sharing class DuplicateCheckObject {

	public Id recId;
	public String firstName;
	public String lastName;
	public String company;
	public String email;
	public String city;
	public String postCode;
	public String street;
	public String country;


	public DuplicateCheckObject(Opportunity o) {
		this.recId = o.Id;
		this.firstName = o.FirstName__c;
		this.lastName = o.LastName__c;
		this.company = o.Company__c;
		this.email = o.Email__c;
		this.city = o.BillingCity__c;
		this.postCode = o.BillingPostalCode__c;
		this.street = o.BillingStreet__c;
		this.country = o.Country__c;
	}

	public DuplicateCheckObject(Asset a) {
		this.recId = a.Id;
		this.firstName = a.INClientFirstName__c;
		this.lastName = a.INClientLastName__c;
		this.company = NULL;
		this.email = a.INClientEmail__c;
		this.city = a.INClientCity__c;
		this.postCode = a.INClientZIPCode__c;
		this.street = a.INClientStreet__c;
		this.country = a.INClientCountry__c;
	}

	public DuplicateCheckObject getDuplicateCheckObject() {
		return this;
	}
}