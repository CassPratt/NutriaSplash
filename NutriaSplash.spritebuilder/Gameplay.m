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
    CCButton* _playButton;
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

-(void)settingLevel {
    // Random positions for Pools
    pools = [NSMutableArray array];
    
    // for the position of the Pool
    float x = 0;
    float y = 0;
    
    for (int i = 0; i<_totalPools; i++){
        
        int rndPosition;
        // random position
        rndPosition = 10 + arc4random() % (430);
        x = rndPosition;
        rndPosition = 20 + arc4random() % (230);
        y = rndPosition;
        
        // setting the position
        CGPoint thisPosition = ccp(x, y);
        
        Pool* pool = (Pool*)[CCBReader load:@"Pool"];
        [pool convertPositionToPoints:self.position type:CCPositionTypePoints];
        pool.position = thisPosition;
        [_physicsNode addChild: pool];
        [pools addObject:pool];
    }
    
    // Randoms Pools for Nutrias
    nutrias = [NSMutableArray array];
    for (int j = 0 ; j<_totalNutrias; j++) {
        Nutria* otter = (Nutria*)[CCBReader load:@"Nutria"];
        Pool* thisPool;
        do{
            int rndPool = 0 + arc4random()%(_totalPools);
            thisPool = (Pool*)[pools objectAtIndex:rndPool];
            [thisPool setNutria:otter];
        } while(thisPool.lola == NULL);
            
    }
}

#pragma mark - GAME METHODS

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
