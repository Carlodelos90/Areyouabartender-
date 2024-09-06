import SwiftUI
import AppKit

@main
struct CustomMenubarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            ContentView(appDelegate: appDelegate)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover = NSPopover()
    var customBarVisible = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "ellipsis.circle", accessibilityDescription: nil)
            button.action = #selector(toggleCustomBar)
        }
        
        // Configure the popover
        popover.contentViewController = NSHostingController(rootView: ContentView(appDelegate: self))
        popover.behavior = .transient
    }

    @objc func toggleCustomBar() {
        if customBarVisible {
            popover.performClose(nil)
        } else {
            if let button = statusItem?.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
        customBarVisible.toggle()
    }
}

struct ContentView: View {
    @State private var hiddenIcons: [String] = [] // Simulate hidden icons with app names or identifiers
    @State private var visibleIcons: [String] = ["WiFi", "Battery", "Bluetooth", "Clock"] // Example list of visible icons
    
    var appDelegate: AppDelegate
    
    var body: some View {
        VStack {
            Text("Manage Menubar Icons")
                .font(.headline)
                .padding()

            HStack {
                Text("Visible Icons")
                    .font(.subheadline)
                    .padding(.leading)

                Spacer()

                Text("Hidden Icons")
                    .font(.subheadline)
                    .padding(.trailing)
            }

            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(visibleIcons, id: \.self) { iconName in
                            VStack {
                                Image(systemName: "square") // Placeholder for actual icon
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding()
                                Text(iconName) // Name of the icon (or app)
                            }
                            .onDrag {
                                NSItemProvider(object: iconName as NSString)
                            }
                        }
                    }
                }

                Spacer()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(hiddenIcons, id: \.self) { iconName in
                            VStack {
                                Image(systemName: "square") // Placeholder for actual icon
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding()
                                Text(iconName) // Name of the icon (or app)
                            }
                            .onDrag {
                                NSItemProvider(object: iconName as NSString)
                            }
                        }
                    }
                }
            }
            .frame(height: 40)
            .padding()

            Spacer()
        }
        .padding()
        .onDrop(of: ["public.text"], isTargeted: nil) { providers in
            for provider in providers {
                provider.loadObject(ofClass: NSString.self) { object, _ in
                    if let iconName = object as? String {
                        if let index = self.visibleIcons.firstIndex(of: iconName) {
                            self.hiddenIcons.append(self.visibleIcons.remove(at: index))
                        } else if let index = self.hiddenIcons.firstIndex(of: iconName) {
                            self.visibleIcons.append(self.hiddenIcons.remove(at: index))
                        }
                    }
                }
            }
            return true
        }
    }
}
