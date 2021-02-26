public class OpenWeatherMapApiController{
	String apiKey = '229b2ef22138c3a99347225b1e64c3be';
	String endpoint;
	Account account;
	CustomWeatherMap weather;
	public OpenWeatherMapApiController(ApexPages.StandardController controller){
		this.account = (Account)controller.getRecord();
		this.endpoint = 'https://api.openweathermap.org/data/2.5/weather?q=' + account.BillingCity+ '&appid=' + apiKey;
	}

	/*
	 * @author Gulbahar Çelik
	 * @date Feb 24 2021
	 * @name getWeather
	 * @description gets the weather conditions of Accounts billing city
	 * @param
	 * @return CustomWeatherMap
	 */
	public CustomWeatherMap getWeather(){
		try{
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(endpoint);
			request.setMethod('GET');
			request.setHeader('Content-Type', 'application/json;charset=UTF-8');

			HttpResponse response = http.send(request);
			if (response.getStatusCode() == 200){
				OpenWeatherMap data = OpenWeatherMap.parse(response.getBody());
				CustomWeatherMap result = new CustomWeatherMap();
				result.icon = data.weather[0].icon;
				result.description = data.weather[0].description;
				result.temp = data.main.temp;
				return result;
			} else{
				System.debug(response.getBody());
				return null;
			}
		} catch (Exception ex){
			new CustomException().Log(ex);
			return null;
		}
	}
}