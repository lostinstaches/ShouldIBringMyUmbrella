//
//  WeatherGetter.swift
//  ShouldIBringMyUmbrella
//
//  Created by Katselenbogen, Igor on 2020/02/03.
//  Copyright © 2020 Katselenbogen, Igor. All rights reserved.
//

import Foundation

class WeatherGetter {
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "ba3f86c30095dc1370593732b542bc2d"
    
    func getWeather(city: String) {
        
        let session = URLSession.shared
        let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
        
        let dataTask = session.dataTask(with: weatherRequestURL) { data, response, error in
            if let error = error {
                print("Error:\n\(error)")
            }
            else {
                if let jsonString = String(data: data!, encoding: .utf8){
                    print(jsonString)
                }
            }
        }
        dataTask.resume()
    }
    
}
