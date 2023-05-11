//
//  CountryPicker.swift
//  CountryPicker
//
//  Created by Danial Zahid on 18/06/2019.
//  Copyright © 2019 Danial Zahid. All rights reserved.
//

import UIKit

protocol CountryPickerDelegate1 {
    func didSelectCountry(country: Country1)
}

class CountryPicker1: NSObject {
    //MARK: - Private variables
    fileprivate var countries = [Country1]()

    //MARK: - Public variables
    public var delegate: CountryPickerDelegate1?
    
    /*
     The UIPickerView object used to present the countries list.
     The pickerView settings and appearance can be modified by accessing it directly.
     */
    public let pickerView = UIPickerView()
    
    /*
     The font used for the text in the pickerView.
     Can be passed any custom font from here.
     */
    public var font : UIFont = UIFont.systemFont(ofSize: 15.0)
    
    /*
     The text color for the text in the pickerView.
     Can be passed any custom UIColor.
     */
    public var textColor : UIColor = .black
    
    /*
     The selected country object. Can be used to access different properties
     of the selected country.
     */
    public var selectedCountry : Country1? {
        didSet {
            guard let country = selectedCountry else { return }
            textField?.text = country.countryFlagAndCode()
            delegate?.didSelectCountry(country: country)
        }
    }
    
    /*
     Assign the text field to this object on which the country picker
     needs to be shown.
     */
    public var textField : UITextField? {
        didSet {
            textField?.inputView = pickerView
            textField?.text = selectedCountry?.countryFlagAndCode()
            createToolbar()
        }
    }
    
    //MARK: - Setup Methods
    
    override init() {
        super.init()
        
        populateCountryList()
        setupPicker()
    }
    
    func setupPicker() {
        
        pickerView.delegate = self
        pickerView.backgroundColor = .white
        
        if let currentRegion = Locale.current.regionCode {
            selectedCountry = Country1(isoCode: currentRegion)
        }
    }
    
    private func createToolbar() {
        
        guard let textField = textField else { return }
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(CountryPicker1.dismissField))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        textField.inputAccessoryView = toolBar
    }
    
    @objc func dismissField() {
        textField?.resignFirstResponder()
    }
    
    private func populateCountryList() {
        let list = Locale.isoRegionCodes.map { isoCode in
            return Country1(isoCode: isoCode)
        }
        // Removing Regions that don't have phone codes i.e Antarctica, Aland Islands
        countries = list.filter { $0.phoneCode != ""}
        countries.sort(by: {$0.name < $1.name})
        let empty = Country1(isoCode: "")
        countries.insert(empty, at: 0)
    }
    
    func didSelectCountry(country: Country1) {
        selectedCountry = country
    }
    
    //MARK: -
}

extension CountryPicker1: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        didSelectCountry(country: countries[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textColor = textColor
        label.font = font
        label.text = countries[row].countryFlagAndNameFormatted()
        return label
    }
}
