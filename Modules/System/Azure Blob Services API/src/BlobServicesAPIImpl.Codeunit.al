// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9041 "Blob Services API Impl."
{
    Access = Internal;

    // See: https://docs.microsoft.com/en-us/rest/api/storageservices/blob-service-rest-api
    var
        BlobAPIHttpContentHelper: Codeunit "Blob API HttpContent Helper";
        BlobAPIWebRequestHelper: Codeunit "Blob API Web Request Helper";
        BlobAPIValueHelper: Codeunit "Blob API Value Helper";
        ListContainercOperationNotSuccessfulErr: Label 'Could not list container.';
        ListBlobsContainercOperationNotSuccessfulErr: Label 'Could not list blobs for container %1.', Comment = '%1 = Container Name';
        CreateContainerOperationNotSuccessfulErr: Label 'Could not create container %1.', Comment = '%1 = Container Name';
        DeleteContainerOperationNotSuccessfulErr: Label 'Could not delete container %1.', Comment = '%1 = Container Name';
        UploadBlobOperationNotSuccessfulErr: Label 'Could not upload %1 to %2', Comment = '%1 = Blob Name; %2 = Container Name';
        DeleteBlobOperationNotSuccessfulErr: Label 'Could not %3 Blob %1 in container %2.', Comment = '%1 = Blob Name; %2 = Container Name, %3 = Delete/Undelete';
        SnapshotOperationNotSuccessfulErr: Label 'Could not create snapshot for %1.', Comment = '%1 = Blob';
        CopyOperationNotSuccessfulErr: Label 'Could not copy %1 to %2.', Comment = '%1 = Source, %2 = Desctination';
        AbortCopyOperationNotSuccessfulErr: Label 'Could not abort copy operation for %1.', Comment = '%1 = Blobname';
        AppendBlockFromUrlOperationNotSuccessfulErr: Label 'Could not append block from URL %1 on %2.', Comment = '%1 = Source URI; %2 = Blob';
        PropertiesOperationNotSuccessfulErr: Label 'Could not %1%2 Properties.', Comment = '%1 = Get/Set, %2 = Service/"", ';
        BlobServiceStatsOperationNotSuccessfulErr: Label 'Could not get Blob Service stats.';
        AccountInfoOperationNotSuccessfulErr: Label 'Could not get Account Information.';
        PreflightBlobRequestOperationNotSuccessfulErr: Label 'CORS request failed.';
        GetUserDelegationKeyOperationNotSuccessfulErr: Label 'Could not get user delegation key.';
        MetadataOperationNotSuccessfulErr: Label 'Could not %1%2 Metadata.', Comment = '%1 = Get/Set, %2 = Container/Blob, ';
        ContainerAclOperationNotSuccessfulErr: Label 'Could not %1 Container ACL.', Comment = '%1 = Get/Set ';
        LeaseOperationNotSuccessfulErr: Label 'Could not %1 lease for %2 %3.', Comment = '%1 = Lease Action, %2 = Type (Container or Blob), %3 = Name';
        ParameterDurationErr: Label 'Duration can be -1 (for infinite) or between 15 and 60 seconds. Parameter Value: %1', Comment = '%1 = Current Value';
        ParameterMissingErr: Label 'You need to specify %1 (%2)', Comment = '%1 = Variable Name, %2 = Header Identifer';
        TagsOperationNotSuccessfulErr: Label 'Could not %1%2 Tags.', Comment = '%1 = Get/Set, %2 = Service/Blob, ';
        FindBlobsByTagsOperationNotSuccessfulErr: Label 'Could not find Blobs by Tags.';
        PutBlockOperationNotSuccessfulErr: Label 'Could not put block on %1.', Comment = '%1 = Blob';
        GetBlobOperationNotSuccessfulErr: Label 'Could not get Blob %1.', Comment = '%1 = Blob';
        BlockListOperationNotSuccessfulErr: Label 'Could not %2 block list on %1.', Comment = '%1 = Blob; %2 = Get/Set';
        PutBlockFromUrlOperationNotSuccessfulErr: Label 'Could not put block from URL %1 on %2.', Comment = '%1 = Source URI; %2 = Blob';
        QueryBlobContentOperationNotSuccessfulErr: Label 'Blob Content Query request failed.';
        PutPageOperationNotSuccessfulErr: Label 'Could not put page on %1.', Comment = '%1 = Blob';
        GetPageRangeOperationNotSuccessfulErr: Label 'Could not get page range on %1.', Comment = '%1 = Blob';
        IncrementalCopyOperationNotSuccessfulErr: Label 'Could not copy from %1 to %2.', Comment = '%1 = Source; %2 = Destination';
        ExpiryOperationNotSuccessfulErr: Label 'Could not set expiration on %1.', Comment = '%1 = Blob';
        BlobTierOperationNotSuccessfulErr: Label 'Could not set tier %1 on %2.', Comment = '%1 = Tier; %2 = Blob';

    // #region temp
    procedure ListContainers(var OperationPayload: Codeunit "Blob API Operation Payload"; var Container: Record "Container") OperationResponse: Codeunit "Blob API Operation Response"
    var
        HelperLibrary: Codeunit "Blob API Helper Library";
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
        NodeList: XmlNodeList;
    begin
        OperationPayload.SetOperation(Operation::ListContainers);

        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, ResponseText, ListContainercOperationNotSuccessfulErr);

        NodeList := HelperLibrary.CreateContainerNodeListFromResponse(ResponseText);
        Container.SetBaseInfos(OperationPayload);
        HelperLibrary.ContainerNodeListTotempRecord(NodeList, Container);
    end;

    procedure CreateContainer(var OperationPayload: Codeunit "Blob API Operation Payload") OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::CreateContainer);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, StrSubstNo(CreateContainerOperationNotSuccessfulErr, OperationPayload.GetContainerName()));
    end;

    procedure DeleteContainer(var OperationPayload: Codeunit "Blob API Operation Payload") OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::DeleteContainer);
        OperationResponse := BlobAPIWebRequestHelper.DeleteOperation(OperationPayload, StrSubstNo(DeleteContainerOperationNotSuccessfulErr, OperationPayload.GetContainerName()));
    end;

    procedure PutBlobBlockBlobUI(var OperationPayload: Codeunit "Blob API Operation Payload") OperationResponse: Codeunit "Blob API Operation Response"
    var
        Filename: Text;
        SourceStream: InStream;
    begin
        if UploadIntoStream('*.*', SourceStream) then
            OperationResponse := PutBlobBlockBlobStream(OperationPayload, Filename, SourceStream);
    end;

    procedure PutBlobBlockBlobStream(var OperationPayload: Codeunit "Blob API Operation Payload"; BlobName: Text; var SourceStream: InStream) OperationResponse: Codeunit "Blob API Operation Response"
    var
        SourceContent: Variant;
    begin
        SourceContent := SourceStream;
        OperationPayload.SetBlobName(BlobName);
        OperationResponse := PutBlobBlockBlob(OperationPayload, SourceContent);
    end;

    procedure PutBlobBlockBlobText(var OperationPayload: Codeunit "Blob API Operation Payload"; BlobName: Text; SourceText: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        SourceContent: Variant;
    begin
        SourceContent := SourceText;
        OperationPayload.SetBlobName(BlobName);
        OperationResponse := PutBlobBlockBlob(OperationPayload, SourceContent);
    end;

    local procedure PutBlobBlockBlob(var OperationPayload: Codeunit "Blob API Operation Payload"; var SourceContent: Variant) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
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
    end;
    // #endregion temp
    procedure PutBlobPageBlob(var OperationPayload: Codeunit "Blob API Operation Payload"; ContentType: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::PutBlob);
        BlobAPIHttpContentHelper.AddBlobPutPageBlobContentHeaders(OperationPayload, 0, ContentType);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, StrSubstNo(UploadBlobOperationNotSuccessfulErr, OperationPayload.GetBlobName(), OperationPayload.GetContainerName()));
    end;

    procedure PutBlobAppendBlob(var OperationPayload: Codeunit "Blob API Operation Payload"; ContentType: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::PutBlob);
        BlobAPIHttpContentHelper.AddBlobPutAppendBlobContentHeaders(OperationPayload, ContentType);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, StrSubstNo(UploadBlobOperationNotSuccessfulErr, OperationPayload.GetBlobName(), OperationPayload.GetContainerName()));
    end;

    procedure AppendBlockText(var OperationPayload: Codeunit "Blob API Operation Payload"; ContentAsText: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := AppendBlockText(OperationPayload, ContentAsText, 'text/plain; charset=UTF-8');
    end;

    procedure AppendBlockText(var OperationPayload: Codeunit "Blob API Operation Payload"; ContentAsText: Text; ContentType: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := AppendBlock(OperationPayload, ContentType, ContentAsText);
    end;

    procedure AppendBlockStream(var OperationPayload: Codeunit "Blob API Operation Payload"; ContentAsStream: InStream) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := AppendBlockStream(OperationPayload, ContentAsStream, 'application/octet-stream');
    end;

    procedure AppendBlockStream(var OperationPayload: Codeunit "Blob API Operation Payload"; ContentAsStream: InStream; ContentType: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := AppendBlock(OperationPayload, ContentType, ContentAsStream);
    end;

    procedure AppendBlock(var OperationPayload: Codeunit "Blob API Operation Payload"; ContentType: Text; SourceContent: Variant) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
        SourceStream: InStream;
        SourceText: Text;
    begin
        OperationPayload.SetOperation(Operation::AppendBlock);
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
    end;

    procedure AppendBlockFromURL(var OperationPayload: Codeunit "Blob API Operation Payload"; SourceUri: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
    begin
        OperationPayload.SetOperation(Operation::AppendBlockFromURL);
        OperationPayload.AddHeader('Content-Length', '0');
        BlobAPIValueHelper.SetCopySourceNameHeader(OperationPayload, SourceUri);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, Content, StrSubstNo(AppendBlockFromUrlOperationNotSuccessfulErr, SourceUri, OperationPayload.GetBlobName()));
    end;

    procedure GetBlobServiceProperties(var OperationPayload: Codeunit "Blob API Operation Payload"; var Properties: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationPayload.SetOperation(Operation::GetBlobServiceProperties);
        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, ResponseText, StrSubstNo(PropertiesOperationNotSuccessfulErr, 'get', 'Service'));
        Properties := FormatHelper.TextToXmlDocument(ResponseText);
    end;

    procedure SetBlobServiceProperties(var OperationPayload: Codeunit "Blob API Operation Payload"; Document: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
    begin
        OperationPayload.SetOperation(Operation::SetBlobServiceProperties);
        BlobAPIHttpContentHelper.AddServicePropertiesContent(Content, OperationPayload, Document);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, Content, StrSubstNo(PropertiesOperationNotSuccessfulErr, 'set', 'Service'));
    end;

    procedure PreflightBlobRequest(var OperationPayload: Codeunit "Blob API Operation Payload"; Origin: Text; AccessControlRequestMethod: Enum "Http Request Type"; AccessControlRequestHeaders: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::PreflightBlobRequest);
        BlobAPIValueHelper.SetOriginHeader(OperationPayload, Origin);
        BlobAPIValueHelper.SetAccessControlRequestMethodHeader(OperationPayload, AccessControlRequestMethod);
        if AccessControlRequestHeaders <> '' then
            BlobAPIValueHelper.SetAccessControlRequestHeadersHeader(OperationPayload, AccessControlRequestHeaders);
        OperationResponse := BlobAPIWebRequestHelper.OptionsOperation(OperationPayload, PreflightBlobRequestOperationNotSuccessfulErr);
    end;

    procedure GetBlobServiceStats(var OperationPayload: Codeunit "Blob API Operation Payload"; var ServiceStats: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationPayload.SetOperation(Operation::GetBlobServiceStats);
        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, ResponseText, BlobServiceStatsOperationNotSuccessfulErr);
        ServiceStats := FormatHelper.TextToXmlDocument(ResponseText);
    end;

    procedure GetAccountInformation(var OperationPayload: Codeunit "Blob API Operation Payload"; var AccountInformationHeaders: HttpHeaders) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationPayload.SetOperation(Operation::GetAccountInformation);
        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, ResponseText, AccountInfoOperationNotSuccessfulErr);
        AccountInformationHeaders := OperationResponse.GetHttpResponseHeaders();
    end;

    procedure GetUserDelegationKey(var OperationPayload: Codeunit "Blob API Operation Payload"; ExpiryDateTime: DateTime; StartDateTime: DateTime; var UserDelegationKey: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
        Document: XmlDocument;
    begin
        // TODO: Think about adding a function with all details as return value (instead of only the key)
        OperationPayload.SetOperation(Operation::GetUserDelegationKey);
        Document := FormatHelper.CreateUserDelegationKeyBody(StartDateTime, ExpiryDateTime);
        BlobAPIHttpContentHelper.AddUserDelegationRequestContent(Content, OperationPayload, Document);
        OperationResponse := BlobAPIWebRequestHelper.PostOperation(OperationPayload, Content, GetUserDelegationKeyOperationNotSuccessfulErr);
        UserDelegationKey := OperationResponse.GetUserDelegationKeyFromResponse();
    end;

    procedure GetContainerProperties(var OperationPayload: Codeunit "Blob API Operation Payload"; var PropertyHeaders: HttpHeaders) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationPayload.SetOperation(Operation::GetContainerProperties);
        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, ResponseText, StrSubstNo(PropertiesOperationNotSuccessfulErr, 'get ', 'Container'));
        PropertyHeaders := OperationResponse.GetHttpResponseHeaders();
    end;

    procedure GetContainerMetadata(var OperationPayload: Codeunit "Blob API Operation Payload"; var MetadataHeaders: HttpHeaders) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationPayload.SetOperation(Operation::GetContainerMetadata);
        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, ResponseText, StrSubstNo(MetadataOperationNotSuccessfulErr, 'get', 'Container'));
        MetadataHeaders := OperationResponse.GetHttpResponseHeaders();
    end;

    procedure SetContainerMetadata(var OperationPayload: Codeunit "Blob API Operation Payload") OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::SetContainerMetadata);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, StrSubstNo(MetadataOperationNotSuccessfulErr, 'set', 'Container')); // TODO: replace with labels
    end;

    procedure GetContainerACL(var OperationPayload: Codeunit "Blob API Operation Payload"; var ContainerAcl: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationPayload.SetOperation(Operation::GetContainerAcl);
        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, ResponseText, StrSubstNo(ContainerAclOperationNotSuccessfulErr, 'get'));
        ContainerAcl := FormatHelper.TextToXmlDocument(ResponseText);
    end;

    procedure SetContainerACL(var OperationPayload: Codeunit "Blob API Operation Payload"; Document: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
    begin
        OperationPayload.SetOperation(Operation::SetContainerAcl);
        BlobAPIHttpContentHelper.AddContainerAclDefinition(Content, OperationPayload, Document);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, Content, StrSubstNo(ContainerAclOperationNotSuccessfulErr, 'set'));
    end;

    procedure ContainerLeaseAcquire(var OperationPayload: Codeunit "Blob API Operation Payload"; DurationSeconds: Integer; ProposedLeaseId: Guid; var LeaseGuid: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::LeaseContainer);
        OperationResponse := LeaseAcquire(OperationPayload, DurationSeconds, ProposedLeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'acquire', 'Container', OperationPayload.GetContainerName()), LeaseGuid);
    end;

    procedure ContainerLeaseRelease(var OperationPayload: Codeunit "Blob API Operation Payload"; LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::LeaseContainer);
        OperationResponse := LeaseRelease(OperationPayload, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'release', 'Container', OperationPayload.GetContainerName()));
    end;

    procedure ContainerLeaseRenew(var OperationPayload: Codeunit "Blob API Operation Payload"; LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::LeaseContainer);
        OperationResponse := LeaseRenew(OperationPayload, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'renew', 'Container', OperationPayload.GetContainerName()));
    end;

    procedure ContainerLeaseBreak(var OperationPayload: Codeunit "Blob API Operation Payload"; LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::LeaseContainer);
        OperationResponse := LeaseBreak(OperationPayload, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'break', 'Container', OperationPayload.GetContainerName()));
    end;

    procedure ContainerLeaseChange(var OperationPayload: Codeunit "Blob API Operation Payload"; LeaseId: Guid; ProposedLeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::LeaseContainer);
        OperationResponse := LeaseChange(OperationPayload, LeaseId, ProposedLeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'change', 'Container', OperationPayload.GetContainerName()));
    end;

    procedure BlobLeaseAcquire(var OperationPayload: Codeunit "Blob API Operation Payload"; DurationSeconds: Integer; ProposedLeaseId: Guid; var LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::LeaseBlob);
        OperationResponse := LeaseAcquire(OperationPayload, DurationSeconds, ProposedLeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'acquire', 'Blob', OperationPayload.GetBlobName()), LeaseId);
    end;

    procedure BlobLeaseRelease(var OperationPayload: Codeunit "Blob API Operation Payload"; LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::LeaseBlob);
        OperationResponse := LeaseRelease(OperationPayload, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'release', 'Blob', OperationPayload.GetBlobName()));
    end;

    procedure BlobLeaseRenew(var OperationPayload: Codeunit "Blob API Operation Payload"; LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::LeaseBlob);
        OperationResponse := LeaseRenew(OperationPayload, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'renew', 'Blob', OperationPayload.GetBlobName()));
    end;

    procedure BlobLeaseBreak(var OperationPayload: Codeunit "Blob API Operation Payload"; LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::LeaseBlob);
        OperationResponse := LeaseBreak(OperationPayload, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'break', 'Blob', OperationPayload.GetBlobName()));
    end;

    procedure BlobLeaseChange(var OperationPayload: Codeunit "Blob API Operation Payload"; LeaseId: Guid; ProposedLeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::LeaseBlob);
        OperationResponse := LeaseChange(OperationPayload, LeaseId, ProposedLeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'change', 'Blob', OperationPayload.GetBlobName()));
    end;

    local procedure LeaseAcquire(var OperationPayload: Codeunit "Blob API Operation Payload"; DurationSeconds: Integer; ProposedLeaseId: Guid; OperationNotSuccessfulErr: Text; var LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        if ((DurationSeconds > 0) and ((DurationSeconds < 15) or (DurationSeconds > 60))) xor ((DurationSeconds = -1)) then
            Error(ParameterDurationErr, DurationSeconds);
        BlobAPIValueHelper.SetLeaseActionHeader(OperationPayload, Enum::"Lease Action"::acquire);
        BlobAPIValueHelper.SetLeaseDurationHeader(OperationPayload, DurationSeconds);
        if not IsNullGuid(ProposedLeaseId) then
            BlobAPIValueHelper.SetProposedLeaseIdHeader(OperationPayload, ProposedLeaseId);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, OperationNotSuccessfulErr);
        LeaseId := OperationResponse.GetLeaseIdFromResponseHeaders();
    end;

    local procedure LeaseRelease(var OperationPayload: Codeunit "Blob API Operation Payload"; LeaseId: Guid; OperationNotSuccessfulErr: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        BlobAPIValueHelper.SetLeaseActionHeader(OperationPayload, Enum::"Lease Action"::release);
        if IsNullGuid(LeaseId) then
            Error(ParameterMissingErr, 'LeaseId', 'x-ms-lease-id');
        BlobAPIValueHelper.SetLeaseIdHeader(OperationPayload, LeaseId);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, OperationNotSuccessfulErr);
    end;

    local procedure LeaseRenew(var OperationPayload: Codeunit "Blob API Operation Payload"; LeaseId: Guid; OperationNotSuccessfulErr: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        BlobAPIValueHelper.SetLeaseActionHeader(OperationPayload, Enum::"Lease Action"::renew);
        if IsNullGuid(LeaseId) then
            Error(ParameterMissingErr, 'LeaseId', 'x-ms-lease-id');
        BlobAPIValueHelper.SetLeaseIdHeader(OperationPayload, LeaseId);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, OperationNotSuccessfulErr);
    end;

    local procedure LeaseBreak(var OperationPayload: Codeunit "Blob API Operation Payload"; LeaseId: Guid; OperationNotSuccessfulErr: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        BlobAPIValueHelper.SetLeaseActionHeader(OperationPayload, Enum::"Lease Action"::break);
        if IsNullGuid(LeaseId) then
            Error(ParameterMissingErr, 'LeaseId', 'x-ms-lease-id');
        BlobAPIValueHelper.SetLeaseIdHeader(OperationPayload, LeaseId);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, OperationNotSuccessfulErr);
    end;

    local procedure LeaseChange(var OperationPayload: Codeunit "Blob API Operation Payload"; LeaseId: Guid; ProposedLeaseId: Guid; OperationNotSuccessfulErr: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        BlobAPIValueHelper.SetLeaseActionHeader(OperationPayload, Enum::"Lease Action"::change);
        if IsNullGuid(LeaseId) then
            Error(ParameterMissingErr, 'LeaseId', 'x-ms-lease-id');
        if IsNullGuid(ProposedLeaseId) then
            Error(ParameterMissingErr, 'ProposedLeaseId', 'x-ms-proposed-lease-id');
        BlobAPIValueHelper.SetLeaseIdHeader(OperationPayload, LeaseId);
        BlobAPIValueHelper.SetProposedLeaseIdHeader(OperationPayload, ProposedLeaseId);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, OperationNotSuccessfulErr);
    end;
    // #endregion Private Lease-functions

    procedure ListBlobs(var OperationPayload: Codeunit "Blob API Operation Payload"; var ContainerContent: Record "Container Content") OperationResponse: Codeunit "Blob API Operation Response"
    var
        HelperLibrary: Codeunit "Blob API Helper Library";
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
        NodeList: XmlNodeList;
    begin
        OperationPayload.SetOperation(Operation::ListBlobs);

        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, ResponseText, StrSubstNo(ListBlobsContainercOperationNotSuccessfulErr, OperationPayload.GetContainerName()));

        NodeList := HelperLibrary.CreateBlobNodeListFromResponse(ResponseText);
        ContainerContent.SetBaseInfos(OperationPayload);
        HelperLibrary.BlobNodeListToTempRecord(NodeList, ContainerContent);
    end;

    procedure GetBlobAsFile(var OperationPayload: Codeunit "Blob API Operation Payload") OperationResponse: Codeunit "Blob API Operation Response"
    var
        BlobName: Text;
        TargetStream: InStream;
    begin
        OperationResponse := GetBlobAsStream(OperationPayload, TargetStream);
        BlobName := OperationPayload.GetBlobName();
        DownloadFromStream(TargetStream, '', '', '', BlobName);
    end;

    procedure GetBlobAsStream(var OperationPayload: Codeunit "Blob API Operation Payload"; var TargetStream: InStream) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::GetBlob);
        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsStream(OperationPayload, TargetStream, StrSubstNo(GetBlobOperationNotSuccessfulErr, OperationPayload.GetBlobName()));
    end;

    procedure GetBlobAsText(var OperationPayload: Codeunit "Blob API Operation Payload"; var TargetText: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::GetBlob);
        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, TargetText, StrSubstNo(GetBlobOperationNotSuccessfulErr, OperationPayload.GetBlobName()));
    end;

    procedure GetBlobProperties(var OperationPayload: Codeunit "Blob API Operation Payload") OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
        Response: HttpResponseMessage;
    begin
        OperationPayload.SetOperation(Operation::GetBlobProperties);
        OperationResponse := BlobAPIWebRequestHelper.HeadOperation(OperationPayload, StrSubstNo(PropertiesOperationNotSuccessfulErr, 'get', '')); // TODO: Validate
    end;

    procedure SetBlobProperties(var OperationPayload: Codeunit "Blob API Operation Payload") OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
    begin
        OperationPayload.SetOperation(Operation::SetBlobProperties);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, Content, StrSubstNo(PropertiesOperationNotSuccessfulErr, 'set', ''));
    end;

    procedure SetBlobExpiryRelativeToCreation(var OperationPayload: Codeunit "Blob API Operation Payload"; ExpiryTime: Integer) OperationResponse: Codeunit "Blob API Operation Response"
    var
        ExpiryOption: Enum "Blob Expiry Option";
    begin
        OperationResponse := SetBlobExpiry(OperationPayload, ExpiryOption::RelativeToCreation, ExpiryTime, StrSubstNo(ExpiryOperationNotSuccessfulErr, OperationPayload.GetBlobName()));
    end;

    procedure SetBlobExpiryRelativeToNow(var OperationPayload: Codeunit "Blob API Operation Payload"; ExpiryTime: Integer) OperationResponse: Codeunit "Blob API Operation Response"
    var
        ExpiryOption: Enum "Blob Expiry Option";
    begin
        OperationResponse := SetBlobExpiry(OperationPayload, ExpiryOption::RelativeToNow, ExpiryTime, StrSubstNo(ExpiryOperationNotSuccessfulErr, OperationPayload.GetBlobName()));
    end;

    procedure SetBlobExpiryAbsolute(var OperationPayload: Codeunit "Blob API Operation Payload"; ExpiryTime: DateTime) OperationResponse: Codeunit "Blob API Operation Response"
    var
        ExpiryOption: Enum "Blob Expiry Option";
    begin
        OperationResponse := SetBlobExpiry(OperationPayload, ExpiryOption::Absolute, ExpiryTime, StrSubstNo(ExpiryOperationNotSuccessfulErr, OperationPayload.GetBlobName()));
    end;

    procedure SetBlobExpiryNever(var OperationPayload: Codeunit "Blob API Operation Payload") OperationResponse: Codeunit "Blob API Operation Response"
    var
        ExpiryOption: Enum "Blob Expiry Option";
    begin
        OperationResponse := SetBlobExpiry(OperationPayload, ExpiryOption::NeverExpire, '', StrSubstNo(ExpiryOperationNotSuccessfulErr, OperationPayload.GetBlobName()));
    end;

    procedure SetBlobExpiry(var OperationPayload: Codeunit "Blob API Operation Payload"; ExpiryOption: Enum "Blob Expiry Option"; ExpiryTime: Variant; OperationNotSuccessfulErr: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
        DateTimeValue: DateTime;
        IntegerValue: Integer;
        SpecifyMilisecondsErr: Label 'You need to specify an Integer Value (number of miliseconds) for option %1', Comment = '%1 = Expiry Option';
        SpecifyDateTimeErr: Label 'You need to specify an DateTime Value for option %1', Comment = '%1 = Expiry Option';
    begin
        OperationPayload.SetOperation(Operation::SetBlobExpiry);
        BlobAPIValueHelper.SetBlobExpiryOptionHeader(OperationPayload, ExpiryOption);
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
                        BlobAPIValueHelper.SetBlobExpiryTimeHeader(OperationPayload, IntegerValue);
                    end;
                ExpiryTime.IsDateTime():
                    begin
                        DateTimeValue := ExpiryTime;
                        BlobAPIValueHelper.SetBlobExpiryTimeHeader(OperationPayload, DateTimeValue);
                    end;
            end;
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, OperationNotSuccessfulErr);
    end;

    procedure GetBlobMetadata(var OperationPayload: Codeunit "Blob API Operation Payload") OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationPayload.SetOperation(Operation::GetBlobMetadata);
        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, ResponseText, StrSubstNo(MetadataOperationNotSuccessfulErr, 'get', 'Blob'));
    end;

    procedure SetBlobMetadata(var OperationPayload: Codeunit "Blob API Operation Payload") OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::SetBlobMetadata);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, StrSubstNo(MetadataOperationNotSuccessfulErr, 'set', 'Blob'));
    end;

    procedure GetBlobTags(var OperationPayload: Codeunit "Blob API Operation Payload"; var BlobTags: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationPayload.SetOperation(Operation::GetBlobTags);
        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, ResponseText, StrSubstNo(TagsOperationNotSuccessfulErr, 'get', 'Blob'));
        BlobTags := FormatHelper.TextToXmlDocument(ResponseText);
    end;

    procedure SetBlobTags(var OperationPayload: Codeunit "Blob API Operation Payload"; Tags: Dictionary of [Text, Text]) OperationResponse: Codeunit "Blob API Operation Response"
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Document: XmlDocument;
    begin
        Document := FormatHelper.TagsDictionaryToXmlDocument(Tags);
        OperationResponse := SetBlobTags(OperationPayload, Document);
    end;

    procedure SetBlobTags(var OperationPayload: Codeunit "Blob API Operation Payload"; Tags: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Content: HttpContent;
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::SetBlobTags);
        BlobAPIHttpContentHelper.AddTagsContent(Content, OperationPayload, Tags);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, Content, StrSubstNo(TagsOperationNotSuccessfulErr, 'set', 'Blob'));
    end;

    procedure FindBlobsByTags(var OperationPayload: Codeunit "Blob API Operation Payload"; SearchTags: Dictionary of [Text, Text]; var FoundBlobs: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    var
        FormatHelper: Codeunit "Blob API Format Helper";
    begin
        OperationResponse := FindBlobsByTags(OperationPayload, FormatHelper.TagsDictionaryToSearchExpression(SearchTags), FoundBlobs);
    end;

    procedure FindBlobsByTags(var OperationPayload: Codeunit "Blob API Operation Payload"; SearchExpression: Text; var FoundBlobs: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationPayload.SetOperation(Operation::FindBlobByTags);
        OperationPayload.AddOptionalUriParameter('where', SearchExpression);
        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, ResponseText, FindBlobsByTagsOperationNotSuccessfulErr);
        FoundBlobs := FormatHelper.TextToXmlDocument(ResponseText);
    end;

    procedure DeleteBlob(var OperationPayload: Codeunit "Blob API Operation Payload") OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::DeleteBlob);
        OperationResponse := BlobAPIWebRequestHelper.DeleteOperation(OperationPayload, StrSubstNo(DeleteBlobOperationNotSuccessfulErr, OperationPayload.GetBlobName(), OperationPayload.GetContainerName(), 'Delete'));
    end;

    procedure UndeleteBlob(var OperationPayload: Codeunit "Blob API Operation Payload") OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::UndeleteBlob);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, StrSubstNo(DeleteBlobOperationNotSuccessfulErr, OperationPayload.GetBlobName(), OperationPayload.GetContainerName(), 'Undelete'));
    end;

    procedure SnapshotBlob(var OperationPayload: Codeunit "Blob API Operation Payload") OperationResponse: Codeunit "Blob API Operation Response"
    var
        Content: HttpContent;
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::SnapshotBlob);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, Content, StrSubstNo(SnapshotOperationNotSuccessfulErr, OperationPayload.GetBlobName()));
    end;

    procedure CopyBlob(var OperationPayload: Codeunit "Blob API Operation Payload"; SourceName: Text; LeaseId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::CopyBlob);
        BlobAPIValueHelper.SetCopySourceNameHeader(OperationPayload, SourceName);
        if not IsNullGuid(LeaseId) then
            BlobAPIValueHelper.SetLeaseIdHeader(OperationPayload, LeaseId);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, StrSubstNo(CopyOperationNotSuccessfulErr, SourceName, OperationPayload.GetBlobName()));
    end;

    procedure CopyBlobFromURL(var OperationPayload: Codeunit "Blob API Operation Payload"; SourceUri: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::CopyBlobFromUrl);
        BlobAPIValueHelper.SetCopySourceNameHeader(OperationPayload, SourceUri);
        BlobAPIValueHelper.SetRequiresSyncHeader(OperationPayload, true);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, CopyOperationNotSuccessfulErr);
    end;

    procedure AbortCopyBlob(var OperationPayload: Codeunit "Blob API Operation Payload"; CopyId: Guid) OperationResponse: Codeunit "Blob API Operation Response"
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::AbortCopyBlob);
        OperationPayload.AddOptionalUriParameter('copyid', FormatHelper.RemoveCurlyBracketsFromString(CopyId)); // TODO: Create overload in BlobAPIValueHelper
        BlobAPIValueHelper.SetCopyActionHeader(OperationPayload, Enum::"Copy Action"::abort);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, StrSubstNo(AbortCopyOperationNotSuccessfulErr, CopyId));
    end;

    procedure PutBlock(var OperationPayload: Codeunit "Blob API Operation Payload"; SourceContent: Variant) OperationResponse: Codeunit "Blob API Operation Response"
    var
        FormatHelper: Codeunit "Blob API Format Helper";
    begin
        OperationResponse := PutBlock(OperationPayload, SourceContent, FormatHelper.GetBase64BlockId());
    end;

    procedure PutBlock(var OperationPayload: Codeunit "Blob API Operation Payload"; SourceContent: Variant; BlockId: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
        SourceStream: InStream;
        SourceText: Text;
    begin
        OperationPayload.SetOperation(Operation::PutBlock);
        BlobAPIValueHelper.SetBlockIdParameter(OperationPayload, BlockId);
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
    end;

    procedure GetBlockList(var OperationPayload: Codeunit "Blob API Operation Payload"; BlockListType: Enum "Block List Type"; var CommitedBlocks: Dictionary of [Text, Integer]; var UncommitedBlocks: Dictionary of [Text, Integer]) OperationResponse: Codeunit "Blob API Operation Response"
    var
        HelperLibrary: Codeunit "Blob API Helper Library";
        Document: XmlDocument;
    begin
        OperationResponse := GetBlockList(OperationPayload, BlockListType, Document);
        HelperLibrary.BlockListResultToDictionary(Document, CommitedBlocks, UncommitedBlocks);
    end;

    procedure GetBlockList(var OperationPayload: Codeunit "Blob API Operation Payload"; var BlockList: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    var
        BlockListType: Enum "Block List Type";
    begin
        OperationResponse := GetBlockList(OperationPayload, BlockListType::committed, BlockList); // default API value is "committed"        
    end;

    procedure GetBlockList(var OperationPayload: Codeunit "Blob API Operation Payload"; BlockListType: Enum "Block List Type"; var BlockList: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationPayload.SetOperation(Operation::GetBlockList);
        BlobAPIValueHelper.SetBlockListTypeParameter(OperationPayload, BlockListType);
        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, ResponseText, StrSubstNo(BlockListOperationNotSuccessfulErr, OperationPayload.GetBlobName(), 'get'));
        BlockList := FormatHelper.TextToXmlDocument(ResponseText);
    end;

    procedure PutBlockList(var OperationPayload: Codeunit "Blob API Operation Payload"; CommitedBlocks: Dictionary of [Text, Integer]; UncommitedBlocks: Dictionary of [Text, Integer]) OperationResponse: Codeunit "Blob API Operation Response"
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        BlockList: Dictionary of [Text, Text];
        BlockListAsXml: XmlDocument;
    begin
        FormatHelper.BlockDictionariesToBlockListDictionary(CommitedBlocks, UncommitedBlocks, BlockList, false);
        BlockListAsXml := FormatHelper.BlockListDictionaryToXmlDocument(BlockList);
        OperationResponse := PutBlockList(OperationPayload, BlockListAsXml);
    end;

    procedure PutBlockList(var OperationPayload: Codeunit "Blob API Operation Payload"; BlockList: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
    begin
        OperationPayload.SetOperation(Operation::PutBlockList);
        BlobAPIHttpContentHelper.AddBlockListContent(Content, OperationPayload, BlockList);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, Content, StrSubstNo(BlockListOperationNotSuccessfulErr, OperationPayload.GetBlobName(), 'put'));
    end;

    procedure PutBlockFromURL(var OperationPayload: Codeunit "Blob API Operation Payload"; SourceUri: Text; BlockId: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
    begin
        OperationPayload.SetOperation(Operation::PutBlockFromURL);
        BlobAPIValueHelper.SetCopySourceNameHeader(OperationPayload, SourceUri);
        BlobAPIValueHelper.SetBlockIdParameter(OperationPayload, BlockId);
        OperationPayload.AddHeader('Content-Length', '0');
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, Content, StrSubstNo(PutBlockFromUrlOperationNotSuccessfulErr, SourceUri, OperationPayload.GetBlobName()));
    end;

    procedure QueryBlobContents(var OperationPayload: Codeunit "Blob API Operation Payload"; QueryExpression: Text; var Result: InStream) OperationResponse: Codeunit "Blob API Operation Response"
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        QueryDocument: XmlDocument;
    begin
        QueryDocument := FormatHelper.QueryExpressionToQueryBlobContent(QueryExpression);
        OperationResponse := QueryBlobContents(OperationPayload, QueryDocument, Result);
    end;

    procedure QueryBlobContents(var OperationPayload: Codeunit "Blob API Operation Payload"; QueryDocument: XmlDocument; var Result: InStream) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
    begin
        OperationPayload.SetOperation(Operation::QueryBlobContents);
        BlobAPIHttpContentHelper.AddQueryBlobContentRequestContent(Content, OperationPayload, QueryDocument);
        OperationResponse := BlobAPIWebRequestHelper.PostOperation(OperationPayload, Content, QueryBlobContentOperationNotSuccessfulErr);
        Result := OperationResponse.GetHttpResponseAsStream();
        // TODO: I don't know yet what to do with the "Avro\Binary"-result. It contains the result, but I still need to figure out how to read the format....
    end;

    procedure SetBlobTier(var OperationPayload: Codeunit "Blob API Operation Payload"; BlobAccessTier: Enum "Blob Access Tier") OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::SetBlobTier);
        BlobAPIValueHelper.SetBlobAccessTierHeader(OperationPayload, BlobAccessTier);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, StrSubstNo(BlobTierOperationNotSuccessfulErr, BlobAccessTier, OperationPayload.GetBlobName()));
    end;

    procedure PutPageUpdate(var OperationPayload: Codeunit "Blob API Operation Payload"; StartRange: Integer; EndRange: Integer; SourceContent: Variant) OperationResponse: Codeunit "Blob API Operation Response"
    var
        PageWriteOption: Enum "PageBlob Write Option";
    begin
        OperationResponse := PutPage(OperationPayload, StartRange, EndRange, SourceContent, PageWriteOption::Update);
    end;

    procedure PutPageClear(var OperationPayload: Codeunit "Blob API Operation Payload"; StartRange: Integer; EndRange: Integer) OperationResponse: Codeunit "Blob API Operation Response"
    var
        PageWriteOption: Enum "PageBlob Write Option";
    begin
        OperationResponse := PutPage(OperationPayload, StartRange, EndRange, '', PageWriteOption::Clear);
    end;

    procedure PutPage(var OperationPayload: Codeunit "Blob API Operation Payload"; StartRange: Integer; EndRange: Integer; SourceContent: Variant; PageWriteOption: Enum "PageBlob Write Option") OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
        SourceStream: InStream;
        SourceText: Text;
    begin
        OperationPayload.SetOperation(Operation::PutPage);
        BlobAPIValueHelper.SetPageWriteOptionHeader(OperationPayload, PageWriteOption);
        BlobAPIValueHelper.SetRangeHeader(OperationPayload, StartRange, EndRange);
        if PageWriteOption <> PageWriteOption::Clear then
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

        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, Content, StrSubstNo(PutPageOperationNotSuccessfulErr, OperationPayload.GetBlobName()));
    end;

    procedure PutPageFromURL(var OperationPayload: Codeunit "Blob API Operation Payload"; StartRangeSource: Integer; EndRangeSource: Integer; SourceUri: Text) OperationResponse: Codeunit "Blob API Operation Response"
    begin
        OperationResponse := PutPageFromURL(OperationPayload, StartRangeSource, EndRangeSource, StartRangeSource, EndRangeSource, SourceUri); // uses the same ranges for source and destination
    end;

    procedure PutPageFromURL(var OperationPayload: Codeunit "Blob API Operation Payload"; StartRangeSource: Integer; EndRangeSource: Integer; StartRange: Integer; EndRange: Integer; SourceUri: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
        PageWriteOption: Enum "PageBlob Write Option";
        Content: HttpContent;
        Headers: HttpHeaders;
    begin
        OperationPayload.SetOperation(Operation::PutPageFromURL);
        BlobAPIValueHelper.SetSourceRangeHeader(OperationPayload, StartRangeSource, EndRangeSource);
        BlobAPIValueHelper.SetRangeHeader(OperationPayload, StartRange, EndRange);
        BlobAPIValueHelper.SetCopySourceNameHeader(OperationPayload, SourceUri);
        BlobAPIValueHelper.SetPageWriteOptionHeader(OperationPayload, PageWriteOption::Update);    // TODO: According to documentation, this header shouldn't be needed
                                                                                                   // but it doesn't work without it. Support is informed about it and will either update docs or API
        Content.GetHeaders(Headers);
        OperationPayload.AddHeader(Headers, 'Content-Length', '0');
        OperationPayload.RemoveHeader(Headers, 'Content-Type'); // was automatically added
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, Content, StrSubstNo(PutPageOperationNotSuccessfulErr, OperationPayload.GetBlobName()));
    end;

    procedure GetPageRanges(var OperationPayload: Codeunit "Blob API Operation Payload"; var PageRanges: Dictionary of [Integer, Integer]) OperationResponse: Codeunit "Blob API Operation Response"
    var
        HelperLibrary: Codeunit "Blob API Helper Library";
        Document: XmlDocument;
    begin
        OperationResponse := GetPageRanges(OperationPayload, Document);
        HelperLibrary.PageRangesResultToDictionairy(Document, PageRanges);
    end;

    procedure GetPageRanges(var OperationPayload: Codeunit "Blob API Operation Payload"; var PageRanges: XmlDocument) OperationResponse: Codeunit "Blob API Operation Response"
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationPayload.SetOperation(Operation::GetPageRanges);
        OperationResponse := BlobAPIWebRequestHelper.GetOperationAsText(OperationPayload, ResponseText, StrSubstNo(GetPageRangeOperationNotSuccessfulErr, OperationPayload.GetBlobName()));
        PageRanges := FormatHelper.TextToXmlDocument(ResponseText);
    end;

    procedure IncrementalCopyBlob(var OperationPayload: Codeunit "Blob API Operation Payload"; SourceUri: Text) OperationResponse: Codeunit "Blob API Operation Response"
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationPayload.SetOperation(Operation::IncrementalCopyBlob);
        BlobAPIValueHelper.SetCopySourceNameHeader(OperationPayload, SourceUri);
        OperationResponse := BlobAPIWebRequestHelper.PutOperation(OperationPayload, StrSubstNo(IncrementalCopyOperationNotSuccessfulErr, SourceUri, OperationPayload.GetBlobName()));
    end;
}