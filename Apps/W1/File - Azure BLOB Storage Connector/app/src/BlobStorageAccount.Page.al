// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

/// <summary>
/// Displays an account that was registered via the Blob Storage connector.
/// </summary>
page 80100 "Blob Storage Account"
{
    SourceTable = "Blob Storage Account";
    Caption = 'Azure Blob Storage Account';
    Permissions = tabledata "Blob Storage Account" = rimd;
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
                ToolTip = 'Specifies the name of the Storage account connection.';
                ShowMandatory = true;
                NotBlank = true;
            }

            field(StorageAccountNameField; Rec."Storage Account Name")
            {
                ApplicationArea = All;
                Caption = 'Storage Account Name';
                ToolTip = 'Specifies the Azure Storage name.';
            }

            field(Password; Password)
            {
                ApplicationArea = All;
                Caption = 'Password';
                Editable = PasswordEditable;
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the shared key to access the Storage Blob.';

                trigger OnValidate()
                begin
                    Rec.SetPassword(Password);
                end;
            }

            field(ContainerNameField; Rec."Container Name")
            {
                ApplicationArea = All;
                Caption = 'Container Name';
                ToolTip = 'Specifies the Azure Storage Container name.';
            }
        }
    }

    var
        PasswordEditable: Boolean;
        [NonDebuggable]
        Password: Text;

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey(Name);

        if not IsNullGuid(Rec."Password Key") then
            Password := '***';
    end;
}