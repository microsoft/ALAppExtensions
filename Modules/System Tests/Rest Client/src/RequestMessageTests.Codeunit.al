// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.RestClient;

using System.RestClient;
using System.TestLibraries.Utilities;

codeunit 134972 "Request Message Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure TestSetHttpMethod()
    var
        ALHttpRequestMessage: Codeunit "Http Request Message";
        HttpRequestMessage: HttpRequestMessage;
    begin
        // [SCENARIO] The request message is initialized with an empty content

        // [GIVEN] An initialized Http Request Message
        ALHttpRequestMessage.SetHttpMethod(Enum::"Http Method"::PATCH);

        // [WHEN] The request message is read
        HttpRequestMessage := ALHttpRequestMessage.GetHttpRequestMessage();

        // [THEN] The request message is initialized correctly
        Assert.AreEqual(HttpRequestMessage.Method(), 'PATCH', 'The request message method is not correct.');
    end;

    [Test]
    procedure TestRequestMessageWithoutContent()
    var
        ALHttpRequestMessage: Codeunit "Http Request Message";
        HttpRequestMessage: HttpRequestMessage;
    begin
        // [SCENARIO] The request message is initialized without content

        // [GIVEN] An initialized Http Request Message
        ALHttpRequestMessage.SetHttpMethod('GET');
        ALHttpRequestMessage.SetRequestUri('https://www.microsoft.com/');

        // [WHEN] The request message is read
        HttpRequestMessage := ALHttpRequestMessage.GetHttpRequestMessage();

        // [THEN] The request message is initialized correctly
        Assert.AreEqual(HttpRequestMessage.Method(), 'GET', 'The request message method is not correct.');
        Assert.AreEqual(HttpRequestMessage.GetRequestUri(), 'https://www.microsoft.com/', 'The request message request URI is not correct.');
    end;

    [Test]
    procedure TestRequestMessageWithTextContent()
    var
        ALHttpRequestMessage: Codeunit "Http Request Message";
        HttpContent: Codeunit "Http Content";
        HttpRequestMessage: HttpRequestMessage;
        ContentHeaders: HttpHeaders;
        ContentHeaderValues: List of [Text];
        ContentText: Text;
    begin
        // [GIVEN] An initialized Http Request Message
        ALHttpRequestMessage.SetHttpMethod('POST');
        ALHttpRequestMessage.SetRequestUri('https://www.microsoft.com/');

        // [GIVEN] The request message content is a text
        ALHttpRequestMessage.SetContent(HttpContent.Create('Hello World!'));

        // [WHEN] The request message is read
        HttpRequestMessage := ALHttpRequestMessage.GetHttpRequestMessage();

        // [THEN] The request message is initialized correctly
        Assert.AreEqual(HttpRequestMessage.Method(), 'POST', 'The request message method is not correct.');
        Assert.AreEqual(HttpRequestMessage.GetRequestUri(), 'https://www.microsoft.com/', 'The request message request URI is not correct.');

        HttpRequestMessage.Content().ReadAs(ContentText);
        Assert.AreEqual(ContentText, 'Hello World!', 'The request message content is not correct.');

        HttpRequestMessage.Content.GetHeaders(ContentHeaders);
        Assert.AreEqual(ContentHeaders.Contains('Content-Type'), true, 'The content type header is missing.');

        ContentHeaders.GetValues('Content-Type', ContentHeaderValues);
        Assert.AreEqual(ContentHeaderValues.Get(1), 'text/plain', 'The request message content type is not correct.');
    end;

    [Test]
    procedure TestRequestMessageWithJsonContent()
    var
        ALHttpRequestMessage: Codeunit "Http Request Message";
        HttpContent: Codeunit "Http Content";
        HttpRequestMessage: HttpRequestMessage;
        ContentHeaders: HttpHeaders;
        ContentHeaderValues: List of [Text];
        ContentJson: JsonObject;
        ContentText: Text;
    begin
        // [GIVEN] An initialized Http Request Message
        ALHttpRequestMessage.SetHttpMethod('POST');
        ALHttpRequestMessage.SetRequestUri('https://www.microsoft.com/');

        // [GIVEN] The request message content is a JSON object
        ContentJson.Add('value', 'Hello World!');
        ALHttpRequestMessage.SetContent(HttpContent.Create(ContentJson));

        // [WHEN] The request message is read
        HttpRequestMessage := ALHttpRequestMessage.GetHttpRequestMessage();

        // [THEN] The request message is initialized correctly
        Assert.AreEqual(HttpRequestMessage.Method(), 'POST', 'The request message method is not correct.');
        Assert.AreEqual(HttpRequestMessage.GetRequestUri(), 'https://www.microsoft.com/', 'The request message request URI is not correct.');

        HttpRequestMessage.Content().ReadAs(ContentText);
        Assert.AreEqual(ContentJson.ReadFrom(ContentText), true, 'The request message content is not a valid JSON object.');
        Assert.AreEqual(ContentJson.Contains('value'), true, 'The request message content does not contain the expected property "value".');
        Assert.AreEqual(GetJsonToken(ContentJson, 'value').AsValue().AsText(), 'Hello World!', 'The request message content property "value" is not correct.');

        HttpRequestMessage.Content.GetHeaders(ContentHeaders);
        Assert.AreEqual(ContentHeaders.Contains('Content-Type'), true, 'The content type header is missing.');

        ContentHeaders.GetValues('Content-Type', ContentHeaderValues);
        Assert.AreEqual(ContentHeaderValues.Get(1), 'application/json', 'The request message content type is not correct.');
    end;

    [Test]
    procedure TestAddRequestHeader()
    var
        ALHttpRequestMessage: Codeunit "Http Request Message";
        HttpRequestMessage: HttpRequestMessage;
        ContentHeaders: HttpHeaders;
        ContentHeaderValues: List of [Text];
    begin
        // [GIVEN] An initialized Http Request Message
        ALHttpRequestMessage.SetHttpMethod('GET');
        ALHttpRequestMessage.SetRequestUri('https://www.microsoft.com/');

        // [GIVEN] The request message has a custom header
        ALHttpRequestMessage.SetHeader('X-Custom-Header', 'My Request Header');

        // [WHEN] The request message is read
        HttpRequestMessage := ALHttpRequestMessage.GetHttpRequestMessage();

        // [THEN] The request message is initialized correctly
        HttpRequestMessage.GetHeaders(ContentHeaders);
        Assert.AreEqual(ContentHeaders.Contains('X-Custom-Header'), true, 'The custom header is missing.');

        ContentHeaders.GetValues('X-Custom-Header', ContentHeaderValues);
        Assert.AreEqual(ContentHeaderValues.Get(1), 'My Request Header', 'The custom header value is not correct.');
    end;

    local procedure GetJsonToken(JsonObject: JsonObject; Name: Text) JsonToken: JsonToken
    begin
        JsonObject.Get(Name, JsonToken);
    end;
}