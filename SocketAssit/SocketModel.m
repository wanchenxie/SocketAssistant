//
//  SocketModel.m
//  SocketAssit
//
//  Created by wanchenxie on 30/06/2017.
//  Copyright © 2017 wanchenxie. All rights reserved.
//

#import "SocketModel.h"
#import "GCDAsyncSocket.h"

static const NSTimeInterval kConnectTimeOut = 10.f;


@interface SocketModel ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket* socket;
@property (nonatomic, strong, readwrite) NSString* host;
@property (nonatomic, assign, readwrite) NSInteger port;

@property (nonatomic, strong) NSError* socketError;

@property (nonatomic, strong) dispatch_queue_t socketDelegateQueue;
@property (nonatomic, strong) dispatch_queue_t requestQueue;
@property (nonatomic, strong) dispatch_queue_t reponseQueue;

@property (nonatomic, strong) dispatch_semaphore_t requestSemaphore;
@property (nonatomic, strong) dispatch_semaphore_t responseSemaphore;


@end


@implementation SocketModel

#pragma mark - Initializer and destructor

- (instancetype)init {
    self = [super init];
    
    if (self) {
        [self initializer];
    }
    
    return self;
}

- (void)initializer {
    // Create three thread for delegate, request and response respectively.
    self.socketDelegateQueue = dispatch_queue_create("com.kef.tcpremote-delegate", DISPATCH_QUEUE_SERIAL);
    self.requestQueue = dispatch_queue_create("com.kef.requsetQueue", DISPATCH_QUEUE_SERIAL);
    self.reponseQueue = dispatch_queue_create("com.kef.responseQueue", DISPATCH_QUEUE_SERIAL);
    
    // Set self as Socket's delegate and assign a seperated queue for it.
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.socketDelegateQueue];
    
    
    
}

- (void)dealloc {
    self.socket.delegate = nil;
    [self.socket disconnect];
}

#pragma mark - Public Interface

- (void)connectToHost:(NSString *)host port:(NSInteger)port withHandler:(SocketConnectHandler)handler {
    
    // Those function will be blocked when it waits for didConnectToHost to be called.
    dispatch_async(self.requestQueue, ^{
       
        if (self.socket.isConnected) {
            [self.socket disconnect];
        }
        
        self.requestSemaphore = dispatch_semaphore_create(0);
        
        NSError* err;
        [self.socket connectToHost:host onPort:port withTimeout:kConnectTimeOut error:&err];
        
        if (err == nil) {
            dispatch_semaphore_wait(self.requestSemaphore, DISPATCH_TIME_FOREVER);
            
            if (self.socketError == nil) {
                self.host = host;
                self.port = port;
            }
            
            NSError* curErr = self.socketError;
            self.socketError = nil;
            
            handler(curErr);
        }
        
        else {
            
            self.host = nil;
            self.port = -1;
            
            handler(err);
        }
        
        self.requestSemaphore = nil;
    });
    
}

- (BOOL)isConnected {
    return self.socket.isConnected;
}

- (void)disconnect {
    [self.socket disconnect];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    
    dispatch_semaphore_signal(self.requestSemaphore);
    
    DDLogDebug(@"didConnectTo host = %@ port = %d", host, port);
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    self.socketError = err;
    
    if (self.requestSemaphore != nil) {
        dispatch_semaphore_signal(self.requestSemaphore);
    }
    
    
    DDLogDebug(@"disconnect with error = %@", err);
}

@end
