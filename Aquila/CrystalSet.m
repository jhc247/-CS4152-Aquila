//
//  CrystalSet.m
//  Aquila
//
//  Created by Jcard on 2/25/14.
//  Copyright 2014 Seven Layer Games. All rights reserved.
//

#import "CrystalSet.h"
#import "Crystal.h"

// -----------------------------------------------------------------------
#pragma mark CrystalSet
// -----------------------------------------------------------------------

@implementation CrystalSet {
    NSMutableArray *crystals;
    int numOff;
    DemoScene* scene;
}

// -----------------------------------------------------------------------
#pragma mark - Create and Destroy
// -----------------------------------------------------------------------

+(instancetype)createCrystalSet: (NSArray*) positions initialStates:(NSArray*) states physicsNode:(CCPhysicsNode*) physics linkedCrystals:(NSArray*) links level:(DemoScene*) lvl {
    return([[CrystalSet alloc] initCrystalSet:positions initialStates:states physicsNode:physics linkedCrystals:links level:lvl]);
}

-(instancetype)initCrystalSet:(NSArray*) positions initialStates:(NSArray*) states physicsNode:(CCPhysicsNode*) physics linkedCrystals:(NSArray*) links level:(DemoScene*) lvl {
    // Apple recommend assigning self with supers return value, and handling self not created
    self = [super init];
    if (!self) return(nil);
    
    scene = lvl;
    crystals = [NSMutableArray array];
    numOff = 0;
    
    // Create crystals
    for (int i = 0; i < [positions count]; i++) {
        CGPoint position = [[positions objectAtIndex:i] CGPointValue];
        CrystalState state = [[states objectAtIndex:i] integerValue];
        if (state == Off) {
            numOff++;
        }
        
        NSString* image;
        image = state ? @"ice_crystal1.png" : @"ice_crystal_off1.png";
        Crystal *c = [Crystal spriteWithImageNamed:image];
        CCLOG(@"Created crystal at position %@ with state %d", NSStringFromCGPoint(position), state);
        [c initCrystal: position startState:state crystalSet:self];
        [crystals addObject:c];
        [physics addChild:c];
    }
    for (int i = 0; i < [links count]; i++) {
        Crystal *c = [crystals objectAtIndex:i];
        NSMutableArray *lnks = [[NSMutableArray alloc] init];
        
        for (id crys in [links objectAtIndex:i]) {
            int crysNum = [crys integerValue];
            [lnks addObject:[crystals objectAtIndex:crysNum]];
        }
        [c setLinks:lnks];
    }
    return self;
}

- (void)dealloc
{
    CCLOG(@"CrystalSet was deallocated");
    // clean up code goes here, should there be any
    
}

- (void)incrementOn {
    CCLOG(@"Num off: %d", numOff);
    numOff--;
}

- (void)incrementOff {
    CCLOG(@"Num off: %d", numOff);
    numOff++;
}

- (void)isSolved {
    if (numOff == 0) {
        [scene solvedCrystals];
    }
}

@end
