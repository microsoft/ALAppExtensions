// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Azure.KeyVault;
using System.Telemetry;
using System.Environment;

codeunit 10057 "Key Vault Client IRIS"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        Helper: Codeunit "Helper IRIS";
        AzureKeyVault: Codeunit "Azure Key Vault";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        TransmitterTCCKeyTok: Label 'IRS1099IRIS-TransmitterTCC', Locked = true;
        SoftwareDevTCCKeyTok: Label 'IRS1099IRIS-SoftwareDevTCC', Locked = true;
        SoftwareIDKeyTok: Label 'IRS1099IRIS-SoftwareID', Locked = true;
        APIClientIDKeyTok: Label 'IRS1099IRIS-ClientID', Locked = true;
        JSONWebKeyIDKeyTok: Label 'IRS1099IRIS-JSONWebKeyID', Locked = true;
        AuthURLKeyTok: Label 'IRS1099IRIS-AuthURL', Locked = true;
        ConsentAppURLKeyTok: Label 'IRS1099IRIS-ConsentAppURL', Locked = true;
        CertificateNameKeyTok: Label 'IRS1099IRIS-CertificateName', Locked = true;
        SubmitEndpointLiveKeyTok: Label 'IRS1099IRIS-SubmitEndpointLive', Locked = true;
        SubmitEndpointTestKeyTok: Label 'IRS1099IRIS-SubmitEndpointTest', Locked = true;
        GetStatusEndpointLiveKeyTok: Label 'IRS1099IRIS-GetStatusEndpointLive', Locked = true;
        GetStatusEndpointTestKeyTok: Label 'IRS1099IRIS-GetStatusEndpointTest', Locked = true;
        ContactInfoKeyTok: Label 'IRS1099IRIS-ContactInfo', Locked = true;
        CannotGetValueFromKeyVaultErr: Label 'Cannot get %1 from Azure Key Vault using key %2', Comment = '%1 - parameter name, ex. Client ID; %2 - secret name', Locked = true;
        CannotGetValueUserErr: Label 'Could not get %1 from Azure Key Vault. Try the operation again later. If the issue persists, open a Business Central support request.', Comment = '%1 - parameter name, ex. Client ID';
        ValueFromKeyVaultIsEmptyErr: Label '%1 value from Azure Key Vault is empty. Key: %2', Comment = '%1 - parameter name, ex. Client ID; %2 - secret name', Locked = true;
        ValueIsEmptyUserErr: Label '%1 value from Azure Key Vault is empty. Try the operation again later. If the issue persists, open a Business Central support request.', Comment = '%1 - parameter name, ex. Client ID';
        ContactInfoIncorrectJSONErr: Label 'Cannot create JSON object from Contact Info string.';

    procedure GetTCC() TCC: Text
    var
        TCCKey: Text;
    begin
        if TestMode() then
            TCCKey := SoftwareDevTCCKeyTok
        else
            TCCKey := TransmitterTCCKeyTok;

        if not AzureKeyVault.GetAzureKeyVaultSecret(TCCKey, TCC) then
            LogKeyVaultError('0000P7P', 'TCC', TCCKey);
        if TCC = '' then
            LogEmptyValueError('0000P7P', 'TCC', TCCKey);
    end;

    procedure GetSubmitEndpointURL() EndpointURL: Text
    var
        EndpointKey: Text;
    begin
        if TestMode() then
            EndpointKey := SubmitEndpointTestKeyTok
        else
            EndpointKey := SubmitEndpointLiveKeyTok;

        if not AzureKeyVault.GetAzureKeyVaultSecret(EndpointKey, EndpointURL) then
            LogKeyVaultError('0000PA7', 'Submit Endpoint URL', EndpointKey);
        if EndpointURL = '' then
            LogEmptyValueError('0000PA7', 'Submit Endpoint URL', EndpointKey);
    end;

    procedure GetStatusEndpointURL() EndpointURL: Text
    var
        EndpointKey: Text;
    begin
        if TestMode() then
            EndpointKey := GetStatusEndpointTestKeyTok
        else
            EndpointKey := GetStatusEndpointLiveKeyTok;

        if not AzureKeyVault.GetAzureKeyVaultSecret(EndpointKey, EndpointURL) then
            LogKeyVaultError('0000PA9', 'Status Endpoint URL', EndpointKey);
        if EndpointURL = '' then
            LogEmptyValueError('0000PA9', 'Status Endpoint URL', EndpointKey);
    end;

    procedure GetSoftwareId() SoftwareID: Text
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(SoftwareIDKeyTok, SoftwareID) then
            LogKeyVaultError('0000P7Q', 'Software ID', SoftwareIDKeyTok);
        if SoftwareID = '' then
            LogEmptyValueError('0000P7Q', 'Software ID', SoftwareIDKeyTok);
    end;

    procedure GetAPIClientIDFromKV(): Text[36]
    var
        APIClientID: Text;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(APIClientIDKeyTok, APIClientID) then
            FeatureTelemetry.LogError('0000P7R', Helper.GetIRISFeatureName(), '', StrSubstNo(CannotGetValueFromKeyVaultErr, 'API Client ID', APIClientIDKeyTok));
        if APIClientID = '' then
            FeatureTelemetry.LogError('0000P7R', Helper.GetIRISFeatureName(), '', StrSubstNo(ValueFromKeyVaultIsEmptyErr, 'API Client ID', APIClientIDKeyTok));
        exit(CopyStr(APIClientID, 1, 36));
    end;

    procedure GetJSONWebKeyID() KeyID: Text
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(JSONWebKeyIDKeyTok, KeyID) then
            LogKeyVaultError('0000P7S', 'JSON Web Key ID', JSONWebKeyIDKeyTok);
        if KeyID = '' then
            LogEmptyValueError('0000P7S', 'JSON Web Key ID', JSONWebKeyIDKeyTok);
    end;

    procedure GetAuthURL() AuthURL: Text
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(AuthURLKeyTok, AuthURL) then
            LogKeyVaultError('0000P7T', 'Auth URL', AuthURLKeyTok);
        if AuthURL = '' then
            LogEmptyValueError('0000P7T', 'Auth URL', AuthURLKeyTok);
    end;

    procedure GetConsentAppURL() ConsentAppURL: Text
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(ConsentAppURLKeyTok, ConsentAppURL) then
            FeatureTelemetry.LogError('0000P7U', Helper.GetIRISFeatureName(), '', StrSubstNo(CannotGetValueFromKeyVaultErr, 'Consent App URL', ConsentAppURLKeyTok));
        if ConsentAppURL = '' then
            FeatureTelemetry.LogError('0000P7U', Helper.GetIRISFeatureName(), '', StrSubstNo(ValueFromKeyVaultIsEmptyErr, 'Consent App URL', ConsentAppURLKeyTok));
    end;

    procedure GetContactInfo(var ContactName: Text; var ContactEmail: Text; var ContactPhone: Text)
    var
        ContactInfoJSONText: Text;
        ContactInfoJSON: JsonObject;
        JToken: JsonToken;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(ContactInfoKeyTok, ContactInfoJSONText) then begin
            FeatureTelemetry.LogError('0000PAB', Helper.GetIRISFeatureName(), '', StrSubstNo(CannotGetValueFromKeyVaultErr, 'Contact Info', ContactInfoKeyTok));
            exit;
        end;
        if ContactInfoJSONText = '' then begin
            FeatureTelemetry.LogError('0000PAB', Helper.GetIRISFeatureName(), '', StrSubstNo(ValueFromKeyVaultIsEmptyErr, 'Contact Info', ContactInfoKeyTok));
            exit;
        end;

        if not ContactInfoJSON.ReadFrom(ContactInfoJSONText) then begin
            FeatureTelemetry.LogError('0000PAB', Helper.GetIRISFeatureName(), '', ContactInfoIncorrectJSONErr);
            exit;
        end;

        if ContactInfoJSON.Get('ContactName', JToken) then
            ContactName := JToken.AsValue().AsText();
        if ContactInfoJSON.Get('ContactEmail', JToken) then
            ContactEmail := JToken.AsValue().AsText();
        if ContactInfoJSON.Get('ContactPhone', JToken) then
            ContactPhone := JToken.AsValue().AsText();
    end;

    procedure GetCertificate() Certificate: Text
    var
        CertificateName: Text;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(CertificateNameKeyTok, CertificateName) then
            LogKeyVaultError('0000P7V', 'Certificate Name', CertificateNameKeyTok);

        if not AzureKeyVault.GetAzureKeyVaultCertificate(CertificateName, Certificate) then
            LogKeyVaultError('0000P7W', 'Certificate', CertificateName);
    end;

    local procedure LogKeyVaultError(EventId: Text; ParameterName: Text; KeyName: Text)
    begin
        FeatureTelemetry.LogError(EventId, Helper.GetIRISFeatureName(), '', StrSubstNo(CannotGetValueFromKeyVaultErr, ParameterName, KeyName));
        if GuiAllowed() then
            Error(CannotGetValueUserErr, ParameterName);
    end;

    local procedure LogEmptyValueError(EventId: Text; ParameterName: Text; KeyName: Text)
    begin
        FeatureTelemetry.LogError(EventId, Helper.GetIRISFeatureName(), '', StrSubstNo(ValueFromKeyVaultIsEmptyErr, ParameterName, KeyName));
        if GuiAllowed() then
            Error(ValueIsEmptyUserErr, ParameterName);
    end;

    procedure TestMode(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if EnvironmentInformation.IsSandbox() then
            exit(true);

        exit(false);
    end;
}