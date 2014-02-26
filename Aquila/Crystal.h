//
//  Crystal.h
//  Aquila
//
//  Created by Jcard on 2/25/14.
//  Copyright 2014 Seven Layer Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CrystalSet.h"

// -----------------------------------------------------------------------
// Types of effects applied to the spheres
typedef NS_ENUM(NSInteger, CrystalState)
{
    Off,
    On
};

// -----------------------------------------------------------------------

@interface Crystal : CCSprite

// -----------------------------------------------------------------------

@property (nonatomic, readonly, assign) CrystalState state;
@property (nonatomic, assign) CrystalSet* crystalSet;
@property (nonatomic, readonly, strong) NSArray* linkedCrystals;

// -----------------------------------------------------------------------

-(void)initCrystal: (CGPoint)position startState:(CrystalState) state crystalSet:(CrystalSet*) set;
-(void)flipState: (bool)flipOthers;
-(void)setLinks: (NSArray*) links;

@end