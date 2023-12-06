namespace System.DataAdministration;

using Microsoft.EServices.EDocument;
using System.Azure.Storage;
using System.Environment;
using System.Reflection;
using System.Telemetry;
using System.Text;
using System.Azure.KeyVault;

codeunit 6205 "Transaction Storage ABS"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Transact. Storage Task Entry" = r,
                  tabledata "Transact. Storage Table Entry" = rm,
                  tabledata "Table Metadata" = r,
                  tabledata "Incoming Document Attachment" = r,
                  tabledata "ABS Container" = ri;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TransactionStorageTok: Label 'Transaction Storage', Locked = true;
        PutBlobBlockForTableTok: Label 'Put blob block for table %1 with name %2', Comment = '%1 - table id, %2 - blob name';
        SetExpirationDateForTableTok: Label 'Set expiration date for table %1', Comment = '%1 - table id';
        SetExpirationDateForIncomDocTok: Label 'Set expiration date for incoming document %1', Comment = '%1 - incoming document file name';
        ExportOfIncomingDocTok: Label 'Export of incoming document %1 with name %2', Comment = '%1 - incoming document file name, %2 - blob name';
        ExportedDocCountTxt: Label 'Export of incoming documents completed. Collected %1 documents, exported %2 documents', Comment = '%1 - collected documents count, %2 - exported documents count';
        ExportedTablesCountTxt: Label 'Export of tables completed. Collected %1 tables, exported %2 tables', Comment = '%1 - collected tables count, %2 - exported tables count';
        BlobFolderNameTxt: Label '%1/%2', Comment = '%1 - company folder name, %2 - date folder name';
        JsonBlobNameTxt: Label '%1/%2.json', Comment = '%1 - blob folder name, %2 - table name';
        IncomingDocBlobNameTxt: Label '%1/%2-%3.%4', Comment = '%1 - blob folder name, %2 - incoming document entry no., %3 - incoming document name, %4 - incoming document extension';
        CannotGetStorageNameFromKeyVaultTxt: Label 'Cannot get storage account name from Azure Key Vault using key %1', Locked = true;
        CannotGetListOfContainersTxt: Label 'Cannot get list of containers', Locked = true;
        StorageAccountNameBlankTxt: Label 'Storage account name is blank', Locked = true;
        StorageAccountAccessKeyBlankTxt: Label 'Storage account access key is blank', Locked = true;
        TransactStorageNameAKVSecretKeyTok: Label 'TransactionStorageAzureBlobStorageName', Locked = true;
        TransactStorageNameAKVSecretKeyForTestTok: Label 'TransactionStorageTestAzureBlobStorageName', Locked = true;
        TransactStorageAccessKeyAKVSecretKeyTok: Label 'TransactionStorageAzureBlobStorageAccessKey', Locked = true;
        TransactStorageAccessKeyAKVSecretKeyForTestTok: Label 'TransactionStorageTestAzureBlobStorageAccessKey', Locked = true;

    [NonDebuggable]
    procedure ArchiveTransactionsToABS(DataJsonArrays: Dictionary of [Integer, JsonArray]; IncomingDocs: Dictionary of [Text, Integer]; TransactStorageTaskEntry: Record "Transact. Storage Task Entry")
    var
        ABSContainerClient: Codeunit "ABS Container Client";
        ABSBlobClient: Codeunit "ABS Blob Client";
        Authorization: Interface "Storage Service Authorization";
        StorageAccountName: Text;
        ContainerName: Text;
        CurrentDate: Date;
    begin
        Authorization := GetABSAuthorization();
        StorageAccountName := GetStorageAccountNameFromKeyVault();
        ABSContainerClient.Initialize(StorageAccountName, Authorization);
        ContainerName := InitializeContainer(ABSContainerClient);
        ABSBlobClient.Initialize(StorageAccountName, ContainerName, Authorization);
        CurrentDate := Today();
        WriteJsonBlobsToABS(DataJsonArrays, ABSBlobClient, CurrentDate, TransactStorageTaskEntry."Starting Date/Time");
        WriteIncomingDocumentsToABS(IncomingDocs, ABSBlobClient, CurrentDate);
        FeatureTelemetry.LogUsage('0000LQ4', TransactionStorageTok, 'Exported to ABS');
    end;

    [NonDebuggable]
    local procedure WriteJsonBlobsToABS(DataJsonArrays: Dictionary of [Integer, JsonArray]; ABSBlobClient: Codeunit "ABS Blob Client"; CurrentDate: Date; TaskStartingDateTime: DateTime)
    var
        TableMetadata: Record "Table Metadata";
        TransactStorageTableEntry: Record "Transact. Storage Table Entry";
        ABSOperationResponse: Codeunit "ABS Operation Response";
        StringConversionManagement: Codeunit StringConversionManagement;
        TableDataJsonArray: JsonArray;
        TableNumber: Integer;
        ExportedTableCount: Integer;
        BlobFolder: Text;
        BlobName: Text;
        JsonData: Text;
        BlobExpirationDateTime: DateTime;
    begin
        BlobFolder := GetBlobFolder(CurrentDate);
        BlobExpirationDateTime := GetBlobExpirationDateTime(CurrentDate);
        foreach TableNumber in DataJsonArrays.Keys() do begin
            TableDataJsonArray := DataJsonArrays.Get(TableNumber);
            TableDataJsonArray.WriteTo(JsonData);
            TableMetadata.Get(TableNumber);
            BlobName := StrSubstNo(JsonBlobNameTxt, BlobFolder, StringConversionManagement.RemoveNonAlphaNumericCharacters(TableMetadata.Name));
            ABSOperationResponse := ABSBlobClient.PutBlobBlockBlobText(BlobName, JsonData);
            HandleABSOperationResponse(ABSOperationResponse, StrSubstNo(PutBlobBlockForTableTok, TableNumber, BlobName));
            if ABSOperationResponse.IsSuccessful() then
                ExportedTableCount += 1;
            ABSBlobClient.SetBlobExpiryAbsolute(BlobName, BlobExpirationDateTime);
            HandleABSOperationResponse(ABSOperationResponse, StrSubstNo(SetExpirationDateForTableTok, TableNumber));

            if TransactStorageTableEntry.Get(TableNumber) then begin
                TransactStorageTableEntry."Exported To ABS" := true;
                TransactStorageTableEntry."Blob Name in ABS" := CopyStr(BlobName, 1, MaxStrLen(TransactStorageTableEntry."Blob Name in ABS"));
                TransactStorageTableEntry."Last Handled Date/Time" := TaskStartingDateTime;
                TransactStorageTableEntry.Modify();
            end;
        end;
        FeatureTelemetry.LogUsage('0000LQ6', TransactionStorageTok, StrSubstNo(ExportedTablesCountTxt, DataJsonArrays.Count(), ExportedTableCount))
    end;

    [NonDebuggable]
    local procedure WriteIncomingDocumentsToABS(IncomingDocs: Dictionary of [Text, Integer]; ABSBlobClient: Codeunit "ABS Blob Client"; CurrentDate: Date)
    var
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        ABSOperationResponse: Codeunit "ABS Operation Response";
        IncomingDocKey: Text;
        BlobFolder: Text;
        BlobName: Text;
        IncomingDocEntryNo: Integer;
        ExportedDocCount: Integer;
        BlobExpirationDateTime: DateTime;
        BlobInStream: InStream;
    begin
        BlobFolder := GetBlobFolder(CurrentDate);
        BlobExpirationDateTime := GetBlobExpirationDateTime(CurrentDate);
        foreach IncomingDocKey in IncomingDocs.Keys() do begin
            IncomingDocEntryNo := IncomingDocs.Get(IncomingDocKey);
            IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDocEntryNo);
            if IncomingDocumentAttachment.FindSet() then
                repeat
                    IncomingDocumentAttachment.CalcFields(Content);
                    if IncomingDocumentAttachment.Content.HasValue() then begin
                        IncomingDocumentAttachment.Content.CreateInStream(BlobInStream);
                        BlobName := StrSubstNo(IncomingDocBlobNameTxt, BlobFolder, IncomingDocKey, IncomingDocumentAttachment.Name, IncomingDocumentAttachment."File Extension");
                        ABSOperationResponse := ABSBlobClient.PutBlobBlockBlobStream(BlobName, BlobInStream);
                        HandleABSOperationResponse(ABSOperationResponse, StrSubstNo(ExportOfIncomingDocTok, IncomingDocumentAttachment.Name, BlobName));
                        if ABSOperationResponse.IsSuccessful() then
                            ExportedDocCount += 1;
                        ABSBlobClient.SetBlobExpiryAbsolute(BlobName, BlobExpirationDateTime);
                        HandleABSOperationResponse(ABSOperationResponse, StrSubstNo(SetExpirationDateForIncomDocTok, IncomingDocumentAttachment.Name));
                    end;
                until IncomingDocumentAttachment.Next() = 0;
        end;
        FeatureTelemetry.LogUsage('0000LT3', TransactionStorageTok, StrSubstNo(ExportedDocCountTxt, IncomingDocs.Count(), ExportedDocCount));
    end;

    [NonDebuggable]
    local procedure GetBlobFolder(CurrentDate: Date): Text
    var
        CompanyFolderName: Text;
        DateFolderName: Text;
    begin
        CompanyFolderName := DelChr(CompanyName(), '=', './\');
        DateFolderName := Format(CurrentDate, 0, '<Year4><Month,2><Day,2>');
        exit(StrSubstNo(BlobFolderNameTxt, CompanyFolderName, DateFolderName));
    end;

    local procedure GetBlobExpirationDateTime(CurrentDate: Date): DateTime
    var
        ExpirationDate: Date;
        ExpirationTime: Time;
    begin
        ExpirationDate := CalcDate('<+5Y + 1D>', CurrentDate);
        ExpirationTime := 0T;
        exit(CreateDateTime(ExpirationDate, ExpirationTime));
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    local procedure GetABSAuthorization(): Interface "Storage Service Authorization"
    var
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        StorageAccessKey: Text;
    begin
        StorageAccessKey := GetStorageAccountAccessKeyFromKeyVault();
        exit(StorageServiceAuthorization.CreateSharedKey(StorageAccessKey));
    end;

    [NonDebuggable]
    local procedure InitializeContainer(ABSContainerClient: Codeunit "ABS Container Client") ContainerName: Text
    var
        ABSContainer: Record "ABS Container";
        ABSOperationResponse: Codeunit "ABS Operation Response";
    begin
        ABSOperationResponse := ABSContainerClient.ListContainers(ABSContainer);
        if ABSOperationResponse.IsSuccessful() then begin
            ContainerName := GetTenantId();
            if not ABSContainer.Get(ContainerName) then
                ABSContainerClient.CreateContainer(ContainerName);
        end else begin
            FeatureTelemetry.LogError('0000LQ5', TransactionStorageTok, '', CannotGetListOfContainersTxt);
            Error(ABSOperationResponse.GetError());
        end;
    end;

    [NonDebuggable]
    local procedure HandleABSOperationResponse(ABSOperationResponse: Codeunit "ABS Operation Response"; ActionText: Text)
    begin
        if not ABSOperationResponse.IsSuccessful() then begin
            FeatureTelemetry.LogError('0000LQ7', TransactionStorageTok, '', ActionText + ' failed');
            Error(ABSOperationResponse.GetError());
        end;
    end;

    [NonDebuggable]
    local procedure GetTenantId(): Text
    var
        TenantInformation: Codeunit "Tenant Information";
    begin
        exit(TenantInformation.GetTenantId());
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    local procedure GetStorageAccountNameFromKeyVault() StorageAccountName: Text
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        AKVSecretKey: Text;
        IsHandled: Boolean;
    begin
        AKVSecretKey := TransactStorageNameAKVSecretKeyTok;
        OnBeforeGetStorageAccountNameFromKeyVault(IsHandled);
        if IsHandled then
            AKVSecretKey := TransactStorageNameAKVSecretKeyForTestTok;

        if not AzureKeyVault.GetAzureKeyVaultSecret(AKVSecretKey, StorageAccountName) then begin
            FeatureTelemetry.LogError('0000LSZ', TransactionStorageTok, '', StrSubstNo(CannotGetStorageNameFromKeyVaultTxt, AKVSecretKey));
            Error(CannotGetStorageNameFromKeyVaultTxt, AKVSecretKey);
        end;

        if StorageAccountName = '' then begin
            FeatureTelemetry.LogError('0000LT0', TransactionStorageTok, '', StorageAccountNameBlankTxt);
            Error(StorageAccountNameBlankTxt);
        end;
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    local procedure GetStorageAccountAccessKeyFromKeyVault() StorageAccessKey: Text
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        AKVSecretKey: Text;
        IsHandled: Boolean;
    begin
        AKVSecretKey := TransactStorageAccessKeyAKVSecretKeyTok;
        OnBeforeGetStorageAccountAccessKeyFromKeyVault(IsHandled);
        if IsHandled then
            AKVSecretKey := TransactStorageAccessKeyAKVSecretKeyForTestTok;

        if not AzureKeyVault.GetAzureKeyVaultSecret(AKVSecretKey, StorageAccessKey) then begin
            FeatureTelemetry.LogError('0000LT1', TransactionStorageTok, '', StrSubstNo(CannotGetStorageNameFromKeyVaultTxt, AKVSecretKey));
            Error(CannotGetStorageNameFromKeyVaultTxt, AKVSecretKey);
        end;

        if StorageAccessKey = '' then begin
            FeatureTelemetry.LogError('0000LT2', TransactionStorageTok, '', StorageAccountAccessKeyBlankTxt);
            Error(StorageAccountAccessKeyBlankTxt);
        end;
    end;

    [InternalEvent(false)]
    internal procedure OnBeforeGetStorageAccountNameFromKeyVault(var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false)]
    internal procedure OnBeforeGetStorageAccountAccessKeyFromKeyVault(var IsHandled: Boolean)
    begin
    end;
}
