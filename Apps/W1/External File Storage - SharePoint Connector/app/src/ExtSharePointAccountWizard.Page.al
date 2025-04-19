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
                ToolTip = 'Specifies the name of the Azure SharePoint account.';

                trigger OnValidate()
                begin
                    IsNextEnabled := SharePointConnectorImpl.IsAccountValid(Rec);
                end;
            }

            field("Tenant Id"; Rec."Tenant Id")
            {
                ShowMandatory = true;

                trigger OnValidate()
                begin
                    IsNextEnabled := SharePointConnectorImpl.IsAccountValid(Rec);
                end;
            }

            field("Client Id"; Rec."Client Id")
            {
                ShowMandatory = true;

                trigger OnValidate()
                begin
                    IsNextEnabled := SharePointConnectorImpl.IsAccountValid(Rec);
                end;
            }

            field("Authentication Type"; Rec."Authentication Type")
            {
                ToolTip = 'Specifies the authentication method used for this SharePoint account.';

                trigger OnValidate()
                begin
                    UpdateAuthTypeVisibility();
                    IsNextEnabled := SharePointConnectorImpl.IsAccountValid(Rec);
                end;
            }

            field(ClientSecretField; ClientSecret)
            {
                Caption = 'Client Secret';
                ExtendedDatatype = Masked;
                ShowMandatory = true;
                ToolTip = 'Specifies the Client Secret of the App Registration.';
                Visible = ClientSecretVisible;
            }

            field(CertificateField; Certificate)
            {
                Caption = 'Certificate (Base64-encoded)';
                ExtendedDatatype = Masked;
                ShowMandatory = true;
                ToolTip = 'Specifies the Base64-encoded certificate for the Application (client) configured in the Azure Portal.';
                Visible = CertificateVisible;
            }

            field(CertificatePasswordField; CertificatePassword)
            {
                Caption = 'Certificate Password';
                ExtendedDatatype = Masked;
                ShowMandatory = false;
                ToolTip = 'Specifies the password for the certificate.';
                Visible = CertificatePasswordVisible;
            }

            field("SharePoint Url"; Rec."SharePoint Url")
            {
                Caption = 'SharePoint Name';
                ShowMandatory = true;
                ToolTip = 'Specifies the SharePoint to use of the storage account.';

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
        [NonDebuggable]
        Certificate: Text;
        [NonDebuggable]
        CertificatePassword: Text;
        IsNextEnabled: Boolean;
        TopBannerVisible: Boolean;
        ClientSecretVisible: Boolean;
        CertificateVisible: Boolean;
        CertificatePasswordVisible: Boolean;

    trigger OnOpenPage()
    var
        AssistedSetupLogoTok: Label 'ASSISTEDSETUP-NOTEXT-400PX.PNG', Locked = true;
    begin
        Rec.Init();
        Rec.Insert();

        if MediaResources.Get(AssistedSetupLogoTok) and (CurrentClientType() = ClientType::Web) then
            TopBannerVisible := MediaResources."Media Reference".HasValue();

        UpdateAuthTypeVisibility();
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