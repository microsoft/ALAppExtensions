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
    procedure ListContainers(var OperationObject: Codeunit "Blob API Operation Object"; var Container: Record "Container")
    var
        HelperLibrary: Codeunit "Blob API Helper Library";
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
        NodeList: XmlNodeList;
    begin
        OperationObject.SetOperation(Operation::ListContainers);

        BlobAPIWebRequestHelper.GetOperationAsText(OperationObject, ResponseText, ListContainercOperationNotSuccessfulErr); // might throw error

        NodeList := HelperLibrary.CreateContainerNodeListFromResponse(ResponseText);
        Container.SetBaseInfos(OperationObject);
        HelperLibrary.ContainerNodeListTotempRecord(NodeList, Container);
        //if ShowOutput then
        //    HelperLibrary.ShowTempRecordLookup(Container);
    end;

    procedure CreateContainer(var OperationObject: Codeunit "Blob API Operation Object")
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::CreateContainer);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, StrSubstNo(CreateContainerOperationNotSuccessfulErr, OperationObject.GetContainerName()));
    end;

    procedure DeleteContainer(var OperationObject: Codeunit "Blob API Operation Object")
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::DeleteContainer);
        BlobAPIWebRequestHelper.DeleteOperation(OperationObject, StrSubstNo(DeleteContainerOperationNotSuccessfulErr, OperationObject.GetContainerName()));
    end;

    procedure PutBlobBlockBlobUI(var OperationObject: Codeunit "Blob API Operation Object")
    var
        Filename: Text;
        SourceStream: InStream;
    begin
        if UploadIntoStream('*.*', SourceStream) then
            PutBlobBlockBlobStream(OperationObject, Filename, SourceStream);
    end;

    procedure PutBlobBlockBlobStream(var OperationObject: Codeunit "Blob API Operation Object"; BlobName: Text; var SourceStream: InStream)
    var
        SourceContent: Variant;
    begin
        SourceContent := SourceStream;
        OperationObject.SetBlobName(BlobName);
        PutBlobBlockBlob(OperationObject, SourceContent);
    end;

    procedure PutBlobBlockBlobText(var OperationObject: Codeunit "Blob API Operation Object"; BlobName: Text; SourceText: Text)
    var
        SourceContent: Variant;
    begin
        SourceContent := SourceText;
        OperationObject.SetBlobName(BlobName);
        PutBlobBlockBlob(OperationObject, SourceContent);
    end;

    local procedure PutBlobBlockBlob(var OperationObject: Codeunit "Blob API Operation Object"; var SourceContent: Variant)
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
        SourceStream: InStream;
        SourceText: Text;
    begin
        OperationObject.SetOperation(Operation::PutBlob);

        case true of
            SourceContent.IsInStream():
                begin
                    SourceStream := SourceContent;
                    BlobAPIHttpContentHelper.AddBlobPutBlockBlobContentHeaders(Content, OperationObject, SourceStream);
                end;
            SourceContent.IsText():
                begin
                    SourceText := SourceContent;
                    BlobAPIHttpContentHelper.AddBlobPutBlockBlobContentHeaders(Content, OperationObject, SourceText);
                end;
        end;

        BlobAPIWebRequestHelper.PutOperation(OperationObject, Content, StrSubstNo(UploadBlobOperationNotSuccessfulErr, OperationObject.GetBlobName(), OperationObject.GetContainerName()));
    end;
    // #endregion temp
    procedure PutBlobPageBlob(var OperationObject: Codeunit "Blob API Operation Object"; ContentType: Text)
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::PutBlob);
        BlobAPIHttpContentHelper.AddBlobPutPageBlobContentHeaders(OperationObject, 0, ContentType);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, StrSubstNo(UploadBlobOperationNotSuccessfulErr, OperationObject.GetBlobName(), OperationObject.GetContainerName()));
    end;

    procedure PutBlobAppendBlob(var OperationObject: Codeunit "Blob API Operation Object"; ContentType: Text)
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::PutBlob);
        BlobAPIHttpContentHelper.AddBlobPutAppendBlobContentHeaders(OperationObject, ContentType);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, StrSubstNo(UploadBlobOperationNotSuccessfulErr, OperationObject.GetBlobName(), OperationObject.GetContainerName()));
    end;

    procedure AppendBlockText(var OperationObject: Codeunit "Blob API Operation Object"; ContentAsText: Text)
    begin
        AppendBlockText(OperationObject, ContentAsText, 'text/plain; charset=UTF-8');
    end;

    procedure AppendBlockText(var OperationObject: Codeunit "Blob API Operation Object"; ContentAsText: Text; ContentType: Text)
    begin
        AppendBlock(OperationObject, ContentType, ContentAsText);
    end;

    procedure AppendBlockStream(var OperationObject: Codeunit "Blob API Operation Object"; ContentAsStream: InStream)
    begin
        AppendBlockStream(OperationObject, ContentAsStream, 'application/octet-stream');
    end;

    procedure AppendBlockStream(var OperationObject: Codeunit "Blob API Operation Object"; ContentAsStream: InStream; ContentType: Text)
    begin
        AppendBlock(OperationObject, ContentType, ContentAsStream);
    end;

    procedure AppendBlock(var OperationObject: Codeunit "Blob API Operation Object"; ContentType: Text; SourceContent: Variant)
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
        //Headers: HttpHeaders;
        SourceStream: InStream;
        SourceText: Text;
    begin
        OperationObject.SetOperation(Operation::AppendBlock);
        case true of
            SourceContent.IsInStream():
                begin
                    SourceStream := SourceContent;
                    BlobAPIHttpContentHelper.AddBlobPutBlockBlobContentHeaders(Content, OperationObject, SourceStream);
                end;
            SourceContent.IsText():
                begin
                    SourceText := SourceContent;
                    BlobAPIHttpContentHelper.AddBlobPutBlockBlobContentHeaders(Content, OperationObject, SourceText);
                end;
        end;

        BlobAPIWebRequestHelper.PutOperation(OperationObject, Content, StrSubstNo(UploadBlobOperationNotSuccessfulErr, OperationObject.GetBlobName(), OperationObject.GetContainerName()));
    end;

    procedure AppendBlockFromURL(var OperationObject: Codeunit "Blob API Operation Object"; SourceUri: Text)
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
    begin
        OperationObject.SetOperation(Operation::AppendBlockFromURL);
        OperationObject.AddHeader('Content-Length', '0');
        BlobAPIValueHelper.SetCopySourceNameHeader(OperationObject, SourceUri);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, Content, StrSubstNo(AppendBlockFromUrlOperationNotSuccessfulErr, SourceUri, OperationObject.GetBlobName()));
    end;

    procedure GetBlobServiceProperties(var OperationObject: Codeunit "Blob API Operation Object"): XmlDocument
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationObject.SetOperation(Operation::GetBlobServiceProperties);
        BlobAPIWebRequestHelper.GetOperationAsText(OperationObject, ResponseText, StrSubstNo(PropertiesOperationNotSuccessfulErr, 'get', 'Service')); // might throw error
        exit(FormatHelper.TextToXmlDocument(ResponseText));
    end;

    procedure SetBlobServiceProperties(var OperationObject: Codeunit "Blob API Operation Object"; Document: XmlDocument)
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
    begin
        OperationObject.SetOperation(Operation::SetBlobServiceProperties);
        BlobAPIHttpContentHelper.AddServicePropertiesContent(Content, OperationObject, Document);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, Content, StrSubstNo(PropertiesOperationNotSuccessfulErr, 'set', 'Service'));
    end;

    procedure PreflightBlobRequest(var OperationObject: Codeunit "Blob API Operation Object"; Origin: Text; AccessControlRequestMethod: Enum "Http Request Type"; AccessControlRequestHeaders: Text)
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::PreflightBlobRequest);
        BlobAPIValueHelper.SetOriginHeader(OperationObject, Origin);
        BlobAPIValueHelper.SetAccessControlRequestMethodHeader(OperationObject, AccessControlRequestMethod);
        if AccessControlRequestHeaders <> '' then
            BlobAPIValueHelper.SetAccessControlRequestHeadersHeader(OperationObject, AccessControlRequestHeaders);
        BlobAPIWebRequestHelper.OptionsOperation(OperationObject, PreflightBlobRequestOperationNotSuccessfulErr);
    end;

    procedure GetBlobServiceStats(var OperationObject: Codeunit "Blob API Operation Object"): XmlDocument
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationObject.SetOperation(Operation::GetBlobServiceStats);
        BlobAPIWebRequestHelper.GetOperationAsText(OperationObject, ResponseText, BlobServiceStatsOperationNotSuccessfulErr); // might throw error
        exit(FormatHelper.TextToXmlDocument(ResponseText));
    end;

    procedure GetAccountInformation(var OperationObject: Codeunit "Blob API Operation Object"): HttpHeaders
    var
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationObject.SetOperation(Operation::GetAccountInformation);
        BlobAPIWebRequestHelper.GetOperationAsText(OperationObject, ResponseText, AccountInfoOperationNotSuccessfulErr); // might throw error
        exit(BlobAPIValueHelper.GetHttpResponseHeaders(OperationObject));
    end;

    procedure GetUserDelegationKey(var OperationObject: Codeunit "Blob API Operation Object"; ExpiryDateTime: DateTime; StartDateTime: DateTime): Text
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
        Document: XmlDocument;
    begin
        // TODO: Think about adding a function with all details as return value (instead of only the key)
        OperationObject.SetOperation(Operation::GetUserDelegationKey);
        Document := FormatHelper.CreateUserDelegationKeyBody(StartDateTime, ExpiryDateTime);
        BlobAPIHttpContentHelper.AddUserDelegationRequestContent(Content, OperationObject, Document);
        BlobAPIWebRequestHelper.PostOperation(OperationObject, Content, GetUserDelegationKeyOperationNotSuccessfulErr);
        exit(FormatHelper.GetUserDelegationKeyFromResponse(BlobAPIValueHelper.GetHttpResponseAsText(OperationObject)));
    end;

    procedure GetContainerProperties(var OperationObject: Codeunit "Blob API Operation Object"): HttpHeaders
    var
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationObject.SetOperation(Operation::GetContainerProperties);
        BlobAPIWebRequestHelper.GetOperationAsText(OperationObject, ResponseText, StrSubstNo(PropertiesOperationNotSuccessfulErr, 'get ', 'Container')); // might throw error
        exit(BlobAPIValueHelper.GetHttpResponseHeaders(OperationObject));
    end;

    procedure GetContainerMetadata(var OperationObject: Codeunit "Blob API Operation Object"): HttpHeaders
    var
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationObject.SetOperation(Operation::GetContainerMetadata);
        BlobAPIWebRequestHelper.GetOperationAsText(OperationObject, ResponseText, StrSubstNo(MetadataOperationNotSuccessfulErr, 'get', 'Container')); // might throw error
        exit(BlobAPIValueHelper.GetHttpResponseHeaders(OperationObject));
    end;

    procedure SetContainerMetadata(var OperationObject: Codeunit "Blob API Operation Object")
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::SetContainerMetadata);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, StrSubstNo(MetadataOperationNotSuccessfulErr, 'set', 'Container')); // TODO: replace with labels
    end;

    procedure GetContainerACL(var OperationObject: Codeunit "Blob API Operation Object"): XmlDocument
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationObject.SetOperation(Operation::GetContainerAcl);
        BlobAPIWebRequestHelper.GetOperationAsText(OperationObject, ResponseText, StrSubstNo(ContainerAclOperationNotSuccessfulErr, 'get')); // might throw error
        exit(FormatHelper.TextToXmlDocument(ResponseText));
    end;

    procedure SetContainerACL(var OperationObject: Codeunit "Blob API Operation Object"; Document: XmlDocument)
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
    begin
        OperationObject.SetOperation(Operation::SetContainerAcl);
        BlobAPIHttpContentHelper.AddContainerAclDefinition(Content, OperationObject, Document);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, Content, StrSubstNo(ContainerAclOperationNotSuccessfulErr, 'set'));
    end;

    procedure ContainerLeaseAcquire(var OperationObject: Codeunit "Blob API Operation Object"; DurationSeconds: Integer; ProposedLeaseId: Guid): Guid
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::LeaseContainer);
        exit(LeaseAcquire(OperationObject, DurationSeconds, ProposedLeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'acquire', 'Container', OperationObject.GetContainerName())));
    end;

    procedure ContainerLeaseRelease(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid)
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::LeaseContainer);
        LeaseRelease(OperationObject, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'release', 'Container', OperationObject.GetContainerName()));
    end;

    procedure ContainerLeaseRenew(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid)
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::LeaseContainer);
        LeaseRenew(OperationObject, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'renew', 'Container', OperationObject.GetContainerName()));
    end;

    procedure ContainerLeaseBreak(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid)
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::LeaseContainer);
        LeaseBreak(OperationObject, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'break', 'Container', OperationObject.GetContainerName()));
    end;

    procedure ContainerLeaseChange(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid; ProposedLeaseId: Guid)
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::LeaseContainer);
        LeaseChange(OperationObject, LeaseId, ProposedLeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'change', 'Container', OperationObject.GetContainerName()));
    end;

    procedure BlobLeaseAcquire(var OperationObject: Codeunit "Blob API Operation Object"; DurationSeconds: Integer; ProposedLeaseId: Guid): Guid
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::LeaseBlob);
        exit(LeaseAcquire(OperationObject, DurationSeconds, ProposedLeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'acquire', 'Blob', OperationObject.GetBlobName())));
    end;

    procedure BlobLeaseRelease(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid)
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::LeaseBlob);
        LeaseRelease(OperationObject, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'release', 'Blob', OperationObject.GetBlobName()));
    end;

    procedure BlobLeaseRenew(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid)
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::LeaseBlob);
        LeaseRenew(OperationObject, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'renew', 'Blob', OperationObject.GetBlobName()));
    end;

    procedure BlobLeaseBreak(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid)
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::LeaseBlob);
        LeaseBreak(OperationObject, LeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'break', 'Blob', OperationObject.GetBlobName()));
    end;

    procedure BlobLeaseChange(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid; ProposedLeaseId: Guid)
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::LeaseBlob);
        LeaseChange(OperationObject, LeaseId, ProposedLeaseId, StrSubstNo(LeaseOperationNotSuccessfulErr, 'change', 'Blob', OperationObject.GetBlobName()));
    end;

    local procedure LeaseAcquire(var OperationObject: Codeunit "Blob API Operation Object"; DurationSeconds: Integer; ProposedLeaseId: Guid; OperationNotSuccessfulErr: Text): Guid
    begin

        if ((DurationSeconds > 0) and ((DurationSeconds < 15) or (DurationSeconds > 60))) xor ((DurationSeconds = -1)) then
            Error(ParameterDurationErr, DurationSeconds);
        BlobAPIValueHelper.SetLeaseActionHeader(OperationObject, Enum::"Lease Action"::acquire);
        BlobAPIValueHelper.SetLeaseDurationHeader(OperationObject, DurationSeconds);
        if not IsNullGuid(ProposedLeaseId) then
            BlobAPIValueHelper.SetProposedLeaseIdHeader(OperationObject, ProposedLeaseId);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, OperationNotSuccessfulErr);
        exit(BlobAPIValueHelper.GetLeaseIdFromResponseHeaders(OperationObject));
    end;

    local procedure LeaseRelease(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid; OperationNotSuccessfulErr: Text)
    begin
        BlobAPIValueHelper.SetLeaseActionHeader(OperationObject, Enum::"Lease Action"::release);
        if IsNullGuid(LeaseId) then
            Error(ParameterMissingErr, 'LeaseId', 'x-ms-lease-id');
        BlobAPIValueHelper.SetLeaseIdHeader(OperationObject, LeaseId);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, OperationNotSuccessfulErr);
    end;

    local procedure LeaseRenew(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid; OperationNotSuccessfulErr: Text)
    begin
        BlobAPIValueHelper.SetLeaseActionHeader(OperationObject, Enum::"Lease Action"::renew);
        if IsNullGuid(LeaseId) then
            Error(ParameterMissingErr, 'LeaseId', 'x-ms-lease-id');
        BlobAPIValueHelper.SetLeaseIdHeader(OperationObject, LeaseId);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, OperationNotSuccessfulErr);
    end;

    local procedure LeaseBreak(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid; OperationNotSuccessfulErr: Text)
    begin
        BlobAPIValueHelper.SetLeaseActionHeader(OperationObject, Enum::"Lease Action"::break);
        if IsNullGuid(LeaseId) then
            Error(ParameterMissingErr, 'LeaseId', 'x-ms-lease-id');
        BlobAPIValueHelper.SetLeaseIdHeader(OperationObject, LeaseId);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, OperationNotSuccessfulErr);
    end;

    local procedure LeaseChange(var OperationObject: Codeunit "Blob API Operation Object"; LeaseId: Guid; ProposedLeaseId: Guid; OperationNotSuccessfulErr: Text)
    begin
        BlobAPIValueHelper.SetLeaseActionHeader(OperationObject, Enum::"Lease Action"::change);
        if IsNullGuid(LeaseId) then
            Error(ParameterMissingErr, 'LeaseId', 'x-ms-lease-id');
        if IsNullGuid(ProposedLeaseId) then
            Error(ParameterMissingErr, 'ProposedLeaseId', 'x-ms-proposed-lease-id');
        BlobAPIValueHelper.SetLeaseIdHeader(OperationObject, LeaseId);
        BlobAPIValueHelper.SetProposedLeaseIdHeader(OperationObject, ProposedLeaseId);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, OperationNotSuccessfulErr);
    end;
    // #endregion Private Lease-functions

    procedure ListBlobs(var OperationObject: Codeunit "Blob API Operation Object"; var ContainerContent: Record "Container Content")
    var
        HelperLibrary: Codeunit "Blob API Helper Library";
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
        NodeList: XmlNodeList;
    begin
        OperationObject.SetOperation(Operation::ListBlobs);

        BlobAPIWebRequestHelper.GetOperationAsText(OperationObject, ResponseText, StrSubstNo(ListBlobsContainercOperationNotSuccessfulErr, OperationObject.GetContainerName())); // might throw error

        NodeList := HelperLibrary.CreateBlobNodeListFromResponse(ResponseText);
        ContainerContent.SetBaseInfos(OperationObject);
        HelperLibrary.BlobNodeListToTempRecord(NodeList, ContainerContent);
    end;

    procedure GetBlobAsFile(var OperationObject: Codeunit "Blob API Operation Object")
    var
        BlobName: Text;
        TargetStream: InStream;
    begin
        GetBlobAsStream(OperationObject, TargetStream);
        BlobName := OperationObject.GetBlobName();
        DownloadFromStream(TargetStream, '', '', '', BlobName);
    end;

    procedure GetBlobAsStream(var OperationObject: Codeunit "Blob API Operation Object"; var TargetStream: InStream)
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::GetBlob);
        BlobAPIWebRequestHelper.GetOperationAsStream(OperationObject, TargetStream, StrSubstNo(GetBlobOperationNotSuccessfulErr, OperationObject.GetBlobName()));
    end;

    procedure GetBlobAsText(var OperationObject: Codeunit "Blob API Operation Object"; var TargetText: Text)
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::GetBlob);
        BlobAPIWebRequestHelper.GetOperationAsText(OperationObject, TargetText, StrSubstNo(GetBlobOperationNotSuccessfulErr, OperationObject.GetBlobName()));
    end;

    procedure GetBlobProperties(var OperationObject: Codeunit "Blob API Operation Object")
    var
        Operation: Enum "Blob Service API Operation";
        Response: HttpResponseMessage;
    begin
        OperationObject.SetOperation(Operation::GetBlobProperties);
        BlobAPIWebRequestHelper.HeadOperation(OperationObject, Response, StrSubstNo(PropertiesOperationNotSuccessfulErr, 'get', '')); // TODO: Validate
    end;

    procedure SetBlobProperties(var OperationObject: Codeunit "Blob API Operation Object")
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
    begin
        OperationObject.SetOperation(Operation::SetBlobProperties);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, Content, StrSubstNo(PropertiesOperationNotSuccessfulErr, 'set', ''));
    end;

    procedure SetBlobExpiryRelativeToCreation(var OperationObject: Codeunit "Blob API Operation Object"; ExpiryTime: Integer)
    var
        ExpiryOption: Enum "Blob Expiry Option";
    begin
        SetBlobExpiry(OperationObject, ExpiryOption::RelativeToCreation, ExpiryTime, StrSubstNo(ExpiryOperationNotSuccessfulErr, OperationObject.GetBlobName()));
    end;

    procedure SetBlobExpiryRelativeToNow(var OperationObject: Codeunit "Blob API Operation Object"; ExpiryTime: Integer)
    var
        ExpiryOption: Enum "Blob Expiry Option";
    begin
        SetBlobExpiry(OperationObject, ExpiryOption::RelativeToNow, ExpiryTime, StrSubstNo(ExpiryOperationNotSuccessfulErr, OperationObject.GetBlobName()));
    end;

    procedure SetBlobExpiryAbsolute(var OperationObject: Codeunit "Blob API Operation Object"; ExpiryTime: DateTime)
    var
        ExpiryOption: Enum "Blob Expiry Option";
    begin
        SetBlobExpiry(OperationObject, ExpiryOption::Absolute, ExpiryTime, StrSubstNo(ExpiryOperationNotSuccessfulErr, OperationObject.GetBlobName()));
    end;

    procedure SetBlobExpiryNever(var OperationObject: Codeunit "Blob API Operation Object")
    var
        ExpiryOption: Enum "Blob Expiry Option";
    begin
        SetBlobExpiry(OperationObject, ExpiryOption::NeverExpire, '', StrSubstNo(ExpiryOperationNotSuccessfulErr, OperationObject.GetBlobName()));
    end;

    procedure SetBlobExpiry(var OperationObject: Codeunit "Blob API Operation Object"; ExpiryOption: Enum "Blob Expiry Option"; ExpiryTime: Variant; OperationNotSuccessfulErr: Text)
    var
        Operation: Enum "Blob Service API Operation";
        DateTimeValue: DateTime;
        IntegerValue: Integer;
        SpecifyMilisecondsErr: Label 'You need to specify an Integer Value (number of miliseconds) for option %1', Comment = '%1 = Expiry Option';
        SpecifyDateTimeErr: Label 'You need to specify an DateTime Value for option %1', Comment = '%1 = Expiry Option';
    begin
        OperationObject.SetOperation(Operation::SetBlobExpiry);
        BlobAPIValueHelper.SetBlobExpiryOptionHeader(OperationObject, ExpiryOption);
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
                        BlobAPIValueHelper.SetBlobExpiryTimeHeader(OperationObject, IntegerValue);
                    end;
                ExpiryTime.IsDateTime():
                    begin
                        DateTimeValue := ExpiryTime;
                        BlobAPIValueHelper.SetBlobExpiryTimeHeader(OperationObject, DateTimeValue);
                    end;
            end;
        BlobAPIWebRequestHelper.PutOperation(OperationObject, OperationNotSuccessfulErr);
    end;

    procedure GetBlobMetadata(var OperationObject: Codeunit "Blob API Operation Object")
    var
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationObject.SetOperation(Operation::GetBlobMetadata);
        BlobAPIWebRequestHelper.GetOperationAsText(OperationObject, ResponseText, StrSubstNo(MetadataOperationNotSuccessfulErr, 'get', 'Blob')); // might throw error
    end;

    procedure SetBlobMetadata(var OperationObject: Codeunit "Blob API Operation Object")
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::SetBlobMetadata);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, StrSubstNo(MetadataOperationNotSuccessfulErr, 'set', 'Blob'));
    end;

    procedure GetBlobTags(var OperationObject: Codeunit "Blob API Operation Object"): XmlDocument
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationObject.SetOperation(Operation::GetBlobTags);
        BlobAPIWebRequestHelper.GetOperationAsText(OperationObject, ResponseText, StrSubstNo(TagsOperationNotSuccessfulErr, 'get', 'Blob')); // might throw error
        exit(FormatHelper.TextToXmlDocument(ResponseText));
    end;

    procedure SetBlobTags(var OperationObject: Codeunit "Blob API Operation Object"; Tags: Dictionary of [Text, Text])
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Document: XmlDocument;
    begin
        Document := FormatHelper.TagsDictionaryToXmlDocument(Tags);
        SetBlobTags(OperationObject, Document);
    end;

    procedure SetBlobTags(var OperationObject: Codeunit "Blob API Operation Object"; Tags: XmlDocument)
    var
        Content: HttpContent;
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::SetBlobTags);
        BlobAPIHttpContentHelper.AddTagsContent(Content, OperationObject, Tags);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, Content, StrSubstNo(TagsOperationNotSuccessfulErr, 'set', 'Blob'));
    end;

    procedure FindBlobsByTags(var OperationObject: Codeunit "Blob API Operation Object"; SearchTags: Dictionary of [Text, Text]): XmlDocument
    var
        FormatHelper: Codeunit "Blob API Format Helper";
    begin
        exit(FindBlobsByTags(OperationObject, FormatHelper.TagsDictionaryToSearchExpression(SearchTags)));
    end;

    procedure FindBlobsByTags(var OperationObject: Codeunit "Blob API Operation Object"; SearchExpression: Text): XmlDocument
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationObject.SetOperation(Operation::FindBlobByTags);
        OperationObject.AddOptionalUriParameter('where', SearchExpression);
        BlobAPIWebRequestHelper.GetOperationAsText(OperationObject, ResponseText, FindBlobsByTagsOperationNotSuccessfulErr); // might throw error
        exit(FormatHelper.TextToXmlDocument(ResponseText));
    end;

    procedure DeleteBlob(var OperationObject: Codeunit "Blob API Operation Object")
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::DeleteBlob);
        BlobAPIWebRequestHelper.DeleteOperation(OperationObject, StrSubstNo(DeleteBlobOperationNotSuccessfulErr, OperationObject.GetBlobName(), OperationObject.GetContainerName(), 'Delete'));
    end;

    procedure UndeleteBlob(var OperationObject: Codeunit "Blob API Operation Object")
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::UndeleteBlob);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, StrSubstNo(DeleteBlobOperationNotSuccessfulErr, OperationObject.GetBlobName(), OperationObject.GetContainerName(), 'Undelete'));
    end;

    procedure SnapshotBlob(var OperationObject: Codeunit "Blob API Operation Object")
    var
        Content: HttpContent;
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::SnapshotBlob);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, Content, StrSubstNo(SnapshotOperationNotSuccessfulErr, OperationObject.GetBlobName()));
    end;

    procedure CopyBlob(var OperationObject: Codeunit "Blob API Operation Object"; SourceName: Text; LeaseId: Guid)
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::CopyBlob);
        BlobAPIValueHelper.SetCopySourceNameHeader(OperationObject, SourceName);
        if not IsNullGuid(LeaseId) then
            BlobAPIValueHelper.SetLeaseIdHeader(OperationObject, LeaseId);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, StrSubstNo(CopyOperationNotSuccessfulErr, SourceName, OperationObject.GetBlobName()));
    end;

    procedure CopyBlobFromURL(var OperationObject: Codeunit "Blob API Operation Object"; SourceUri: Text)
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::CopyBlobFromUrl);
        BlobAPIValueHelper.SetCopySourceNameHeader(OperationObject, SourceUri);
        BlobAPIValueHelper.SetRequiresSyncHeader(OperationObject, true);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, CopyOperationNotSuccessfulErr);
    end;

    procedure AbortCopyBlob(var OperationObject: Codeunit "Blob API Operation Object"; CopyId: Guid)
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::AbortCopyBlob);
        OperationObject.AddOptionalUriParameter('copyid', FormatHelper.RemoveCurlyBracketsFromString(CopyId)); // TODO: Create overload in BlobAPIValueHelper
        BlobAPIValueHelper.SetCopyActionHeader(OperationObject, Enum::"Copy Action"::abort);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, StrSubstNo(AbortCopyOperationNotSuccessfulErr, CopyId));
    end;

    procedure PutBlock(var OperationObject: Codeunit "Blob API Operation Object"; SourceContent: Variant)
    var
        FormatHelper: Codeunit "Blob API Format Helper";
    begin
        PutBlock(OperationObject, SourceContent, FormatHelper.GetBase64BlockId());
    end;

    procedure PutBlock(var OperationObject: Codeunit "Blob API Operation Object"; SourceContent: Variant; BlockId: Text)
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
        SourceStream: InStream;
        SourceText: Text;
    begin
        OperationObject.SetOperation(Operation::PutBlock);
        BlobAPIValueHelper.SetBlockIdParameter(OperationObject, BlockId);
        case true of
            SourceContent.IsInStream():
                begin
                    SourceStream := SourceContent;
                    BlobAPIHttpContentHelper.AddBlobPutBlockBlobContentHeaders(Content, OperationObject, SourceStream);
                end;
            SourceContent.IsText():
                begin
                    SourceText := SourceContent;
                    BlobAPIHttpContentHelper.AddBlobPutBlockBlobContentHeaders(Content, OperationObject, SourceText);
                end;
        end;

        BlobAPIWebRequestHelper.PutOperation(OperationObject, Content, StrSubstNo(PutBlockOperationNotSuccessfulErr, OperationObject.GetBlobName()));
    end;

    procedure GetBlockList(var OperationObject: Codeunit "Blob API Operation Object"; BlockListType: Enum "Block List Type"; var CommitedBlocks: Dictionary of [Text, Integer]; var UncommitedBlocks: Dictionary of [Text, Integer])
    var
        HelperLibrary: Codeunit "Blob API Helper Library";
        Document: XmlDocument;
    begin
        Document := GetBlockList(OperationObject, BlockListType);
        HelperLibrary.BlockListResultToDictionary(Document, CommitedBlocks, UncommitedBlocks);
    end;

    procedure GetBlockList(var OperationObject: Codeunit "Blob API Operation Object"): XmlDocument
    var
        BlockListType: Enum "Block List Type";
    begin
        exit(GetBlockList(OperationObject, BlockListType::committed)); // default API value is "committed"
    end;

    procedure GetBlockList(var OperationObject: Codeunit "Blob API Operation Object"; BlockListType: Enum "Block List Type"): XmlDocument
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationObject.SetOperation(Operation::GetBlockList);
        BlobAPIValueHelper.SetBlockListTypeParameter(OperationObject, BlockListType);
        BlobAPIWebRequestHelper.GetOperationAsText(OperationObject, ResponseText, StrSubstNo(BlockListOperationNotSuccessfulErr, OperationObject.GetBlobName(), 'get')); // might throw error
        exit(FormatHelper.TextToXmlDocument(ResponseText));
    end;

    procedure PutBlockList(var OperationObject: Codeunit "Blob API Operation Object"; CommitedBlocks: Dictionary of [Text, Integer]; UncommitedBlocks: Dictionary of [Text, Integer])
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        BlockList: Dictionary of [Text, Text];
        BlockListAsXml: XmlDocument;
    begin
        FormatHelper.BlockDictionariesToBlockListDictionary(CommitedBlocks, UncommitedBlocks, BlockList, false);
        BlockListAsXml := FormatHelper.BlockListDictionaryToXmlDocument(BlockList);
        PutBlockList(OperationObject, BlockListAsXml);
    end;

    procedure PutBlockList(var OperationObject: Codeunit "Blob API Operation Object"; BlockList: XmlDocument)
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
    begin
        OperationObject.SetOperation(Operation::PutBlockList);
        BlobAPIHttpContentHelper.AddBlockListContent(Content, OperationObject, BlockList);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, Content, StrSubstNo(BlockListOperationNotSuccessfulErr, OperationObject.GetBlobName(), 'put'));
    end;

    procedure PutBlockFromURL(var OperationObject: Codeunit "Blob API Operation Object"; SourceUri: Text; BlockId: Text)
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
    begin
        OperationObject.SetOperation(Operation::PutBlockFromURL);
        BlobAPIValueHelper.SetCopySourceNameHeader(OperationObject, SourceUri);
        BlobAPIValueHelper.SetBlockIdParameter(OperationObject, BlockId);
        OperationObject.AddHeader('Content-Length', '0');
        BlobAPIWebRequestHelper.PutOperation(OperationObject, Content, StrSubstNo(PutBlockFromUrlOperationNotSuccessfulErr, SourceUri, OperationObject.GetBlobName()));
    end;

    procedure QueryBlobContents(var OperationObject: Codeunit "Blob API Operation Object"; QueryExpression: Text; var Result: InStream)
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        QueryDocument: XmlDocument;
    begin
        QueryDocument := FormatHelper.QueryExpressionToQueryBlobContent(QueryExpression);
        QueryBlobContents(OperationObject, QueryDocument, Result);
    end;

    procedure QueryBlobContents(var OperationObject: Codeunit "Blob API Operation Object"; QueryDocument: XmlDocument; var Result: InStream)
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
    begin
        OperationObject.SetOperation(Operation::QueryBlobContents);
        BlobAPIHttpContentHelper.AddQueryBlobContentRequestContent(Content, OperationObject, QueryDocument);
        BlobAPIWebRequestHelper.PostOperation(OperationObject, Content, QueryBlobContentOperationNotSuccessfulErr);
        BlobAPIValueHelper.GetHttpResponseAsStream(OperationObject, Result);
        // TODO: I don't know yet what to do with the "Avro\Binary"-result. It contains the result, but I still need to figure out how to read the format....
    end;

    procedure SetBlobTier(var OperationObject: Codeunit "Blob API Operation Object"; BlobAccessTier: Enum "Blob Access Tier")
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::SetBlobTier);
        BlobAPIValueHelper.SetBlobAccessTierHeader(OperationObject, BlobAccessTier);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, StrSubstNo(BlobTierOperationNotSuccessfulErr, BlobAccessTier, OperationObject.GetBlobName()));
    end;

    procedure PutPageUpdate(var OperationObject: Codeunit "Blob API Operation Object"; StartRange: Integer; EndRange: Integer; SourceContent: Variant)
    var
        PageWriteOption: Enum "PageBlob Write Option";
    begin
        PutPage(OperationObject, StartRange, EndRange, SourceContent, PageWriteOption::Update);
    end;

    procedure PutPageClear(var OperationObject: Codeunit "Blob API Operation Object"; StartRange: Integer; EndRange: Integer)
    var
        PageWriteOption: Enum "PageBlob Write Option";
    begin
        PutPage(OperationObject, StartRange, EndRange, '', PageWriteOption::Clear);
    end;

    procedure PutPage(var OperationObject: Codeunit "Blob API Operation Object"; StartRange: Integer; EndRange: Integer; SourceContent: Variant; PageWriteOption: Enum "PageBlob Write Option")
    var
        Operation: Enum "Blob Service API Operation";
        Content: HttpContent;
        //Headers: HttpHeaders;
        SourceStream: InStream;
        SourceText: Text;
    begin
        OperationObject.SetOperation(Operation::PutPage);
        BlobAPIValueHelper.SetPageWriteOptionHeader(OperationObject, PageWriteOption);
        BlobAPIValueHelper.SetRangeHeader(OperationObject, StartRange, EndRange);
        if PageWriteOption <> PageWriteOption::Clear then
            case true of
                SourceContent.IsInStream():
                    begin
                        SourceStream := SourceContent;
                        BlobAPIHttpContentHelper.AddBlobPutBlockBlobContentHeaders(Content, OperationObject, SourceStream);
                    end;
                SourceContent.IsText():
                    begin
                        SourceText := SourceContent;
                        BlobAPIHttpContentHelper.AddBlobPutBlockBlobContentHeaders(Content, OperationObject, SourceText);
                    end;
            end;

        BlobAPIWebRequestHelper.PutOperation(OperationObject, Content, StrSubstNo(PutPageOperationNotSuccessfulErr, OperationObject.GetBlobName()));
    end;

    procedure PutPageFromURL(var OperationObject: Codeunit "Blob API Operation Object"; StartRangeSource: Integer; EndRangeSource: Integer; SourceUri: Text)
    begin
        PutPageFromURL(OperationObject, StartRangeSource, EndRangeSource, StartRangeSource, EndRangeSource, SourceUri); // uses the same ranges for source and destination
    end;

    procedure PutPageFromURL(var OperationObject: Codeunit "Blob API Operation Object"; StartRangeSource: Integer; EndRangeSource: Integer; StartRange: Integer; EndRange: Integer; SourceUri: Text)
    var
        Operation: Enum "Blob Service API Operation";
        PageWriteOption: Enum "PageBlob Write Option";
        Content: HttpContent;
        Headers: HttpHeaders;
    begin
        OperationObject.SetOperation(Operation::PutPageFromURL);
        BlobAPIValueHelper.SetSourceRangeHeader(OperationObject, StartRangeSource, EndRangeSource);
        BlobAPIValueHelper.SetRangeHeader(OperationObject, StartRange, EndRange);
        BlobAPIValueHelper.SetCopySourceNameHeader(OperationObject, SourceUri);
        BlobAPIValueHelper.SetPageWriteOptionHeader(OperationObject, PageWriteOption::Update);    // TODO: According to documentation, this header shouldn't be needed
                                                                                                  // but it doesn't work without it. Support is informed about it and will either update docs or API
        Content.GetHeaders(Headers);
        OperationObject.AddHeader(Headers, 'Content-Length', '0');
        OperationObject.RemoveHeader(Headers, 'Content-Type'); // was automatically added
        BlobAPIWebRequestHelper.PutOperation(OperationObject, Content, StrSubstNo(PutPageOperationNotSuccessfulErr, OperationObject.GetBlobName()));
    end;

    procedure GetPageRanges(var OperationObject: Codeunit "Blob API Operation Object"; var PageRanges: Dictionary of [Integer, Integer])
    var
        HelperLibrary: Codeunit "Blob API Helper Library";
        Document: XmlDocument;
    begin
        Document := GetPageRanges(OperationObject);
        HelperLibrary.PageRangesResultToDictionairy(Document, PageRanges);
    end;

    procedure GetPageRanges(var OperationObject: Codeunit "Blob API Operation Object"): XmlDocument
    var
        FormatHelper: Codeunit "Blob API Format Helper";
        Operation: Enum "Blob Service API Operation";
        ResponseText: Text;
    begin
        OperationObject.SetOperation(Operation::GetPageRanges);
        BlobAPIWebRequestHelper.GetOperationAsText(OperationObject, ResponseText, StrSubstNo(GetPageRangeOperationNotSuccessfulErr, OperationObject.GetBlobName())); // might throw error
        exit(FormatHelper.TextToXmlDocument(ResponseText));
    end;

    procedure IncrementalCopyBlob(var OperationObject: Codeunit "Blob API Operation Object"; SourceUri: Text)
    var
        Operation: Enum "Blob Service API Operation";
    begin
        OperationObject.SetOperation(Operation::IncrementalCopyBlob);
        BlobAPIValueHelper.SetCopySourceNameHeader(OperationObject, SourceUri);
        BlobAPIWebRequestHelper.PutOperation(OperationObject, StrSubstNo(IncrementalCopyOperationNotSuccessfulErr, SourceUri, OperationObject.GetBlobName()));
    end;
}