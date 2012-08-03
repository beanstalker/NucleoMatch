//
//  Suffix.m
//  NucleoMatch
//
//  Created by John Hervey on 2/08/12.
//
//

#import "Suffix.h"

@implementation Suffix

-(id) initWithFirstChar:(long)first lastChar:(long)last originNode:(long)node
{
    self = [super init];
    if (self) {
        firstCharacter = first;
        lastCharacter = last;
        originNode = node;
    }
    return self;
}

@end
