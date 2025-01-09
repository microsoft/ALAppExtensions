// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

/// <summary>
/// Displays an account that was registered via the SharePoint connector.
/// </summary>
page 4580 "Ext. SharePoint Account"
{
    SourceTable = "Ext. SharePoint Account";
    Caption = 'SharePoint Account';
    Permissions = tabledata "Ext. SharePoint Account" = rimd;
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

            field("Tenant Id"; Rec."Tenant Id")
            {
            }

            field("Client Id"; Rec."Client Id")
            {
            }

            field(SecretField; ClientSecret)
            {
                Caption = 'Password';
                Editable = ClientSecretEditable;
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the the Client Secret of the App Registration.';

                trigger OnValidate()
                begin
                    Rec.SetClientSecret(ClientSecret);
                end;
            }

            field("SharePoint Url"; Rec."SharePoint Url")
            {
                Caption = 'SharePoint Url';
            }

            field("Base Relative Folder Path"; Rec."Base Relative Folder Path")
            {
            }
        }
    }

    var
        ClientSecretEditable: Boolean;
        [NonDebuggable]
        ClientSecret: Text;

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey(Name);

        if not IsNullGuid(Rec."Client Secret Key") then
            ClientSecret := '***';
    end;

    trigger OnAfterGetCurrRecord()
    begin
        ClientSecretEditable := CurrPage.Editable();
    end;
}