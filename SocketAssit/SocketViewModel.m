//
//  SocketViewModel.m
//  SocketAssit
//
//  Created by wanchenxie on 30/06/2017.
//  Copyright © 2017 wanchenxie. All rights reserved.
//

#import "SocketViewModel.h"

#import "SocketModel.h"

@interface SocketViewModel ()

@property (nonatomic, strong) SocketModel* socketModel;

@end



@implementation SocketViewModel

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
}

- (BOOL)isConnected {
    return [self.socketModel isConnected];
}

- (void)disconnect {
    [self.socketModel disconnect];
}

@end
