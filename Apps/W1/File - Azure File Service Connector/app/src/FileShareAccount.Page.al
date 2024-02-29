// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

/// <summary>
/// Displays an account that was registered via the File Share connector.
/// </summary>
page 80200 "File Share Account"
{
    SourceTable = "File Share Account";
    Caption = 'Azure File Share Account';
    Permissions = tabledata "File Share Account" = rimd;
    PageType = Card;
    Extensible = false;
    InsertAllowed = false;
    DataCaptionExpression = Rec.Name;

    layout
    {
        area(Content)
        {
            field(NameField; Rec.Name)
            {
                ApplicationArea = All;
                Caption = 'Account Name';
                ToolTip = 'Specifies the name of the storage account connection.';
                ShowMandatory = true;
                NotBlank = true;
            }

            field(StorageAccountNameField; Rec."Storage Account Name")
            {
                ApplicationArea = All;
                Caption = 'Storage Account Name';
                ToolTip = 'Specifies the Azure Storage name.';
            }

            field(SASTokenField; SASToken)
            {
                ApplicationArea = All;
                Caption = 'SAS Token';
                Editable = PasswordEditable;
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the shared access signature to access the file share.';

                trigger OnValidate()
                begin
                    Rec.SetSAS(SASToken);
                end;
            }

            field(FileShareNameField; Rec."File Share Name")
            {
                ApplicationArea = All;
                Caption = 'File Share Name';
                ToolTip = 'Specifies the Azure File Share name.';
            }
        }
    }

    var
        PasswordEditable: Boolean;
        [NonDebuggable]
        SASToken: Text;

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey(Name);

        if not IsNullGuid(Rec."SAS Key") then
            SASToken := '***';
    end;

    trigger OnAfterGetCurrRecord()
    begin
        PasswordEditable := CurrPage.Editable();
    end;
}