//
//  FollowAIBehavior.m
//  Aquila
//
//  Created by Jcard on 2/26/14.
//  Copyright 2014 Seven Layer Games. All rights reserved.
//

#import "Constants.h"
#import "FollowAIBehavior.h"

@implementation FollowAIBehavior : NSObject {
    AIActor* _monster;
    Aquila* _target;
}

- (id) init:(Aquila*) target : (AIActor*) monster
{
    _monster = monster;
    _target = target;
    return self;
}

- (void) generateAIAction
{
    
    float distance = ccpDistance(_monster.position, _target.position);
    float duration = distance / SLOW_SPEED;
    CCActionMoveTo* walk = [CCActionMoveTo actionWithDuration:duration position:_target.position];
    CCActionCallFunc *update = [CCActionCallFunc actionWithTarget:self selector:@selector(generateAIAction)];
    CCActionSequence* patrolAction = [CCActionSequence actionWithArray:@[walk, update]];
    [_monster runAction:patrolAction ];
}

@end
