
#import "MainScene.h"

#pragma mark - COMPONENTS AND VARIABLES

@implementation MainScene{
    CCButton* _playButton;
}

#pragma mark - INITIALIZING

-(id)init{
    if (self = [super init]) {
    }
    return self;
}

#pragma mark - SCENE METHODS

-(void)play {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
    _playButton.enabled = false;
}

@end
