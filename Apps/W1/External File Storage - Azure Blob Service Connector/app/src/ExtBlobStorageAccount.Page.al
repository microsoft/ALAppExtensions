// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

/// <summary>
/// Displays an account that was registered via the Blob Storage connector.
/// </summary>
page 4560 "Ext. Blob Storage Account"
{
    ApplicationArea = All;
    Caption = 'Azure Blob Storage Account';
    DataCaptionExpression = Rec.Name;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    Permissions = tabledata "Ext. Blob Storage Account" = rimd;
    SourceTable = "Ext. Blob Storage Account";
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
            field(ContainerNameField; Rec."Container Name")
            {
                trigger OnLookup(var Text: Text): Boolean
                var
                    BlobStorageConnectorImpl: Codeunit "Ext. Blob Sto. Connector Impl.";
                    NewContainerName: Text[2048];
                begin
                    CurrPage.Update();
                    NewContainerName := CopyStr(Text, 1, MaxStrLen(NewContainerName));
                    BlobStorageConnectorImpl.LookUpContainer(Rec, Rec."Authorization Type", Rec.GetSecret(Rec."Secret Key"), NewContainerName);
                    Text := NewContainerName;
                    exit(true);
                end;
            }
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