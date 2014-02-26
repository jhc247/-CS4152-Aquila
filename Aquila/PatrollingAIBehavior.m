//
//  PatrollingAI.m
//  Aquila
//
//  Created by Jose Hirshman on 2/25/14.
//  Copyright (c) 2014 Seven Layer Games. All rights reserved.
//

#import "PatrollingAIBehavior.h"
#import "AIActor.h"

@implementation PatrollingAIBehavior
{
    AIActor* _monster;
    CGPoint _start;
    CGPoint _end;
}

- (id) initWithPoints:(CGPoint) start :(CGPoint) end monster:(AIActor*) mon
{
    _monster = mon;
    _start = start;
    _end = end;
    return self;
}

- (void) generateAIAction
{
    CCActionMoveTo* patrol1 = [CCActionMoveTo actionWithDuration:2 position:_end];
    CCActionMoveTo* patrol2 = [CCActionMoveTo actionWithDuration:2 position:_start];
    CCActionSequence* patrolAction = [CCActionSequence actionWithArray:@[patrol1, patrol2]];
    [_monster runAction: [CCActionRepeatForever actionWithAction:patrolAction]];
}

@end
