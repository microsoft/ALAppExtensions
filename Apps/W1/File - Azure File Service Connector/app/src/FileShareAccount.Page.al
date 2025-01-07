// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

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
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            field(NameField; Rec.Name)
            {
                Caption = 'Account Name';
                ShowMandatory = true;
                NotBlank = true;
            }

            field(StorageAccountNameField; Rec."Storage Account Name")
            {
                Caption = 'Storage Account Name';
            }

            field("Authorization Type"; Rec."Authorization Type")
            {
            }

            field(SecretField; Secret)
            {
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
                Caption = 'File Share Name';
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