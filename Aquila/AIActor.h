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
#

// -----------------------------------------------------------------------
// Types of effects applied to the spheres
typedef NS_ENUM(NSInteger, AIState)
{
    Stunned,
    Normal
};

// -----------------------------------------------------------------------

@interface AIActor : CCSprite

// -----------------------------------------------------------------------

@property (nonatomic, assign) AIState state;

- (void) initWithBehavior:(NSObject<AIBehaving>*) behavior :(CGPoint)position normalSprite:(NSString*) normal stunnedSprite:(NSString*) stunned;
- (void) startAI;
- (void) restartAI;
- (void) stopAI;
- (void) stun;

@end
