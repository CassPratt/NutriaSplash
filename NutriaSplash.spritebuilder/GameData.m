//
//  GameData.m
//  MiniMusicGame
//
//  Created by Cassandra Pratt Romero on 7/28/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameData.h"

@implementation GameData

//static variable - this stores our singleton instance
static GameData *sharedData = nil;

+(GameData*) sharedData
{
    //If our singleton instance has not been created (first time it is being accessed)
    if(sharedData == nil)
    {
        //create our singleton instance
        sharedData = [[GameData alloc] init];
        
        //collections (Sets, Dictionaries, Arrays) must be initialized
        sharedData.level = 0;
    }
    
    //if the singleton instance is already created, return it
    return sharedData;
}

@end
