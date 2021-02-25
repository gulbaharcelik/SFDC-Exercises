public class CustomWeatherMap{
    public String description{ get; set; }

    public String icon{ get; set; }

    public String iconPath{
        get{
            return 'http://openweathermap.org/img/wn/' + this.icon + '.png';
        }
    }

    public Double temp{ get; set; }
}