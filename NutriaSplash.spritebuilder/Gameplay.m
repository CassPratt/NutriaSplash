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
    CGSize interSize;
    NSDictionary *_readingLevel;
    NSDictionary *_thisLevel;
    NSString *_countN;
    NSMutableArray *nutrias;
    NSMutableArray *pools;
    NSMutableArray *targets;
    NSMutableArray *nextMoving;
    NSMutableArray *movingNutrias;

    BOOL _fishShowing;
    int _fishCount;
}

#pragma mark - INITIALIZING

-(id)init{
    if (self = [super init]) {
        _level = [GameData sharedData].level; // Will be read from singleton
        nutrias = [NSMutableArray array];
        pools = [NSMutableArray array];
        targets = [NSMutableArray array];
        nextMoving = [NSMutableArray array];
        movingNutrias = [NSMutableArray array];
        _fishShowing = FALSE;
        _fishCount = 0;
    }
    return self;
}

-(void)didLoadFromCCB{
    //_physicsNode.debugDraw = TRUE;
    _physicsNode.collisionDelegate = self;
    _physicsNode.name = @"physicsNode";
    
    // Reading/Setting level
    [self readingLevel];
    [self settingLevel];
    
    // Setting timer
    [self schedule:@selector(levelTimer) interval:1.0f];
    
    // Will show Nutrias for the first time!
    [self scheduleOnce:@selector(showNutrias) delay:2.0f];
}

