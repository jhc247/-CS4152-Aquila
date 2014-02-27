//
//  Level.h
//  Aquila
//
//  Created by Jcard on 2/26/14.
//  Copyright (c) 2014 Seven Layer Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// -----------------------------------------------------------------------

@interface LevelScene : CCScene <CCPhysicsCollisionDelegate>

// -----------------------------------------------------------------------

@property (nonatomic, readonly, assign) CGPoint AquilaStart;
@property (nonatomic, assign) int** enemies;
@property (nonatomic, strong) NSArray *crystals;


// -----------------------------------------------------------------------

+ (LevelScene *)scene;
- (id)init;

// Tutorial on how to save persistent data
//http://bobueland.com/cocos2d/2011/how-to-save-data-in-a-plist/

@end