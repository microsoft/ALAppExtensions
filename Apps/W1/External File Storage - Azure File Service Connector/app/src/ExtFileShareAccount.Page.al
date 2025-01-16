// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

/// <summary>
/// Displays an account that was registered via the File Share connector.
/// </summary>
page 4570 "Ext. File Share Account"
{
    ApplicationArea = All;
    Caption = 'Azure File Share Account';
    DataCaptionExpression = Rec.Name;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    Permissions = tabledata "Ext. File Share Account" = rimd;
    SourceTable = "Ext. File Share Account";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            field(NameField; Rec.Name)
            {
                NotBlank = true;
                ShowMandatory = true;
            }
            field(StorageAccountNameField; Rec."Storage Account Name") { }
            field("Authorization Type"; Rec."Authorization Type") { }
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
            field(FileShareNameField; Rec."File Share Name") { }
            field(DisabledField; Rec.Disabled) { }
        }
    }

    var
        SecretEditable: Boolean;
        [NonDebuggable]
        Secret: Text;

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey(Name);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SecretEditable := CurrPage.Editable();
        if not IsNullGuid(Rec."Secret Key") then
            Secret := '***';
    end;
}