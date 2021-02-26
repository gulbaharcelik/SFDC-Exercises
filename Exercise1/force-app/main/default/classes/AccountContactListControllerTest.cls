@isTest
public class AccountContactListControllerTest{
	@IsTest
	static void getContacts(){
		AccountContactListController extension = makeData();
		Test.startTest();
		List<Contact> contacts = extension.getContacts();

		extension.Next();
		List<Contact> contacts1 = extension.getContacts();

		extension.End();
		extension.getDisableNext(); // action will automatically disable next when user clicks on beginning.
		List<Contact> contacts2 = extension.getContacts();

		Test.stopTest();

		System.assertEquals(extension.getTotalPages(), 3);
		System.assertEquals(extension.getTotalSize(), 50);

		//after next
		System.assertEquals(extension.offset, 40);

		//after end
		System.assertEquals(extension.getPageNumber(), 3);
	}

	@isTest
	static void searchContacts(){
		AccountContactListController extension = makeData();
		extension.searchText = 'Elda';
		Test.startTest();
		Pagereference result = extension.doSearch();
		List<Contact> contacts = extension.getContacts();

		Test.stopTest();

		System.assertEquals(result, null);
		System.assertEquals(contacts.size(), 5);
		System.assertEquals(extension.getTotalSize(), 5);
		System.assertEquals(extension.getTotalPages(), 1);
		System.assertEquals(extension.offset, 0);
	}

	@isTest
	static void testOffset(){
		AccountContactListController extension = makeData();
		Test.startTest();
		extension.listSize = 10;
		List<Contact> contacts = extension.getContacts();

		extension.offset = 40;
		List<Contact> contacts1 = extension.getContacts();

		extension.Previous();
		List<Contact> contacts2 = extension.getContacts();
		Integer offset = extension.offset;

		extension.Beginning();
		extension.getDisablePrevious(); // action will automatically disable previus when user clicks on beginning.
		List<Contact> contacts3 = extension.getContacts();

		Test.stopTest();
		System.assertEquals(extension.getTotalPages(), 5);
		System.assertEquals(contacts.size(), 10);

		//after previous method
		System.assertEquals(offset, 30);
		//after beginning method
		System.assertEquals(extension.offset, 0);
	}

	@isTest
	static void setPrimary(){
		AccountContactListController extension = makeData();
		Test.startTest();
		String contactId = Apexpages.currentpage().getParameters().get('contactId');
		extension.doContactUpdate();
		String accountId = Apexpages.currentpage().getParameters().get('recordId');

		List<Contact> primaryContacts = [select Id
		                                 from Contact
		                                 where Is_Primary_Contact__c = true and AccountId = :accountId];

		System.assertEquals(primaryContacts.size(), 1);
		Contact temp = primaryContacts[0];
		System.assertEquals(temp.Id, contactId);
		Test.stopTest();
	}

	static AccountContactListController makeData(){
		List<Account> accounts = TestDataFactory.createAccounts(1, true);
		Account myaccount = accounts[0];
		List<Contact> contactlist = new List<Contact>();
		for (Integer i = 0; i < 5; i++){
			Contact contact = new Contact(LastName = 'Last Name ' + i, AccountId = myaccount.Id);
			if (i < 5){
				Contact.FirstName = 'Elda';
			}
			contactlist.add(contact);
		}
		contactlist[1].Is_Primary_Contact__c = true;
		List<Contact> factoryContacts = TestDataFactory.createContacts(45, accounts, false, false);
		contactlist.addAll(factoryContacts);
		insert contactlist;

		PageReference pageRef = Page.AccountPrimaryContactPage;
		pageRef.getparameters().put('recordId', myaccount.id);
		pageRef.getparameters().put('contactId', contactlist[0].Id);
		Test.setCurrentPage(pageRef);
		Apexpages.StandardController sc = new Apexpages.StandardController(myaccount);
		return new AccountContactListController(sc);
	}
}