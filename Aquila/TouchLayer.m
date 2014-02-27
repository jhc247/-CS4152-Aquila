//
//  TouchLayer.m
//  Aquila
//
//  Created by Jcard on 2/26/14.
//  Copyright 2014 Seven Layer Games. All rights reserved.
//

#import "cocos2d.h"
#import "TouchLayer.h"

@implementation TouchLayer 

+ (instancetype) createTouchLayer {
    return [[TouchLayer alloc] initTouchLayer];
}

- (instancetype)initTouchLayer {
    if( (self=[super init])) {
        self.userInteractionEnabled = YES;
        self.anchorPoint = ccp(0.5,0.5);
        CGSize size = [[CCDirector sharedDirector] viewSizeInPixels];
        self.position = ccp(size.width/2,size.height/2);
        [self setContentSize: size];
    }
    return self;
}

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    //CCLOG(@"Touched TouchLayer at %@", NSStringFromCGPoint([touch locationInNode:_parent]));
    [_parent touchBegan:touch withEvent:event];
}

-(void) touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    //CCLOG(@"Touched TouchLayer");
    [_parent touchMoved:touch withEvent:event];
}

-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    //CCLOG(@"Touched TouchLayer");
    [_parent touchEnded:touch withEvent:event];
}

-(void) touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    //CCLOG(@"Touched TouchLayer");
    [_parent touchCancelled:touch withEvent:event];
}

@end
