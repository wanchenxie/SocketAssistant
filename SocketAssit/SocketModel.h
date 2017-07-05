//
//  SocketModel.h
//  SocketAssit
//
//  Created by wanchenxie on 30/06/2017.
//  Copyright © 2017 wanchenxie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCDAsyncSocket.h>
#import "SocketViewModel.h"


@protocol SocketModelDelegate <NSObject>

- (void)socketModelConnectHostHostResult:(NSError*)error;


@end


@interface SocketModel : NSObject

@property (nonatomic, weak) id<SocketModelDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isConnected;
@property (nonatomic, strong, readonly) NSString* host;
@property (nonatomic, assign, readonly) NSInteger port;

- (instancetype)init;
- (void)connectToHost:(NSString*)host port:(NSInteger)port withHandler:(SocketConnectHandler)handler;
- (void)disconnect;

@end
