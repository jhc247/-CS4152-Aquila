//
//  AIBehavior.h
//  Aquila
//
//  Created by Jose Hirshman on 2/25/14.
//  Copyright (c) 2014 Seven Layer Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/*
 Protocol defining an AI's actions
 */
@protocol AIBehaving <NSObject>
- (void) generateAIAction;
@end
