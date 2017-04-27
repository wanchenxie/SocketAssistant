//
//  SocketAssitViewController.m
//  SocketAssit
//
//  Created by wanchenxie on 25/04/2017.
//  Copyright © 2017 wanchenxie. All rights reserved.
//

#import "SocketAssitViewController.h"
#import "GCDAsyncSocket.h"

@interface SocketAssitViewController ()<GCDAsyncSocketDelegate>

@property (strong, nonatomic) IBOutlet UITextField *hostAddressTextField;
@property (strong, nonatomic) IBOutlet UITextField *sendDataTextField;
@property (strong, nonatomic) IBOutlet UITextField *hostPortTextTextField;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;


@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) dispatch_queue_t socketQueue;

@end

@implementation SocketAssitViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.socket disconnect];
    self.socket = nil;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)connectToHost:(UIButton *)sender {
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
        
        NSLog(@"port = %ld", [portStr integerValue]);
        
        [self.socket connectToHost:self.hostAddressTextField.text onPort:[portStr integerValue] error:&error];
        if (error != nil) {
            NSLog(@"Error occur when connect... %@", [error userInfo]);
        }else {
            self.statusLabel.text = @"connected";
        }
    }
    
    
   
    
}


- (IBAction)sendDataToHost:(UIButton *)sender {
    NSString *inputStr = self.sendDataTextField.text;
    
    NSData *dat = [self stringToByte:inputStr];
   
    NSLog(@"dat = %@", dat);
    
    [self.socket writeData:dat withTimeout:5 tag:1000.0];
    
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



@end
