#import "Keystore.h"
#import <Cordova/CDVPlugin.h>

@implementation Keystore

- (void)createKeyPair:(CDVInvokedUrlCommand*)command {
  CDVPluginResult* pluginResult = nil;
  NSString* echo = [command.arguments objectAtIndex:0];
  if (echo != nil && [echo length] > 0) {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:echo];
  } else {
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
  }
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sign:(CDVInvokedUrlCommand*)command {
}

- (void)verify:(CDVInvokedUrlCommand*)command {
}

@end
