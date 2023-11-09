#import "Keystore.h"
#import <Cordova/CDVPlugin.h>

@implementation Keystore

- (void)createKeyPair:(CDVInvokedUrlCommand*)command {
  NSString* alias = [command.arguments objectAtIndex:0];
  NSData* tag = [alias dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary* attributes = @{
    (id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
    (id)kSecAttrKeySizeInBits: @2048,
    (id)kSecPrivateKeyAttrs: @{(id)kSecAttrIsPermanent: @YES, (id)kSecAttrApplicationTag: tag}
  };
  CDVPluginResult* pluginResult = nil;
  CFErrorRef error = NULL;
  SecKeyRef privateKey = SecKeyCreateRandomKey((__bridge CFDictionaryRef)attributes, &error);
  if (!privateKey) {
    NSError *err = CFBridgingRelease(error);
    NSString *message = [NSString stringWithFormat:@"Cannot generate key pair: @", [err localizedDescription]];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
  } else {
    SecKeyRef publicKey = SecKeyCopyPublicKey(privateKey);
    if (!publicKey)
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot export public key"];
    else {
      NSData* keyData = (NSData*)CFBridgingRelease(SecKeyCopyExternalRepresentation(publicKey, &error));
      if (!keyData)
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Failed to export public key"];
      else {
        NSString *pem = [keyData base64EncodedStringWithOptions:0];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:pem];
      }
    }
    CFRelease(privateKey);
  }
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)sign:(CDVInvokedUrlCommand*)command {
}

- (void)verify:(CDVInvokedUrlCommand*)command {
}

@end
