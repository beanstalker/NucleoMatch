//
//  main.m
//  NucleoMatch
//
//  Created by John Hervey on 26/07/12.
//  Copyright (c) 2012 JRDH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SequenceLibrary.h"
#import "Sequence.h"
#include <stdio.h>


int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        SequenceLibrary *library = [[SequenceLibrary alloc] init];
        Sequence *seq;
        NSProcessInfo *process = [NSProcessInfo processInfo];
        NSArray *args = [process arguments];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *filename, *data, *line;
        NSStringEncoding encoding;
        NSScanner *scanner;
        NSCharacterSet *newline = [NSCharacterSet newlineCharacterSet];
        
        if ([args count] != 2) {
            NSLog(@"Usage: %@ filename", [process processName]);
            return 1;
        }
        filename = [args objectAtIndex:1];
        if ([fm isReadableFileAtPath:filename] == NO) {
            NSLog(@"2 Can't read %@", filename);
            return 2;
        }
        data = [NSString stringWithContentsOfFile:filename
                                     usedEncoding:&encoding
                                            error:nil];
        if (data == nil) {
            data = [NSString stringWithContentsOfFile:filename
                                             encoding:NSUTF8StringEncoding
                                                error:nil];
            encoding = NSUTF8StringEncoding;
        }
        if (data == nil) {
            NSLog(@"3 Can't read %@", filename);
            return 3;
        }
        NSLog(@"Encoding of %@ was %lu", filename, encoding);
        scanner = [NSScanner scannerWithString:data];
        while ([scanner isAtEnd] == NO) {
            [scanner scanUpToCharactersFromSet:newline intoString:&line];
            //NSLog(@"line %@", line);
            seq = [[Sequence alloc] initWithSequence:line];
            //[seq print];
            [library addSequence:seq];
        }
        [library print];
    }
    return 0;
}

