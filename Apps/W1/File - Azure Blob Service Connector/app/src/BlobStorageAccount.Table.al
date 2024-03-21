// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

/// <summary>
/// Holds the information for all file accounts that are registered via the Blob Storage connector
/// </summary>
table 80100 "Blob Storage Account"
{
    Access = Internal;

    Caption = 'Azure Blob Storage Account';

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
        field(3; "Storage Account Name"; Text[2048])
        {
            Caption = 'Storage Account Name';
        }
        field(4; "Container Name"; Text[2048])
        {
            Caption = 'Container Name';
        }
        field(7; "Authorization Type"; Enum "Blob Storage Auth. Type")
        {
            Caption = 'Authorization Type';
        }
        field(8; "Secret Key"; Guid)
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
        UnableToGetSecretMsg: Label 'Unable to get Blob Storage secret.';
        UnableToSetSecretMsg: Label 'Unable to set Blob Storage secret.';

    trigger OnDelete()
    begin
        if not IsNullGuid(Rec."Secret Key") then
            if IsolatedStorage.Delete(Rec."Secret Key") then;
    end;

    procedure SetSecret(Secret: Text)
    begin
        if IsNullGuid(Rec."Secret Key") then
            Rec."Secret Key" := CreateGuid();

        if not IsolatedStorage.Set(Format(Rec."Secret Key"), Secret, DataScope::Company) then
            Error(UnableToSetSecretMsg);
    end;

    procedure GetSecret(SecretKey: Guid) Secret: SecretText
    begin
        if not IsolatedStorage.Get(Format(SecretKey), DataScope::Company, Secret) then
            Error(UnableToGetSecretMsg);
    end;
}