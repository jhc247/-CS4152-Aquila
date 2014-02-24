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
    CCSprite *AOEcircle;
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
    
    // Add circle
    AOEcircle = [CCSprite spriteWithImageNamed:@"Circle.png"];
    AOEcircle.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
    AOEcircle.zOrder = 1;
    AOEcircle.opacity = .2f;
    
    // Add Aquila
    _aquila = [CCSprite spriteWithImageNamed:@"sword.png"];
    _aquila.position  = ccp(self.contentSize.width/2,self.contentSize.height/2);
    [self addChild:_aquila];
    _aquila.zOrder = 5;
    
    // Create a back button
    CCButton *backButton = [CCButton buttonWithTitle:@"[ Menu ]" fontName:@"Verdana-Bold" fontSize:18.0f];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.95f, 0.95f); // Top Right of screen
    [backButton setTarget:self selector:@selector(onBackClicked:)];
    [self addChild:backButton];

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

    CCLOG(@"Current action: %s", currentAction.description);
    if (currentAction == NULL || currentAction.isDone || walking) {
        [_aquila stopAllActions];
        touchStart = [touch locationInNode:self];
        /*float distance = ccpDistance(_aquila.position, touchStart);
        if (distance > FLICK_LENGTH) {
            float duration = distance/AQUILA_WALK_SPEED;
            walking = true;
            CCAction *walkMove = [CCActionMoveTo  actionWithDuration:duration position:touchStart];
            CCActionCallFunc *update_status = [CCActionCallFunc actionWithTarget:self selector:NSSelectorFromString(@"doneWalking")];
            CCActionSequence *actions = [CCActionSequence actionWithArray:@[walkMove, update_status]];
            [_aquila runAction: actions];
        }*/
        AOEcircle.position = _aquila.position;
        [self addChild:AOEcircle];
    }
    else {
        ignore = true;
    }
    
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self removeChild:AOEcircle];
    if (ignore) {
        ignore = false;
        return;
    }
    touchEnd = [touch locationInNode:self];
    float touchDistance = ccpDistance(touchStart, touchEnd);
    CGPoint start = _aquila.position;
    float distance = ccpDistance(start, touchEnd);
    if (touchDistance < FLICK_TRESHHOLD) { // WALK
        // Move our sprite to touch location
        float duration = distance/AQUILA_WALK_SPEED;
        walking = true;
        CCAction *walkMove = [CCActionMoveTo  actionWithDuration:duration position:touchEnd];
        CCActionCallFunc *update_status = [CCActionCallFunc actionWithTarget:self selector:NSSelectorFromString(@"doneWalking")];
        CCActionSequence *actions = [CCActionSequence actionWithArray:@[walkMove, update_status]];
        [_aquila runAction: actions];
        // Log touch location
        CCLOG(@"Aquila walking to @ %@",NSStringFromCGPoint(touchEnd));
        
    }
    else { // SLASH
        float xchange = touchEnd.x - touchStart.x;
        float ychange = touchEnd.y - touchStart.y;
        float angle = atanf(ychange/xchange);
        CCLOG(@"Angle: %4.2f", angle);
        float endX;
        float endY;
        if (xchange > 0) {
            endX = start.x + fabsf(FLICK_LENGTH*cos(angle));
        }
        else {
            endX = start.x - fabsf(FLICK_LENGTH*cos(angle));
        }
        if (ychange > 0) {
            endY = start.y + fabsf(FLICK_LENGTH*sin(angle));
        }
        else {
            endY = start.y - fabsf(FLICK_LENGTH*sin(angle));
        }
        CGPoint endPoint = ccp(endX, endY);
        distance = ccpDistance(start, endPoint);
        float duration = distance/AQUILA_FLICK_SPEED;
        CCActionMoveTo *flickMove = [CCActionMoveTo  actionWithDuration:duration position:endPoint];
        currentAction = [_aquila runAction:flickMove];
        
        // Log touch location
        CCLOG(@"Aquila slashing to @ %@",NSStringFromCGPoint(endPoint));
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


// -----------------------------------------------------------------------
@end
