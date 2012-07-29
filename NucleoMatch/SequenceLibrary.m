//
//  SequenceLibrary.m
//  NucleoMatch
//
//  Created by John Hervey on 26/07/12.
//  Copyright (c) 2012 JRDH. All rights reserved.
//

#import "SequenceLibrary.h"

@implementation SequenceLibrary

@synthesize numberOfSequences;

-(id) init
{
    self = [super init];
    if (self) {
        seqLib = [[NSMutableArray alloc] init];
    }
    numberOfSequences = 0;
    return self;
}

-(void) addSequence:(Sequence *)sequence
{
    [seqLib addObject:sequence];
    numberOfSequences++;
}

-(void) removeSequence:(Sequence *)sequence
{
    [seqLib removeObject:sequence];
    numberOfSequences--;
}

-(void) removeSequenceAtIndex:(int)index
{
    [seqLib removeObjectAtIndex:index];
    numberOfSequences--;
}

-(void) print
{
    for (Sequence *theSeq in seqLib){
        const char *cString = [[theSeq seq] cStringUsingEncoding:NSUTF8StringEncoding];
        printf("%s\n", cString);
        //[[NSFileHandle fileHandleWithStandardOutput] writeData:[[theSeq seq] dataUsingEncoding: NSUTF8StringEncoding]];
        //- (NSString *)debugDescription;
    }
    NSLog(@"Number of sequences: %i", numberOfSequences);
}

@end
