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
                trigger OnValidate()
                begin
                    MaskSensitiveFields();
                    UpdateAuthTypeVisibility();
                    CurrPage.Update(true);
                end;
            }
            group(Credentials)
            {
                Caption = 'Credentials';
                Editable = IsPageEditable;

                group(SharePointClientSecretGroup)
                {
                    ShowCaption = false;
                    Visible = ClientSecretVisible;

                    field(SecretField; ClientSecret)
                    {
                        Caption = 'Client Secret';
                        ExtendedDatatype = Masked;
                        ToolTip = 'Specifies the Client Secret value from the App Registration in Microsoft Entra ID. This value is used to authenticate the connection to SharePoint.';

                        trigger OnValidate()
                        begin
                            Rec.SetClientSecret(ClientSecret);
                        end;
                    }
                }
                group(SharePointCertificateGroup)
                {
                    ShowCaption = false;
                    Visible = CertificateVisible;

                    field(CertificateField; Certificate)
                    {
                        Caption = 'Certificate (Base64-encoded)';
                        ExtendedDatatype = Masked;
                        ToolTip = 'Specifies the Base64-encoded certificate for the Application (client) configured in Microsoft Entra ID. This provides a more secure authentication method than Client Secret.';

                        trigger OnValidate()
                        begin
                            Rec.SetCertificate(Certificate);
                        end;
                    }

                    field(CertificatePasswordField; CertificatePassword)
                    {
                        Caption = 'Certificate Password';
                        ExtendedDatatype = Masked;
                        ToolTip = 'Specifies the password used to protect the private key in the certificate. Leave empty if the certificate is not password-protected.';

                        trigger OnValidate()
                        begin
                            Rec.SetCertificatePassword(CertificatePassword);
                        end;
                    }
                }
            }
            field(Disabled; Rec.Disabled) { }
        }
    }

    var
        IsPageEditable: Boolean;
        ClientSecretVisible: Boolean;
        CertificateVisible: Boolean;
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
        IsPageEditable := CurrPage.Editable();

        MaskSensitiveFields();
        UpdateAuthTypeVisibility();
    end;

    local procedure MaskSensitiveFields()
    begin
        Clear(ClientSecret);
        Clear(Certificate);
        Clear(CertificatePassword);

        if not IsNullGuid(Rec."Client Secret Key") then
            ClientSecret := '***';

        if not IsNullGuid(Rec."Certificate Key") then
            Certificate := '***';

        if not IsNullGuid(Rec."Certificate Password Key") then
            CertificatePassword := '***';
    end;

    local procedure UpdateAuthTypeVisibility()
    begin
        ClientSecretVisible := Rec."Authentication Type" = Enum::"Ext. SharePoint Auth Type"::"Client Secret";
        CertificateVisible := Rec."Authentication Type" = Enum::"Ext. SharePoint Auth Type"::Certificate;
    end;
}