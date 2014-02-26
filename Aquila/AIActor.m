//
//  AIActor.m
//  Aquila
//
//  Created by Jose Hirshman on 2/25/14.
//  Copyright (c) 2014 Seven Layer Games. All rights reserved.
//

#import "AIActor.h"

@implementation AIActor : CCSprite
{
    NSObject<AIBehaving>*   _behavior;
    NSString* normalSprite;
    NSString* stunnedSprite;
}

- (void) initWithBehavior:(NSObject<AIBehaving>*) behavior :(CGPoint)position normalSprite:(NSString*) normal stunnedSprite:(NSString*) stunned
{
    self.position = position;
    
    CCPhysicsBody *body = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, self.contentSize} cornerRadius:0];
    body.collisionGroup = @"monsterGroup";
    body.collisionType = @"monsterCollision";
    
    self.physicsBody = body;
    _behavior = behavior;
    self.state = Normal;
    normalSprite = normal;
    stunnedSprite = stunned;
}

- (void) startAI
{
    [_behavior generateAIAction];
}

- (void) restartAI
{
    self.state = Normal;
    [self setTexture:[[CCSprite spriteWithImageNamed:normalSprite] texture]];
    [self startAI];
}

- (void) stun
{
    self.state = Stunned;
    [self setTexture:[[CCSprite spriteWithImageNamed:stunnedSprite] texture]];
    [self stopAI];
}

- (void) stopAI
{
    [self stopAllActions];
}



@end
