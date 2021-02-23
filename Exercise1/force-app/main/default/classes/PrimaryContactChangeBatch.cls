public class PrimaryContactChangeBatch implements Database.Batchable<SObject>, Database.Stateful{
	public Contact PrimaryContact;
	//Get the primary contact and set to the state object
	public PrimaryContactChangeBatch(Id accountId){
		List<Contact> primaryContacts = [select Id, Phone, AccountId
		                                 from Contact
		                                 where AccountId = :accountId and Is_Primary_Contact__c = true
		                                 limit 1];
		if (primaryContacts != null && primaryContacts.size() > 0){
			this.PrimaryContact = primaryContacts[0];
		}
	}

	//Get all the contacts of the company except primary contact
	public Database.QueryLocator start(Database.BatchableContext bc){
		return Database.getQueryLocator('SELECT ID FROM Contact ' + 
										'Where AccountId = \'' + PrimaryContact.AccountId + '\' and Id != \'' + PrimaryContact.Id + '\'');
	}

	public void execute(Database.BatchableContext bc, List<Contact> scope){
		for (Contact contact : scope){
			contact.Primary_Contact_Phone__c = PrimaryContact.Phone;
		}
		update scope;
	}

	public void finish(Database.BatchableContext bc){
		// execute any post-processing operations
	}
}