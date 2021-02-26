public inherited sharing class CustomException extends Exception{
	/*
	 * @author Gulbahar Çelik
	 * @date Feb 25 2021
	 * @name Log
	 * @description inserts the exceptions to Error Log entity and also to the debug log.
	 * @param Exception ex
	 * @return void
	 */
	public void Log(Exception ex){
		try{
			Error_Log__c log = new Error_Log__c();
			log.ExceptionType__c = ex.getTypeName();
			log.Message__c = ex.getMessage();
			log.Line__c = ex.getLineNumber();
            insert log;
            System.debug(log);
		} catch (Exception e){
			System.debug(e);
		}
	}
}