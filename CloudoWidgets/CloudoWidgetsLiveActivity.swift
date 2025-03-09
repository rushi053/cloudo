//
//  CloudoWidgetsLiveActivity.swift
//  CloudoWidgets
//
//  Created by Rushiraj Jadeja on 09/03/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CloudoWidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct CloudoWidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CloudoWidgetsAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension CloudoWidgetsAttributes {
    fileprivate static var preview: CloudoWidgetsAttributes {
        CloudoWidgetsAttributes(name: "World")
    }
}

extension CloudoWidgetsAttributes.ContentState {
    fileprivate static var smiley: CloudoWidgetsAttributes.ContentState {
        CloudoWidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: CloudoWidgetsAttributes.ContentState {
         CloudoWidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: CloudoWidgetsAttributes.preview) {
   CloudoWidgetsLiveActivity()
} contentStates: {
    CloudoWidgetsAttributes.ContentState.smiley
    CloudoWidgetsAttributes.ContentState.starEyes
}
