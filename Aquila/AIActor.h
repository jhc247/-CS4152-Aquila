//
//  AIActor.h
//  Aquila
//
//  Created by Jose Hirshman on 2/25/14.
//  Copyright (c) 2014 Seven Layer Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AIBehaving.h"

// -----------------------------------------------------------------------
// Types of effects applied to the spheres
typedef NS_ENUM(NSInteger, AIState)
{
    Stunned,
    Normal
};

// -----------------------------------------------------------------------

@interface AIActor : NSObject

// -----------------------------------------------------------------------

@property (nonatomic, assign) AIState   state;
@property (nonatomic, assign) CCSprite*  sprite;

- (id) initWithBehavior:(NSObject<AIBehaving>*) behavior :(CCSprite*) sprt;
- (id) addPhysics:(CGPoint)position :(CCPhysicsBody*)body :(NSString*)group :(NSString*)type;
- (void) startAI;
- (void) stopAI;

@end
