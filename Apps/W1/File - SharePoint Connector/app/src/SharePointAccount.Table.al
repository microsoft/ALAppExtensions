// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

/// <summary>
/// Holds the information for all file accounts that are registered via the SharePoint connector
/// </summary>
table 80300 "SharePoint Account"
{
    Access = Internal;

    Caption = 'SharePoint Account';

    fields
    {
        field(1; "Id"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Primary Key';
        }

        field(2; Name; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Name of account';
        }
        field(4; "SharePoint Url"; Text[2048])
        {
            Caption = 'SharePoint Url';
        }
        field(5; "Base Relative Folder Path"; Text[2048])
        {
            Caption = 'Base Relative Folder Path';
        }
        field(6; "Tenant Id"; Text[36])
        {
            Caption = 'Tenant Id';
        }
        field(7; "Client Id"; Text[36])
        {
            Caption = 'Client Id';
        }
        field(8; "Client Secret Key"; Guid)
        {
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

    trigger OnDelete()
    begin
        if not IsNullGuid(Rec."Client Secret Key") then
            if IsolatedStorage.Delete(Rec."Client Secret Key") then;
    end;

    [NonDebuggable]
    procedure SetClientSecret(ClientSecret: SecretText)
    begin
        if IsNullGuid(Rec."Client Secret Key") then
            Rec."Client Secret Key" := CreateGuid();

        if not IsolatedStorage.Set(Format(Rec."Client Secret Key"), ClientSecret, DataScope::Company) then
            Error(UnableToSetClientSecretMsg);
    end;

    [NonDebuggable]
    procedure GetClientSecret(ClientSecretKey: Guid) ClientSecret: SecretText
    begin
        if not IsolatedStorage.Get(Format(ClientSecretKey), DataScope::Company, ClientSecret) then
            Error(UnableToGetClientMsg);
    end;
}