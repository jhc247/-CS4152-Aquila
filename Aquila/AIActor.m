//
//  AIActor.m
//  Aquila
//
//  Created by Jose Hirshman on 2/25/14.
//  Copyright (c) 2014 Seven Layer Games. All rights reserved.
//

#import "AIActor.h"

@implementation AIActor
{
    NSObject<AIBehaving>*   _behavior;
}

- (id) initWithBehavior:(NSObject<AIBehaving>*) behavior :(CCSprite*) sprt
{
    _behavior = behavior;
    self.sprite = sprt;
    return self;
}


- (id) addPhysics:(CGPoint)position :(CCPhysicsBody*)body :(NSString*)group :(NSString*)type
{
    self.sprite.position = position;
    self.sprite.physicsBody = body;
    self.sprite.physicsBody.collisionGroup = group;
    self.sprite.physicsBody.collisionType = type;
    return self;
}

- (void) startAI
{
    [self.sprite runAction:[_behavior generateAIAction]];
}

- (void) stopAI
{
    [self.sprite stopAllActions];
}

@end
