//
//  ViewController.swift
//  AvnetPMOD
//
//  Created by James Flynn on 10/31/19.
//  Copyright © 2019 James Flynn. All rights reserved.
//

import UIKit
import CoreBluetooth


public let nordicPMODServiceUUID  = CBUUID.init(string: "00001523-1212-EFDE-1523-785FEABCD123")
public let ledCharacteristicUUID  = CBUUID.init(string: "00001525-1212-EFDE-1523-785FEABCD123")

class ViewController: UIViewController, CBCentralManagerDelegate {
    
    // MARK: - Outlet and Action variables
    @IBOutlet weak var statusLabel           : UILabel!
    @IBOutlet weak var requestedActionButton : UIButton!
    @IBOutlet weak var searchActivity        : UIActivityIndicatorView!
    @IBOutlet weak var btImage               : UIImageView!
    var requestedActionState                 : uint = 0

    // MARK: - Properties Used
    private var hapticGenerator              : NSObject?             // iOS10 and higher only
    private var cbCentralManager             : CBCentralManager!
    private var cbPeripheral                 : CBPeripheral!
    private var ledCharacteristic            : CBCharacteristic?
    
    public private(set) var advertisedName   : String?
    public private(set) var rssi             : NSNumber = 0.0
    public var ledColor                      : uint = 0
    
    // -------------------------------------------------------------------
    //MARK: - BlueTooth actions
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("central.state is .poweredOn")
            cbCentralManager.scanForPeripherals(withServices: [nordicPMODServiceUUID], options:[CBCentralManagerScanOptionAllowDuplicatesKey : false])
        }
    }


    // ----------------------------------------------------------------------
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
      print(peripheral)
    }

    // -------------------------------------------------------------------
    // MARK: - UIView actions
    // Just before the UI view is displayed, connect the CBCentralManager to
    // this view so we can handle its events.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cbCentralManager = CBCentralManager(delegate: self, queue: nil)
    }

    override func prepare (for seque: UIStoryboardSegue, sender: Any!) {
        if( seque.identifier == "LEDViewController" ) {
            let svc = seque.destination as! LEDViewController
            svc.localLEDcolor = ledColor
        }
    }

    // -------------------------------------------------------------------
    // Now we want to display the storyboard and setup the labels/button text.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do additional setup after loading the view.

        statusLabel.text = "Not Connected!"
        btImage.isHidden = true
        requestedActionButton.setTitle("Search?", for:[])
    }

    // -------------------------------------------------------------------
    @IBAction func quitApp(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              exit(0)
             }
        }
    }
    
    // -------------------------------------------------------------------
    @IBAction func goToLEDControl(_ sender: Any) {
        performSegue(withIdentifier: "LEDViewController", sender:self)
    }

    // -------------------------------------------------------------------
    // The statusLabel can be:
    // 1. Searching... with BT ICON displayed
    // 2. PMOD Connected with RSSI icon showing
    // 3. Disconnecting... with BT ICON displayed
    // 4. Not Connected.

    @IBAction func requestAction(_ sender: Any) {
        // The user can request to
        // 0. Search?
        // 1. Searching... for the PMOD
        // 2. Stop looking for the PMOD
        // 3. Disconnect from the PMOD
        
        switch( requestedActionState){
        case 0:
            statusLabel.text = ""
            btImage.isHidden = false
            searchActivity.startAnimating()
            requestedActionButton.setTitle("Stop Search?", for: [])
            requestedActionState = 1
            break;
        case 1:
            btImage.isHidden = true
            searchActivity.stopAnimating()
            requestedActionButton.setTitle("Stoping Search!", for: [])
            requestedActionState = 2
            break;
        case 2:
            requestedActionButton.setTitle("Disconnected!", for: [])
            requestedActionState = 3
            break;
        case 3:
            requestedActionButton.setTitle("Search?", for: [])
            statusLabel.text = "Not Connected!"
            requestedActionState = 0
            break;
        default:
            break;
        }
        
    }
    
    // -------------------------------------------------------------------
    //MARK: - Haptics actions
    //These functions provide user feedback in terms of phone vibration. They only
    //work with using iOS v10 and higher. When a PMOD is found, the user is
    //notified via HapticFeedback
    
    private func prepareHaptics() {
        if #available(iOS 10.0,*) {
            hapticGenerator = UIImpactFeedbackGenerator(style: .heavy)
            (hapticGenerator as? UIImpactFeedbackGenerator)?.prepare()
        }
    }

    // -------------------------------------------------------------------
    private func buttonTapHapticFeedback() {
        if #available(iOS 10.0, *) {
            (hapticGenerator as? UIImpactFeedbackGenerator)?.impactOccurred()
        }
    }
    

}


