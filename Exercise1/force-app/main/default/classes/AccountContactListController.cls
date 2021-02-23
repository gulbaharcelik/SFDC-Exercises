public class AccountContactListController extends PagingHelper{
	public Account account;

	public String searchText{ get; set; }

	private List<Contact> contacts;
	public AccountContactListController(ApexPages.StandardController controller){
		this.account = (Account)controller.getRecord();
		if (searchText == null){
			searchText = '';
		}
		this.totalSize = [select count()
		                  from Contact
		                  where AccountId = :this.account.Id and Name LIKE :('%' + this.searchText + '%')]; //set the total size in the constructor
	}

	public List<Contact> getContacts(){
		try{

			if (searchText != null && searchText != ''){
				totalSize = [select count()
				             from Contact
				             where AccountId = :account.Id and Name LIKE :('%' + this.searchText + '%')];
			}
			contacts = [Select Name, Title, Phone, Is_Primary_Contact__c
			            From Contact
			            where AccountId = :account.Id and Name LIKE :('%' + searchText + '%')
			            limit :listSize
			            offset :offset];
			return contacts;
		} catch (QueryException e){
			ApexPages.addMessages(e);
			return null;
		}
	}

	public PageReference doSearch(){
		offset = 0;
		return null;
	}

	public PageReference doContactUpdate(){
		try{
			String contactId = Apexpages.currentpage().getParameters().get('contactId');
			List<Contact> currentPrimaryContacts = [select Id
			                                        from Contact
			                                        where Is_Primary_Contact__c = true and AccountId = :account.Id];
			for (Contact item : currentPrimaryContacts){
				item.Is_Primary_Contact__c = false;
			}
			update currentPrimaryContacts;

			Contact newPrimaryInstance = new Contact(Id = contactId, Is_Primary_Contact__c = true);
			update newPrimaryInstance;
			return null;
		} catch (Exception e){
			ApexPages.addMessages(e);
			return null;
		}
	}
}