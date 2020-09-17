//
//  TestPlugin.h
//  testCordova
//
//  Created by Administrator on 16/9/20.
//
//

#import <Cordova/CDVPlugin.h>
#import "QPOSService.h"
#import "BTDeviceFinder.h"

@interface TestPlugin : CDVPlugin<BluetoothDelegate2Mode, QPOSServiceListener>

-(void)testWithTitle:(CDVInvokedUrlCommand *)command;

-(void)getQposId:(CDVInvokedUrlCommand *)command;

-(void)scanQPos2Mode:(CDVInvokedUrlCommand *)command;

-(void)connectBluetoothDevice:(CDVInvokedUrlCommand *)command;

-(void)doTrade:(CDVInvokedUrlCommand *)command;

-(void)disconenctBT:(CDVInvokedUrlCommand *)command;
@end
