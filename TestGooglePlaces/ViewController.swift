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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.nameLabel.text = place.name
                    self.addressLabel.text = place.formattedAddress?.components(separatedBy: ", ")
                        .joined(separator: "\n")
                }
            }
        }
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
