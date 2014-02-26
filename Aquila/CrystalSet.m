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
}

// -----------------------------------------------------------------------
#pragma mark - Create and Destroy
// -----------------------------------------------------------------------

+(instancetype)createCrystalSet: (NSArray*) positions initialStates:(NSArray*) states physicsNode:(CCPhysicsNode*) physics {
    return([[CrystalSet alloc] initCrystalSet:positions initialStates:states physicsNode:physics]);
}

-(instancetype)initCrystalSet:(NSArray*) positions initialStates:(NSArray*) states physicsNode:(CCPhysicsNode*) physics {
    // Apple recommend assigning self with supers return value, and handling self not created
    self = [super init];
    if (!self) return(nil);
    
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
        [c initCrystal: position startState:state];
        [crystals addObject:c];
        [physics addChild:c];
    }
    
    return self;
}

- (void)dealloc
{
    CCLOG(@"CrystalSet was deallocated");
    // clean up code goes here, should there be any
    
}

// -----------------------------------------------------------------------
#pragma mark - Instance methods
// -----------------------------------------------------------------------
- (void)incrementOn {
    numOff--;
    if (numOff == 0) {
        //TODO: call some event handler that all crystals are on
    }
}

- (void)incrementOff {
    numOff++;
}

@end
