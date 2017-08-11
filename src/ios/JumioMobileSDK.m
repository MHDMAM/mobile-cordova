//
//  JumioMobileSDK.h
//  Jumio Software Development GmbH
// 
//  Modified by Mhd Abdulkarim Al Midani.

#import "JumioMobileSDK.h"

@implementation JumioMobileSDK

#pragma mark - BAM

- (void)initBAM:(CDVInvokedUrlCommand*)command
{
    NSUInteger argc = [command.arguments count];
    if (argc < 3) {
        [self showSDKError: @"Missing required parameters apiToken, apiSecret or dataCenter."];
        return;
    }
    
    NSString *apiToken = [command.arguments objectAtIndex: 0];
    NSString *apiSecret = [command.arguments objectAtIndex: 1];
    NSString *dataCenterString = [command.arguments objectAtIndex: 2];
    NSString *dataCenterLowercase = [dataCenterString lowercaseString];
    JumioDataCenter dataCenter = ([dataCenterLowercase isEqualToString: @"us"]) ? JumioDataCenterUS : JumioDataCenterEU;
    
    // Initialize the SDK
    _bamConfiguration = [BAMCheckoutConfiguration new];
    _bamConfiguration.delegate = self;
    _bamConfiguration.merchantApiToken = apiToken;
    _bamConfiguration.merchantApiSecret = apiSecret;
    _bamConfiguration.dataCenter = dataCenter;
    
    // Set custom configurations
    NSDictionary *options = [command.arguments objectAtIndex: 3];
    if (![options isEqual: [NSNull null]]) {
        for (NSString *key in options) {
            if ([key isEqualToString: @"cardHolderNameRequired"]) {
                _bamConfiguration.cardHolderNameRequired = [self getBoolValue: [options objectForKey: key]];
            } else if ([key isEqualToString: @"sortCodeAndAccountNumberRequired"]) {
                _bamConfiguration.sortCodeAndAccountNumberRequired = [self getBoolValue: [options objectForKey: key]];
            } else if ([key isEqualToString: @"expiryRequired"]) {
                _bamConfiguration.expiryRequired = [self getBoolValue: [options objectForKey: key]];
            } else if ([key isEqualToString: @"cvvRequired"]) {
                _bamConfiguration.cvvRequired = [self getBoolValue: [options objectForKey: key]];
            } else if ([key isEqualToString: @"expiryEditable"]) {
                _bamConfiguration.expiryEditable = [self getBoolValue: [options objectForKey: key]];
            } else if ([key isEqualToString: @"cardHolderNameEditable"]) {
                _bamConfiguration.cardHolderNameEditable = [self getBoolValue: [options objectForKey: key]];
            } else if ([key isEqualToString: @"merchantReportingCriteria"]) {
                _bamConfiguration.merchantReportingCriteria = [options objectForKey: key];
            } else if ([key isEqualToString: @"vibrationEffectEnabled"]) {
                _bamConfiguration.vibrationEffectEnabled = [self getBoolValue: [options objectForKey: key]];
            } else if ([key isEqualToString: @"enableFlashOnScanStart"]) {
                _bamConfiguration.enableFlashOnScanStart = [self getBoolValue: [options objectForKey: key]];
            } else if ([key isEqualToString: @"cardNumberMaskingEnabled"]) {
                _bamConfiguration.cardNumberMaskingEnabled = [self getBoolValue: [options objectForKey: key]];
            } else if ([key isEqualToString: @"offlineToken"]) {
                _bamConfiguration.offlineToken = [options objectForKey: key];
            } else if ([key isEqualToString: @"cameraPosition"]) {
                NSString *cameraString = [[options objectForKey: key] lowercaseString];
                JumioCameraPosition cameraPosition = ([cameraString isEqualToString: @"front"]) ? JumioCameraPositionFront : JumioCameraPositionBack;
                _bamConfiguration.cameraPosition = cameraPosition;
            } else if ([key isEqualToString: @"cardTypes"]) {
                NSMutableArray *jsonTypes = [options objectForKey: key];
                BAMCheckoutCreditCardTypes cardTypes;
                
                int i;
                for (i = 0; i < [jsonTypes count]; i++) {
                    id type = [jsonTypes objectAtIndex: i];
                    
                    if ([[type lowercaseString] isEqualToString: @"visa"]) {
                        cardTypes = cardTypes | BAMCheckoutCreditCardTypeVisa;
                    } else if ([[type lowercaseString] isEqualToString: @"master_card"]) {
                        cardTypes = cardTypes | BAMCheckoutCreditCardTypeMasterCard;
                    } else if ([[type lowercaseString] isEqualToString: @"american_express"]) {
                        cardTypes = cardTypes | BAMCheckoutCreditCardTypeAmericanExpress;
                    } else if ([[type lowercaseString] isEqualToString: @"china_unionpay"]) {
                        cardTypes = cardTypes | BAMCheckoutCreditCardTypeChinaUnionPay;
                    } else if ([[type lowercaseString] isEqualToString: @"diners_club"]) {
                        cardTypes = cardTypes | BAMCheckoutCreditCardTypeDiners;
                    } else if ([[type lowercaseString] isEqualToString: @"discover"]) {
                        cardTypes = cardTypes | BAMCheckoutCreditCardTypeDiscover;
                    } else if ([[type lowercaseString] isEqualToString: @"jcb"]) {
                        cardTypes = cardTypes | BAMCheckoutCreditCardTypeJCB;
                    } else if ([[type lowercaseString] isEqualToString: @"starbucks"]) {
                        cardTypes = cardTypes | BAMCheckoutCreditCardTypeStarbucks;
                    }
                }
                
                _bamConfiguration.supportedCreditCardTypes = cardTypes;
            }
        }
    }
    
    self.bamViewController = [[BAMCheckoutViewController alloc] initWithConfiguration: _bamConfiguration];
}

