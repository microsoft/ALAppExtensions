// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9049 "ABS HttpContent Helper"
{
    Access = Internal;

    var
        ContentLengthLbl: Label '%1', Comment = '%1 = Length', Locked = true;

    [NonDebuggable]
    procedure AddBlobPutBlockBlobContentHeaders(var HttpContent: HttpContent; ABSOperationPayload: Codeunit "ABS Operation Payload"; var SourceInStream: InStream)
    var
        BlobType: Enum "ABS Blob Type";
    begin
        AddBlobPutContentHeaders(HttpContent, ABSOperationPayload, SourceInStream, BlobType::BlockBlob)
    end;

    [NonDebuggable]
    procedure AddBlobPutBlockBlobContentHeaders(var HttpContent: HttpContent; ABSOperationPayload: Codeunit "ABS Operation Payload"; SourceText: Text)
    var
        BlobType: Enum "ABS Blob Type";
    begin
        AddBlobPutContentHeaders(HttpContent, ABSOperationPayload, SourceText, BlobType::BlockBlob)
    end;

    [NonDebuggable]
    procedure AddBlobPutPageBlobContentHeaders(ABSOperationPayload: Codeunit "ABS Operation Payload"; ContentLength: Integer; ContentType: Text)
    var
        BlobType: Enum "ABS Blob Type";
        HttpContent: HttpContent;
    begin
        if ContentLength = 0 then
            ContentLength := 512;
        AddBlobPutContentHeaders(HttpContent, ABSOperationPayload, BlobType::PageBlob, ContentLength, ContentType)
    end;

    [NonDebuggable]
    procedure AddBlobPutAppendBlobContentHeaders(ABSOperationPayload: Codeunit "ABS Operation Payload"; ContentType: Text)
    var
        BlobType: Enum "ABS Blob Type";
        HttpContent: HttpContent;
    begin
        AddBlobPutContentHeaders(HttpContent, ABSOperationPayload, BlobType::AppendBlob, 0, ContentType)
    end;

    [NonDebuggable]
    local procedure AddBlobPutContentHeaders(var HttpContent: HttpContent; ABSOperationPayload: Codeunit "ABS Operation Payload"; var SourceInStream: InStream; BlobType: Enum "ABS Blob Type")
    var
        Length: Integer;
    begin
        // Do this before calling "GetContentLength", because for some reason the system errors out with "Cannot access a closed Stream."
        HttpContent.WriteFrom(SourceInStream);

        Length := GetContentLength(SourceInStream);

        AddBlobPutContentHeaders(HttpContent, ABSOperationPayload, BlobType, Length, 'application/octet-stream');
    end;

    [NonDebuggable]
    local procedure AddBlobPutContentHeaders(var HttpContent: HttpContent; ABSOperationPayload: Codeunit "ABS Operation Payload"; SourceText: Text; BlobType: Enum "ABS Blob Type")
    var
        Length: Integer;
    begin
        HttpContent.WriteFrom(SourceText);

        Length := GetContentLength(SourceText);

        AddBlobPutContentHeaders(HttpContent, ABSOperationPayload, BlobType, Length, 'text/plain; charset=UTF-8');
    end;

    [NonDebuggable]
    local procedure AddBlobPutContentHeaders(var HttpContent: HttpContent; ABSOperationPayload: Codeunit "ABS Operation Payload"; BlobType: Enum "ABS Blob Type"; ContentLength: Integer; ContentType: Text)
    var
        Headers: HttpHeaders;
        BlobServiceAPIOperation: Enum "ABS Operation";
    begin
        if ContentType = '' then
            ContentType := 'application/octet-stream';

        HttpContent.GetHeaders(Headers);

        if not (ABSOperationPayload.GetOperation() in [BlobServiceAPIOperation::PutPage]) then
            ABSOperationPayload.AddContentHeader('HttpContent-Type', ContentType);

        case BlobType of
            BlobType::PageBlob:
                begin
                    ABSOperationPayload.AddRequestHeader('x-ms-blob-content-length', StrSubstNo(ContentLengthLbl, ContentLength));
                    ABSOperationPayload.AddContentHeader('HttpContent-Length', StrSubstNo(ContentLengthLbl, 0));
                end;
            else
                ABSOperationPayload.AddContentHeader('HttpContent-Length', StrSubstNo(ContentLengthLbl, ContentLength));
        end;

        if not (ABSOperationPayload.GetOperation() in [BlobServiceAPIOperation::PutBlock, BlobServiceAPIOperation::PutPage, BlobServiceAPIOperation::AppendBlock]) then
            ABSOperationPayload.AddRequestHeader('x-ms-blob-type', Format(BlobType));
    end;

    [NonDebuggable]
    procedure AddTagsContent(var HttpContent: HttpContent; var ABSOperationPayload: Codeunit "ABS Operation Payload"; Document: XmlDocument)
    begin
        AddXmlDocumentAsContent(HttpContent, ABSOperationPayload, Document);
    end;

    [NonDebuggable]
    procedure AddBlockListContent(var HttpContent: HttpContent; var ABSOperationPayload: Codeunit "ABS Operation Payload"; Document: XmlDocument)
    begin
        AddXmlDocumentAsContent(HttpContent, ABSOperationPayload, Document);
    end;

    [NonDebuggable]
    local procedure AddXmlDocumentAsContent(var HttpContent: HttpContent; var ABSOperationPayload: Codeunit "ABS Operation Payload"; Document: XmlDocument)
    var
        Headers: HttpHeaders;
        Length: Integer;
        DocumentAsText: Text;
    begin
        DocumentAsText := Format(Document);
        Length := StrLen(DocumentAsText);

        HttpContent.WriteFrom(DocumentAsText);

        HttpContent.GetHeaders(Headers);
        ABSOperationPayload.AddContentHeader('HttpContent-Type', 'application/xml');
        ABSOperationPayload.AddContentHeader('HttpContent-Length', Format(Length));
    end;

    [NonDebuggable]
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
    [NonDebuggable]
    local procedure GetContentLength(var SourceInStream: InStream): Integer
    var
        MemoryStream: DotNet MemoryStream;
        Length: Integer;
    begin
        // Load the memory stream and get the size
        MemoryStream := MemoryStream.MemoryStream();
        CopyStream(MemoryStream, SourceInStream);
        Length := MemoryStream.Length();
        Clear(SourceInStream);
        exit(Length);
    end;

    /// <summary>
    /// Retrieves the length of the given stream (used for "HttpContent-Length" header in PUT-operations)
    /// </summary>
    /// <param name="SourceText">The Text for Request Body.</param>
    /// <returns>The length of the current stream</returns>
    [NonDebuggable]
    local procedure GetContentLength(SourceText: Text): Integer
    var
        Length: Integer;
    begin
        Length := StrLen(SourceText);
        exit(Length);
    end;
}