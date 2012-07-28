//
//  Sequence.h
//  NucleoMatch
//
//  Created by John Hervey on 26/07/12.
//  Copyright (c) 2012 JRDH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sequence : NSObject
{
    NSMutableString *seq;
    int percentGC;
    enum nucleicAcidType {RNA, DNA};
}

@property NSMutableString *seq;
@property int percentGC;

-(void) print;
-(void) setNucleicAcidType:(enum nucleicAcidType)acidType;
-(void) nucleicAcidType:(enum nucleicAcidType)acidType;

@end
