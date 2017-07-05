//
//  SocketViewModel.h
//  SocketAssit
//
//  Created by wanchenxie on 30/06/2017.
//  Copyright © 2017 wanchenxie. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^SocketConnectHandler)(NSError* err);

@class SocketViewModel;

@protocol SocketViewModelDelegate <NSObject>

@optional

// Get the result of initialization.
- (void)initSocketWithResult:(NSError*)err;

// Those methods below is used to update the content of display.
- (void)socketViewModelWillUpdate:(SocketViewModel*)viewModel;
- (void)socketViewModelDidUpdate:(SocketViewModel*)viewModel;

@end



@interface SocketViewModel : NSObject

@property (nonatomic, weak) id<SocketViewModelDelegate> delegate;
@property (nonatomic, assign, getter=isConnected, readonly) BOOL connected;


- (instancetype)init;
- (void)connectToHost:(NSString*)host port:(NSInteger)port withHandler:(SocketConnectHandler)handler;

- (instancetype)initWithHost:(NSString*)host portNum:(NSInteger)port;

- (void)connectWithHandler:(SocketConnectHandler)callBack;

- (void)disconnect;

@end
