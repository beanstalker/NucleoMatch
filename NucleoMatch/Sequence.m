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
    NSLog(@"seq  %@", seq);
}

-(BOOL) isEqual:(Sequence *)theSequence
{
    if ([seq isEqualToString:theSequence.seq]) {
        return YES;
    } else {
        return NO;
    }
}

-(id) initWithSequence:(NSString *)theSequence type:(nucleicAcidType)acid
{
    self = [super init];
    seq = [[NSString alloc] initWithString:theSequence];
    type = acid;
    return self;
}

@end
