//
//  Nutria.m
//  NutriaSplash
//
//  Created by Esteban Piazza Vázquez on 27/06/15.
//  Copyright 2015 Apportable. All rights reserved.
//

#import "Nutria.h"


@implementation Nutria

#pragma mark - INITIALIZING

-(id)init{
    if([super init]){
        _oldPool = 0;
    }
    return self;
}

-(void)didLoadFromCCB {
    self.physicsBody.collisionType = @"nutria";
}

#pragma mark - NUTRIA METHODS

@end
