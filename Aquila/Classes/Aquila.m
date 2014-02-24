//
//  Aquila.h
//  Aquila
//
//  Created by Jcard on 2/24/14.
//  Copyright (c) 2014 Seven Layer Games. All rights reserved.
//

#import "Aquila.h"
#import "Constants.h"

// -----------------------------------------------------------------------
#pragma mark Aquila
// -----------------------------------------------------------------------

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
    // Apple recommend assigning self with supers return value, and handling self not created
    
    // enable touch for Aquila
    self.userInteractionEnabled = YES;
    
    self.position = position;
    self.zOrder = 5;
    
    // Create physics body
    CCPhysicsBody *body = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, self.contentSize} cornerRadius:0];
    body.type = CCPhysicsBodyTypeDynamic;
    body.collisionCategories = @[CollisionAquila];
    body.collisionMask = @[];
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
}

// -----------------------------------------------------------------------
#pragma mark - Touch implementation
// -----------------------------------------------------------------------

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    // convert the touch into parents coordinate system
    // This is often the same as the world location, but if the scene is ex, scaled or offset, it might not be
    CCLOG(@"Aquila was touched");
    //CGPoint parentPos = [_parent convertToNodeSpace:touch.locationInWorld];
    if (self.state == Standing || self.state == Walking) {
        _grabbed = YES;
        [self stopAllActions];
        greencircle.position = self.position;
        [_parent addChild:greencircle];
    }
    else {
        
    }
    
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    /*// convert the touch into parents coordinate system
    // This is often the same as the world location, but if the scene is ex, scaled or offset, it might not be
    CGPoint parentPos = [_parent convertToNodeSpace:touch.locationInWorld];
    
    // on each move, calculate a velocity used in update, and save new state data
    _previousVelocity = ccpMult( ccpSub(parentPos, _previousPos), 1 / (event.timestamp - _previousTime));
    _previousTime = event.timestamp;
    _previousPos = parentPos;*/
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
        float distance = ccpDistance(start, touchEnd);
        float xchange = touchEnd.x - start.x;
        float ychange = touchEnd.y - start.y;
        
        float angle= CC_RADIANS_TO_DEGREES(atanf(ychange/xchange));
        float angle_degrees;
        //CCLOG(@"%s", "-------------------");
        //CCLOG(@"Y-Change: %f", ychange);
        //CCLOG(@"X-Change: %f", xchange);
        
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
        //CCLOG(@"Angle Degrees: %f", angle_degrees);
        //CCLOG(@"FLICK*COS: %f", FLICK_LENGTH*cos(angle_radians));
        //CCLOG(@"FLICK*SIN %f", FLICK_LENGTH*sin(angle_radians));
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
        //CCLOG(@"Initial angle: %f", updated_initial_rotation);
        //CCLOG(@"Target angle: %f", angle_degrees);
        //CCLOG(@"Angle Change: %f", angle_change);
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

@end