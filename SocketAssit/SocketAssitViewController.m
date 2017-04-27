//
//  SocketAssitViewController.m
//  SocketAssit
//
//  Created by wanchenxie on 25/04/2017.
//  Copyright © 2017 wanchenxie. All rights reserved.
//

#import "SocketAssitViewController.h"
#import "GCDAsyncSocket.h"
#import "MBProgressHUD.h"

NSString* ipAddressKey = @"ipAddress";
NSString* portNumKey = @"portNum";
NSString* sendDataKey = @"sendData";

@interface SocketAssitViewController ()<GCDAsyncSocketDelegate>

@property (strong, nonatomic) IBOutlet UITextField *hostAddressTextField;
@property (strong, nonatomic) IBOutlet UITextField *sendDataTextField;
@property (strong, nonatomic) IBOutlet UITextField *hostPortTextTextField;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIButton *connectBtn;


@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) dispatch_queue_t socketQueue;
@property (nonatomic, assign) BOOL isConnected;

@end

@implementation SocketAssitViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadDataFromUserDefault];
    
    // Add notification for app resign
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCurInfo) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.socket disconnect];
    self.socket = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
#pragma mark - Setter and Getter
- (GCDAsyncSocket*)socket {
    
    if (_socket == nil) {
        // NULL stand for serial queue.
        self.socketQueue = dispatch_queue_create("www.socketAssit.queue", NULL);
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.socketQueue];
    }
    
    return _socket;
}

#pragma mark - Private Methods

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


- (IBAction)disConnectOrConnectToHost:(UIButton *)sender {
    
    if (self.isConnected == false) {
        if ([self.hostAddressTextField.text isEqualToString:@""]
            || [self.hostPortTextTextField.text isEqualToString:@""]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Host Address" message:@"Address or Port is empty" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:ok];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        else {
            NSError *error;
            NSString *portStr = self.hostPortTextTextField.text;
            
            [self startToConnect];
            
            [self.socket disconnect];
            
            [self.socket connectToHost:self.hostAddressTextField.text onPort:[portStr integerValue] error:&error];
            if (error != nil) {
                
                
                NSLog(@"Error occur when connect... %@", [error userInfo]);
                
                [self endToConnect];
            }
        }

    }
    
    else {
        [self.socket disconnect];
    }
}


- (IBAction)sendDataToHost:(UIButton *)sender {
    // If self.isConnected send the data to the host directly.
    if (self.isConnected) {
        NSString *inputStr = self.sendDataTextField.text;
        
        NSData *dat = [self stringToByte:inputStr];
        
        NSLog(@"dat = %@", dat);
        
        [self.socket writeData:dat withTimeout:10 tag:1000.0];
    }
    
    // If the iPhone is not connected to host, tell the user to connect first.
    else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"You should connect to the speaker first" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    
}


#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    __weak SocketAssitViewController* weakself = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself endToConnect];
        weakself.connectBtn.enabled = true;
        weakself.statusLabel.text = @"Connected";
        [weakself.connectBtn setTitle:@"Disconnect" forState:UIControlStateNormal];
    });
    
    self.isConnected = true;
    
    NSLog(@"Connect to host with ip address %@ and port %hu", host, port);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    self.isConnected = false;
    
    __weak SocketAssitViewController* weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.connectBtn setTitle:@"Connect" forState:UIControlStateNormal];
        weakSelf.statusLabel.text = @"Disconnected";
    });
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"Write to host with Tag %ld successfully.", tag);
}

@end