// Obtaining level info from plist "Levels"
-(void)readingLevel {
    // Reading Level options from Levels' plist
    NSString *strLevel = [NSString stringWithFormat:@"Level%i",_level];
    NSString *superList = [[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"];
    _readingLevel = [NSDictionary dictionaryWithContentsOfFile:superList];
    _thisLevel = [NSDictionary dictionaryWithDictionary:[_readingLevel objectForKey:strLevel]];
    
    // Getting number of Nutrias
    _totalNutrias = [[_thisLevel objectForKey:@"totalNutrias"] intValue];
    if (_totalNutrias < 10)
        _countN = [NSString stringWithFormat:@"x0%i",_totalNutrias];
    else _countN = [NSString stringWithFormat:@"x%i",_totalNutrias];
    [_nutriaCountLabel setString:_countN];
    // Max. number of Nutrias shown
    _maxShown = [[_thisLevel objectForKey:@"maxShown"] intValue];
    
    // Time for showing the Nutrias
    _showingTime = [[_thisLevel objectForKey:@"showingTime"] floatValue];
    // Time before moving the Nutrias
    _delayAfterHiding = [[_thisLevel objectForKey:@"delayAfterHiding"] floatValue];

    // Getting number of pools
    _totalPools = _totalNutrias + _maxShown;
    for (int i = 0; i<_totalPools; i++) {
        NSString *nothing = [[NSString string] init];
        [targets addObject:nothing];
    }
    
    // Getting level time
    _totalTime = [[_thisLevel objectForKey:@"time"] intValue];
    [self setTimeLabel];
    
    // Getting _physicsNode damping
    float newDamp = [[_thisLevel objectForKey:@"damping"] floatValue];
    [_physicsNode.space setDamping:newDamp];
}

// Adding Pools and Nutrias randomly
-(void)settingLevel {
    
    // Random positions for Pools
    for (int i = 0; i<_totalPools; i++){
        Pool* pool = (Pool*)[CCBReader load:@"Pool"];
        pool.positionType = CCPositionTypePoints;
        pool.position = [self randomPositionInScreen];
        [_physicsNode addChild: pool];
        if (CGRectContainsRect(_physicsNode.boundingBox, pool.boundingBox))
            pool.position = ccp(100,100);
        [pools addObject:pool];
    }
    // Checking there are no intersections
    [self checkPoolsPosition];
    
    // Pools for Nutrias
    int numPool = 0;
    for (int j = 0 ; j<_totalNutrias; j++) {
        Nutria* otter = (Nutria*)[CCBReader load:@"Nutria"];
        Pool* thisPool = (Pool*)[pools objectAtIndex:numPool];
        otter.oldPool = numPool;
        [thisPool setNutria:otter];
        [nutrias addObject:otter];
        numPool++;
    }
    
    // For intersection with Pools
    interSize = ((Nutria*)[nutrias objectAtIndex:0]).boundingBox.size;
}

// Checking there are no intersections between pools
-(void)checkPoolsPosition {
    int sth = 0;
    do{
        for (int i = 0; i<_totalPools; i++) {
            Pool *thisPool = (Pool*)[pools objectAtIndex:i];
            for (Pool *toCompare in pools) {
                if (![toCompare isEqual:thisPool]) {
                    if (CGRectIntersectsRect(thisPool.boundingBox, toCompare.boundingBox))
                        thisPool.position = [self randomPositionInScreen];
                }
            }
            sth++;
        }
    } while (sth < _totalPools*3);
}

#pragma mark - GAME METHODS

-(void)update:(CCTime)delta {
    if (_totalNutrias == 0)
       [self endGame];
    
    // Random time for showing fish
    float rndTime = 0.5 + arc4random_uniform(3.5f);
    if (!_fishShowing) {
        [self scheduleOnce:@selector(showFish) delay:rndTime];
        _fishShowing = TRUE;
    }
}

// Showing (max) Nutrias and their targets
-(void)showNutrias {
    
    for (Nutria *toHide in nutrias) {
        if (toHide.visible)
            toHide.visible = FALSE;
    }
    
    // Showing a certain number of Nutrias at a time ([1,_maxShown])
    int rndShow;
    if (_totalNutrias > (_maxShown-_totalNutrias))
        rndShow = 1 + arc4random()%(_maxShown);
    else
        rndShow = 1;
    
    Pool *tryThis;
    int foundPools = 0;
    int countPools = 0;
    while (foundPools < rndShow) {
        if (countPools < _totalPools) {
            tryThis = (Pool*)[pools objectAtIndex:countPools];
            if (tryThis.lola != NULL && !tryThis.lola.visible) {
                CCSprite *theTarget = [[CCSprite alloc] initWithImageNamed:@"GameAssets/target.png"];
                theTarget.positionType = CCPositionTypePoints;
                theTarget.anchorPoint = ccp(0.5,0.5);
                theTarget.position = [self randomPositionInScreen];
                
                // Adding the target to its array
                int indexOfTar = (int)[pools indexOfObject:tryThis];
                [targets setObject:theTarget atIndexedSubscript:indexOfTar];
                [self addChild:theTarget];
                
                [tryThis.lola setVisible:TRUE];
                [nextMoving addObject:tryThis];

                foundPools++;
            }
            countPools++;
        } else if (_totalNutrias > 1)
            countPools = 0;
    }
    
    // Next is hiding!
    [self scheduleOnce:@selector(hideNutrias) delay:_showingTime];
}

// Hiding Nutrias after a certain time
-(void)hideNutrias {
    for (Pool *thisPool in nextMoving) {
        if (thisPool.lola.visible) {
            [thisPool.lola setVisible:FALSE];
            int pos = (int)[pools indexOfObject:thisPool];
            CCSprite *oneTar = (CCSprite*)[targets objectAtIndex:pos];
            [oneTar setVisible:FALSE];
        }
    }
    
    // Next is moving!
    [self scheduleOnce:@selector(moveNutrias) delay:_delayAfterHiding];
}

// Moving the Nutrias
-(void)moveNutrias {
    
    int countPool = 0;
    for (int i = 0; i<[nextMoving count]; i++) {
        // Removing pool's Nutria
        Pool *showThis = [nextMoving objectAtIndex:countPool];
        Nutria *theNutria = showThis.lola;
        if (theNutria != NULL)
            [showThis removeChild:showThis.lola];
        showThis.lola = NULL;
        
        // theNutria has a new parent!
        theNutria.anchorPoint = ccp(0.5,0);
        theNutria.position = ccp(showThis.position.x-5,showThis.position.y);
        [self addChild:theNutria];
        [movingNutrias addObject:theNutria];
        [theNutria setVisible:TRUE];
        
        // Getting target position
        CCSprite *toTarget = (CCSprite*)[targets objectAtIndex:[pools indexOfObject:showThis]];
//        if (toTarget.position.x < theNutria.position.x)
//            [theNutria changeSprite:-1];
//        else [theNutria changeSprite:1];
        CCActionMoveTo *moveNutria = [CCActionMoveTo actionWithDuration:1.0f position:toTarget.position];
        [theNutria runAction:moveNutria];
        
        countPool++;
    }
    
    // Deleting items for old moving
    [nextMoving removeAllObjects];
    
    // Deleting existing targets
    for (CCSprite *thisTarget in targets) {
        if (thisTarget != NULL && ![thisTarget isKindOfClass:[NSString class]])
            [self removeChild:thisTarget];
    }
    [targets removeAllObjects];
    for (int i = 0; i<_totalPools; i++) {
        NSString *nothing = [[NSString string] init];
        [targets addObject:nothing];
    }
    
    // Next is checking!
    [self scheduleOnce:@selector(setNutriasInNewPool) delay:(_delayAfterHiding+0.1f)];
}

// Giving Nutrias a new parent, or deleting it
-(void)setNutriasInNewPool {
    for (Nutria *thisOtter in movingNutrias) {
        // Checking if the Nutria intersects with a Pool (not the original) 
        for (Pool *thisPool in pools) {
            CGRect intersection = CGRectIntersection(thisOtter.boundingBox, thisPool.boundingBox);
            float interWidth = intersection.size.width;
            float interHeight = intersection.size.height;
            int index = (int)[pools indexOfObject:thisPool];
            if (thisOtter != NULL && !CGRectIsNull(intersection) && interWidth > interSize.width/2 && interHeight > interSize.height/2
                && thisOtter.oldPool != index && thisPool.lola == NULL) {
                [self removeChild:thisOtter];
                thisOtter.oldPool = index;
                [thisPool setNutria:thisOtter];
                if (thisPool.nemo != NULL) {
                    _fishCount++;
                    NSLog([NSString stringWithFormat:@"Fish: %i",_fishCount]);
                    [self setFishLabel];
                    [thisPool removeChild:thisPool.nemo];
                    _fishShowing = FALSE;
                }
            }
        }
        if (thisOtter.parent == self && thisOtter != NULL){
            _totalNutrias--;
            _countN = [NSString stringWithFormat:@"x0%i",_totalNutrias];
            [_nutriaCountLabel setString:_countN];
            [self removeChild:thisOtter];
            [nutrias removeObject:thisOtter];
        }
    }
    [nextMoving removeAllObjects];
    [movingNutrias removeAllObjects];
    
    // Next is showing!
    [self scheduleOnce:@selector(showNutrias) delay:1.0f];
}

// Show fish for incrementing score
-(void)showFish {
    Fish *newOne;
    int counter = 0 + arc4random()%(_totalPools);
    do {
        Pool *tryThis = (Pool*)[pools objectAtIndex:counter];
        if (tryThis.lola == NULL) {
            newOne = (Fish*)[CCBReader load:@"Fish"];
            [tryThis setFish:newOne];
        }
        counter =  0 + arc4random()%(_totalPools);
    }while(newOne == NULL && counter < _totalPools);
    
    // Random time for showing fish
    float rndTime = 3 + arc4random_uniform(4);
    [self scheduleOnce:@selector(hideFish) delay:rndTime];
}

// SORRY! Removing fishes
-(void)hideFish {
    for (Pool *goGo in pools) {
        if (goGo.nemo != NULL) {
            [goGo removeChild:goGo.nemo];
            goGo.nemo = NULL;
        }
    }
    _fishShowing = FALSE;
}

// Checking there are no intersections between targets
-(void)checkTargetsPosition {
    int sth = 0;
    do{
        for (CCSprite *thisTarget in targets) {
            if (![thisTarget isKindOfClass:[NSString class]]){
                for (CCSprite *toCompare in targets) {
                    if (![toCompare isEqual:thisTarget]){
                        if (CGRectIntersectsRect(thisTarget.boundingBox, toCompare.boundingBox))
                            thisTarget.position = [self randomPositionInScreen];
                    }
                }
            }
        }
    } while (sth < _totalNutrias*2);
}

// Getting random position in screen
-(CGPoint)randomPositionInScreen {
    int rndPosition;
    // random position
    rndPosition = 40 + arc4random() % (400);
    float x = rndPosition;
    rndPosition = 50 + arc4random() % (150);
    float y = rndPosition;
    if (y >= 240)
        y -= 200;
    
    // setting the position
    CGPoint thisPosition = ccp(x, y);
    return thisPosition;
}

// Setting correct text format in _fishCountLabel
-(void)setFishLabel {
    NSString *thisCount;
    if (_fishCount < 10)
        thisCount = [NSString stringWithFormat:@"x0%i",_fishCount];
    else
        thisCount = [NSString stringWithFormat:@"x%i",_fishCount];
    [_fishCountLabel setString:thisCount];
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
    else  if (_totalTime == 0){
        _totalTime = 0;
        [self endGame];
    }
    [self setTimeLabel];
}

//TODO: check winning or losing conditions
-(void)endGame {
    if (_level == 1)
        _level++;
    else _level--;
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
    _playButton.enabled = false;
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
