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
        SendBlobBlockForTableTok: Label 'Send blob block for table %1 with name %2 to Azure Function', Comment = '%1 - table id, %2 - blob name', Locked = true;
        ExportOfIncomingDocTok: Label 'Export of incoming document %1 with name %2', Comment = '%1 - incoming document file name, %2 - blob name', Locked = true;
        IncomingDocsExportedTxt: Label 'Incoming documents were exported.', Locked = true;
        CollectedDocsCountTxt: Label 'Collected docs count', Locked = true;
        ExportedDocsCountTxt: Label 'Exported docs count', Locked = true;
        TablesExportedTxt: Label 'Tables were exported.', Locked = true;
        CollectedTablesCountTxt: Label 'Collected tables count', Locked = true;
        ExportedTablesCountTxt: Label 'Exported tables count', Locked = true;
        ExportedToABSTxt: Label 'Exported to Azure Blob Storage', Locked = true;
        BlobFolderNameTxt: Label '%1_%2/%3', Comment = '%1 - aad tenant id, %2 - environment name, %3 - date', Locked = true;
        JsonBlobNameTxt: Label '%1/%2.json', Comment = '%1 - blob folder name, %2 - table name', Locked = true;
        IncomingDocBlobNameTxt: Label '%1/%2-%3.%4', Comment = '%1 - blob folder name, %2 - incoming document entry no., %3 - incoming document name, %4 - incoming document extension', Locked = true;
        CannotGetAuthorityURLFromKeyVaultErr: Label 'Cannot get Authority URL from Azure Key Vault using key %1', Locked = true;
        CannotGetClientIdFromKeyVaultErr: Label 'Cannot get Client ID from Azure Key Vault using key %1', Locked = true;
        CannotGetClientSecretFromKeyVaultErr: Label 'Cannot get Client Secret from Azure Key Vault using key %1', Locked = true;
        CannotGetResourceURLFromKeyVaultErr: Label 'Cannot get Resource URL from Azure Key Vault using key %1', Locked = true;
        CannotGetEndpointTextFromKeyVaultErr: Label 'Cannot get Endpoint for text from Azure Key Vault using key %1 ', Locked = true;
        CannotGetEndpointBase64FromKeyVaultErr: Label 'Cannot get Endpoint for base64 from Azure Key Vault using key %1 ', Locked = true;
        ActionFailedErr: Label '%1 failed. See Custom Dimensions.', Locked = true;
        LargeFileFoundErr: Label '%1 file(s) with size more than 100 MB were not exported.', Locked = true;
        AzFunctionResponseErr: Label 'Azure Function response has error or http status code is not 200. HttpStatusCode: %1. ResponseError: %2. ReasonPhrase: %3.', Locked = true;
        AzFunctionClientIdKeyTok: Label 'TransactionStorage-AzFuncClientId', Locked = true;
        AzFuncClientSecretKeyTok: Label 'TransactionStorage-AzFuncClientSecret', Locked = true;
        AzFuncAuthURLKeyTok: Label 'TransactionStorage-AzFuncAuthUrl', Locked = true;
        AzFuncResourceURLKeyTok: Label 'TransactionStorage-AzFuncResourceUrl', Locked = true;
        AzFuncEndpointTextKeyTok: Label 'TransactionStorage-AzFuncEndpointText', Locked = true;
        AzFuncEndpointBase64KeyTok: Label 'TransactionStorage-AzFuncEndpointBase64', Locked = true;

    [NonDebuggable]
    procedure ArchiveTransactionsToABS(DataJsonArrays: Dictionary of [Integer, JsonArray]; IncomingDocs: Dictionary of [Text, Integer])
    var
        AzureFunctionsAuthentication: Codeunit "Azure Functions Authentication";
        AzureFunctionsAuthForJson: Interface "Azure Functions Authentication";
        AzureFunctionsAuthForDoc: Interface "Azure Functions Authentication";
        ExportLog: JsonObject;
        CurrentDate: Date;
        ClientID, ResourceURL, AuthURL, EndpointText, EndpointBase64 : Text;
        ClientSecret: SecretText;
    begin
        GetAzFunctionSecrets(ClientID, ClientSecret, AuthURL, ResourceURL, EndpointText, EndpointBase64);
#if not CLEAN24
#pragma warning disable AL0432
        AzureFunctionsAuthForJson := AzureFunctionsAuthentication.CreateOAuth2(EndpointText, '', ClientID, ClientSecret.Unwrap(), AuthURL, '', ResourceURL);
        AzureFunctionsAuthForDoc := AzureFunctionsAuthentication.CreateOAuth2(EndpointBase64, '', ClientID, ClientSecret.Unwrap(), AuthURL, '', ResourceURL);