- (void)startBAM:(CDVInvokedUrlCommand*)command
{
    if (self.bamViewController == nil) {
        [self showSDKError: @"The BAM SDK is not initialized yet. Call initBAM() first."];
        return;
    }
    
    self.callbackId = command.callbackId;
    //
    UIButton *overlay = [UIButton buttonWithType:UIButtonTypeCustom];
    overlay.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern-card.png"]];
    overlay.frame = CGRectMake(1, 44, self.bamViewController.view.frame.size.width, self.bamViewController.view.frame.size.height);
    
    UIButton *overlaybottom = [UIButton buttonWithType:UIButtonTypeCustom];
    overlaybottom.backgroundColor = [UIColor blackColor];
    overlaybottom.frame = CGRectMake(0, 570, self.bamViewController.view.frame.size.width, 55);
    
    [self.bamViewController.view addSubview:overlaybottom];
    [self.bamViewController.view addSubview:overlay];
    
    self.bamViewController.view.superview.bounds = CGRectMake(0, 0, 100, 100);
    //
    [self.viewController presentViewController: self.bamViewController animated: YES completion: nil];
}

#pragma mark - BAM Delegates

- (void) bamCheckoutViewController:(BAMCheckoutViewController *)controller didFinishScanWithCardInformation:(BAMCheckoutCardInformation *)cardInformation scanReference:(NSString *)scanReference {
    // Build Result Object
    NSDictionary *result = [[NSMutableDictionary alloc] init];
    
    if (cardInformation.cardType == BAMCheckoutCreditCardTypeVisa) {
        [result setValue: @"VISA" forKey: @"cardType"];
    } else if (cardInformation.cardType == BAMCheckoutCreditCardTypeMasterCard) {
        [result setValue: @"MASTER_CARD" forKey: @"cardType"];
    } else if (cardInformation.cardType == BAMCheckoutCreditCardTypeAmericanExpress) {
        [result setValue: @"AMERICAN_EXPRESS" forKey: @"cardType"];
    } else if (cardInformation.cardType == BAMCheckoutCreditCardTypeChinaUnionPay) {
        [result setValue: @"CHINA_UNIONPAY" forKey: @"cardType"];
    } else if (cardInformation.cardType == BAMCheckoutCreditCardTypeDiners) {
        [result setValue: @"DINERS_CLUB" forKey: @"cardType"];
    } else if (cardInformation.cardType == BAMCheckoutCreditCardTypeDiscover) {
        [result setValue: @"DISCOVER" forKey: @"cardType"];
    } else if (cardInformation.cardType == BAMCheckoutCreditCardTypeJCB) {
        [result setValue: @"JCB" forKey: @"cardType"];
    } else if (cardInformation.cardType == BAMCheckoutCreditCardTypeStarbucks) {
        [result setValue: @"STARBUCKS" forKey: @"cardType"];
    }
    
    [result setValue: cardInformation.cardNumber forKey: @"cardNumber"];
    [result setValue: cardInformation.cardNumberGrouped forKey: @"cardNumberGrouped"];
    [result setValue: cardInformation.cardNumberMasked forKey: @"cardNumberMasked"];
    [result setValue: cardInformation.cardExpiryMonth forKey: @"cardExpiryMonth"];
    [result setValue: cardInformation.cardExpiryYear forKey: @"cardExpiryYear"];
    [result setValue: cardInformation.cardExpiryDate forKey: @"cardExpiryDate"];
    [result setValue: cardInformation.cardCVV forKey: @"cardCVV"];
    [result setValue: cardInformation.cardHolderName forKey: @"cardHolderName"];
    [result setValue: cardInformation.cardSortCode forKey: @"cardSortCode"];
    [result setValue: cardInformation.cardAccountNumber forKey: @"cardAccountNumber"];
    [result setValue: [NSNumber numberWithBool: cardInformation.cardSortCodeValid] forKey: @"cardSortCodeValid"];
    [result setValue: [NSNumber numberWithBool: cardInformation.cardAccountNumberValid] forKey: @"cardAccountNumberValid"];
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsDictionary: result];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}

- (void) bamCheckoutViewController:(BAMCheckoutViewController *)controller didCancelWithError:(NSError *)error scanReference:(NSString *)scanReference {
    NSString *msg = [NSString stringWithFormat: @"Cancelled with error code %ld: %@", (long)error.code, error.localizedDescription];
    [self showSDKError: msg];
}

#pragma mark - Helper methods

- (void)showSDKError:(NSString *)msg {
    NSLog(@"%@", msg);
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString: msg];
    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.callbackId];
    [self.viewController dismissViewControllerAnimated: YES completion: nil];
}

- (BOOL) getBoolValue:(NSObject *)value {
    if (value && [value isKindOfClass: [NSNumber class]]) {
        return [((NSNumber *)value) boolValue];
    }
    return value;
}

@end
