# Plugin for Apache Cordova

Official Jumio Mobile SDK plugin for Apache Cordova

**Note: Modified to meet ours project requirements** by [MAM](https://github.com/MHDMAM)

## Compatibility
With every release, we only ensure compatibility with the latest version of Cordova.

## Setup

Create Cordova project and add our plugin
```
cordova create MyProject com.my.project "MyProject"
cd MyProject
cordova platform add ios
cordova platform add android
cordova plugin add https://github.com/MHDMAM/mobile-cordova.git
```

## Integration

### iOS

Manual integration or dependency management via cocoapods possible, please see [the official documentation of the Jumio Mobile SDK for iOS](https://github.com/Jumio/mobile-sdk-ios/tree/v2.7.0#basic-setup)

### Android

Add the Jumio repository:

```
repositories {
    maven { url 'http://mobile-sdk.jumio.com' }
}
```

Add a parameter for your SDK_VERSION into the ext-section:

```
ext {
    SDK_VERSION = "2.7.0"
}
```

Add required permissions for the products as described in chapter [Permissions](https://github.com/Jumio/mobile-sdk-android/blob/v2.7.0/README.md#dependencies)

Open the android project of your cordova project located in */platforms/android* and insert the dependencies from the products you require to your **build.gradle** file. (Module: android)

* [BAM Checkout](https://github.com/Jumio/mobile-sdk-android/blob/v2.7.0/docs/integration_bam-checkout.md#dependencies)

## Usage

### BAM Checkout

To Initialize the SDK, perform the following call.

```javascript
Jumio.initBAM(<API_TOKEN>, <API_SECRET>, <DATACENTER>, {configuration});
```

Datacenter can either be **US** or **EU**.



Configure the SDK with the *configuration*-Object.

| Configuration | Datatype | Description |
| ------ | -------- | ----------- |
| cardHolderNameRequired | Boolean |
| sortCodeAndAccountNumberRequired | Boolean |
| expiryRequired | Boolean |
| cvvRequired | Boolean |
| expiryEditable | Boolean |
| cardHolderNameEditable | Boolean |
| merchantReportingCriteria | String | Overwrite your specified reporting criteria to identify each scan attempt in your reports (max. 100 characters)
| vibrationEffectEnabled | Boolean |
| enableFlashOnScanStart | Boolean |
| cardNumberMaskingEnabled | Boolean |
| offlineToken *(iOS only)* | String | In your Jumio merchant backend on the "Settings" page under "API credentials" you can find your Offline token. In case you use your offline token, you must not set the API token and secret|
| cameraPosition | String | Which camera is used by default. Can be **FRONT** or **BACK**. |
| cardTypes | String-Array | An array of accepted card types. Available card types: **VISA**, **MASTER_CARD**, **AMERICAN_EXPRESS**, **CHINA_UNIONPAY**, **DINERS_CLUB**, **DISCOVER**, **JCB**, **STARBUCKS** |

Initialization example with configuration.

```javascript
Jumio.initBAM("API_TOKEN", "API_SECRET", "US", {
    cardHolderNameRequired: false,
    cvvRequired: true,
    cameraPosition: "BACK",
    cardTypes: ["VISA", "MASTER_CARD"]
});
```


As soon as the sdk is initialized, the sdk is started by the following call.

```javascript
Jumio.startBAM(successCallback, errorCallback);
```

Example

```javascript
Jumio.startBAM(function(cardInformation) {
    // YOUR CODE
}, function(error) {
    // YOUR CODE
});
```
## Callback

### BAM Checkout

*BAMCardInformation*

|Parameter | Type | Max. length | Description |
|:---------------------------- 	|:-------------|:-----------------|:-------------|
| cardType | String |  16| VISA, MASTER_CARD, AMERICAN_EXPRESS, CHINA_UNIONPAY, DINERS_CLUB, DISCOVER, JCB or STARBUCKS |
| cardNumber | String | 16 | Full credit card number |
| cardNumberGrouped | String | 19 | Grouped credit card number |
| cardNumberMasked | String | 19 | First 6 and last 4 digits of the grouped credit card number, other digits are masked with "X" |
| cardExpiryMonth | String | 2 | Month card expires if enabled and readable |
| CardExpiryYear | String | 2 | Year card expires if enabled and readable |
| cardExpiryDate | String | 5 | Date card expires in the format MM/yy if enabled and readable |
| cardCVV | String | 4 | Entered CVV if enabled |
| cardHolderName | String | 100 | Name of the card holder in capital letters if enabled and readable, or as entered if editable |
| cardSortCode | String | 8 | Sort code in the format xx-xx-xx or xxxxxx if enabled, available and readable |
| cardAccountNumber | String | 8 | Account number if enabled, available and readable |
| cardSortCodeValid | BOOL |  | True if sort code valid, otherwise false |
| cardAccountNumberValid | BOOL |  | True if account number code valid, otherwise false |

# Copyright

© Jumio Corp. 268 Lambert Avenue, Palo Alto, CA 94306
