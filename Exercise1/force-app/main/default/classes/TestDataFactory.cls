@isTest
public class TestDataFactory{
	public static List<Account> createAccounts(Integer count){
		List<Account> accountList = new List<Account>();
		for (Integer i = 0; i < count; i++){
			Account tempAcc = new Account(BillingCity = 'Portland', Name = 'Test Factory Acc ' + i);
			accountList.add(tempAcc);
		}
		insert accountList;
		return accountList;
	}

	public static List<Contact> createContacts(Integer count, List<Account> accounts, Boolean createPrimaryContact){
		List<Contact> contacts = new List<Contact>();
		if (accounts == null || accounts.isEmpty()){
			contacts = processContacts(count, '', createPrimaryContact);
		} else{
			for (Account account : accounts){
				List<Contact> contactsByAccount = processContacts(count, account.Id, createPrimaryContact);
				contacts.addAll(contactsByAccount);
			}
		}
		insert contacts;
		return contacts;
	}

	private static List<Contact> processContacts(Integer count, string accountId, Boolean createPrimaryContact){
		List<Contact> contactList = new List<Contact>();
		for (Integer i = 0; i < count; i++){
			Contact temp = new Contact(AccountId = accountId, FirstName = 'TF First ' + i, LastName = 'TF Last ' + i);
			temp.Email = 'testFContact' + i + '@mail.com';
			if (createPrimaryContact && i == 0){
				temp.Is_Primary_Contact__c = true;
			}
			contactList.add(temp);
		}
		return contactList;
	}
}