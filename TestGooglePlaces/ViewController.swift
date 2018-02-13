//
//  ViewController.swift
//  TestGooglePlaces
//
//  Created by Kosuke Matsuda on 2018/02/11.
//  Copyright © 2018年 matsuda. All rights reserved.
//

import UIKit
import GooglePlaces

class ViewController: UIViewController {

    var placesClient: GMSPlacesClient!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    var locationManager: CLLocationManager!
    var coordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.delegate = self
        placesClient = GMSPlacesClient.shared()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLaunchClicked(_ sender: Any) {
        let acController = GMSAutocompleteViewController()
        let filter = GMSAutocompleteFilter()
        filter.type = .region
        acController.autocompleteFilter = filter
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }

    @IBAction func getCurrentPlace(_ sender: Any) {
        placesClient.currentPlace { (placeLikelihoodList, error) in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }

            self.nameLabel.text = "No current place"
            self.addressLabel.text = ""

            if let placeLikelihoodList = placeLikelihoodList {
                for likelihood in placeLikelihoodList.likelihoods {
                    let place = likelihood.place
                    print("--------------------------------------")
                    print("Current Place name \(place.name) at likelihood \(likelihood.likelihood)")
                    print("Current Place address \(place.formattedAddress)")
                    print("Current Place attributions \(place.attributions)")
                    print("Current PlaceID \(place.placeID)")
                    print("Current Place coordinate >>>", place.coordinate)
                }
            }
        }
    }

    func requestCurrentPlace() {
        guard let coordinate = coordinate else {
            return
        }
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("error >>>", error)
                return
            }
            guard let placemarks = placemarks, placemarks.count > 0 else {
                print("empty placemarks")
                return
            }
            for placemark in placemarks {
                print("placemark >>>", placemark)
            }
        }
    }

    @IBAction func onClickGecode(_ sender: Any) {
//        requestGeocoding()
        requestReverseGeocoding()
    }

    let googleGeocodingAPIKey = ""
    let googleGeocodingBaseURL = "https://maps.googleapis.com/maps/api/geocode/json"

    func requestGeocoding() {
        print(#function)
        var components = URLComponents(string: googleGeocodingBaseURL)!
        components.queryItems = [
            URLQueryItem(name: "key", value: googleGeocodingAPIKey),
            URLQueryItem(name: "address", value: "Tokyo"),
        ]
        requestGoogleGeocoding(url: components.url!)
    }
    func requestReverseGeocoding() {
        print(#function)
        guard let coordinate = coordinate else {
            return
        }
//        let latlng = "\(coordinate.latitude),\(coordinate.longitude)"
        let latlng = "35.6836488,139.6829098"
        var components = URLComponents(string: googleGeocodingBaseURL)!
        components.queryItems = [
            URLQueryItem(name: "key", value: googleGeocodingAPIKey),
            URLQueryItem(name: "latlng", value: latlng),
            URLQueryItem(name: "result_type", value: "locality|sublocality"),
        ]
        requestGoogleGeocoding(url: components.url!)
    }
    func requestGoogleGeocoding(url: URL) {
        print(#function)
        print("url >>>", url)
        let task = URLSession.shared.dataTask(with: url) { (data, urlSession, error) in
            if let error = error {
                print("error >>>", error)
                return
            }
            guard let data = data, data.count > 0 else {
                print("data is empty")
                return
            }
            let json = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
            print("json >>>\n", json)
            guard let dict = json as? [String: Any], let results = dict["results"] as? [[String: Any]] else { return }
            for result in results {
                print("result >>>", result)
            }
        }
        task.resume()
    }
}

extension ViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        print("Place coordinate: \(place.coordinate)")
        print("Place types: \(place.types)")
        dismiss(animated: true, completion: nil)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: \(error)")
        dismiss(animated: true, completion: nil)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Autocomplete was cancelled.")
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func startUpdateLocation(manager: CLLocationManager) {
        coordinate = nil
//        manager.startUpdatingLocation()
        manager.requestLocation()
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(#function)
        print("status >>>", status.rawValue)
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
        case .denied:
            break
        case .restricted:
            break
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdateLocation(manager: manager)
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(#function)
        guard let location = locations.last else {
            return
        }
        print("location >>>", location)
        coordinate = location.coordinate
//        requestCurrentPlace()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function)
        print("error >>>", error)
        locationManager.stopUpdatingLocation()
    }
}
