<p align="center">
  <img width="376" height="182" alt="ROCC" src="https://github.com/simonmitchell/rocc/blob/master/assets/rocc.png">
</p>
<p align="center">
  <a href="https://travis-ci.org/simonmitchell/rocc">
  	<img alt="Build Status" src="https://travis-ci.org/simonmitchell/rocc.svg">
  </a>
  <a href="https://github.com/Carthage/Carthage">
  	<img alt="Carthage Compatible" src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat">
  </a>
  <a href="https://swift.org/blog/swift-5-2-released/">
  	<img alt="Swift 5.2" src="http://img.shields.io/badge/swift-5.2-brightgreen.svg">
  </a>
  <a href="https://github.com/simonmitchell/rocc/blob/master/README.md">
  	<img alt="MIT" src="https://img.shields.io/badge/license-MIT-brightgreen.svg">
  </a>
</p>

Rocc (Remote Camera Control) is a Swift framework for interacting with Digital Cameras which support function control or Image/Video transfer via a WiFi connection. It currently only supports control/transfer from Sony's line-up of cameras but will be expanding in the future to support as many manufacturers as possible!

The Sony implementation is a tried and tested codebase which is used by the app [Camrote](https://itunes.apple.com/app/id1408732788) to provide the connectivity with the camera.

Rocc is designed to be as generic as possible, both from a coding point of view and also from an API point of view, meaning support for other manufacturers should be a seamless integration with any existing codebase which is using the framework.

## Installation

### Carthage

Carthage is a dependency manager which builds frameworks for you or downloads pre-built binaries from a specific tag on GitHub

1. If you haven't already, setup Carthage as outlined [here](https://github.com/Carthage/Carthage#quick-start).
1. Add Rocc as a dependency in your Cartfile: `github "simonmitchell/rocc" == 2.0.0`.
1. Drag both `Rocc.framework` and `ThunderRequest.framework` into your project's  `Frameworks, Libraries and Embedded Content` section.
1. Make sure that both frameworks are included in your carthage copy files build phase. 

**We will be removing the dependency on `ThunderRequest` in a future release**

### Manual

Manual installation is a bit more involved, and not the suggested approach.

1. Clone, download or add the repo as a submodule to your repo.
1. Drag the Rocc project file into your main app's project.
1. Add `Rocc` (Or the platform appropriate equivalent) to the `Frameworks, Libraries and Embedded Content` section of your app's target in the General panel of your project. Making sure you set it to `Embed & Sign`.
1. Add `ThunderRequest` (make sure you choose the correct framework for your OS) to the `Frameworks, Libraries and Embedded Content` section of your app's target, again making sure to set it to `Embed & Sign`
1. Import `Rocc` and you're ready to go!

## Examples

### Discovering Cameras

To discover cameras you will use the class `CameraDiscoverer`. You must keep a strong reference to this in order to keep it in memory. It will start all the various tasks necessary for device discovery as well as keeping track of WiFi network changes and re-starting the search e.t.c. in these cases. 

It will not start and re-start when your application enters the background and foreground however so you may want to implement this yourself!

```swift
init () {
    cameraDiscoverer = CameraDiscoverer()
    cameraDiscoverer.delegate = self
    cameraDiscoverer.start()
}


func cameraDiscoverer(_ discoverer: CameraDiscoverer, didError error: Error) {
    // Called with errors, these do happen a lot so you will want to check the error code and type here before displaying!        
}
    
func cameraDiscoverer(_ discoverer: CameraDiscoverer, discovered device: Camera) {
    // Connect to the device!
   connect(to: device)
}
```

`CameraDiscoverer` also maintains a dictionary of devices that have been discovered keyed by the `SSID` they were discovered on for your convenience, and the current `SSID` can be accessed using the `Reachability` class:

```swift
let cameras = discoverer.camerasBySSID[Reachability.currentWiFiSSID] ?? []
```

### Connecting to a Camera
-----

Once you have discovered to a camera, you will need to connect to it. Not all, but most Sony cameras require an API call to be made to enable remote functionality, but for the sake of genericness this should be called on all `Camera` objects.

```swift
func connect(to camera: Camera) {
    camera.connect { (error, isInTransferMode) in
        // isInTransferMode reflects whether the camera was already connected
        // to and has been re-connected to whilst in "Contents Transfer" mode.
    }
}
```

You should then progress to performing the functionality you wish to with the connected Camera. You should first check the core capabilities of the camera however as Sony supports two (Really 3) connection modes:

```swift
switch camera.connectionMode {
case .contentsTransfer(let preselected): 
    if preselected {
        camera.loadFilesToTransfer(callback: { (fileUrls) in
            // Download Files Somehow!
            camera.finishTransfer(callback: { (_) in
                
            })
        })
    } else {
        // Show UI for transferring files
    }
case .remoteControl:
// Show remote control UI
}
```

### Staying Connected!
-----

Rocc provides a simple delegate based class that will alert you when a `Camera` has become disconnected.

```swift
init(camera: Camera) {
    connectivityNotifier = DeviceConnectivityNotifier(camera: camera, delegate: self)
}

func connectivityNotifier(_ notifier: DeviceConnectivityNotifier, didDisconnectFrom device: Camera) {
    // If it is appropriate to show some kind of UI to let 
    //  the user know the camera has disconnected!    
}

func connectivityNotifier(_ notifier: DeviceConnectivityNotifier, didReconnectTo device: Camera) {
    // Let the user carry on as they were!
}
```

### Streaming the Live View
-----

Streaming the live view is as simple as using a `LiveViewStream` class.

```swift
init(camera: Camera) {
    liveViewStream = LiveViewStream(camera: camera, delegate: self)
    liveViewStream.start()
}

func liveViewStream(_ stream: LiveViewStream, didReceive image: UIImage) {
    OperationQueue.main.addOperation {
        // Show the next image
    }
}
    
func liveViewStream(_ stream: LiveViewStream, didReceive frames: [FrameInfo]) {
    OperationQueue.main.addOperation {
        // Show frame information (Focus info)
    }
}
    
func liveViewStreamDidStop(_ stream: LiveViewStream) {
    // Live view stopped!
}
    
func liveViewStream(_ stream: LiveViewStream, didError error: Error) {
    // Stream errored, you can try and restart it in this method if
    // you want, but be careful not to recurse too much!
}
```

### Receiving Camera "Events"
-----

Because your camera settings can still be adjusted manually on the camera whilst shooting, and some settings may affect others (Changing aperture whilst in aperture priority mode may change shutter speed/ISO e.t.c) it is important that the camera can communicate these changes over WiFi. To get changes you should subscribe to them using `CameraEventNotifier`:

```swift
init(camera: Camera) {
    eventNotifier = CameraEventNotifier(camera: camera, delegate: self)
    eventNotifier.startNotifying()
}

func eventNotifier(_ notifier: CameraEventNotifier, didError error: Error) {
    // If it's important to, show the user an Error        
}
    
func eventNotifier(_ notifier: CameraEventNotifier, receivedEvent event: CameraEvent) {
    // Handle the event and update UI! CameraEvent includes all exposure
    // info as well as changes to shooting mode, camera status, e.t.c.
}
```

It is important to note that the information provided by `CameraEventNotifier` will vary by manufacturer, and even by model of camera for the same manufacturer, so you may not always be able to rely on it solely! 

**IMPORTANT:** The `CameraEvent` object will have `nil` values for properties that haven't changed with a given `event` occuring. For example if only the aperture has changed things like `cameraStatus` will be `nil`, which doesn't mean the camera is now `idle`.

### Performing Camera Functions
-----

Camera functions are written generically, so there are only 4 methods you need to call on `Camera` rather than an individual set of methods for each piece of functionality on the camera.

#### Function Support

Before showing the UI for a function, you should make sure it is supported on your camera. To do this you call a method on your Camera object:

```swift
camera.supportsFunction(Focus.Mode.set, callback: { (isSupported, error, supportedValues) in
    // Disable/enable features using the returned value
})
```

The type type of `supportedValues` is defined on the declaration of `Focus.Mode` by it's associatedtype `SendType`

#### Function Availability

Once you have deemed if a function is supported on your camera, you can then check manually for function availability:

```swift
camera.isFunctionAvailable(Focus.Mode.set, callback: { (isAvailable, error, availableValues) in
    // Update UI to enable/disable control and show available values
})
```

**Important:** Function availability is also provided by the eventing mechanism, which is often a friendlier way to check for function availability and should be used for disabling/enabling controls when things like shutter speed setting become temporarily unavailable as the user takes a picture or changes to "Auto" mode on their camera.

You can also attempt to make a function available if it isn't currently, for example when changing shooting modes it is recommended to simply call:

```swift
camera.makeFunctionAvailable(BulbCapture.start, callback: { (error) in
    // Update UI
})
```

This will handle all the logic needed to enable bulb shooting, mainly making sure the camera is in `Still Image` shooting mode, and setting the shutter speed to `BULB`. It is also vital in changing to contents transfer mode as can be seen in **Transferring Images** below.

#### Performing a Function

Once you have finally deemed if a function is available (Or made it available) you can then with confidence call it on your Camera knowing that in all likelihood it will work:

```swift
camera.performFunction(Focus.Mode.set, payload: focusMode, callback: { (error, _) in
    // Update UI (You can rely on eventing if you want to update or do it
    // manually here)
})
```

```swift
camera.performFunction(Focus.Mode.get, payload: nil, callback: { (error, value) in
    // Update UI
})
```

As with calling `isFunctionAvailable` or `supportsFunction` both the send type (`payload` parameter) and return type (`value` in the second example) are defined by associated types on the function you are calling!

### Transferring Images
-----

This topic will only cover transferring images whilst connected to a camera using the 'Remote Control' connection mode, as the other methods have already been covered above.

#### Checking if Contents Transfer is supported

Before allowing the user to enter "Content Transfer" mode, it is important to make sure the connected camera supports doing so, this includes two checks:

```swift
camera.supportsFunction(Function.set, callback: { (setFunctionSupported, _, _) in
                    
    // If we're not allowed to set the camera's "Function" then we're done
    guard let supported = setFunctionSupported, supported else {
        self.supportsContentsTransfer = false
        return
    }
    
    // Check if once we've set the camera's function we can actually list contents!
    device.supportsFunction(FileSystem.Contents.list) { (isSupported, error, supported) in
        self.supportsContentsTransfer = isSupported
    }
})
```

#### Entering Contents Transfer mode

First off, we need to enter "Contents Transfer" mode on the camera, this may not be needed on all manufacturers but it should be called for all anyway and some will just do nothing internally:

```swift
// First check if listing contents is already available!
camera.isFunctionAvailable(FileSystem.Contents.list, callback: { (isAvailable, error, _) in
	
    guard let available = isAvailable else {
        // Show error!
        return
    }
	
    guard !isAvailable else {
        // Load schemes
    }
	
    camera.makeFunctionAvailable(FileSystem.Contents.list, callback: { (error) in
        guard error = error else {
            // Load schemes
        }
        // Show error!
    }
}
```

#### Load "Schemes"

Sony cameras require a "Scheme" when calling further APIs. Although their docs state this can only ever be `"storage"` we should still list them in-case this has changed:

```swift
camera.performFunction(FileSystem.Schemes.list, payload: nil, callback: { (error, schemes) in
	
    // If multiple schemes, give the user some kind of UI to pick!
    // Then move on to loading "Sources"
}
```

**Important:** At this stage it's important to note that this function may not always be available immediately after the return from `makeFunctionAvailable(FileSystem.Contents.List)` therefore you should listen to events and call this again in certain cases:

```swift
// If the status has changed to ready for contents transfer
if let status = event.status, status == .readyForContentsTransfer {
    loadSchemes()
    // Or the function has changed to Contents Transfer load schemes!
} else if let function = event.function, function.current == "Contents Transfer" {
    loadSchemes()
}
```

However I would advise not relying solely on these events and calling the list schemes function immediately as well.

#### Load "Sources"

Once you have loaded schemes, you can load sources for the given scheme, again most cameras will only have one `Source` unless they have dual memory card slots perhaps (We are yet to test this theory)

```swift
camera.performFunction(FileSystem.Schemes.list, payload: scheme, callback: { (error, schemes) in
	
    // Again, if multiple "schemes" are returned, let the user pick!
    // Then move on to getting the count of items on the camera.
}
```

#### Load Content Count

It's important to load this as it will let you know when to paginate (If you are loading contents in using a flat view, more on that later!)

```swift
let countRequest = CountRequest(uri: source)
camera.performFunction(FileSystem.Contents.Count.get, payload: countRequest, callback: { [weak self] (error, count) in
            
    guard let _count = count else {
        // Show error
        return
    }
    
    // Save the content count and start loading content!
})
```

#### Loading content!

Once you have done all the above you can then finally start loading content (Important to note, you can take shortcuts with the above if you know you are only working with certain manufacturers, but do so at your own risk!):

```swift
// Setup a file request using the given source and a start index and number of items to return
let fileRequest = FileRequest(uri: source, startIndex: offset, count: itemsToFetch, view: .flat, sort: .descending, types: nil)

camera?.performFunction(FileSystem.Contents.list, payload: fileRequest, callback: { (error, fileResponse) in

    guard let response = fileResponse else {
        // Show error!
        return
    }
	
    // File response returns whether we have reached the end of the files:
    fullyLoaded = response.fullyLoaded
    // And an array of `File` objects:
    files.append(contentsOf: response.files)
    // Redraw!
}
```

## Class Level Documentation

Class level documentation is available for inspection in Xcode, and will be made available using GitHub docs in the future.

## Contributing

Please see our [contribution guidelines](CONTRIBUTING.md)


