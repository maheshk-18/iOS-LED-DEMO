//
//  ViewController.swift
//  IoTDemo
//
//  Created by Mahesh Kokate on 28/01/18.
//  Copyright © 2018 Mahesh Kokate. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // Properties
    var mediator: TAHble!
    var peripheral: CBPeripheral!
    @IBOutlet weak var onLightImage: UIImageView!
    @IBOutlet weak var statusView: UIView!
    

    // Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        
        // Create instance of CBCentralManager class
        self.setup()
        
        // Use timer to start scan devices
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(scanDevices), userInfo: nil, repeats: false)
    }
    
    func setup(){
        self.mediator = TAHble()
        self.mediator.setup()
        self.mediator.delegate = self;
    }
    
    @objc func scanDevices(){
        // Dissconnect already connected devices
        if(self.mediator.activePeripheral != nil) {
            if (self.mediator.activePeripheral.state == CBPeripheralState.connected) {
                self.mediator.manager.cancelPeripheralConnection(self.mediator.activePeripheral)
                self.mediator.activePeripheral = nil
            }
        }
        // Clear peripherals
        if(self.mediator.peripherals != nil){
            self.mediator.peripherals = nil
        }
        // Scan devices
        self.mediator.delegate = self;
        
        // scan for peripherals (scanForPeripheralsWithServices)
        self.mediator.findTAHPeripherals(5)
    }
    
    
    // MARK: Button Action
    @IBAction func changeLedState(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0) {
            self.turnOffLed()
        }else{
            self.turnOnLed()
        }
    }
    
    func turnOnLed(){
        //self.onLightImage.isHidden = false;
        self.mediator.taHanalogWrite(self.mediator.activePeripheral, pinNumber: 13, value: 1)
    }
    
    func turnOffLed(){
        //self.onLightImage.isHidden = true;
        self.mediator.taHanalogWrite(self.mediator.activePeripheral, pinNumber: 13, value: 0)
    }
    

    // MARK: Status Bar Methods
    override var prefersStatusBarHidden: Bool{
        return true
    }
}

extension ViewController: BTSmartSensorDelegate{
    
    func sensorReady(){
        //TODO: it seems useless right now.
    }
    
    
    // Method getsinvoked
    func peripheralFound(_ peripheral: CBPeripheral!) {
        // Connect peripheral which has name "LED DEMO", we have used this name in Arduino program.
        if (peripheral.name == "LED DEMO") {
            // Stop scan
            self.mediator.stopScan()
            
            self.peripheral = peripheral
            
            // Clear past records
            if (self.mediator.activePeripheral != nil) {
                self.mediator.disconnect(self.mediator.activePeripheral)
            }
            // Connect new device
            self.mediator.connect(self.peripheral)
        }
    }
    
    // Method gets invoked for received data
    func taHbleCharValueUpdated(_ UUID: String!, value data: Data!) {
        let receivedValue : String = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
        print(receivedValue)
        
        if(receivedValue == "1\r\n"){
            self.onLightImage.isHidden = false;
        }else if(receivedValue == "0\r\n"){
            self.onLightImage.isHidden = true;
        }
    }
    
    // Method to notify that current active Peripheral is connected
    func setConnect() {
        self.statusView.backgroundColor = UIColor.green;
    }
    
    // Method to notify that current active Peripheral is disconnected
    func setDisconnect() {
        self.statusView.backgroundColor = UIColor.red;
        self.onLightImage.isHidden = true;
    }
}

