//
//  JumioMobileSDK.h
//  Jumio Software Development GmbH
// 
//  Modified by Mhd Abdulkarim Al Midani.

#import "Cordova/CDVPlugin.h"
@import BAMCheckout;

@interface JumioMobileSDK : CDVPlugin <BAMCheckoutViewControllerDelegate>

@property (strong) BAMCheckoutViewController* bamViewController;
@property (strong) BAMCheckoutConfiguration* bamConfiguration;
@property (strong) NSString* callbackId;

@end
