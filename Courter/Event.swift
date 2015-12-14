//
//  Event.swift
//  Courter
//
//  Created by n3turn on 10/24/15.
//  Copyright © 2015 Zhihao Tang. All rights reserved.
//

import Foundation

class Event {
    
    private var _startTime: String
    private var _endTime: String
    private var _eventTitle: String
    private var _ownerUsername: String
    private var _avaliableToJoin = true
    
    init(startTime: String, endtime: String, eventTitle: String, ownerUsername: String){
        _startTime = startTime
        _endTime = endtime
        _eventTitle = eventTitle
        _ownerUsername = ownerUsername
    }
    
    func getStartTime() -> String {
        return _startTime
    }
    
    func getEndTime() -> String {
        return _endTime
    }
    
    func getEventTitle() -> String {
        return _eventTitle
    }
    
    func getOwnerUsername() -> String {
        return _ownerUsername
    }
    
    func isAvaliableToJoin() -> Bool {
        return _avaliableToJoin
    }
    
    func setAvaliableToJoin(avaliableToJoin: Bool) -> Void {
        self._avaliableToJoin = avaliableToJoin
    }
    
    func isEqual(event1: Event, event2: Event) -> Bool{
        return (event1.getStartTime() == event2.getStartTime() && event1.getEndTime() == event2.getEndTime() && event1.getEventTitle() == event2.getEventTitle() && event1.getOwnerUsername() == event2.getOwnerUsername() && event1.isAvaliableToJoin() == event2.isAvaliableToJoin())
    }
}