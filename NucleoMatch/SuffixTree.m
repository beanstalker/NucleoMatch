//
//  SuffixTree.m
//  NucleoMatch
//
//  Created by John Hervey on 2/08/12.
//
//

#import "SuffixTree.h"

@implementation SuffixTree

-(id) initWithString:(NSString *)theString
{
    self = [super init];
    if (self) {
        //Initialise
        inputString = [[NSString alloc] initWithString:theString];//copy or pass?
        root = [[Node alloc] initWithSuffixNode:-1];
        nodes = [[NSMutableArray alloc] initWithCapacity:[inputString length] * 2];
        
        //Add the first suffix
        [nodes addObject:root];
        lastIndex = [inputString length];
        currentSuffix = 0;
        numberOfNodes = 1;
    }
    return  self;
}

@end
