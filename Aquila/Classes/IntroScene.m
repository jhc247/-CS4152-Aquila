//
//  IntroScene.m
//  Aquila
//
//  Created by Jcard on 2/21/14.
//  Copyright Seven Layer Games 2014. All rights reserved.
//
// -----------------------------------------------------------------------

// Import the interfaces
#import "IntroScene.h"
#import "LevelScene.h"

// -----------------------------------------------------------------------
#pragma mark - IntroScene
// -----------------------------------------------------------------------

@implementation IntroScene

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (IntroScene *)scene
{
	return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.0f]];
    [self addChild:background];
    
    // Title
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Aquila" fontName:@"Chalkduster" fontSize:80.0f];
    label.positionType = CCPositionTypeNormalized;
    label.color = [CCColor blackColor];
    label.position = ccp(0.5f, 0.6f); // Middle of screen
    [self addChild:label];
    
    // Controls
    CCButton *controlsButton = [CCButton buttonWithTitle:@"[ Controls ]" fontName:@"Verdana-Bold" fontSize:30.0f];
    controlsButton.positionType = CCPositionTypeNormalized;
    controlsButton.position = ccp(0.25f, 0.35f);
    [controlsButton setTarget:self selector:@selector(onControlsClicked:)];
    //[self addChild:controlsButton];
    
    // Monster
    CCButton *monsterButton = [CCButton buttonWithTitle:@"[ Monsters ]" fontName:@"Verdana-Bold" fontSize:30.0f];
    monsterButton.positionType = CCPositionTypeNormalized;
    monsterButton.position = ccp(0.5f, 0.35f);
    [monsterButton setTarget:self selector:@selector(onMonsterClicked:)];
    //[self addChild:monsterButton];
    
    // Demo
    CCButton *playButton = [CCButton buttonWithTitle:@"[ Demo ]" fontName:@"Verdana-Bold" fontSize:30.0f];
    playButton.positionType = CCPositionTypeNormalized;
    playButton.position = ccp(0.75f, 0.35f);
    [playButton setTarget:self selector:@selector(onPlayClicked:)];
    [self addChild:playButton];
    
    // done
	return self;
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onPlayClicked:(id)sender
{
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[LevelScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionLeft duration:1.0f]];
}

- (void)onMonsterClicked:(id)sender
{
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[LevelScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionDown duration:1.0f]];
}

- (void)onControlsClicked:(id)sender
{
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[LevelScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}


// -----------------------------------------------------------------------
@end
