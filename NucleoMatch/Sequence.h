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
    double percentGC;
    nucleicAcidType type;
}

@property (copy, nonatomic) NSString *seq;

-(void) print;
-(BOOL) isEqual:(Sequence *)theSequence;
-(id) initWithSequence:(NSString *)theSequence;
-(double) percentGC;
-(NSString *) dnaOrRNA;

@end
