//
//  ControlScene.h
//  Aquila
//
//  Created by Jcard on 2/26/14.
//  Copyright 2014 Seven Layer Games. All rights reserved.
//

#import "cocos2d.h"
#import "cocos2d-ui.h"

// -----------------------------------------------------------------------

/**
 *  The main scene
 */
@interface ControlScene : CCScene <CCPhysicsCollisionDelegate>

// -----------------------------------------------------------------------

+ (ControlScene *)scene;
- (id)init;

- (void)solvedCrystals;

// -----------------------------------------------------------------------
@end