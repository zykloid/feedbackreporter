/*
 * Copyright 2008, Torsten Curdt
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FRCommand.h"


@implementation FRCommand

- (id) initWithPath:(NSString*)pPath
{
    self = [super init];
    if (self != nil) {
        task = [[NSTask alloc] init];
        args = [NSArray array];
        path = pPath;
        error = nil;
        output = nil;
        terminated = NO;
    }
    
    return self;
}

- (void) setArgs:(NSArray*)pArgs
{
    args = pArgs;
}

- (void) setError:(NSMutableString*)pError
{
    error = pError;
}

- (void) setOutput:(NSMutableString*)pOutput
{
    output = pOutput;
}


-(void) appendDataFrom:(NSFileHandle*)fileHandle to:(NSMutableString*)string
{
   NSData *data = [fileHandle availableData];

    if ([data length]) {
        NSString *s = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    
        [output appendString:s];
        //NSLog(@"| %@", s);
        
        [s release];
    }
    [fileHandle waitForDataInBackgroundAndNotify];

}

-(void) outData: (NSNotification *) notification
{
    NSFileHandle *fileHandle = (NSFileHandle*) [notification object];

    [self appendDataFrom:fileHandle to:output];

    [fileHandle waitForDataInBackgroundAndNotify];
}

-(void) errData: (NSNotification *) notification
{
    NSFileHandle *fileHandle = (NSFileHandle*) [notification object];

    [self appendDataFrom:fileHandle to:output];

    [fileHandle waitForDataInBackgroundAndNotify];
}


- (void) terminated: (NSNotification *)notification
{
    // NSLog(@"Task terminated");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    terminated = YES;
}

- (int) execute
{
    [task setLaunchPath:path];
    [task setArguments:args];

    NSPipe *outPipe = [NSPipe pipe];
    NSPipe *errPipe = [NSPipe pipe];

    [task setStandardInput:[NSFileHandle fileHandleWithNullDevice]];
    [task setStandardOutput:outPipe];
    [task setStandardError:errPipe];

    NSFileHandle *outFile = [outPipe fileHandleForReading];
    NSFileHandle *errFile = [errPipe fileHandleForReading]; 

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(outData:)
                                                 name:NSFileHandleDataAvailableNotification
                                               object:outFile];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(errData:)
                                                 name:NSFileHandleDataAvailableNotification
                                               object:errFile];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(terminated:)
                                                 name:NSTaskDidTerminateNotification
                                               object:task];

    [outFile waitForDataInBackgroundAndNotify];
    [errFile waitForDataInBackgroundAndNotify];

    [task launch];

    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    while(!terminated) {
        if (![[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100000]]) {
            break;
        }
        [pool drain];
        pool = [[NSAutoreleasePool alloc] init];
    }
    [pool drain];

    [self appendDataFrom:outFile to:output];
    [self appendDataFrom:errFile to:error];

    int result = [task terminationStatus];

    return result;
}

-(void)dealloc
{
    [task release];

    [super dealloc];
}

@end
