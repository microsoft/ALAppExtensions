// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

Using System.Environment;

/// <summary>
/// Displays an account that is being registered via the SharePoint connector.
/// </summary>
page 4581 "Ext. SharePoint Account Wizard"
{
    ApplicationArea = All;
    Caption = 'Setup SharePoint Account';
    Editable = true;
    Extensible = false;
    PageType = NavigatePage;
    Permissions = tabledata "Ext. SharePoint Account" = rimd;
    SourceTable = "Ext. SharePoint Account";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(TopBanner)
            {
                Editable = false;
                ShowCaption = false;
                Visible = TopBannerVisible;
                field(NotDoneIcon; MediaResources."Media Reference")
                {
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = ' ', Locked = true;
                }
            }

            field(NameField; Rec.Name)
            {
                Caption = 'Account Name';
                NotBlank = true;
                ShowMandatory = true;
                ToolTip = 'Specifies a descriptive name for this SharePoint storage account connection.';

                trigger OnValidate()
                begin
                    IsNextEnabled := SharePointConnectorImpl.IsAccountValid(Rec);
                end;
            }

            field("Tenant Id"; Rec."Tenant Id")
            {
                ShowMandatory = true;
                ToolTip = 'Specifies the Microsoft Entra ID Tenant ID (Directory ID) where your SharePoint site and app registration are located.';

                trigger OnValidate()
                begin
                    IsNextEnabled := SharePointConnectorImpl.IsAccountValid(Rec);
                end;
            }

            field("Client Id"; Rec."Client Id")
            {
                ShowMandatory = true;
                ToolTip = 'Specifies the Client ID (Application ID) of the App Registration in Microsoft Entra ID.';

                trigger OnValidate()
                begin
                    IsNextEnabled := SharePointConnectorImpl.IsAccountValid(Rec);
                end;
            }

            field("Authentication Type"; Rec."Authentication Type")
            {
                ToolTip = 'Specifies the authentication flow used for this SharePoint account. Client Secret uses User grant flow, which means that the user must sign in when using this account. Certificate uses Client credentials flow, which means that the user does not need to sign in when using this account.';
                trigger OnValidate()
                begin
                    UpdateAuthTypeVisibility();
                    IsNextEnabled := SharePointConnectorImpl.IsAccountValid(Rec);
                end;
            }
            group(SharePointClientSecretCredentials)
            {
                ShowCaption = false;
                Visible = ClientSecretVisible;

                field(ClientSecretField; ClientSecret)
                {
                    Caption = 'Client Secret';
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the Client Secret value from the App Registration in Microsoft Entra ID. This value is used to authenticate the connection to SharePoint.';
                }
            }

            group(SharePointCertificateCredentials)
            {
                ShowCaption = false;
                Visible = CertificateVisible;

                field(CertificateUploadStatus; CertificateStatusText)
                {
                    Caption = 'Certificate';
                    Editable = false;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the certificate file used for authentication. Click here to upload a certificate file (.pfx, .cer, or .crt).';

                    trigger OnDrillDown()
                    begin
                        Certificate := Rec.UploadCertificateFile();
                        UpdateCertificateStatus();
                        IsNextEnabled := SharePointConnectorImpl.IsAccountValid(Rec);
                    end;
                }

                field(CertificatePasswordField; CertificatePassword)
                {
                    Caption = 'Certificate Password';
                    ExtendedDatatype = Masked;
                    ShowMandatory = false;
                    ToolTip = 'Specifies the password used to protect the private key in the certificate. Leave empty if the certificate is not password-protected.';
                }
            }
            field("SharePoint Url"; Rec."SharePoint Url")
            {
                Caption = 'SharePoint Name';
                ShowMandatory = true;

                trigger OnValidate()
                begin
                    IsNextEnabled := SharePointConnectorImpl.IsAccountValid(Rec);
                end;
            }

            field("Base Relative Folder Path"; Rec."Base Relative Folder Path")
            {
                ShowMandatory = true;

                trigger OnValidate()
                begin
                    IsNextEnabled := SharePointConnectorImpl.IsAccountValid(Rec);
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Back)
            {
                Caption = 'Back';
                Image = Cancel;
                InFooterBar = true;
                ToolTip = 'Move to previous step.';

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
            action(Next)
            {
                Caption = 'Next';
                Enabled = IsNextEnabled;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Move to next step.';

                trigger OnAction()
                var
                    SecretToPass: SecretText;
                begin
                    case Rec."Authentication Type" of
                        Enum::"Ext. SharePoint Auth Type"::"Client Secret":
                            SecretToPass := ClientSecret;
                        Enum::"Ext. SharePoint Auth Type"::Certificate:
                            SecretToPass := Certificate;
                    end;

                    SharePointConnectorImpl.CreateAccount(Rec, SecretToPass, CertificatePassword, SharePointAccount);
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        SharePointAccount: Record "File Account";
        MediaResources: Record "Media Resources";
        SharePointConnectorImpl: Codeunit "Ext. SharePoint Connector Impl";
        [NonDebuggable]
        ClientSecret: Text;
        Certificate: SecretText;
        [NonDebuggable]
        CertificatePassword: Text;
        CertificateStatusText: Text;
        IsNextEnabled: Boolean;
        TopBannerVisible: Boolean;
        ClientSecretVisible: Boolean;
        CertificateVisible: Boolean;

    trigger OnOpenPage()
    var
        AssistedSetupLogoTok: Label 'ASSISTEDSETUP-NOTEXT-400PX.PNG', Locked = true;
    begin
        Rec.Init();
        Rec.Insert();

        if MediaResources.Get(AssistedSetupLogoTok) and (CurrentClientType() = ClientType::Web) then
            TopBannerVisible := MediaResources."Media Reference".HasValue();

        UpdateAuthTypeVisibility();
        UpdateCertificateStatus();
    end;

    internal procedure GetAccount(var FileAccount: Record "File Account"): Boolean
    begin
        if IsNullGuid(SharePointAccount."Account Id") then
            exit(false);

        FileAccount := SharePointAccount;

        exit(true);
    end;

    local procedure UpdateAuthTypeVisibility()
    begin
        ClientSecretVisible := Rec."Authentication Type" = Enum::"Ext. SharePoint Auth Type"::"Client Secret";
        CertificateVisible := Rec."Authentication Type" = Enum::"Ext. SharePoint Auth Type"::Certificate;

        if CertificateVisible then
            UpdateCertificateStatus();
    end;

    local procedure UpdateCertificateStatus()
    var
        NoCertificateUploadedLbl: Label 'Click to upload certificate file...';
        CertificateUploadedLbl: Label 'Certificate uploaded (click to change)';
    begin
        if Certificate.IsEmpty() then
            CertificateStatusText := NoCertificateUploadedLbl
        else
            CertificateStatusText := CertificateUploadedLbl;
    end;
}