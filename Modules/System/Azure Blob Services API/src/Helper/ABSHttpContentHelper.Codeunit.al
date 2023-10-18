// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Storage;

codeunit 9049 "ABS HttpContent Helper"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        ContentLengthLbl: Label '%1', Comment = '%1 = Length', Locked = true;

    [NonDebuggable]
    procedure AddBlobPutBlockBlobContentHeaders(var HttpContent: HttpContent; ABSOperationPayload: Codeunit "ABS Operation Payload"; var SourceInStream: InStream; ContentType: Text)
    var
        BlobType: Enum "ABS Blob Type";
    begin
        AddBlobPutContentHeaders(HttpContent, ABSOperationPayload, SourceInStream, BlobType::BlockBlob, ContentType)
    end;

    [NonDebuggable]
    procedure AddBlobPutBlockBlobContentHeaders(var HttpContent: HttpContent; ABSOperationPayload: Codeunit "ABS Operation Payload"; SourceText: Text; ContentType: Text)
    var
        BlobType: Enum "ABS Blob Type";
    begin
        AddBlobPutContentHeaders(HttpContent, ABSOperationPayload, SourceText, BlobType::BlockBlob, ContentType)
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
    local procedure AddBlobPutContentHeaders(var HttpContent: HttpContent; ABSOperationPayload: Codeunit "ABS Operation Payload"; var SourceInStream: InStream; BlobType: Enum "ABS Blob Type"; ContentType: Text)
    var
        Length: BigInteger;
    begin
        // Do this before calling "GetContentLength", because for some reason the system errors out with "Cannot access a closed Stream."
        HttpContent.WriteFrom(SourceInStream);

        Length := GetContentLength(SourceInStream);

        if ContentType = '' then
            ContentType := 'application/octet-stream';

        AddBlobPutContentHeaders(HttpContent, ABSOperationPayload, BlobType, Length, ContentType);
    end;

    [NonDebuggable]
    local procedure AddBlobPutContentHeaders(var HttpContent: HttpContent; ABSOperationPayload: Codeunit "ABS Operation Payload"; SourceText: Text; BlobType: Enum "ABS Blob Type"; ContentType: Text)
    var
        Length: Integer;
    begin
        HttpContent.WriteFrom(SourceText);

        Length := GetContentLength(SourceText);

        if ContentType = '' then
            ContentType := 'text/plain; charset=UTF-8';

        AddBlobPutContentHeaders(HttpContent, ABSOperationPayload, BlobType, Length, ContentType);
    end;

    [NonDebuggable]
    local procedure AddBlobPutContentHeaders(var HttpContent: HttpContent; ABSOperationPayload: Codeunit "ABS Operation Payload"; BlobType: Enum "ABS Blob Type"; ContentLength: BigInteger; ContentType: Text)
    var
        Headers: HttpHeaders;
        BlobServiceAPIOperation: Enum "ABS Operation";
    begin
        if ContentType = '' then
            ContentType := 'application/octet-stream';

        HttpContent.GetHeaders(Headers);

        if not (ABSOperationPayload.GetOperation() in [BlobServiceAPIOperation::PutPage]) then
            ABSOperationPayload.AddContentHeader('Content-Type', ContentType);

        case BlobType of
            BlobType::PageBlob:
                begin
                    ABSOperationPayload.AddRequestHeader('x-ms-blob-content-length', StrSubstNo(ContentLengthLbl, ContentLength));
                    ABSOperationPayload.AddContentHeader('Content-Length', StrSubstNo(ContentLengthLbl, 0));
                end;
            else
                ABSOperationPayload.AddContentHeader('Content-Length', StrSubstNo(ContentLengthLbl, ContentLength));
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
        ABSOperationPayload.AddContentHeader('Content-Type', 'application/xml');
        ABSOperationPayload.AddContentHeader('Content-Length', Format(Length));
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
    local procedure GetContentLength(var SourceInStream: InStream): BigInteger
    begin
        exit(SourceInStream.Length());
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