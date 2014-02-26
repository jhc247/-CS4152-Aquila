//
//  Level.h
//  Aquila
//
//  Created by Jcard on 2/26/14.
//  Copyright (c) 2014 Seven Layer Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// -----------------------------------------------------------------------

@interface Level : CCScene

// -----------------------------------------------------------------------

@property (readonly, assign) CGPoint AquilaStart;
@property (readonly, assign) (NSArray*) monsters;
@property (readonly, assign) (NSARray*) crystals;

// -----------------------------------------------------------------------

+ (Level *)scene;
- (id)init;

// Tutorial on how to save persistent data
//http://bobueland.com/cocos2d/2011/how-to-save-data-in-a-plist/

@end