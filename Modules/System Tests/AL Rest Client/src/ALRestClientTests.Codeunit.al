codeunit 50403 "AL Rest Client Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure TestGet()
    var
        ALRestClient: Codeunit "AL Rest Client";
        ALHttpResponseMessage: Codeunit "AL Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test GET request

        // [GIVEN] An uninitialized AL Rest Client
        // [WHEN] The Get method is called
        ALHttpResponseMessage := ALRestClient.Get('https://httpbin.org/get');

        // [THEN] The response contains the expected data
        Assert.AreEqual(ALHttpResponseMessage.HttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(ALHttpResponseMessage.IsSuccessStatusCode(), 'IsSuccessStatusCode should be true');
        JsonObject := ALHttpResponseMessage.Content().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/get', 'The response should contain the expected url');
    end;

    [Test]
    procedure TestPost()
    var
        ALRestClient: Codeunit "AL Rest Client";
        ALHttpContent: Codeunit "AL Http Content";
        ALHttpResponseMessage: Codeunit "AL Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test POST request

        // [GIVEN] An uninitialized AL Rest Client
        // [WHEN] The Post method is called
        ALHttpResponseMessage := ALRestClient.Post('https://httpbin.org/post', ALHttpContent.Create('Hello World'));

        // [THEN] The response contains the expected data
        Assert.AreEqual(ALHttpResponseMessage.HttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(ALHttpResponseMessage.IsSuccessStatusCode(), 'IsSuccessStatusCode should be true');
        JsonObject := ALHttpResponseMessage.Content().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/post', 'The response should contain the expected url');
        Assert.AreEqual(GetJsonToken(JsonObject, 'data').AsValue().AsText(), 'Hello World', 'The response should contain the expected data');
    end;

    [Test]
    procedure TestPatch()
    var
        ALRestClient: Codeunit "AL Rest Client";
        ALHttpContent: Codeunit "AL Http Content";
        ALHttpResponseMessage: Codeunit "AL Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test PATCH request

        // [GIVEN] An uninitialized AL Rest Client
        // [WHEN] The Patch method is called
        ALHttpResponseMessage := ALRestClient.Patch('https://httpbin.org/patch', ALHttpContent.Create('Hello World'));

        // [THEN] The response contains the expected data
        Assert.AreEqual(ALHttpResponseMessage.HttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(ALHttpResponseMessage.IsSuccessStatusCode(), 'IsSuccessStatusCode should be true');
        JsonObject := ALHttpResponseMessage.Content().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/patch', 'The response should contain the expected url');
        Assert.AreEqual(GetJsonToken(JsonObject, 'data').AsValue().AsText(), 'Hello World', 'The response should contain the expected data');
    end;

    [Test]
    procedure TestPut()
    var
        ALRestClient: Codeunit "AL Rest Client";
        ALHttpContent: Codeunit "AL Http Content";
        ALHttpResponseMessage: Codeunit "AL Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test PUT request

        // [GIVEN] An uninitialized AL Rest Client
        // [WHEN] The Put method is called
        ALHttpResponseMessage := ALRestClient.Put('https://httpbin.org/put', ALHttpContent.Create('Hello World'));

        // [THEN] The response contains the expected data
        Assert.AreEqual(ALHttpResponseMessage.HttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(ALHttpResponseMessage.IsSuccessStatusCode(), 'IsSuccessStatusCode should be true');
        JsonObject := ALHttpResponseMessage.Content().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/put', 'The response should contain the expected url');
        Assert.AreEqual(GetJsonToken(JsonObject, 'data').AsValue().AsText(), 'Hello World', 'The response should contain the expected data');
    end;

    [Test]
    procedure TestDelete()
    var
        ALRestClient: Codeunit "AL Rest Client";
        ALHttpResponseMessage: Codeunit "AL Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test DELETE request

        // [GIVEN] An uninitialized AL Rest Client
        // [WHEN] The Delete method is called
        ALHttpResponseMessage := ALRestClient.Delete('https://httpbin.org/delete');

        // [THEN] The response contains the expected data
        Assert.AreEqual(ALHttpResponseMessage.HttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(ALHttpResponseMessage.IsSuccessStatusCode(), 'IsSuccessStatusCode should be true');
        JsonObject := ALHttpResponseMessage.Content().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/delete', 'The response should contain the expected url');
    end;

    [Test]
    procedure TestGetWithDefaultHeaders()
    var
        ALRestClient: Codeunit "AL Rest Client";
        ALHttpResponseMessage: Codeunit "AL Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test GET request with headers

        // [GIVEN] An initialized AL Rest Client with default request headers
        ALRestClient.SetDefaultRequestHeader('X-Test-Header', 'Test');

        // [WHEN] The Get method is called with headers
        ALHttpResponseMessage := ALRestClient.Get('https://httpbin.org/get');

        // [THEN] The response contains the expected data
        Assert.AreEqual(ALHttpResponseMessage.HttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(ALHttpResponseMessage.IsSuccessStatusCode(), 'IsSuccessStatusCode should be true');
        JsonObject := ALHttpResponseMessage.Content().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/get', 'The response should contain the expected url');
        Assert.AreEqual(SelectJsonToken('$.headers.X-Test-Header', JsonObject).AsValue().AsText(), 'Test', 'The response should contain the expected header');
    end;

    [Test]
    procedure TestBaseAddress()
    var
        ALRestClient: Codeunit "AL Rest Client";
        ALHttpResponseMessage: Codeunit "AL Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test GET request with base address

        // [GIVEN] An initialized AL Rest Client with base address
        ALRestClient.SetBaseAddress('https://httpbin.org');

        // [WHEN] The Get method is called with relative url
        ALHttpResponseMessage := ALRestClient.Get('/get');

        // [THEN] The response contains the expected data
        Assert.AreEqual(ALHttpResponseMessage.HttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(ALHttpResponseMessage.IsSuccessStatusCode(), 'IsSuccessStatusCode should be true');
        JsonObject := ALHttpResponseMessage.Content().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/get', 'The response should contain the expected url');
    end;

    [Test]
    procedure TestDefaultUserAgentHeader()
    var
        ALRestClient: Codeunit "AL Rest Client";
        ALHttpResponseMessage: Codeunit "AL Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test GET request with default User-Agent header

        // [GIVEN] An uninitialized AL Rest Client 
        // [WHEN] The Get method is called using the default User-Agent header
        ALHttpResponseMessage := ALRestClient.Get('https://httpbin.org/get');

        // [THEN] The response contains the expected data
        Assert.AreEqual(ALHttpResponseMessage.HttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(ALHttpResponseMessage.IsSuccessStatusCode(), 'IsSuccessStatusCode should be true');
        JsonObject := ALHttpResponseMessage.Content().AsJson().AsObject();
        Assert.IsTrue(SelectJsonToken('$.headers.User-Agent', JsonObject).AsValue().AsText().StartsWith('Dynamics 365 Business Central '), 'The response should contain a User-Agent header');
    end;

    [Test]
    procedure TestCustomUserAgentHeader()
    var
        ALRestClient: Codeunit "AL Rest Client";
        ALHttpResponseMessage: Codeunit "AL Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test GET request with custom User-Agent header

        // [GIVEN] An initialized AL Rest Client with a customer User-Agent header
        ALRestClient.SetUserAgentHeader('AL Rest Client Test');

        // [WHEN] The Get method is called using a custom User-Agent header
        ALHttpResponseMessage := ALRestClient.Get('https://httpbin.org/get');

        // [THEN] The response contains the expected data
        Assert.AreEqual(ALHttpResponseMessage.HttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(ALHttpResponseMessage.IsSuccessStatusCode(), 'IsSuccessStatusCode should be true');
        JsonObject := ALHttpResponseMessage.Content().AsJson().AsObject();
        Assert.AreEqual(SelectJsonToken('$.headers.User-Agent', JsonObject).AsValue().AsText(), 'AL Rest Client Test', 'The response should contain the expected User-Agent header');
    end;

    [Test]
    procedure TestGetAsJson()
    var
        ALRestClient: Codeunit "AL Rest Client";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test GET request with JSON response

        // [GIVEN] An uninitialized AL Rest Client
        // [WHEN] The GetAsJson method is called
        JsonObject := ALRestClient.GetAsJson('https://httpbin.org/get').AsObject();

        // [THEN] The response contains the expected data
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/get', 'The response should contain the expected url');
    end;

    [Test]
    procedure TestPostAsJson()
    var
        ALRestClient: Codeunit "AL Rest Client";
        ALHttpContent: Codeunit "AL Http Content";
        ALHttpResponseMessage: Codeunit "AL Http Response Message";
        JsonObject1: JsonObject;
        JsonObject2: JsonObject;
    begin
        // [SCENARIO] Test POST request with JSON request and response

        // [GIVEN] An uninitialized AL Rest Client
        // [GIVEN] A Json object
        JsonObject1.Add('name', 'John');
        JsonObject1.Add('age', 30);

        // [WHEN] The PostAsJson method is called with a Json object
        ALHttpContent := ALHttpContent.Create(JsonObject1);
        JsonObject2 := ALRestClient.PostAsJson('https://httpbin.org/post', JsonObject1).AsObject();

        // [THEN] The response contains the expected data
        Assert.AreEqual(GetJsonToken(JsonObject2, 'url').AsValue().AsText(), 'https://httpbin.org/post', 'The response should contain the expected url');
        JsonObject2.ReadFrom(GetJsonToken(JsonObject2, 'data').AsValue().AsText());
        Assert.AreEqual(GetJsonToken(JsonObject2, 'name').AsValue().AsText(), 'John', 'The response should contain the expected data');
        Assert.AreEqual(GetJsonToken(JsonObject2, 'age').AsValue().AsInteger(), 30, 'The response should contain the expected data');
    end;

    [Test]
    procedure TestPatchAsJson()
    var
        ALRestClient: Codeunit "AL Rest Client";
        ALHttpContent: Codeunit "AL Http Content";
        ALHttpResponseMessage: Codeunit "AL Http Response Message";
        JsonObject1: JsonObject;
        JsonObject2: JsonObject;
    begin
        // [SCENARIO] Test PATCH request with JSON request and response

        // [GIVEN] An uninitialized AL Rest Client
        // [GIVEN] A Json object
        JsonObject1.Add('name', 'John');
        JsonObject1.Add('age', 30);

        // [WHEN] The PatchAsJson method is called with a Json object
        ALHttpContent := ALHttpContent.Create(JsonObject1);
        JsonObject2 := ALRestClient.PatchAsJson('https://httpbin.org/patch', JsonObject1).AsObject();

        // [THEN] The response contains the expected data
        Assert.AreEqual(GetJsonToken(JsonObject2, 'url').AsValue().AsText(), 'https://httpbin.org/patch', 'The response should contain the expected url');
        JsonObject2.ReadFrom(GetJsonToken(JsonObject2, 'data').AsValue().AsText());
        Assert.AreEqual(GetJsonToken(JsonObject2, 'name').AsValue().AsText(), 'John', 'The response should contain the expected data');
        Assert.AreEqual(GetJsonToken(JsonObject2, 'age').AsValue().AsInteger(), 30, 'The response should contain the expected data');
    end;

    [Test]
    procedure TestPutAsJson()
    var
        ALRestClient: Codeunit "AL Rest Client";
        ALHttpContent: Codeunit "AL Http Content";
        ALHttpResponseMessage: Codeunit "AL Http Response Message";
        JsonObject1: JsonObject;
        JsonObject2: JsonObject;
    begin
        // [SCENARIO] Test PUT request with JSON request and response

        // [GIVEN] An uninitialized AL Rest Client
        // [GIVEN] A Json object
        JsonObject1.Add('name', 'John');
        JsonObject1.Add('age', 30);

        // [WHEN] The PutAsJson method is called with a Json object
        ALHttpContent := ALHttpContent.Create(JsonObject1);
        JsonObject2 := ALRestClient.PutAsJson('https://httpbin.org/put', JsonObject1).AsObject();

        // [THEN] The response contains the expected data
        Assert.AreEqual(GetJsonToken(JsonObject2, 'url').AsValue().AsText(), 'https://httpbin.org/put', 'The response should contain the expected url');
        JsonObject2.ReadFrom(GetJsonToken(JsonObject2, 'data').AsValue().AsText());
        Assert.AreEqual(GetJsonToken(JsonObject2, 'name').AsValue().AsText(), 'John', 'The response should contain the expected data');
        Assert.AreEqual(GetJsonToken(JsonObject2, 'age').AsValue().AsInteger(), 30, 'The response should contain the expected data');
    end;

    [Test]
    procedure TestSendWithoutContent()
    var
        ALRestClient: Codeunit "AL Rest Client";
        ALHttpResponseMessage: Codeunit "AL Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test Send method without content

        // [GIVEN] An uninitialized AL Rest Client
        // [WHEN] The Send method is called without content
        ALHttpResponseMessage := ALRestClient.Send(Enum::"Http Request Type"::GET, 'https://httpbin.org/get');

        // [THEN] The response contains the expected data
        Assert.AreEqual(ALHttpResponseMessage.HttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(ALHttpResponseMessage.IsSuccessStatusCode(), 'IsSuccessStatusCode should be true');
        JsonObject := ALHttpResponseMessage.Content().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/get', 'The response should contain the expected url');
    end;

    [Test]
    procedure TestSendWithContent()
    var
        ALRestClient: Codeunit "AL Rest Client";
        ALHttpResponseMessage: Codeunit "AL Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test Send method with content

        // [GIVEN] An uninitialized AL Rest Client
        // [WHEN] The Send method is called with content
        ALHttpResponseMessage := ALRestClient.Send(Enum::"Http Request Type"::POST, 'https://httpbin.org/post', 'Hello World');

        // [THEN] The response contains the expected data
        Assert.AreEqual(ALHttpResponseMessage.HttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(ALHttpResponseMessage.IsSuccessStatusCode(), 'IsSuccessStatusCode should be true');
        JsonObject := ALHttpResponseMessage.Content().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/post', 'The response should contain the expected url');
        Assert.AreEqual(GetJsonToken(JsonObject, 'data').AsValue().AsText(), 'Hello World', 'The response should contain the expected data');
    end;

    [Test]
    procedure TestSendRequestMessage()
    var
        ALRestClient: Codeunit "AL Rest Client";
        ALHttpRequestMessage: Codeunit "AL Http Request Message";
        ALHttpResponseMessage: Codeunit "AL Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test Send method with request message

        // [GIVEN] An uninitialized AL Rest Client
        // [WHEN] The Send method is called with a request message
        ALHttpRequestMessage.Initialize();
        ALHttpRequestMessage.SetHttpMethod(Enum::"Http Request Type"::GET);
        ALHttpRequestMessage.SetRequestUri('https://httpbin.org/get');
        ALHttpResponseMessage := ALRestClient.Send(ALHttpRequestMessage);

        // [THEN] The response contains the expected data
        Assert.AreEqual(ALHttpResponseMessage.HttpStatusCode(), 200, 'The response status code should be 200');
        Assert.IsTrue(ALHttpResponseMessage.IsSuccessStatusCode(), 'IsSuccessStatusCode should be true');
        JsonObject := ALHttpResponseMessage.Content().AsJson().AsObject();
        Assert.AreEqual(GetJsonToken(JsonObject, 'url').AsValue().AsText(), 'https://httpbin.org/get', 'The response should contain the expected url');
    end;

    [Test]
    procedure TestBasicAuthentication()
    var
        ALRestClient: Codeunit "AL Rest Client";
        HttpAuthenticationBasic: Codeunit "Http Authentication Basic";
        ALHttpResponseMessage: Codeunit "AL Http Response Message";
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Test Http Get with Basic Authentication

        // [GIVEN] An initialized AL Rest Client with Basic Authentication
        HttpAuthenticationBasic.Initialize('user01', 'Password123');
        ALRestClient.Initialize(HttpAuthenticationBasic);

        // [WHEN] The Get method is called
        ALHttpResponseMessage := ALRestClient.Get('https://httpbin.org/basic-auth/user01/Password123');

        // [THEN] The response contains the expected data
        Assert.AreEqual(ALHttpResponseMessage.HttpStatusCode(), 200, 'The response status code should be 200');
        JsonObject := ALHttpResponseMessage.Content().AsJson().AsObject();
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