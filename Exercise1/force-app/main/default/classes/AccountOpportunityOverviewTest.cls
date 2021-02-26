@isTest
public class AccountOpportunityOverviewTest{
	@IsTest
	static void testSchedule(){
		Test.startTest();
		Integer hourValue = 10;
		String schedule = '0 0 ' + hourValue + ' * * ?';
		String jobId = System.schedule('testAccountOpportunity', schedule, new AccountOpportunityOverviewSchedule());

		// Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
		                  FROM CronTrigger
		                  WHERE id = :jobId];
		Datetime now = Datetime.now();
		Datetime expected = Datetime.now();
		Integer hour = Datetime.now().Hour();
		if (hour > hourValue){
			Datetime temp = now.addDays(1);
			expected = Datetime.newInstance(temp.year(), temp.month(), temp.day(), hourValue, 0, 0);
		} else{
			expected = Datetime.newInstance(now.year(), now.month(), now.day(), hourValue, 0, 0);
		}
		// Verify the expressions are the same
		System.assertEquals(schedule, ct.CronExpression);
		System.assertEquals(String.valueOf(expected), String.valueOf(ct.NextFireTime));
		Test.stopTest();
	}

	@TestSetup
	static void makeData(){
		Account account = new Account(Name = 'Batch Test');

		insert account;

		Contact contact = New Contact(FirstName = 'Primary', LastName = 'Contact', Email = 'gulbahar.celik@osf.digital', AccountId = account.Id, Is_Primary_Contact__c = true);

		insert contact;

		Date closeDate = Date.today().addMonths(5);
		Set<String> stages = new Set<String>{'Open', 'Closed Won', 'Closed Lost'};
		List<Opportunity> opps = TestDataFactory.createOpportunityByStage(3, stages, account.Id, true);
	}
}