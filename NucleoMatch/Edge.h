//
//  Edge.h
//  NucleoMatch
//
//  Created by John Hervey on 2/08/12.
//
//

#import <Foundation/Foundation.h>
#import "Node.h"

@interface Edge : NSObject
{
    long firstCharacterIndex, lastCharacterIndex;
    long startNode, endNode;
}

-(id) initWithFirstChar:(long) first lastChar:(long) last parentNode:(long) node;

@end
