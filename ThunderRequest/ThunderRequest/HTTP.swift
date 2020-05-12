//
//  HTTP.swift
//  ThunderRequest
//
//  Created by Simon Mitchell on 11/12/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

/// A protocol which can be conformed to in order to send any object as a HTTP request
public protocol RequestBody {
    
    /// Returns the content type that should be used in the headers for a request of this type
    var contentType: String? { get }
    
    /// Returns the data payload that should be sent with the `URLRequest`
    ///
    /// - Returns: Data to be sent with the request. If nil, the request will error!
    func payload() -> Data?
    
    /// A function to allow this request body to mutate the url that is being sent with the request
    ///
    /// - Parameter url: The url which can be mutated
    func mutate(url: inout URL)
}

public extension RequestBody {
    
    func mutate(url: inout URL) {
        
    }
}

public struct HTTP {
    /// Enum representing HTTP Methods
    ///
    /// - CONNECT: The CONNECT method establishes a tunnel to the server identified by the target resource.
    /// - DELETE: The DELETE method deletes the specified resource.
    /// - GET: The GET method requests a representation of the specified resource. Requests using GET should only retrieve data.
    /// - HEAD: The HEAD method asks for a response identical to that of a GET request, but without the response body.
    /// - OPTIONS: The OPTIONS method is used to describe the communication options for the target resource.
    /// - PATCH: The PATCH method is used to apply partial modifications to a resource.
    /// - POST: The POST method is used to submit an entity to the specified resource, often causing a change in state or side effects on the server.
    /// - PUT: The PUT method replaces all current representations of the target resource with the request payload.
    /// - TRACE: The TRACE method performs a message loop-back test along the path to the target resource.
    public enum Method: String {
        case CONNECT
        case DELETE
        case GET
        case HEAD
        case OPTIONS
        case PATCH
        case POST
        case PUT
        case TRACE
    }
    
