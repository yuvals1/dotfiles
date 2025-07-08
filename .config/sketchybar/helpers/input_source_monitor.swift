#!/usr/bin/env swift

import Foundation
import Carbon

// Function to execute the sketchybar plugin
func updateSketchybar() {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", "~/.config/sketchybar/plugins/language.sh"]
    task.launch()
}

// Set up distributed notification observer
DistributedNotificationCenter.default.addObserver(
    forName: NSNotification.Name("com.apple.Carbon.TISNotifySelectedKeyboardInputSourceChanged"),
    object: nil,
    queue: nil
) { _ in
    updateSketchybar()
}

// Initial update
updateSketchybar()

// Keep the program running
RunLoop.current.run()