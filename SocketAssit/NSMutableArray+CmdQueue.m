//
//  NSMutableArray+CmdQueue.m
//  
//
//  Created by wanchenxie on 24/07/2017.
//
//

#import "NSMutableArray+CmdQueue.h"

@implementation NSMutableArray (CmdQueue)

- (void)pushCmd:(id)cmd {
    
    @synchronized (self) {
        [self addObject:cmd];
    }
    
}

- (id)popCmd {
    
    @synchronized (self) {
        id cmd = [self objectAtIndex:0];
        [self removeObjectAtIndex:0];
        
        return cmd;
    }
    
}

- (void)removeAllCmds {
    
    @synchronized (self) {
        [self removeAllObjects];
    }
    
}


- (BOOL)isCmdQueueEmpty {
    return self.count == 0;
}
@end
