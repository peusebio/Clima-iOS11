//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    @IBOutlet weak var conversionSwitch: UISwitch!
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "78dc015d98183b9857667544cdaac492"
    
    
    //TODO: Declare instance variables here
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    var currentUnitIsCelsius : Bool = true
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        conversionSwitch.tintColor = UIColor.clear
        conversionSwitch.onTintColor = UIColor.clear
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData (url: String, parameters: [String : String]){
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess{
                print("Success! Got the weather data.")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                print("Error \(response.result.error)")
                self.cityLabel.text = "Connection issues"
            }
        }
    }
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    //Write the updateWeatherData method here:
    
    
    func updateWeatherData(json: JSON){
        if let tempResult = json["main"]["temp"].double{
            
            weatherDataModel.temperature = tempResult - 273.15
            
            weatherDataModel.city = json["name"].stringValue
            
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWeatherData()
        }
        else {
            cityLabel.text = "Weather unavailable."
        }
    }
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWeatherData(){
        checkTemperatureUnits()
        cityLabel.text = weatherDataModel.city
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            let params : [String : String] = ["lat": String(latitude), "lon" : String(longitude), "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location not available"
    }
    
    
    
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredNewCityName (city : String){
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    //Write the PrepareForSegue Method here
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    @IBAction func temperatureConversion(_ sender: UISwitch) {
        if sender.isOn && !currentUnitIsCelsius {
            currentUnitIsCelsius = true
            convertToCelsius()
        }
        else if !sender.isOn && currentUnitIsCelsius{
            currentUnitIsCelsius = false
            convertToFahrenheit()
        }
    }
    
    func checkTemperatureUnits(){
        if conversionSwitch.isOn && currentUnitIsCelsius {
            temperatureLabel.text = "\(Int(weatherDataModel.temperature))ºC"
        }
        else if(conversionSwitch.isOn){
            convertToCelsius()
        }
        else {
            convertToFahrenheit()
        }
    }
    
    func convertToCelsius(){
        weatherDataModel.temperature = (weatherDataModel.temperature - 32) / 1.8
        temperatureLabel.text = "\(Int(weatherDataModel.temperature))ºC"
    }
    
    func convertToFahrenheit(){
        weatherDataModel.temperature = (weatherDataModel.temperature * 1.8) + 32
        temperatureLabel.text = "\(Int(weatherDataModel.temperature))ºF"
    }
    
}


