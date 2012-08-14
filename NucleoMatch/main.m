//
//  main.m
//  NucleoMatch
//
//  Created by John Hervey on 26/07/12.
//  Copyright (c) 2012 JRDH. All rights reserved.
//  Uses Automatic reference counting (ARC).
//

#import <Foundation/Foundation.h>
//#import "SequenceLibrary.h"
//#import "Sequence.h"
#import <stdio.h>
#import <stdlib.h>
#import <math.h>

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        
        //Get an input file from a filepath given as an argument.
        //Process the input file into individual sequences and store in a
        // SequenceLibrary object.
        //SequenceLibrary *library = [[SequenceLibrary alloc] init];
        //Sequence *seq;
        NSMutableArray *library = [[NSMutableArray alloc] init];
        NSMutableString *seq;
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
            seq = [[NSMutableString alloc] initWithString:line];
            //[seq print];
            [library addObject:seq];
        }
        //[library print];
        for (NSMutableString *str in library) {
            printf("%s\n", [str cStringUsingEncoding:NSUTF8StringEncoding]);
        }
        NSLog(@"Number of sequences: %li", [library count]);
        
        //Calculate all k-mer query patterns. These will be the search terms
        // when searching the sequences from the input file for frequent
        // patterns.
        NSArray *yAlphabet = [NSArray arrayWithObjects:@"A", @"C", @"G", @"U", nil];
        NSArray *xAlphabet = [NSArray arrayWithObjects:@"A", @"C", @"G", @"U", @"?", nil];
        NSMutableArray *queries = [[NSMutableArray alloc] init];
        long i, v;
        long k = 3;
        long count = 0;
        long numberOfCases = 16 * pow(5 , (k - 2));
        
        for (long n = 0; n < numberOfCases; n++) {
            i = n;
            v = i % 4;//4 letters in alphabet
            i = i / 4;
            count++;
            NSMutableString *query = [[NSMutableString alloc] initWithString:[yAlphabet objectAtIndex:v]];
            for (long m = 1; m < (k - 1); m++) {
                v = i % 5;//5 letters in alphabet
                i = i / 5;
                [query appendString:[xAlphabet objectAtIndex:v]];
            }
            [query appendString:[yAlphabet objectAtIndex:i]];
            [queries addObject:query];
        }
        NSLog(@"No. queries looped: %li", count);
        //print the array to confirm
        long count1 = 0;
        for (NSMutableString *str in queries) {
            fprintf(stderr, "%s\n", [str cStringUsingEncoding:NSUTF8StringEncoding]);
            count1++;
        }
        NSLog(@"No. queries printed: %li", count1);
        NSLog(@"Counts match? : %@", (count == count1 ? @"YES" : @"NO"));
        NSLog(@"Queries in array: %li", [queries count]);
        
        //Use Rabin-karp algorithm to search the sequence library with all
        // query patterns. Record the number of sequences that have a match
        // with a given pattern. Multiple matches within the same sequence only
        // count as one hit. We want the number of sequences that have a match
        // (one or more) NOT the total number of matches.
        long queryScores[[queries count]];
        //Initialise the queryScores to 0
        for (long z = 0; z < [queries count]; z++) {
            queryScores[z] = 0;
        }
        //Calculate all query hashes
        //BAD!!! USES ? in hash! NO NO NO
        //Could precalculate hash for all queries that do not contain ? and flag the ones
        // that do for calculation later?
        long queryHashes[[queries count]];
        long queryLength = k;
        for (long z = 0; z < [queries count]; z++) {
            queryHashes[z] = 0;
            for (int w = 0; w < queryLength; w++) {
                queryHashes[z] += ([[queries objectAtIndex:z] characterAtIndex:w] * (long) pow(5, (queryLength - w + 1)) % 2049);
            }
        }
        for (long z = 0; z < [queries count]; z++) {
            NSLog(@"Hash of query %li : %li", (z + 1), queryHashes[z]);
        }
        //TEST this implementation for speed with other input file and other k's before
        // implementing rabin karp rolling hash amd comparison
        //Search the sequences
        for (NSMutableString *currentSeq in library) {
            long seqLength = [currentSeq length];
            long seqHash = 0;
            //Calculate first window hash
            for (int w = 0; w < queryLength; w++) {
                seqHash += ([currentSeq characterAtIndex:w] * (long) pow(5, (queryLength - w + 1)) % 2049);
            }
            NSLog(@"Hash of sequence %li", seqHash);
            for (long z = 0; z < (seqLength - queryLength); z++) {
                //
                NSLog(@"%@", currentSeq);
            }
        }
    }
    return 0;
}

