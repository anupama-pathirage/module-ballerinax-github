//
// Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
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
//

package src.github;

import ballerina.net.http;

string gitAccessToken = "";

@Description {value:"GitHub client connector"}
public struct GitHubConnector {
    string accessToken;
}

@Description {value:"Get a repository of an owner"}
@Param {value:"name: Name of the form owner/repository"}
@Return {value:"Repository: Repository struct"}
@Return {value:"error: Error"}
public function <GitHubConnector gitHubConnector> getRepository (string name) (Repository, GitConnectorError) {
    endpoint http:ClientEndpoint gitHubEndpoint {
        targets: [{uri:GIT_API_URL}]
    };
    GitConnectorError connectorError;

    if (name == null || name == "") {
        connectorError = {message:["Repository owner and name should be specified."]};
        return null, connectorError;
    }
    string[] repoIdentifier = name.split(GIT_PATH_SEPARATOR);
    string repoOwner = repoIdentifier[GIT_INDEX_ZERO];
    string repoName = repoIdentifier[GIT_INDEX_ONE];
    http:Request request = {};
    http:Response response = {};
    http:HttpConnectorError httpError;
    Repository singleRepository;

    string stringQuery = string `{"{{GIT_VARIABLES}}":{"{{GIT_OWNER}}":"{{repoOwner}}","{{GIT_NAME}}":"{{repoName}}"},"{{GIT_QUERY}}":"{{GET_REPOSITORY}}"}`;

    var jsonQuery, _ = <json>stringQuery;

    // Set headers and payload to the request
    constructRequest(request, jsonQuery, gitHubConnector.accessToken);

    // Make an HTTP POST request 
    response, httpError = gitHubEndpoint -> post("", request);
    if (httpError != null) {
        connectorError = {message:[httpError.message], statusCode:httpError.statusCode};
        return null, connectorError;
    }
    json validatedResponse;
    validatedResponse, connectorError = getValidatedResponse(response, GIT_NAME);
    if (connectorError != null) {
        return null, connectorError;
    }
    try {
        var githubRepositoryJson, _ = (json)validatedResponse[GIT_DATA][GIT_REPOSITORY];
        singleRepository, _ = <Repository>githubRepositoryJson;
    } catch (error e) {
        connectorError = {message:[e.message]};
        return null, connectorError;
    }

    return singleRepository, connectorError;
}

@Description {value:"Get an organization"}
@Param {value:"name: Name of the organization"}
@Return {value:"Organization: Organization struct"}
@Return {value:"GitConnectorError: Error"}
public function <GitHubConnector gitHubConnector> getOrganization (string name) (Organization, GitConnectorError) {
    endpoint http:ClientEndpoint gitHubEndpoint {
        targets: [{uri:GIT_API_URL}]
    };

    GitConnectorError connectorError;

    if (null == name || "" == name) {
        connectorError = {message:["Organization name should be specified."]};
        return null, connectorError;
    }
    http:Request request = {};
    http:Response response = {};
    http:HttpConnectorError httpError;
    Organization singleOrganization;

    string stringQuery = string `{"{{GIT_VARIABLES}}":{"{{GIT_ORGANIZATION}}":"{{name}}"},
        "{{GIT_QUERY}}":"{{GET_ORGANIZATION}}"}`;

    var jsonQuery, _ = <json>stringQuery;

    //Set headers and payload to the request
    constructRequest(request, jsonQuery, gitHubConnector.accessToken);

    // Make an HTTP POST request
    response, httpError = gitHubEndpoint -> post("", request);
    if (httpError != null) {
        connectorError = {message:[httpError.message], statusCode:httpError.statusCode};
        return null, connectorError;
    }
    json validatedResponse;
    validatedResponse, connectorError = getValidatedResponse(response, GIT_NAME);
    if (connectorError != null) {
        return null, connectorError;
    }
    try {
        var githubRepositoryJson, _ = (json)validatedResponse[GIT_DATA][GIT_ORGANIZATION];
        singleOrganization, _ = <Organization>githubRepositoryJson;
    } catch (error e) {
        connectorError = {message:[e.message]};
        return null, connectorError;
    }

    return singleOrganization, connectorError;
}