//
//  NSMutableArray+CmdQueue.h
//  
//
//  Created by wanchenxie on 24/07/2017.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (CmdQueue)


- (void)pushCmd:(id)cmd;

- (id)popCmd;

- (void)removeAllCmds;

- (BOOL)isCmdQueueEmpty;

@end
