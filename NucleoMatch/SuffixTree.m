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
        nodes = [[NSMutableArray alloc] initWithCapacity:[inputString length] * 2];
        edges = [[NSMutableArray alloc] initWithCapacity:[inputString length] * 2];
        root = [[Node alloc] initWithSuffixNode:-1];
        
        //Add the root node
        [nodes addObject:root];
        lastIndex = [inputString length];
        currentSuffix = 0;
        numberOfNodes = 1;
        activeNode = root;
        activeEdge = NULL;
        activeLength = 0;
        
        //Add suffixes
        for (int i = 0; i < lastIndex; i++) {
            <#statements#>
        }
    }
    return  self;
}

@end
