//
//  Edge.m
//  NucleoMatch
//
//  Created by John Hervey on 2/08/12.
//
//

#import "Edge.h"

@implementation Edge

-(id) initWithFirstChar:(long)first lastChar:(long)last parentNode:(long)node
{
    self = [super init];
    if (self) {
        firstCharacterIndex = first;
        lastCharacterIndex = last;
        startNode = node;
    }
    return self;
}

@end
