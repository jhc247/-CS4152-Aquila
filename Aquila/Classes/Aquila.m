//
//  Aquila.h
//  Aquila
//
//  Created by Jcard on 2/24/14.
//  Copyright (c) 2014 Seven Layer Games. All rights reserved.
//

#import "Aquila.h"
#import "Constants.h"
#import "PhysicsCollisionDelegate.h"

// -----------------------------------------------------------------------
#pragma mark Aquila
// -----------------------------------------------------------------------

@interface Aquila()

@property (nonatomic, readwrite, assign) AquilaState state; //sets setState() to private access

@end

@implementation Aquila {
    BOOL _grabbed;
    NSTimeInterval _previousTime;
    CGPoint _previousVelocity;
    CGPoint _previousPos;
    
    CCSprite *greencircle;
}

// -----------------------------------------------------------------------
#pragma mark - Create and Destroy
// -----------------------------------------------------------------------


- (void)dealloc
{
    CCLOG(@"Aquila was deallocated");
    // clean up code goes here, should there be any
    
}

-(void)initAquila: (CGPoint) position {
    
    // enable touch for Aquila
    self.userInteractionEnabled = YES;
    
    self.position = position;
    self.zOrder = 1;
    
    // Create physics body
    CCPhysicsBody *body = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, self.contentSize} cornerRadius:0.0f];
    body.collisionType = aquilaCollisionType;
    body.collisionGroup = @"aquilaGroup";
    body.mass = AQUILA_MASS;
    
    self.physicsBody = body;
    self.state = Standing;
    
    // Create green circle
    greencircle = [CCSprite spriteWithImageNamed:@"Circle.png"];
    greencircle.position = position;
    greencircle.zOrder = 1;
    greencircle.opacity = .2f;

}

- (void) update:(CCTime)delta {
    //CCLOG(@"Updating");
    
}

- (void)doneDashing {
    self.state = Standing;
    CCLOG(@"Done dashing");
    CCLOG(@"Aquila location: %@", NSStringFromCGPoint([_parent convertToWorldSpace:self.position]));
}

// -----------------------------------------------------------------------
#pragma mark - Touch implementation
// -----------------------------------------------------------------------

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.state == Standing || self.state == Walking) {
        _grabbed = YES;
        [self stopAllActions];
        greencircle.position = self.position;
        [_parent addChild:greencircle];
    }
    else {
        
    }
    
    return;
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    return;
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_grabbed) {
        [_parent removeChild:greencircle];
        _grabbed = NO;
        CGPoint touchEnd = [touch locationInNode:_parent];
        CGPoint start = self.position;
        float touchDistance = ccpDistance(touchEnd, start);
        if (touchDistance < FLICK_TRESHHOLD) {
            return;
        }
        self.state = Dashing;
        
        // Calculate angle, distance and actions 
        float distance = ccpDistance(start, touchEnd);
        float xchange = touchEnd.x - start.x;
        float ychange = touchEnd.y - start.y;
        float angle= CC_RADIANS_TO_DEGREES(atanf(ychange/xchange));
        float angle_degrees;
        
        if (ychange >= 0) {
            if (xchange >= 0) {
                angle_degrees = angle;
            }
            else {
                angle_degrees = 180 + angle;
            }
        }
        else {
            if (xchange >= 0) {
                angle_degrees = 360 + angle;
            }
            else {
                angle_degrees = 180 + angle;
            }
        }
        float angle_radians = CC_DEGREES_TO_RADIANS(angle_degrees);
        float endX = start.x + FLICK_LENGTH*cos(angle_radians);
        float endY = start.y + FLICK_LENGTH*sin(angle_radians);
        CGPoint endPoint = ccp(endX, endY);
        distance = ccpDistance(start, endPoint);
        float duration = distance/AQUILA_FLICK_SPEED;
        float updated_initial_rotation = fmodf(self.rotation, 360);
        self.rotation = updated_initial_rotation;
        float angle_change = fmodf(fmodf(-1*angle_degrees, 360) - updated_initial_rotation, 360) - 45;
        if (angle_change > 180 || angle_change < -180) {
            angle_change = 360 - fabsf(angle_change);
        }
        
        CCActionMoveTo *flickMove = [CCActionMoveTo  actionWithDuration:duration position:endPoint];
        CCActionRotateBy *actionSpin = [CCActionRotateBy actionWithDuration:duration/2 angle:
                                        angle_change];
        CCActionCallFunc *done_dashing = [CCActionCallFunc actionWithTarget:(self) selector:@selector(doneDashing)];
        CCActionSequence *dash = [CCActionSequence actionWithArray:@[flickMove, done_dashing]];
        [self runAction: dash];
        [self runAction: actionSpin];
        
        // Log touch location
        CCLOG(@"Aquila slashing to %@",NSStringFromCGPoint(endPoint));
    }
    // if not grabbed anymore, return mass to normal
    _grabbed = NO;
}

- (void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self touchEnded:touch withEvent:event];
}

// -----------------------------------------------------------------------
#pragma mark - State Manipulators implementation
// -----------------------------------------------------------------------
- (void) stand {
    [self stopAllActions];
    _state = Standing;
}

- (void) walk:(CCActionMoveTo*)move rotate:(CCActionRotateTo*)rotate; {
    [self stopAllActions];
    _state = Walking;
    CCActionCallFunc *update_status = [CCActionCallFunc actionWithTarget:self selector:NSSelectorFromString(@"doneWalking")];
    CCActionSequence *actions = [CCActionSequence actionWithArray:@[move, update_status]];
    [self runAction: rotate];
    [self runAction: actions];
}

- (void) dash {
    
}

- (void) die {
    [self runAction: [CCActionRemove action]];
    // Deallocate?
}

- (void)doneWalking {
    [self stand];
}

@end