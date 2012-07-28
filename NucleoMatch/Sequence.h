//
//  Sequence.h
//  NucleoMatch
//
//  Created by John Hervey on 26/07/12.
//  Copyright (c) 2012 JRDH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {RNA, DNA} nucleicAcidType;

@interface Sequence : NSObject
{
    NSString *seq;
    int percentGC;
    nucleicAcidType type;
}

@property (copy, nonatomic) NSString *seq;
@property (nonatomic) int percentGC;
@property (nonatomic) nucleicAcidType type;

-(void) print;
-(BOOL) isEqual:(Sequence *)theSequence;
-(id) initWithSequence:(NSString *)theSequence type:(nucleicAcidType)acid;

@end
