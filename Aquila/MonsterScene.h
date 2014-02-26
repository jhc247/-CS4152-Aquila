//
//  MonsterScene.h
//  Aquila
//
//  Created by Jcard on 2/26/14.
//  Copyright 2014 Seven Layer Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// -----------------------------------------------------------------------

/**
 *  The main scene
 */
@interface MonsterScene : CCScene <CCPhysicsCollisionDelegate>

// -----------------------------------------------------------------------

+ (MonsterScene *)scene;
- (id)init;

- (void)solvedCrystals;

// -----------------------------------------------------------------------
@end