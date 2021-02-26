@isTest
public class OpenWeatherMapControllerTest{
	@IsTest
	static void getWeather(){
		OpenWeatherMapApiController extension = makeData();
		Test.startTest();
		//set mock response
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('WeatherCalloutResource');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		// Associate the callout with a mock response
		Test.setMock(HttpCalloutMock.class, mock);
		// Call method to test
		CustomWeatherMap result = extension.getWeather();
		Test.stopTest();
		System.assertNotEquals(null, result, 'The callout returned a null response.');
		// Verify status code

		CustomWeatherMap expected = new CustomWeatherMap();
		expected.description = 'clear sky';
		expected.temp = 284.53;
        expected.icon = '01n';
		System.assertEquals(expected.description, result.description);
		System.assertEquals(expected.temp, result.temp);
        System.assertEquals(expected.icon, result.icon);
        System.assertEquals(expected.iconPath, result.iconPath);
	}

	public static OpenWeatherMapApiController makeData(){
		List<Account> accountList = TestDataFactory.createAccounts(1, true);
		Account testAccount = accountList[0];
		PageReference pageRef = Page.OpenWeatherMap;
		pageRef.getparameters().put('recordId', testAccount.Id);
		Test.setCurrentPage(pageRef);
		Apexpages.StandardController sc = new Apexpages.StandardController(testAccount);
		return new OpenWeatherMapApiController(sc);
	}
}