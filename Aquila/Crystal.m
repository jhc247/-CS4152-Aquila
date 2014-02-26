//
//  Crystal.m
//  Aquila
//
//  Created by Jcard on 2/25/14.
//  Copyright 2014 Seven Layer Games. All rights reserved.
//

#import "Crystal.h"
#import "CrystalSet.h"
#import "Constants.h"


// -----------------------------------------------------------------------
#pragma mark Crystal
// -----------------------------------------------------------------------
@interface Crystal()
@property (nonatomic, readwrite, assign) CrystalState state; //sets setState() to private readwrite access
@property (nonatomic, readwrite, strong) NSArray* linkedCrystals;


@end

@implementation Crystal : CCSprite

    

// -----------------------------------------------------------------------
#pragma mark - Create and Destroy
// -----------------------------------------------------------------------

-(void)initCrystal: (CGPoint)position startState:(CrystalState) state crystalSet:(CrystalSet*) set {
    self.position = position;
    
    // Create physics body
    CCPhysicsBody *body = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, self.contentSize} cornerRadius:0.0f];
    body.collisionType = @"crystalCollision";
    body.collisionGroup = @"crystalGroup";
    body.mass = CRYSTAL_MASS;
    
    self.physicsBody = body;
    self.state = state;
    self.crystalSet = set;
}

- (void)dealloc
{
    CCLOG(@"Crystal was deallocated");
    // clean up code goes here, should there be any
    
}

-(void)setLinks: (NSArray*) links {
    self.linkedCrystals = [NSArray arrayWithArray:links];
}

// -----------------------------------------------------------------------
#pragma mark - Property implementation
// -----------------------------------------------------------------------


-(void)flipState: (bool)flipOthers  {
    NSString* newSprite;
    if (self.state == On) {
        self.state = Off;
        [_crystalSet incrementOff];
        newSprite = @"ice_crystal_off1.png";
    }
    else {
        self.state = On;
        [_crystalSet incrementOn];
        newSprite = @"ice_crystal1.png";
    }
    [self setTexture:[[CCSprite spriteWithImageNamed:newSprite] texture]];
    if (flipOthers) {
        for (id obj in [self linkedCrystals]) {
            Crystal* c = obj;
            [c flipState:false];
        }
    }
    [_crystalSet isSolved];

}
// -----------------------------------------------------------------------

@end
