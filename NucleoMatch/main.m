//
//  main.m
//  NucleoMatch
//
//  Created by John Hervey on 26/07/12.
//  Copyright (c) 2012 JRDH. All rights reserved.
//  Uses Automatic reference counting (ARC).
//

#import <Foundation/Foundation.h>
#import <stdio.h>
#import <stdlib.h>
#import <math.h>

#define prime 2049
#define alpha 256
#define kvalue 3

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        
        //Get an input file from a filepath given as an argument.
        //Process the input file into individual strings (one per line of the
        // input file) and store in an array.
        NSMutableArray *library = [[NSMutableArray alloc] init];
        NSMutableString *seq;
        NSProcessInfo *process = [NSProcessInfo processInfo];
        NSArray *args = [process arguments];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *filename, *data, *line;
        NSStringEncoding encoding;
        NSScanner *scanner;
        NSCharacterSet *newline = [NSCharacterSet newlineCharacterSet];
        
        //Check for argument
        if ([args count] != 2) {
            NSLog(@"Usage: %@ filename", [process processName]);
            return 1;
        }
        filename = [args objectAtIndex:1];
        //Check that argument is a filepath that points to a readable file
        if ([fm isReadableFileAtPath:filename] == NO) {
            NSLog(@"Can't read %@", filename);
            return 2;
        }
        //Guess and check file encoding
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
        //Process file into strings
        scanner = [NSScanner scannerWithString:data];
        while ([scanner isAtEnd] == NO) {
            [scanner scanUpToCharactersFromSet:newline intoString:&line];
            seq = [[NSMutableString alloc] initWithString:line];
            [library addObject:seq];
        }
        /*for (NSMutableString *str in library) {
            printf("%s\n", [str cStringUsingEncoding:NSUTF8StringEncoding]);
        }*/
        NSLog(@"Number of sequences: %li", [library count]);
        
        //Calculate all k-mer query patterns. These will be the search terms
        // when searching the sequences from the input file for frequent
        // patterns.
        NSArray *yAlphabet = [NSArray arrayWithObjects:@"A", @"C", @"G", @"U", nil];
        NSArray *xAlphabet = [NSArray arrayWithObjects:@"A", @"C", @"G", @"U", @"?", nil];
        NSMutableArray *queries = [[NSMutableArray alloc] init];
        long i, v;
        long k = kvalue;
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
        /*long count1 = 0;
        for (NSMutableString *str in queries) {
            fprintf(stderr, "%s\n", [str cStringUsingEncoding:NSUTF8StringEncoding]);
            count1++;
        }
        NSLog(@"No. queries printed: %li", count1);
        NSLog(@"Counts match? : %@", (count == count1 ? @"YES" : @"NO"));*/
        NSLog(@"Queries in array: %li", [queries count]);
        
        //Use Rabin-karp algorithm to search the sequence library with all
        // query patterns. Record the number of sequences that have a match
        // with a given pattern. Multiple matches within the same sequence only
        // count as one hit. We want the number of sequences that have a match
        // (one or more) NOT the total number of matches.
        long numberOfQueries = [queries count];
        NSMutableArray *queryScores = [[NSMutableArray alloc] initWithCapacity:numberOfQueries];
        //Initialise the queryScores to 0
        for (long z = 0; z < numberOfQueries; z++) {
            [queryScores addObject:[NSNumber numberWithLong:0]];
        }
        //Calculate query hashes (except any that contain wildcard "?")
        NSMutableArray *queryHashes = [[NSMutableArray alloc] initWithCapacity:numberOfQueries];
        long queryLength = k;
        for (long z = 0; z < numberOfQueries; z++) {
            [queryHashes addObject:[NSNumber numberWithLong:0]];
            for (int w = 0; w < queryLength; w++) {
                long currentHashValue = [[queryHashes objectAtIndex:z] longValue];
                if (currentHashValue != -1 && [[queries objectAtIndex:z] characterAtIndex:w] != '?') {
                    [queryHashes replaceObjectAtIndex:z
                                           withObject:[NSNumber numberWithLong:(currentHashValue + ([[queries objectAtIndex:z] characterAtIndex:w] * (long) pow(5, (queryLength - w + 1)) % prime))]];
                } else {//flag queries that contain wildcard
                    [queryHashes replaceObjectAtIndex:z
                                           withObject:[NSNumber numberWithLong:-1]];
                }
            }
        }
        /*for (long z = 0; z < numberOfQueries; z++) {
            NSLog(@"Hash of query %li, %@ : %li", (z + 1), [queries objectAtIndex:z], [[queryHashes objectAtIndex:z] longValue]);
        }*/
        //TEST this implementation for speed with other input file and other k's before
        // implementing rabin karp rolling hash amd comparison
        //Search the sequences
        long seqcount = 0;
        for (NSMutableString *currentSeq in library) {
            long seqLength = [currentSeq length];
            long seqHash = 0;
            seqcount++;
            if (seqLength >= queryLength) {
                //Calculate first window hash
                for (int w = 0; w < queryLength; w++) {
                    seqHash += ([currentSeq characterAtIndex:w] * (long) pow(5, (queryLength - w + 1)) % prime);
                }
            } else {
                seqHash = -1;
            }
            //NSLog(@"Hash of sequence %li : %li", seqcount, seqHash);
            for (long z = 0; z < (seqLength - queryLength); z++) {
                //
                count++;
            }
        }
    }
    return 0;
}

