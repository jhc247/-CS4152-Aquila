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
#import "Aquila.h"
#import "AIActor.h"
#import "PatrollingAIBehavior.h"

// -----------------------------------------------------------------------
#pragma mark - DemoScene
// -----------------------------------------------------------------------

@implementation DemoScene
{
    Aquila *_aquila;
    CCPhysicsNode *_physicsWorld;
    AIActor *_dumbmonster;
    
    bool green;
    CCSprite *greencircle;
    CCSprite *redcircle;
    
    CGPoint touchStart;
    CGPoint touchEnd;
    bool walking;
    bool ignore;
    
    
    CGPoint walkTarget;
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
    _aquila = [Aquila spriteWithImageNamed:@"sword.png"];
    [_aquila initAquila: ccp(self.contentSize.width/2,self.contentSize.height/2)];
    [_physicsWorld addChild:_aquila];
    _aquila.currentWalk = NULL;
    
    // Add dumb monster
    CGPoint startPos = ccp(self.contentSize.width/5,self.contentSize.height/5);
    _dumbmonster = [[AIActor alloc] initWithBehavior:[[PatrollingAIBehavior alloc] initWithPoints :startPos
                                                                                                  :ccp(self.contentSize.width/5, 4*self.contentSize.height/5)]
                                                    :[CCSprite spriteWithImageNamed:@"megagrunt.png"]];
    _dumbmonster = [_dumbmonster addPhysics    :startPos
                                :[CCPhysicsBody bodyWithRect:(CGRect){CGPointZero, _dumbmonster.sprite.contentSize} cornerRadius:0]
                                :@"monsterGroup"
                                :@"monsterCollision"];
    [_physicsWorld addChild:_dumbmonster.sprite];
    [_dumbmonster startAI];
    
    
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
    _aquila.currentWalk = NULL;
    CCLOG(@"%s", "done walking");
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (_aquila.state == Standing || _aquila.state == Walking) {
        _aquila.state = Walking;
        CGPoint targetPoint = [touch locationInNode:self];
        CGPoint startPoint = _aquila.position;
        walkTarget = targetPoint;
        float distance = ccpDistance(startPoint, targetPoint);
        float xchange = targetPoint.x - startPoint.x;
        float ychange = targetPoint.y - startPoint.y;
        float angle = CC_RADIANS_TO_DEGREES(atanf(ychange/xchange));
        if (ychange >= 0) {
            if (xchange >= 0) {
                angle = angle;
            }
            else {
                angle = 180 + angle;
            }
        }
        else {
            if (xchange >= 0) {
                angle = 360 + angle;
            }
            else {
                angle = 180 + angle;
            }
        }
        float updated_initial_rotation = fmodf(_aquila.rotation, 360);
        _aquila.rotation = updated_initial_rotation;
        float angle_change = fmodf(fmodf(-1*angle, 360) - updated_initial_rotation, 360) - 45;
        if (angle_change > 180 || angle_change < -180) {
            angle_change = 360 - fabsf(angle_change);
        }
        float duration = distance/AQUILA_WALK_SPEED;
        CCActionMoveTo *walkMove = [CCActionMoveTo  actionWithDuration:duration position:targetPoint];
        CCActionRotateBy* actionSpin = [CCActionRotateBy actionWithDuration:0.3f angle:
                                        angle_change];
        CCActionCallFunc *update_status = [CCActionCallFunc actionWithTarget:self selector:NSSelectorFromString(@"doneWalking")];
        CCActionSequence *actions = [CCActionSequence actionWithArray:@[walkMove, update_status]];
        
        [_aquila stopAllActions];
        [_aquila runAction: actionSpin];
        [_aquila runAction: actions];
        _aquila.currentWalk = actions;
        // Log touch location
        CCLOG(@"Aquila walking to @ %@",NSStringFromCGPoint(targetPoint));

    }    
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_aquila.state == Walking) {
        CGPoint targetPoint = [touch locationInNode:self];
        CGPoint startPoint = _aquila.position;
        float change = ccpDistance(targetPoint, walkTarget);
        if (change < WALK_THRESHOLD) {
            return;
        }
        walkTarget = targetPoint;
        float distance = ccpDistance(startPoint, targetPoint);
        float xchange = targetPoint.x - startPoint.x;
        float ychange = targetPoint.y - startPoint.y;
        float angle = CC_RADIANS_TO_DEGREES(atanf(ychange/xchange));
        if (ychange >= 0) {
            if (xchange >= 0) {
                angle = angle;
            }
            else {
                angle = 180 + angle;
            }
        }
        else {
            if (xchange >= 0) {
                angle = 360 + angle;
            }
            else {
                angle = 180 + angle;
            }
        }
        float updated_initial_rotation = fmodf(_aquila.rotation, 360);
        _aquila.rotation = updated_initial_rotation;
        float angle_change = fmodf(fmodf(-1*angle, 360) - updated_initial_rotation, 360) - 45;
        if (angle_change > 180 || angle_change < -180) {
            angle_change = 360 - fabsf(angle_change);
        }
        float duration = distance/AQUILA_WALK_SPEED;
        CCActionMoveTo *walkMove = [CCActionMoveTo  actionWithDuration:duration position:targetPoint];
        CCActionRotateBy* actionSpin = [CCActionRotateBy actionWithDuration:0.3f angle:
                                        angle_change];
        CCActionCallFunc *update_status = [CCActionCallFunc actionWithTarget:self selector:NSSelectorFromString(@"doneWalking")];
        CCActionSequence *actions = [CCActionSequence actionWithArray:@[walkMove, update_status]];
        
        
        [_aquila stopAllActions];
        [_aquila runAction: actionSpin];
        [_aquila runAction: actions];
        
        _aquila.currentWalk = actions;
        // Log touch location
        CCLOG(@"Aquila walking to @ %@",NSStringFromCGPoint(targetPoint));
        
    }
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (_aquila.state == Walking) {
        
        
    }
}

-(void) restartAI
{
    _dumbmonster.state = Normal;
    [_dumbmonster startAI];
}

-(void) gameOver {
    // Title
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"You died" fontName:@"Chalkduster" fontSize:50.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor redColor];
    label.position = ccp(0.5f, 0.8f); // Middle of screen
    [_physicsWorld removeChild:_aquila];
    [self addChild:label];
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair monsterCollision:(CCNode *)monster aquilaCollision:(CCNode *)aqui {
    CCLOG(@"Monster state: %d", _dumbmonster.state);
    if (_aquila.state != Dashing && _dumbmonster.state == Normal) {
        [self gameOver];
    }
    else if (_aquila.state == Dashing)
    {
        _dumbmonster.state = Stunned;
        [_dumbmonster stopAI];
        [NSTimer scheduledTimerWithTimeInterval:AI_STUN_DURATION
                                         target:self
                                       selector:NSSelectorFromString(@"restartAI")
                                       userInfo:nil
                                    repeats:NO];
    }
    return YES;
}

- (void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    
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
