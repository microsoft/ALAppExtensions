namespace Microsoft.Finance.VAT.Reporting;

using System.Azure.KeyVault;
using System.Telemetry;

codeunit 13668 "Elec. VAT Decl. Az. Key Vault"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CannotGetSecretFromKeyVaultErr: Label 'Cannot get secret from Azure Key Vault. Key name: %1', Comment = '%1: Name of key that was searched for in Azure Key Vault';
        CannotGetCertFromKeyVaultErr: Label 'Cannot get certificate from Azure Key Vault. Key name: %1', Comment = '%1: Name of key that was searched for in Azure Key Vault';
        FeatureNameTxt: Label 'Electronic VAT Declaration DK', Locked = true;
        AKVGetPeriodsEndpointKeyTok: Label 'DKElecVAT-EndpointGetPeriods', Locked = true;
        AKVSubmitDraftEndpointKeyTok: Label 'DKElecVAT-SubmitDraftEndpoint', Locked = true;
        AKVGetStatusEndpointKeyTok: Label 'DKElecVAT-GetStatusEndpoint', Locked = true;
        AVKCompanyCertTok: Label 'DKElecVAT-CompanyCert', Locked = true;

    [NonDebuggable]
    procedure GetClientCertificateBase64FromAKV() ClientCertificateBase64: Text
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        if not AzureKeyVault.GetAzureKeyVaultCertificate(AVKCompanyCertTok, ClientCertificateBase64) then begin
            FeatureTelemetry.LogError('0000M7L', FeatureNameTxt, '', StrSubstNo(CannotGetCertFromKeyVaultErr, AVKCompanyCertTok));
            Error(CannotGetCertFromKeyVaultErr, AVKCompanyCertTok);
        end;
    end;

    [NonDebuggable]
    procedure GetEndpointURLForRequestType(RequestType: enum "Elec. VAT Decl. Request Type") EndpointText: Text
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        KeyName: Text;
    begin
        case RequestType of
            RequestType::"Get VAT Return Periods":
                KeyName := AKVGetPeriodsEndpointKeyTok;
            RequestType::"Submit VAT Return":
                KeyName := AKVSubmitDraftEndpointKeyTok;
            RequestType::"Check VAT Return Status":
                KeyName := AKVGetStatusEndpointKeyTok;
        end;
        if not AzureKeyVault.GetAzureKeyVaultSecret(KeyName, EndpointText) then begin
            FeatureTelemetry.LogError('0000M7K', FeatureNameTxt, '', StrSubstNo(CannotGetSecretFromKeyVaultErr, KeyName));
            Error(CannotGetSecretFromKeyVaultErr, KeyName);
        end;
    end;
}