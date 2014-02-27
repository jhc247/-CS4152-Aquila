//
//  CrystalSet.h
//  Aquila
//
//  Created by Jcard on 2/25/14.
//  Copyright 2014 Seven Layer Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LevelScene.h"

// -----------------------------------------------------------------------

@interface CrystalSet : NSObject

// -----------------------------------------------------------------------

+ (instancetype)createCrystalSet: (NSArray*) positions initialStates:(NSArray*) states physicsNode:(CCPhysicsNode*) physics linkedCrystals:(NSArray*) links level:(LevelScene*) lvl;

- (instancetype)initCrystalSet: (NSArray*) positions initialStates:(NSArray*) states physicsNode:(CCPhysicsNode*) physics linkedCrystals:(NSArray*) links level:(LevelScene*) lvl;

- (void)incrementOn;
- (void)incrementOff;
- (BOOL)doSomething;
- (void)roundDone;

@end