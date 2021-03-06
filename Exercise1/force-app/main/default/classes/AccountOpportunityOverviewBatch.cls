global class AccountOpportunityOverviewBatch implements Database.Batchable<SObject>, Database.Stateful{
	//Email table style
	String style = '<style>table{border-collapse:collapse;width:100%; border:2px solid #ddd;text-align:left;padding:8px}th{border:1px solid #fff; text-aling:center;padding:8px;background-color:#ddd}h4{font-weight:300}</style>';
	Map<Id, ContactAccountInfo> accountPrimaryContactMap;
	Map<Id, List<CustomOpportunity>> opportunitiesByAccountId;
	public List<Account> start(Database.BatchableContext bc){
		try{
			//Get accounts that has primary contact and email.
			List<Account> accountsWithPrimaryContacts = [Select Id, Name, (Select Email
			                                                               From Contacts
			                                                               Where Is_Primary_Contact__c = true
			                                                               Limit 1)
			                                             From Account 
			                                             Where Id IN (Select AccountId
			                                                          From Contact
			                                                          Where Is_Primary_Contact__c = true and Email != null)];
			//Map AccountId and contact email to use in the filters in future
			accountPrimaryContactMap = new Map<Id, ContactAccountInfo>();
			for (Account account : accountsWithPrimaryContacts){
				ContactAccountInfo contactItem = new ContactAccountInfo();
				contactItem.AccountName = account.Name;
				contactItem.Email = account.Contacts[0].Email;
				AccountPrimaryContactMap.put(account.Id, contactItem);
			}

			GetOpportunities();

			return accountsWithPrimaryContacts;
		} catch (Exception ex){
			new CustomException().Log(ex);
			return null;
		}
	}

	/*
	 * @author Gulbahar Çelik
	 * @date Feb 23 2021
	 * @name GetOpportunities
	 * @description gets the opportunities by accounts and groups by stages. After retrieving, writes elements to a opportunitiesByAccountId map by accountId to group them. 
	 * @param
	 * @return
	 */
	public void GetOpportunities(){
		try{
			//Get opportunities filtered with the above accounts and given conditions.
			Date lastModifiedFilter = Date.today().addMonths(-1);

			List<AggregateResult> opportunitiesResult = [Select AccountId, Account.Name AccountName, StageName, Format(Sum(Amount))AmountSum
			                                             From Opportunity
			                                             Where StageName IN ('Closed Won', 'Open', 'Closed Lost') and AccountId IN :accountPrimaryContactMap.keySet() and (CreatedDate >= :lastModifiedFilter OR LastModifiedDate >= :lastModifiedFilter)
			                                             Group By AccountId, Account.Name, StageName
			                                             Order By StageName desc];

			if (opportunitiesResult != null && !opportunitiesResult.isEmpty()){
				opportunitiesByAccountId = new Map<Id, List<CustomOpportunity>>();
				//Map opportunities with accountId to group
				for (AggregateResult result : opportunitiesResult){
					Id key = (Id)result.get('AccountId');
					if (!opportunitiesByAccountId.containsKey(key)){
						opportunitiesByAccountId.put(key, new List<CustomOpportunity>());
					}
					CustomOpportunity value = new CustomOpportunity();
					value.StageName = (String)result.get('StageName');
					value.AmountSum = (String)result.get('AmountSum');
					opportunitiesByAccountId.get(key).add(value);
				}
			}
		} catch (Exception ex){
			new CustomException().Log(ex);
		}
	}

	public void execute(Database.BatchableContext bc, List<Account> scope){
		try{
			List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
			if (opportunitiesByAccountId != null && !opportunitiesByAccountId.isEmpty()){
				//execute the logic for each account
				for (Id key : opportunitiesByAccountId.keySet()){
					ContactAccountInfo primaryContact = accountPrimaryContactMap.get(key);
					List<CustomOpportunity> opportunities = opportunitiesByAccountId.get(key);
					//Get email content by primary contact information and opportunities of account
					Messaging.SingleEmailMessage mail = getEmail(primaryContact, opportunities);
					if (mail != null)
						mailList.Add(mail);
				}
				if (mailList.size() > 0){
					Messaging.sendEmail(mailList);
				}
			}
		} catch (Exception ex){
			new CustomException().Log(ex);
		}
	}

	public void finish(Database.BatchableContext bc){
		// execute any post-processing operations
	}

	/*
	 * @author Gulbahar Çelik
	 * @date Feb 23 2021
	 * @name getEmail
	 * @description creates an instance of SingleEmailMessage using primary contact and opportunities list
	 * @param ContactAccountInfo primaryContact, List<CustomOpportunity> opportunities
	 * @return Messaging.SingleEmailMessage
	 */
	public Messaging.SingleEmailMessage getEmail(ContactAccountInfo primaryContact, List<CustomOpportunity> opportunities){
		try{
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setSubject('Opportunities related to ' + primaryContact.AccountName);
			List<String> emailAddresses = new List<String>();
			emailAddresses.Add(primaryContact.Email);
			mail.setToAddresses(emailAddresses);
			String oppSection = '';

			if (opportunities != null && opportunities.size() > 0){
				String rows = '';
				Set<String> stages = new Set<String>{'Open', 'Closed Won', 'Closed Lost'};
				//stages Set will be used to check if all stages are existing, if not, it will add missing stages to the table.
				for (CustomOpportunity item : opportunities){
					stages.remove(item.StageName);
					String row = '<tr><td>' + primaryContact.AccountName + '</td><td>' + item.StageName + '</td><td> ' + item.AmountSum + '</td></tr>';
					rows += row;
				}
				if (!stages.isEmpty()){
					//missing stages inserting to the table
					for (String item : stages){
						String row = '<tr><td>' + primaryContact.AccountName + '</td><td>' + item + '</td><td></td></tr>';
						rows += row;
					}
				}
				oppSection = '<table><tr><th>Account</th><th>Stage</th><th>Amount</th> ' + rows + '</tr></table>';
			} else{
				oppSection = '<p>Your account does not have any opportunities in Open, Closed Won, Closed Lost stages.</p>';
			}

			String htmlBody = '<html><head>' + style + '</head><body><h4>Below is a table of opportunities related to the account: ' + primaryContact.AccountName + ' </h4><br/>' + oppSection + '</body>';

			mail.setHtmlBody(htmlBody);
			return mail;
		} catch (Exception ex){
			new CustomException().Log(ex);
			return null;
		}
	}

	public class ContactAccountInfo{
		public String AccountName{ get; set; }

		public String Email{ get; set; }
	}

	public class CustomOpportunity{
		public String StageName{ get; set; }

		public String AmountSum{ get; set; }
	}
}