//
//  main.swift
//  Backend
//
//  Created by Damouse on 11/7/15.
//  Copyright © 2015 exis. All rights reserved.
//

import Foundation
import Riffle


// How long each round takes, in seconds
let PICK_TIME = 15.0
let CHOOSE_TIME = 8.0
let SCORE_TIME = 3.0
let EMPTY_TIME = 1.0


let app = RiffleAgent(domain: "xs.demo.damouse.cardsagainst")
Riffle.setDevFabric()


class Container: RiffleAgent {
    var timer: NSTimer?
    
    var state: String = "Empty"
    var players: [Player] = []
    
    var questions = loadCards("q13")
    var answers = loadCards("a13")
    
    
    override func onJoin() {
        print("Container joined")
        
        register("leave", playerLeft)
        register("play", addPlayer)
        register("pick", pick)

        // Called automatically when a domain leaves the fabric
        app.subscribe("sessionLeft", playerLeft)
    }
    
    
    ////////////////////////////////////////////////////////////////////////////
    // State Changing
    // Generally called from players. Change the state of the room
    ////////////////////////////////////////////////////////////////////////////
    
    func addPlayer(domain: String) -> AnyObject {
        // Add the new player and draw them a hand. Let everyone else in the room know theres a new player
        
        print("Adding Player \(domain)")
        
        let newPlayer = Player()
        newPlayer.domain = domain
        newPlayer.hand = answers.randomElements(4, remove: true)
        
        players.append(newPlayer)
        
        return [newPlayer.hand, players, state]
    }
    
    func playerLeft(player: Player) {
        // The player left the game. Remove the given player, reshuffle their cards, and notify the other players
        
        answers.appendContentsOf(player.hand)
        players.removeObject(player)
    }
    
    func pick(player: Player, card: String) {
        // Player picked a card. This action depends on the current state of play
        
        print("Player: \(player.domain) answered \(card)")
    }
    
    
    ////////////////////////////////////////////////////////////////////////////
    // Timer and Utils
    // Utility code for managing timed methods and the current set of rooms
    ////////////////////////////////////////////////////////////////////////////
    
    func startTimer(time: NSTimeInterval, selector: String, info: AnyObject? = nil) {
        // Calls the given function after (time) seconds. Used to count down the seconds on the current round
        
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: Selector(selector), userInfo: info, repeats: false)
    }
    
}

Container(name: "container", superdomain: app).join()
NSRunLoop.currentRunLoop().run()
