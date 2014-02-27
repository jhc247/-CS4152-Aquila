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
// Types of effects applied to the enemies
typedef NS_ENUM(NSInteger, AIState)
{
    Stunned,
    Normal
};

// Types of enemy
typedef NS_ENUM(NSInteger, EnemyType) {
    Megagrunt,
    Game_N_Watch
};

// -----------------------------------------------------------------------

@interface AIActor : CCSprite

// -----------------------------------------------------------------------

@property (nonatomic, assign) AIState state;
@property (nonatomic, assign) EnemyType type;

+ (NSString*) getSprite:(EnemyType)type state:(AIState)state;

- (void) initWithBehavior:(NSObject<AIBehaving>*) behavior :(CGPoint)position type:(EnemyType)type;
- (void) startAI;
- (void) restartAI;
- (void) stopAI;
- (void) stun;

@end
