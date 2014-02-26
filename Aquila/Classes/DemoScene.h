//
//  HelloWorldScene.h
//  Aquila
//
//  Created by Jcard on 2/21/14.
//  Copyright Seven Layer Games 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using Cocos2D v3
#import "cocos2d.h"
#import "cocos2d-ui.h"

// -----------------------------------------------------------------------

/**
 *  The main scene
 */
@interface DemoScene : CCScene <CCPhysicsCollisionDelegate>

// -----------------------------------------------------------------------

+ (DemoScene *)scene;
- (id)init;

- (void)solvedCrystals;

// -----------------------------------------------------------------------
@end