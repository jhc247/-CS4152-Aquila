//
//  DemoScene.m
//  Aquila
//
//  Created by Jcard on 2/21/14.
//  Copyright Seven Layer Games 2014. All rights reserved.
//
// -----------------------------------------------------------------------

#import "DemoScene.h"
#import "IntroScene.h"
#import "NewtonScene.h"
#import "Constants.h"
#import "CCDrawingPrimitives.h"
#import "CCSprite.h"
#import "CCActionInstant.h"

// -----------------------------------------------------------------------
#pragma mark - DemoScene
// -----------------------------------------------------------------------

@implementation DemoScene
{
    CCSprite *_aquila;
    CCPhysicsNode *_physicsWorld;
    CCSprite *_dumbmonster;
    CCSprite *_followmonster;
    
    bool green;
    CCSprite *greencircle;
    CCSprite *redcircle;
    
    CCAction *currentAction;
    CGPoint touchStart;
    CGPoint touchEnd;
    bool walking;
    bool ignore;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (DemoScene *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
    [self addChild:background];
    background.zOrder = 0;
    
    // Create physics
    _physicsWorld = [CCPhysicsNode node];
    _physicsWorld.gravity = ccp(0,0);
    _physicsWorld.debugDraw = NO;
    _physicsWorld.collisionDelegate = self;
    [self addChild:_physicsWorld];
    
    // Add green circle
    greencircle = [CCSprite spriteWithImageNamed:@"Circle.png"];
    greencircle.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
    greencircle.zOrder = 1;
    greencircle.opacity = .2f;
    
    // Add red circle
    redcircle = [CCSprite spriteWithImageNamed:@"redcircle.png"];
    redcircle.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
    redcircle.zOrder = 1;
    redcircle.opacity = .2f;
    
    // Add Aquila
    _aquila = [CCSprite spriteWithImageNamed:@"sword.png"];
    _aquila.position  = ccp(self.contentSize.width/2,self.contentSize.height/2);
    _aquila.zOrder = 5;
    _aquila.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _aquila.contentSize} cornerRadius:0]; // 1
    _aquila.physicsBody.collisionGroup = @"playerGroup";
    //_aquila.rotation = 45;
    [_physicsWorld addChild:_aquila];
    
    // Add dumb monster
    _dumbmonster = [CCSprite spriteWithImageNamed:@"megagrunt.png"];
    _dumbmonster.position = ccp(self.contentSize.width/5,self.contentSize.height/5);
    _dumbmonster.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _dumbmonster.contentSize} cornerRadius:0];
    _dumbmonster.physicsBody.collisionGroup = @"enemyGroup";
    [_physicsWorld addChild:_dumbmonster];
    
    // Add follow monster
    _followmonster = [CCSprite spriteWithImageNamed:@"monster2.png"];
    _followmonster.position = ccp(3*self.contentSize.width/5,4*self.contentSize.height/5);
    _followmonster.physicsBody = [CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _followmonster.contentSize} cornerRadius:0];
    _followmonster.physicsBody.collisionGroup = @"enemyGroup";
    [_physicsWorld addChild:_followmonster];
    
    // Create a back button
    CCButton *backButton = [CCButton buttonWithTitle:@"[ Menu ]" fontName:@"Verdana-Bold" fontSize:18.0f];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.95f, 0.95f); // Top Right of screen
    [backButton setTarget:self selector:@selector(onBackClicked:)];
    [self addChild:backButton];
    
    // Create a debug button
    CCButton *debugButton = [CCButton buttonWithTitle:@"Enable Debug" fontName:@"Verdana-Bold" fontSize:18.0f];
    debugButton.positionType = CCPositionTypeNormalized;
    debugButton.position = ccp(0.90f, 0.05f); // Bottom Right of screen
    [debugButton setTarget:self selector:@selector(onDebugClicked:)];
    [self addChild:debugButton];

    currentAction = NULL;
    walking = false;
    ignore = false;
    // done
	return self;
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInterActionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
}

// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}

