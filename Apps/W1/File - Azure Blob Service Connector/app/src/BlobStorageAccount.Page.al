// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

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

            field(ContainerNameField; Rec."Container Name")
            {
                ApplicationArea = All;
                Caption = 'Container Name';
                ToolTip = 'Specifies the Azure Storage Container name.';

                trigger OnLookup(var Text: Text): Boolean
                var
                    BlobStorageConnectorImpl: Codeunit "Blob Storage Connector Impl.";
                begin
                    CurrPage.Update();
                    BlobStorageConnectorImpl.LookUpContainer(Rec, Rec."Authorization Type", Rec.GetSecret(Rec."Secret Key"), Text);
                    exit(true);
                end;
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