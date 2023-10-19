#import <Cordova/CDVPlugin.h>

@interface DdKeyStore : CDVPlugin

  -(void)createKeyPair:(CDVInvokedUrlCommand*)command;
  -(void)sign:(CDVInvokedUrlCommand*)command;

@end