- (void)doneWalking {
    walking = false;
    currentAction = NULL;
    CCLOG(@"%s", "done walking");
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    /*CGPoint touchLoc = [touch locationInNode:self];
    // Walk implementation:
    
    if (currentAction != NULL) {
        [_aquila stopAction: currentAction];
    }
    // Log touch location
    CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
        
    // Move our sprite to touch location
    CGPoint start = _aquila.position;
    CGPoint end = touchLoc;
    float distance = ccpDistance(start, end);
    float duration = distance/300; // AQUILA_SPEED
    CCActionMoveTo *walkMove = [CCActionMoveTo  actionWithDuration:duration position:touchLoc];
    
    currentAction = [_aquila runAction:walkMove]; */

    CCLOG(@"Current action: %@", currentAction.description);
    if (currentAction == NULL || currentAction.isDone || walking) {
        [_aquila stopAllActions];
        touchStart = [touch locationInNode:self];
        float distance = ccpDistance(_aquila.position, touchStart);
        if (distance > FLICK_LENGTH) {
            /*float duration = distance/AQUILA_WALK_SPEED;
            walking = true;
            CCAction *walkMove = [CCActionMoveTo  actionWithDuration:duration position:touchStart];
            CCActionCallFunc *update_status = [CCActionCallFunc actionWithTarget:self selector:NSSelectorFromString(@"doneWalking")];
            CCActionSequence *actions = [CCActionSequence actionWithArray:@[walkMove, update_status]];
            [_aquila runAction: actions];*/
            redcircle.position = _aquila.position;
            green = false;
            [self addChild:redcircle];
        }
        else {
            greencircle.position = _aquila.position;
            green = true;
            [self addChild:greencircle];
        }
    }
    else {
        ignore = true;
    }
    
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (ignore) {
        ignore = false;
        return;
    }
    if (green) {
        [self removeChild:greencircle];
    }
    else {
        [self removeChild:redcircle];
    }
    
    touchEnd = [touch locationInNode:self];
    float touchDistance = ccpDistance(touchStart, touchEnd);
    CGPoint start = _aquila.position;
    float distance = ccpDistance(start, touchEnd);
    if (touchDistance < FLICK_TRESHHOLD || !green) { // WALK
        // Move our sprite to touch location
        float xchange = touchEnd.x - _aquila.position.x;
        float ychange = touchEnd.y - _aquila.position.y;
        float angle;
        if (distance == 0) {
            return;
        }
        angle = CC_RADIANS_TO_DEGREES(atanf(ychange/xchange));
        float angle_degrees;
        CCLOG(@"%s", "-------------------");
        CCLOG(@"Y-Change: %f", ychange);
        CCLOG(@"X-Change: %f", xchange);
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
        CCLOG(@"Angle Degrees: %f", angle_degrees);
        CCLOG(@"FLICK*COS: %f", FLICK_LENGTH*cos(angle_radians));
        CCLOG(@"FLICK*SIN %f", FLICK_LENGTH*sin(angle_radians));
        float updated_initial_rotation = fmodf(_aquila.rotation, 360);
        _aquila.rotation = updated_initial_rotation;
        float angle_change = fmodf(fmodf(-1*angle_degrees, 360) - updated_initial_rotation, 360) - 45;
        if (angle_change > 180 || angle_change < -180) {
            angle_change = 360 - fabsf(angle_change);
        }
        
        
        float duration = distance/AQUILA_WALK_SPEED;
        walking = true;
        CCAction *walkMove = [CCActionMoveTo  actionWithDuration:duration position:touchEnd];
        CCActionRotateBy* actionSpin = [CCActionRotateBy actionWithDuration:0.3f angle:
                                        angle_change];
        CCActionCallFunc *update_status = [CCActionCallFunc actionWithTarget:self selector:NSSelectorFromString(@"doneWalking")];
        CCActionSequence *actions = [CCActionSequence actionWithArray:@[walkMove, update_status]];
        [_aquila runAction: actionSpin];
        [_aquila runAction: actions];
        // Log touch location
        CCLOG(@"Aquila walking to @ %@",NSStringFromCGPoint(touchEnd));
        
    }
    else { // SLASH
        float xchange = touchEnd.x - touchStart.x;
        float ychange = touchEnd.y - touchStart.y;
        
        float angle= CC_RADIANS_TO_DEGREES(atanf(ychange/xchange));
        float angle_degrees;
        CCLOG(@"%s", "-------------------");
        CCLOG(@"Y-Change: %f", ychange);
        CCLOG(@"X-Change: %f", xchange);
        
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
        CCLOG(@"Angle Degrees: %f", angle_degrees);
        CCLOG(@"FLICK*COS: %f", FLICK_LENGTH*cos(angle_radians));
        CCLOG(@"FLICK*SIN %f", FLICK_LENGTH*sin(angle_radians));
        float endX = start.x + FLICK_LENGTH*cos(angle_radians);
        float endY = start.y + FLICK_LENGTH*sin(angle_radians);
        CGPoint endPoint = ccp(endX, endY);
        distance = ccpDistance(start, endPoint);
        float duration = distance/AQUILA_FLICK_SPEED;
        float updated_initial_rotation = fmodf(_aquila.rotation, 360);
        _aquila.rotation = updated_initial_rotation;
        float angle_change = fmodf(fmodf(-1*angle_degrees, 360) - updated_initial_rotation, 360) - 45;
        if (angle_change > 180 || angle_change < -180) {
            angle_change = 360 - fabsf(angle_change);
        }
        CCLOG(@"Initial angle: %f", updated_initial_rotation);
        CCLOG(@"Target angle: %f", angle_degrees);
        CCLOG(@"Angle Change: %f", angle_change);
        CCActionMoveTo *flickMove = [CCActionMoveTo  actionWithDuration:duration position:endPoint];
        CCActionRotateBy* actionSpin = [CCActionRotateBy actionWithDuration:duration/2 angle:
                                        angle_change];
        currentAction = [_aquila runAction: flickMove];
        [_aquila runAction: actionSpin];
        
        // Log touch location
        CCLOG(@"Aquila slashing to %@",NSStringFromCGPoint(endPoint));
    }
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}

- (void)onDebugClicked:(id)sender
{
    
    if (_physicsWorld.debugDraw == true) {
        _physicsWorld.debugDraw = NO;
        CCLOG(@"%s", "Was YES, now NO");
    }
    else if (_physicsWorld.debugDraw == false) {
        _physicsWorld.debugDraw = YES;
        CCLOG(@"%s", "Was NO, now YES");
        
    }
    else {
        CCLOG(@"%s", "wtf");
    }
}

// -----------------------------------------------------------------------
@end
