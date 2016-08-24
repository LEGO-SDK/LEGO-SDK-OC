# LEGO-SDK-OC
LEGO SDK improves UIWebView &amp; WKWebView features. It's light-weight and easy to use.

## Introduce

LEGO SDK includes JavascriptBridge and Modules(APIs).

JavascriptBridge provides an universal pipe connects WebView and Native.

Modules provides some feature which is necessary for developer.

### WebApp

You may use SDK for WebApp. It's a good choice to replace Cordavor.

### Improve WebView

You may use SDK for WebView Plugin, No need to develop your own protocol.

## Protocols

SDK use these classes for pipe.

* LGOModule  - Receive request and build LGORequestable.
* LGORequestable - Operate request and response result.
* LGORequest - Saving request params from JSON, built via LGOModule.
* LGOResponse - Saving response result, and translate to JSON data to WebView.

## Usage (Javascript)

Add above code before you use SDK.

```javascript
window.JSBridge && eval(window.JSBridge.bridgeScript())
``` 

Try to request device information, may use above code.

```javascript
JSMessage.newMessage("Native.Device").call(function(err, result){console.log(result);})
```

And then console log these things.

```
Object
application: {shortVersion: "1.0", buildNumber: 0, name: "Sample", bundleIdentifier: "com.legosdk.Sample"}
custom: {}
device: {osName: "iPhone OS", osVersion: "9.3.4", model: "iPhone", IDFV: "093B2097-1F92-464D-B1BB-232266403FB8", screenWidth: 414, …}
network: {usingWIFI: true, cellularType: 4}
```

## Intergrade

We recommend use CocoaPods.

### All

If you wonder install all modules. Just add following code to Podfile.

pod 'LEGO-SDK'

### Core only

If you just wondering JavascriptBridge, no needs modules. Add following code to Podfile.

pod 'LEGO-SDK/Core'

### AutoInject

AutoInject will inject JavascriptBridge to UIWebView & WKWebView automatically. Add following code to Podfile enable it.

pod 'LEGO-SDK/AutoInject'

### Install module stand alone

You may install module stand alone. Just like this.

pod 'LEGO-SDK/API/Native/Device'
