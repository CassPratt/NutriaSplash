//
//  Gameplay.m
//  NutriaSplash
//
//  Created by Esteban Piazza Vázquez on 27/06/15.
//  Copyright 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"

#pragma mark - COMPONENTS AND VARIABLES

#define ARC4RANDOM_MAX 0x100000000

@implementation Gameplay{
    CCButton* _playButton; // Temporal button
    // Spritebuilder set nodes
    CCPhysicsNode *_physicsNode;
    CCLabelTTF *_fishCountLabel, *_nutriaCountLabel, *_timeCountLabel;
    CCSprite *_bTop, *_bBottom, *_bLeft, *_bRight;
    
    // Local variables (per level)
    CGSize phSize;
    NSDictionary *_readingLevel;
    NSDictionary *_thisLevel;
    NSMutableArray *nutrias;
    NSMutableArray *pools;
}

#pragma mark - INITIALIZING

-(id)init{
    if (self = [super init]) {
        _level = 1; // Will be read from singleton
    }
    return self;
}

-(void)didLoadFromCCB{
    //_physicsNode.debugDraw = TRUE;
    _physicsNode.collisionDelegate = self;
    _physicsNode.name = @"physicsNode";
    phSize = _physicsNode.boundingBox.size;
    
    // Reading/Setting level
    [self readingLevel];
    [self settingLevel];
    
    // Setting timer
    [self schedule:@selector(levelTimer) interval:1.0f];
}

-(void)readingLevel {
    // Reading Level options from Levels' plist
    NSString *strLevel = [NSString stringWithFormat:@"Level%i",_level];
    NSString *superList = [[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"];
    _readingLevel = [NSDictionary dictionaryWithContentsOfFile:superList];
    _thisLevel = [NSDictionary dictionaryWithDictionary:[_readingLevel objectForKey:strLevel]];
    
    // Getting number of Nutrias
    _totalNutrias = [[_thisLevel objectForKey:@"totalNutrias"] intValue];
    NSString *countN;
    if (_totalNutrias < 10)
        countN = [NSString stringWithFormat:@"x0%i",_totalNutrias];
    else countN = [NSString stringWithFormat:@"x%i",_totalNutrias];
    [_nutriaCountLabel setString:countN];

    // Getting number of pools
    _totalPools = _totalNutrias * 2;
    
    // Getting level time
    _totalTime = [[_thisLevel objectForKey:@"time"] intValue];
    [self setTimeLabel];
    
    // Getting _physicsNode damping
    float newDamp = [[_thisLevel objectForKey:@"damping"] floatValue];
    [_physicsNode.space setDamping:newDamp];
}

// Adding Pools randomly
-(void)settingLevel {
    // Random positions for Pools
    pools = [NSMutableArray array];
    
    // for the position of the Pool
    float x = 0;
    float y = 0;
    
    for (int i = 0; i<_totalPools; i++){
        
        int rndPosition;
        // random position
        rndPosition = 40 + arc4random() % (400);
        x = rndPosition;
        rndPosition = 30 + arc4random() % (210);
        y = rndPosition;
        
        // setting the position
        CGPoint thisPosition = ccp(x, y);
        
        Pool* pool = (Pool*)[CCBReader load:@"Pool"];
        pool.positionType = CCPositionTypePoints;
        pool.position = thisPosition;
        [_physicsNode addChild: pool];
        if (CGRectContainsRect(_physicsNode.boundingBox, pool.boundingBox))
            pool.position = ccp(100,100);
        [pools addObject:pool];
    }
    // Checking there are no intersections
    [self checkPoolsPosition];
    
    // Pools for Nutrias
    int numPool = 0;
    nutrias = [NSMutableArray array];
    for (int j = 0 ; j<_totalNutrias; j++) {
        Nutria* otter = (Nutria*)[CCBReader load:@"Nutria"];
        Pool* thisPool = (Pool*)[pools objectAtIndex:numPool];
        [thisPool setNutria:otter];
        numPool++;
    }
}

// Checking there are no intersections between pools
-(void)checkPoolsPosition {
    
    CGPoint newPos;
    int rndPosition, x=0, y=0;
    // random position
    int sth = 0;
    do{
        for (int i = 0; i<_totalPools; i++) {
            Pool *thisPool = (Pool*)[pools objectAtIndex:i];
            for (Pool *toCompare in pools) {
                if (![toCompare isEqual:thisPool]) {
                    if (CGRectIntersectsRect(thisPool.boundingBox, toCompare.boundingBox)) {
                        rndPosition = 40 + arc4random() % (400);
                        x = rndPosition;
                        rndPosition = 30 + arc4random() % (210);
                        y = rndPosition;
                        newPos = ccp(x,y);
                        thisPool.position = newPos;
                    }
                }
            }
            sth++;
        }
    } while (sth < _totalPools*3);
}

#pragma mark - GAME METHODS

//TODO: remove play method after all gameplay is ready
-(void)play {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
    _playButton.enabled = false;
}

// Setting correct text format in _timeCountLabel
-(void)setTimeLabel {
    NSString *thisTime;
    if (_totalTime < 60) {
        if (_totalTime < 10)
            thisTime = [NSString stringWithFormat:@"0:0%i",_totalTime];
        else
            thisTime = [NSString stringWithFormat:@"0:%i",_totalTime];
    } else {
        int minutes = _totalTime / 60;
        int seconds = _totalTime % 60;
        if (seconds < 10)
            thisTime = [NSString stringWithFormat:@"%i:0%i",minutes,seconds];
        else
            thisTime = [NSString stringWithFormat:@"%i:%i",minutes,seconds];
    }
    [_timeCountLabel setString:thisTime];
}
// Counter --
-(void)levelTimer {
    if (_totalTime > 0)
        _totalTime--;
    else
        _totalTime = 0;
    [self setTimeLabel];
}

#pragma mark - AT THE END

- (void)dealloc {
    [self removeAllChildrenWithCleanup:TRUE];
    // Clean up memory allocations from sprites
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    [[CCDirector sharedDirector] purgeCachedData];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    [CCSpriteFrameCache purgeSharedSpriteFrameCache];
}

@end
