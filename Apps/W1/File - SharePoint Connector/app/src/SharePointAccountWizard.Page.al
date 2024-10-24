// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

Using System.Environment;

/// <summary>
/// Displays an account that is being registered via the SharePoint connector.
/// </summary>
page 80301 "SharePoint Account Wizard"
{
    Caption = 'Setup SharePoint Account';
    SourceTable = "SharePoint Account";
    SourceTableTemporary = true;
    Permissions = tabledata "SharePoint Account" = rimd;
    PageType = NavigatePage;
    Extensible = false;
    Editable = true;

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
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = ' ';
                    Caption = ' ';
                }
            }

            field(NameField; Rec.Name)
            {
                ApplicationArea = All;
                Caption = 'Account Name';
                ToolTip = 'Specifies the name of the Azure SharePoint account.';
                ShowMandatory = true;
                NotBlank = true;

                trigger OnValidate()
                begin
                    IsNextEnabled := FileShareConnectorImpl.IsAccountValid(Rec);
                end;
            }

            field("Tenant Id"; Rec."Tenant Id")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Tenant Id of the App Registration.';
                ShowMandatory = true;

                trigger OnValidate()
                begin
                    IsNextEnabled := FileShareConnectorImpl.IsAccountValid(Rec);
                end;
            }

            field("Client Id"; Rec."Client Id")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the the Client Id of the App Registration.';
                ShowMandatory = true;

                trigger OnValidate()
                begin
                    IsNextEnabled := FileShareConnectorImpl.IsAccountValid(Rec);
                end;
            }

            field(ClientSecretField; ClientSecret)
            {
                ApplicationArea = All;
                Caption = 'Client Secret';
                ExtendedDatatype = Masked;
                ToolTip = 'Specifies the Client Secret of the App Registration.';
                ShowMandatory = true;
            }

            field("SharePoint Url"; Rec."SharePoint Url")
            {
                ApplicationArea = All;
                Caption = 'SharePoint Name';
                ToolTip = 'Specifies the SharePoint to use of the storage account.';
                ShowMandatory = true;

                trigger OnValidate()
                begin
                    IsNextEnabled := FileShareConnectorImpl.IsAccountValid(Rec);
                end;
            }

            field("Base Relative Folder Path"; Rec."Base Relative Folder Path")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Base Relative Folder Path to use for this account.';
                ShowMandatory = true;

                trigger OnValidate()
                begin
                    IsNextEnabled := FileShareConnectorImpl.IsAccountValid(Rec);
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
                ApplicationArea = All;
                Caption = 'Back';
                ToolTip = 'Back';
                Image = Cancel;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }

            action(Next)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Image = NextRecord;
                Enabled = IsNextEnabled;
                InFooterBar = true;
                ToolTip = 'Next';

                trigger OnAction()
                begin
                    FileShareConnectorImpl.CreateAccount(Rec, ClientSecret, FileShareAccount);
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        FileShareAccount: Record "File Account";
        MediaResources: Record "Media Resources";
        FileShareConnectorImpl: Codeunit "SharePoint Connector Impl.";
        [NonDebuggable]
        ClientSecret: Text;
        IsNextEnabled: Boolean;
        TopBannerVisible: Boolean;

    trigger OnOpenPage()
    var
        AssistedSetupLogoTok: Label 'ASSISTEDSETUP-NOTEXT-400PX.PNG', Locked = true;
    begin
        Rec.Init();
        Rec.Insert();

        if MediaResources.Get(AssistedSetupLogoTok) and (CurrentClientType() = ClientType::Web) then
            TopBannerVisible := MediaResources."Media Reference".HasValue();
    end;

    internal procedure GetAccount(var FileAccount: Record "File Account"): Boolean
    begin
        if IsNullGuid(FileShareAccount."Account Id") then
            exit(false);

        FileAccount := FileShareAccount;

        exit(true);
    end;
}