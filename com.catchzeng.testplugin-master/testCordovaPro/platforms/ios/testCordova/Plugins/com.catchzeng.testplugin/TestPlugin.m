//
//  TestPlugin.m
//  testCordova
//
//  Created by Administrator on 16/9/20.
//
//

#import "TestPlugin.h"
#import "TestViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface TestPlugin ()

@property (nonatomic, strong)QPOSService *mPos;
@property (nonatomic, strong)BTDeviceFinder *bt;
@property (nonatomic, strong)CDVInvokedUrlCommand *urlCommand;
@property (nonatomic,copy)NSString *terminalTime;
@property (nonatomic,copy)NSString *currencyCode;
@property (nonatomic,assign)TransactionType mTransType;
@property (nonatomic,strong)UIActionSheet *mActionSheet;
@property (nonatomic,strong)UIAlertView *mAlertView;
@end

@implementation TestPlugin

-(id)init{
    self = [super init];
    if(self != nil){
        [self initPos];
    }
    return self;
}

-(void)initPos{
    NSLog(@"init pos");
    if (_mPos == nil) {
        _mPos = [QPOSService sharedInstance];
    }
    [self.mPos setDelegate:self];
    [self.mPos setQueue:nil];
    [self.mPos setPosType:PosType_BLUETOOTH_2mode];
    if (_bt== nil) {
        self.bt = [[BTDeviceFinder alloc]init];
    }
}

