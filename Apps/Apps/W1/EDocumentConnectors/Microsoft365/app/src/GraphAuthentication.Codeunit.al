// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using System.Environment;
using System.Security.Authentication;
using System.Azure.KeyVault;

codeunit 6383 "Graph Authentication"
{
    Access = Internal;

    internal procedure GetAccessToken(var Token: SecretText)
    var
        OAuth2: Codeunit OAuth2;
        FirstPartyAppId: Text;
        FirstPartyAppCertificate: SecretText;
        RedirectUrl, ResourceURL, AuthorityURL, AuthError : Text;
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            Error(AvailableOnlyOnSaaSErr);

        FirstPartyAppId := GetFirstPartyAppId();
        FirstPartyAppCertificate := GetFirstPartyAppCertificate();
        AuthorityURL := GetOAuthAuthorityURL();
        RedirectURL := GetRedirectURL();
        ResourceURL := GetResourceURL();

        if (FirstPartyAppId = '') or FirstPartyAppCertificate.IsEmpty() then
            Error(MissingFirstPartyappIdOrCertificateTelemetryTxt);

        if OAuth2.AcquireAuthorizationCodeTokenFromCacheWithCertificate(FirstPartyAppId, FirstPartyAppCertificate, RedirectUrl, AuthorityURL, ResourceURL, Token) then
            if not Token.IsEmpty() then begin
                Session.LogMessage('0000NWC', StrSubstNo(AcquiredTokenFromCacheTelemetry1PAppMsg, FirstPartyAppId, ResourceURL), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryLbl);
                exit;
            end;

        if OAuth2.AcquireTokenByAuthorizationCodeWithCertificate(FirstPartyAppId, FirstPartyAppCertificate, AuthorityURL, RedirectURL, ResourceURL, Enum::"Prompt Interaction"::"Select Account", Token, AuthError) then
            if not Token.IsEmpty() then begin
                Session.LogMessage('0000NWD', StrSubstNo(AcquiredTokenTelemetry1PAppMsg, FirstPartyAppId, ResourceURL), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryLbl);
                exit;
            end;

        Session.LogMessage('0000NWE', StrSubstNo(EmptyTokenTelemetry1PAppMsg, FirstPartyAppId, ResourceURL), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryLbl);
    end;

    [NonDebuggable]
    procedure GetFirstPartyAppId(): Text
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        ClientId: Text;
    begin
        if EnvironmentInformation.IsSaaSInfrastructure() then
            if not AzureKeyVault.GetAzureKeyVaultSecret(BCToGraphAppIdSecretNameLbl, ClientId) then
                Session.LogMessage('0000NWF', MissingFirstPartyappIdOrCertificateTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryLbl)
            else
                exit(ClientId);
        exit(ClientId);
    end;

    [NonDebuggable]
    procedure GetFirstPartyAppCertificate(): SecretText;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        Certificate: SecretText;
        CertificateName: Text;
    begin
        if EnvironmentInformation.IsSaaSInfrastructure() then
            if not AzureKeyVault.GetAzureKeyVaultSecret(BCToGraphAppCertificateNameSecretNameLbl, CertificateName) then begin
                Session.LogMessage('0000EBV', MissingFirstPartyappIdOrCertificateTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryLbl);
                exit(Certificate);
            end;

        if not AzureKeyVault.GetAzureKeyVaultCertificate(CertificateName, Certificate) then
            Session.LogMessage('0000EC2', MissingFirstPartyappIdOrCertificateTelemetryTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryLbl);

        exit(Certificate);
    end;

    local procedure GetOAuthAuthorityURL(): Text
    begin
        exit(OAuthAuthorityUrlLbl);
    end;

    local procedure GetResourceURL(): Text
    begin
        exit(GraphApiUrlTxt);
    end;

    local procedure GetRedirectURL(): Text
    begin
        if EnvironmentInformation.IsSaaSInfrastructure() then
            exit('');
    end;

    var
        EnvironmentInformation: Codeunit "Environment Information";
        GraphApiUrlTxt: Label 'https://graph.microsoft.com', Locked = true;
        OAuthAuthorityUrlLbl: Label 'https://login.microsoftonline.com/common/oauth2', Locked = true;
        EmptyTokenTelemetry1PAppMsg: Label 'Empty access token from 1P App %1 for resource %2.', Locked = true;
        AcquiredTokenTelemetry1PAppMsg: Label 'Access token acquired via 1P App %1 for resource %2.', Locked = true;
        AcquiredTokenFromCacheTelemetry1PAppMsg: Label 'Access token acquired from cache via 1P App %1 for resource %2.', Locked = true;
        BCToGraphAppIdSecretNameLbl: Label 'BCToGraphAppId', Locked = true;
        BCToGraphAppCertificateNameSecretNameLbl: Label 'BCToGraphCertificateName', Locked = true;
        MissingFirstPartyappIdOrCertificateTelemetryTxt: Label 'The OAuth2 app id or certificate have not been initialized. Note that this functionality is available only on fully Microsoft-hosted environemnts, excluding Embed ISV environments.', Locked = true;
        CategoryLbl: Label 'EDoc Connector M365', Locked = true;
        AvailableOnlyOnSaaSErr: Label 'This functionality is available only when running on Business Central Online environment.';
}