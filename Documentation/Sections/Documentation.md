<p align="center">
<img src="img/logo.png" width="250">
</p>

# Gini Capture SDK for iOS

[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg)]()
[![Devices](https://img.shields.io/badge/devices-iPhone%20%7C%20iPad-blue.svg)]()
[![Swift version](https://img.shields.io/badge/swift-5.0-orange.svg)]()

**Deprecation Notice**
 ----------------------

Development of the Gini Capture SDK for iOS will be continued in 
[new repository for Gini Capture SDK](https://github.com/gini/capture-sdk-ios) and
[new repository for Gini Capture SDK Pinning](https://github.com/gini/capture-sdk-pinning-ios).

No new versions will be released using CocoaPods. We kindly ask you to update to the [version](https://github.com/gini/gini-mobile-ios/releases/tag/GiniCaptureSDK%3B1.1.0) available as a swift package.

A few breaking changes were necessary, but these are easy to fix. You can find the steps in this 
[migration guide](https://developer.gini.net/gini-mobile-ios/GiniCaptureSDK/migration-guide.html).

 ## Introduction

The Gini Capture SDK provides components for capturing, reviewing and analyzing photos of invoices and remittance slips.

By integrating this SDK into your application you can allow your users to easily take a picture of a document, review it and getting analysis results from the Gini backend.

The Gini Capture SDK can be integrated in two ways, either by using the *Screen API* or the *Component API*. In the Screen API we provide pre-defined screens that can be customized in a limited way. The screen and configuration design is based on our long-lasting experience with integration in customer apps. In the Component API, we provide independent views so you can design your own application as you wish. We strongly recommend keeping in mind our UI/UX guidelines, however.

On *iPhone*, the Gini Capture SDK has been designed for portrait orientation. In the Screen API, orientation is automatically forced to portrait when being displayed. In case you use the Component API, you should limit the view controllers orientation hosting the Component API's views to portrait orientation. This is specifically true for the camera view.

## Contents

* [Installation](installation.html)
* [Integration](integration.html)
* [Integration in a Xamarin Project](integration-in-a-xamarin-project.html)
* [Changelog](changelog.html)
* [License](license.html)
* Guides
  - [Customization guide](customization-guide.html)
  - [Import PDFs and Images guide](import-pdfs-and-images-guide.html)
  - [Open with guide](open-with-guide.html)
  - [QR Code scanning guide](qr-code-scanning-guide.html)
  - [Event tracking guide](event-tracking-guide.html)
  - [Error logging guide](error-logging-guide.html)

## API

* [Classes](Classes.html)
* [Enums](Enums.html)
* [Protocols](Protocols.html)
* [Typealiases](Typealiases.html)
