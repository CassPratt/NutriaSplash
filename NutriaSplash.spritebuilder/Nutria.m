//
//  Nutria.m
//  NutriaSplash
//
//  Created by Esteban Piazza Vázquez on 27/06/15.
//  Copyright 2015 Apportable. All rights reserved.
//

#import "Nutria.h"


@implementation Nutria {
    CCSprite *_spriteNutria;
}

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

-(void)changeSprite:(int)flip {
    NSString *newString = @"GameAssets/nutria-saltando.png";
    if (flip != -1)
        _spriteNutria.flipX = FALSE;
    if (flip < 0)
        _spriteNutria.flipX = TRUE;
    else if (flip == 0){
        newString = @"GameAssets/nutria-mitad-1.png";
    }
    [_spriteNutria setTexture:[CCTexture textureWithFile:newString]];
}

@end
