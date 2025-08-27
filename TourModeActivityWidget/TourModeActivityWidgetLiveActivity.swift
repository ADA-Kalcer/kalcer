//
//  TourModeActivityWidgetLiveActivity.swift
//  TourModeActivityWidget
//
//  Created by Gede Pramananda Kusuma Wisesa on 27/08/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TourModeActivityWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
//        var emoji: String
        var patungName: String
        var isPlaying: Bool
        var tourModeActive: Bool
    }
    
    // Fixed non-changing properties about your activity go here!
    var name: String
}


/// MARK: - Default
//struct TourModeActivityWidgetLiveActivity: Widget {
//    var body: some WidgetConfiguration {
//        ActivityConfiguration(for: TourModeActivityWidgetAttributes.self) { context in
//            // Lock screen/banner UI goes here
//            VStack {
//                Text("Hello \(context.state.emoji)")
//            }
//            .activityBackgroundTint(Color.cyan)
//            .activitySystemActionForegroundColor(Color.black)
//
//        } dynamicIsland: { context in
//            DynamicIsland {
//                // Expanded UI goes here.  Compose the expanded UI through
//                // various regions, like leading/trailing/center/bottom
//                DynamicIslandExpandedRegion(.leading) {
//                    Text("Leading")
//                }
//                DynamicIslandExpandedRegion(.trailing) {
//                    Text("Trailing")
//                }
//                DynamicIslandExpandedRegion(.bottom) {
//                    Text("Bottom \(context.state.emoji)")
//                    // more content
//                }
//            } compactLeading: {
//                Text("L")
//            } compactTrailing: {
//                Text("T \(context.state.emoji)")
//            } minimal: {
//                Text(context.state.emoji)
//            }
//            .widgetURL(URL(string: "http://www.apple.com"))
//            .keylineTint(Color.red)
//        }
//    }
//}

/// MARK: - Arca Dynamic Island
struct TourModeActivityWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TourModeActivityWidgetAttributes.self)
        { context in
            // Lock Screen Live Activity View
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "headphones")
                        .foregroundColor(.arcaPrimary)
                    Text("Tour Mode Active")
                        .font(.headline)
                    Spacer()
                }
                
                if context.state.isPlaying {
                    HStack {
                        Image(systemName: "speaker.wave.2")
                        Text("Playing: \(context.state.patungName)")
                            .font(.body)
                        Spacer()
                    }
                } else {
                    Text("Exploring nearby statues...")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .activityBackgroundTint(.black.opacity(0.1))
        } dynamicIsland: { context in
            DynamicIsland {
                // Dynamic Island Expanded View
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "headphones")
                        .foregroundColor(.arcaPrimary)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isPlaying {
                        Image(systemName: "speaker.wave.2")
                            .foregroundColor(.green)
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    if context.state.isPlaying {
                        Text("Playing: \(context.state.patungName)")
                            .font(.caption)
                            .lineLimit(1)
                    } else {
                        Text("Tour Mode Active")
                            .font(.caption)
                    }
                }
            } compactLeading: {
                Image(systemName: "headphones")
                    .foregroundColor(.arcaPrimary)
            } compactTrailing: {
                if context.state.isPlaying {
                    Image(systemName: "speaker.wave.2")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "location")
                        .foregroundColor(.blue)
                }
            } minimal: {
                Image(systemName: context.state.isPlaying ?
                      "speaker.wave.2" : "headphones")
                .foregroundColor(context.state.isPlaying ? .green :
                        .arcaPrimary)
            }
        }
    }
}

extension TourModeActivityWidgetAttributes {
    fileprivate static var preview: TourModeActivityWidgetAttributes {
        TourModeActivityWidgetAttributes(name: "Arca Tour")
    }
}

extension TourModeActivityWidgetAttributes.ContentState {
    fileprivate static var exploring: TourModeActivityWidgetAttributes.ContentState {
        TourModeActivityWidgetAttributes.ContentState(
            patungName: "Exploring...",
            isPlaying: false,
            tourModeActive: true
        )
     }
     
     fileprivate static var playing: TourModeActivityWidgetAttributes.ContentState {
         TourModeActivityWidgetAttributes.ContentState(
            patungName: "Patung Nearby!",
            isPlaying: true,
            tourModeActive: true
         )
     }
}

#Preview("Notification", as: .content, using: TourModeActivityWidgetAttributes.preview) {
   TourModeActivityWidgetLiveActivity()
} contentStates: {
    TourModeActivityWidgetAttributes.ContentState.exploring
    TourModeActivityWidgetAttributes.ContentState.playing
}
