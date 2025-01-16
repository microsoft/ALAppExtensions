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
    ApplicationArea = All;
    Caption = 'SharePoint Account';
    DataCaptionExpression = Rec.Name;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    Permissions = tabledata "Ext. SharePoint Account" = rimd;
    SourceTable = "Ext. SharePoint Account";
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
            field("Tenant Id"; Rec."Tenant Id") { }
            field("Client Id"; Rec."Client Id") { }
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
            field("SharePoint Url"; Rec."SharePoint Url") { }
            field("Base Relative Folder Path"; Rec."Base Relative Folder Path") { }
            field(Disabled; Rec.Disabled) { }
        }
    }

    var
        ClientSecretEditable: Boolean;
        [NonDebuggable]
        ClientSecret: Text;

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey(Name);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        ClientSecretEditable := CurrPage.Editable();
        if not IsNullGuid(Rec."Client Secret Key") then
            ClientSecret := '***';
    end;
}