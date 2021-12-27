//
//  CanonPTPEvents+Addition.swift
//  Rocc
//
//  Created by Simon Mitchell on 21/06/2021.
//  Copyright © 2021 Simon Mitchell. All rights reserved.
//

import Foundation

extension CanonPTPEvents {
    static func +(lhs: CanonPTPEvents, rhs: CanonPTPEvents) -> CanonPTPEvents {

        var lhsEvents = lhs.events
        rhs.events.forEach { event in
            // If the property is already present in received properties,
            // just directly replace it
            if let existingIndex = lhsEvents.firstIndex(where: { existingEvent in
                // Quick check for performance!
                guard type(of: existingEvent) == type(of: event) else {
                    return false
                }
                switch (existingEvent, event) {
                // TODO: See if we can make this more generic! Perhaps add `code` param to protocol so can compare using that?
                case (let existingPropChange as CanonPTPPropValueChange, let newPropChange as CanonPTPPropValueChange):
                    return existingPropChange.code == newPropChange.code
                case (let existingAvailableValsPropChange as CanonPTPAvailableValuesChange, let newAvailableValsPropChange as CanonPTPAvailableValuesChange):
                    return existingAvailableValsPropChange.code == newAvailableValsPropChange.code
                default: return false
                }
            }) {
                lhsEvents[existingIndex] = event
            } else { // Otherwise append it to the array
                lhsEvents.append(event)
            }
        }
        return CanonPTPEvents(events: lhsEvents)
    }
}
