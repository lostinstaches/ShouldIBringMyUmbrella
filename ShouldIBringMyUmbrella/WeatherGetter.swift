//
//  WeatherGetter.swift
//  ShouldIBringMyUmbrella
//
//  Created by Katselenbogen, Igor on 2020/02/03.
//  Copyright © 2020 Katselenbogen, Igor. All rights reserved.
//

import Foundation

protocol WeatherGetterDelegate {
    func didGetWeather(weather: Weather)
    func didNotGetWeather(error: Error)
}

class WeatherGetter {
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "ba3f86c30095dc1370593732b542bc2d"
    
    private var delegate: WeatherGetterDelegate
    
    init(delegate: WeatherGetterDelegate) {
        self.delegate = delegate
    }
    

    func getWeatherByCity(city: String) {
        let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
        getWeather(weatherRequestURL: weatherRequestURL)
    }
    
    func getWeatherByCoordinates(latitude: Double, longitude: Double) {
        let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&lat=\(latitude)&lon=\(longitude)")!
        getWeather(weatherRequestURL: weatherRequestURL)
    }
    
    private func getWeather(weatherRequestURL: URL) {
        
        let session = URLSession.shared
        session.configuration.timeoutIntervalForRequest = 3
        
        
        let dataTask = session.dataTask(with: weatherRequestURL) { data, response, error in
            if let networkError = error {
                self.delegate.didNotGetWeather(error: networkError)
            }
            else {
                do {
                    let weatherData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                 
                    let weather = Weather(weatherData: weatherData)
                    self.delegate.didGetWeather(weather: weather)
                }
                catch {
                    self.delegate.didNotGetWeather(error: error)
                }
            }
        }
        dataTask.resume()
    }
    
}
