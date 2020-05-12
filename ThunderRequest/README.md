# Thunder Request

[![Build Status](https://travis-ci.org/3sidedcube/ThunderRequest.svg)](https://travis-ci.org/3sidedcube/ThunderRequest) [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Swift 5.2](http://img.shields.io/badge/swift-5.2-brightgreen.svg)](https://swift.org/blog/swift-5-2-released/) [![Apache 2](https://img.shields.io/badge/license-Apache%202-brightgreen.svg)](LICENSE.md)

Thunder Request is a Framework used to simplify making http and https web requests.

# Installation

Setting up your app to use Thunder Request is a simple and quick process.

+ Drag the project file into your project
+ Add ThunderRequest.framework to your Embedded Binaries.
+ Wherever you want to use ThunderRequest use `import ThunderRequest`.

# Authentication Support
Support for authentication protocols such as OAuth2 is available via the `Authenticator` protocol which when set on `RequestController` will have it's delegate methods called to refresh the user's token when it either expires or a 403 is sent by the server.

When `authenticator` is set on `RequestController` any current credentials will be pulled from the user's keychain by the service identifier provided by `authIdentifier` on the protocol object.

To register a credential for the first time to the user's keychain, use the method `set(sharedRequestCredentials:savingToKeychain:)` after having set the delegate. This will store the credential to the keychain for later use by the request controller and also set the `sharedRequestCredential` property on the request controller.

If the request controller detects that the `RequestCredential` object is expired, or receives a 403 on a request it will call the method `reAuthenticate(credential:completion:)` to re-authenticate the user before then continuing to make the request (Or re-making) the request.

# Examples

All of the examples shown below are shown with all optional parameters excluded, for example the `request`, `download` and `upload` functions have multiple parameters (For things such as header overrides and base url overrides) as outlined in the generated docs.

### Initialization

```
guard let baseURL = URL(string: "https://httpbin.org/") else {
	fatalError("Unexpectedly failed to create URL")
}
let requestController = RequestController(baseURL: baseURL)
```

### GET request
```
requestController.request("get", method: .GET) { (response, error) in
	// Do something with response
}
```

### POST request
```
let body = [
	"name": "Thunder Request",
	"isAwesome": true
]
requestController.request("post", method: .POST, body: JSONRequestBody(body)) { (response, error) in
	// Do something with response
}
```

### Request bodies
The body sent to the `request` function must conform to the `RequestBody` protocol. There are multiple extensions and structs built into the project that conform to this protocol for ease of use.

#### JSONRequestBody
Formats the request as JSON, and sets the request's `Content-Type` header to `application/json`.

```
let bodyJSON = [
    "name": "Thunder Request",
    "isAwesome": true
]
let body = JSONRequestBody(bodyJSON)
```

#### PropertyListRequestBody
Similar to `JSONRequestBody` but uses the `"text/x-xml-plist"` or `"application/x-plist"` `Content-Type`.

```
let bodyPlist = [
    "name": "Thunder Request",
    "isAwesome": true
]
let body = PropertyListRequestBody(bodyPlist, format: .xml)
```

#### MultipartFormRequestBody
Formats a dictionary of objects conforming to `MultipartFormElement` to the data required for the `multipart/form-data; boundary=` `Content-Type`.

```
let multipartElements = [
    "name": "Thunder Request",
    "avatar": MultipartFormFile(
    	image: image, 
    	format: .png, 
    	fileName: "image.png", 
    	name: "image"
    )!
]
let body = MultipartFormRequestBody(
	parts: multipartElements, 
	boundary: "----SomeBoundary"
)
```

#### FormURLEncodedRequestBody
Similar to `JSONRequestBody` except uses the `"application/x-www-form-urlencoded"` `Content-Type` and formats the payload to be correct for this type of request.

```
let bodyJSON = [
    "name": "Thunder Request",
    "isAwesome": true
]
let body = FormURLEncodedRequestBody(bodyJSON)
```

#### ImageRequestBody
Converts a `UIImage` to a request payload data and `Content-Type` based on the provided format.

```
let imageBody = ImageRequestBody(image: image, format: .png)
```

#### EncodableRequestBody
Converts an object which conforms to the `Encodable` (Or `Codable`) protocol to either `JSON` or `Plist` based on the format provided upon initialisation (Defaults to `JSON`).

```
let someEncodableObject: CodableStruct = CodableStruct(
	name: "Thunder Request", 
	isAwesome: true
)
let body = EncodableRequestBody(someEncodableObject)
```

### Request Response
The request response callback sends both an `Error?` object and a `RequestResponse?` object. `RequestResponse` has helper methods for converting the response to various `Swift` types:

#### Decodable
If your object conforms to the `Decodable` (Or `Codable`) is can be decoded directly for you:

```
let codableArray: [CodableStruct]? = response.decoded()
let codableObject: CodableStruct? = response.decoded()
```

#### Dictionary
```
let dictionaryResponse = response.dictionary
```

#### Array
```
let arrayResponse = response.array
```

#### String
```
let stringResponse = response.string
let utf16Response = response.string(encoding: .utf16)
```

The `RequestResponse` object also includes the HTTP `status` as an enum, the raw `Data` from the request response, the original response (For when a request was re-directed), and the request headers (`headers`)

### Downloading
Downloading from a url is as simple as making any a request using any other HTTP method

```
let requestBaseURL = URL(string: "https://via.placeholder.com/")!        
let requestController = RequestController(baseURL: requestBaseURL)
requestController.download("500", progress: nil) { (response, url, error) in
	// Do something with the filePath that the file was downloaded to
}
```

### Uploading
Uploading is just as simple, and can be done using any of the `RequestBody` types listed above, as well as via a raw `Data` instance or from a file `URL`

```
requestController.uploadFile(fileURL, to: "post", progress: { (progress, totalBytes, uploadedBytes) in
    // Do something with progress
}) { (response, _, error) in
    // Do something with response/error
} 
```

# Code level documentation
Documentation is available for the entire library in AppleDoc format. This is available in the framework itself or in the [Hosted Version](http://3sidedcube.github.io/iOS-ThunderRequest/)

# License
See [LICENSE.md](LICENSE.md)
