global class AccountOpportunityOverviewSchedule implements Schedulable{
	/*
	 * @author Gulbahar Çelik
	 * @date Feb 23 2021
	 * @name execute
	 * @description schedules AccountOpportunityOverviewBatch batch in the preferred time.
	 * @param SchedulableContext context
	 * @return void
	 */
    global void execute(SchedulableContext context){
        AccountOpportunityOverviewBatch batch = new AccountOpportunityOverviewBatch();
        database.executeBatch(batch);
    }
}

/* Daily at 10 AM.
 AccountOpportunityOverviewSchedule sch = new AccountOpportunityOverviewSchedule();
 String daily = '0 0 10 * * ?';
 String dailyJobID = System.Schedule('Account Opportunity Overview - Daily', daily, sch);
 System.debug(dailyJobID);
 */
/* Weekly - every friday at 13 PM.
 String weeklyFriday = '0 0 13 ? * FRI';
 String weeklyFridayJobID = System.Schedule('Account Opportunity Overview - Weekly Friday', weeklyFriday, sch);
 System.debug(weeklyFridayJobID);
 */
/* Last Friday of month at 18 PM.
 String monthlyFriday = '0 0 18 ? * 6L';
 String monthlyFridayJobID = System.Schedule('Account Opportunity Overview - Monthly Friday', monthlyFriday, sch);
 System.debug(monthlyFridayJobID);
 */