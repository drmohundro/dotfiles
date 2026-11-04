// Prints the CGDirectDisplayID of every screen with a camera notch, one per line.
import AppKit

for screen in NSScreen.screens where screen.safeAreaInsets.top > 0 {
  if let id = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber {
    print(id.uint32Value)
  }
}
