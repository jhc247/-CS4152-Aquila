//
//  PhysicsCollisionDelegate.h
//  Aquila
//
//  Created by Jcard on 2/26/14.
//  Copyright 2014 Seven Layer Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Aquila.h"
#import "AIActor.h"
#import "Crystal.h"

static NSString* const aquilaCollisionType = @"aquilaCollision";
static NSString* const monsterCollisionType = @"monsterCollision";
static NSString* const crystalCollisionType = @"crystalCollision";


@interface PhysicsCollisionDelegate : NSObject <CCPhysicsCollisionDelegate>

+ (PhysicsCollisionDelegate*) delegate;

// Aquila Collisions
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair aquilaCollision:(Aquila *)aquila Monster:(AIActor *)monster;
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair aquilaCollision:(Aquila *)aquila crystalCollision:(Crystal *)crystal;


@end
