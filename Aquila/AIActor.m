//
//  AIActor.m
//  Aquila
//
//  Created by Jose Hirshman on 2/25/14.
//  Copyright (c) 2014 Seven Layer Games. All rights reserved.
//

#import "AIActor.h"
#import "PhysicsCollisionDelegate.h"
#import "Constants.h"

@implementation AIActor : CCSprite
{
    NSObject<AIBehaving>* _behavior;
    NSString* normalSprite;
    NSString* stunnedSprite;
}

+ (NSString*) getSprite:(EnemyType)type state:(AIState)state {
    switch (type) {
        case Megagrunt:
            return (state == Normal) ? MEGAGRUNT : MEGAGRUNT_STUNNED;
        case Game_N_Watch:
            return (state == Normal) ? GAMEnWATCH : GAMEnWATCH_STUNNED;
        default:
            return NULL;
    }
}


- (void) initWithBehavior:(NSObject<AIBehaving>*) behavior :(CGPoint)position type:(EnemyType)type
{
    self.position = position;
    
    CCPhysicsBody *body = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, self.contentSize} cornerRadius:0];
    body.collisionGroup = @"monsterGroup";
    body.collisionType = monsterCollisionType;
    
    self.physicsBody = body;
    _behavior = behavior;
    _state = Normal;
    normalSprite = [AIActor getSprite:type state:Normal];
    stunnedSprite = [AIActor getSprite:type state:Stunned];
}

- (void) startAI
{
    [_behavior generateAIAction];
}

- (void) restartAI
{
    _state = Normal;
    [self setTexture:[[CCSprite spriteWithImageNamed:normalSprite] texture]];
    [self startAI];
}

- (void) stun
{
    _state = Stunned;
    [self setTexture:[[CCSprite spriteWithImageNamed:stunnedSprite] texture]];
    [self stopAI];
}

- (void) stopAI
{
    [self stopAllActions];
}

@end
