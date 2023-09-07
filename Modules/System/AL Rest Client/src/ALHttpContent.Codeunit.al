/// <summary>Holder object for the Http Content data.</summary>
codeunit 2354 "AL Http Content"
{
    var
        HttpContent: HttpContent;
        ContentTypeEmptyErr: Label 'The value of the Content-Type header must be specified.';
        ContentNotSupportedErr: Label 'The content is not supported.';
        MimeTypeTextPlainTxt: Label 'text/plain', Locked = true;
        MimeTypeTextXmlTxt: Label 'text/xml', Locked = true;
        MimeTypeApplicationOctetStreamTxt: Label 'application/octet-stream', Locked = true;
        MimeTypeApplicationJsonTxt: Label 'application/json', Locked = true;

    #region Constructors
    /// <summary>Initializes a new instance of the ALHttpContent class with the specified content.</summary>
    /// <param name="Content">The content to send to the server. Valid types are Codeunit (Temp Blob), InStream, JsonObject, JsonArray, JsonToken, XmlDocument, Text</param>
    /// <returns>The AL Http Content object</returns>
    /// <remarks>
    /// Text types will automatically get 'text/plain'.
    /// Json types will automatically get 'application/json'. 
    /// Xml types will automatically get 'text/xml'. 
    /// Codeunit "Temp Blob" and InStream types will automatically get 'application/octet-stream'.
    /// </remarks>

    procedure Create(Content: Variant) ALHttpContent: Codeunit "AL Http Content";
    begin
        ALHttpContent := Create(Content, '');
    end;

    /// <summary>Initializes a new instance of the ALHttpContent class with the specified content and content type.</summary>
    /// <param name="Content">The content to send to the server. Valid types are Codeunit (Temp Blob), InStream, JsonObject, JsonArray, JsonToken, XmlDocument, Text</param>
    /// <param name="ContentType">The content type of the content to send to the server.</param>
    /// <returns>The AL Http Content object.</returns>
    /// <remarks>
    /// Text types will automatically get 'text/plain' if not specified in the ContentType parameter.
    /// Json types will automatically get 'application/json'. 
    /// Xml types will automatically get 'text/xml'. 
    /// Codeunit "Temp Blob" and InStream types will automatically get 'application/octet-stream' if not specified in the ContentType parameter.
    /// </remarks>
    procedure Create(Content: Variant; ContentType: Text) ALHttpContent: Codeunit "AL Http Content"
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        XmlDoc: XmlDocument;
        ContentText: Text;
    begin
        case true of
            Content.IsText:
                begin
                    ContentText := Content;
                    if ContentType = '' then
                        ContentType := MimeTypeTextPlainTxt;
                    ALHttpContent.SetContent(ContentText, ContentType);
                end;
            Content.IsJsonObject:
                begin
                    JsonObject := Content;
                    ALHttpContent.SetContent(JsonObject);
                end;
            Content.IsJsonArray:
                begin
                    JsonArray := Content;
                    ALHttpContent.SetContent(JsonArray);
                end;
            Content.IsJsonToken:
                begin
                    JsonToken := Content;
                    ALHttpContent.SetContent(JsonToken);
                end;
            Content.IsXmlDocument:
                begin
                    XmlDoc := Content;
                    ALHttpContent.SetContent(XmlDoc);
                end;
            Content.IsCodeunit:
                begin
                    TempBlob := Content;
                    if ContentType = '' then
                        ContentType := MimeTypeApplicationOctetStreamTxt;
                    ALHttpContent.SetContent(TempBlob, ContentType);
                end;
            Content.IsInStream:
                begin
                    InStream := Content;
                    if ContentType = '' then
                        ContentType := MimeTypeApplicationOctetStreamTxt;
                    ALHttpContent.SetContent(InStream, ContentType);
                end;
            else
                Error(ContentNotSupportedErr);
        end;
    end;

    /// <summary>Initializes a new instance of the ALHttpContent object with the specified HttpContent object.</summary>
    /// <param name="Content">The HttpContent object.</param>
    /// <returns>The HttpContent object.</returns>
    /// <remarks>The HttpContent must be properly prepared including the Content-Type header.</remarks>
    procedure Create(Content: HttpContent) ALHttpContent: Codeunit "AL Http Content"
    var
        ContentText: Text;
    begin
        ALHttpContent.SetHttpContent(Content);
    end;
    #endregion

    #region Public Methods

    /// <summary>Sets the Content-Type header of the HttpContent object.</summary>
    /// <param name="ContentType">The value of the header to add.</param>
    /// <remarks>If the header already exists, it will be overwritten.</remarks>
    procedure SetContentTypeHeader(ContentType: Text)
    begin
        if ContentType = '' then
            Error(ContentTypeEmptyErr);
        SetHeader('Content-Type', ContentType);
    end;

    /// <summary>Sets the Content-Encoding header of the HttpContent object.</summary>
    /// <param name="ContentEncoding">The value of the header to add.</param>
    /// <remarks>If the header already exists, it will be overwritten.</remarks>
    procedure AddContentEncoding(ContentEncoding: Text)
    var
        Headers: HttpHeaders;
    begin
        if not HttpContent.GetHeaders(Headers) then begin
            HttpContent.Clear();
            HttpContent.GetHeaders(Headers);
        end;
        Headers.Add('Content-Encoding', ContentEncoding);
    end;

    /// <summary>Adds a header to the HttpContent object.</summary>
    /// <param name="Name">The name of the header to add.</param>
    /// <param name="Value">The value of the header to add.</param>
    /// <remarks>If the header already exists, it will be overwritten.</remarks>
    procedure SetHeader(Name: Text; Value: Text)
    var
        Headers: HttpHeaders;
    begin
        if not HttpContent.GetHeaders(Headers) then begin
            HttpContent.Clear();
            HttpContent.GetHeaders(Headers);
        end;

        if Headers.Contains(Name) then
            Headers.Remove(Name);

        Headers.Add(Name, Value);
    end;

    /// <summary>Gets the HttpContent object.</summary>
    /// <returns>The HttpContent object.</returns>
    procedure GetHttpContent(): HttpContent
    begin
        exit(HttpContent);
    end;

    /// <summary>Gets the content of the HTTP response message as a string.</summary>
    /// <returns>The content of the HTTP response message as a string.</returns>
    procedure AsText() ReturnValue: Text
    begin
        HttpContent.ReadAs(ReturnValue);
    end;

    /// <summary>Gets the content of the HTTP response message as a "Temp Blob" Codeunit.</summary>
    /// <returns>The content of the HTTP response message as a "Temp Blob" Codeunit.</returns>
    procedure AsBlob() ReturnValue: Codeunit "Temp Blob"
    var
        InStr: InStream;
        OutStr: OutStream;
    begin
        HttpContent.ReadAs(InStr);
        ReturnValue.CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
    end;

    /// <summary>Gets the content of the HTTP response message as an InStream.</summary>
    /// <returns>The content of the HTTP response message as an InStream.</returns>
    procedure AsInStream() InStr: InStream
    begin
        HttpContent.ReadAs(InStr);
    end;

    /// <summary>Gets the content of the HTTP response message as an XmlDocument.</summary>
    /// <returns>The content of the HTTP response message as an XmlDocument.</returns>
    /// <remarks>Fails in case the content is not a valid XML document.</remarks>
    procedure AsXmlDocument() ReturnValue: XmlDocument
    var
        XmlReadOptions: XmlReadOptions;
    begin
        XmlReadOptions.PreserveWhitespace(false);
        XmlDocument.ReadFrom(AsText(), XmlReadOptions, ReturnValue);
    end;

    /// <summary>Gets the content of the HTTP response message as a JsonToken.</summary>
    /// <returns>The content of the HTTP response message as a JsonToken.</returns>
    /// <remarks>Fails in case the content is not a valid JSON document.</remarks>
    procedure AsJson() ReturnValue: JsonToken
    begin
        ReturnValue.ReadFrom(AsInStream());
    end;

    #endregion

    #region Internal Methods
    internal procedure SetContent(Content: Text; ContentType: Text)
    begin
        HttpContent.Clear();
        HttpContent.WriteFrom(Content);
        SetContentTypeHeader(ContentType);
    end;

    internal procedure SetContent(Content: InStream; ContentType: Text)
    begin
        HttpContent.Clear();
        HttpContent.WriteFrom(Content);
        SetContentTypeHeader(ContentType);
    end;

    internal procedure SetContent(TempBlob: Codeunit "Temp Blob"; ContentType: Text)
    var
        InStream: InStream;
    begin
        InStream := TempBlob.CreateInStream(TextEncoding::UTF8);
        SetContent(InStream, ContentType);
    end;

    internal procedure SetContent(Content: XmlDocument)
    var
        Xml: Text;
        XmlWriteOptions: XmlWriteOptions;
    begin
        XmlWriteOptions.PreserveWhitespace(false);
        Content.WriteTo(XmlWriteOptions, Xml);
        SetContent(Xml, MimeTypeTextXmlTxt);
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
    var
        Json: Text;
    begin
        Content.WriteTo(Json);
        SetContent(Json, MimeTypeApplicationJsonTxt);
    end;

    internal procedure SetHttpContent(var Value: HttpContent)
    begin
        HttpContent := Value;
    end;
    #endregion
}