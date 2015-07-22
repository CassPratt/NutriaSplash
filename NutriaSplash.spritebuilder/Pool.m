//
//  Pool.m
//  NutriaSplash
//
//  Created by Esteban Piazza Vázquez on 27/06/15.
//  Copyright 2015 Apportable. All rights reserved.
//

#import "Pool.h"

#pragma mark - COMPONENTS AND VARIABLES

@implementation Pool{
    CGPoint firstTouch;
    CGPoint lastTouch;
    CCSprite *_water; // For Nutria collision
}

#pragma mark - INITIALIZING

-(id)init{
    if (self = [super init]) {
    }
    return self;
}

-(void)didLoadFromCCB{
    self.userInteractionEnabled = TRUE;
    self.physicsBody.collisionType = @"pool";
}

#pragma mark - POOL METHODS

-(void)update:(CCTime)delta{
    if (ccpLength(self.physicsBody.velocity) < 25)
        self.physicsBody.velocity = ccp(0, 0);
}

-(void)setNutria:(Nutria*)nutria{
    _lola = nutria;
//    [_lola changeSprite:0];
    _lola.anchorPoint = ccp(0.5,0);
    _lola.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    [self addChild:nutria];
}

-(void)setFish:(Fish *)fish{
    _nemo = fish;
    _nemo.anchorPoint = ccp(0.5,0.3);
    _nemo.scale = 0.8;
    _nemo.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    [self addChild:_nemo];
}

#pragma mark - TOUCH METHODS

-(void) touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    self.physicsBody.velocity = ccp(0,0);
    firstTouch = [touch locationInNode:self.parent];
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    lastTouch = [touch locationInNode:self.parent];
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    CGPoint vector = ccpSub(lastTouch, firstTouch);
    CGFloat dist = ccpDistance(lastTouch, firstTouch);
    CGPoint vel = ccpMult(vector, dist/1.75f);
    if ((vel.x >100 || vel.y > 100) || (vel.x <-100 || vel.y < -100)){
        vel = ccpMult(vel, 0.10);
    }
    [self.physicsBody applyImpulse:vel];
}

@end
