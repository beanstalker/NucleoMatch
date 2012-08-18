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
#define kvalue 8
#define pValue 0.5

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
        NSMutableArray *totalQueryScores = [[NSMutableArray alloc] initWithCapacity:numberOfQueries];
        //Initialise the totalQueryScores to 0
        for (long z = 0; z < numberOfQueries; z++) {
            [totalQueryScores addObject:[NSNumber numberWithLong:0]];
        }
        //Calculate query hashes (except any that contain wildcard "?")
        NSMutableArray *queryHashes = [[NSMutableArray alloc] initWithCapacity:numberOfQueries];
        long queryLength = k;
        long hasher = 1;
        for (long z = 0; z < queryLength - 1; z++) {
            hasher = (hasher * alpha) % prime;
        }
        for (long z = 0; z < numberOfQueries; z++) {
            //Initialise querHashes to zero
            [queryHashes addObject:[NSNumber numberWithLong:0]];
            //Caclulate hash values (except any that contain wildcard "?")
            for (long w = 0; w < queryLength; w++) {
                long currentHashValue = [[queryHashes objectAtIndex:z] longValue];
                if (currentHashValue != -1 && [[queries objectAtIndex:z] characterAtIndex:w] != '?') {
                    [queryHashes replaceObjectAtIndex:z
                                           withObject:[NSNumber numberWithLong:((alpha * currentHashValue + ([[queries objectAtIndex:z] characterAtIndex:w])) % prime)]];
                } else {//flag queries that contain wildcard
                    [queryHashes replaceObjectAtIndex:z
                                           withObject:[NSNumber numberWithLong:-1]];
                }
            }
        }
        /*for (long z = 0; z < numberOfQueries; z++) {
            NSLog(@"Hash of query %li, %@ : %li", (z + 1), [queries objectAtIndex:z], [[queryHashes objectAtIndex:z] longValue]);
        }*/
        long seqcount = 0;
        //For every sequence
        for (NSMutableString *currentSeq in library) {
            long seqLength = [currentSeq length];
            long seqHash = 0;
            seqcount++;
            if (seqLength >= queryLength) {
                //Calculate first window hash
                for (long w = 0; w < queryLength; w++) {
                    seqHash = ((alpha * seqHash) + [currentSeq characterAtIndex:w]) % prime;
                }
            } else {//If the sequence is shorter than the query, then there is no hash
                seqHash = -1;
            }
            //NSLog(@"Hash of sequence %li : %li", seqcount, seqHash);
            //Slide the query over the sequence character by character
            for (long z = 0; z < (seqLength - queryLength); z++) {
                //Check every query against the current window
                for (long w = 0; w < numberOfQueries; w++) {
                    long queryHashValue = [[queryHashes objectAtIndex:w] longValue];
                    NSMutableString *currentQuery = [queries objectAtIndex:w];
                    //If it is a wildcard sequence, calculate the hash for each character replacement
                    //NSLog(@"Current seqHash : %li Current queryHash : %li", seqHash, queryHashValue);
                    if (queryHashValue == seqHash) {
                        //Check for correct match
                        long y;
                        for (y = 0; y < queryLength; y++) {
                            if ([currentSeq characterAtIndex:(z + y)] != [currentQuery characterAtIndex:y]) {
                                break;
                            }
                        }
                        //If not break, then correct match: increment scores
                        if (y == queryLength) {
                            long score = [[queryScores objectAtIndex:w] longValue];
                            [queryScores replaceObjectAtIndex:w withObject:[NSNumber numberWithLong:(score + 1)]];
                        }
                    }
                }
                //Calculate hash value for next window
                if (z < (seqLength - queryLength)) {
                    //Remove leading character and add trailing character to hash value
                    seqHash = ((alpha * (seqHash - ([currentSeq characterAtIndex:z] * hasher))) + [currentSeq characterAtIndex:(z + queryLength)]) % prime;
                    //Make positive if need be
                    if (seqHash < 0) {
                        seqHash = seqHash + prime;
                    }
                }
            }
            //Normalise to total queryscores (number of sequences with 1 or more rather than total number of hits in all sequences)
            for (long w = 0; w < numberOfQueries; w++) {
                if ([[queryScores objectAtIndex:w] longValue] > 0) {
                    long currentNormalScore = [[totalQueryScores objectAtIndex:w] longValue];
                    [totalQueryScores replaceObjectAtIndex:w withObject:[NSNumber numberWithLong:(currentNormalScore + 1)]];
                    //reset queryscores
                    [queryScores replaceObjectAtIndex:w withObject:[NSNumber numberWithLong:0]];
                }
            }
        }
        /*long numberOfScores = 0;
        for (NSNumber *numberscore in totalQueryScores) {
            numberOfScores++;
            NSLog(@"Score of query %li : %@", numberOfScores, numberscore);
        }*/
        
        //Number of queries that occur in pN sequences:
        long numberFixedPatterns = 0;
        for (NSNumber *patternScore in totalQueryScores) {
            if ([patternScore longValue] > (pValue * [library count])) {
                numberFixedPatterns++;
            }
        }
        NSLog(@"Number fixed patterns: %li", numberFixedPatterns);
    }//end autoreleasepool
    return 0;
}//end main
