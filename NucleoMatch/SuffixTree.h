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
    NSString *inputString;
    Node *root;
    long currentSuffix, lastIndex, numberOfNodes;
}

-(id) initWithString:(NSString *) theString;

@end
