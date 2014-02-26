//
//  FollowAIBehavior.h
//  Aquila
//
//  Created by Jcard on 2/26/14.
//  Copyright 2014 Seven Layer Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AIBehaving.h"
#import "Aquila.h"
#import "AIActor.h"

@interface FollowAIBehavior : NSObject <AIBehaving>

-(id) init: (Aquila*) target : (AIActor*) monster;

@end

