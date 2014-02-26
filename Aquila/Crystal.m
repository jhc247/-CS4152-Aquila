//
//  Crystal.m
//  Aquila
//
//  Created by Jcard on 2/25/14.
//  Copyright 2014 Seven Layer Games. All rights reserved.
//

#import "Crystal.h"
#import "Constants.h"


// -----------------------------------------------------------------------
#pragma mark Crystal
// -----------------------------------------------------------------------
@interface Crystal()
@property (nonatomic, readwrite, assign) CrystalState state; //sets setState() to private readwrite access


@end

@implementation Crystal : CCSprite

    

// -----------------------------------------------------------------------
#pragma mark - Create and Destroy
// -----------------------------------------------------------------------

-(void)initCrystal: (CGPoint)position startState:(CrystalState) state {
    // Apple recommend assigning self with supers return value, and handling self not created
    //CCLOG(@"Position: %@", NSStringFromCGPoint(position));
    self.position = position;
    
    // Create physics body
    CCPhysicsBody *body = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, self.contentSize} cornerRadius:0.0f];
    body.collisionType = @"crystalCollision";
    body.collisionGroup = @"crystalGroup";
    body.mass = CRYSTAL_MASS;
    
    
    self.physicsBody = body;
    self.state = state;
}

- (void)dealloc
{
    CCLOG(@"Crystal was deallocated");
    // clean up code goes here, should there be any
    
}


// -----------------------------------------------------------------------
#pragma mark - Property implementation
// -----------------------------------------------------------------------


-(void)flipState {
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
}
// -----------------------------------------------------------------------

@end
