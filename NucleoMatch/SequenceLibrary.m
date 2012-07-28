//
//  SequenceLibrary.m
//  NucleoMatch
//
//  Created by John Hervey on 26/07/12.
//  Copyright (c) 2012 JRDH. All rights reserved.
//

#import "SequenceLibrary.h"

@implementation SequenceLibrary

-(id) init
{
    self = [super init];
    if (self) {
        seqLib = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addSequence:(Sequence *)sequence
{
    [seqLib addObject:sequence];
}

-(void) removeSequence:(Sequence *)sequence
{
    [seqLib removeObject:sequence];
}

-(void) removeSequenceAtIndex:(int)index
{
    [seqLib removeObjectAtIndex:index];
}

@end
