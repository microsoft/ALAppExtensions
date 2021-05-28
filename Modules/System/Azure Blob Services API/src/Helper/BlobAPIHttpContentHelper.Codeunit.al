// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9049 "Blob API HttpContent Helper"
{
    Access = Internal;

    var
        ContentLengthLbl: Label '%1', Comment = '%1 = Length';

    procedure AddBlobPutBlockBlobContentHeaders(var Content: HttpContent; OperationObject: Codeunit "Blob API Operation Object"; var SourceStream: InStream)
    var
        BlobType: Enum "Blob Type";
    begin
        AddBlobPutContentHeaders(Content, OperationObject, SourceStream, BlobType::BlockBlob)
    end;

    procedure AddBlobPutBlockBlobContentHeaders(var Content: HttpContent; OperationObject: Codeunit "Blob API Operation Object"; SourceText: Text)
    var
        BlobType: Enum "Blob Type";
    begin
        AddBlobPutContentHeaders(Content, OperationObject, SourceText, BlobType::BlockBlob)
    end;

    procedure AddBlobPutPageBlobContentHeaders(OperationObject: Codeunit "Blob API Operation Object"; ContentLength: Integer; ContentType: Text)
    var
        BlobType: Enum "Blob Type";
        Content: HttpContent;
    begin
        if ContentLength = 0 then
            ContentLength := 512;
        AddBlobPutContentHeaders(Content, OperationObject, BlobType::PageBlob, ContentLength, ContentType)
    end;

    procedure AddBlobPutAppendBlobContentHeaders(OperationObject: Codeunit "Blob API Operation Object"; ContentType: Text)
    var
        BlobType: Enum "Blob Type";
        Content: HttpContent;
    begin
        AddBlobPutContentHeaders(Content, OperationObject, BlobType::AppendBlob, 0, ContentType)
    end;

    local procedure AddBlobPutContentHeaders(var Content: HttpContent; OperationObject: Codeunit "Blob API Operation Object"; var SourceStream: InStream; BlobType: Enum "Blob Type")
    var
        Length: Integer;
    begin
        // Do this before calling "GetContentLength", because for some reason the system errors out with "Cannot access a closed Stream."
        Content.WriteFrom(SourceStream);

        Length := GetContentLength(SourceStream);

        AddBlobPutContentHeaders(Content, OperationObject, BlobType, Length, 'application/octet-stream');
    end;

    local procedure AddBlobPutContentHeaders(var Content: HttpContent; OperationObject: Codeunit "Blob API Operation Object"; SourceText: Text; BlobType: Enum "Blob Type")
    var
        Length: Integer;
    begin
        Content.WriteFrom(SourceText);

        Length := GetContentLength(SourceText);

        AddBlobPutContentHeaders(Content, OperationObject, BlobType, Length, 'text/plain; charset=UTF-8');
    end;

    local procedure AddBlobPutContentHeaders(var Content: HttpContent; OperationObject: Codeunit "Blob API Operation Object"; BlobType: Enum "Blob Type"; ContentLength: Integer; ContentType: Text)
    var
        Headers: HttpHeaders;
        BlobServiceAPIOperation: Enum "Blob Service API Operation";
    begin
        if ContentType = '' then
            ContentType := 'application/octet-stream';
        Content.GetHeaders(Headers);
        if not (OperationObject.GetOperation() in [BlobServiceAPIOperation::PutPage]) then
            OperationObject.AddHeader(Headers, 'Content-Type', ContentType);
        case BlobType of
            BlobType::PageBlob:
                begin
                    OperationObject.AddHeader(Headers, 'x-ms-blob-content-length', StrSubstNo(ContentLengthLbl, ContentLength));
                    OperationObject.AddHeader(Headers, 'Content-Length', StrSubstNo(ContentLengthLbl, 0));
                end;
            else
                OperationObject.AddHeader(Headers, 'Content-Length', StrSubstNo(ContentLengthLbl, ContentLength));
        end;
        if not (OperationObject.GetOperation() in [BlobServiceAPIOperation::PutBlock, BlobServiceAPIOperation::PutPage, BlobServiceAPIOperation::AppendBlock]) then
            OperationObject.AddHeader(Headers, 'x-ms-blob-type', Format(BlobType));
    end;

    procedure AddServicePropertiesContent(var Content: HttpContent; var OperationObject: Codeunit "Blob API Operation Object"; Document: XmlDocument)
    begin
        AddXmlDocumentAsContent(Content, OperationObject, Document);
    end;

    procedure AddContainerAclDefinition(var Content: HttpContent; var OperationObject: Codeunit "Blob API Operation Object"; Document: XmlDocument)
    begin
        AddXmlDocumentAsContent(Content, OperationObject, Document);
    end;

    procedure AddTagsContent(var Content: HttpContent; var OperationObject: Codeunit "Blob API Operation Object"; Document: XmlDocument)
    begin
        AddXmlDocumentAsContent(Content, OperationObject, Document);
    end;

    procedure AddBlockListContent(var Content: HttpContent; var OperationObject: Codeunit "Blob API Operation Object"; Document: XmlDocument)
    begin
        AddXmlDocumentAsContent(Content, OperationObject, Document);
    end;

    procedure AddUserDelegationRequestContent(var Content: HttpContent; var OperationObject: Codeunit "Blob API Operation Object"; Document: XmlDocument)
    begin
        AddXmlDocumentAsContent(Content, OperationObject, Document);
    end;

    procedure AddQueryBlobContentRequestContent(var Content: HttpContent; var OperationObject: Codeunit "Blob API Operation Object"; Document: XmlDocument)
    begin
        AddXmlDocumentAsContent(Content, OperationObject, Document);
    end;

    local procedure AddXmlDocumentAsContent(var Content: HttpContent; var OperationObject: Codeunit "Blob API Operation Object"; Document: XmlDocument)
    var
        Headers: HttpHeaders;
        Length: Integer;
        DocumentAsText: Text;
    begin
        DocumentAsText := Format(Document);
        Length := StrLen(DocumentAsText);

        Content.WriteFrom(DocumentAsText);

        Content.GetHeaders(Headers);
        OperationObject.AddHeader(Headers, 'Content-Type', 'application/xml');
        OperationObject.AddHeader(Headers, 'Content-Length', Format(Length));
    end;

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
    local procedure GetContentLength(SourceText: Text): Integer
    var
        Length: Integer;
    begin
        Length := StrLen(SourceText);
        exit(Length);
    end;
}