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
            field("SharePoint Url"; Rec."SharePoint Url") { }
            field("Base Relative Folder Path"; Rec."Base Relative Folder Path") { }
            field("Tenant Id"; Rec."Tenant Id") { }
            field("Client Id"; Rec."Client Id") { }
            field("Authentication Type"; Rec."Authentication Type")
            {
                ToolTip = 'Specifies the authentication method used for this SharePoint account.';

                trigger OnValidate()
                begin
                    UpdateAuthTypeVisibility();
                end;
            }
            field(SecretField; ClientSecret)
            {
                Caption = 'Client Secret';
                Editable = ClientSecretEditable;
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the Client Secret of the App Registration.';
                Visible = ClientSecretVisible;

                trigger OnValidate()
                begin
                    Rec.SetClientSecret(ClientSecret);
                end;
            }
            field(CertificateField; Certificate)
            {
                Caption = 'Certificate (Base64-encoded)';
                Editable = CertificateEditable;
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the Base64-encoded certificate for the Application (client) configured in the Azure Portal.';
                Visible = CertificateVisible;

                trigger OnValidate()
                begin
                    Rec.SetCertificate(Certificate);
                end;
            }
            field(CertificatePasswordField; CertificatePassword)
            {
                Caption = 'Certificate Password';
                Editable = CertificatePasswordEditable;
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the password for the certificate.';
                Visible = CertificatePasswordVisible;

                trigger OnValidate()
                begin
                    Rec.SetCertificatePassword(CertificatePassword);
                end;
            }
            field(Disabled; Rec.Disabled) { }
        }
    }

    var
        ClientSecretEditable: Boolean;
        ClientSecretVisible: Boolean;
        CertificateEditable: Boolean;
        CertificateVisible: Boolean;
        CertificatePasswordEditable: Boolean;
        CertificatePasswordVisible: Boolean;
        [NonDebuggable]
        ClientSecret: Text;
        [NonDebuggable]
        Certificate: Text;
        [NonDebuggable]
        CertificatePassword: Text;

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey(Name);
        UpdateAuthTypeVisibility();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        ClientSecretEditable := CurrPage.Editable();
        CertificateEditable := CurrPage.Editable();
        CertificatePasswordEditable := CurrPage.Editable();

        if not IsNullGuid(Rec."Client Secret Key") then
            ClientSecret := '***';

        if not IsNullGuid(Rec."Certificate Key") then
            Certificate := '***';

        if not IsNullGuid(Rec."Certificate Password Key") then
            CertificatePassword := '***';

        UpdateAuthTypeVisibility();
    end;

    local procedure UpdateAuthTypeVisibility()
    begin
        case Rec."Authentication Type" of
            Enum::"Ext. SharePoint Auth Type"::"Client Secret":
                begin
                    ClientSecretVisible := true;
                    CertificateVisible := false;
                    CertificatePasswordVisible := false;
                end;
            Enum::"Ext. SharePoint Auth Type"::Certificate:
                begin
                    ClientSecretVisible := false;
                    CertificateVisible := true;
                    CertificatePasswordVisible := true;
                end;
        end;
    end;
}