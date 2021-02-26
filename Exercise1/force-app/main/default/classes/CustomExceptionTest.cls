@isTest
public class CustomExceptionTest{
	@IsTest
	static void testDmlException(){
		Test.startTest();
		try{
			Account account;
			account.Name = 'Ex Test';
		} catch (Exception ex){
			new CustomException().Log(ex);
		}

        List<Error_Log__c> logs = [select Id, ExceptionType__c, Message__c, Line__c from Error_Log__c];
        Error_Log__c log = logs[0];
        
        System.assertEquals(1, logs.size());
        System.assertEquals(8, log.Line__c);
        System.assertEquals('System.NullPointerException', log.ExceptionType__c);
		Test.stopTest();
	}
}