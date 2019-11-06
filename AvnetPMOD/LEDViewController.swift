//
//  LEDViewController.swift
//  AvnetPMOD
//
//  Created by James Flynn on 11/3/19.
//  Copyright © 2019 James Flynn. All rights reserved.
//

import UIKit

class LEDViewController: UIViewController {

    @IBOutlet weak var ledColor: UILabel!
    @IBOutlet weak var redSwitchState: UISwitch!
    @IBOutlet weak var blueSwitchState: UISwitch!
    @IBOutlet weak var greenSwitchState: UISwitch!
    
    var localLEDcolor          : uint=0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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




