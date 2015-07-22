//
//  Pool.h
//  NutriaSplash
//
//  Created by Esteban Piazza Vázquez on 27/06/15.
//  Copyright 2015 Apportable. All rights reserved.
//

@class GridNode;

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Nutria.h"
#import "Fish.h"

@interface Pool : CCNode

@property (nonatomic,weak) Nutria* lola;
@property (nonatomic,weak) Fish* nemo;

-(void)setNutria:(Nutria*)nutria;
-(void)setFish:(Fish*)fish;

@end
