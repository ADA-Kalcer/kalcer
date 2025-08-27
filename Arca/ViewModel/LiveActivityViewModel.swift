//
//  LiveActivityViewModel.swift
//  Arca
//
//  Created by Gede Pramananda Kusuma Wisesa on 27/08/25.
//

import Foundation
import ActivityKit
import SwiftUI

class LiveActivityViewModel: ObservableObject {
    @Published var currentActivity: Activity<TourModeActivityWidgetAttributes>?
    
    func startTourActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }
        
        let initialState = TourModeActivityWidgetAttributes.ContentState(
            patungName: "Exploring...",
            isPlaying: false,
            tourModeActive: true
        )
        
        let activityAttributes = TourModeActivityWidgetAttributes(name: "Arca Tour")
        
        do {
            currentActivity = try Activity.request(
                attributes: activityAttributes,
                content: .init(state: initialState, staleDate: nil),
                pushType: nil
            )
            print("Live Activity started successfully")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }
    
    func updateActivity(patungName: String, isPlaying: Bool) {
        guard let activity = currentActivity else { return }
        
        let updatedState = TourModeActivityWidgetAttributes.ContentState(
            patungName: patungName,
            isPlaying: isPlaying,
            tourModeActive: true
        )
        
        Task {
            await activity.update(.init(state: updatedState, staleDate: nil))
        }
    }
    
    func endActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            DispatchQueue.main.async {
                self.currentActivity = nil
            }
        }
        print("Live Activity ended")
    }
}
