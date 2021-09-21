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
    procedure AddBlobPutBlockBlobContentHeaders(var Content: HttpContent; OperationPayload: Codeunit "ABS Operation Payload"; var SourceStream: InStream)
    var
        BlobType: Enum "ABS Blob Type";
    begin
        AddBlobPutContentHeaders(Content, OperationPayload, SourceStream, BlobType::BlockBlob)
    end;

    [NonDebuggable]
    procedure AddBlobPutBlockBlobContentHeaders(var Content: HttpContent; OperationPayload: Codeunit "ABS Operation Payload"; SourceText: Text)
    var
        BlobType: Enum "ABS Blob Type";
    begin
        AddBlobPutContentHeaders(Content, OperationPayload, SourceText, BlobType::BlockBlob)
    end;

    [NonDebuggable]
    procedure AddBlobPutPageBlobContentHeaders(OperationPayload: Codeunit "ABS Operation Payload"; ContentLength: Integer; ContentType: Text)
    var
        BlobType: Enum "ABS Blob Type";
        Content: HttpContent;
    begin
        if ContentLength = 0 then
            ContentLength := 512;
        AddBlobPutContentHeaders(Content, OperationPayload, BlobType::PageBlob, ContentLength, ContentType)
    end;

    [NonDebuggable]
    procedure AddBlobPutAppendBlobContentHeaders(OperationPayload: Codeunit "ABS Operation Payload"; ContentType: Text)
    var
        BlobType: Enum "ABS Blob Type";
        Content: HttpContent;
    begin
        AddBlobPutContentHeaders(Content, OperationPayload, BlobType::AppendBlob, 0, ContentType)
    end;

    [NonDebuggable]
    local procedure AddBlobPutContentHeaders(var Content: HttpContent; OperationPayload: Codeunit "ABS Operation Payload"; var SourceStream: InStream; BlobType: Enum "ABS Blob Type")
    var
        Length: Integer;
    begin
        // Do this before calling "GetContentLength", because for some reason the system errors out with "Cannot access a closed Stream."
        Content.WriteFrom(SourceStream);

        Length := GetContentLength(SourceStream);

        AddBlobPutContentHeaders(Content, OperationPayload, BlobType, Length, 'application/octet-stream');
    end;

    [NonDebuggable]
    local procedure AddBlobPutContentHeaders(var Content: HttpContent; OperationPayload: Codeunit "ABS Operation Payload"; SourceText: Text; BlobType: Enum "ABS Blob Type")
    var
        Length: Integer;
    begin
        Content.WriteFrom(SourceText);

        Length := GetContentLength(SourceText);

        AddBlobPutContentHeaders(Content, OperationPayload, BlobType, Length, 'text/plain; charset=UTF-8');
    end;

    [NonDebuggable]
    local procedure AddBlobPutContentHeaders(var Content: HttpContent; OperationPayload: Codeunit "ABS Operation Payload"; BlobType: Enum "ABS Blob Type"; ContentLength: Integer; ContentType: Text)
    var
        Headers: HttpHeaders;
        BlobServiceAPIOperation: Enum "ABS Operation";
    begin
        if ContentType = '' then
            ContentType := 'application/octet-stream';

        Content.GetHeaders(Headers);

        if not (OperationPayload.GetOperation() in [BlobServiceAPIOperation::PutPage]) then
            OperationPayload.AddContentHeader('Content-Type', ContentType);

        case BlobType of
            BlobType::PageBlob:
                begin
                    OperationPayload.AddRequestHeader('x-ms-blob-content-length', StrSubstNo(ContentLengthLbl, ContentLength));
                    OperationPayload.AddContentHeader('Content-Length', StrSubstNo(ContentLengthLbl, 0));
                end;
            else
                OperationPayload.AddContentHeader('Content-Length', StrSubstNo(ContentLengthLbl, ContentLength));
        end;

        if not (OperationPayload.GetOperation() in [BlobServiceAPIOperation::PutBlock, BlobServiceAPIOperation::PutPage, BlobServiceAPIOperation::AppendBlock]) then
            OperationPayload.AddRequestHeader('x-ms-blob-type', Format(BlobType));
    end;

    [NonDebuggable]
    procedure AddTagsContent(var Content: HttpContent; var OperationPayload: Codeunit "ABS Operation Payload"; Document: XmlDocument)
    begin
        AddXmlDocumentAsContent(Content, OperationPayload, Document);
    end;

    [NonDebuggable]
    procedure AddBlockListContent(var Content: HttpContent; var OperationPayload: Codeunit "ABS Operation Payload"; Document: XmlDocument)
    begin
        AddXmlDocumentAsContent(Content, OperationPayload, Document);
    end;

    [NonDebuggable]
    local procedure AddXmlDocumentAsContent(var Content: HttpContent; var OperationPayload: Codeunit "ABS Operation Payload"; Document: XmlDocument)
    var
        Headers: HttpHeaders;
        Length: Integer;
        DocumentAsText: Text;
    begin
        DocumentAsText := Format(Document);
        Length := StrLen(DocumentAsText);

        Content.WriteFrom(DocumentAsText);

        Content.GetHeaders(Headers);
        OperationPayload.AddContentHeader('Content-Type', 'application/xml');
        OperationPayload.AddContentHeader('Content-Length', Format(Length));
    end;

    [NonDebuggable]
    procedure ContentSet(Content: HttpContent): Boolean
    var
        VarContent: Text;
    begin
        Content.ReadAs(VarContent);
        if StrLen(VarContent) > 0 then
            exit(true);

        exit(VarContent <> '');
    end;

    /// <summary>
    /// Retrieves the length of the given stream (used for "Content-Length" header in PUT-operations)
    /// </summary>
    /// <param name="SourceStream">The InStream for Request Body.</param>
    /// <returns>The length of the current stream</returns>
    [NonDebuggable]
    local procedure GetContentLength(var SourceStream: InStream): Integer
    var
        MemoryStream: DotNet MemoryStream;
        Length: Integer;
    begin
        // Load the memory stream and get the size
        MemoryStream := MemoryStream.MemoryStream();
        CopyStream(MemoryStream, SourceStream);
        Length := MemoryStream.Length();
        Clear(SourceStream);
        exit(Length);
    end;

    /// <summary>
    /// Retrieves the length of the given stream (used for "Content-Length" header in PUT-operations)
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