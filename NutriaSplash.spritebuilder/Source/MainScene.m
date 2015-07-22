
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

-(void)didLoadFromCCB {
    [[OALSimpleAudio sharedInstance] playBgWithLoop:YES];
}

#pragma mark - SCENE METHODS

//TODO: Create Level Menu
// Going to Gameplay Scene
-(void)play {
    _playButton.enabled = false;
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[OALSimpleAudio sharedInstance] stopBg];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

@end
