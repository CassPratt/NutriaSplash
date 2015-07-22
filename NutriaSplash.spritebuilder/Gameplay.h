//
//  Gameplay.h
//  NutriaSplash
//
//  Created by Esteban Piazza Vázquez on 27/06/15.
//  Copyright 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCPhysics+ObjectiveChipmunk.h"

#import "Pool.h"

@interface Gameplay : CCNode <CCPhysicsCollisionDelegate>

@property (nonatomic, assign) int level;
@property (nonatomic, assign) int totalNutrias;
@property (nonatomic, assign) int totalPools;
@property (nonatomic, assign) int totalTime;
@property (nonatomic, assign) float showingTime;
@property (nonatomic, assign) float delayAfterHiding;
@property (nonatomic, assign) int maxShown;

@end