#pragma warning restore AL0432
#else
        AzureFunctionsAuthForJson := AzureFunctionsAuthentication.CreateOAuth2(EndpointText, '', ClientID, ClientSecret, AuthURL, '', ResourceURL);
        AzureFunctionsAuthForDoc := AzureFunctionsAuthentication.CreateOAuth2(EndpointBase64, '', ClientID, ClientSecret, AuthURL, '', ResourceURL);
#endif
        CurrentDate := Today();
        WriteJsonBlobsToABS(DataJsonArrays, AzureFunctionsAuthForJson, CurrentDate, ExportLog);
        WriteIncomingDocumentsToABS(IncomingDocs, AzureFunctionsAuthForDoc, CurrentDate, ExportLog);
        WriteExportLog(ExportLog, AzureFunctionsAuthForJson, CurrentDate);
        FeatureTelemetry.LogUsage('0000LQ4', TransactionStorageTok, ExportedToABSTxt);
    end;

    [NonDebuggable]
    local procedure WriteJsonBlobsToABS(DataJsonArrays: Dictionary of [Integer, JsonArray]; AzureFunctionsAuth: Interface "Azure Functions Authentication"; CurrentDate: Date; var ExportLog: JsonObject)
    var
        TableMetadata: Record "Table Metadata";
        TransactStorageTableEntry: Record "Transact. Storage Table Entry";
        TransactStorageExport: Codeunit "Transact. Storage Export";
        AzureFunctionsResponse: Codeunit "Azure Functions Response";
        StringConversionManagement: Codeunit StringConversionManagement;
        TableDataJsonArray: JsonArray;
        TableID: Integer;
        ExportedTableCount: Integer;
        ContainerName: Text;
        BlobFolder: Text;
        BlobName: Text;
        JsonData: Text;
        CustomDimensions: Dictionary of [Text, Text];
        BlobExpirationDate: Date;
    begin
        ContainerName := GetCompanyCVRNumber();
        BlobFolder := GetBlobFolder(CurrentDate);
        BlobExpirationDate := GetBlobExpirationDate(CurrentDate);
        foreach TableID in DataJsonArrays.Keys() do begin
            TableDataJsonArray := DataJsonArrays.Get(TableID);
            TableDataJsonArray.WriteTo(JsonData);
            TableMetadata.Get(TableID);
            BlobName := StrSubstNo(JsonBlobNameTxt, BlobFolder, StringConversionManagement.RemoveNonAlphaNumericCharacters(TableMetadata.Name));
            AzureFunctionsResponse := SendJsonTextToAzureFunction(AzureFunctionsAuth, ContainerName, BlobName, JsonData, BlobExpirationDate);
            HandleAzureFunctionResponse(AzureFunctionsResponse, StrSubstNo(SendBlobBlockForTableTok, TableID, BlobName), TableID);
            ExportedTableCount += 1;
            ExportLog.Add(BlobName, TableDataJsonArray.Count());

            if TransactStorageTableEntry.Get(TableID) then
                TransactStorageExport.SetTableEntryProcessed(TransactStorageTableEntry, TransactStorageTableEntry."Filter Record To DT", true, CopyStr(BlobName, 1, MaxStrLen(TransactStorageTableEntry."Blob Name in ABS")));
        end;
        CustomDimensions.Add(CollectedTablesCountTxt, Format(DataJsonArrays.Count()));
        CustomDimensions.Add(ExportedTablesCountTxt, Format(ExportedTableCount));
        FeatureTelemetry.LogUsage('0000LQ6', TransactionStorageTok, TablesExportedTxt, CustomDimensions);
    end;

    [NonDebuggable]
    local procedure WriteIncomingDocumentsToABS(IncomingDocs: Dictionary of [Text, Integer]; AzureFunctionsAuth: Interface "Azure Functions Authentication"; CurrentDate: Date; var ExportLog: JsonObject)
    var
        IncomingDocAttachment: Record "Incoming Document Attachment";
        AzureFunctionsResponse: Codeunit "Azure Functions Response";
        TempBlob: Codeunit "Temp Blob";
        IncomingDocKey: Text;
        BlobFolder: Text;
        BlobName: Text;
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
        ContainerName := GetCompanyCVRNumber();
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
                            AzureFunctionsResponse := SendDocumentToAzureFunction(AzureFunctionsAuth, ContainerName, BlobName, TempBlob, BlobExpirationDate);
                            HandleAzureFunctionResponse(AzureFunctionsResponse, StrSubstNo(ExportOfIncomingDocTok, IncomingDocAttachment.Name, BlobName), 0);
                            ExportedDocCount += 1;
                        end;
                until IncomingDocAttachment.Next() = 0;
        end;
        ExportLog.Add(IncomingDocAttachment.TableName, ExportedDocCount);
        if LargeFileCount > 0 then
            FeatureTelemetry.LogError('0000M7H', TransactionStorageTok, '', StrSubstNo(LargeFileFoundErr, LargeFileCount));
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
        ContainerName := GetCompanyCVRNumber();
        BlobFolder := GetBlobFolder(CurrentDate);
        BlobExpirationDate := GetBlobExpirationDate(CurrentDate);
        BlobName := StrSubstNo(JsonBlobNameTxt, BlobFolder, ExportLogFileNameTxt);
        ExportLog.WriteTo(JsonData);
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

    [NonDebuggable]
    local procedure HandleAzureFunctionResponse(AzureFunctionsResponse: Codeunit "Azure Functions Response"; ActionText: Text; TableID: Integer)
    var
        TransactStorageTableEntry: Record "Transact. Storage Table Entry";
        ResultResponseMsg: HttpResponseMessage;
        CustomDimensions: Dictionary of [Text, Text];
    begin
        AzureFunctionsResponse.GetHttpResponse(ResultResponseMsg);
        if not AzureFunctionsResponse.IsSuccessful() or (ResultResponseMsg.HttpStatusCode <> 200) then begin
            CustomDimensions.Add('HttpStatusCode', Format(ResultResponseMsg.HttpStatusCode));
            CustomDimensions.Add('ResponseError', AzureFunctionsResponse.GetError());
            CustomDimensions.Add('ReasonPhrase', ResultResponseMsg.ReasonPhrase);
            CustomDimensions.Add('CVR Number', GetCompanyCVRNumber());
            if TableID <> 0 then begin
                CustomDimensions.Add('Table ID', Format(TableID));
                if TransactStorageTableEntry.Get(TableID) then
                    CustomDimensions.Add('Record Filters', TransactStorageTableEntry."Record Filters");
            end;
            FeatureTelemetry.LogError('0000LQ7', TransactionStorageTok, '', StrSubstNo(ActionFailedErr, ActionText), '', CustomDimensions);
            Error(AzFunctionResponseErr, ResultResponseMsg.HttpStatusCode, AzureFunctionsResponse.GetError(), ResultResponseMsg.ReasonPhrase);
        end;
    end;

    [NonDebuggable]
    local procedure GetBlobFolder(CurrentDate: Date): Text
    var
        EnvironmentName: Text;
        DateFolderName: Text;
    begin
        EnvironmentName := GetEnvironmentName();
        DateFolderName := Format(CurrentDate, 0, '<Year4><Month,2><Day,2>');
        exit(StrSubstNo(BlobFolderNameTxt, GetAadTenantId(), EnvironmentName, DateFolderName));
    end;

    [NonDebuggable]
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
    local procedure GetAzFunctionSecrets(var ClientID: Text; var ClientSecret: SecretText; var AuthURL: Text; var ResourceURL: Text; var EndpointForText: Text; var EndpointForBase64: Text)
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(AzFunctionClientIdKeyTok, ClientID) then begin
            FeatureTelemetry.LogError('0000LX9', TransactionStorageTok, '', StrSubstNo(CannotGetClientIdFromKeyVaultErr, AzFunctionClientIdKeyTok));
            Error(CannotGetClientIdFromKeyVaultErr, AzFunctionClientIdKeyTok);
        end;

        if not AzureKeyVault.GetAzureKeyVaultSecret(AzFuncClientSecretKeyTok, ClientSecret) then begin
            FeatureTelemetry.LogError('0000LXA', TransactionStorageTok, '', StrSubstNo(CannotGetClientSecretFromKeyVaultErr, AzFuncClientSecretKeyTok));
            Error(CannotGetClientSecretFromKeyVaultErr, AzFuncClientSecretKeyTok);
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

    [NonDebuggable]
    procedure GetAadTenantId(): Text
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        exit(AzureADTenant.GetAadTenantId());
    end;

    [NonDebuggable]
    local procedure GetEnvironmentName(): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        exit(RemoveProhibitedChars(EnvironmentInformation.GetEnvironmentName()));
    end;

    local procedure GetCompanyCVRNumber(): Text
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

    [NonDebuggable]
    local procedure IsFileSizeExceedsLimit(FileSize: Integer): Boolean
    begin
        exit(FileSize > 100 * 1024 * 1024);     // 100 MB
    end;

    [NonDebuggable]
    local procedure RemoveProhibitedChars(InputValue: Text): Text
    begin
        exit(DelChr(InputValue, '=', './\'));
    end;

    [NonDebuggable]
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
}
