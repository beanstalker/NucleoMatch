//
//  main.m
//  NucleoMatch
//
//  Created by John Hervey on 26/07/12.
//  Copyright (c) 2012 JRDH. All rights reserved.
//  Uses Automatic reference counting (ARC).
//

#import <Foundation/Foundation.h>
#import "SequenceLibrary.h"
#import "Sequence.h"
#import <stdio.h>
#import <stdlib.h>
#import <math.h>

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        
        //Get an input file from a filepath given as an argument.
        //Process the input file into individual sequences and store in a
        // SequenceLibrary object.
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
            NSLog(@"Can't read %@", filename);
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
            NSLog(@"Can't read %@. Check encoding (Try UTF8).", filename);
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
        
        
        //Calculate all k-mer query patterns. These will be the search terms
        // when searching the sequences from the input file for frequent
        // patterns.
        NSArray *yAlphabet = [NSArray arrayWithObjects:@"A", @"C", @"G", @"U", nil];
        NSArray *xAlphabet = [NSArray arrayWithObjects:@"A", @"C", @"G", @"U", @"?", nil];
        NSMutableArray *queries = [[NSMutableArray alloc] init];
        int i, v;
        int k = 4;
        int count = 0;
        int numberOfCases = 16 * pow(5 , (k - 2));
        
        for (int n = 0; n < numberOfCases; n++) {
            i = n;
            v = i % 4;
            i = i / 4;
            count++;
            NSMutableString *query = [[NSMutableString alloc] initWithString:[yAlphabet objectAtIndex:v]];
            for (int m = 1; m < (k - 1); m++) {
                v = i % 5;
                i = i / 5;
                [query appendString:[xAlphabet objectAtIndex:v]];
            }
            [query appendString:[yAlphabet objectAtIndex:i]];
            [queries addObject:query];
        }
        NSLog(@"No. queries looped: %i", count);
        
        //print the array to confirm
        int count1 = 0;
        for (NSMutableString *str in queries) {
            fprintf(stderr, "%s\n", [str cStringUsingEncoding:NSUTF8StringEncoding]);
            count1++;
        }
        NSLog(@"No. queries printed: %i", count1);
        NSLog(@"Counts match? : %@", (count == count1 ? @"YES" : @"NO"));
    }
    return 0;
}

