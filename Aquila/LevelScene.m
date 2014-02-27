//
//  LevelScene.m
//  Aquila
//
//  Created by Jcard on 2/26/14.
//  Copyright 2014 Seven Layer Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LevelScene.h"
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
#import "TouchLayer.h"
#import "PhysicsCollisionDelegate.h"

// -----------------------------------------------------------------------
#pragma mark - LevelScene
// -----------------------------------------------------------------------

@implementation LevelScene
{
    Aquila *_aquila;
    CCPhysicsNode *_physicsWorld;
    TouchLayer *touchLayer;
    
    NSMutableArray* actualEnemies;
    NSMutableArray* actualCrystalSets;

    CGPoint walkTarget;
    CGPoint prevAquilaLocation;
    
    float level_width; // multiplier for screen size
    float level_height;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (LevelScene *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    //////// Hard coded level //////////
    
    float width = self.contentSize.width;
    float height = self.contentSize.height;
    
    level_width = 1.5;
    level_height = 1.5;
    _AquilaStart = ccp(.5*width, .5*height);
    
    //Format:       {EnemyType, startX, startY, behavior(1=follow,0=patroll),
    //               patrolpt1_x, patrolpt1_y, patrolpt2_x, patrolpt2_y};
    int numEnemies = 3; // <---- Update this field when adding
    _enemies = (int**)malloc(numEnemies*sizeof(int*));
    int enemy1[8] = {Game_N_Watch, (int)width, (int)(height/2), 1, -1, -1, -1, -1};
    int enemy2[8] = {Megagrunt, (int)(width/2), (int)height, 0, 0, (int)height, (int)width, (int)height};
    int enemy3[8] = {Megagrunt, (int)width, (int)(height/2), 0, (int)width, 0,(int)width, (int)height};

    _enemies[0] = enemy1;
    _enemies[1] = enemy2;
    _enemies[2] = enemy3;

    
    // Initialize arrays
    actualEnemies = [[NSMutableArray alloc] init];
    actualCrystalSets = [[NSMutableArray alloc] init];
    
    // Create moveable touch layer
    touchLayer = [TouchLayer createTouchLayer];
    [self addChild:touchLayer];
    
    // Create physics
    _physicsWorld = [CCPhysicsNode node];
    _physicsWorld.gravity = ccp(0,0);
    _physicsWorld.debugDraw = NO;
    _physicsWorld.collisionDelegate = [PhysicsCollisionDelegate delegate];
    [self addChild:_physicsWorld];
    
    // Create Aquila
    _aquila = [Aquila spriteWithImageNamed:AQUILA];
    [_aquila initAquila: _AquilaStart];
    touchLayer.position = _AquilaStart;
    self.position = ccp(-_AquilaStart.x+width/2, -_AquilaStart.y+height/2);
    [_physicsWorld addChild:_aquila z:10 name:@"aquila"];
    prevAquilaLocation = _aquila.position;
    
    // Create enemies
    [self createEnemies:numEnemies];
    
    // Create crystals
    for (int i = 0; i < [_crystals count]; i++) {
        NSArray* crystalSetInfo = [_crystals objectAtIndex:i];
        
        NSArray* positions = [crystalSetInfo objectAtIndex:0];
        NSArray* states = [crystalSetInfo objectAtIndex:1];
        NSArray* links = [crystalSetInfo objectAtIndex:2];
        
        CrystalSet* c = [CrystalSet createCrystalSet:positions initialStates:states physicsNode:_physicsWorld linkedCrystals:links level:self];
        [actualCrystalSets addObject:c];
    }
    
    /*
    // Create crystals
    // Positions
    NSValue *loc1 = [NSValue valueWithCGPoint:ccp(self.contentSize.width/2, self.contentSize.height/5)];
    NSValue *loc2 = [NSValue valueWithCGPoint:ccp(4*self.contentSize.width/5, 4*self.contentSize.height/5)];
    NSValue *loc3 = [NSValue valueWithCGPoint:ccp(1*self.contentSize.width/5, 4*self.contentSize.height/5)];
    NSValue *loc4 = [NSValue valueWithCGPoint:ccp(4*self.contentSize.width/5, 2*self.contentSize.height/5)];
    // Initial States
    NSNumber *state1 = [NSNumber numberWithInt:Off];
    NSNumber *state2 = [NSNumber numberWithInt:On];
    NSNumber *state3 = [NSNumber numberWithInt:On];
    NSNumber *state4 = [NSNumber numberWithInt:On];
    // Links
    
     Pink Crystal = Crystal 1    linked to: 2
     Purple Crystal = Crystal 2  linked to: 3
     Orange Crystal = Crystal 3  linked to:
     Blue Crystal = Crystal 4    linked to: 3, 1
     
     The Pink Crystal activates the Purple Crystal as well.
     The Purple Crystal activates the Orange Crystal as well.
     The Blue Crystal activates both the Orange and Pink Crystals as well.
     
    NSArray *link1 = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:1], nil];
    NSArray *link2 = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:2], nil];
    NSArray *link3 = [[NSArray alloc] initWithObjects: nil];
    NSArray *link4 = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:0],
                      [NSNumber numberWithInt:2], nil];
    
    NSArray* crystalPositions = [[NSArray alloc] initWithObjects:loc1, loc2, loc3, loc4, nil];
    NSArray* crystalStates = [[NSArray alloc] initWithObjects:state1,state2,state3,state4,nil];
    NSArray* crystalLinks = [[NSArray alloc] initWithObjects:link1, link2,link3,link4, nil];
    
    _crystals = [CrystalSet createCrystalSet:crystalPositions initialStates:crystalStates physicsNode:_physicsWorld linkedCrystals:crystalLinks level:self];
    
    */
    
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
    
	return self;
}

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

- (void) createEnemies: (int)size {
    // _enemies is an array, where each element contains an array of information on an enemy
    for (int i = 0; i < size; i++) {
        int* enemyInfo = _enemies[i];
        EnemyType type = enemyInfo[0];
        int startx = enemyInfo[1];
        int starty = enemyInfo[2];
        CGPoint startPos = ccp(startx, starty);
        int behav = enemyInfo[3];
        CCLOG(@"HI");
        AIActor *enemy = [AIActor spriteWithImageNamed:[AIActor getSprite:type state:Normal]];
        if (behav == 0) {
            int p1x = enemyInfo[4];
            int p1y = enemyInfo[5];
            CGPoint p1 = ccp(p1x, p1y);
            
            int p2x = enemyInfo[6];
            int p2y = enemyInfo[7];
            CGPoint p2 = ccp(p2x, p2y);
            PatrollingAIBehavior *behavior = [[PatrollingAIBehavior alloc] initWithPoints:p1 :
                                              p2 monster:enemy];
            [enemy initWithBehavior:behavior :startPos type:type];
        }
        else {
            FollowAIBehavior *behavior = [[FollowAIBehavior alloc] init:_aquila :enemy];
            [enemy initWithBehavior:behavior :startPos type:type];
        }
        [enemy startAI];
        [_physicsWorld addChild:enemy];
        [actualEnemies addObject:enemy ];
    }
}


// -----------------------------------------------------------------------
#pragma mark - Update method
// -----------------------------------------------------------------------

- (void)update:(CCTime)delta {

    // Update screen position
    float xChange = -(_aquila.position.x - prevAquilaLocation.x);
    float yChange = -(_aquila.position.y - prevAquilaLocation.y);
    prevAquilaLocation = _aquila.position;
    CGPoint aquilaChange = ccp(xChange, yChange);
    float width = self.contentSize.width;
    float height = self.contentSize.height;
    float totalwidth = level_width*width;
    float totalheight = level_height*height;
    
    if (_aquila.position.x >= width/2 &&
        _aquila.position.x <= totalwidth - width/2) {
        self.position = ccp((self.position.x + aquilaChange.x), self.position.y);
        touchLayer.position = _aquila.position;
    }
    if (_aquila.position.y >= height/2 &&
        _aquila.position.y <= totalheight - height/2) {
        self.position = ccp(self.position.x, (self.position.y + aquilaChange.y));
        touchLayer.position = _aquila.position;
    }
    
    
    
    for (CrystalSet *set in actualCrystalSets) {
        if ([set doSomething]) {
            
            //TODO: Something to do when all the crystals are on
            // !
            CCLabelTTF *label = [CCLabelTTF labelWithString:@"!" fontName:@"Chalkduster" fontSize:150.0f];
            label.positionType = CCPositionTypeNormalized;
            label.color = [CCColor greenColor];
            label.position = ccp(0.5f, 0.8f); // Middle of screen
            [self addChild:label];
            CCActionRemove *remove = [CCActionRemove action];
            CCActionDelay *delay = [CCActionDelay actionWithDuration:AI_STUN_DURATION];
            CCActionSequence *sequence = [CCActionSequence actionWithArray:@[delay, remove]];
            [label runAction:sequence];
            
        }
    }
}

// -----------------------------------------------------------------------
#pragma mark - Instance methods
// -----------------------------------------------------------------------

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

// -----------------------------------------------------------------------
#pragma mark - Touch Handler for touchLayer
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (_aquila.state == Standing || _aquila.state == Walking) {
        
        // Calculate angle, distance and actions
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
        CCActionRotateTo* actionSpin = [CCActionRotateBy actionWithDuration:AQUILA_ROTATE_DURATION angle: angle_change];
        
        [_aquila walk:walkMove rotate:actionSpin];
        
        // Log touch location
        CCLOG(@"Aquila walking to @ %@",NSStringFromCGPoint(targetPoint));
        
    }
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_aquila.state == Walking) {
        
        // Calculate angle, distance and actions
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
        CCActionRotateTo* actionSpin = [CCActionRotateBy actionWithDuration:AQUILA_ROTATE_DURATION angle: angle_change];
        
        [_aquila walk:walkMove rotate:actionSpin];
        
        // Log touch location
        CCLOG(@"Aquila walking to @ %@",NSStringFromCGPoint(targetPoint));
        
    }
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
    return;
}

-(void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    
    return;
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}

- (void)onResetClicked:(id)sender
{
    // Restart level
    [[CCDirector sharedDirector] replaceScene: self
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionDown duration:0.5f]];
}

- (void)onDebugClicked:(id)sender
{
    // TODO: Buggy
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
