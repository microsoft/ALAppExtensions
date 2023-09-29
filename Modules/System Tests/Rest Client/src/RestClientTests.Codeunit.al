// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.RestClient;

using System.RestClient;
using System.TestLibraries.Utilities;

codeunit 134971 "Rest Client Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        HttpClientHandler: Codeunit "Test Http Client Handler";

    [Test]
    procedure TestGet()
    var
        RestClient: Codeunit "Rest Client";
        HttpResponseMessage: Codeunit "Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test GET request

        // [GIVEN] An uninitialized Rest Client
        RestClient.Initialize(HttpClientHandler);

        // [WHEN] The Get method is called
        HttpResponseMessage := RestClient.Get('https://httpbin.org/get');

        // [THEN] The response contains the expected data
        Assert.AreEqual(HttpResponseMessage.GetHttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(HttpResponseMessage.GetIsSuccessStatusCode(), 'GetIsSuccessStatusCode should be true');
        JsonObject := HttpResponseMessage.GetContent().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/get', 'The response should contain the expected url');
    end;

    [Test]
    procedure TestPost()
    var
        RestClient: Codeunit "Rest Client";
        HttpGetContent: Codeunit "Http Content";
        HttpResponseMessage: Codeunit "Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test POST request

        // [GIVEN] An uninitialized Rest Client
        RestClient.Initialize(HttpClientHandler);

        // [WHEN] The Post method is called
        HttpResponseMessage := RestClient.Post('https://httpbin.org/post', HttpGetContent.Create('Hello World'));

        // [THEN] The response contains the expected data
        Assert.AreEqual(HttpResponseMessage.GetHttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(HttpResponseMessage.GetIsSuccessStatusCode(), 'GetIsSuccessStatusCode should be true');
        JsonObject := HttpResponseMessage.GetContent().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/post', 'The response should contain the expected url');
        Assert.AreEqual(GetJsonToken(JsonObject, 'data').AsValue().AsText(), 'Hello World', 'The response should contain the expected data');
    end;

    [Test]
    procedure TestPatch()
    var
        RestClient: Codeunit "Rest Client";
        HttpGetContent: Codeunit "Http Content";
        HttpResponseMessage: Codeunit "Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test PATCH request

        // [GIVEN] An uninitialized Rest Client
        RestClient.Initialize(HttpClientHandler);

        // [WHEN] The Patch method is called
        HttpResponseMessage := RestClient.Patch('https://httpbin.org/patch', HttpGetContent.Create('Hello World'));

        // [THEN] The response contains the expected data
        Assert.AreEqual(HttpResponseMessage.GetHttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(HttpResponseMessage.GetIsSuccessStatusCode(), 'GetIsSuccessStatusCode should be true');
        JsonObject := HttpResponseMessage.GetContent().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/patch', 'The response should contain the expected url');
        Assert.AreEqual(GetJsonToken(JsonObject, 'data').AsValue().AsText(), 'Hello World', 'The response should contain the expected data');
    end;

    [Test]
    procedure TestPut()
    var
        RestClient: Codeunit "Rest Client";
        HttpGetContent: Codeunit "Http Content";
        HttpResponseMessage: Codeunit "Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test PUT request

        // [GIVEN] An uninitialized Rest Client
        RestClient.Initialize(HttpClientHandler);

        // [WHEN] The Put method is called
        HttpResponseMessage := RestClient.Put('https://httpbin.org/put', HttpGetContent.Create('Hello World'));

        // [THEN] The response contains the expected data
        Assert.AreEqual(HttpResponseMessage.GetHttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(HttpResponseMessage.GetIsSuccessStatusCode(), 'GetIsSuccessStatusCode should be true');
        JsonObject := HttpResponseMessage.GetContent().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/put', 'The response should contain the expected url');
        Assert.AreEqual(GetJsonToken(JsonObject, 'data').AsValue().AsText(), 'Hello World', 'The response should contain the expected data');
    end;

    [Test]
    procedure TestDelete()
    var
        RestClient: Codeunit "Rest Client";
        HttpResponseMessage: Codeunit "Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test DELETE request

        // [GIVEN] An uninitialized Rest Client
        RestClient.Initialize(HttpClientHandler);

        // [WHEN] The Delete method is called
        HttpResponseMessage := RestClient.Delete('https://httpbin.org/delete');

        // [THEN] The response contains the expected data
        Assert.AreEqual(HttpResponseMessage.GetHttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(HttpResponseMessage.GetIsSuccessStatusCode(), 'GetIsSuccessStatusCode should be true');
        JsonObject := HttpResponseMessage.GetContent().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/delete', 'The response should contain the expected url');
    end;

    [Test]
    procedure TestGetWithDefaultHeaders()
    var
        RestClient: Codeunit "Rest Client";
        HttpResponseMessage: Codeunit "Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test GET request with headers

        // [GIVEN] An initialized Rest Client with default request headers
        RestClient.Initialize(HttpClientHandler);
        RestClient.SetDefaultRequestHeader('X-Test-Header', 'Test');

        // [WHEN] The Get method is called with headers
        HttpResponseMessage := RestClient.Get('https://httpbin.org/get');

        // [THEN] The response contains the expected data
        Assert.AreEqual(HttpResponseMessage.GetHttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(HttpResponseMessage.GetIsSuccessStatusCode(), 'GetIsSuccessStatusCode should be true');
        JsonObject := HttpResponseMessage.GetContent().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/get', 'The response should contain the expected url');
        Assert.AreEqual(SelectJsonToken('$.headers.X-Test-Header', JsonObject).AsValue().AsText(), 'Test', 'The response should contain the expected header');
    end;

    [Test]
    procedure TestBaseAddress()
    var
        RestClient: Codeunit "Rest Client";
        HttpResponseMessage: Codeunit "Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test GET request with base address

        // [GIVEN] An initialized Rest Client with base address
        RestClient.Initialize(HttpClientHandler);
        RestClient.SetBaseAddress('https://httpbin.org');

        // [WHEN] The Get method is called with relative url
        HttpResponseMessage := RestClient.Get('/get');

        // [THEN] The response contains the expected data
        Assert.AreEqual(HttpResponseMessage.GetHttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(HttpResponseMessage.GetIsSuccessStatusCode(), 'GetIsSuccessStatusCode should be true');
        JsonObject := HttpResponseMessage.GetContent().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/get', 'The response should contain the expected url');
    end;

    [Test]
    procedure TestDefaultUserAgentHeader()
    var
        RestClient: Codeunit "Rest Client";
        HttpResponseMessage: Codeunit "Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test GET request with default User-Agent header

        // [GIVEN] An uninitialized Rest Client 
        RestClient.Initialize(HttpClientHandler);

        // [WHEN] The Get method is called using the default User-Agent header
        HttpResponseMessage := RestClient.Get('https://httpbin.org/get');

        // [THEN] The response contains the expected data
        Assert.AreEqual(HttpResponseMessage.GetHttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(HttpResponseMessage.GetIsSuccessStatusCode(), 'GetIsSuccessStatusCode should be true');
        JsonObject := HttpResponseMessage.GetContent().AsJson().AsObject();
        Assert.IsTrue(SelectJsonToken('$.headers.User-Agent', JsonObject).AsValue().AsText().StartsWith('Dynamics 365 Business Central '), 'The response should contain a User-Agent header');
    end;

    [Test]
    procedure TestCustomUserAgentHeader()
    var
        RestClient: Codeunit "Rest Client";
        HttpResponseMessage: Codeunit "Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test GET request with custom User-Agent header

        // [GIVEN] An initialized Rest Client with a customer User-Agent header
        RestClient.Initialize(HttpClientHandler);
        RestClient.SetUserAgentHeader('BC Rest Client Test');

        // [WHEN] The Get method is called using a custom User-Agent header
        HttpResponseMessage := RestClient.Get('https://httpbin.org/get');

        // [THEN] The response contains the expected data
        Assert.AreEqual(HttpResponseMessage.GetHttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(HttpResponseMessage.GetIsSuccessStatusCode(), 'GetIsSuccessStatusCode should be true');
        JsonObject := HttpResponseMessage.GetContent().AsJson().AsObject();
        Assert.AreEqual(SelectJsonToken('$.headers.User-Agent', JsonObject).AsValue().AsText(), 'BC Rest Client Test', 'The response should contain the expected User-Agent header');
    end;

    [Test]
    procedure TestGetAsJson()
    var
        RestClient: Codeunit "Rest Client";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test GET request with JSON response

        // [GIVEN] An uninitialized Rest Client
        RestClient.Initialize(HttpClientHandler);

        // [WHEN] The GetAsJson method is called
        JsonObject := RestClient.GetAsJson('https://httpbin.org/get').AsObject();

        // [THEN] The response contains the expected data
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/get', 'The response should contain the expected url');
    end;

    [Test]
    procedure TestPostAsJson()
    var
        RestClient: Codeunit "Rest Client";
        HttpGetContent: Codeunit "Http Content";
        JsonObject1: JsonObject;
        JsonObject2: JsonObject;
    begin
        // [SCENARIO] Test POST request with JSON request and response

        // [GIVEN] An uninitialized Rest Client
        RestClient.Initialize(HttpClientHandler);

        // [GIVEN] A Json object
        JsonObject1.Add('name', 'John');
        JsonObject1.Add('age', 30);

        // [WHEN] The PostAsJson method is called with a Json object
        HttpGetContent := HttpGetContent.Create(JsonObject1);
        JsonObject2 := RestClient.PostAsJson('https://httpbin.org/post', JsonObject1).AsObject();

        // [THEN] The response contains the expected data
        Assert.AreEqual(GetJsonToken(JsonObject2, 'url').AsValue().AsText(), 'https://httpbin.org/post', 'The response should contain the expected url');
        JsonObject2.ReadFrom(GetJsonToken(JsonObject2, 'data').AsValue().AsText());
        Assert.AreEqual(GetJsonToken(JsonObject2, 'name').AsValue().AsText(), 'John', 'The response should contain the expected data');
        Assert.AreEqual(GetJsonToken(JsonObject2, 'age').AsValue().AsInteger(), 30, 'The response should contain the expected data');
    end;

    [Test]
    procedure TestPatchAsJson()
    var
        RestClient: Codeunit "Rest Client";
        HttpGetContent: Codeunit "Http Content";
        JsonObject1: JsonObject;
        JsonObject2: JsonObject;
    begin
        // [SCENARIO] Test PATCH request with JSON request and response

        // [GIVEN] An uninitialized Rest Client
        RestClient.Initialize(HttpClientHandler);

        // [GIVEN] A Json object
        JsonObject1.Add('name', 'John');
        JsonObject1.Add('age', 30);

        // [WHEN] The PatchAsJson method is called with a Json object
        HttpGetContent := HttpGetContent.Create(JsonObject1);
        JsonObject2 := RestClient.PatchAsJson('https://httpbin.org/patch', JsonObject1).AsObject();

        // [THEN] The response contains the expected data
        Assert.AreEqual(GetJsonToken(JsonObject2, 'url').AsValue().AsText(), 'https://httpbin.org/patch', 'The response should contain the expected url');
        JsonObject2.ReadFrom(GetJsonToken(JsonObject2, 'data').AsValue().AsText());
        Assert.AreEqual(GetJsonToken(JsonObject2, 'name').AsValue().AsText(), 'John', 'The response should contain the expected data');
        Assert.AreEqual(GetJsonToken(JsonObject2, 'age').AsValue().AsInteger(), 30, 'The response should contain the expected data');
    end;

    [Test]
    procedure TestPutAsJson()
    var
        RestClient: Codeunit "Rest Client";
        HttpGetContent: Codeunit "Http Content";
        JsonObject1: JsonObject;
        JsonObject2: JsonObject;
    begin
        // [SCENARIO] Test PUT request with JSON request and response

        // [GIVEN] An uninitialized Rest Client
        RestClient.Initialize(HttpClientHandler);

        // [GIVEN] A Json object
        JsonObject1.Add('name', 'John');
        JsonObject1.Add('age', 30);

        // [WHEN] The PutAsJson method is called with a Json object
        HttpGetContent := HttpGetContent.Create(JsonObject1);
        JsonObject2 := RestClient.PutAsJson('https://httpbin.org/put', JsonObject1).AsObject();

        // [THEN] The response contains the expected data
        Assert.AreEqual(GetJsonToken(JsonObject2, 'url').AsValue().AsText(), 'https://httpbin.org/put', 'The response should contain the expected url');
        JsonObject2.ReadFrom(GetJsonToken(JsonObject2, 'data').AsValue().AsText());
        Assert.AreEqual(GetJsonToken(JsonObject2, 'name').AsValue().AsText(), 'John', 'The response should contain the expected data');
        Assert.AreEqual(GetJsonToken(JsonObject2, 'age').AsValue().AsInteger(), 30, 'The response should contain the expected data');
    end;

    [Test]
    procedure TestSendWithoutGetContent()
    var
        RestClient: Codeunit "Rest Client";
        HttpResponseMessage: Codeunit "Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test Send method without Getcontent

        // [GIVEN] An uninitialized Rest Client
        RestClient.Initialize(HttpClientHandler);

        // [WHEN] The Send method is called without Getcontent
        HttpResponseMessage := RestClient.Send(Enum::"Http Method"::GET, 'https://httpbin.org/get');

        // [THEN] The response contains the expected data
        Assert.AreEqual(HttpResponseMessage.GetHttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(HttpResponseMessage.GetIsSuccessStatusCode(), 'GetIsSuccessStatusCode should be true');
        JsonObject := HttpResponseMessage.GetContent().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/get', 'The response should contain the expected url');
    end;

    [Test]
    procedure TestSendWithGetContent()
    var
        RestClient: Codeunit "Rest Client";
        HttpContent: Codeunit "Http Content";
        HttpResponseMessage: Codeunit "Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test Send method with Getcontent

        // [GIVEN] An uninitialized Rest Client
        RestClient.Initialize(HttpClientHandler);

        // [WHEN] The Send method is called with Getcontent
        HttpResponseMessage := RestClient.Send(Enum::"Http Method"::POST, 'https://httpbin.org/post', HttpContent.Create('Hello World'));

        // [THEN] The response contains the expected data
        Assert.AreEqual(HttpResponseMessage.GetHttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(HttpResponseMessage.GetIsSuccessStatusCode(), 'GetIsSuccessStatusCode should be true');
        JsonObject := HttpResponseMessage.GetContent().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/post', 'The response should contain the expected url');
        Assert.AreEqual(GetJsonToken(JsonObject, 'data').AsValue().AsText(), 'Hello World', 'The response should contain the expected data');
    end;

    [Test]
    procedure TestSendRequestMessage()
    var
        RestClient: Codeunit "Rest Client";
        ALHttpRequestMessage: Codeunit "Http Request Message";
        HttpResponseMessage: Codeunit "Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test Send method with request message

        // [GIVEN] An uninitialized Rest Client
        RestClient.Initialize(HttpClientHandler);

        // [WHEN] The Send method is called with a request message
        ALHttpRequestMessage.SetHttpMethod(Enum::"Http Method"::GET);
        ALHttpRequestMessage.SetRequestUri('https://httpbin.org/get');
        HttpResponseMessage := RestClient.Send(ALHttpRequestMessage);

        // [THEN] The response contains the expected data
        Assert.AreEqual(HttpResponseMessage.GetHttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(HttpResponseMessage.GetIsSuccessStatusCode(), 'GetIsSuccessStatusCode should be true');
        JsonObject := HttpResponseMessage.GetContent().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/get', 'The response should contain the expected url');
    end;

    [Test]
    procedure TestBasicAuthentication()
    var
        RestClient: Codeunit "Rest Client";
        HttpAuthenticationBasic: Codeunit "Http Authentication Basic";
        HttpResponseMessage: Codeunit "Http Response Message";
        JsonObject: JsonObject;
        PasswordText: Text;
    begin
        // [SCENARIO] Test Http Get with Basic Authentication

        // [GIVEN] An initialized Rest Client with Basic Authentication
        PasswordText := 'Password123';
        HttpAuthenticationBasic.Initialize('user01', PasswordText);
        RestClient.Initialize(HttpClientHandler, HttpAuthenticationBasic);

        // [WHEN] The Get method is called
        HttpResponseMessage := RestClient.Get('https://httpbin.org/basic-auth/user01/Password123');

        // [THEN] The response contains the expected data
        Assert.AreEqual(HttpResponseMessage.GetHttpStatusCode(), 200, 'The response status code should be 200');
        JsonObject := HttpResponseMessage.GetContent().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'authenticated').AsValue().AsBoolean(), true, 'The response should contain the expected data');
    end;

    local procedure GetJsonToken(JsonObject: JsonObject; Name: Text) JsonToken: JsonToken
    begin
        JsonObject.Get(Name, JsonToken);
    end;

    local procedure SelectJsonToken(Path: Text; JsonObject: JsonObject) JsonToken: JsonToken
    begin
        JsonObject.SelectToken(Path, JsonToken);
    end;
}