//
//  ViewController.swift
//  ShouldIBringMyUmbrella
//
//  Created by Katselenbogen, Igor on 2020/02/03.
//  Copyright © 2020 Katselenbogen, Igor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let weather = WeatherGetter()
        weather.getWeather(city: "Tampa")
    }


}

