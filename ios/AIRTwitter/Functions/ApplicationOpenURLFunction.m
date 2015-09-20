/**
 * Copyright 2015 Marcel Piestansky (http://marpies.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AIRTwitter.h"
#import "FREObjectUtils.h"
#import "ApplicationOpenURLFunction.h"
#import "AIR.h"
#import "AIRTwitterEvent.h"

NSDictionary* parametersDictionaryFromQueryString( NSString* queryString ) {
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    
    for( NSString *s in queryComponents ) {
        NSArray *pair = [s componentsSeparatedByString:@"="];
        if([pair count] != 2) continue;
        
        NSString *key = pair[0];
        NSString *value = pair[1];
        
        md[key] = value;
    }
    
    return md;
}

FREObject applicationOpenURL( FREContext context, void* functionData, uint32_t argc, FREObject argv[] ) {
    /* If the invoke reason is "standard" then check if login is in process, if so then dispatch LOGIN_CANCEL */
//    NSString* reason = (argv[1] == nil) ? nil : [FREObjectUtils getNSString:argv[1]];
//    if( reason && [reason isEqualToString:@"standard"] && [AIRTwitter isLoginInProcess] ) {
//        [AIR log:@"Login tab was cancelled"];
//        [AIR dispatchEvent:LOGIN_CANCEL];
//    }
//    /* Handle open URL invoke */
//    else {
//
//    }

    NSString* url = (argv[0] == nil) ? nil : [FREObjectUtils getNSString:argv[0]];

    NSURL* nsURL = [NSURL URLWithString:url];
    NSDictionary *d = parametersDictionaryFromQueryString( nsURL.query );

//    NSString* token = d[@"oauth_token"];
    NSString* verifier = d[@"oauth_verifier"];
    NSString* denied = d[@"denied"];

    if( denied || !verifier ) {
        [AIR log:@"App was launched after cancelled attempt to login"];
        [AIR dispatchEvent:LOGIN_CANCEL];
        return nil;
    }

    [AIRTwitter getAccessTokensForPIN:verifier];

    [AIRTwitter setLoginInProcess:NO];
    
    return nil;
}