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
        field(8; "Password Key"; Guid)
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
        UnableToGetPasswordMsg: Label 'Unable to get Blob Storage Account Key';
        UnableToSetPasswordMsg: Label 'Unable to set Blob Storage Account Key';

    trigger OnDelete()
    begin
        if not IsNullGuid(Rec."Password Key") then
            if IsolatedStorage.Delete(Rec."Password Key") then;
    end;

    [NonDebuggable]
    procedure SetPassword(Password: Text)
    begin
        if IsNullGuid(Rec."Password Key") then
            Rec."Password Key" := CreateGuid();

        if not IsolatedStorage.Set(Format(Rec."Password Key"), Password, DataScope::Company) then
            Error(UnableToSetPasswordMsg);
    end;

    [NonDebuggable]
    procedure GetPassword(PasswordKey: Guid) Password: SecretText
    begin
        if not IsolatedStorage.Get(Format(PasswordKey), DataScope::Company, Password) then
            Error(UnableToGetPasswordMsg);
    end;
}