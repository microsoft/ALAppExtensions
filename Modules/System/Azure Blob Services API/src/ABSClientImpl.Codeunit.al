// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

// See: https://docs.microsoft.com/en-us/rest/api/storageservices/blob-service-rest-api
codeunit 9051 "ABS Client Impl."
{
    Access = Internal;

    var
        ABSOperationPayload: Codeunit "ABS Operation Payload";
        ABSHttpContentHelper: Codeunit "ABS HttpContent Helper";
        ABSWebRequestHelper: Codeunit "ABS Web Request Helper";
        ABSFormatHelper: Codeunit "ABS Format Helper";

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
        LeaseOperationNotSuccessfulErr: Label 'Could not %1 lease for %2 %3.', Comment = '%1 = Lease Action, %2 = Type (Container or Blob), %3 = Name';
        ParameterDurationErr: Label 'Duration can be -1 (for infinite) or between 15 and 60 seconds. Parameter Value: %1', Comment = '%1 = Current Value';
        ParameterLeaseBreakDurationErr: Label 'Duration can be  between 0 and 60 seconds. Parameter Value: %1', Comment = '%1 = Current Value';
        ParameterMissingErr: Label 'You need to specify %1 (%2)', Comment = '%1 = Parameter Name, %2 = Header Identifer';
        LeaseAcquireLbl: Label 'acquire';
        LeaseBreakLbl: Label 'break';
        LeaseChangeLbl: Label 'change';
        LeaseReleaseLbl: Label 'release';
        LeaseRenewLbl: Label 'renew';
        BlobLbl: Label 'Blob';
        ContainerLbl: Label 'Container';

    #endregion 

    [NonDebuggable]
    procedure Initialize(StorageAccountName: Text; ContainerName: Text; BlobName: Text; Authorization: Interface "Storage Service Authorization"; ApiVersion: Enum "Storage Service API Version")
    begin
        ABSOperationPayload.Initialize(StorageAccountName, ContainerName, BlobName, Authorization, ApiVersion);
    end;

    procedure SetBaseUrl(BaseUrl: Text)
    begin
        ABSOperationPayload.SetBaseUrl(BaseUrl);
    end;

    [NonDebuggable]
    procedure ListContainers(var ABSContainer: Record "ABS Container"; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        ABSHelperLibrary: Codeunit "ABS Helper Library";
        Operation: Enum "ABS Operation";
        ResponseText: Text;
        NodeList: XmlNodeList;
    begin
        ABSOperationPayload.SetOperation(Operation::ListContainers);
        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);

        ABSOperationResponse := ABSWebRequestHelper.GetOperationAsText(ABSOperationPayload, ResponseText, ListContainercOperationNotSuccessfulErr);

        NodeList := ABSHelperLibrary.CreateContainerNodeListFromResponse(ResponseText);
        ABSHelperLibrary.ContainerNodeListTotempRecord(NodeList, ABSContainer);

        exit(ABSOperationResponse);
    end;

    #region Container operations
    procedure CreateContainer(ContainerName: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::CreateContainer);
        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);
        ABSOperationPayload.SetContainerName(ContainerName);

        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, StrSubstNo(CreateContainerOperationNotSuccessfulErr, ABSOperationPayload.GetContainerName()));
        exit(ABSOperationResponse);
    end;

    procedure DeleteContainer(ContainerName: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::DeleteContainer);
        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);
        ABSOperationPayload.SetContainerName(ContainerName);

        ABSOperationResponse := ABSWebRequestHelper.DeleteOperation(ABSOperationPayload, StrSubstNo(DeleteContainerOperationNotSuccessfulErr, ABSOperationPayload.GetContainerName()));

        exit(ABSOperationResponse);
    end;

    [NonDebuggable]
    procedure ListBlobs(var ABSContainerContent: Record "ABS Container Content"; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        ABSHelperLibrary: Codeunit "ABS Helper Library";
        Operation: Enum "ABS Operation";
        ResponseText: Text;
        NodeList: XmlNodeList;
    begin
        ABSOperationPayload.SetOperation(Operation::ListBlobs);
        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);

        ABSOperationResponse := ABSWebRequestHelper.GetOperationAsText(ABSOperationPayload, ResponseText, StrSubstNo(ListBlobsContainercOperationNotSuccessfulErr, ABSOperationPayload.GetContainerName()));

        NodeList := ABSHelperLibrary.CreateBlobNodeListFromResponse(ResponseText);
        ABSHelperLibrary.BlobNodeListToTempRecord(NodeList, ABSContainerContent);

        exit(ABSOperationResponse);
    end;

    procedure ContainerAcquireLease(ContainerName: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"; DurationSeconds: Integer; ProposedLeaseId: Guid; var LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::LeaseContainer);
        ABSOperationPayload.SetContainerName(ContainerName);
        exit(AcquireLease(ABSOptionalParameters, DurationSeconds, ProposedLeaseId, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, LeaseAcquireLbl, ContainerLbl, ABSOperationPayload.GetContainerName())));
    end;

    procedure ContainerReleaseLease(ContainerName: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"; LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::LeaseContainer);
        ABSOperationPayload.SetContainerName(ContainerName);
        exit(ReleaseLease(ABSOptionalParameters, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, LeaseReleaseLbl, ContainerLbl, ABSOperationPayload.GetContainerName())));
    end;

    procedure ContainerRenewLease(ContainerName: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"; LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        ABSOperation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(ABSOperation::LeaseContainer);
        ABSOperationPayload.SetContainerName(ContainerName);
        exit(RenewLease(ABSOptionalParameters, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, LeaseRenewLbl, ContainerLbl, ABSOperationPayload.GetContainerName())));
    end;

    procedure ContainerBreakLease(ContainerName: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"; LeaseId: Guid; LeaseBreakPeriod: Integer): Codeunit "ABS Operation Response"
    var
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::LeaseContainer);
        ABSOperationPayload.SetContainerName(ContainerName);
        exit(BreakLease(ABSOptionalParameters, LeaseId, LeaseBreakPeriod, StrSubstNo(LeaseOperationNotSuccessfulErr, LeaseBreakLbl, ContainerLbl, ABSOperationPayload.GetContainerName())));
    end;

    procedure ContainerChangeLease(ContainerName: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"; var LeaseId: Guid; ProposedLeaseId: Guid): Codeunit "ABS Operation Response"
    var
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::LeaseContainer);
        ABSOperationPayload.SetContainerName(ContainerName);
        exit(ChangeLease(ABSOptionalParameters, LeaseId, ProposedLeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, LeaseChangeLbl, ContainerLbl, ABSOperationPayload.GetContainerName())));
    end;
    #endregion

    #region Blob operations
    procedure PutBlobBlockBlobUI(ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Filename: Text;
        SourceInStream: InStream;
    begin
        if UploadIntoStream('', '', '', FileName, SourceInStream) then
            ABSOperationResponse := PutBlobBlockBlobStream(Filename, SourceInStream, ABSOptionalParameters);

        exit(ABSOperationResponse);
    end;

    procedure PutBlobBlockBlobStream(BlobName: Text; var SourceInStream: InStream; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        SourceContentVariant: Variant;
    begin
        SourceContentVariant := SourceInStream;

        ABSOperationPayload.SetBlobName(BlobName);
        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);

        ABSOperationResponse := PutBlobBlockBlob(SourceContentVariant);
        exit(ABSOperationResponse);
    end;

    procedure PutBlobBlockBlobText(BlobName: Text; SourceText: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        SourceContentVariant: Variant;
    begin
        ABSOperationPayload.SetBlobName(BlobName);
        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);

        SourceContentVariant := SourceText;
        ABSOperationResponse := PutBlobBlockBlob(SourceContentVariant);
        exit(ABSOperationResponse);
    end;

    local procedure PutBlobBlockBlob(var SourceContentVariant: Variant): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
        HttpContent: HttpContent;
        SourceInStream: InStream;
        SourceText: Text;
    begin
        ABSOperationPayload.SetOperation(Operation::PutBlob);

        case true of
            SourceContentVariant.IsInStream():
                begin
                    SourceInStream := SourceContentVariant;
                    ABSHttpContentHelper.AddBlobPutBlockBlobContentHeaders(HttpContent, ABSOperationPayload, SourceInStream);
                end;
            SourceContentVariant.IsText():
                begin
                    SourceText := SourceContentVariant;
                    ABSHttpContentHelper.AddBlobPutBlockBlobContentHeaders(HttpContent, ABSOperationPayload, SourceText);
                end;
        end;

        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, HttpContent, StrSubstNo(UploadBlobOperationNotSuccessfulErr, ABSOperationPayload.GetBlobName(), ABSOperationPayload.GetContainerName()));
        exit(ABSOperationResponse);
    end;

    procedure PutBlobPageBlob(BlobName: Text; ContentType: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::PutBlob);
        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);
        ABSOperationPayload.SetBlobName(BlobName);

        ABSHttpContentHelper.AddBlobPutPageBlobContentHeaders(ABSOperationPayload, 0, ContentType);
        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, StrSubstNo(UploadBlobOperationNotSuccessfulErr, ABSOperationPayload.GetBlobName(), ABSOperationPayload.GetContainerName()));

        exit(ABSOperationResponse);
    end;

    procedure PutBlobAppendBlob(BlobName: Text; ContentType: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::PutBlob);
        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);
        ABSOperationPayload.SetBlobName(BlobName);

        ABSHttpContentHelper.AddBlobPutAppendBlobContentHeaders(ABSOperationPayload, ContentType);
        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, StrSubstNo(UploadBlobOperationNotSuccessfulErr, ABSOperationPayload.GetBlobName(), ABSOperationPayload.GetContainerName()));
        exit(ABSOperationResponse);
    end;

    procedure AppendBlockText(BlobName: Text; ContentAsText: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
    begin
        ABSOperationResponse := AppendBlockText(BlobName, ContentAsText, 'text/plain; charset=UTF-8', ABSOptionalParameters);
        exit(ABSOperationResponse);
    end;

    procedure AppendBlockText(BlobName: Text; ContentAsText: Text; ContentType: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
    begin
        ABSOperationResponse := AppendBlock(BlobName, ContentType, ContentAsText, ABSOptionalParameters);
        exit(ABSOperationResponse);
    end;

    procedure AppendBlockStream(BlobName: Text; ContentAsInStream: InStream; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
    begin
        ABSOperationResponse := AppendBlockStream(BlobName, ContentAsInStream, 'application/octet-stream', ABSOptionalParameters);
        exit(ABSOperationResponse);
    end;

    procedure AppendBlockStream(BlobName: Text; ContentAsInStream: InStream; ContentType: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
    begin
        ABSOperationResponse := AppendBlock(BlobName, ContentType, ContentAsInStream, ABSOptionalParameters);
        exit(ABSOperationResponse);
    end;

    procedure AppendBlock(BlobName: Text; ContentType: Text; SourceContentVariant: Variant; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
        HttpContent: HttpContent;
        SourceInStream: InStream;
        SourceText: Text;
    begin
        ABSOperationPayload.SetOperation(Operation::AppendBlock);
        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);
        ABSOperationPayload.SetBlobName(BlobName);

        case true of
            SourceContentVariant.IsInStream():
                begin
                    SourceInStream := SourceContentVariant;
                    ABSHttpContentHelper.AddBlobPutBlockBlobContentHeaders(HttpContent, ABSOperationPayload, SourceInStream);
                end;
            SourceContentVariant.IsText():
                begin
                    SourceText := SourceContentVariant;
                    ABSHttpContentHelper.AddBlobPutBlockBlobContentHeaders(HttpContent, ABSOperationPayload, SourceText);
                end;
        end;

        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, HttpContent, StrSubstNo(UploadBlobOperationNotSuccessfulErr, ABSOperationPayload.GetBlobName(), ABSOperationPayload.GetContainerName()));
        exit(ABSOperationResponse);
    end;

    procedure AppendBlockFromURL(BlobName: Text; SourceUri: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
        HttpContent: HttpContent;
    begin
        ABSOperationPayload.SetOperation(Operation::AppendBlockFromURL);
        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);
        ABSOperationPayload.SetBlobName(BlobName);
        ABSOperationPayload.AddContentHeader('Content-Length', '0');
        ABSOperationPayload.AddRequestHeader('x-ms-copy-source', SourceUri);

        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, HttpContent, StrSubstNo(AppendBlockFromUrlOperationNotSuccessfulErr, SourceUri, ABSOperationPayload.GetBlobName()));

        exit(ABSOperationResponse);
    end;

    procedure GetBlobAsFile(BlobName: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        TargetInStream: InStream;
    begin
        ABSOperationResponse := GetBlobAsStream(BlobName, TargetInStream, ABSOptionalParameters);

        BlobName := ABSOperationPayload.GetBlobName();
        DownloadFromStream(TargetInStream, '', '', '', BlobName);
        exit(ABSOperationResponse);
    end;

    procedure GetBlobAsStream(BlobName: Text; var TargetInStream: InStream; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::GetBlob);
        ABSOperationPayload.SetBlobName(BlobName);
        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);

        ABSOperationResponse := ABSWebRequestHelper.GetOperationAsStream(ABSOperationPayload, TargetInStream, StrSubstNo(GetBlobOperationNotSuccessfulErr, ABSOperationPayload.GetBlobName()));
        exit(ABSOperationResponse);
    end;

    procedure GetBlobAsText(BlobName: Text; var TargetText: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::GetBlob);
        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);
        ABSOperationPayload.SetBlobName(BlobName);

        ABSOperationResponse := ABSWebRequestHelper.GetOperationAsText(ABSOperationPayload, TargetText, StrSubstNo(GetBlobOperationNotSuccessfulErr, ABSOperationPayload.GetBlobName()));
        exit(ABSOperationResponse);
    end;

    procedure SetBlobExpiryRelativeToCreation(BlobName: Text; ExpiryTime: Integer): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        ExpiryOption: Enum "ABS Blob Expiry Option";
    begin
        ABSOperationResponse := SetBlobExpiry(BlobName, ExpiryOption::RelativeToCreation, ExpiryTime, StrSubstNo(ExpiryOperationNotSuccessfulErr, ABSOperationPayload.GetBlobName()));
        exit(ABSOperationResponse);
    end;

    procedure SetBlobExpiryRelativeToNow(BlobName: Text; ExpiryTime: Integer): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        ExpiryOption: Enum "ABS Blob Expiry Option";
    begin
        ABSOperationResponse := SetBlobExpiry(BlobName, ExpiryOption::RelativeToNow, ExpiryTime, StrSubstNo(ExpiryOperationNotSuccessfulErr, ABSOperationPayload.GetBlobName()));
        exit(ABSOperationResponse);
    end;

    procedure SetBlobExpiryAbsolute(BlobName: Text; ExpiryTime: DateTime): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        ExpiryOption: Enum "ABS Blob Expiry Option";
    begin
        ABSOperationResponse := SetBlobExpiry(BlobName, ExpiryOption::Absolute, ExpiryTime, StrSubstNo(ExpiryOperationNotSuccessfulErr, ABSOperationPayload.GetBlobName()));
        exit(ABSOperationResponse);
    end;

    procedure SetBlobExpiryNever(BlobName: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        ExpiryOption: Enum "ABS Blob Expiry Option";
    begin
        ABSOperationResponse := SetBlobExpiry(BlobName, ExpiryOption::NeverExpire, '', StrSubstNo(ExpiryOperationNotSuccessfulErr, ABSOperationPayload.GetBlobName()));
        exit(ABSOperationResponse);
    end;

    procedure SetBlobExpiry(BlobName: Text; ExpiryOption: Enum "ABS Blob Expiry Option"; ExpiryTimeVariant: Variant;
                                                              OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
        DateTimeValue: DateTime;
        IntegerValue: Integer;
        SpecifyMilisecondsErr: Label 'You need to specify an Integer Value (number of miliseconds) for option %1', Comment = '%1 = Expiry Option';
        SpecifyDateTimeErr: Label 'You need to specify an DateTime Value for option %1', Comment = '%1 = Expiry Option';
    begin
        ABSOperationPayload.SetOperation(Operation::SetBlobExpiry);
        ABSOperationPayload.SetBlobName(BlobName);
        ABSOperationPayload.AddRequestHeader('x-ms-expiry-option', Format(ExpiryOption));

        case ExpiryOption of
            ExpiryOption::RelativeToCreation, ExpiryOption::RelativeToNow:
                if not ExpiryTimeVariant.IsInteger() then
                    Error(SpecifyMilisecondsErr, ExpiryOption);
            ExpiryOption::Absolute:
                if not ExpiryTimeVariant.IsDateTime() then
                    Error(SpecifyDateTimeErr, ExpiryOption);
        end;
        if not (ExpiryOption in [ExpiryOption::NeverExpire]) then
            case true of
                ExpiryTimeVariant.IsInteger():
                    begin
                        IntegerValue := ExpiryTimeVariant;
                        ABSOperationPayload.AddRequestHeader('x-ms-expiry-time', Format(IntegerValue));
                    end;
                ExpiryTimeVariant.IsDateTime():
                    begin
                        DateTimeValue := ExpiryTimeVariant;
                        ABSOperationPayload.AddRequestHeader('x-ms-expiry-time', ABSFormatHelper.GetRfc1123DateTime((DateTimeValue)));
                    end;
            end;
        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, OperationNotSuccessfulErr);
        exit(ABSOperationResponse);
    end;

    procedure GetBlobTags(BlobName: Text; var BlobTags: XmlDocument; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
        ResponseText: Text;
    begin
        ABSOperationPayload.SetOperation(Operation::GetBlobTags);
        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);
        ABSOperationPayload.SetBlobName(BlobName);

        ABSOperationResponse := ABSWebRequestHelper.GetOperationAsText(ABSOperationPayload, ResponseText, StrSubstNo(TagsOperationNotSuccessfulErr, 'get', BlobLbl));
        BlobTags := ABSFormatHelper.TextToXmlDocument(ResponseText);
        exit(ABSOperationResponse);
    end;

    procedure SetBlobTags(BlobName: Text; Tags: Dictionary of [Text, Text]): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Document: XmlDocument;
    begin
        Document := ABSFormatHelper.TagsDictionaryToXmlDocument(Tags);
        ABSOperationResponse := SetBlobTags(BlobName, Document);
        exit(ABSOperationResponse);
    end;

    procedure SetBlobTags(BlobName: Text; Tags: XmlDocument): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        HTTPContent: HttpContent;
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::SetBlobTags);
        ABSOperationPayload.SetBlobName(BlobName);

        ABSHttpContentHelper.AddTagsContent(HTTPContent, ABSOperationPayload, Tags);
        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, HTTPContent, StrSubstNo(TagsOperationNotSuccessfulErr, 'set', BlobLbl));
        exit(ABSOperationResponse);
    end;

    procedure FindBlobsByTags(SearchTags: Dictionary of [Text, Text]; var FoundBlobs: XmlDocument): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
    begin
        ABSOperationResponse := FindBlobsByTags(ABSFormatHelper.TagsDictionaryToSearchExpression(SearchTags), FoundBlobs);
        exit(ABSOperationResponse);
    end;

    procedure FindBlobsByTags(SearchExpression: Text; var FoundBlobs: XmlDocument): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
        ResponseText: Text;
    begin
        ABSOperationPayload.SetOperation(Operation::FindBlobByTags);
        ABSOperationPayload.AddUriParameter('where', SearchExpression);

        ABSOperationResponse := ABSWebRequestHelper.GetOperationAsText(ABSOperationPayload, ResponseText, FindBlobsByTagsOperationNotSuccessfulErr);

        FoundBlobs := ABSFormatHelper.TextToXmlDocument(ResponseText);

        exit(ABSOperationResponse);
    end;

    procedure DeleteBlob(BlobName: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::DeleteBlob);
        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);
        ABSOperationPayload.SetBlobName(BlobName);

        ABSOperationResponse := ABSWebRequestHelper.DeleteOperation(ABSOperationPayload, StrSubstNo(DeleteBlobOperationNotSuccessfulErr, ABSOperationPayload.GetBlobName(), ABSOperationPayload.GetContainerName(), 'Delete'));

        exit(ABSOperationResponse);
    end;

    procedure UndeleteBlob(BlobName: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::UndeleteBlob);
        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);
        ABSOperationPayload.SetBlobName(BlobName);

        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, StrSubstNo(DeleteBlobOperationNotSuccessfulErr, ABSOperationPayload.GetBlobName(), ABSOperationPayload.GetContainerName(), 'Undelete'));

        exit(ABSOperationResponse);
    end;

    procedure CopyBlob(BlobName: Text; SourceName: Text; LeaseId: Guid; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";

    begin
        ABSOperationPayload.SetOperation(Operation::CopyBlob);
        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);
        ABSOperationPayload.SetBlobName(BlobName);
        ABSOperationPayload.AddRequestHeader('x-ms-copy-source', SourceName);

        if not IsNullGuid(LeaseId) then
            ABSOperationPayload.AddRequestHeader('x-ms-lease-id', ABSFormatHelper.RemoveCurlyBracketsFromString(Format(LeaseId).ToLower()));

        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, StrSubstNo(CopyOperationNotSuccessfulErr, SourceName, ABSOperationPayload.GetBlobName()));
        exit(ABSOperationResponse);
    end;

    procedure CopyBlobFromURL(SourceUri: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::CopyBlobFromUrl);
        ABSOperationPayload.AddRequestHeader('x-ms-copy-source', SourceUri);
        ABSOperationPayload.AddRequestHeader('x-ms-requires-sync', 'true');

        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, CopyOperationNotSuccessfulErr);
        exit(ABSOperationResponse);
    end;

    procedure PutBlock(SourceContentVariant: Variant): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
    begin
        ABSOperationResponse := PutBlock(SourceContentVariant, ABSFormatHelper.GetBase64BlockId());
        exit(ABSOperationResponse);
    end;

    procedure PutBlock(SourceContentVariant: Variant; BlockId: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
        HttpContent: HttpContent;
        SourceInStream: InStream;
        SourceText: Text;
    begin
        ABSOperationPayload.SetOperation(Operation::PutBlock);
        ABSOperationPayload.AddUriParameter('blockid', BlockId);

        case true of
            SourceContentVariant.IsInStream():
                begin
                    SourceInStream := SourceContentVariant;
                    ABSHttpContentHelper.AddBlobPutBlockBlobContentHeaders(HttpContent, ABSOperationPayload, SourceInStream);
                end;
            SourceContentVariant.IsText():
                begin
                    SourceText := SourceContentVariant;
                    ABSHttpContentHelper.AddBlobPutBlockBlobContentHeaders(HttpContent, ABSOperationPayload, SourceText);
                end;
        end;

        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, HttpContent, StrSubstNo(PutBlockOperationNotSuccessfulErr, ABSOperationPayload.GetBlobName()));
        exit(ABSOperationResponse);
    end;

    procedure GetBlockList(BlockListType: Enum "ABS Block List Type"; var CommitedBlocks: Dictionary of [Text, Integer]; var UncommitedBlocks: Dictionary of [Text, Integer]): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        ABSHelperLibrary: Codeunit "ABS Helper Library";
        Document: XmlDocument;
    begin
        ABSOperationResponse := GetBlockList(BlockListType, Document);
        ABSHelperLibrary.BlockListResultToDictionary(Document, CommitedBlocks, UncommitedBlocks);
        exit(ABSOperationResponse);
    end;

    procedure GetBlockList(var BlockList: XmlDocument): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        BlockListType: Enum "ABS Block List Type";
    begin
        ABSOperationResponse := GetBlockList(BlockListType::committed, BlockList); // default API value is "committed"
        exit(ABSOperationResponse);
    end;

    procedure GetBlockList(BlockListType: Enum "ABS Block List Type"; var BlockList: XmlDocument): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
        ResponseText: Text;
    begin
        ABSOperationPayload.SetOperation(Operation::GetBlockList);
        ABSOperationPayload.AddUriParameter('blocklisttype', Format(BlockListType));
        ABSOperationResponse := ABSWebRequestHelper.GetOperationAsText(ABSOperationPayload, ResponseText, StrSubstNo(BlockListOperationNotSuccessfulErr, ABSOperationPayload.GetBlobName(), 'get'));
        BlockList := ABSFormatHelper.TextToXmlDocument(ResponseText);
        exit(ABSOperationResponse);
    end;

    procedure PutBlockList(CommitedBlocks: Dictionary of [Text, Integer]; UncommitedBlocks: Dictionary of [Text, Integer]): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        BlockList: Dictionary of [Text, Text];
        BlockListAsXml: XmlDocument;
    begin
        ABSFormatHelper.BlockDictionariesToBlockListDictionary(CommitedBlocks, UncommitedBlocks, BlockList, false);
        BlockListAsXml := ABSFormatHelper.BlockListDictionaryToXmlDocument(BlockList);
        ABSOperationResponse := PutBlockList(BlockListAsXml);
        exit(ABSOperationResponse);
    end;

    procedure PutBlockList(BlockList: XmlDocument): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
        HttpContent: HttpContent;
    begin
        ABSOperationPayload.SetOperation(Operation::PutBlockList);
        ABSHttpContentHelper.AddBlockListContent(HttpContent, ABSOperationPayload, BlockList);
        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, HttpContent, StrSubstNo(BlockListOperationNotSuccessfulErr, ABSOperationPayload.GetBlobName(), 'put'));
        exit(ABSOperationResponse);
    end;

    procedure PutBlockFromURL(BlobName: Text; SourceUri: Text; BlockId: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        Operation: Enum "ABS Operation";
        HttpContent: HttpContent;
    begin
        ABSOperationPayload.SetOperation(Operation::PutBlockFromURL);
        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);
        ABSOperationPayload.SetBlobName(BlobName);
        ABSOperationPayload.AddRequestHeader('x-ms-copy-source', SourceUri);
        ABSOperationPayload.AddUriParameter('blockid', BlockId);
        ABSOperationPayload.AddContentHeader('Content-Length', '0');

        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, HttpContent, StrSubstNo(PutBlockFromUrlOperationNotSuccessfulErr, SourceUri, ABSOperationPayload.GetBlobName()));

        exit(ABSOperationResponse);
    end;

    procedure BlobAcquireLease(BlobName: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"; DurationSeconds: Integer; ProposedLeaseId: Guid; var LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::LeaseBlob);
        ABSOperationPayload.SetBlobName(BlobName);
        exit(AcquireLease(ABSOptionalParameters, DurationSeconds, ProposedLeaseId, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, LeaseAcquireLbl, BlobLbl, ABSOperationPayload.GetBlobName())));
    end;

    procedure BlobReleaseLease(BlobName: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"; LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::LeaseBlob);
        ABSOperationPayload.SetBlobName(BlobName);
        exit(ReleaseLease(ABSOptionalParameters, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, LeaseReleaseLbl, BlobLbl, ABSOperationPayload.GetBlobName())));
    end;

    procedure BlobRenewLease(BlobName: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"; LeaseId: Guid): Codeunit "ABS Operation Response"
    var
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::LeaseBlob);
        ABSOperationPayload.SetBlobName(BlobName);
        exit(RenewLease(ABSOptionalParameters, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, LeaseRenewLbl, BlobLbl, ABSOperationPayload.GetBlobName())));
    end;

    procedure BlobBreakLease(BlobName: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"; LeaseId: Guid; LeaseBreakPeriod: Integer): Codeunit "ABS Operation Response"
    var
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::LeaseBlob);
        ABSOperationPayload.SetBlobName(BlobName);
        exit(BreakLease(ABSOptionalParameters, LeaseId, LeaseBreakPeriod, StrSubstNo(LeaseOperationNotSuccessfulErr, LeaseBreakLbl, BlobLbl, ABSOperationPayload.GetBlobName())));
    end;

    procedure BlobChangeLease(BlobName: Text; ABSOptionalParameters: Codeunit "ABS Optional Parameters"; var LeaseId: Guid; ProposedLeaseId: Guid): Codeunit "ABS Operation Response"
    var
        Operation: Enum "ABS Operation";
    begin
        ABSOperationPayload.SetOperation(Operation::LeaseBlob);
        ABSOperationPayload.SetBlobName(BlobName);
        exit(ChangeLease(ABSOptionalParameters, LeaseId, ProposedLeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, LeaseChangeLbl, BlobLbl, ABSOperationPayload.GetBlobName())));
    end;
    #endregion

    #region Private Lease-functions
    local procedure AcquireLease(ABSOptionalParameters: Codeunit "ABS Optional Parameters"; DurationSeconds: Integer; ProposedLeaseId: Guid; var LeaseId: Guid; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        LeaseAction: Enum "ABS Lease Action";
    begin
        // Duration can be:
        //   between 15 and 60 seconds
        //   -1 (= infinite)
        if ((((DurationSeconds < 15) or (DurationSeconds > 60))) and (DurationSeconds <> -1)) then
            Error(ParameterDurationErr, DurationSeconds);

        ABSOptionalParameters.LeaseAction(LeaseAction::Acquire);
        ABSOptionalParameters.LeaseDuration(DurationSeconds);
        if not IsNullGuid(ProposedLeaseId) then
            ABSOptionalParameters.ProposedLeaseId(ProposedLeaseId);

        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);

        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, OperationNotSuccessfulErr);
        LeaseId := ABSFormatHelper.RemoveCurlyBracketsFromString(ABSOperationResponse.GetHeaderValueFromResponseHeaders('x-ms-lease-id'));
        exit(ABSOperationResponse);
    end;

    local procedure ReleaseLease(ABSOptionalParameters: Codeunit "ABS Optional Parameters"; LeaseId: Guid; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        LeaseAction: Enum "ABS Lease Action";
    begin
        ABSOptionalParameters.LeaseAction(LeaseAction::Release);

        TestParameterSpecified(LeaseId, 'LeaseId', 'x-ms-lease-id');

        ABSOptionalParameters.LeaseId(LeaseId);

        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);

        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, OperationNotSuccessfulErr);
        exit(ABSOperationResponse);
    end;

    local procedure RenewLease(ABSOptionalParameters: Codeunit "ABS Optional Parameters"; LeaseId: Guid; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        LeaseAction: Enum "ABS Lease Action";
    begin
        ABSOptionalParameters.LeaseAction(LeaseAction::Renew);

        TestParameterSpecified(LeaseId, 'LeaseId', 'x-ms-lease-id');

        ABSOptionalParameters.LeaseId(LeaseId);

        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);

        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, OperationNotSuccessfulErr);
        exit(ABSOperationResponse);
    end;

    local procedure BreakLease(ABSOptionalParameters: Codeunit "ABS Optional Parameters"; LeaseId: Guid; LeaseBreakPeriod: Integer; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        LeaseAction: Enum "ABS Lease Action";
    begin
        if (LeaseBreakPeriod < 0) or (LeaseBreakPeriod > 60) then
            Error(ParameterLeaseBreakDurationErr, LeaseBreakPeriod);

        ABSOptionalParameters.LeaseAction(LeaseAction::Break);
        ABSOptionalParameters.LeaseBreakPeriod(LeaseBreakPeriod);

        TestParameterSpecified(LeaseId, 'LeaseId', 'x-ms-lease-id');

        ABSOptionalParameters.LeaseId(LeaseId);

        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);

        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, OperationNotSuccessfulErr);
        exit(ABSOperationResponse);
    end;

    local procedure ChangeLease(ABSOptionalParameters: Codeunit "ABS Optional Parameters"; var LeaseId: Guid; ProposedLeaseId: Guid; OperationNotSuccessfulErr: Text): Codeunit "ABS Operation Response"
    var
        ABSOperationResponse: Codeunit "ABS Operation Response";
        LeaseAction: Enum "ABS Lease Action";
    begin
        ABSOptionalParameters.LeaseAction(LeaseAction::Change);

        TestParameterSpecified(LeaseId, 'LeaseId', 'x-ms-lease-id');
        TestParameterSpecified(ProposedLeaseId, 'ProposedLeaseId', 'x-ms-proposed-lease-id');

        ABSOptionalParameters.LeaseId(LeaseId);
        ABSOptionalParameters.ProposedLeaseId(ProposedLeaseId);

        ABSOperationPayload.SetOptionalParameters(ABSOptionalParameters);

        ABSOperationResponse := ABSWebRequestHelper.PutOperation(ABSOperationPayload, OperationNotSuccessfulErr);
        LeaseId := ABSFormatHelper.RemoveCurlyBracketsFromString(ABSOperationResponse.GetHeaderValueFromResponseHeaders('x-ms-lease-id'));
        exit(ABSOperationResponse);
    end;

    local procedure TestParameterSpecified(ValueVariant: Variant; ParameterName: Text; HeaderIdentifer: Text)
    begin
        if ValueVariant.IsGuid() then
            if IsNullGuid(ValueVariant) then
                Error(ParameterMissingErr, ParameterName, HeaderIdentifer);
    end;
    #endregion
}