#import "Keystore.h"
#import <Cordova/CDVPlugin.h>

@implementation Keystore

// Unfortunately we cannot store the key inside the iOS Secure Enclave because it support only
// storing NIST P-256 elliptic curve keys and we are using RSA 2048 keys.

- (void)createKeyPair:(CDVInvokedUrlCommand*)command {
  NSString* alias = [command.arguments objectAtIndex:0];
  NSData* tag = [alias dataUsingEncoding:NSUTF8StringEncoding];
  // delete any existing key pair with the same tag name
  NSDictionary *deleteQuery = @{
    (id)kSecClass: (id)kSecClassKey,
    (id)kSecAttrApplicationTag: tag,
    (id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA
  };
  SecItemDelete((__bridge CFDictionaryRef)deleteQuery);
  // create a new key pair
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
    NSString *message = [NSString stringWithFormat:@"Cannot generate key pair: %@", [err localizedDescription]];
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
  NSString* tagString = [command.arguments objectAtIndex:0];
  NSString* dataString = [command.arguments objectAtIndex:1];
  NSData* tag = [tagString dataUsingEncoding:NSUTF8StringEncoding];
  NSData* data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *getquery = @{
    (id)kSecClass: (id)kSecClassKey,
    (id)kSecAttrApplicationTag: tag,
    (id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
    (id)kSecReturnRef: @YES,
  };
  SecKeyRef key = NULL;
  OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)getquery, (CFTypeRef *)&key);
  CDVPluginResult* pluginResult = nil;
  if (status != errSecSuccess)
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot retrieve key"];
  else {
    SecKeyAlgorithm algorithm = kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA256;
    NSData *signature = nil;
    CFErrorRef error = NULL;
    signature = (NSData*)CFBridgingRelease(SecKeyCreateSignature(key, algorithm, (__bridge CFDataRef)data, &error));
    if (!signature) {
      NSError *err = CFBridgingRelease(error);
      NSString *message = [NSString stringWithFormat:@"Cannot sign message: %@", [err localizedDescription]];
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    } else {
      NSString *base64Encoded = [signature base64EncodedStringWithOptions:0];
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:base64Encoded];
    }
  }
  if (key)
    CFRelease(key);
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)verify:(CDVInvokedUrlCommand*)command {
  NSString* tagString = [command.arguments objectAtIndex:0];
  NSString* messageString = [command.arguments objectAtIndex:1];
  NSString* signatureString = [command.arguments objectAtIndex:2];
  NSData* tag = [tagString dataUsingEncoding:NSUTF8StringEncoding];
  NSData* message = [messageString dataUsingEncoding:NSUTF8StringEncoding];
  NSData* signature = [signatureString dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *getquery = @{
    (id)kSecClass: (id)kSecClassKey,
    (id)kSecAttrApplicationTag: tag,
    (id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
    (id)kSecReturnRef: @YES,
  };
  SecKeyRef key = NULL;
  OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)getquery, (CFTypeRef *)&key);
  CDVPluginResult* pluginResult = nil;
  if (status != errSecSuccess)
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot retrieve key"];
  else {
    SecKeyRef publicKey = SecKeyCopyPublicKey(key);
    CFErrorRef error = NULL;
    SecKeyAlgorithm algorithm = kSecKeyAlgorithmRSASignatureMessagePKCS1v15SHA256;
    BOOL result = NO;
    result = SecKeyVerifySignature(publicKey, algorithm, (__bridge CFDataRef)message, (__bridge CFDataRef)signature, &error);
    if (!result) {
      NSError *err = CFBridgingRelease(error);
      if (err) {
        NSString *message = [NSString stringWithFormat:@"Cannot verify signature: %@", [err localizedDescription]];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
      } else
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
    } else
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:1];
  }
  if (key)
    CFRelease(key);
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
