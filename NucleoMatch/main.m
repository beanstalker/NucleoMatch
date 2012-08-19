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
#import <time.h>

#define prime 1299673
#define alpha 256
#define pValue 0.5

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        clock_t time1, time2;
        time1 = clock();
        long double time;
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
        if ([args count] != 3) {
            NSLog(@"Usage: %@ filename KValue", [process processName]);
            return 1;
        }
        filename = [args objectAtIndex:1];
        //Check that argument is a filepath that points to a readable file
        if ([fm isReadableFileAtPath:filename] == NO) {
            NSLog(@"Can't read %@", filename);
            return 2;
        }
        //Get k value
        long k = [[args objectAtIndex:2] integerValue];
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
        long collisions = 0;
        long numberOfQueries = [queries count];
        long numberOfWildCardQueryArrays = 0;
        NSMutableArray *queryScores = [[NSMutableArray alloc] initWithCapacity:numberOfQueries];
        NSMutableArray *totalQueryScores = [[NSMutableArray alloc] initWithCapacity:numberOfQueries];
        NSMutableArray *queryHashes = [[NSMutableArray alloc] initWithCapacity:numberOfQueries];
        NSMutableArray *wildcardQueryArray = [[NSMutableArray alloc] init];
        NSMutableArray *wildcardHashArray = [[NSMutableArray alloc] init];
        
        //Initialise the queryScores to 0
        for (long a = 0; a < numberOfQueries; a++) {
            [queryScores addObject:[NSNumber numberWithLong:0]];
        }
        
        //Initialise the totalQueryScores to 0
        for (long a = 0; a < numberOfQueries; a++) {
            [totalQueryScores addObject:[NSNumber numberWithLong:0]];
        }
        
        //Calculate query hashes (except any that contain wildcard "?")
        long queryLength = k;
        long hasher = 1;
        
        for (long a = 0; a < queryLength - 1; a++) {
            hasher = (hasher * alpha) % prime;
        }
        
        for (long a = 0; a < numberOfQueries; a++) {
            
            //Initialise queryHashes to zero
            [queryHashes addObject:[NSNumber numberWithLong:0]];
            
            //Caclulate hash values (except any that contain wildcard "?")
            for (long b = 0; b < queryLength; b++) {
                long currentHashValue = [[queryHashes objectAtIndex:a] longValue];
                
                if (currentHashValue >= 0 && [[queries objectAtIndex:a] characterAtIndex:b] != '?') {
                    [queryHashes replaceObjectAtIndex:a
                                           withObject:[NSNumber numberWithLong:((alpha * currentHashValue + ([[queries objectAtIndex:a] characterAtIndex:b])) % prime)]];
                } else {//flag queries that contain wildcard and create an array that will store all possible replacement queries
                    if (!(currentHashValue < 0)) {
                        [queryHashes replaceObjectAtIndex:a
                                               withObject:[NSNumber numberWithLong:((numberOfWildCardQueryArrays + 1) * -1)]];
                        [wildcardQueryArray addObject:[[NSMutableArray alloc] init]];
                        [wildcardHashArray addObject:[[NSMutableArray alloc] init]];
                        numberOfWildCardQueryArrays++;
                    }
                    
                }
            }
        }
        /*for (long z = 0; z < numberOfQueries; z++) {
         NSLog(@"Hash of query %li, %@ : %li", (z + 1), [queries objectAtIndex:z], [[queryHashes objectAtIndex:z] longValue]);
         }*/
        //Calculate all of the wildcard replacement queries and their hashes
        for (long a = 0; a < numberOfQueries; a++) {
            NSMutableString *currentQuery = [queries objectAtIndex:a];
            if ([[queryHashes objectAtIndex:a] longValue] < 0) {
                NSMutableArray *currentWildcardQueryArray = [wildcardQueryArray objectAtIndex:(([[queryHashes objectAtIndex:a] longValue] + 1) * -1)];
                NSMutableArray *currentWildcardHashArray = [wildcardHashArray objectAtIndex:(([[queryHashes objectAtIndex:a] longValue] + 1) * -1)];
                
                //Calculate total number of wildcardhashes
                long numberOfWildcards = 0;
                for (long c = 0; c < queryLength; c++) {
                    if ([currentQuery characterAtIndex:c] == '?') {
                        numberOfWildcards++;
                    }
                }
                long numberOfWildcardQueries = pow(4, numberOfWildcards);
                
                //Calculate all of the wildcard queries
                for (long c = 0; c < numberOfWildcardQueries; c++) {
                    i = c;
                    v = i % 4;//4 letters in alphabet
                    i = i / 4;
                    NSMutableString *query = [[NSMutableString alloc] initWithString:[yAlphabet objectAtIndex:v]];
                    for (long d = 1; d < numberOfWildcards; d++) {
                        v = i % 4;//4 letters in alphabet
                        i = i / 4;
                        [query appendString:[yAlphabet objectAtIndex:v]];
                    }
                    [currentWildcardQueryArray addObject:query];
                }
                //Add non-"?" characters from query into wildcardqueries at correct positions
                for (long c = 0; c < queryLength; c++) {
                    const unichar currentCharacter[1] = {[currentQuery characterAtIndex:c]};
                    if (currentCharacter[0] != '?') {
                        NSString *characterToInsert = [[NSString alloc] initWithCharacters:currentCharacter length:1];
                        for (NSMutableString *wildcardQuery in currentWildcardQueryArray) {
                            [wildcardQuery insertString:characterToInsert atIndex:c];
                        }
                    }
                }
                //Calculate the hashes of each wildcard query
                //Initialise all to zero
                for (long c = 0; c < numberOfWildcardQueries; c++) {
                    [currentWildcardHashArray addObject:[NSNumber numberWithLong:0]];
                }
                /*NSLog(@"Query: %@", currentQuery);
                NSLog(@"Hash Values:");
                for (long c = 0; c < numberOfWildcardQueries; c++) {
                    NSLog(@"%@ : %@", [currentWildcardQueryArray objectAtIndex:c], [currentWildcardHashArray objectAtIndex:c]);
                }*/
                //Calculate hash
                for (long c = 0; c < numberOfWildcardQueries; c++) {
                    NSMutableString *currentWildcardQuery = [currentWildcardQueryArray objectAtIndex:c];
                    
                    for (long d = 0; d < queryLength; d++) {
                        NSNumber *currentHashValueObject = [currentWildcardHashArray objectAtIndex:c];
                        long currentHashValue = [currentHashValueObject longValue];
                        [currentWildcardHashArray replaceObjectAtIndex:c
                                                            withObject:[NSNumber numberWithLong: (alpha * currentHashValue + ([currentWildcardQuery characterAtIndex:d])) % prime]];
                    }
                }/*
                NSLog(@"Query: %@", currentQuery);
                NSLog(@"Hash Values:");
                for (long c = 0; c < numberOfWildcardQueries; c++) {
                    NSLog(@"%@ : %@", [currentWildcardQueryArray objectAtIndex:c], [currentWildcardHashArray objectAtIndex:c]);
                }*/
            }
        }
        
        //long seqcount = 0;
        //For every sequence
        for (NSMutableString *currentSeq in library) {
            long seqLength = [currentSeq length];
            long seqHash = 0;
            //seqcount++;
            if (seqLength >= queryLength) {
                
                //Calculate first window hash
                for (long a = 0; a < queryLength; a++) {
                    seqHash = ((alpha * seqHash) + [currentSeq characterAtIndex:a]) % prime;
                }
            } else {//If the sequence is shorter than the query, then there is no hash
                seqHash = -1;
            }
            //NSLog(@"Hash of sequence %li : %li", seqcount, seqHash);
            
            //Slide the query over the sequence character by character
            for (long a = 0; a < (seqLength - queryLength); a++) {
                
                //Check every query against the current window
                for (long b = 0; b < numberOfQueries; b++) {
                    NSMutableString *currentQuery = [queries objectAtIndex:b];
                    NSMutableArray *wildCardHashValues = [[NSMutableArray alloc] initWithCapacity:1];
                    long queryHashValue = [[queryHashes objectAtIndex:b] longValue];
                    [wildCardHashValues addObject:[NSNumber numberWithLong:queryHashValue]];
                    if (queryHashValue < 0) {
                        wildCardHashValues = [wildcardHashArray objectAtIndex:((queryHashValue * -1) - 1)];
                    }
                    
                    //Look for matches
                    for (NSNumber *currentHashValue in wildCardHashValues) {
                        queryHashValue = [currentHashValue longValue];
                        if (queryHashValue == seqHash) {
                            //Check for correct match
                            long c;
                            for (c = 0; c < queryLength; c++) {
                                if ([currentSeq characterAtIndex:(a + c)] != [currentQuery characterAtIndex:c] && [currentQuery characterAtIndex:c] != '?') {
                                    collisions++;
                                    break;
                                }
                            }
                            //If not break, then correct match: increment scores
                            if (c == queryLength) {
                                long score = [[queryScores objectAtIndex:b] longValue];
                                [queryScores replaceObjectAtIndex:b
                                                       withObject:[NSNumber numberWithLong:(score + 1)]];
                            }
                        }
                    }
                }
                //Calculate hash value for next window
                if (a < (seqLength - queryLength)) {
                    //Remove leading character and add trailing character to hash value
                    seqHash = ((alpha * (seqHash - ([currentSeq characterAtIndex:a] * hasher))) + [currentSeq characterAtIndex:(a + queryLength)]) % prime;
                    //Make positive if need be
                    if (seqHash < 0) {
                        seqHash = seqHash + prime;
                    }
                }
            }
            //Normalise to total queryscores (number of sequences with 1 or more rather than total number of hits in all sequences)
            for (long a = 0; a < numberOfQueries; a++) {
                if ([[queryScores objectAtIndex:a] longValue] > 0) {
                    long currentNormalScore = [[totalQueryScores objectAtIndex:a] longValue];
                    [totalQueryScores replaceObjectAtIndex:a
                                                withObject:[NSNumber numberWithLong:(currentNormalScore + 1)]];
                    //reset queryscores
                    [queryScores replaceObjectAtIndex:a
                                           withObject:[NSNumber numberWithLong:0]];
                }
            }
        }
        /*long numberOfScores = 0;
        for (NSNumber *numberscore in totalQueryScores) {
            numberOfScores++;
            //NSLog(@"Score of query %li : %@", numberOfScores, numberscore);
        }*/
        
        //Number of queries that occur in pN sequences:
        FILE *outputFileFixed = fopen("fixedPatterns.txt", "w");
        FILE *outputFileVariable = fopen("variablePatterns.txt", "w");
        long numberFixedPatterns = 0;
        long numberVariablePatterns = 0;
        for (long z = 0; z < numberOfQueries; z++) {
            NSNumber *patternScore = [totalQueryScores objectAtIndex:z];
            if ([patternScore longValue] > (pValue * [library count])) {
                if ([[queryHashes objectAtIndex:z] longValue] >= 0) {
                    numberFixedPatterns++;
                    fprintf(outputFileFixed, "%s\n", [[queries objectAtIndex:z] cStringUsingEncoding:NSUTF8StringEncoding]);
                } else {
                    numberVariablePatterns++;
                    fprintf(outputFileVariable, "%s\n", [[queries objectAtIndex:z] cStringUsingEncoding:NSUTF8StringEncoding]);
                }
            }
        }
        time2 = clock();
        time = (long double)(time2 - time1) / (long double)CLOCKS_PER_SEC;
        printf("%li, %li, %li, %li, %Lf\n", k, numberFixedPatterns, numberVariablePatterns, collisions, time);
        //NSLog(@"Number fixed patterns: %li", numberFixedPatterns);
        //NSLog(@"Number variable patterns: %li", numberVariablePatterns);
        //NSLog(@"Number of collisions: %li", collisions);
        fclose(outputFileFixed);
        fclose(outputFileVariable);
        
    }//end autoreleasepool
    return 0;
}//end main
