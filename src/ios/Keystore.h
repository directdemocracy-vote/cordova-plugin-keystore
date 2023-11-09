#import <Cordova/CDVPlugin.h>

@interface Keystore : CDVPlugin

-(void)createKeyPair:(CDVInvokedUrlCommand*)command;
-(void)sign:(CDVInvokedUrlCommand*)command;
-(void)verify:(CDVInvokedUrlCommand*)command;

@end
