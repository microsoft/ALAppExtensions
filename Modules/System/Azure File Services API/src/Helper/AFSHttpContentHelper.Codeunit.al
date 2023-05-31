codeunit 50104 "AFS HttpContent Helper"
{
    Access = Internal;

    var
        ContentLengthLbl: Label '%1', Comment = '%1 = Length', Locked = true;
        RangeLbl: Label 'bytes=%1-%2', Comment = '%1 = Range Start, %2 = Range End', Locked = true;

    // // [NonDebuggable]
    // procedure AddXmlDocumentAsContent(var HttpContent: HttpContent; var AFSOperationPayload: Codeunit "AFS Operation Payload"; Document: XmlDocument)
    // var
    //     Headers: HttpHeaders;
    //     Length: Integer;
    //     DocumentAsText: Text;
    // begin
    //     DocumentAsText := Format(Document);
    //     Length := StrLen(DocumentAsText);

    //     HttpContent.WriteFrom(DocumentAsText);

    //     HttpContent.GetHeaders(Headers);
    //     AFSOperationPayload.AddContentHeader('HttpContent-Type', 'application/xml');
    //     AFSOperationPayload.AddContentHeader('HttpContent-Length', Format(Length));
    // end;

    // [NonDebuggable]
    procedure ContentSet(HttpContent: HttpContent): Boolean
    var
        VarContent: Text;
    begin
        HttpContent.ReadAs(VarContent);
        if StrLen(VarContent) > 0 then
            exit(true);

        exit(VarContent <> '');
    end;

    /// <summary>
    /// Retrieves the length of the given stream (used for "HttpContent-Length" header in PUT-operations)
    /// </summary>
    /// <param name="SourceInStream">The InStream for Request Body.</param>
    /// <returns>The length of the current stream</returns>
    // [NonDebuggable]
    procedure GetContentLength(var SourceInStream: InStream): Integer
    var
        Length: Integer;
    begin
        Evaluate(Length, Format(SourceInStream.Length()));
        exit(Length);
    end;

    /// <summary>
    /// Retrieves the length of the given stream (used for "HttpContent-Length" header in PUT-operations)
    /// </summary>
    /// <param name="SourceText">The Text for Request Body.</param>
    /// <returns>The length of the current stream</returns>
    // [NonDebuggable]
    procedure GetContentLength(SourceText: Text): Integer
    var
        Length: Integer;
    begin
        Length := StrLen(SourceText);
        exit(Length);
    end;

    // [NonDebuggable]
    procedure AddFilePutContentHeaders(AFSOperationPayload: Codeunit "AFS Operation Payload"; ContentType: Text; RangeStart: Integer; RangeEnd: Integer)
    var
        HttpContent: HttpContent;
    begin
        AddFilePutContentHeaders(HttpContent, AFSOperationPayload, 0, ContentType, RangeStart, RangeEnd);
    end;

    // [NonDebuggable]
    procedure AddFilePutContentHeaders(AFSOperationPayload: Codeunit "AFS Operation Payload"; ContentLength: Integer; ContentType: Text; RangeStart: Integer; RangeEnd: Integer)
    var
        HttpContent: HttpContent;
    begin
        AddFilePutContentHeaders(HttpContent, AFSOperationPayload, ContentLength, ContentType, RangeStart, RangeEnd);
    end;

    // [NonDebuggable]
    procedure AddFilePutContentHeaders(var HttpContent: HttpContent; AFSOperationPayload: Codeunit "AFS Operation Payload"; var SourceInStream: InStream; RangeStart: Integer; RangeEnd: Integer)
    var
        Length: Integer;
    begin
        // Do this before calling "GetContentLength", because for some reason the system errors out with "Cannot access a closed Stream."
        HttpContent.WriteFrom(SourceInStream);

        Length := GetContentLength(SourceInStream);

        AddFilePutContentHeaders(HttpContent, AFSOperationPayload, Length, 'application/octet-stream', RangeStart, RangeEnd);
    end;

    // [NonDebuggable]
    procedure AddFilePutContentHeaders(var HttpContent: HttpContent; ABSOperationPayload: Codeunit "AFS Operation Payload"; SourceText: Text; RangeStart: Integer; RangeEnd: Integer)
    var
        Length: Integer;
    begin
        HttpContent.WriteFrom(SourceText);

        Length := GetContentLength(SourceText);

        AddFilePutContentHeaders(HttpContent, ABSOperationPayload, Length, 'text/plain; charset=UTF-8', RangeStart, RangeEnd);
    end;

    // [NonDebuggable]
    local procedure AddFilePutContentHeaders(var HttpContent: HttpContent; AFSOperationPayload: Codeunit "AFS Operation Payload"; ContentLength: Integer; ContentType: Text; RangeStart: Integer; RangeEnd: Integer)
    var
        Headers: HttpHeaders;
        FileServiceAPIOperation: Enum "AFS Operation";
    begin
        if ContentType = '' then
            ContentType := 'application/octet-stream';

        HttpContent.GetHeaders(Headers);

        AFSOperationPayload.AddContentHeader('Content-Type', ContentType);
        if AFSOperationPayload.GetOperation() in [FileServiceAPIOperation::CreateFile] then
            AFSOperationPayload.AddContentHeader('x-ms-content-length', StrSubstNo(ContentLengthLbl, ContentLength))
        else
            AFSOperationPayload.AddContentHeader('Content-Length', StrSubstNo(ContentLengthLbl, ContentLength));

        if AFSOperationPayload.GetOperation() in [FileServiceAPIOperation::PutRange, FileServiceAPIOperation::PutRangefromURL] then begin
            AFSOperationPayload.AddRequestHeader('x-ms-write', 'update');
            AFSOperationPayload.AddRequestHeader('x-ms-range', StrSubstNo(RangeLbl, RangeStart, RangeEnd));
        end;
    end;

    // [NonDebuggable]
    procedure GetMaxRange(): Integer
    begin
        exit(4 * Power(2, 20));
    end;
}