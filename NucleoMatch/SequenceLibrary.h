//
//  SequenceLibrary.h
//  NucleoMatch
//
//  Created by John Hervey on 26/07/12.
//  Copyright (c) 2012 JRDH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sequence.h"

@interface SequenceLibrary : NSObject
{
    NSMutableArray *seqLib;
}

-(id) init;
-(void) addSequence:(Sequence *)sequence;
-(void) removeSequence:(Sequence *)sequence;
-(void) removeSequenceAtIndex:(int)index;

@end
