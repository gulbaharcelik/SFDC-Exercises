public class PrimaryContactChangeBatch implements Database.Batchable<SObject>, Database.Stateful{
	public Contact PrimaryContact;
    public PrimaryContactChangeBatch(Id accountId){
        //Get the primary contact and set to the state object
        List<Contact> primaryContacts = [select Id, Phone, AccountId
                                         from Contact
                                         where AccountId = :accountId and Is_Primary_Contact__c = true
                                         limit 1];
        if (primaryContacts != null && primaryContacts.size() > 0){
            this.PrimaryContact = primaryContacts[0];
        }
    }

	public Database.QueryLocator start(Database.BatchableContext bc){
		//Get all the contacts of the company except primary contact
		try{
			return Database.getQueryLocator('SELECT ID FROM Contact ' + 
											'Where AccountId = \'' + PrimaryContact.AccountId + '\' and Id != \'' + PrimaryContact.Id + '\'');

		} catch (Exception ex){
			new CustomException().Log(ex);
			return null;
		}
	}

	public void execute(Database.BatchableContext bc, List<Contact> scope){
		//Set the primary contact phone to other contacts of account
		try{
			for (Contact contact : scope){
				contact.Primary_Contact_Phone__c = PrimaryContact.Phone;
			}
			update scope;
		} catch (Exception ex){
			new CustomException().Log(ex);
		}
	}

	public void finish(Database.BatchableContext bc){
		// execute any post-processing operations
	}
}