    /// HTTP status codes as defined by the IETF RFCs and other commonly used codes in popular server implementations.
    ///
    /// - `continue`: The server has received the request headers and the client should proceed to send the request body (in the case of a request for which a body needs to be sent; for example, a POST request).
    /// - switchingProtocols: The requester has asked the server to switch protocols and the server has agreed to do so.
    /// - processing: A WebDAV request may contain many sub-requests involving file operations, requiring a long time to complete the request. This code indicates that the server has received and is processing the request, but no response is available yet. This prevents the client from timing out and assuming the request was lost.
    /// - earlyHints: Used to return some response headers before final HTTP message.
    /// - ok: Standard response for successful HTTP requests. The actual response will depend on the request method used. In a GET request, the response will contain an entity corresponding to the requested resource. In a POST request, the response will contain an entity describing or containing the result of the action.
    /// - created: The request has been fulfilled, resulting in the creation of a new resource.
    /// - accepted: The request has been accepted for processing, but the processing has not been completed. The request might or might not be eventually acted upon, and may be disallowed when processing occurs.
    /// - nonAuthoritativeInfo: The server is a transforming proxy (e.g. a Web accelerator) that received a 200 OK from its origin, but is returning a modified version of the origin's response.
    /// - noContent: The server successfully processed the request and is not returning any content.
    /// - resetContent: The server successfully processed the request, but is not returning any content. Unlike a 204 response, this response requires that the requester reset the document view.
    /// - partialContent: The server is delivering only part of the resource (byte serving) due to a range header sent by the client. The range header is used by HTTP clients to enable resuming of interrupted downloads, or split a download into multiple simultaneous streams.
    /// - multiStatus: The message body that follows is by default an XML message and can contain a number of separate response codes, depending on how many sub-requests were made.
    /// - alreadyReported: The members of a DAV binding have already been enumerated in a preceding part of the (multistatus) response, and are not being included again.
    /// - thisIsFine: (Apache Web Server) Used as a catch-all error condition for allowing response bodies to flow through Apache when ProxyErrorOverride is enabled. When ProxyErrorOverride is enabled in Apache, response bodies that contain a status code of 4xx or 5xx are automatically discarded by Apache in favor of a generic response or a custom response specified by the ErrorDocument directive.
    /// - pageExpired: (Laravel Framework) Used by the Laravel Framework when a CSRF Token is missing or expired.
    /// - methodFailure: (Spring Framework) A deprecated response used by the Spring Framework when a method has failed.
    /// - imUsed: The server has fulfilled a request for the resource, and the response is a representation of the result of one or more instance-manipulations applied to the current instance.
    /// - multipleChoices: Indicates multiple options for the resource from which the client may choose (via agent-driven content negotiation). For example, this code could be used to present multiple video format options, to list files with different filename extensions, or to suggest word-sense disambiguation.
    /// - movedPermanently: This and all future requests should be directed to the given URI.
    /// - found: Tells the client to look at (browse to) another url.
    /// - seeOther: The response to the request can be found under another URI using the GET method. When received in response to a POST (or PUT/DELETE), the client should presume that the server has received the data and should issue a new GET request to the given URI.
    /// - notModified: Indicates that the resource has not been modified since the version specified by the request headers If-Modified-Since or If-None-Match. In such case, there is no need to retransmit the resource since the client still has a previously-downloaded copy.
    /// - useProxy: The requested resource is available only through a proxy, the address for which is provided in the response. Many HTTP clients (such as Mozilla[27] and Internet Explorer) do not correctly handle responses with this status code, primarily for security reasons.
    /// - switchProxy: No longer used. Originally meant "Subsequent requests should use the specified proxy."
    /// - temporaryRedirect: In this case, the request should be repeated with another URI; however, future requests should still use the original URI. In contrast to how 302 was historically implemented, the request method is not allowed to be changed when reissuing the original request. For example, a POST request should be repeated using another POST request.
    /// - permanentRedirect: The request and all future requests should be repeated using another URI. 307 and 308 parallel the behaviors of 302 and 301, but do not allow the HTTP method to change. So, for example, submitting a form to a permanently redirected resource may continue smoothly.
    /// - badRequest: The server cannot or will not process the request due to an apparent client error (e.g., malformed request syntax, size too large, invalid request message framing, or deceptive request routing).
    /// - unauthorized: Similar to 403 Forbidden, but specifically for use when authentication is required and has failed or has not yet been provided. The response must include a WWW-Authenticate header field containing a challenge applicable to the requested resource. See Basic access authentication and Digest access authentication.[34] 401 semantically means "unauthenticated",[35] i.e. the user does not have the necessary credentials.
    /// Note: Some sites incorrectly issue HTTP 401 when an IP address is banned from the website (usually the website domain) and that specific address is refused permission to access a website.
    /// - paymentRequired: Reserved for future use. The original intention was that this code might be used as part of some form of digital cash or micropayment scheme, as proposed for example by GNU Taler, but that has not yet happened, and this code is not usually used. Google Developers API uses this status if a particular developer has exceeded the daily limit on requests. Sipgate uses this code if an account does not have sufficient funds to start a call.[38] Shopify uses this code when the store has not paid their fees and is temporarily disabled.
    /// - forbidden: The request was valid, but the server is refusing action. The user might not have the necessary permissions for a resource, or may need an account of some sort.
    /// - notFound: The requested resource could not be found but may be available in the future. Subsequent requests by the client are permissible.
    /// - methodNotAllowed: A request method is not supported for the requested resource; for example, a GET request on a form that requires data to be presented via POST, or a PUT request on a read-only resource.
    /// - notAcceptable: The requested resource is capable of generating only content not acceptable according to the Accept headers sent in the request. See Content negotiation.
    /// - proxyAuthenticationRequired: The client must first authenticate itself with the proxy.
    /// - requestTimeout: The server timed out waiting for the request. According to HTTP specifications: "The client did not produce a request within the time that the server was prepared to wait. The client MAY repeat the request without modifications at any later time."
    /// - conflict: Indicates that the request could not be processed because of conflict in the current state of the resource, such as an edit conflict between multiple simultaneous updates.
    /// - gone: Indicates that the resource requested is no longer available and will not be available again. This should be used when a resource has been intentionally removed and the resource should be purged. Upon receiving a 410 status code, the client should not request the resource in the future. Clients such as search engines should remove the resource from their indices. Most use cases do not require clients and search engines to purge the resource, and a "404 Not Found" may be used instead.
    /// - lengthRequired: The request did not specify the length of its content, which is required by the requested resource.
    /// - preconditionFailed: The server does not meet one of the preconditions that the requester put on the request.
    /// - payloadTooLarge: The request is larger than the server is willing or able to process. Previously called "Request Entity Too Large".
    /// - uriTooLong: The URI provided was too long for the server to process. Often the result of too much data being encoded as a query-string of a GET request, in which case it should be converted to a POST request. Called "Request-URI Too Long" previously.
    /// - unsupportedMediaType: The request entity has a media type which the server or resource does not support. For example, the client uploads an image as image/svg+xml, but the server requires that images use a different format.
    /// - rangeNotSatisfiable: The client has asked for a portion of the file (byte serving), but the server cannot supply that portion. For example, if the client asked for a part of the file that lies beyond the end of the file. Called "Requested Range Not Satisfiable" previously.
    /// - expectationFailed: The server cannot meet the requirements of the Expect request-header field.
    /// - imATeapot: This code was defined in 1998 as one of the traditional IETF April Fools' jokes, in RFC 2324, Hyper Text Coffee Pot Control Protocol, and is not expected to be implemented by actual HTTP servers. The RFC specifies this code should be returned by teapots requested to brew coffee. This HTTP status is used as an Easter egg in some websites, including Google.com.
    /// - misdirectedRequest: The request was directed at a server that is not able to produce a response (for example because of connection reuse).
    /// - unprocessableIdentity: The request was well-formed but was unable to be followed due to semantic errors.
    /// - locked: The resource that is being accessed is locked.
    /// - failedDependency: The request failed because it depended on another request and that request failed (e.g., a PROPPATCH).
    /// - upgradeRequired: The client should switch to a different protocol such as TLS/1.0, given in the Upgrade header field.
    /// - preconditionRequired: The origin server requires the request to be conditional. Intended to prevent the 'lost update' problem, where a client GETs a resource's state, modifies it, and PUTs it back to the server, when meanwhile a third party has modified the state on the server, leading to a conflict."
    /// - tooManyRequests: The user has sent too many requests in a given amount of time. Intended for use with rate-limiting schemes.
    /// - requestHeaderFieldsTooLarge: The server is unwilling to process the request because either an individual header field, or all the header fields collectively, are too large.
    /// - loginTimeout: (Internet Information Services) The client's session has expired and must log in again.
    /// - noResponse: (nginx) Used internally to instruct the server to return no information to the client and close the connection immediately.
    /// - retryWith: (Internet Information Services) The server cannot honour the request because the user has not provided the required information.
    /// - blockedByWindowsParentalControls: (Microsoft) The Microsoft extension code indicated when Windows Parental Controls are turned on and are blocking access to the requested webpage.
    /// - unavailableForLegalReasons: A server operator has received a legal demand to deny access to a resource or to a set of resources that includes the requested resource. The code 451 was chosen as a reference to the novel Fahrenheit 451 (see the Acknowledgements in the RFC).
    /// - requestHeaderTooLarge: (nginx) Client sent too large request or too long header line.
    /// - sslCertificateError: (nginx) An expansion of the 400 Bad Request response code, used when the client has provided an invalid client certificate.
    /// - sslCertificateRequired: (nginx) An expansion of the 400 Bad Request response code, used when a client certificate is required but not provided.
    /// - httpRequestSentToHttpsPort: (nginx) An expansion of the 400 Bad Request response code, used when the client has made a HTTP request to a port listening for HTTPS requests.
    /// - invalidToken: (Esri) Returned by ArcGIS for Server. Code 498 indicates an expired or otherwise invalid token.
    /// - tokenRequired: (Esri) Returned by ArcGIS for Server. Code 499 indicates that a token is required but was not submitted.
    /// - internalServerError: A generic error message, given when an unexpected condition was encountered and no more specific message is suitable.
    /// - notImplemented: The server either does not recognize the request method, or it lacks the ability to fulfil the request. Usually this implies future availability (e.g., a new feature of a web-service API).
    /// - badGateway: The server was acting as a gateway or proxy and received an invalid response from the upstream server.
    /// - serviceUnavailable: The server is currently unavailable (because it is overloaded or down for maintenance). Generally, this is a temporary state.
    /// - gatewayTimeout: The server was acting as a gateway or proxy and did not receive a timely response from the upstream server.
    /// - httpVersionNotSupported: The server does not support the HTTP protocol version used in the request.
    /// - variantAlsoNegotiates: Transparent content negotiation for the request results in a circular reference.
    /// - insufficientStorage: The server is unable to store the representation needed to complete the request.
    /// - loopDetected: The server detected an infinite loop while processing the request (sent in lieu of 208 Already Reported).
    /// - bandwidthLimitExceeded: (Apache Web Server / cPanel) The server has exceeded the bandwidth specified by the server administrator; this is often used by shared hosting providers to limit the bandwidth of customers.
    /// - notExtended: Further extensions to the request are required for the server to fulfil it.
    /// - networkAuthenticationRequired: The client needs to authenticate to gain network access. Intended for use by intercepting proxies used to control access to the network (e.g., "captive portals" used to require agreement to Terms of Service before granting full Internet access via a Wi-Fi hotspot).
    /// - unknownError: (Cloudflate) The 520 error is used as a "catch-all response for when the origin server returns something unexpected", listing connection resets, large headers, and empty or invalid responses as common triggers.
    /// - webServerIsDown: (Cloudflare) The origin server has refused the connection from Cloudflare.
    /// - connectionTimedOut: (Cloudflare) Cloudflare could not negotiate a TCP handshake with the origin server.
    /// - originIsUnreachable: (Cloudflare) Cloudflare could not reach the origin server; for example, if the DNS records for the origin server are incorrect.
    /// - timeoutOccured: (Cloudflare) Cloudflare was able to complete a TCP connection to the origin server, but did not receive a timely HTTP response.
    /// - sslHandshakeFailed: (Cloudflare) Cloudflare could not negotiate a SSL/TLS handshake with the origin server.
    /// - invalidSSLCertificate: (Cloudflare) Cloudflare could not validate the SSL certificate on the origin web server.
    /// - railgunError: (Cloudflare) Error 527 indicates that the request timed out or failed after the WAN connection had been established.
    /// - originDNSError: (Cloudflare) Error 530 indicates that the requested host name could not be resolved on the Cloudflare network to an origin server.
    /// - networkReadTimeoutError: Used by some HTTP proxies to signal a network read timeout behind the proxy to a client in front of the proxy.
    public enum StatusCode: Int {
        case `continue` = 100
        case switchingProtocols
        case processing
        case earlyHints
        case okay = 200
        case created
        case accepted
        case nonAuthoritativeInfo
        case noContent
        case resetContent
        case partialContent
        case multiStatus
        case alreadyReported
        case thisIsFine = 218
        case pageExpired
        case methodFailure
        case imUsed = 226
        case multipleChoices = 300
        case movedPermanently
        case found
        case seeOther
        case notModified
        case useProxy
        case switchProxy
        case temporaryRedirect
        case permanentRedirect
        case badRequest = 400
        case unauthorized
        case paymentRequired
        case forbidden
        case notFound
        case methodNotAllowed
        case notAcceptable
        case proxyAuthenticationRequired
        case requestTimeout
        case conflict
        case gone
        case lengthRequired
        case preconditionFailed
        case payloadTooLarge
        case uriTooLong
        case unsupportedMediaType
        case rangeNotSatisfiable
        case expectationFailed
        case imATeapot
        case misdirectedRequest = 421
        case unprocessableIdentity
        case locked
        case failedDependency
        case upgradeRequired = 426
        case preconditionRequired = 428
        case tooManyRequests
        case requestHeaderFieldsTooLarge = 431
        case loginTimeout = 440
        case noResponse = 444
        case retryWith = 449
        case blockedByWindowsParentalControls = 450
        case unavailableForLegalReasons
        case requestHeaderTooLarge = 494
        case sslCertificateError
        case sslCertificateRequired
        case httpRequestSentToHttpsPort
        case invalidToken
        case tokenRequired
        case internalServerError
        case notImplemented
        case badGateway
        case serviceUnavailable
        case gatewayTimeout
        case httpVersionNotSupported
        case variantAlsoNegotiates
        case insufficientStorage
        case loopDetected
        case bandwidthLimitExceeded
        case notExtended
        case networkAuthenticationRequired
        case unknownError = 520
        case webServerIsDown
        case connectionTimedOut
        case originIsUnreachable
        case timeoutOccured
        case sslHandshakeFailed
        case invalidSSLCertificate
        case railgunError
        case originDNSError = 530
        case networkReadTimeoutError = 598
        
        public var isConsideredError: Bool {
            return rawValue >= 400 && rawValue < 600
        }
        
        public var localizedDescription: String {
            return HTTPURLResponse.localizedString(forStatusCode: rawValue)
        }
    }
}
