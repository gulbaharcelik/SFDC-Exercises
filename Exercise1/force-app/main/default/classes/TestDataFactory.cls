@isTest
/*
 * @author Gulbahar Çelik
 * @date Feb 25 2021
 * @name TestDataFactory
 * @description contains test data creation methods
 */
public class TestDataFactory{
	//This class could be more dynamic to create instances and relations of given sObject types in the params. But because of time restriction, I created methods for objects that I need.
	/*
	 * @author Gulbahar Çelik
	 * @date Feb 25 2021
	 * @name createAccounts
	 * @description creates accounts as much as given count
	 * @param Integer count
	 * @return List<Account>
	 */
	public static List<Account> createAccounts(Integer count){
		List<Account> accountList = new List<Account>();
		for (Integer i = 0; i < count; i++ ){
			Account tempAcc = new Account(BillingCity = 'Portland', Name = 'Test Factory Acc ' + i);
			accountList.add(tempAcc);
		}
		return accountList;
	}

	/*
	 * @author Gulbahar Çelik
	 * @date Feb 25 2021
	 * @name createAccounts
	 * @description creates accounts as much as given count, inserts records if preferred
	 * @param Integer count, Boolean doInsert
	 * @return List<Account>
	 */
	public static List<Account> createAccounts(Integer count, Boolean doInsert){
		List<Account> accountList = createAccounts(count);
		if (doInsert){
			insert accountList;
		}
		return accountList;
	}

	/*
	 * @author Gulbahar Çelik
	 * @date Feb 25 2021
	 * @name createContacts
	 * @description creates contacts as much as given count linked with given accounts, creates primary contact with no insert operation
	 * @param Integer count, List<Account> accounts, Boolean createPrimaryContact
	 * @return List<Contact>
	 */
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
		return contacts;
	}

	/*
	 * @author Gulbahar Çelik
	 * @date Feb 25 2021
	 * @name createContacts
	 * @description creates contacts as much as given count linked with given accounts, creates primary contact, inserts records if preferred
	 * @param Integer count, List<Account> accounts, Boolean createPrimaryContact, Boolean doInsert
	 * @return List<Contact>
	 */
	public static List<Contact> createContacts(Integer count, List<Account> accounts, Boolean createPrimaryContact, Boolean doInsert){
		List<Contact> contacts = createContacts(count, accounts, createPrimaryContact);

		if (doInsert){
			insert contacts;
		}

		return contacts;
	}

	/*
	 * @author Gulbahar Çelik
	 * @date Feb 25 2021
	 * @name processContacts
	 * @description returns a list of mocked contact objects
	 * @param Integer count, string accountId, Boolean createPrimaryContact
	 * @return List<Contact>
	 */
	private static List<Contact> processContacts(Integer count, Id accountId, Boolean createPrimaryContact){
		List<Contact> contactList = new List<Contact>();
		for (Integer i = 0; i < count; i++ ){
			Contact temp = new Contact(AccountId = accountId, FirstName = 'TF First ' + i, LastName = 'TF Last ' + i);
			temp.Email = 'testFContact' + i + '@mail.com';
			if (createPrimaryContact && i == 0){
				temp.Is_Primary_Contact__c = true;
			}
			contactList.add(temp);
		}
		return contactList;
	}

	/*
	 * @author Gulbahar Çelik
	 * @date Feb 26 2021
	 * @name createOpportunityByStage
	 * @description creates oops by given stages linked with given account, inserts if preferred
	 * @param Integer count, Set<String> stages, Id accountId, Boolean doInsert
	 * @return List<Opportunity>
	 */
	public static List<Opportunity> createOpportunityByStage(Integer count, Set<String> stages, Id accountId, Boolean doInsert){
		List<Opportunity> opps = createOpportunityByStage(count, stages, accountId);
		if (doInsert){
			insert opps;
		}
		return opps;
	}

	/*
	 * @author Gulbahar Çelik
	 * @date Feb 26 2021
	 * @name createOpportunityByStage
	 * @description creates oops by given stages linked with given account, no insert operation
	 * @param Integer count, Set<String> stages, Id accountId
	 * @return List<Opportunity>
	 */
	public static List<Opportunity> createOpportunityByStage(Integer count, Set<String> stages, Id accountId){
		List<Opportunity> opps = new List<Opportunity>();
		Date closeDate = Date.today().addMonths(5);
		for (String stage : stages){
			for (Integer i = 1; i <= count; i++){
				opps.Add(new Opportunity(Name = stage + i, StageName = stage, Amount = 11 * i, AccountId = accountId, CloseDate = closeDate));
			}
		}
		return opps;
	}
}