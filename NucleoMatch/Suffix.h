//
//  Suffix.h
//  NucleoMatch
//
//  Created by John Hervey on 2/08/12.
//
//

#import <Foundation/Foundation.h>

@interface Suffix : NSObject
{
    BOOL leafNode, explicitNode, implicitNode;
    long firstCharacter, lastCharacter, originNode;
}

-(id) initWithFirstChar:(long) first lastChar:(long) last originNode:(long) node;

@end
