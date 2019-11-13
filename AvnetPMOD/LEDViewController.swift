//
//  LEDViewController.swift
//  AvnetPMOD
//
//  Created by James Flynn on 11/3/19.
//  Copyright © 2019 James Flynn. All rights reserved.
//

import UIKit

class LEDViewController: UIViewController, BlinkyDelegate {
 

    @IBOutlet weak var ledColor        : UILabel!
    @IBOutlet weak var redSwitchState  : UISwitch!
    @IBOutlet weak var blueSwitchState : UISwitch!
    @IBOutlet weak var greenSwitchState: UISwitch!
    @IBOutlet weak var binioState      : UILabel!
    @IBOutlet weak var binioSwitch     : UISwitch!

    private var blinkyPeripheral       : BlinkyPeripheral!
    
    //var centralManager                 : CBCentralManager!
    
    var localLEDcolor          : uint=0
    var localBINIOstate        : Bool = false
     
// MARK: - functionallity associated with BlinkyDelegate

    // This function is called from the ViewController to establish the PMOD peripheral that
    // we are talking with
    public func setPMOD(_ peripheral: BlinkyPeripheral) {
        blinkyPeripheral = peripheral
        peripheral.delegate = self
        print("in setPMOD")
    }

     func blinkyDidConnect(ledSupported: Bool, buttonSupported: Bool) {
         print("in blinkyDidConnect")
     }
     
     func blinkyDidDisconnect() {
         print("in blinkyDidDisconnect")
     }
     
     func buttonStateChanged(isPressed: Bool) {
         print("in buttonStateChanged")
     }
     
     func ledStateChanged(isOn: Bool) {
         print("in ledStateChanged")
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("in viewDidLoad")
        
        guard !blinkyPeripheral.isConnected else {
            return
        }
        // Do any additional setup after loading the view.
        if( localBINIOstate ) {
            binioSwitch.isOn = true
            binioState.text = "BINIO is ON "
        }
        else {
            binioSwitch.isOn = false
            binioState.text = "BINIO is OFF"
        }

        if ( (localLEDcolor & 1) == 1 ) {
            redSwitchState.isOn = true
        }
        if ( (localLEDcolor & 2) == 2 ) {
            blueSwitchState.isOn = true
        }
        if ( (localLEDcolor & 4) == 4 ) {
            greenSwitchState.isOn = true
        }

        setColorLabel(localLEDcolor)
        blinkyPeripheral.connect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        blinkyPeripheral.disconnect()
        super.viewWillAppear(animated)
    }
    
    /*
    // MARK: - Navigation
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onReturn(_ sender: Any) {
        dismiss(animated: true, completion:nil)
    }
    
    @IBAction func redSwitch(_ sender: Any) {
        if ( (localLEDcolor&1) == 1 ) {
            localLEDcolor &= 6
        }
        else {
            localLEDcolor |= 1
        }
        setColorLabel(localLEDcolor)
    }
    
    @IBAction func blueSwitch(_ sender: Any) {
        if ( (localLEDcolor&2) == 2 ) {
            localLEDcolor &= 5
        }
        else {
            localLEDcolor |= 2
        }
        setColorLabel(localLEDcolor)
    }
    
    @IBAction func binioSwitch(_ sender: Any) {
        localBINIOstate = !localBINIOstate
        binioState.text = "BINIO is " + (localBINIOstate ? "ON " : "OFF")
        
    }
    
    @IBAction func greenSwitch(_ sender: Any) {
        if ( (localLEDcolor&4) == 4 ) {
            localLEDcolor &= 3
        }
        else {
            localLEDcolor |= 4
        }
        setColorLabel(localLEDcolor)
    }
    
    @IBAction func ledAllOff(_ sender: Any) {
        localLEDcolor = 0
        redSwitchState.isOn = false
        blueSwitchState.isOn = false
        greenSwitchState.isOn = false
        setColorLabel(localLEDcolor)
    }
    
    func setColorLabel(_ color: uint) {
        switch color {
        case 0:
            ledColor.text = "BLACK/OFF"
        case 1:
            ledColor.text = "RED"
        case 2:
            ledColor.text = "BLUE"
        case 3:
            ledColor.text = "MAGENTA"
        case 4:
            ledColor.text = "GREEN"
        case 5:
            ledColor.text = "YELLOW"
        case 6:
            ledColor.text = "CYAN"
        default:
            ledColor.text = "WHITE"
        }
    }
}