-(void)testWithTitle:(CDVInvokedUrlCommand *)command{
    NSLog(@"调用了 testWithTitle");
    if (command.arguments.count>0) {
        //customize argument
        NSString* title = command.arguments[0];
        TestViewController* testViewCtrl = [[TestViewController alloc]init];
        [self.viewController presentViewController:testViewCtrl animated:YES completion:^{
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"我是OC回传的参数!"];
            testViewCtrl.labTitle.text = title;
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }else{
        //callback
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"没有参数"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

-(void)getQposId:(CDVInvokedUrlCommand *)command{
    NSLog(@"调用了 getQposId");
    if (command.arguments.count>0) {
        //customize argument
        NSString* title = command.arguments[0];
        
        TestViewController* testViewCtrl = [[TestViewController alloc]init];
        [self.viewController presentViewController:testViewCtrl animated:YES completion:^{
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"我是OC回传的参数!"];
            testViewCtrl.labTitle.text = title;
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }else{
        //callback
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"没有参数"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

-(void)scanQPos2Mode:(CDVInvokedUrlCommand *)command{
    self.urlCommand = command;
    if (_mPos == nil) {
        _mPos = [QPOSService sharedInstance];
    }
    [self.mPos setDelegate:self];
    [self.mPos setQueue:nil];
    [self.mPos setPosType:PosType_BLUETOOTH_2mode];
    if (_bt== nil) {
        self.bt = [[BTDeviceFinder alloc]init];
    }
       NSInteger delay = 30;
       NSLog(@"蓝牙状态:%ld",(long)[self.bt getCBCentralManagerState]);
       [self.bt setBluetoothDelegate2Mode:self];
       if ([self.bt getCBCentralManagerState] == CBCentralManagerStateUnknown) {
               while ([self.bt getCBCentralManagerState]!= CBCentralManagerStatePoweredOn) {
                   NSLog(@"Bluetooth state is not power on");
                   [self sleepMs:10];
                   if(delay++==10){
                       return;
                   }
               }
           }
      [self.bt scanQPos2Mode:delay];
}

-(void) sleepMs: (NSInteger)msec {
    NSTimeInterval sec = (msec / 1000.0f);
    [NSThread sleepForTimeInterval:sec];
}

-(void)onBluetoothName2Mode:(NSString *)bluetoothName{
    if (bluetoothName != nil && ![bluetoothName isEqualToString:@""]) {
        NSLog(@"蓝牙名: %@",bluetoothName);
        NSString *jsStr = [NSString stringWithFormat:@"addrow('%@')",bluetoothName];
        [self.commandDelegate evalJs:jsStr];
    }
   
}

-(void)connectBluetoothDevice:(CDVInvokedUrlCommand *)command{
    self.urlCommand = command;
    NSLog(@"btAddress: %@", command.arguments);
    if (command.arguments.count>0) {
        //customize argument
        NSString* btAddress = command.arguments[0];
        [self.mPos connectBT:btAddress];
    }else{
        
    }
}

//pos 连接成功的回调
-(void) onRequestQposConnected{
    NSLog(@"onRequestQposConnected");
    [self.bt stopQPos2Mode];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"connected"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.urlCommand.callbackId];
}

-(void) onRequestQposDisconnected{
    [self.bt stopQPos2Mode];
    NSLog(@"onRequestQposDisconnected");
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"disconnect"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.urlCommand.callbackId];
}

-(void) onRequestNoQposDetected{
    [self.bt stopQPos2Mode];
    NSLog(@"onRequestNoQposDetected");
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"detected"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.urlCommand.callbackId];
}

-(void)doTrade:(CDVInvokedUrlCommand *)command{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    _terminalTime = [dateFormatter stringFromDate:[NSDate date]];
    self.mTransType = TransactionType_GOODS;
    _currencyCode = @"156";
    [self.mPos setCardTradeMode:CardTradeMode_SWIPE_TAP_INSERT_CARD];
    [self.mPos doTrade:30];
}

-(void) onRequestDisplay: (Display)displayMsg{
    NSString *msg = @"";
    if (displayMsg==Display_CLEAR_DISPLAY_MSG) {
        msg = @"";
    }else if(displayMsg==Display_PLEASE_WAIT){
        msg = @"Please wait...";
    }else if(displayMsg==Display_REMOVE_CARD){
        msg = @"Please remove card";
    }else if (displayMsg==Display_TRY_ANOTHER_INTERFACE){
        msg = @"Please try another interface";
    }else if (displayMsg == Display_TRANSACTION_TERMINATED){
        msg = @"Terminated";
    }else if (displayMsg == Display_PIN_OK){
        msg = @"Pin ok";
    }else if (displayMsg == Display_INPUT_PIN_ING){
        msg = @"please input pin on pos";
    }else if (displayMsg == Display_MAG_TO_ICC_TRADE){
        msg = @"please insert chip card on pos";
    }else if (displayMsg == Display_INPUT_OFFLINE_PIN_ONLY){
        msg = @"input offline pin only";
    }else if(displayMsg == Display_CARD_REMOVED){
        msg = @"Card Removed";
    }
    NSString *displayStr = msg;
}

-(void) onRequestSetAmount{
    [self.mPos setAmount:@"100" aAmountDescribe:@"1000" currency:@"156" transactionType:TransactionType_GOODS];
}

-(void) onRequestWaitingUser{
    NSString *displayStr  =@"Please insert/swipe/tap card now.";
}
-(void) onDHError: (DHError)errorState{
    NSString *msg = @"";
    
    if(errorState ==DHError_TIMEOUT) {
        msg = @"Pos no response";
    } else if(errorState == DHError_DEVICE_RESET) {
        msg = @"Pos reset";
    } else if(errorState == DHError_UNKNOWN) {
        msg = @"Unknown error";
    } else if(errorState == DHError_DEVICE_BUSY) {
        msg = @"Pos Busy";
    } else if(errorState == DHError_INPUT_OUT_OF_RANGE) {
        msg = @"Input out of range.";
    } else if(errorState == DHError_INPUT_INVALID_FORMAT) {
        msg = @"Input invalid format.";
    } else if(errorState == DHError_INPUT_ZERO_VALUES) {
        msg = @"Input are zero values.";
    } else if(errorState == DHError_INPUT_INVALID) {
        msg = @"Input invalid.";
    } else if(errorState == DHError_CASHBACK_NOT_SUPPORTED) {
        msg = @"Cashback not supported.";
    } else if(errorState == DHError_CRC_ERROR) {
        msg = @"CRC Error.";
    } else if(errorState == DHError_COMM_ERROR) {
        msg = @"Communication Error.";
    }else if(errorState == DHError_MAC_ERROR){
        msg = @"MAC Error.";
    }else if(errorState == DHError_CMD_TIMEOUT){
        msg = @"CMD Timeout.";
    }else if(errorState == DHError_AMOUNT_OUT_OF_LIMIT){
        msg = @"Amount out of limit.";
    }
    
    NSString *error = msg;
    NSLog(@"onError = %@",msg);
}


//开始执行start 按钮后返回的结果状态
-(void) onDoTradeResult: (DoTradeResult)result DecodeData:(NSDictionary*)decodeData{
    NSLog(@"onDoTradeResult?>> result %ld",(long)result);
    if (result == DoTradeResult_NONE) {
        NSString *display = @"No card detected. Please insert or swipe card again and press check card.";
        [self.mPos doTrade:30];
    }else if (result==DoTradeResult_ICC) {
        NSString *display = @"ICC Card Inserted";
        [self.mPos doEmvApp:EmvOption_START];
    }else if(result==DoTradeResult_NOT_ICC){
        NSString *display = @"Card Inserted (Not ICC)";
    }else if(result==DoTradeResult_MCR){
        NSLog(@"decodeData: %@",decodeData);
        NSString *formatID = [NSString stringWithFormat:@"Format ID: %@\n",decodeData[@"formatID"]] ;
        NSString *maskedPAN = [NSString stringWithFormat:@"Masked PAN: %@\n",decodeData[@"maskedPAN"]];
        NSString *expiryDate = [NSString stringWithFormat:@"Expiry Date: %@\n",decodeData[@"expiryDate"]];
        NSString *cardHolderName = [NSString stringWithFormat:@"Cardholder Name: %@\n",decodeData[@"cardholderName"]];
        //NSString *ksn = [NSString stringWithFormat:@"KSN: %@\n",decodeData[@"ksn"]];
        NSString *serviceCode = [NSString stringWithFormat:@"Service Code: %@\n",decodeData[@"serviceCode"]];
        //NSString *track1Length = [NSString stringWithFormat:@"Track 1 Length: %@\n",decodeData[@"track1Length"]];
        //NSString *track2Length = [NSString stringWithFormat:@"Track 2 Length: %@\n",decodeData[@"track2Length"]];
        //NSString *track3Length = [NSString stringWithFormat:@"Track 3 Length: %@\n",decodeData[@"track3Length"]];
        //NSString *encTracks = [NSString stringWithFormat:@"Encrypted Tracks: %@\n",decodeData[@"encTracks"]];
        NSString *encTrack1 = [NSString stringWithFormat:@"Encrypted Track 1: %@\n",decodeData[@"encTrack1"]];
        NSString *encTrack2 = [NSString stringWithFormat:@"Encrypted Track 2: %@\n",decodeData[@"encTrack2"]];
        NSString *encTrack3 = [NSString stringWithFormat:@"Encrypted Track 3: %@\n",decodeData[@"encTrack3"]];
        //NSString *partialTrack = [NSString stringWithFormat:@"Partial Track: %@",decodeData[@"partialTrack"]];
        NSString *pinKsn = [NSString stringWithFormat:@"PIN KSN: %@\n",decodeData[@"pinKsn"]];
        NSString *trackksn = [NSString stringWithFormat:@"Track KSN: %@\n",decodeData[@"trackksn"]];
        NSString *pinBlock = [NSString stringWithFormat:@"pinBlock: %@\n",decodeData[@"pinblock"]];
        NSString *encPAN = [NSString stringWithFormat:@"encPAN: %@\n",decodeData[@"encPAN"]];
        
        NSString *msg = [NSString stringWithFormat:@"Card Swiped:\n"];
        msg = [msg stringByAppendingString:formatID];
        msg = [msg stringByAppendingString:maskedPAN];
        msg = [msg stringByAppendingString:expiryDate];
        msg = [msg stringByAppendingString:cardHolderName];
        //msg = [msg stringByAppendingString:ksn];
        msg = [msg stringByAppendingString:pinKsn];
        msg = [msg stringByAppendingString:trackksn];
        msg = [msg stringByAppendingString:serviceCode];
        
        msg = [msg stringByAppendingString:encTrack1];
        msg = [msg stringByAppendingString:encTrack2];
        msg = [msg stringByAppendingString:encTrack3];
        msg = [msg stringByAppendingString:pinBlock];
        msg = [msg stringByAppendingString:encPAN];
    }else if(result==DoTradeResult_NFC_OFFLINE || result == DoTradeResult_NFC_ONLINE){
        NSLog(@"decodeData: %@",decodeData);
        NSString *formatID = [NSString stringWithFormat:@"Format ID: %@\n",decodeData[@"formatID"]] ;
        NSString *maskedPAN = [NSString stringWithFormat:@"Masked PAN: %@\n",decodeData[@"maskedPAN"]];
        NSString *expiryDate = [NSString stringWithFormat:@"Expiry Date: %@\n",decodeData[@"expiryDate"]];
        NSString *cardHolderName = [NSString stringWithFormat:@"Cardholder Name: %@\n",decodeData[@"cardholderName"]];
        //NSString *ksn = [NSString stringWithFormat:@"KSN: %@\n",decodeData[@"ksn"]];
        NSString *serviceCode = [NSString stringWithFormat:@"Service Code: %@\n",decodeData[@"serviceCode"]];
        //NSString *track1Length = [NSString stringWithFormat:@"Track 1 Length: %@\n",decodeData[@"track1Length"]];
        //NSString *track2Length = [NSString stringWithFormat:@"Track 2 Length: %@\n",decodeData[@"track2Length"]];
        //NSString *track3Length = [NSString stringWithFormat:@"Track 3 Length: %@\n",decodeData[@"track3Length"]];
        //NSString *encTracks = [NSString stringWithFormat:@"Encrypted Tracks: %@\n",decodeData[@"encTracks"]];
        NSString *encTrack1 = [NSString stringWithFormat:@"Encrypted Track 1: %@\n",decodeData[@"encTrack1"]];
        NSString *encTrack2 = [NSString stringWithFormat:@"Encrypted Track 2: %@\n",decodeData[@"encTrack2"]];
        NSString *encTrack3 = [NSString stringWithFormat:@"Encrypted Track 3: %@\n",decodeData[@"encTrack3"]];
        //NSString *partialTrack = [NSString stringWithFormat:@"Partial Track: %@",decodeData[@"partialTrack"]];
        NSString *pinKsn = [NSString stringWithFormat:@"PIN KSN: %@\n",decodeData[@"pinKsn"]];
        NSString *trackksn = [NSString stringWithFormat:@"Track KSN: %@\n",decodeData[@"trackksn"]];
        NSString *pinBlock = [NSString stringWithFormat:@"pinBlock: %@\n",decodeData[@"pinblock"]];
        NSString *encPAN = [NSString stringWithFormat:@"encPAN: %@\n",decodeData[@"encPAN"]];
        
        NSString *msg = [NSString stringWithFormat:@"Tap Card:\n"];
        msg = [msg stringByAppendingString:formatID];
        msg = [msg stringByAppendingString:maskedPAN];
        msg = [msg stringByAppendingString:expiryDate];
        msg = [msg stringByAppendingString:cardHolderName];
        //msg = [msg stringByAppendingString:ksn];
        msg = [msg stringByAppendingString:pinKsn];
        msg = [msg stringByAppendingString:trackksn];
        msg = [msg stringByAppendingString:serviceCode];
        
        msg = [msg stringByAppendingString:encTrack1];
        msg = [msg stringByAppendingString:encTrack2];
        msg = [msg stringByAppendingString:encTrack3];
        msg = [msg stringByAppendingString:pinBlock];
        msg = [msg stringByAppendingString:encPAN];
        
        dispatch_async(dispatch_get_main_queue(),  ^{
            NSDictionary *mDic = [self.mPos getNFCBatchData];
            NSString *tlv;
            if(mDic !=nil){
                tlv= [NSString stringWithFormat:@"NFCBatchData: %@\n",mDic[@"tlv"]];
            }else{
                tlv = @"";
            }
            NSLog(@"%@",tlv);
        });
        
    }else if(result==DoTradeResult_NFC_DECLINED){
        NSString *displayStr = @"Tap Card Declined";
    }else if (result==DoTradeResult_NO_RESPONSE){
        NSString *displayStr = @"Check card no response";
    }else if(result==DoTradeResult_BAD_SWIPE){
        NSString *displayStr = @"Bad Swipe. \nPlease swipe again and press check card.";
    }else if(result==DoTradeResult_NO_UPDATE_WORK_KEY){
        NSString *displayStr = @"device not update work key";
    }
}

-(void) onRequestSelectEmvApp: (NSArray*)appList{
    self.mActionSheet = [[UIActionSheet new] initWithTitle:@"Please select app" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    for (int i=0 ; i<[appList count] ; i++){
        NSString *emvApp = [appList objectAtIndex:i];
        [self.mActionSheet addButtonWithTitle:emvApp];
    }
    [self.mActionSheet addButtonWithTitle:@"Cancel"];
    [self.mActionSheet setCancelButtonIndex:[appList count]];
    [self.mActionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

-(void) onRequestFinalConfirm{
    NSString *amount = @"100";
    NSLog(@"onRequestFinalConfirm-------amount = %@",amount);
    NSString *msg = [NSString stringWithFormat:@"Amount: $%@",amount];
    self.mAlertView = [[UIAlertView new]
                  initWithTitle:@"Confirm amount"
                  message:msg
                  delegate:self
                  cancelButtonTitle:@"Confirm"
                  otherButtonTitles:@"Cancel",
                  nil ];
    [self.mAlertView show];
}
-(void) onRequestTime{
    //    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    //    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    //    NSString *terminalTime = [dateFormatter stringFromDate:[NSDate date]];
    [self.mPos sendTime:_terminalTime];
    
}

-(void) onRequestOnlineProcess: (NSString*) tlv{
    NSLog(@"tlv == %@",tlv);
    NSLog(@"onRequestOnlineProcess = %@",[[QPOSService sharedInstance] anlysEmvIccData:tlv]);
    [self.mPos sendOnlineProcessResult:@"8A023030"];
}

-(void) onRequestTransactionResult: (TransactionResult)transactionResult{
    
    NSString *messageTextView = @"";
    if (transactionResult==TransactionResult_APPROVED) {
    }else if(transactionResult == TransactionResult_TERMINATED) {
        [self clearDisplay];
        messageTextView = @"Terminated";
    } else if(transactionResult == TransactionResult_DECLINED) {
        messageTextView = @"Declined";
    } else if(transactionResult == TransactionResult_CANCEL) {
        [self clearDisplay];
        messageTextView = @"Cancel";
    } else if(transactionResult == TransactionResult_CAPK_FAIL) {
        [self clearDisplay];
        messageTextView = @"Fail (CAPK fail)";
    } else if(transactionResult == TransactionResult_NOT_ICC) {
        [self clearDisplay];
        messageTextView = @"Fail (Not ICC card)";
    } else if(transactionResult == TransactionResult_SELECT_APP_FAIL) {
        [self clearDisplay];
        messageTextView = @"Fail (App fail)";
    } else if(transactionResult == TransactionResult_DEVICE_ERROR) {
        [self clearDisplay];
        messageTextView = @"Pos Error";
    } else if(transactionResult == TransactionResult_CARD_NOT_SUPPORTED) {
        [self clearDisplay];
        messageTextView = @"Card not support";
    } else if(transactionResult == TransactionResult_MISSING_MANDATORY_DATA) {
        [self clearDisplay];
        messageTextView = @"Missing mandatory data";
    } else if(transactionResult == TransactionResult_CARD_BLOCKED_OR_NO_EMV_APPS) {
        [self clearDisplay];
        messageTextView = @"Card blocked or no EMV apps";
    } else if(transactionResult == TransactionResult_INVALID_ICC_DATA) {
        [self clearDisplay];
        messageTextView = @"Invalid ICC data";
    }else if(transactionResult == TransactionResult_NFC_TERMINATED) {
        [self clearDisplay];
        messageTextView = @"NFC Terminated";
    }
    NSString *displayStr = messageTextView;
    //    mAlertView = [[UIAlertView new]
    //                  initWithTitle:@"Transaction Result"
    //                  message:messageTextView
    //                  delegate:self
    //                  cancelButtonTitle:@"Confirm"
    //                  otherButtonTitles:nil,
    //                  nil ];
    //    [mAlertView show];
}

-(void)clearDisplay{
    
}

-(void) onRequestTransactionLog: (NSString*)tlv{
    NSLog(@"onTransactionLog %@",tlv);
}
-(void) onRequestBatchData: (NSString*)tlv{
    NSLog(@"onBatchData %@",tlv);
    tlv = [@"batch data:\n" stringByAppendingString:tlv];
    NSString *displayStr = tlv;
}

-(void) onReturnReversalData: (NSString*)tlv{
    NSLog(@"onReversalData %@",tlv);
    tlv = [@"reversal data:\n" stringByAppendingString:tlv];
    NSString *displayStr = tlv;
}

-(void)disconenctBT:(CDVInvokedUrlCommand *)command{
    self.urlCommand = command;
    [self.mPos disconnectBT];
}

@end
