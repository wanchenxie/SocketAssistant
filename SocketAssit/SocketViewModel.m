//
//  SocketViewModel.m
//  SocketAssit
//
//  Created by wanchenxie on 30/06/2017.
//  Copyright © 2017 wanchenxie. All rights reserved.
//

#import "SocketViewModel.h"

#import "SocketModel.h"

#import "NSMutableArray+CmdQueue.h"


@interface SocketViewModel ()<SocketModelDelegate>



@property (nonatomic, strong) SocketModel* socketModel;
@property (nonatomic) NSString* host;
@property (nonatomic) NSInteger port;

@property (nonatomic) NSMutableArray* cmdQueue;
@property (nonatomic) NSThread* synInfoThread;

@end



@implementation SocketViewModel

#pragma mark - Setter and getter
- (NSMutableArray*)cmdQueue {
    if (_cmdQueue == nil) {
        _cmdQueue = [[NSMutableArray alloc] init];
    }
    
    return _cmdQueue;
}


#pragma mark - Initializer
- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        [self initializer];
    }
    
    return self;
}
- (instancetype)initWithHost:(NSString *)host portNum:(NSInteger)port {
    self = [super init];
    if (self) {
        [self initializer];
    }
    
    return self;
}

- (void)initializer {
    self.socketModel = [[SocketModel alloc] init];
    
    
}

#pragma mark - Public Interface
- (void)connectToHost:(NSString *)host port:(NSInteger)port withHandler:(SocketConnectHandler)handler {
    [self.socketModel connectToHost:host port:port withHandler:handler];
    
    self.host = host;
    self.port = port;
}

- (void)reconnect {
    [self.socketModel connectToHost:self.host port:self.port withHandler:nil];
}

- (void)synConnectToHost:(NSString*)host port:(NSInteger)port {
    [self.socketModel synConnectToHost:host port:port];
}
- (BOOL)isConnected {
    return [self.socketModel isConnected];
}

- (void)disconnect {
    [self.socketModel disconnect];
}

- (void)cancelSynThread {
    if (self.synInfoThread != nil) {
        [self.synInfoThread cancel];
        [self.cmdQueue removeAllCmds];
    }
    
}

- (void)setupSynThread {
    self.synInfoThread = [[NSThread alloc] initWithTarget:self selector:@selector(synchronizeSpeakerInfo:) object:nil];
    [self.synInfoThread start];
}

- (void)queueCmd:(SynCmd)cmd {
    [self.cmdQueue pushCmd:[NSNumber numberWithInteger:cmd]];
}
#pragma mark - Private methods
- (void)synchronizeSpeakerInfo:(id)obj {
    @autoreleasepool {
        
        while ([[NSThread currentThread] isCancelled] == NO) {
            
            if (![self.cmdQueue isCmdQueueEmpty]) {
                
                if (!self.socketModel.isConnected) {
                    [self synConnectToHost:self.host port:self.port];
                }
                
                id cmd = [self.cmdQueue popCmd];
                
                [self executeCmd:cmd];
                
            }else {
                
                if (self.socketModel.isConnected) {
                    [self.socketModel disconnect];
                }
            }
            
            [NSThread sleepForTimeInterval:0.1];
        }
        
    }
}

- (void)executeCmd:(id)cmd {
    NSData* cmdData = [self composeSocketCmdByCmdType:cmd];
    
    [self.socketModel sendData:cmdData];
}

- (NSData*)composeSocketCmdByCmdType:(id)cmd {
    
    NSInteger cmdType = [cmd integerValue];
    NSData* cmdData;
    
    switch (cmdType) {
        case Syn_CmdOne:{
            Byte cmdByts[] = {0x53, 0x30, 0x81, 0x80, 0x94};
            
            cmdData = [NSData dataWithBytes:cmdByts length:5];
            break;
        }
            
            
            
        case Syn_CmdTwo: {
            Byte cmdByts[] = {0x53, 0x30, 0x81, 0x8a, 0x94};
            
            cmdData = [NSData dataWithBytes:cmdByts length:5];
        }
            
            break;
        case Syn_CmdThree: {
            Byte cmdBytes[] = {0x53, 0x30, 0x81, 0x89, 0x94};
            cmdData = [NSData dataWithBytes:cmdBytes length:5];
        }
            break;
        default:
            break;
    }
    
    return cmdData;
}

#pragma mark - SocketModelDelegate
- (void)socketModelConnectHostHostResult:(NSError *)error {
    
    [self.delegate initSocketWithResult:error];
}

- (void)socketModelSendDataResult:(NSError *)error {
    
}
@end
