//
//  ViewController.swift
//  WeatherApp
//
//  Created by Ahmed on 3/4/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController,CLLocationManagerDelegate,ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    

    //TODO: Declare instance variables here
     let locationManger = CLLocationManager()
    let WeatherDataobject = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManger.requestWhenInUseAuthorization()
        locationManger.startUpdatingLocation()
    
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData (url : String , parameters:[String : String]){
        
        Alamofire.request(url , method: .get,parameters:parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got weather data")
                
                let WeatherJson : JSON =  JSON(response.result.value!)
                self.updateWeatherData(json: WeatherJson)
            }else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
                
            }
        }
        
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateWeatherData(json : JSON)
    {
        if  let tempResult = json["main"]["temp"].double {
            
            WeatherDataobject.temprature = Int(tempResult - 273.15)
            WeatherDataobject.city = json["name"].stringValue
            WeatherDataobject.condition = json["weather"][0]["id"].intValue
           WeatherDataobject.WeatherIconName = WeatherDataobject.updateWeatherIcon(condition: WeatherDataobject.condition)
            
            updateUIWithWeatherData()
       
        }
        else {
            cityLabel.text = "Weather Unavailable"
        }
        
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData(){
        cityLabel.text = WeatherDataobject.city
        temperatureLabel.text = "\(WeatherDataobject.temprature)º"
        weatherIcon.image = UIImage(named:WeatherDataobject.WeatherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        if location.horizontalAccuracy < 0 {
            locationManger.stopUpdatingLocation()
            locationManger.delegate = nil
            
            print("longtude : \(location.coordinate.longitude)  ,latitude : \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longtude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat":latitude,"lon":longtude,"appid" :APP_ID]
            
           getWeatherData(url: WEATHER_URL, parameters: params)
        }
        
    }
    
    
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func UserEnteredAnewCityNAme(city: String) {
        let params : [String : String] = ["q":city ,"appid":APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
        
    }
    
    
    
    
}


