//
//  Node.m
//  NucleoMatch
//
//  Created by John Hervey on 2/08/12.
//
//

#import "Node.h"

@implementation Node

-(id) initWithSuffixNode:(long)node
{
    self = [super init];
    if (self) {
        suffixNode = node;
    }
    return self;
}

@end
