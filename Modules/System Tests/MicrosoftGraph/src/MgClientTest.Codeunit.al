// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Integration.Microsoft.Graph;

using System.Integration.Microsoft.Graph;
using System.RestClient;
using System.Utilities;
using System.TestLibraries.Utilities;

codeunit 135140 "Mg Client Test"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";


    [Test]
    procedure AuthTriggeredTest()
    var
        HttpResponseMessage: Codeunit "Http Response Message";
        MgAuthSpy: Codeunit "Mg Auth. Spy";
        MgClient: Codeunit "Mg Client";
        MockHttpClientHandler: Codeunit "Mock Http Client Handler";
        TempBlob: Codeunit "Temp Blob";
        ResponseInStream: InStream;
    begin
        MgClient.Initialize(Enum::"Mg API Version"::"v1.0", MgAuthSpy, MockHttpClientHandler);
        ResponseInStream := TempBlob.CreateInStream();

        // [WHEN] When Get Method is called  
        MgClient.Get('groups', HttpResponseMessage);

        // [THEN] Verify authorization of request is triggered
        LibraryAssert.AreEqual(true, MgAuthSpy.IsInvoked(), 'Authorization should be invoked.');
    end;

    [Test]
    procedure RequestUriTest()
    var
        HttpRequestMessage: Codeunit "Http Request Message";
        HttpResponseMessage: Codeunit "Http Response Message";
        MgAuthSpy: Codeunit "Mg Auth. Spy";
        MgClient: Codeunit "Mg Client";
        MockHttpClientHandler: Codeunit "Mock Http Client Handler";
        TempBlob: Codeunit "Temp Blob";
        ResponseInStream: InStream;
    begin
        MgClient.Initialize(Enum::"Mg API Version"::"v1.0", MgAuthSpy, MockHttpClientHandler);
        ResponseInStream := TempBlob.CreateInStream();

        // [WHEN] When Get Method is called  
        MgClient.Get('groups', HttpResponseMessage);

        // [THEN] Verify request uri is build correct
        MockHttpClientHandler.GetHttpRequestMessage(HttpRequestMessage);
        LibraryAssert.AreEqual(HttpRequestMessage.GetRequestUri(), 'https://graph.microsoft.com/v1.0/groups', 'Incorrect Request URI.');
    end;

    [Test]
    procedure ResponseBodyTest()
    var
        HttpContent: Codeunit "Http Content";
        MockHttpContent: Codeunit "Http Content";
        HttpResponseMessage: Codeunit "Http Response Message";
        MockHttpResponseMessage: Codeunit "Http Response Message";
        MgAuthSpy: Codeunit "Mg Auth. Spy";
        MgClient: Codeunit "Mg Client";
        MockHttpClientHandler: Codeunit "Mock Http Client Handler";
        TempBlob: Codeunit "Temp Blob";
        ResponseInStream: InStream;
        ResponseJsonObject: JsonObject;
        DisplayNameJsonToken: JsonToken;
    begin
        // [GIVEN] Mocked Response for groups
        MockHttpResponseMessage.SetHttpStatusCode(200);
        MockHttpContent := HttpContent.Create(GetGroupsResponse());
        MockHttpResponseMessage.SetContent(MockHttpContent);
        MockHttpClientHandler.SetResponse(MockHttpResponseMessage);
        MgClient.Initialize(Enum::"Mg API Version"::"v1.0", MgAuthSpy, MockHttpClientHandler);
        ResponseInStream := TempBlob.CreateInStream();

        // [WHEN] When Get Method is called  
        MgClient.Get('groups', HttpResponseMessage);

        // [THEN] Verify response is correct
        LibraryAssert.AreEqual(true, HttpResponseMessage.GetIsSuccessStatusCode(), 'Should be success status code.');
        HttpContent := HttpResponseMessage.GetContent();
        ResponseInStream := HttpContent.AsInStream();
        ResponseJsonObject.ReadFrom(ResponseInStream);
        ResponseJsonObject.SelectToken('$.value[:1].displayName', DisplayNameJsonToken);
        LibraryAssert.AreEqual('HR Taskforce (ÄÖÜßäöü)', DisplayNameJsonToken.AsValue().AsText(), 'Incorrect Displayname.');
    end;

    local procedure GetGroupsResponse(): Text
    var
        StringBuilder: TextBuilder;
    begin
        StringBuilder.Append('{');
        StringBuilder.Append('    "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#groups",');
        StringBuilder.Append('    "value": [');
        StringBuilder.Append('        {');
        StringBuilder.Append('            "id": "02bd9fd6-8f93-4758-87c3-1fb73740a315",');
        StringBuilder.Append('            "deletedDateTime": null,');
        StringBuilder.Append('            "classification": null,');
        StringBuilder.Append('            "createdDateTime": "2017-07-31T18:56:16Z",');
        StringBuilder.Append('            "creationOptions": [');
        StringBuilder.Append('                "ExchangeProvisioningFlags:481"');
        StringBuilder.Append('            ],');
        StringBuilder.Append('            "description": "Welcome to the HR Taskforce team.",');
        StringBuilder.Append('            "displayName": "HR Taskforce (ÄÖÜßäöü)",');
        StringBuilder.Append('            "expirationDateTime": null,');
        StringBuilder.Append('            "groupTypes": [');
        StringBuilder.Append('                "Unified"');
        StringBuilder.Append('            ],');
        StringBuilder.Append('            "isAssignableToRole": null,');
        StringBuilder.Append('            "mail": "HRTaskforce@M365x214355.onmicrosoft.com",');
        StringBuilder.Append('            "mailEnabled": true,');
        StringBuilder.Append('            "mailNickname": "HRTaskforce",');
        StringBuilder.Append('            "membershipRule": null,');
        StringBuilder.Append('            "membershipRuleProcessingState": null,');
        StringBuilder.Append('            "onPremisesDomainName": null,');
        StringBuilder.Append('            "onPremisesLastSyncDateTime": null,');
        StringBuilder.Append('            "onPremisesNetBiosName": null,');
        StringBuilder.Append('            "onPremisesSamAccountName": null,');
        StringBuilder.Append('            "onPremisesSecurityIdentifier": null,');
        StringBuilder.Append('            "onPremisesSyncEnabled": null,');
        StringBuilder.Append('            "preferredDataLocation": null,');
        StringBuilder.Append('            "preferredLanguage": null,');
        StringBuilder.Append('            "proxyAddresses": [],');
        StringBuilder.Append('            "renewedDateTime": "2023-01-31T00:00:00Z",');
        StringBuilder.Append('            "resourceBehaviorOptions": [],');
        StringBuilder.Append('            "resourceProvisioningOptions": [');
        StringBuilder.Append('                "Team"');
        StringBuilder.Append('            ],');
        StringBuilder.Append('            "securityEnabled": false,');
        StringBuilder.Append('            "securityIdentifier": "S-1-12-1-45981654-1196986259-3072312199-363020343",');
        StringBuilder.Append('            "theme": null,');
        StringBuilder.Append('            "visibility": "Private",');
        StringBuilder.Append('            "onPremisesProvisioningErrors": [],');
        StringBuilder.Append('            "serviceProvisioningErrors": []');
        StringBuilder.Append('        }');
        StringBuilder.Append('    ]');
        StringBuilder.Append('}');
        exit(StringBuilder.ToText());
    end;

}