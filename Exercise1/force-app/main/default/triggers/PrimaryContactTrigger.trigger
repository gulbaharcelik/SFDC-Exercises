trigger PrimaryContactTrigger on Contact (before insert, before update, after insert, after update){
	if (Trigger.isBefore){
		for (Contact contact : Trigger.New){
			if (contact.Is_Primary_Contact__c){
				List<Contact> primaryContacts = [select Id
				                                 from Contact
				                                 where Id != :contact.Id and Is_Primary_Contact__c = true and AccountId = :contact.AccountId];

				if (primaryContacts != null && primaryContacts.size() > 0){
					Trigger.newMap.get(contact.Id).addError('Cannot set primary contact since account already has one');
				}
			}
		}
	} else{
		for (Contact contact : Trigger.New){
			if (contact.Is_Primary_Contact__c){
				Contact oldContact = Trigger.isUpdate ? Trigger.oldMap.get(contact.Id) : null;
				if (Trigger.isInsert || Trigger.isUpdate && oldContact != null && !oldContact.Is_Primary_Contact__c){
					PrimaryContactChangeBatch batchInstance = new PrimaryContactChangeBatch(contact.AccountId);
					Id batchId = Database.executeBatch(batchInstance);
				}
			}
		}
	}
}