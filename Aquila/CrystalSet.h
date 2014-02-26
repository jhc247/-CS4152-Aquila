//
//  CrystalSet.h
//  Aquila
//
//  Created by Jcard on 2/25/14.
//  Copyright 2014 Seven Layer Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// -----------------------------------------------------------------------

@interface CrystalSet : NSObject

// -----------------------------------------------------------------------

+ (instancetype)createCrystalSet: (NSArray*) positions initialStates:(NSArray*) states physicsNode:(CCPhysicsNode*) physics;
- (instancetype)initCrystalSet: (NSArray*) positions initialStates:(NSArray*) states physicsNode:(CCPhysicsNode*) physics;

- (void)incrementOn;
- (void)incrementOff;

@end