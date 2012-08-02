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
    int firstCharacterIndex, lastCharacterIndex;
    int startNode, endNode;
}

@end
