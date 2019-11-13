//
//  ViewController.swift
//  AvnetPMOD
//
//  Created by James Flynn on 10/31/19.
//  Copyright © 2019 James Flynn. All rights reserved.
//
// This is the Main Screen View Controller.  The only control this view has is to connect to the
// PMOD or not.  Once connected, the variable cbCentralManager is set and used by the other views.
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
    private var cbCentralManager             : CBCentralManager!
    private var cbPeripheral                 : CBPeripheral!
    private var blinkyPeripheral             : BlinkyPeripheral!
    private var discoveredPeripherals        = [BlinkyPeripheral]()
    
    public private(set) var advertisedName   : String?
    public private(set) var rssi             : NSNumber = 0.0
    var pmodFound                            : Bool = false
    
    // -------------------------------------------------------------------
    //MARK: - BlueTooth actions

    // -------------------------------------------------------------------
    // MARK: - UIView actions
    // Just before the UI view is displayed, connect the CBCentralManager to
    // this view so we can handle its events.
    override func viewWillAppear(_ animated: Bool) {
        print("in viewWillAppear")
        super.viewWillAppear(animated)
        discoveredPeripherals.removeAll()
    }

    override func prepare (for seque: UIStoryboardSegue, sender: Any!) {
        if( seque.identifier == "LEDViewController" ) {
            print("in prepare...")
            if let pmod = blinkyPeripheral {
                print("and calling setPMOD()")
                let destView = seque.destination as! LEDViewController
                destView.setPMOD(pmod)
                }
            }
    }

    // -------------------------------------------------------------------
    // Now we want to display the storyboard and setup the labels/button text.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do additional setup after loading the view.
        pmodFound = false
        cbCentralManager = CBCentralManager(delegate: self, queue: nil)
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
        case 0:  // we are searching for a PMOD device
            if (cbCentralManager.state == .poweredOn) {
                statusLabel.text = ""
                btImage.isHidden = false
                searchActivity.startAnimating()
                if !cbCentralManager.isScanning  {
                    print ("start pmod search.")
                    cbCentralManager.scanForPeripherals(withServices: [BlinkyPeripheral.nordicBlinkyServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
                }
                requestedActionButton.setTitle("Stop Search?", for: [])
                requestedActionState = 1
            }
            else {
                print("Bluetooth is powered off!")
            }
            break;
        case 1:  // we were searching for a PMOD but user requested us to stop
            cbCentralManager.stopScan()
            print("Stopping search")
            btImage.isHidden = true
            searchActivity.stopAnimating()
            discoveredPeripherals.removeAll()
            requestedActionButton.setTitle("Search?", for:[])
            requestedActionState = 0
            pmodFound = false
            break;
        case 2:  // We are connected and can begin manipulating the PMOD
            requestedActionButton.setTitle("Disconnect?", for: [])
            requestedActionState = 3
            break;
        case 3:  // we were connected and user requested we disconnect
            requestedActionState = 4
            break;
        case 4:  // we are not connected and asking user if we should search
            requestedActionButton.setTitle("Search?", for: [])
            statusLabel.text = "Not Connected!"
            requestedActionState = 0
            break;
        default:
            break;
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let newPeripheral = BlinkyPeripheral(withPeripheral: peripheral, advertisementData: advertisementData, andRSSI: RSSI, using: cbCentralManager)
        if !discoveredPeripherals.contains(newPeripheral) {
            print("in centralManager function, found a new peripheral!", newPeripheral)
            if advertisedName == "Nordic_Blinky" {
                pmodFound = true
                requestedActionState = 2
            }
            advertisedName = newPeripheral.advertisedName
            rssi = newPeripheral.RSSI
            print(newPeripheral)
            blinkyPeripheral = newPeripheral
            statusLabel.text = (newPeripheral.advertisedName!) + ":" + rssi.stringValue
            print("    PMOD Name = ", advertisedName ?? String())
            print("RSSI strength = ", rssi)
            discoveredPeripherals.append(newPeripheral)
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
         if central.state == .poweredOn {
             print("going to scan for peripherals")
             cbCentralManager.scanForPeripherals(withServices: [BlinkyPeripheral.nordicBlinkyServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
         }
         else {
             print("BT now powered on!")
         }
     }
    
}


