//
//  Sequence.m
//  NucleoMatch
//
//  Created by John Hervey on 26/07/12.
//  Copyright (c) 2012 JRDH. All rights reserved.
//

#import "Sequence.h"

@implementation Sequence

@synthesize percentGC;
@synthesize seq;
@synthesize type;

-(void) print
{
    NSLog(@"%@", seq);
}

-(BOOL) isEqual:(Sequence *)theSequence
{
    if ([seq isEqualToString:theSequence.seq]) {
        return YES;
    } else {
        return NO;
    }
}

@end
