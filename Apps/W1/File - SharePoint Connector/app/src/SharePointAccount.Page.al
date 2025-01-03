// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

/// <summary>
/// Displays an account that was registered via the SharePoint connector.
/// </summary>
page 80300 "SharePoint Account"
{
    SourceTable = "SharePoint Account";
    Caption = 'SharePoint Account';
    Permissions = tabledata "SharePoint Account" = rimd;
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

            field("Tenant Id"; Rec."Tenant Id")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Tenant Id of the App Registration.';
            }

            field("Client Id"; Rec."Client Id")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the the Client Id of the App Registration.';
            }

            field(SecretField; ClientSecret)
            {
                ApplicationArea = All;
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
                ApplicationArea = All;
                Caption = 'SharePoint Url';
                ToolTip = 'Specifies the the url to your SharePoint site.';
            }

            field("Base Relative Folder Path"; Rec."Base Relative Folder Path")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Base Relative Folder Path to use for this account.';
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