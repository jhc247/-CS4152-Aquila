//
//  PhysicsCollisionDelegate.m
//  Aquila
//
//  Created by Jcard on 2/26/14.
//  Copyright 2014 Seven Layer Games. All rights reserved.
//

#import "PhysicsCollisionDelegate.h"
#import "Constants.h"

@implementation PhysicsCollisionDelegate

static PhysicsCollisionDelegate *delegate;

+ (void) initialize
{
    static BOOL initialized = NO;
    if (!initialized)
    {
        initialized = YES;
        delegate = [[PhysicsCollisionDelegate alloc] init];
    }
}

+ (PhysicsCollisionDelegate*) delegate {
    return delegate;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair aquilaCollision:(Aquila *)aquila monsterCollision:(AIActor *)monster {
    
    CCLOG(@"Aquila collided with a monster");
    if (aquila.state != Dashing && monster.state == Normal) {
        [aquila die];
    }
    else if (aquila.state == Dashing)
    {
        [monster stun];
        CCActionCallFunc *unstun = [CCActionCallFunc actionWithTarget:monster selector:@selector(restartAI)];
        CCActionDelay *delay = [CCActionDelay actionWithDuration:AI_STUN_DURATION];
        CCActionSequence *sequence = [CCActionSequence actionWithArray:@[delay, unstun]];
        [monster runAction:sequence];
    }
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair aquilaCollision:(Aquila *)aquila crystalCollision:(Crystal *)crystal {
    
    CCLOG(@"Aquila collided with a crystal");
    [aquila stand];
    [crystal flipState:true];
    
    return YES;
}

@end
