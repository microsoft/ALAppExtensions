namespace System.DataAdministration;

using Microsoft.EServices.EDocument;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.Period;
using System.Utilities;
using System.Azure.Functions;
using System.Azure.Identity;
using System.Azure.KeyVault;
using System.Azure.Storage;
using System.Environment;
using System.Reflection;
using System.Telemetry;
using System.Text;

codeunit 6205 "Transaction Storage ABS"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Transact. Storage Task Entry" = R,
                  tabledata "Transact. Storage Table Entry" = RM,
                  tabledata "Trans. Storage Export Data" = RD,
                  tabledata "Table Metadata" = r,
                  tabledata "Incoming Document Attachment" = r,
                  tabledata "ABS Container" = ri;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CVRNumberGlobal: Text;
        VATRegNoGlobal: Text;
        TransactionStorageTok: Label 'Transaction Storage', Locked = true;
        JsonContentTypeHeaderTok: Label 'application/json', Locked = true;
        ExportLogFileNameTxt: Label 'ExportLog', Locked = true;
        MetadataFileNameTxt: Label 'metadata', Locked = true;
        SendBlobBlockForTableErr: Label 'Send blob block to Azure Function failed.', Locked = true;
        ExportOfIncomingDocErr: Label 'Export of incoming document failed.', Locked = true;
        IncomingDocsExportedTxt: Label 'Incoming documents were exported.', Locked = true;
        CollectedDocsCountTxt: Label 'Collected docs count', Locked = true;
        ExportedDocsCountTxt: Label 'Exported docs count', Locked = true;
        TablesExportedTxt: Label 'Tables were exported.', Locked = true;
        ExportedTablesCountTxt: Label 'Exported tables count', Locked = true;
        ExportedToABSTxt: Label 'Exported to Azure Blob Storage using certificate authorized Azure Function', Locked = true;
        BlobFolderNameTxt: Label '%1_%2/%3', Comment = '%1 - aad tenant id, %2 - environment name, %3 - date', Locked = true;
        JsonBlobNameTxt: Label '%1/%2.json', Comment = '%1 - blob folder name, %2 - table name', Locked = true;
        JsonBlobNameWithPartTxt: Label '%1/%2_%3.json', Comment = '%1 - blob folder name, %2 - table name, %3 - part', Locked = true;
        IncomingDocBlobNameTxt: Label '%1/%2-%3.%4', Comment = '%1 - blob folder name, %2 - incoming document entry no., %3 - incoming document name, %4 - incoming document extension', Locked = true;
        CannotGetAuthorityURLFromKeyVaultErr: Label 'Cannot get Authority URL from Azure Key Vault using key %1', Locked = true;
        CannotGetClientIdFromKeyVaultErr: Label 'Cannot get Client ID from Azure Key Vault using key %1', Locked = true;
        CannotGetCertFromKeyVaultErr: Label 'Cannot get certificate from Azure Key Vault using key %1', Locked = true;
        CannotGetResourceURLFromKeyVaultErr: Label 'Cannot get Resource URL from Azure Key Vault using key %1', Locked = true;
        CannotGetEndpointTextFromKeyVaultErr: Label 'Cannot get Endpoint for text from Azure Key Vault using key %1 ', Locked = true;
        CannotGetEndpointBase64FromKeyVaultErr: Label 'Cannot get Endpoint for base64 from Azure Key Vault using key %1 ', Locked = true;
        LargeFileFoundErr: Label '%1 file(s) with size more than 100 MB were not exported.', Locked = true;
        ShortContainerNameErr: Label 'Container name length is less than 3 characters.', Locked = true;
        AzFunctionResponseErr: Label 'Azure Function response has error or http status code is not 200. HttpStatusCode: %1. ResponseError: %2. ReasonPhrase: %3.', Locked = true;
        AzFunctionClientIdKeyTok: Label 'TransactionStorage-AzFuncClientId', Locked = true;
        AzFuncCertificateNameTok: Label 'TransactionStorage-AzFuncCertificateName', Locked = true;
        AzFuncAuthURLKeyTok: Label 'TransactionStorage-AzFuncAuthUrl', Locked = true;
        AzFuncResourceURLKeyTok: Label 'TransactionStorage-AzFuncScope', Locked = true;
        AzFuncEndpointTextKeyTok: Label 'TransactionStorage-AzFuncEndpointText', Locked = true;
        AzFuncEndpointBase64KeyTok: Label 'TransactionStorage-AzFuncEndpointBase64', Locked = true;

    [NonDebuggable]
    procedure ArchiveTransactionsToABS(IncomingDocs: Dictionary of [Text, Integer])
    var
        AzureFunctionsAuthentication: Codeunit "Azure Functions Authentication";
        AzureFunctionsAuthForJson: Interface "Azure Functions Authentication";
        AzureFunctionsAuthForDoc: Interface "Azure Functions Authentication";
        ExportLog: JsonObject;
        CurrentDate: Date;
        ClientID, ResourceURL, AuthURL, EndpointText, EndpointBase64 : Text;
        Cert: SecretText;
    begin
        GetAzFunctionSecrets(ClientID, Cert, AuthURL, ResourceURL, EndpointText, EndpointBase64);

        AzureFunctionsAuthForJson := AzureFunctionsAuthentication.CreateOAuth2WithCert(EndpointText, '', ClientID, Cert, AuthURL, '', ResourceURL);
        AzureFunctionsAuthForDoc := AzureFunctionsAuthentication.CreateOAuth2WithCert(EndpointBase64, '', ClientID, Cert, AuthURL, '', ResourceURL);

        CurrentDate := Today();
        VerifyContainerNameLength(GetContainerName());

        WriteJsonBlobsToABS(AzureFunctionsAuthForJson, CurrentDate, ExportLog);
        WriteIncomingDocumentsToABS(IncomingDocs, AzureFunctionsAuthForDoc, CurrentDate, ExportLog);
        WriteExportLog(ExportLog, AzureFunctionsAuthForJson, CurrentDate);
        WriteMetadata(AzureFunctionsAuthForJson, CurrentDate);
        FeatureTelemetry.LogUsage('0000LQ4', TransactionStorageTok, ExportedToABSTxt);
    end;

    [NonDebuggable]
    local procedure WriteJsonBlobsToABS(AzureFunctionsAuth: Interface "Azure Functions Authentication"; CurrentDate: Date; var ExportLog: JsonObject)
    var
        TableMetadata: Record "Table Metadata";
        TransStorageExportData: Record "Trans. Storage Export Data";
        TransactStorageTableEntry: Record "Transact. Storage Table Entry";
        AzureFunctionsResponse: Codeunit "Azure Functions Response";
        StringConversionManagement: Codeunit StringConversionManagement;
        ExportedTableCount: Integer;
        TotalRecordCount: Integer;
        ContainerName: Text;
        BlobFolder: Text;
        BlobName: Text;
        JsonData: Text;
        CustomDimensions: Dictionary of [Text, Text];
        BlobExpirationDate: Date;
        InStream: InStream;
    begin
        TransStorageExportData.SetAutoCalcFields(Content);
        if not TransStorageExportData.FindSet() then
            exit;

        ContainerName := GetContainerName();
        BlobFolder := GetBlobFolder(CurrentDate);
        BlobExpirationDate := GetBlobExpirationDate(CurrentDate);
        repeat
            TransStorageExportData.SetRange("Table ID", TransStorageExportData."Table ID");
            TotalRecordCount := 0;
            repeat
                TotalRecordCount += TransStorageExportData."Record Count";
                TransStorageExportData.Content.CreateInStream(InStream);
                InStream.ReadText(JsonData);
                TableMetadata.Get(TransStorageExportData."Table ID");
                BlobName :=
                    StrSubstNo(
                        JsonBlobNameWithPartTxt, BlobFolder,
                        StringConversionManagement.RemoveNonAlphaNumericCharacters(TableMetadata.Name),
                        TransStorageExportData.Part);
                AzureFunctionsResponse := SendJsonTextToAzureFunction(AzureFunctionsAuth, ContainerName, BlobName, JsonData, BlobExpirationDate);
                if not AzureFunctionsResponse.IsSuccessful() then
                    ProcessJsonFaultResponse(
                        AzureFunctionsResponse, TransStorageExportData."Table ID",
                        TransStorageExportData."Record Count", BlobName, GetDataLengthMB(StrLen(JsonData)));
            until TransStorageExportData.Next() = 0;
            UpdateExportedTableData(
                TransStorageExportData, TransactStorageTableEntry, ExportLog, ExportedTableCount, BlobName, TotalRecordCount);
        until TransStorageExportData.Next() = 0;
        TransStorageExportData.DeleteAll(true);
        CustomDimensions.Add(ExportedTablesCountTxt, Format(ExportedTableCount));
        FeatureTelemetry.LogUsage('0000LQ6', TransactionStorageTok, TablesExportedTxt, CustomDimensions);
    end;

    local procedure UpdateExportedTableData(var TransStorageExportData: Record "Trans. Storage Export Data"; var TransactStorageTableEntry: Record "Transact. Storage Table Entry"; var ExportLog: JsonObject; var ExportedTableCount: Integer; BlobName: Text; TotalRecordCount: Integer)
    var
        TransactStorageExport: Codeunit "Transact. Storage Export";
    begin
        ExportedTableCount += 1;
        ExportLog.Add(BlobName, TotalRecordCount);
        if TransactStorageTableEntry.Get(TransStorageExportData."Table ID") then
            TransactStorageExport.SetTableEntryProcessed(TransactStorageTableEntry, TransactStorageTableEntry."Filter Record To DT", true, CopyStr(BlobName, 1, MaxStrLen(TransactStorageTableEntry."Blob Name in ABS")));
        TransStorageExportData.SetRange("Table ID");
    end;

    [NonDebuggable]
    local procedure WriteIncomingDocumentsToABS(IncomingDocs: Dictionary of [Text, Integer]; AzureFunctionsAuth: Interface "Azure Functions Authentication"; CurrentDate: Date; var ExportLog: JsonObject)
    var
        IncomingDocAttachment: Record "Incoming Document Attachment";
        TransactStorageExport: Codeunit "Transact. Storage Export";
        AzureFunctionsResponse: Codeunit "Azure Functions Response";
        TempBlob: Codeunit "Temp Blob";
        IncomingDocKey: Text;
        BlobFolder: Text;
        BlobName: Text;
        BlobNameToLog: Text;
        AttachmentName: Text;
        FileExtension: Text;
        ContainerName: Text;
        CustomDimensions: Dictionary of [Text, Text];
        IncomingDocEntryNo: Integer;
        ExportedDocCount: Integer;
        LargeFileCount: Integer;
        BlobExpirationDate: Date;
        BlobInStream: InStream;
        BlobOutStream: OutStream;
    begin
        ContainerName := GetContainerName();
        BlobFolder := GetBlobFolder(CurrentDate);
        BlobExpirationDate := GetBlobExpirationDate(CurrentDate);
        foreach IncomingDocKey in IncomingDocs.Keys() do begin
            IncomingDocEntryNo := IncomingDocs.Get(IncomingDocKey);
            IncomingDocAttachment.SetRange("Incoming Document Entry No.", IncomingDocEntryNo);
            if IncomingDocAttachment.FindSet() then
                repeat
                    IncomingDocAttachment.CalcFields(Content);
                    if IncomingDocAttachment.Content.HasValue() then
                        if IsFileSizeExceedsLimit(IncomingDocAttachment.Content.Length()) then
                            LargeFileCount += 1
                        else begin
                            Clear(TempBlob);
                            TempBlob.CreateOutStream(BlobOutStream);
                            IncomingDocAttachment.Content.CreateInStream(BlobInStream);
                            CopyStream(BlobOutStream, BlobInStream);
                            AttachmentName := RemoveProhibitedChars(IncomingDocAttachment.Name);
                            FileExtension := RemoveProhibitedChars(IncomingDocAttachment."File Extension");
                            BlobName := StrSubstNo(IncomingDocBlobNameTxt, BlobFolder, IncomingDocKey, AttachmentName, FileExtension);
                            BlobNameToLog := StrSubstNo(IncomingDocBlobNameTxt, BlobFolder, IncomingDocKey, EncodeDocName(AttachmentName), FileExtension);
                            AzureFunctionsResponse := SendDocumentToAzureFunction(AzureFunctionsAuth, ContainerName, BlobName, TempBlob, BlobExpirationDate);
                            if not AzureFunctionsResponse.IsSuccessful() then
                                ProcessBase64FaultResponse(
                                    AzureFunctionsResponse, EncodeDocName(IncomingDocAttachment.Name), BlobNameToLog, GetDataLengthMB(TempBlob.Length()));
                            ExportedDocCount += 1;
                        end;
                until IncomingDocAttachment.Next() = 0;
        end;
        ExportLog.Add(IncomingDocAttachment.TableName, ExportedDocCount);
        if LargeFileCount > 0 then
            TransactStorageExport.LogWarning('0000M7H', StrSubstNo(LargeFileFoundErr, LargeFileCount));
        CustomDimensions.Add(CollectedDocsCountTxt, Format(IncomingDocAttachment.Count()));
        CustomDimensions.Add(ExportedDocsCountTxt, Format(ExportedDocCount));
        FeatureTelemetry.LogUsage('0000LT3', TransactionStorageTok, IncomingDocsExportedTxt, CustomDimensions);
    end;

    [NonDebuggable]
    local procedure WriteExportLog(ExportLog: JsonObject; AzureFunctionsAuth: Interface "Azure Functions Authentication"; CurrentDate: Date)
    var
        BlobExpirationDate: Date;
        ContainerName: Text;
        BlobFolder: Text;
        BlobName: Text;
        JsonData: Text;
    begin
        ContainerName := GetContainerName();
        BlobFolder := GetBlobFolder(CurrentDate);
        BlobExpirationDate := GetBlobExpirationDate(CurrentDate);
        BlobName := StrSubstNo(JsonBlobNameTxt, BlobFolder, ExportLogFileNameTxt);
        ExportLog.WriteTo(JsonData);
        SendJsonTextToAzureFunction(AzureFunctionsAuth, ContainerName, BlobName, JsonData, BlobExpirationDate);
    end;

    [NonDebuggable]
    local procedure WriteMetadata(AzureFunctionsAuth: Interface "Azure Functions Authentication"; CurrentDate: Date)
    var
        Metadata: JsonObject;
        AppInfo: ModuleInfo;
        BlobExpirationDate: Date;
        ContainerName: Text;
        BlobFolder: Text;
        BlobName: Text;
        JsonData: Text;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        ContainerName := GetContainerName();
        BlobFolder := GetBlobFolder(CurrentDate);
        BlobExpirationDate := GetBlobExpirationDate(CurrentDate);
        BlobName := StrSubstNo(JsonBlobNameTxt, BlobFolder, MetadataFileNameTxt);
        Metadata.Add('aadTenantId', GetAadTenantId());
        Metadata.Add('environmentName', GetEnvironmentName());
        Metadata.Add('companyName', CompanyName());
        Metadata.Add('vatRegistrationNo', GetCompanyVATRegistrationNo());
        Metadata.Add('cvrNo', GetContainerName());
        Metadata.Add('bcVersion', Format(AppInfo.DataVersion()));
        Metadata.Add('exportDate', CurrentDate);
        Metadata.Add('expirationDate', BlobExpirationDate);
        Metadata.WriteTo(JsonData);
        SendJsonTextToAzureFunction(AzureFunctionsAuth, ContainerName, BlobName, JsonData, BlobExpirationDate);
    end;

    [NonDebuggable]
    local procedure SendJsonTextToAzureFunction(var AzureFunctionsAuth: Interface "Azure Functions Authentication"; ContainerName: Text; BlobName: Text; JsonText: Text; BlobExpirationDate: Date) AzureFunctionsResponse: Codeunit "Azure Functions Response"
    var
        AzureFunctions: Codeunit "Azure Functions";
        AppInfo: ModuleInfo;
        RequestBodyJson: JsonObject;
        RequestBody: Text;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        RequestBodyJson.Add('containerName', ContainerName);
        RequestBodyJson.Add('blobName', BlobName);
        RequestBodyJson.Add('blobContent', JsonText);
        RequestBodyJson.Add('blobExpirationDate', BlobExpirationDate);
        RequestBodyJson.Add('aadTenantId', GetAadTenantId());
        RequestBodyJson.Add('companyName', CompanyName());
        RequestBodyJson.Add('vatRegistrationNo', GetCompanyVATRegistrationNo());
        RequestBodyJson.Add('bcVersion', Format(AppInfo.DataVersion()));
        RequestBodyJson.WriteTo(RequestBody);
        AzureFunctionsResponse := AzureFunctions.SendPostRequest(AzureFunctionsAuth, RequestBody, JsonContentTypeHeaderTok);
    end;

    [NonDebuggable]
    local procedure SendDocumentToAzureFunction(var AzureFunctionsAuth: Interface "Azure Functions Authentication"; ContainerName: Text; BlobName: Text; var TempBlob: Codeunit "Temp Blob"; BlobExpirationDate: Date) AzureFunctionsResponse: Codeunit "Azure Functions Response"
    var
        AzureFunctions: Codeunit "Azure Functions";
        Base64Convert: Codeunit "Base64 Convert";
        AppInfo: ModuleInfo;
        BlobInStream: InStream;
        RequestBodyJson: JsonObject;
        RequestBody: Text;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        Tempblob.CreateInStream(BlobInStream);
        RequestBodyJson.Add('containerName', ContainerName);
        RequestBodyJson.Add('blobName', BlobName);
        RequestBodyJson.Add('blobContent', Base64Convert.ToBase64(BlobInStream));
        RequestBodyJson.Add('blobExpirationDate', BlobExpirationDate);
        RequestBodyJson.Add('aadTenantId', GetAadTenantId());
        RequestBodyJson.Add('companyName', CompanyName());
        RequestBodyJson.Add('vatRegistrationNo', GetCompanyVATRegistrationNo());
        RequestBodyJson.Add('bcVersion', Format(AppInfo.DataVersion()));
        RequestBodyJson.WriteTo(RequestBody);
        AzureFunctionsResponse := AzureFunctions.SendPostRequest(AzureFunctionsAuth, RequestBody, JsonContentTypeHeaderTok);
    end;

    local procedure ProcessJsonFaultResponse(AzureFunctionsResponse: Codeunit "Azure Functions Response"; TableID: Integer; RecordCount: Integer; BlobName: Text; BlobSizeMB: Decimal)
    var
        TransactStorageTableEntry: Record "Transact. Storage Table Entry";
        ResultResponseMsg: HttpResponseMessage;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        AzureFunctionsResponse.GetHttpResponse(ResultResponseMsg);
        CustomDimensions.Add('HttpStatusCode', Format(ResultResponseMsg.HttpStatusCode));
        CustomDimensions.Add('ResponseError', AzureFunctionsResponse.GetError());
        CustomDimensions.Add('ReasonPhrase', ResultResponseMsg.ReasonPhrase);
        CustomDimensions.Add('ContainerName', GetContainerName());
        CustomDimensions.Add('BlobName', BlobName);
        CustomDimensions.Add('BlobSizeMB', Format(BlobSizeMB));
        CustomDimensions.Add('TableId', Format(TableID));
        CustomDimensions.Add('RecordCount', Format(RecordCount));
        if TransactStorageTableEntry.Get(TableID) then
            CustomDimensions.Add('RecordFilters', TransactStorageTableEntry."Record Filters");
        FeatureTelemetry.LogError('0000LQ7', TransactionStorageTok, '', SendBlobBlockForTableErr, '', CustomDimensions);
        Error(AzFunctionResponseErr, ResultResponseMsg.HttpStatusCode, AzureFunctionsResponse.GetError(), ResultResponseMsg.ReasonPhrase);
    end;

    local procedure ProcessBase64FaultResponse(AzureFunctionsResponse: Codeunit "Azure Functions Response"; IncomingDocName: Text; BlobName: Text; BlobSizeMB: Decimal)
    var
        ResultResponseMsg: HttpResponseMessage;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        AzureFunctionsResponse.GetHttpResponse(ResultResponseMsg);
        CustomDimensions.Add('HttpStatusCode', Format(ResultResponseMsg.HttpStatusCode));
        CustomDimensions.Add('ResponseError', AzureFunctionsResponse.GetError());
        CustomDimensions.Add('ReasonPhrase', ResultResponseMsg.ReasonPhrase);
        CustomDimensions.Add('ContainerName', GetContainerName());
        CustomDimensions.Add('BlobName', BlobName);
        CustomDimensions.Add('BlobSizeMB', Format(BlobSizeMB));
        CustomDimensions.Add('IncomingDocName', IncomingDocName);
        FeatureTelemetry.LogError('0000LQ7', TransactionStorageTok, '', ExportOfIncomingDocErr, '', CustomDimensions);
        Error(AzFunctionResponseErr, ResultResponseMsg.HttpStatusCode, AzureFunctionsResponse.GetError(), ResultResponseMsg.ReasonPhrase);
    end;

    local procedure GetBlobFolder(CurrentDate: Date): Text
    var
        EnvironmentName: Text;
        DateFolderName: Text;
    begin
        EnvironmentName := GetEnvironmentName();
        DateFolderName := Format(CurrentDate, 0, '<Year4><Month,2><Day,2>');
        exit(StrSubstNo(BlobFolderNameTxt, GetAadTenantId(), EnvironmentName, DateFolderName));
    end;

    local procedure GetBlobExpirationDate(CurrentDate: Date): Date
    var
        AccountingPeriodMgt: Codeunit "Accounting Period Mgt.";
        ExpirationDate: Date;
        FiscalYearEndDate: Date;
    begin
        ExpirationDate := CalcDate('<+6Y>', CurrentDate);
        FiscalYearEndDate := AccountingPeriodMgt.FindEndOfFiscalYear(CurrentDate);
        if Date2DMY(FiscalYearEndDate, 3) <> 9999 then      // if end date of fiscal year was found
            ExpirationDate := CalcDate('<+6Y>', FiscalYearEndDate);

        exit(ExpirationDate);
    end;

    [NonDebuggable]
    local procedure GetAzFunctionSecrets(var ClientID: Text; var Certificate: SecretText; var AuthURL: Text; var ResourceURL: Text; var EndpointForText: Text; var EndpointForBase64: Text)
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        CertificateName: Text;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(AzFunctionClientIdKeyTok, ClientID) then begin
            FeatureTelemetry.LogError('0000LX9', TransactionStorageTok, '', StrSubstNo(CannotGetClientIdFromKeyVaultErr, AzFunctionClientIdKeyTok));
            Error(CannotGetClientIdFromKeyVaultErr, AzFunctionClientIdKeyTok);
        end;

        if not AzureKeyVault.GetAzureKeyVaultSecret(AzFuncCertificateNameTok, CertificateName) then begin
            FeatureTelemetry.LogError('0000LXA', TransactionStorageTok, '', StrSubstNo(CannotGetCertFromKeyVaultErr, AzFuncCertificateNameTok));
            Error(CannotGetCertFromKeyVaultErr, AzFuncCertificateNameTok);
        end;
        if not AzureKeyVault.GetAzureKeyVaultCertificate(CertificateName, Certificate) then begin
            FeatureTelemetry.LogError('0000MZM', TransactionStorageTok, '', StrSubstNo(CannotGetCertFromKeyVaultErr, AzFuncCertificateNameTok));
            Error(CannotGetCertFromKeyVaultErr, AzFuncCertificateNameTok);
        end;

        if not AzureKeyVault.GetAzureKeyVaultSecret(AzFuncAuthURLKeyTok, AuthURL) then begin
            FeatureTelemetry.LogError('0000LSZ', TransactionStorageTok, '', StrSubstNo(CannotGetAuthorityURLFromKeyVaultErr, AzFuncAuthURLKeyTok));
            Error(CannotGetAuthorityURLFromKeyVaultErr, AzFuncAuthURLKeyTok);
        end;

        if not AzureKeyVault.GetAzureKeyVaultSecret(AzFuncResourceURLKeyTok, ResourceURL) then begin
            FeatureTelemetry.LogError('0000LXB', TransactionStorageTok, '', StrSubstNo(CannotGetResourceURLFromKeyVaultErr, AzFuncResourceURLKeyTok));
            Error(CannotGetResourceURLFromKeyVaultErr, AzFuncResourceURLKeyTok);
        end;

        if not AzureKeyVault.GetAzureKeyVaultSecret(AzFuncEndpointTextKeyTok, EndpointForText) then begin
            FeatureTelemetry.LogError('0000LXR', TransactionStorageTok, '', StrSubstNo(CannotGetEndpointTextFromKeyVaultErr, AzFuncEndpointTextKeyTok));
            Error(CannotGetEndpointTextFromKeyVaultErr, AzFuncEndpointTextKeyTok);
        end;

        if not AzureKeyVault.GetAzureKeyVaultSecret(AzFuncEndpointBase64KeyTok, EndpointForBase64) then begin
            FeatureTelemetry.LogError('0000M7I', TransactionStorageTok, '', StrSubstNo(CannotGetEndpointBase64FromKeyVaultErr, AzFuncEndpointBase64KeyTok));
            Error(CannotGetEndpointBase64FromKeyVaultErr, AzFuncEndpointBase64KeyTok);
        end;
    end;

    procedure GetAadTenantId(): Text
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        exit(AzureADTenant.GetAadTenantId());
    end;

    local procedure GetEnvironmentName(): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        exit(RemoveProhibitedChars(EnvironmentInformation.GetEnvironmentName()));
    end;

    procedure GetContainerName(): Text
    var
        CompanyInformation: Record "Company Information";
    begin
        if CVRNumberGlobal = '' then begin
            CompanyInformation.Get();
            CVRNumberGlobal := FormatContainerName(CompanyInformation."Registration No.");
        end;
        exit(CVRNumberGlobal);
    end;

    local procedure GetCompanyVATRegistrationNo(): Text
    var
        CompanyInformation: Record "Company Information";
    begin
        if VATRegNoGlobal = '' then begin
            CompanyInformation.Get();
            VATRegNoGlobal := CompanyInformation."VAT Registration No.";
        end;
        exit(VATRegNoGlobal);
    end;

    local procedure GetDataLengthMB(DataLengthBytes: Integer): Decimal
    begin
        exit(Round(DataLengthBytes / 1024 / 1024, 0.1));
    end;

    local procedure IsFileSizeExceedsLimit(FileSize: Integer): Boolean
    begin
        exit(FileSize > 100 * 1024 * 1024);     // 100 MB
    end;

    local procedure RemoveProhibitedChars(InputValue: Text) OutputValue: Text
    var
        Backspace: Char;
        Tab: Char;
        LF: Char;
        CR: Char;
        Ch: Char;
    begin
        Backspace := 8;
        Tab := 9;
        LF := 10;
        CR := 13;
        foreach Ch in InputValue do
            if not (Ch in [Backspace, Tab, LF, CR, '.', '/', '\']) then
                OutputValue += Ch;
    end;

    local procedure FormatContainerName(InputValue: Text) OutputValue: Text
    var
        Regex: Codeunit Regex;
        Ch: Char;
    begin
        InputValue := InputValue.ToLower();
        foreach Ch in InputValue do
            if ((Ch >= 'a') and (Ch <= 'z')) or
               ((Ch >= '0') and (Ch <= '9')) or
               (Ch = '-')
            then
                OutputValue += Ch;

        // remove hypens from start and end of string
        OutputValue := OutputValue.TrimStart('-');
        OutputValue := OutputValue.TrimEnd('-');

        // remove consecutive hypens
        OutputValue := Regex.Replace(OutputValue, '-+', '-');
    end;

    procedure VerifyContainerNameLength(ContainerName: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
    begin
        if StrLen(ContainerName) < 3 then begin
            CustomDimensions.Add('ContainerName', ContainerName);
            FeatureTelemetry.LogError('0000NCG', TransactionStorageTok, '', ShortContainerNameErr, '', CustomDimensions);
            Error(ShortContainerNameErr);
        end;
    end;

    local procedure EncodeDocName(InputValue: Text) OutputValue: Text
    var
        Ch: Char;
    begin
        foreach Ch in InputValue do
            case true of
                (Ch >= 'a') and (Ch <= 'z'):
                    OutputValue += 'a';
                (Ch >= 'A') and (Ch <= 'Z'):
                    OutputValue += 'A';
                (Ch >= '0') and (Ch <= '9'):
                    OutputValue += '0';
                else
                    OutputValue += Ch;
            end;
    end;
}
