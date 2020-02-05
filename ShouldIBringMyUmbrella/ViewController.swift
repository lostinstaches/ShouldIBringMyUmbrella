//
//  ViewController.swift
//  ShouldIBringMyUmbrella
//
//  Created by Katselenbogen, Igor on 2020/02/03.
//  Copyright © 2020 Katselenbogen, Igor. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,
                      WeatherGetterDelegate,
                      CLLocationManagerDelegate,
                      UITextFieldDelegate
{
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cloudCoverLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var rainLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var getCityWeatherButton: UIButton!
    @IBOutlet weak var getLocationWeatherButton: UIButton!
    
    let locationManager = CLLocationManager()
    var weather: WeatherGetter!
    
    
    // TODO: Refactor
    // TODO: Make a nice design
    // TODO: Make a notification feature which is the main one for the should i bring the umbrella today 
    

    override func viewDidLoad() {
        super.viewDidLoad()
        weather = WeatherGetter(delegate: self)
        
        cityLabel.text = "Simple weather"
        weatherLabel.text = ""
        temperatureLabel.text = ""
        cloudCoverLabel.text = ""
        windLabel.text = ""
        rainLabel.text = ""
        humidityLabel.text = ""
        cityTextField.text = ""
        cityTextField.placeholder = "Enter city name"
        cityTextField.delegate = self
        cityTextField.enablesReturnKeyAutomatically = true
        getCityWeatherButton.isEnabled = false
        
        getLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func getWeatherForLocationButtonTapped(_ sender: Any) {
        setWeatherButtonStates(state: false)
        getLocation()
    }
    
    @IBAction func getWeatherForCityButtonTapped(_ sender: Any) {
        guard let text = cityTextField.text, !text.isEmpty else {
                return
            }
        setWeatherButtonStates(state: false)
        weather.getWeatherByCity(city: cityTextField.text!)
    }
    
    func setWeatherButtonStates(state: Bool) {
        getLocationWeatherButton.isEnabled = state
        getCityWeatherButton.isEnabled = state
    }
    
    func didGetWeather(weather: Weather) {
        DispatchQueue.global(qos: .background).async {
            //Background Thread
            
            DispatchQueue.main.async {
                self.cityLabel.text = weather.city
                self.weatherLabel.text = weather.weatherDescription
                self.temperatureLabel.text = "\(Int(round(weather.tempCelsius)))°"
                self.cloudCoverLabel.text = "\(weather.cloudCover)%"
                self.windLabel.text = "\(weather.windSpeed) m/s"
                
                if let rain = weather.rainfallInLast3Hours {
                    self.rainLabel.text = "\(rain) mm"
                }
                else {
                    self.rainLabel.text = "None"
                }
                
                self.humidityLabel.text = "\(weather.humidity)%"
                self.getLocationWeatherButton.isEnabled = true
                self.getCityWeatherButton.isEnabled = self.cityTextField.text!.count > 0
            }
        }
    }
    
    func didNotGetWeather(error: Error) {
        DispatchQueue.global(qos: .background).async {
            //Background Thread
            DispatchQueue.main.async {
                self.showSimpleAlert(title: "Can't get the weather",
                message: "The weather service isn't responding.")
                self.getLocationWeatherButton.isEnabled = true
                self.getCityWeatherButton.isEnabled = self.cityTextField.text!.count > 0
               }
        }
        print("didNotGetWeather error: \(error)")
    }
    
    func getLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            showSimpleAlert( title: "Please turn on location services",
                   message: "This app needs location services in order to report the weather " +
                            "for your current location.\n" +
                            "Go to Settings → Privacy → Location Services and turn location services on."
                 )
            getLocationWeatherButton.isEnabled = true
            return
        }
        
        let authStatus = CLLocationManager.authorizationStatus()
        guard authStatus == .authorizedWhenInUse else {
            switch authStatus {
            case .denied, .restricted:
                let alert = UIAlertController(
                    title: "Location services for this app are disabled",
                       message: "In order to get your current location, please open Settings for this app, choose \"Location\"  and set \"Allow location access\" to \"While Using the App\".",
                       preferredStyle: .alert
                     )
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default) {
                    action in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                alert.addAction(cancelAction)
                alert.addAction(openSettingsAction)
                present(alert, animated: true, completion: nil)
                getLocationWeatherButton.isEnabled = true
                return
                
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                
            default:
                print("Oops! Shouldn't have come this far.")
            }
            
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestLocation()
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        getCityWeatherButton.isEnabled = prospectiveText.count > 0
        print("Count: \(prospectiveText.count)")
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        weather.getWeatherByCoordinates(latitude: newLocation.coordinate.latitude,
                                        longitude: newLocation.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
          if status == .authorizedWhenInUse {
              locationManager.requestLocation()
          }
      }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                self.showSimpleAlert(title: "Can't determine your location",
                message: "The GPS and other location services aren't responding.")
               }
        }
        print("location Manager didFailWithError: \(error)")
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        getCityWeatherButton.isEnabled = false
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        getWeatherForCityButtonTapped(getCityWeatherButton as Any)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",
                                     style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
    
