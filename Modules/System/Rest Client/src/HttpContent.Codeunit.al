// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.RestClient;

using System.Utilities;

/// <summary>Holder object for the Http Content data.</summary>
codeunit 2354 "Http Content"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        HttpContentImpl: Codeunit "Http Content Impl.";

    #region Constructors
    /// <summary>Initializes a new instance of the Http Content class with the specified Text content.</summary>
    /// <param name="Content">The content to send to the server.</param>
    /// <returns>The Http Content object.</returns>
    /// <remarks>The Content-Type header will be set to 'text/plain'.</remarks>
    procedure Create(Content: Text) HttpContent: Codeunit "Http Content"
    begin
        HttpContent := Create(Content, '');
    end;

    /// <summary>Initializes a new instance of the Http Content class with the specified SecretText content.</summary>
    /// <param name="Content">The content to send to the server.</param>
    /// <returns>The Http Content object.</returns>
    /// <remarks>The Content-Type header will be set to 'text/plain'.</remarks>
    procedure Create(Content: SecretText) HttpContent: Codeunit "Http Content"
    begin
        HttpContent := Create(Content, '');
    end;

    /// <summary>Initializes a new instance of the Http Content class with the specified Text content and content type.</summary>
    /// <param name="Content">The content to send to the server.</param>
    /// <param name="ContentType">The content type of the content to send to the server.</param>
    /// <returns>The Http Content object.</returns>
    /// <remarks>If the ContentType parameter is not specified, it will be set to 'text/plain'.</remarks>
    procedure Create(Content: Text; ContentType: Text) HttpContent: Codeunit "Http Content"
    begin
        SetContent(Content, ContentType);
        HttpContent.SetHttpContentImpl(HttpContentImpl);
    end;

    /// <summary>Initializes a new instance of the Http Content class with the specified SecretText content and content type.</summary>
    /// <param name="Content">The content to send to the server.</param>
    /// <param name="ContentType">The content type of the content to send to the server.</param>
    /// <returns>The Http Content object.</returns>
    /// <remarks>If the ContentType parameter is not specified, it will be set to 'text/plain'.</remarks>
    procedure Create(Content: SecretText; ContentType: Text) HttpContent: Codeunit "Http Content"
    begin
        SetContent(Content, ContentType);
        HttpContent.SetHttpContentImpl(HttpContentImpl);
    end;

    /// <summary>Initializes a new instance of the Http Content class with the specified JsonObject content.</summary>
    /// <param name="Content">The content to send to the server.</param>
    /// <returns>The Http Content object.</returns>
    /// <remarks>The Content-Type header will be set to 'application/json'.</remarks>
    procedure Create(Content: JsonObject) HttpContent: Codeunit "Http Content"
    begin
        SetContent(Content);
        HttpContent.SetHttpContentImpl(HttpContentImpl);
    end;

    /// <summary>Initializes a new instance of the Http Content class with the specified JsonArray content.</summary>
    /// <param name="Content">The content to send to the server.</param>
    /// <returns>The Http Content object.</returns>
    /// <remarks>The Content-Type header will be set to 'application/json'.</remarks>
    procedure Create(Content: JsonArray) HttpContent: Codeunit "Http Content"
    begin
        SetContent(Content);
        HttpContent.SetHttpContentImpl(HttpContentImpl);
    end;

    /// <summary>Initializes a new instance of the Http Content class with the specified JsonToken content.</summary>
    /// <param name="Content">The content to send to the server.</param>
    /// <returns>The Http Content object.</returns>
    /// <remarks>The Content-Type header will be set to 'application/json'.</remarks>
    procedure Create(Content: JsonToken) HttpContent: Codeunit "Http Content"
    begin
        SetContent(Content);
        HttpContent.SetHttpContentImpl(HttpContentImpl);
    end;

    /// <summary>Initializes a new instance of the Http Content class with the specified XmlDocument content.</summary>
    /// <param name="Content">The content to send to the server.</param>
    /// <returns>The Http Content object.</returns>
    /// <remarks>The Content-Type header will be set to 'text/xml'.</remarks>
    procedure Create(Content: XmlDocument) HttpContent: Codeunit "Http Content"
    begin
        SetContent(Content);
        HttpContent.SetHttpContentImpl(HttpContentImpl);
    end;

    /// <summary>Initializes a new instance of the Http Content class with the specified "Temp Blob" Codeunit content.</summary>
    /// <param name="Content">The content to send to the server.</param>
    /// <returns>The Http Content object.</returns>
    /// <remarks>The Content-Type header will be set to 'application/octet-stream'.</remarks>
    procedure Create(Content: Codeunit "Temp Blob") HttpContent: Codeunit "Http Content"
    begin
        HttpContent := Create(Content, '');
    end;

    /// <summary>Initializes a new instance of the Http Content class with the specified "Temp Blob" Codeunit content and content type.</summary>
    /// <param name="Content">The content to send to the server.</param>
    /// <param name="ContentType">The content type of the content to send to the server.</param>
    /// <returns>The Http Content object.</returns>
    /// <remarks>If the ContentType parameter is not specified, it will be set to 'application/octet-stream'.</remarks>
    procedure Create(Content: Codeunit "Temp Blob"; ContentType: Text) HttpContent: Codeunit "Http Content"
    begin
        SetContent(Content, ContentType);
        HttpContent.SetHttpContentImpl(HttpContentImpl);
    end;

    /// <summary>Initializes a new instance of the Http Content class with the specified InStream content.</summary>
    /// <param name="Content">The content to send to the server.</param>
    /// <returns>The Http Content object.</returns>
    /// <remarks>The Content-Type header will be set to 'application/octet-stream'.</remarks>
    procedure Create(Content: InStream) HttpContent: Codeunit "Http Content"
    begin
        HttpContent := Create(Content, '');
    end;

    /// <summary>Initializes a new instance of the Http Content class with the specified InStream content and content type.</summary>
    /// <param name="Content">The content to send to the server.</param>
    /// <param name="ContentType">The content type of the content to send to the server.</param>
    /// <returns>The Http Content object.</returns>
    /// <remarks>If the ContentType parameter is not specified, it will be set to 'application/octet-stream'.</remarks>
    procedure Create(Content: InStream; ContentType: Text) HttpContent: Codeunit "Http Content"
    begin
        SetContent(Content, ContentType);
        HttpContent.SetHttpContentImpl(HttpContentImpl);
    end;

    /// <summary>Initializes a new instance of the Http Content object with the specified HttpContent object.</summary>
    /// <param name="Content">The HttpContent object.</param>
    /// <returns>The HttpContent object.</returns>
    /// <remarks>The HttpContent must be properly prepared including the Content-Type header.</remarks>
    procedure Create(Content: HttpContent) HttpContent: Codeunit "Http Content"
    begin
        SetContent(Content);
        HttpContent.SetHttpContentImpl(HttpContentImpl);
    end;
    #endregion

    #region Public Methods

    /// <summary>Sets the Content-Type header of the HttpContent object.</summary>
    /// <param name="ContentType">The value of the header to add.</param>
    /// <remarks>If the header already exists, it will be overwritten.</remarks>
    procedure SetContentTypeHeader(ContentType: Text)
    begin
        HttpContentImpl.SetContentTypeHeader(ContentType);
    end;

    /// <summary>Sets the Content-Encoding header of the HttpContent object.</summary>
    /// <param name="ContentEncoding">The value of the header to add.</param>
    /// <remarks>If the header already exists, the value will be added to the end of the list.</remarks>
    procedure AddContentEncoding(ContentEncoding: Text)
    begin
        HttpContentImpl.AddContentEncoding(ContentEncoding);
    end;

    /// <summary>Sets a new value for an existing header of the HttpContent object, or adds the header if it does not already exist.</summary>
    /// <param name="Name">The name of the header to add.</param>
    /// <param name="Value">The value of the header to add.</param>
    procedure SetHeader(Name: Text; Value: Text)
    begin
        HttpContentImpl.SetHeader(Name, Value);
    end;

    /// <summary>Sets a new value for an existing header of the HttpContent object, or adds the header if it does not already exist.</summary>
    /// <param name="Name">The name of the header to add.</param>
    /// <param name="Value">The value of the header to add.</param>
    procedure SetHeader(Name: Text; Value: SecretText)
    begin
        HttpContentImpl.SetHeader(Name, Value);
    end;

    /// <summary>Gets the HttpContent object.</summary>
    /// <returns>The HttpContent object.</returns>
    procedure GetHttpContent() ReturnValue: HttpContent
    begin
        ReturnValue := HttpContentImpl.GetHttpContent();
    end;

    /// <summary>Gets the content of the HTTP response message as a string.</summary>
    /// <returns>The content of the HTTP response message as a string.</returns>
    procedure AsText() ReturnValue: Text
    begin
        ReturnValue := HttpContentImpl.AsText();
    end;

    /// <summary>Gets the content of the HTTP response message as a SecretText.</summary>
    /// <returns>The content of the HTTP response message as a SecretText.</returns>
    procedure AsSecretText() ReturnValue: SecretText
    begin
        ReturnValue := HttpContentImpl.AsSecretText();
    end;

    /// <summary>Gets the content of the HTTP response message as a "Temp Blob" Codeunit.</summary>
    /// <returns>The content of the HTTP response message as a "Temp Blob" Codeunit.</returns>
    procedure AsBlob() TempBlob: Codeunit "Temp Blob"
    begin
        TempBlob := HttpContentImpl.AsBlob();
    end;

    /// <summary>Gets the content of the HTTP response message as an InStream.</summary>
    /// <returns>The content of the HTTP response message as an InStream.</returns>
    procedure AsInStream() InStr: InStream
    begin
        HttpContentImpl.AsInStream(InStr);
    end;

    /// <summary>Gets the content of the HTTP response message as an XmlDocument.</summary>
    /// <returns>The content of the HTTP response message as an XmlDocument.</returns>
    /// <remarks>Fails in case the content is not a valid XML document.</remarks>
    procedure AsXmlDocument() XmlDoc: XmlDocument
    begin
        XmlDoc := HttpContentImpl.AsXmlDocument();
    end;

    /// <summary>Gets the content of the HTTP response message as a JsonToken.</summary>
    /// <returns>The content of the HTTP response message as a JsonToken.</returns>
    /// <remarks>Fails in case the content is not a valid JSON document.</remarks>
    procedure AsJson() JsonToken: JsonToken
    begin
        JsonToken := HttpContentImpl.AsJson();
    end;
    #endregion

    #region Internal Methods
    internal procedure SetContent(Content: Text; ContentType: Text)
    begin
        HttpContentImpl.SetContent(Content, ContentType);
    end;

    internal procedure SetContent(Content: SecretText; ContentType: Text)
    begin
        HttpContentImpl.SetContent(Content, ContentType);
    end;

    internal procedure SetContent(Content: InStream; ContentType: Text)
    begin
        HttpContentImpl.SetContent(Content, ContentType);
    end;

    internal procedure SetContent(TempBlob: Codeunit "Temp Blob"; ContentType: Text)
    begin
        HttpContentImpl.SetContent(TempBlob, ContentType);
    end;

    internal procedure SetContent(Content: XmlDocument)
    begin
        HttpContentImpl.SetContent(Content);
    end;

    internal procedure SetContent(Content: JsonObject)
    begin
        SetContent(Content.AsToken());
    end;

    internal procedure SetContent(Content: JsonArray)
    begin
        SetContent(Content.AsToken());
    end;

    internal procedure SetContent(Content: JsonToken)
    begin
        HttpContentImpl.SetContent(Content);
    end;

    internal procedure SetContent(var Value: HttpContent)
    begin
        HttpContentImpl.SetContent(Value);
    end;

    internal procedure SetHttpContentImpl(Value: Codeunit "Http Content Impl.")
    begin
        HttpContentImpl := Value;
    end;
    #endregion
}