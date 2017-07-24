//
//  SocketAssitViewController.m
//  SocketAssit
//
//  Created by wanchenxie on 25/04/2017.
//  Copyright © 2017 wanchenxie. All rights reserved.
//

#import "AppDelegate.h"
#import "SocketAssitViewController.h"
#import "GCDAsyncSocket.h"
#import "MBProgressHUD.h"
#import "SocketViewModel.h"


NSString* ipAddressKey = @"ipAddress";
NSString* portNumKey = @"portNum";
NSString* sendDataKey = @"sendData";

@interface SocketAssitViewController ()<GCDAsyncSocketDelegate, SocketViewModelDelegate>

@property (nonatomic, strong) SocketViewModel* socketViewModel;

@property (strong, nonatomic) IBOutlet UITextField *hostAddressTextField;
@property (strong, nonatomic) IBOutlet UITextField *sendDataTextField;
@property (strong, nonatomic) IBOutlet UITextField *hostPortTextTextField;

@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIButton *connectBtn;

@property (strong, nonatomic) NSTimer* testTimer;



@end

@implementation SocketAssitViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadDataFromUserDefault];
    
    self.socketViewModel = [[SocketViewModel alloc] init];
    
    [self.socketViewModel setupSynThread];
    
    
    
    // Add notification for app resign
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCurInfo) name:UIApplicationWillResignActiveNotification object:nil];
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.socketViewModel disconnect];
    self.socketViewModel = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
#pragma mark - Setter and Getter


#pragma mark - Private Methods
- (void)testZone {
    //[self disConnectOrConnectToHost:nil];
    static NSInteger count = 0;
    
    
    
    if (count == 0) {
        [self.socketViewModel queueCmd:Syn_CmdOne];
    }
    else if (count == 1) {
        [self.socketViewModel queueCmd:Syn_CmdTwo];
    }
    else if (count == 2){
        [self.socketViewModel queueCmd:Syn_CmdThree];
    }
    
    
    
    if (++ count == 5) {
        count = 1;
        
    }
    
}

- (void)startToConnect {
    self.connectBtn.enabled = false;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)endToConnect {
   
    self.connectBtn.enabled = true;
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)loadDataFromUserDefault {
    NSString* ipAddress = [[NSUserDefaults standardUserDefaults] objectForKey:ipAddressKey];
    NSString* portNum = [[NSUserDefaults standardUserDefaults] objectForKey:portNumKey];
    NSString* sendData = [[NSUserDefaults standardUserDefaults] objectForKey:sendDataKey];
    
    self.hostAddressTextField.text = ipAddress;
    self.hostPortTextTextField.text = portNum;
    self.sendDataTextField.text = sendData;
}
- (void)saveCurInfo {
    [[NSUserDefaults standardUserDefaults] setObject:self.hostAddressTextField.text forKey:ipAddressKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.hostPortTextTextField.text forKey:portNumKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.sendDataTextField.text forKey:sendDataKey];
}


-(NSData*)stringToByte:(NSString*)string//字符串转换为16位Data
{
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}

#pragma mark - Actions
- (IBAction)screenTapped:(UIControl *)sender {
    
    [self.view endEditing:YES];
}

- (IBAction)startTimer:(UIButton *)sender {
    self.testTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(testZone) userInfo:nil repeats:YES];
}

- (IBAction)disConnectOrConnectToHost:(UIButton *)sender {
    
    // Connect to host
    if (self.socketViewModel.isConnected == false) {
        DDLogDebug(@"Socket is not connected");
        
        // The host and port number is empty.
        if ([self.hostAddressTextField.text isEqualToString:@""]
            || [self.hostPortTextTextField.text isEqualToString:@""]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Host Address" message:@"Address or Port is empty" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:ok];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        // Connect to the host with port number.
        else {            
            NSString* ipAddr = self.hostAddressTextField.text;
            NSInteger port = [self.hostPortTextTextField.text integerValue];
            
            // Indicator start to animate.
            [self startToConnect];
            
            //self.socketViewModel = [self socketViewModelWithHost:ipAddr andPort:port];
            [self.socketViewModel connectToHost:ipAddr port:port withHandler:^(NSError *err) {
                
                DDLogDebug(@"connect with error %@", err);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self endToConnect];
                    
                    
                    if (err == nil) {
                        self.statusLabel.text = @"Connected";
                        [self.connectBtn setTitle:@"Disconnect" forState:UIControlStateNormal];
                    }
                    else {
                        
                        AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                        
                        [delegate showAlertOnKeyWindowTitle:@"Error" msg:@"Failed to connect."];
                    }
                });
                
                
                
            }];
        }

    }
    
    // Disconnect from host
    else {
        DDLogDebug(@"socket connected, the cliking will cause it's disconnecting");
        [self.socketViewModel disconnect];
        
        self.statusLabel.text = @"Disconnected";
        [self.connectBtn setTitle:@"Connect" forState:UIControlStateNormal];
    }
    
    DDLogDebug(@"End of the cliking operation.");
}


- (IBAction)sendDataToHost:(UIButton *)sender {
    // If self.isConnected send the data to the host directly.
    if (self.socketViewModel.isConnected) {
        NSString *inputStr = self.sendDataTextField.text;
        
        NSData *dat = [self stringToByte:inputStr];
        
        NSLog(@"dat = %@", dat);
        
        //[self.socket writeData:dat withTimeout:10 tag:1000.0];
    }
    
    // If the iPhone is not connected to host, tell the user to connect first.
    else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"You should connect to the speaker first" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    
}


#pragma mark - SocketViewModelDelegate
- (void)initSocketWithResult:(NSError *)err {
    
    
    
}

@end
