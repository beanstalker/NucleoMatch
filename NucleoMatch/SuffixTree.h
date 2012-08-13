//
//  SuffixTree.h
//  NucleoMatch
//
//  Created by John Hervey on 2/08/12.
//
//

#import <Foundation/Foundation.h>
#import "Edge.h"
#import "Node.h"
#import "Suffix.h"

@interface SuffixTree : NSObject
{
    NSMutableArray *nodes;
    NSMutableArray *edges;
    NSString *inputString;
    Node *root;
    Node *activeNode;
    Edge *activeEdge;
    long currentSuffix, lastIndex, numberOfNodes, activeLength, remainder;
}

-(id) initWithString:(NSString *) theString;

@end
