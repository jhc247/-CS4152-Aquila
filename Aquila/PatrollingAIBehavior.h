//
//  PatrollingAI.h
//  Aquila
//
//  Created by Jose Hirshman on 2/25/14.
//  Copyright (c) 2014 Seven Layer Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIBehaving.h"

// Patrollers just create actions that define movement from a to b naivly
@interface PatrollingAIBehavior : NSObject <AIBehaving>
- (id) initWithPoints:(CGPoint) start :(CGPoint) end;
@end
