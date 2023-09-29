// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.RestClient;

using System.RestClient;
using System.TestLibraries.Utilities;
using System.Utilities;

codeunit 134970 "Http Content Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure TestCreateWithText()
    var
        ALHttpContent: Codeunit "Http Content";
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HeaderValues: List of [Text];
        TextContent: Text;
    begin
        // [SCENARIO] Create AL Http Content object with text

        // [GIVEN] AL Http Content created with text
        ALHttpContent := ALHttpContent.Create('Hello World');

        // [WHEN] Content is retrieved as Text
        TextContent := ALHttpContent.AsText();

        // [THEN] Content is equal to Hello World
        Assert.AreEqual('Hello World', TextContent, 'The content must be equal to Hello World');

        // [THEN] Header Content-Type is text/plain
        HttpContent := ALHttpContent.GetHttpContent();
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.GetValues('Content-Type', HeaderValues);
        Assert.AreEqual('text/plain', HeaderValues.Get(1), 'The Content-Type header must be text/plain');
    end;

    [Test]
    procedure TestCreateWithTextAndContentType()
    var
        ALHttpContent: Codeunit "Http Content";
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HeaderValues: List of [Text];
        TextContent: Text;
    begin
        // [SCENARIO] Create AL Http Content object with text and content type

        // [GIVEN] AL Http Content created with text and content type
        ALHttpContent := ALHttpContent.Create('<html>Hello World</html>', 'text/html');

        // [WHEN] Content is retrieved as Text
        TextContent := ALHttpContent.AsText();

        // [THEN] Content is equal to Hello World
        Assert.AreEqual('<html>Hello World</html>', TextContent, 'The content must be equal to <html>Hello World</html>');

        // [THEN] Header Content-Type is text/html
        HttpContent := ALHttpContent.GetHttpContent();
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.GetValues('Content-Type', HeaderValues);
        Assert.AreEqual('text/html', HeaderValues.Get(1), 'The Content-Type header must be text/html');
    end;

    [Test]
    procedure TestCreateWithJsonObject()
    var
        ALHttpContent: Codeunit "Http Content";
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HeaderValues: List of [Text];
        JsonObject1: JsonObject;
        JsonObject2: JsonObject;
        JsonText1: Text;
        JsonText2: Text;
    begin
        // [SCENARIO] Create AL Http Content object with json object

        // [GIVEN] AL Http Content created with json object
        JsonObject1.Add('name', 'John');
        JsonObject1.Add('age', 30);
        ALHttpContent := ALHttpContent.Create(JsonObject1);

        // [WHEN] Http Content is retrieved as JsonObject
        JsonObject2 := ALHttpContent.AsJson().AsObject();

        // [THEN] JsonObject is equal to JsonObject2
        JsonObject1.WriteTo(JsonText1);
        JsonObject2.WriteTo(JsonText2);
        Assert.AreEqual(JsonText1, JsonText2, 'The json objects must be equal');

        // [THEN] Header Content-Type is application/json
        HttpContent := ALHttpContent.GetHttpContent();
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.GetValues('Content-Type', HeaderValues);
        Assert.AreEqual('application/json', HeaderValues.Get(1), 'The Content-Type header must be application/json');
    end;

    [Test]
    procedure TestCreateWithJsonArray()
    var
        ALHttpContent: Codeunit "Http Content";
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HeaderValues: List of [Text];
        JsonArray1: JsonArray;
        JsonArray2: JsonArray;
        JsonText1: Text;
        JsonText2: Text;
    begin
        // [SCENARIO] Create AL Http Content object with json array

        // [GIVEN] AL Http Content created with json array
        JsonArray1.Add('John');
        JsonArray1.Add('Doe');
        ALHttpContent := ALHttpContent.Create(JsonArray1);

        // [WHEN] Http Content is retrieved as JsonArray
        JsonArray2 := ALHttpContent.AsJson().AsArray();

        // [THEN] JsonArray is equal to JsonArray2
        JsonArray1.WriteTo(JsonText1);
        JsonArray2.WriteTo(JsonText2);
        Assert.AreEqual(JsonText1, JsonText2, 'The json arrays must be equal');

        // [THEN] Header Content-Type is application/json
        HttpContent := ALHttpContent.GetHttpContent();
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.GetValues('Content-Type', HeaderValues);
        Assert.AreEqual('application/json', HeaderValues.Get(1), 'The Content-Type header must be application/json');
    end;

    [Test]
    procedure TestCreateWithJsonToken()
    var
        ALHttpContent: Codeunit "Http Content";
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HeaderValues: List of [Text];
        JsonToken1: JsonToken;
        JsonToken2: JsonToken;
        JsonText1: Text;
        JsonText2: Text;
    begin
        // [SCENARIO] Create AL Http Content object with json token

        // [GIVEN] AL Http Content created with json token
        JsonToken1.ReadFrom('{"name":"John","age":30}');
        ALHttpContent := ALHttpContent.Create(JsonToken1);

        // [WHEN] Http Content is retrieved as JsonToken
        JsonToken2 := ALHttpContent.AsJson();

        // [THEN] JsonToken is equal to JsonToken2
        JsonToken1.WriteTo(JsonText1);
        JsonToken2.WriteTo(JsonText2);
        Assert.AreEqual(JsonText1, JsonText2, 'The json tokens must be equal');

        // [THEN] Header Content-Type is application/json
        HttpContent := ALHttpContent.GetHttpContent();
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.GetValues('Content-Type', HeaderValues);
        Assert.AreEqual('application/json', HeaderValues.Get(1), 'The Content-Type header must be application/json');
    end;

    [Test]
    procedure TestCreateWithXmlDocument()
    var
        ALHttpContent: Codeunit "Http Content";
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HeaderValues: List of [Text];
        XmlDoc1: XmlDocument;
        XmlDoc2: XmlDocument;
        XmlReadOptions: XmlReadOptions;
        XmlWriteOptions: XmlWriteOptions;
        Xml1: Text;
        Xml2: Text;
    begin
        // [SCENARIO] Create AL Http Content object with xml document

        // [GIVEN] AL Http Content created with xml document
        XmlReadOptions.PreserveWhitespace(false);
        XmlDocument.ReadFrom('<?xml version="1.0" encoding="utf-8"?><root><name>John</name><age>30</age></root>', XmlReadOptions, XmlDoc1);
        ALHttpContent := ALHttpContent.Create(XmlDoc1);

        // [WHEN] Http Content is retrieved as XmlDocument
        XmlDoc2 := ALHttpContent.AsXmlDocument();

        // [THEN] Xml is equal to XmlDoc
        XmlWriteOptions.PreserveWhitespace(false);
        XmlDoc1.WriteTo(XmlWriteOptions, Xml1);

        Clear(XmlWriteOptions); // PreserveWhitespace setting is not preserved between two calls to WriteTo, needed to reset it
        XmlWriteOptions.PreserveWhitespace(false);
        XmlDoc2.WriteTo(XmlWriteOptions, Xml2);
        Assert.AreEqual(Xml1, Xml2, 'The xml documents must be equal');

        // [THEN] Header Content-Type is text/xml
        HttpContent := ALHttpContent.GetHttpContent();
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.GetValues('Content-Type', HeaderValues);
        Assert.AreEqual('text/xml', HeaderValues.Get(1), 'The Content-Type header must be application/xml');
    end;

    [Test]
    procedure TestCreateWithInStream()
    var
        ALHttpContent: Codeunit "Http Content";
        TempBlob: Codeunit "Temp Blob";
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HeaderValues: List of [Text];
        OutStream: OutStream;
        InStream1: InStream;
        InStream2: InStream;
        TextContent: Text;
    begin
        // [SCENARIO] Create AL Http Content object with InStream

        // [GIVEN] AL Http Content created with InStream
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText('Hello World');
        TempBlob.CreateInStream(InStream1);
        ALHttpContent := ALHttpContent.Create(InStream1);

        // [WHEN] Http Content is retrieved as InStream
        InStream2 := ALHttpContent.AsInStream();

        // [THEN] Content is equal to Hello World
        InStream2.ReadText(TextContent);
        Assert.AreEqual('Hello World', TextContent, 'The content must be equal to Hello World');

        // [THEN] Header Content-Type is application/octet-stream
        HttpContent := ALHttpContent.GetHttpContent();
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.GetValues('Content-Type', HeaderValues);
        Assert.AreEqual('application/octet-stream', HeaderValues.Get(1), 'The Content-Type header must be application/octet-stream');
    end;

    [Test]
    procedure TestCreateWithInStreamWithContentType()
    var
        ALHttpContent: Codeunit "Http Content";
        TempBlob: Codeunit "Temp Blob";
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HeaderValues: List of [Text];
        OutStream: OutStream;
        InStream1: InStream;
        InStream2: InStream;
        TextContent: Text;
    begin
        // [SCENARIO] Create AL Http Content object with InStream

        // [GIVEN] AL Http Content created with InStream
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText('Hello World');
        TempBlob.CreateInStream(InStream1);
        ALHttpContent := ALHttpContent.Create(InStream1, 'text/plain');

        // [WHEN] Http Content is retrieved as InStream
        InStream2 := ALHttpContent.AsInStream();

        // [THEN] Content is equal to Hello World
        InStream2.ReadText(TextContent);
        Assert.AreEqual('Hello World', TextContent, 'The content must be equal to Hello World');

        // [THEN] Header Content-Type is application/octet-stream
        HttpContent := ALHttpContent.GetHttpContent();
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.GetValues('Content-Type', HeaderValues);
        Assert.AreEqual('text/plain', HeaderValues.Get(1), 'The Content-Type header must be text/plain');
    end;

    [Test]
    procedure TestCreateWithTempBlob()
    var
        ALHttpContent: Codeunit "Http Content";
        TempBlob1: Codeunit "Temp Blob";
        TempBlob2: Codeunit "Temp Blob";
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HeaderValues: List of [Text];
        OutStream: OutStream;
        InStream: InStream;
        TextContent: Text;
    begin
        // [SCENARIO] Create AL Http Content object with Temp Blob

        // [GIVEN] AL Http Content created with Temp Blob
        TempBlob1.CreateOutStream(OutStream);
        OutStream.WriteText('Hello World');
        ALHttpContent := ALHttpContent.Create(TempBlob1);

        // [WHEN] Http Content is retrieved as Temp Blob
        TempBlob2 := ALHttpContent.AsBlob();

        // [THEN] Content is equal to Hello World
        TempBlob2.CreateInStream(InStream);
        InStream.ReadText(TextContent);
        Assert.AreEqual('Hello World', TextContent, 'The content must be equal to Hello World');

        // [THEN] Header Content-Type is application/octet-stream
        HttpContent := ALHttpContent.GetHttpContent();
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.GetValues('Content-Type', HeaderValues);
        Assert.AreEqual('application/octet-stream', HeaderValues.Get(1), 'The Content-Type header must be application/octet-stream');
    end;

    [Test]
    procedure TestCreateWithTempBlobWithContentType()
    var
        ALHttpContent: Codeunit "Http Content";
        TempBlob1: Codeunit "Temp Blob";
        TempBlob2: Codeunit "Temp Blob";
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HeaderValues: List of [Text];
        OutStream: OutStream;
        InStream: InStream;
        TextContent: Text;
    begin
        // [SCENARIO] Create AL Http Content object with Temp Blob

        // [GIVEN] AL Http Content created with Temp Blob
        TempBlob1.CreateOutStream(OutStream);
        OutStream.WriteText('Hello World');
        ALHttpContent := ALHttpContent.Create(TempBlob1, 'text/plain');

        // [WHEN] Http Content is retrieved as Temp Blob
        TempBlob2 := ALHttpContent.AsBlob();

        // [THEN] Content is equal to Hello World
        TempBlob2.CreateInStream(InStream);
        InStream.ReadText(TextContent);
        Assert.AreEqual('Hello World', TextContent, 'The content must be equal to Hello World');

        // [THEN] Header Content-Type is application/octet-stream
        HttpContent := ALHttpContent.GetHttpContent();
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.GetValues('Content-Type', HeaderValues);
        Assert.AreEqual('text/plain', HeaderValues.Get(1), 'The Content-Type header must be text/plain');
    end;

    [Test]
    procedure TestCreateWithHttpContent()
    var
        ALHttpContent: Codeunit "Http Content";
        HttpContent: HttpContent;
        HttpContentHeaders: HttpHeaders;
        HeaderValues: List of [Text];
        Json1: Text;
        Json2: Text;
    begin
        // [SCENARIO] Create AL Http Content object with HttpContent

        // [GIVEN] AL Http Content is created with HttpContent
        Json1 := '{"name":"John","age":30}';
        HttpContent.WriteFrom(Json1);
        HttpContent.GetHeaders(HttpContentHeaders);
        if HttpContentHeaders.Contains('Content-Type') then
            HttpContentHeaders.Remove('Content-Type');
        HttpContentHeaders.Add('Content-Type', 'application/json');
        ALHttpContent := ALHttpContent.Create(HttpContent);

        // [WHEN] HttpContent object is retrieved
        HttpContent := ALHttpContent.GetHttpContent();

        // [THEN] HttpContent is equal to json
        HttpContent.ReadAs(Json2);
        Assert.AreEqual(Json1, Json2, 'The http content must be equal to json');

        // [THEN] Header Content-Type is application/json
        HttpContent.GetHeaders(HttpContentHeaders);
        HttpContentHeaders.GetValues('Content-Type', HeaderValues);
        Assert.AreEqual('application/json', HeaderValues.Get(1), 'The Content-Type header must be application/json');
    end;

    [Test]
    procedure TestSetContentTypeHeader()
    var
        ALHttpContent: Codeunit "Http Content";
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HeaderValues: List of [Text];
    begin
        // [SCENARIO] Set Content-Type header

        // [GIVEN] AL Http Content created with text
        ALHttpContent := ALHttpContent.Create('{ "name": "John", "age": 30 }');

        // [WHEN] Content-Type header is set
        ALHttpContent.SetContentTypeHeader('application/json');

        // [THEN] Header Content-Type is application/json
        HttpContent := ALHttpContent.GetHttpContent();
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.GetValues('Content-Type', HeaderValues);
        Assert.AreEqual('application/json', HeaderValues.Get(1), 'The Content-Type header must be application/json');
    end;

    [Test]
    procedure TestSetContentEncoding()
    var
        ALHttpContent: Codeunit "Http Content";
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HeaderValues: List of [Text];
    begin
        // [SCENARIO] Set Content-Encoding header

        // [GIVEN] AL Http Content created with text
        ALHttpContent := ALHttpContent.Create('{ "name": "John", "age": 30 }');

        // [WHEN] Content-Encoding header is set
        ALHttpContent.AddContentEncoding('deflate');
        ALHttpContent.AddContentEncoding('br');

        // [THEN] Header Content-Encoding is deflate, br
        HttpContent := ALHttpContent.GetHttpContent();
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.GetValues('Content-Encoding', HeaderValues);
        Assert.AreEqual('deflate', HeaderValues.Get(1), 'The Content-Encoding header must be deflate');
        Assert.AreEqual('br', HeaderValues.Get(2), 'The Content-Encoding header must be br');
    end;

    [Test]
    procedure TestSetHeader()
    var
        ALHttpContent: Codeunit "Http Content";
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HeaderValues: List of [Text];
    begin
        // [SCENARIO] Set header

        // [GIVEN] AL Http Content created with text
        ALHttpContent := ALHttpContent.Create('{ "name": "John", "age": 30 }');

        // [WHEN] Header is set
        ALHttpContent.SetHeader('X-My-Custom-Header', 'BC Rest Client');

        // [THEN] Header X-My-Custom-Header is BC Rest Client
        HttpContent := ALHttpContent.GetHttpContent();
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.GetValues('X-My-Custom-Header', HeaderValues);
        Assert.AreEqual('BC Rest Client', HeaderValues.Get(1), 'The X-Test header must be BC Rest Client');
    end;
}