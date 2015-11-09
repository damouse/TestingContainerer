//
//  LandingViewController.swift
//  FabAgainst
//
//  Created by Damouse on 9/29/15.
//  Copyright © 2015 paradrop. All rights reserved.
//

import UIKit
import Riffle
import Spring
import IHKeyboardAvoiding


class LandingViewController: UIViewController, RiffleDelegate {
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var viewLogo: SpringView!
    @IBOutlet weak var viewButtons: SpringView!
    @IBOutlet weak var viewLogin: SpringView!
    @IBOutlet weak var textfieldUsername: UITextField!
    
    // The agent connection classes
    var app: RiffleAgent!
    var me: RiffleAgent!
    var container: RiffleAgent!
    
    
    override func viewWillAppear(animated: Bool) {
        Riffle.setDevFabric()
        
        // View setup and styling
        IHKeyboardAvoiding.setAvoidingView(viewLogin)
        
        textfieldUsername.layer.borderColor = UIColor.whiteColor().CGColor
        textfieldUsername.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        viewLogo.animate()
        viewLogin.animate()
    }

    
    @IBAction func login(sender: AnyObject) {
        // Log the user in
        
        // Get the name entered in the textfield and send the keyboard down
        textfieldUsername.resignFirstResponder()
        let name = textfieldUsername.text!
        
        // Create objects for each domain were going to interact with
        app = RiffleAgent(domain: "xs.demo.damouse.cardsagainst")
        container = RiffleAgent(name: "container", superdomain: app)
        
        // Create our domain and join the fabric
        me = RiffleAgent(name: name, superdomain: app)
        me.delegate = self
        me.join()
    }
    
    @IBAction func play(sender: AnyObject) {
        // Called when the player presses the "Play" button. Request cards and the players in the room
        container.call("play", me.domain, handler: startPlaying)
    }
    
    func startPlaying(cards: [String], players: [Player], state: String) {
        // Result of the call to the Room when a player starts playing
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("game") as! GameViewController
        
        controller.currentPlayer = players.filter { $0.domain == self.me.domain }[0]
        controller.currentPlayer.hand = cards
        controller.players = players
        controller.state = state
        
        controller.me = self.me
        controller.app = self.app
        controller.container = self.container
        
        presentControllerTranslucent(self, target: controller)
    }
    
    func onJoin() {
        // Dismiss the login view once connected 
        
        print("Agent joined")
        
        // Animations
        viewLogin.animation = "zoomOut"
        viewLogin.animate()
        viewButtons.animation = "zoomIn"
        viewButtons.animate()
    }
    
    func onLeave() {
        print("Agent left")
    }
}