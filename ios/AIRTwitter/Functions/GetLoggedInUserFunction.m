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

#import "GetLoggedInUserFunction.h"
#import "FREObjectUtils.h"
#import "AIRTwitterUser.h"
#import "AIRTwitter.h"
#import "AIR.h"
#import "AIRTwitterEvent.h"
#import "StringUtils.h"
#import "UserUtils.h"

FREObject getLoggedInUser(FREContext context, void* functionData, uint32_t argc, FREObject* argv) {
    const int callbackID = [FREObjectUtils getInt:argv[0]];

    AIRTwitterUser* user = [AIRTwitter loggedInUser];
    /* Return cached object */
    if( user ) {
        NSMutableDictionary* userJSON = [UserUtils getJSON:user];
        userJSON[@"callbackID"] = @(callbackID);
        userJSON[@"success"] = @(true);
        userJSON[@"loggedInUser"] = @(true);	// So that we can cache the user object in AS3
        [AIR dispatchEvent:USER_QUERY_SUCCESS withMessage:[StringUtils getJSONString:userJSON]];
    }
    /* Request user info */
    else if( [AIRTwitter accessToken] ) {
        STTwitterAPI* twitter = [AIRTwitter api];
        [twitter getUserInformationFor:[twitter userName] successBlock:^(NSDictionary* user) {
            AIRTwitterUser* loggedInUser = [UserUtils getUser:user];
            /* Cache the user object */
            [AIRTwitter setLoggedInUser:loggedInUser];
            /* Create JSON */
            NSMutableDictionary* userJSON = [UserUtils getJSON:loggedInUser];
            userJSON[@"callbackID"] = @(callbackID);
            userJSON[@"success"] = @(true);
            userJSON[@"loggedInUser"] = @(true);	// So that we can cache the user object in AS3
            /* Dispatch */
            [AIR log:[NSString stringWithFormat:@"Retrieved user info success: %@", userJSON[@"screenName"]]];
            NSString* resultJSON = [StringUtils getJSONString:userJSON];
            if( resultJSON ) {
                [AIR dispatchEvent:USER_QUERY_SUCCESS withMessage:resultJSON];
            } else {
                [AIR dispatchEvent:USER_QUERY_SUCCESS withMessage:[StringUtils getEventErrorJSONString:callbackID errorMessage:@"User query suceeded but could not parse returned user data."]];
            }
        } errorBlock:^(NSError* error) {
            [AIR log:[NSString stringWithFormat:@"Retrieved user info error: %@", error.localizedDescription]];
            [AIR dispatchEvent:USER_QUERY_ERROR withMessage:[StringUtils getEventErrorJSONString:callbackID errorMessage:error.localizedDescription]];
        }];
    }
    /* User not logged in, error */
    else {
        [AIR log:@"User is not logged in - cannot retrieve info."];
        [AIR dispatchEvent:USER_QUERY_ERROR withMessage:[StringUtils getEventErrorJSONString:callbackID errorMessage:@"User is not logged in."]];
    }

    return nil;
}