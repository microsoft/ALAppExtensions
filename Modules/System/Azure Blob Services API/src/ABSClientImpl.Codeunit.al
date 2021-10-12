// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

// See: https://docs.microsoft.com/en-us/rest/api/storageservices/blob-service-rest-api
codeunit 9051 "ABS Client Impl."
{
    Access = Internal;

    var
        OperationPayload: Codeunit "ABS Operation Payload";
        BlobAPIHttpContentHelper: Codeunit "ABS HttpContent Helper";
        BlobAPIWebRequestHelper: Codeunit "ABS Web Request Helper";
        BlobAPIFormatHelper: Codeunit "ABS Format Helper";

        #region Labels
        ListContainercOperationNotSuccessfulErr: Label 'Could not list container.';
        ListBlobsContainercOperationNotSuccessfulErr: Label 'Could not list blobs for container %1.', Comment = '%1 = Container Name';
        CreateContainerOperationNotSuccessfulErr: Label 'Could not create container %1.', Comment = '%1 = Container Name';
        DeleteContainerOperationNotSuccessfulErr: Label 'Could not delete container %1.', Comment = '%1 = Container Name';
        UploadBlobOperationNotSuccessfulErr: Label 'Could not upload %1 to %2', Comment = '%1 = Blob Name; %2 = Container Name';
        DeleteBlobOperationNotSuccessfulErr: Label 'Could not %3 Blob %1 in container %2.', Comment = '%1 = Blob Name; %2 = Container Name, %3 = Delete/Undelete';
        CopyOperationNotSuccessfulErr: Label 'Could not copy %1 to %2.', Comment = '%1 = Source, %2 = Desctination';
        AppendBlockFromUrlOperationNotSuccessfulErr: Label 'Could not append block from URL %1 on %2.', Comment = '%1 = Source URI; %2 = Blob';
        TagsOperationNotSuccessfulErr: Label 'Could not %1 %2 Tags.', Comment = '%1 = Get/Set, %2 = Service/Blob, ';
        FindBlobsByTagsOperationNotSuccessfulErr: Label 'Could not find Blobs by Tags.';
        PutBlockOperationNotSuccessfulErr: Label 'Could not put block on %1.', Comment = '%1 = Blob';
        GetBlobOperationNotSuccessfulErr: Label 'Could not get Blob %1.', Comment = '%1 = Blob';
        BlockListOperationNotSuccessfulErr: Label 'Could not %2 block list on %1.', Comment = '%1 = Blob; %2 = Get/Set';
        PutBlockFromUrlOperationNotSuccessfulErr: Label 'Could not put block from URL %1 on %2.', Comment = '%1 = Source URI; %2 = Blob';
        ExpiryOperationNotSuccessfulErr: Label 'Could not set expiration on %1.', Comment = '%1 = Blob';
    #endregion

    [NonDebuggable]
    procedure Initialize(StorageAccountName: Text; ContainerName: Text; BlobName: Text; Authorization: Interface "Storage Service Authorization"; ApiVersion: Enum "Storage Service API Version")
    begin
        OperationPayload.Initialize(StorageAccountName, ContainerName, BlobName, Authorization, ApiVersion);
    end;

    procedure SetBaseUrl(BaseUrl: Text)
    begin
        OperationPayload.SetBaseUrl(BaseUrl);
    end;

    [NonDebuggable]
    procedure ListContainers(var Container: Record "ABS Container"; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        HelperLibrary: Codeunit "ABS Helper Library";
        Operation: Enum "ABS Operation";
        ResponseText: Text;
        NodeList: XmlNodeList;
    begin
        OperationPayload.SetOperation(Operation::ListContainers);
        OperationPayload.SetOptionalParameters(OptionalParameters);

        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, ResponseText, ListContainercOperationNotSuccessfulErr);

        NodeList := HelperLibrary.CreateContainerNodeListFromResponse(ResponseText);
        HelperLibrary.ContainerNodeListTotempRecord(NodeList, Container);

        exit(OperationResponse);
    end;

    #region Container operations
    procedure CreateContainer(ContainerName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
    begin
        OperationPayload.SetOperation(Operation::CreateContainer);
        OperationPayload.SetOptionalParameters(OptionalParameters);
        OperationPayload.SetContainerName(ContainerName);

        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, StrSubstNo(CreateContainerOperationNotSuccessfulErr, OperationPayload.GetContainerName()));
        exit(OperationResponse);
    end;

    procedure DeleteContainer(ContainerName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
    begin
        OperationPayload.SetOperation(Operation::DeleteContainer);
        OperationPayload.SetOptionalParameters(OptionalParameters);
        OperationPayload.SetContainerName(ContainerName);

        OperationResponse := BlobAPIWebRequestHelper.DeleteOperation(OperationPayload, StrSubstNo(DeleteContainerOperationNotSuccessfulErr, OperationPayload.GetContainerName()));

        exit(OperationResponse);
    end;

    [NonDebuggable]
    procedure ListBlobs(var ContainerContent: Record "ABS Container Content"; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        HelperLibrary: Codeunit "ABS Helper Library";
        Operation: Enum "ABS Operation";
        ResponseText: Text;
        NodeList: XmlNodeList;
    begin
        OperationPayload.SetOperation(Operation::ListBlobs);
        OperationPayload.SetOptionalParameters(OptionalParameters);

        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, ResponseText, StrSubstNo(ListBlobsContainercOperationNotSuccessfulErr, OperationPayload.GetContainerName()));

        NodeList := HelperLibrary.CreateBlobNodeListFromResponse(ResponseText);
        HelperLibrary.BlobNodeListToTempRecord(NodeList, ContainerContent);

        exit(OperationResponse);
    end;
    #endregion

    #region Blob operations
    procedure PutBlobBlockBlobUI(OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Filename: Text;
        SourceStream: InStream;
    begin
        if UploadIntoStream('*.*', SourceStream) then
            OperationResponse := PutBlobBlockBlobStream(Filename, SourceStream, OptionalParameters);

        exit(OperationResponse);
    end;

    procedure PutBlobBlockBlobStream(BlobName: Text; var SourceStream: InStream; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        SourceContent: Variant;
    begin
        SourceContent := SourceStream;

        OperationPayload.SetBlobName(BlobName);
        OperationPayload.SetOptionalParameters(OptionalParameters);

        OperationResponse := PutBlobBlockBlob(SourceContent);
        exit(OperationResponse);
    end;

    procedure PutBlobBlockBlobText(BlobName: Text; SourceText: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        SourceContent: Variant;
    begin
        OperationPayload.SetBlobName(BlobName);
        OperationPayload.SetOptionalParameters(OptionalParameters);

        SourceContent := SourceText;
        OperationResponse := PutBlobBlockBlob(SourceContent);
        exit(OperationResponse);
    end;

    local procedure PutBlobBlockBlob(var SourceContent: Variant): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
        Content: HttpContent;
        SourceStream: InStream;
        SourceText: Text;
    begin
        OperationPayload.SetOperation(Operation::PutBlob);

        case true of
            SourceContent.IsInStream():
                begin
                    SourceStream := SourceContent;
                    BlobAPIHttpContentHelper.AddBlobPutBlockBlobContentHeaders(Content, OperationPayload, SourceStream);
                end;
            SourceContent.IsText():
                begin
                    SourceText := SourceContent;
                    BlobAPIHttpContentHelper.AddBlobPutBlockBlobContentHeaders(Content, OperationPayload, SourceText);
                end;
        end;

        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, Content, StrSubstNo(UploadBlobOperationNotSuccessfulErr, OperationPayload.GetBlobName(), OperationPayload.GetContainerName()));
        exit(OperationResponse);
    end;

    procedure PutBlobPageBlob(BlobName: Text; ContentType: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
    begin
        OperationPayload.SetOperation(Operation::PutBlob);
        OperationPayload.SetOptionalParameters(OptionalParameters);
        OperationPayload.SetBlobName(BlobName);

        BlobAPIHttpContentHelper.AddBlobPutPageBlobContentHeaders(OperationPayload, 0, ContentType);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, StrSubstNo(UploadBlobOperationNotSuccessfulErr, OperationPayload.GetBlobName(), OperationPayload.GetContainerName()));

        exit(OperationResponse);
    end;

    procedure PutBlobAppendBlob(BlobName: Text; ContentType: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
    begin
        OperationPayload.SetOperation(Operation::PutBlob);
        OperationPayload.SetOptionalParameters(OptionalParameters);
        OperationPayload.SetBlobName(BlobName);

        BlobAPIHttpContentHelper.AddBlobPutAppendBlobContentHeaders(OperationPayload, ContentType);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, StrSubstNo(UploadBlobOperationNotSuccessfulErr, OperationPayload.GetBlobName(), OperationPayload.GetContainerName()));
        exit(OperationResponse);
    end;

    procedure AppendBlockText(BlobName: Text; ContentAsText: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
    begin
        OperationResponse := AppendBlockText(BlobName, ContentAsText, 'text/plain; charset=UTF-8', OptionalParameters);
        exit(OperationResponse);
    end;

    procedure AppendBlockText(BlobName: Text; ContentAsText: Text; ContentType: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
    begin
        OperationResponse := AppendBlock(BlobName, ContentType, ContentAsText, OptionalParameters);
        exit(OperationResponse);
    end;

    procedure AppendBlockStream(BlobName: Text; ContentAsStream: InStream; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
    begin
        OperationResponse := AppendBlockStream(BlobName, ContentAsStream, 'application/octet-stream', OptionalParameters);
        exit(OperationResponse);
    end;

    procedure AppendBlockStream(BlobName: Text; ContentAsStream: InStream; ContentType: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
    begin
        OperationResponse := AppendBlock(BlobName, ContentType, ContentAsStream, OptionalParameters);
        exit(OperationResponse);
    end;

    procedure AppendBlock(BlobName: Text; ContentType: Text; SourceContent: Variant; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
        Content: HttpContent;
        SourceStream: InStream;
        SourceText: Text;
    begin
        OperationPayload.SetOperation(Operation::AppendBlock);
        OperationPayload.SetOptionalParameters(OptionalParameters);
        OperationPayload.SetBlobName(BlobName);

        case true of
            SourceContent.IsInStream():
                begin
                    SourceStream := SourceContent;
                    BlobAPIHttpContentHelper.AddBlobPutBlockBlobContentHeaders(Content, OperationPayload, SourceStream);
                end;
            SourceContent.IsText():
                begin
                    SourceText := SourceContent;
                    BlobAPIHttpContentHelper.AddBlobPutBlockBlobContentHeaders(Content, OperationPayload, SourceText);
                end;
        end;

        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, Content, StrSubstNo(UploadBlobOperationNotSuccessfulErr, OperationPayload.GetBlobName(), OperationPayload.GetContainerName()));
        exit(OperationResponse);
    end;

    procedure AppendBlockFromURL(BlobName: Text; SourceUri: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
        Content: HttpContent;
    begin
        OperationPayload.SetOperation(Operation::AppendBlockFromURL);
        OperationPayload.SetOptionalParameters(OptionalParameters);
        OperationPayload.SetBlobName(BlobName);
        OperationPayload.AddContentHeader('Content-Length', '0');
        OperationPayload.AddRequestHeader('x-ms-copy-source', SourceUri);

        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, Content, StrSubstNo(AppendBlockFromUrlOperationNotSuccessfulErr, SourceUri, OperationPayload.GetBlobName()));

        exit(OperationResponse);
    end;

    procedure GetBlobAsFile(BlobName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        TargetStream: InStream;
    begin
        OperationResponse := GetBlobAsStream(BlobName, TargetStream, OptionalParameters);

        BlobName := OperationPayload.GetBlobName();
        DownloadFromStream(TargetStream, '', '', '', BlobName);
        exit(OperationResponse);
    end;

    procedure GetBlobAsStream(BlobName: Text; var TargetStream: InStream; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
    begin
        OperationPayload.SetOperation(Operation::GetBlob);
        OperationPayload.SetBlobName(BlobName);
        OperationPayload.SetOptionalParameters(OptionalParameters);

        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsStream(OperationPayload, TargetStream, StrSubstNo(GetBlobOperationNotSuccessfulErr, OperationPayload.GetBlobName()));
        exit(OperationResponse);
    end;

    procedure GetBlobAsText(BlobName: Text; var TargetText: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
    begin
        OperationPayload.SetOperation(Operation::GetBlob);
        OperationPayload.SetOptionalParameters(OptionalParameters);
        OperationPayload.SetBlobName(BlobName);

        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, TargetText, StrSubstNo(GetBlobOperationNotSuccessfulErr, OperationPayload.GetBlobName()));
        exit(OperationResponse);
    end;

    procedure SetBlobExpiryRelativeToCreation(BlobName: Text; ExpiryTime: Integer): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        ExpiryOption: Enum "ABS Blob Expiry Option";
    begin
        OperationResponse := SetBlobExpiry(BlobName, ExpiryOption::RelativeToCreation, ExpiryTime, StrSubstNo(ExpiryOperationNotSuccessfulErr, OperationPayload.GetBlobName()));
        exit(OperationResponse);
    end;

    procedure SetBlobExpiryRelativeToNow(BlobName: Text; ExpiryTime: Integer): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        ExpiryOption: Enum "ABS Blob Expiry Option";
    begin
        OperationResponse := SetBlobExpiry(BlobName, ExpiryOption::RelativeToNow, ExpiryTime, StrSubstNo(ExpiryOperationNotSuccessfulErr, OperationPayload.GetBlobName()));
        exit(OperationResponse);
    end;

    procedure SetBlobExpiryAbsolute(BlobName: Text; ExpiryTime: DateTime): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        ExpiryOption: Enum "ABS Blob Expiry Option";
    begin
        OperationResponse := SetBlobExpiry(BlobName, ExpiryOption::Absolute, ExpiryTime, StrSubstNo(ExpiryOperationNotSuccessfulErr, OperationPayload.GetBlobName()));
        exit(OperationResponse);
    end;

    procedure SetBlobExpiryNever(BlobName: Text): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        ExpiryOption: Enum "ABS Blob Expiry Option";
    begin
        OperationResponse := SetBlobExpiry(BlobName, ExpiryOption::NeverExpire, '', StrSubstNo(ExpiryOperationNotSuccessfulErr, OperationPayload.GetBlobName()));
        exit(OperationResponse);
    end;

    procedure SetBlobExpiry(BlobName: Text; ExpiryOption: Enum "ABS Blob Expiry Option"; ExpiryTime: Variant;
                                                              OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
        DateTimeValue: DateTime;
        IntegerValue: Integer;
        SpecifyMilisecondsErr: Label 'You need to specify an Integer Value (number of miliseconds) for option %1', Comment = '%1 = Expiry Option';
        SpecifyDateTimeErr: Label 'You need to specify an DateTime Value for option %1', Comment = '%1 = Expiry Option';
    begin
        OperationPayload.SetOperation(Operation::SetBlobExpiry);
        OperationPayload.SetBlobName(BlobName);
        OperationPayload.AddRequestHeader('x-ms-expiry-option', Format(ExpiryOption));

        case ExpiryOption of
            ExpiryOption::RelativeToCreation, ExpiryOption::RelativeToNow:
                if not ExpiryTime.IsInteger() then
                    Error(SpecifyMilisecondsErr, ExpiryOption);
            ExpiryOption::Absolute:
                if not ExpiryTime.IsDateTime() then
                    Error(SpecifyDateTimeErr, ExpiryOption);
        end;
        if not (ExpiryOption in [ExpiryOption::NeverExpire]) then
            case true of
                ExpiryTime.IsInteger():
                    begin
                        IntegerValue := ExpiryTime;
                        OperationPayload.AddRequestHeader('x-ms-expiry-time', Format(IntegerValue));
                    end;
                ExpiryTime.IsDateTime():
                    begin
                        DateTimeValue := ExpiryTime;
                        OperationPayload.AddRequestHeader('x-ms-expiry-time', BlobAPIFormatHelper.GetRfc1123DateTime((DateTimeValue)));
                    end;
            end;
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, OperationNotSuccessfulErr);
        exit(OperationResponse);
    end;

    procedure GetBlobTags(BlobName: Text; var BlobTags: XmlDocument; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        FormatHelper: Codeunit "ABS Format Helper";
        Operation: Enum "ABS Operation";
        ResponseText: Text;
    begin
        OperationPayload.SetOperation(Operation::GetBlobTags);
        OperationPayload.SetOptionalParameters(OptionalParameters);
        OperationPayload.SetBlobName(BlobName);

        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, ResponseText, StrSubstNo(TagsOperationNotSuccessfulErr, 'get', 'Blob'));
        BlobTags := FormatHelper.TextToXmlDocument(ResponseText);
        exit(OperationResponse);
    end;

    procedure SetBlobTags(BlobName: Text; Tags: Dictionary of [Text, Text]): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        FormatHelper: Codeunit "ABS Format Helper";
        Document: XmlDocument;
    begin
        Document := FormatHelper.TagsDictionaryToXmlDocument(Tags);
        OperationResponse := SetBlobTags(BlobName, Document);
        exit(OperationResponse);
    end;

    procedure SetBlobTags(BlobName: Text; Tags: XmlDocument): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Content: HttpContent;
        Operation: Enum "ABS Operation";
    begin
        OperationPayload.SetOperation(Operation::SetBlobTags);
        OperationPayload.SetBlobName(BlobName);

        BlobAPIHttpContentHelper.AddTagsContent(Content, OperationPayload, Tags);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, Content, StrSubstNo(TagsOperationNotSuccessfulErr, 'set', 'Blob'));
        exit(OperationResponse);
    end;

    procedure FindBlobsByTags(SearchTags: Dictionary of [Text, Text]; var FoundBlobs: XmlDocument): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        FormatHelper: Codeunit "ABS Format Helper";
    begin
        OperationResponse := FindBlobsByTags(FormatHelper.TagsDictionaryToSearchExpression(SearchTags), FoundBlobs);
        exit(OperationResponse);
    end;

    procedure FindBlobsByTags(SearchExpression: Text; var FoundBlobs: XmlDocument): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        FormatHelper: Codeunit "ABS Format Helper";
        Operation: Enum "ABS Operation";
        ResponseText: Text;
    begin
        OperationPayload.SetOperation(Operation::FindBlobByTags);
        OperationPayload.AddUriParameter('where', SearchExpression);

        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, ResponseText, FindBlobsByTagsOperationNotSuccessfulErr);

        FoundBlobs := FormatHelper.TextToXmlDocument(ResponseText);

        exit(OperationResponse);
    end;

    procedure DeleteBlob(BlobName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
    begin
        OperationPayload.SetOperation(Operation::DeleteBlob);
        OperationPayload.SetOptionalParameters(OptionalParameters);
        OperationPayload.SetBlobName(BlobName);

        OperationResponse := BlobAPIWebRequestHelper.DeleteOperation(OperationPayload, StrSubstNo(DeleteBlobOperationNotSuccessfulErr, OperationPayload.GetBlobName(), OperationPayload.GetContainerName(), 'Delete'));

        exit(OperationResponse);
    end;

    procedure UndeleteBlob(BlobName: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
    begin
        OperationPayload.SetOperation(Operation::UndeleteBlob);
        OperationPayload.SetOptionalParameters(OptionalParameters);
        OperationPayload.SetBlobName(BlobName);

        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, StrSubstNo(DeleteBlobOperationNotSuccessfulErr, OperationPayload.GetBlobName(), OperationPayload.GetContainerName(), 'Undelete'));

        exit(OperationResponse);
    end;

    procedure CopyBlob(BlobName: Text; SourceName: Text; LeaseId: Guid; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";

    begin
        OperationPayload.SetOperation(Operation::CopyBlob);
        OperationPayload.SetOptionalParameters(OptionalParameters);
        OperationPayload.SetBlobName(BlobName);
        OperationPayload.AddRequestHeader('x-ms-copy-source', SourceName);

        if not IsNullGuid(LeaseId) then
            OperationPayload.AddRequestHeader('x-ms-lease-id', BlobAPIFormatHelper.RemoveCurlyBracketsFromString(Format(LeaseId).ToLower()));

        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, StrSubstNo(CopyOperationNotSuccessfulErr, SourceName, OperationPayload.GetBlobName()));
        exit(OperationResponse);
    end;

    procedure CopyBlobFromURL(SourceUri: Text): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
    begin
        OperationPayload.SetOperation(Operation::CopyBlobFromUrl);
        OperationPayload.AddRequestHeader('x-ms-copy-source', SourceUri);
        OperationPayload.AddRequestHeader('x-ms-requires-sync', 'true');

        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, CopyOperationNotSuccessfulErr);
        exit(OperationResponse);
    end;

    procedure PutBlock(SourceContent: Variant): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        FormatHelper: Codeunit "ABS Format Helper";
    begin
        OperationResponse := PutBlock(SourceContent, FormatHelper.GetBase64BlockId());
        exit(OperationResponse);
    end;

    procedure PutBlock(SourceContent: Variant; BlockId: Text): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
        Content: HttpContent;
        SourceStream: InStream;
        SourceText: Text;
    begin
        OperationPayload.SetOperation(Operation::PutBlock);
        OperationPayload.AddUriParameter('blockid', BlockId);

        case true of
            SourceContent.IsInStream():
                begin
                    SourceStream := SourceContent;
                    BlobAPIHttpContentHelper.AddBlobPutBlockBlobContentHeaders(Content, OperationPayload, SourceStream);
                end;
            SourceContent.IsText():
                begin
                    SourceText := SourceContent;
                    BlobAPIHttpContentHelper.AddBlobPutBlockBlobContentHeaders(Content, OperationPayload, SourceText);
                end;
        end;

        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, Content, StrSubstNo(PutBlockOperationNotSuccessfulErr, OperationPayload.GetBlobName()));
        exit(OperationResponse);
    end;

    procedure GetBlockList(BlockListType: Enum "ABS Block List Type"; var CommitedBlocks: Dictionary of [Text, Integer]; var UncommitedBlocks: Dictionary of [Text, Integer]): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        HelperLibrary: Codeunit "ABS Helper Library";
        Document: XmlDocument;
    begin
        OperationResponse := GetBlockList(BlockListType, Document);
        HelperLibrary.BlockListResultToDictionary(Document, CommitedBlocks, UncommitedBlocks);
        exit(OperationResponse);
    end;

    procedure GetBlockList(var BlockList: XmlDocument): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        BlockListType: Enum "ABS Block List Type";
    begin
        OperationResponse := GetBlockList(BlockListType::committed, BlockList); // default API value is "committed"
        exit(OperationResponse);
    end;

    procedure GetBlockList(BlockListType: Enum "ABS Block List Type"; var BlockList: XmlDocument): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        FormatHelper: Codeunit "ABS Format Helper";
        Operation: Enum "ABS Operation";
        ResponseText: Text;
    begin
        OperationPayload.SetOperation(Operation::GetBlockList);
        OperationPayload.AddUriParameter('blocklisttype', Format(BlockListType));
        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, ResponseText, StrSubstNo(BlockListOperationNotSuccessfulErr, OperationPayload.GetBlobName(), 'get'));
        BlockList := FormatHelper.TextToXmlDocument(ResponseText);
        exit(OperationResponse);
    end;

    procedure PutBlockList(CommitedBlocks: Dictionary of [Text, Integer]; UncommitedBlocks: Dictionary of [Text, Integer]): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        FormatHelper: Codeunit "ABS Format Helper";
        BlockList: Dictionary of [Text, Text];
        BlockListAsXml: XmlDocument;
    begin
        FormatHelper.BlockDictionariesToBlockListDictionary(CommitedBlocks, UncommitedBlocks, BlockList, false);
        BlockListAsXml := FormatHelper.BlockListDictionaryToXmlDocument(BlockList);
        OperationResponse := PutBlockList(BlockListAsXml);
        exit(OperationResponse);
    end;

    procedure PutBlockList(BlockList: XmlDocument): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
        Content: HttpContent;
    begin
        OperationPayload.SetOperation(Operation::PutBlockList);
        BlobAPIHttpContentHelper.AddBlockListContent(Content, OperationPayload, BlockList);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, Content, StrSubstNo(BlockListOperationNotSuccessfulErr, OperationPayload.GetBlobName(), 'put'));
        exit(OperationResponse);
    end;

    procedure PutBlockFromURL(BlobName: Text; SourceUri: Text; BlockId: Text; OptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        OperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
        Content: HttpContent;
    begin
        OperationPayload.SetOperation(Operation::PutBlockFromURL);
        OperationPayload.SetOptionalParameters(OptionalParameters);
        OperationPayload.SetBlobName(BlobName);
        OperationPayload.AddRequestHeader('x-ms-copy-source', SourceUri);
        OperationPayload.AddUriParameter('blockid', BlockId);
        OperationPayload.AddContentHeader('Content-Length', '0');

        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, Content, StrSubstNo(PutBlockFromUrlOperationNotSuccessfulErr, SourceUri, OperationPayload.GetBlobName()));

        exit(OperationResponse);
    end;
    #endregion
}