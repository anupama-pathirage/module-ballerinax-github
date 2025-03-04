// Copyright (c) 2023, WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;

isolated function starTopic(string topicName, string accessToken, http:Client 
        graphQlClient) returns Error? {
    string topicId = check getTopicId(topicName, accessToken, graphQlClient);

    AddStarInput addStarInput = {
        starrableId: topicId
    };

    string stringQuery = getFormulatedStringQueryForAddStar(addStarInput);
    map<json>|Error graphQlData = getGraphQlData(graphQlClient, accessToken, stringQuery);
    if graphQlData is Error {
        return graphQlData;
    }
}

isolated function unstarTopic(string topicName, string accessToken, http:Client 
        graphQlClient) returns Error? {
    string topicId = check getTopicId(topicName, accessToken, graphQlClient);

    RemoveStarInput removeStarInput = {
        starrableId: topicId
    };

    string stringQuery = getFormulatedStringQueryForRemoveStar(removeStarInput);
    map<json>|Error graphQlData = getGraphQlData(graphQlClient, accessToken, stringQuery);
    if graphQlData is Error {
        return graphQlData;
    }
}
