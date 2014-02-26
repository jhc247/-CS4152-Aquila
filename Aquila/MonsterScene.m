//
//  MonsterScene.m
//  Aquila
//
//  Created by Jcard on 2/26/14.
//  Copyright 2014 Seven Layer Games. All rights reserved.
//

#import "MonsterScene.h"
#import "IntroScene.h"
#import "Constants.h"
#import "CCDrawingPrimitives.h"
#import "CCSprite.h"
#import "CCActionInstant.h"
#import "Aquila.h"
#import "AIActor.h"
#import "PatrollingAIBehavior.h"
#import "FollowAIBehavior.h"
#import "CrystalSet.h"
#import "Crystal.h"

// -----------------------------------------------------------------------
#pragma mark - MonsterScene
// -----------------------------------------------------------------------

@implementation MonsterScene
{
    Aquila *_aquila;
    CCPhysicsNode *_physicsWorld;
    AIActor *_dumbmonster;
    AIActor *_othermonster;
    AIActor *_thirdmonster;
    CrystalSet* _crystals;
    
    bool green;
    CCSprite *greencircle;
    CCSprite *redcircle;
    
    CGPoint touchStart;
    CGPoint touchEnd;
    bool walking;
    bool ignore;
    bool solved;
    
    CGPoint walkTarget;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (MonsterScene *)scene
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
    NSString* dumb_normal = @"megagrunt.png";
    NSString* dumb_stunned = @"megagrunt_stunned.png";
    _dumbmonster = [AIActor spriteWithImageNamed:dumb_normal];
    PatrollingAIBehavior *behavior = [[PatrollingAIBehavior alloc] initWithPoints:startPos :
                                      ccp(self.contentSize.width/5, 4*self.contentSize.height/5) monster:_dumbmonster];
    [_dumbmonster initWithBehavior:behavior :startPos normalSprite:dumb_normal stunnedSprite:dumb_stunned];
    [_physicsWorld addChild:_dumbmonster];
    [_dumbmonster startAI];
    
    // Add another monster
    CGPoint startPos2 = ccp(3*self.contentSize.width/4,4*self.contentSize.height/5);
    NSString* other_normal = @"monster2.png";
    NSString* other_stunned = @"monster2_stunned.png";
    _othermonster = [AIActor spriteWithImageNamed:other_normal];
    FollowAIBehavior *otherbehavior = [[FollowAIBehavior alloc] init:_aquila :_othermonster];
    [_othermonster initWithBehavior:otherbehavior :startPos2 normalSprite:other_normal stunnedSprite:other_stunned];
    [_physicsWorld addChild:_othermonster];
    [_othermonster startAI];
    
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

-(void) solvedCrystals {
    if (!solved) {
        CCLOG(@"Solved");
        [_physicsWorld addChild:_thirdmonster];
        [_thirdmonster startAI];
        solved = true;
    }
    
    // !
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"!" fontName:@"Chalkduster" fontSize:50.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor whiteColor];
    label.position = ccp(0.5f, 0.9f); // Middle of screen
    [self addChild:label];
    CCActionRemove *remove = [CCActionRemove action];
    CCActionDelay *delay = [CCActionDelay actionWithDuration:AI_STUN_DURATION];
    CCActionSequence *sequence = [CCActionSequence actionWithArray:@[delay, remove]];
    [label runAction:sequence];
    
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

-(void) gameOver {
    // Title
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"You died" fontName:@"Chalkduster" fontSize:50.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor redColor];
    label.position = ccp(0.5f, 0.8f); // Middle of screen
    [_physicsWorld removeChild:_aquila];
    [self addChild:label];
    
    // Create a reset button
    CCButton *resetButton = [CCButton buttonWithTitle:@"Reset" fontName:@"Verdana-Bold" fontSize:25.0f];
    resetButton.positionType = CCPositionTypeNormalized;
    resetButton.position = ccp(0.5f, 0.7f); // Top Right of screen
    [resetButton setTarget:self selector:@selector(onResetClicked:)];
    [self addChild:resetButton];
    
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair monsterCollision:(AIActor *)monster aquilaCollision:(Aquila *)aqui {
    CCLOG(@"Aquilla collided with monster");
    if (aqui.state != Dashing && monster.state == Normal) {
        [self gameOver];
    }
    else if (aqui.state == Dashing)
    {
        [monster stun];
        CCActionCallFunc *unstun = [CCActionCallFunc actionWithTarget:monster selector:@selector(restartAI)];
        CCActionDelay *delay = [CCActionDelay actionWithDuration:AI_STUN_DURATION];
        CCActionSequence *sequence = [CCActionSequence actionWithArray:@[delay, unstun]];
        [monster runAction:sequence];
    }
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair aquilaCollision:(Aquila *)aquila crystalCollision:(Crystal *)crystal {
    CCLOG(@"Aquilla collided with crystal");
    [_aquila stopAllActions];
    _aquila.state = Standing;
    [crystal flipState:true];
    return YES;
}

- (void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    
}

- (void)ccPhysicsCollisionSeparate:(CCPhysicsCollisionPair *)pair aquilaCollision:(Aquila *)aquila crystalCollision:(Crystal *)crystal {
    CCLOG(@"Aquilla seperated from crystal");
    
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionUp duration:1.0f]];
}

- (void)onResetClicked:(id)sender
{
    // back to demo scene with transition
    [[CCDirector sharedDirector] replaceScene:[MonsterScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionDown duration:0.5f]];
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
