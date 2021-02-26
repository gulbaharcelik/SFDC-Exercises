public with sharing class AccountContactListController extends PagingHelper{
	public Account account;

	public String searchText{ get; set; }

	private List<Contact> contacts;
	public AccountContactListController(ApexPages.StandardController controller){
		this.account = (Account)controller.getRecord();
		if (searchText == null){
			searchText = '';
		}
		//calculate total size for paging
		this.totalSize = [select count()
		                  from Contact 
		                  where AccountId = :this.account.Id and Name LIKE :('%' + String.escapeSingleQuotes(searchText)+'%')]; //set the total size in the constructor
	}

	/*
	 * @author Gulbahar Çelik
	 * @date Feb 19 2021
	 * @name getContacts
	 * @description get contact list by account
	 * @param
	 * @return List<Contact>
	 */
	public List<Contact> getContacts(){
		try{
			if (searchText != null && searchText != ''){
				//if search text is filled, total count should be calculated again
				totalSize = [select count()
				             from Contact 
				             where AccountId = :account.Id and Name LIKE :('%' + String.escapeSingleQuotes(searchText)+'%')];
			}
			//get contacts
			SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, [Select Name, Title, Phone, Is_Primary_Contact__c
			                                                                                          From Contact
			                                                                                          where AccountId = :account.Id and Name LIKE :('%' + String.escapeSingleQuotes(searchText)+'%')
			                                                                                          limit :listSize
			                                                                                          offset :offset]);
			contacts = securityDecision.getRecords();
			return contacts;
		} catch (QueryException e){
			ApexPages.addMessages(e);
			new CustomException().Log(e);
			return null;
		}
	}

	/*
	 * @author Gulbahar Çelik
	 * @date Feb 19 2021
	 * @name doSearch
	 * @description search contacts by search input
	 * @param
	 * @return PageReference
	 */
	public PageReference doSearch(){
		offset = 0;
		return null;
	}

	/*
	 * @author Gulbahar Çelik
	 * @date Feb 19 2021
	 * @name doContactUpdate
	 * @description set the selected contact as primary and clear existing primary contact
	 * @param
	 * @return PageReference
	 */
	public PageReference doContactUpdate(){
		try{
			String contactId = Apexpages.currentpage().getParameters().get('contactId');
			SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, [select Id
			                                                                                           from Contact
			                                                                                           where Is_Primary_Contact__c = true and AccountId = :account.Id]);
			List<Contact> currentPrimaryContacts = securityDecision.getRecords();
			for (Contact item : currentPrimaryContacts){
				item.Is_Primary_Contact__c = false;
			}
			//firstly, clear existing primary contacts so trigger will not throw error
			update currentPrimaryContacts;

			//set the new contact as primary
			Contact newPrimaryInstance = new Contact(Id = contactId, Is_Primary_Contact__c = true);
			update newPrimaryInstance;
			return null;
		} catch (Exception e){
			ApexPages.addMessages(e);
			new CustomException().Log(e);
			return null;
		}
	}
}