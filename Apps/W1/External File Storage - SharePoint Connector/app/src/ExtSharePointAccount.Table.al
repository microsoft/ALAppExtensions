// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

/// <summary>
/// Holds the information for all file accounts that are registered via the SharePoint connector
/// </summary>
table 4580 "Ext. SharePoint Account"
{
    Caption = 'SharePoint Account';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Id"; Guid)
        {
            AllowInCustomizations = Never;
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; Name; Text[250])
        {
            Caption = 'Account Name';
            ToolTip = 'Specifies a descriptive name for this SharePoint storage account connection.';
        }
        field(4; "SharePoint Url"; Text[2048])
        {
            Caption = 'SharePoint Url';
            ToolTip = 'Specifies the complete URL to your SharePoint site (e.g., https://mysharepoint.sharepoint.com/sites/ProjectX). This is the site URL where your documents will be stored.';
        }
        field(5; "Base Relative Folder Path"; Text[2048])
        {
            Caption = 'Base Relative Folder Path';
            ToolTip = 'Specifies the folder path relative to the site collection. Start with the document library or folder name (e.g., Shared Documents/Reports). This path can be copied from the URL of the folder in SharePoint after the site collection (e.g., /Shared Documents/Reports from https://mysharepoint.sharepoint.com/sites/ProjectX/Shared%20Documents/Reports).';
        }
        field(6; "Tenant Id"; Guid)
        {
            Access = Internal;
            Caption = 'Tenant Id';
            ToolTip = 'Specifies the Microsoft Entra ID Tenant ID (Directory ID) where your SharePoint site and app registration are located.';
        }
        field(7; "Client Id"; Guid)
        {
            Access = Internal;
            Caption = 'Client Id';
            ToolTip = 'Specifies the Client ID (Application ID) of the App Registration in Microsoft Entra ID.';
        }
        field(8; "Client Secret Key"; Guid)
        {
            Access = Internal;
            DataClassification = SystemMetadata;
        }
        field(9; Disabled; Boolean)
        {
            Caption = 'Disabled';
            ToolTip = 'Specifies if the account is disabled. Accounts are automatically disabled when a sandbox environment is created from production.';
        }
        field(10; "Authentication Type"; Enum "Ext. SharePoint Auth Type")
        {
            Caption = 'Authentication Type';
            ToolTip = 'Specifies the authentication flow used for this SharePoint account. Client Secret uses User grant flow, which means that the user must sign in when using this account. Certificate uses Client credentials flow, which means that the user does not need to sign in when using this account.';
            InitValue = "Client Secret";
        }
        field(11; "Certificate Key"; Guid)
        {
            Access = Internal;
            DataClassification = SystemMetadata;
        }
        field(12; "Certificate Password Key"; Guid)
        {
            Access = Internal;
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

    var
        UnableToGetClientMsg: Label 'Unable to get SharePoint Account Client Secret.';
        UnableToSetClientSecretMsg: Label 'Unable to set SharePoint Client Secret.';
        UnableToGetCertificateMsg: Label 'Unable to get SharePoint Account Certificate.';
        UnableToSetCertificateMsg: Label 'Unable to set SharePoint Certificate.';
        UnableToGetCertificatePasswordMsg: Label 'Unable to get SharePoint Account Certificate Password.';
        UnableToSetCertificatePasswordMsg: Label 'Unable to set SharePoint Certificate Password.';

    trigger OnDelete()
    begin
        TryDeleteIsolatedStorageValue(Rec."Client Secret Key");
        TryDeleteIsolatedStorageValue(Rec."Certificate Key");
        TryDeleteIsolatedStorageValue(Rec."Certificate Password Key");
    end;

#pragma warning disable AS0022
    internal procedure SetClientSecret(ClientSecret: SecretText)
    begin
        if IsNullGuid(Rec."Client Secret Key") then
            Rec."Client Secret Key" := CreateGuid();

        SetIsolatedStorageValue(Rec."Client Secret Key", ClientSecret, UnableToSetClientSecretMsg);

        // When setting client secret, clear certificate authentication 
        // as only one authentication method can be active
        ClearCertificateAuthentication();
    end;

    local procedure ClearCertificateAuthentication()
    begin
        if not IsNullGuid(Rec."Certificate Key") then begin
            TryDeleteIsolatedStorageValue(Rec."Certificate Key");
            Clear(Rec."Certificate Key");
        end;
        if not IsNullGuid(Rec."Certificate Password Key") then begin
            TryDeleteIsolatedStorageValue(Rec."Certificate Password Key");
            Clear(Rec."Certificate Password Key");
        end;
    end;

    internal procedure GetClientSecret(ClientSecretKey: Guid): SecretText
    begin
        exit(GetIsolatedStorageValue(ClientSecretKey, UnableToGetClientMsg));
    end;

    internal procedure SetCertificate(Certificate: SecretText)
    begin
        if IsNullGuid(Rec."Certificate Key") then
            Rec."Certificate Key" := CreateGuid();

        SetIsolatedStorageValue(Rec."Certificate Key", Certificate, UnableToSetCertificateMsg);

        // When setting certificate, clear client secret authentication
        // as only one authentication method can be active
        ClearClientSecretAuthentication();
    end;
#pragma warning restore AS0022

    local procedure ClearClientSecretAuthentication()
    begin
        if not IsNullGuid(Rec."Client Secret Key") then begin
            TryDeleteIsolatedStorageValue(Rec."Client Secret Key");
            Clear(Rec."Client Secret Key");
        end;
    end;

    internal procedure GetCertificate(CertificateKey: Guid): SecretText
    begin
        exit(GetIsolatedStorageValue(CertificateKey, UnableToGetCertificateMsg));
    end;

    internal procedure SetCertificatePassword(CertificatePassword: SecretText)
    begin
        if IsNullGuid(Rec."Certificate Password Key") then
            Rec."Certificate Password Key" := CreateGuid();

        SetIsolatedStorageValue(Rec."Certificate Password Key", CertificatePassword, UnableToSetCertificatePasswordMsg);
    end;

    internal procedure GetCertificatePassword(CertificatePasswordKey: Guid): SecretText
    begin
        exit(GetIsolatedStorageValue(CertificatePasswordKey, UnableToGetCertificatePasswordMsg));
    end;

    local procedure TryDeleteIsolatedStorageValue(StorageKey: Guid)
    begin
        if not IsNullGuid(StorageKey) then
            if IsolatedStorage.Delete(StorageKey) then;
    end;

    local procedure SetIsolatedStorageValue(StorageKey: Guid; Value: SecretText; ErrorMessage: Text)
    begin
        if not IsolatedStorage.Set(Format(StorageKey), Value, DataScope::Company) then
            Error(ErrorMessage);
    end;

    local procedure GetIsolatedStorageValue(StorageKey: Guid; ErrorMessage: Text) Value: SecretText
    begin
        if not IsolatedStorage.Get(Format(StorageKey), DataScope::Company, Value) then
            Error(ErrorMessage);
    end;

    /// <summary>
    /// Opens a file dialog and uploads a certificate file, converting it to base64 format.
    /// </summary>
    /// <param name="ErrorOnFailure">Specifies whether to throw an error if the upload fails.</param>
    internal procedure UploadCertificateFile() CertificateBase64: SecretText
    var
        Base64Convert: Codeunit System.Text."Base64 Convert";
        UploadResult: Boolean;
        InStr: InStream;
        CertificateFilterTxt: Label 'Certificate Files (*.pfx;*.p12)|*.pfx;*.p12|All Files (*.*)|*.*';
        FileNotUploadedErr: Label 'Certificate file was not uploaded.';
    begin
        UploadResult := UploadIntoStream(CertificateFilterTxt, InStr);

        if not UploadResult then
            Error(FileNotUploadedErr);

        CertificateBase64 := Base64Convert.ToBase64(InStr);
        exit(CertificateBase64);
    end;
}