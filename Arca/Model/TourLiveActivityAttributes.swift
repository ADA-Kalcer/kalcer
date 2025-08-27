//
//  TourLiveActivity.swift
//  Arca
//
//  Created by Gede Pramananda Kusuma Wisesa on 27/08/25.
//

import Foundation
import ActivityKit

struct TourModeActivityWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var patungName: String
        var isPlaying: Bool
        var tourModeActive: Bool
    }
    
    var name: String
}
