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
            ToolTip = 'Specifies the name of the storage account connection.';
        }
        field(4; "SharePoint Url"; Text[2048])
        {
            Caption = 'SharePoint Url';
            ToolTip = 'Specifies the the url to your SharePoint site.';
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
            ToolTip = 'Specifies the Tenant Id of the App Registration.';
        }
        field(7; "Client Id"; Guid)
        {
            Access = Internal;
            Caption = 'Client Id';
            ToolTip = 'Specifies the the Client Id of the App Registration.';
        }
        field(8; "Client Secret Key"; Guid)
        {
            Access = Internal;
            DataClassification = SystemMetadata;
        }
        field(9; Disabled; Boolean)
        {
            Caption = 'Disabled';
            ToolTip = 'Specifies if the account is disabled. This happens automatically when a sandbox is created.';
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

    trigger OnDelete()
    begin
        if not IsNullGuid(Rec."Client Secret Key") then
            if IsolatedStorage.Delete(Rec."Client Secret Key") then;
    end;

    procedure SetClientSecret(ClientSecret: SecretText)
    begin
        if IsNullGuid(Rec."Client Secret Key") then
            Rec."Client Secret Key" := CreateGuid();

        if not IsolatedStorage.Set(Format(Rec."Client Secret Key"), ClientSecret, DataScope::Company) then
            Error(UnableToSetClientSecretMsg);
    end;

    procedure GetClientSecret(ClientSecretKey: Guid) ClientSecret: SecretText
    begin
        if not IsolatedStorage.Get(Format(ClientSecretKey), DataScope::Company, ClientSecret) then
            Error(UnableToGetClientMsg);
    end;
}