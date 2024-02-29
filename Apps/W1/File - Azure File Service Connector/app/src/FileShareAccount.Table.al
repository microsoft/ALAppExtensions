// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

/// <summary>
/// Holds the information for all file accounts that are registered via the File Share connector
/// </summary>
table 80200 "File Share Account"
{
    Access = Internal;

    Caption = 'Azure File Share Account';

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
        field(4; "File Share Name"; Text[2048])
        {
            Caption = 'File Share Name';
        }
        field(8; "SAS Key"; Guid)
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
        UnableToGetPasswordMsg: Label 'Unable to get File Share Account Key';
        UnableToSetPasswordMsg: Label 'Unable to set File Share Account Key';

    trigger OnDelete()
    begin
        if not IsNullGuid(Rec."SAS Key") then
            if IsolatedStorage.Delete(Rec."SAS Key") then;
    end;

    [NonDebuggable]
    procedure SetSAS(SASToken: Text)
    begin
        if IsNullGuid(Rec."SAS Key") then
            Rec."SAS Key" := CreateGuid();

        if not IsolatedStorage.Set(Format(Rec."SAS Key"), SASToken, DataScope::Company) then
            Error(UnableToSetPasswordMsg);
    end;

    [NonDebuggable]
    procedure GetSAS(SASKey: Guid) Password: Text
    begin
        if not IsolatedStorage.Get(Format(SASKey), DataScope::Company, Password) then
            Error(UnableToGetPasswordMsg);
    end;
}