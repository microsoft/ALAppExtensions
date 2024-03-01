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

            field("Authorization Type"; Rec."Authorization Type")
            {
                ApplicationArea = All;
                ToolTip = 'The way of authorizing used to access the Blob Storage.';
            }

            field(SecretField; Secret)
            {
                ApplicationArea = All;
                Caption = 'Password';
                Editable = SecretEditable;
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the Shared access signature Token or SharedKey.';

                trigger OnValidate()
                begin
                    Rec.SetSecret(Secret);
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
        SecretEditable: Boolean;
        [NonDebuggable]
        Secret: Text;

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey(Name);

        if not IsNullGuid(Rec."Secret Key") then
            Secret := '***';
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SecretEditable := CurrPage.Editable();
    end;
}