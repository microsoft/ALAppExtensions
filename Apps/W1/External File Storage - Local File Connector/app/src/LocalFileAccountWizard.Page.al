// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

Using System.Environment;

/// <summary>
/// Displays an account that is being registered via the File Share connector.
/// </summary>
page 4821 "Local File Account Wizard"
{
    Caption = 'Setup Local File Account';
    SourceTable = "Local File Account";
    SourceTableTemporary = true;
    Permissions = tabledata "Local File Account" = rimd;
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
                ToolTip = 'Specifies the name of the Azure File Share account.';
                ShowMandatory = true;
                NotBlank = true;

                trigger OnValidate()
                begin
                    IsNextEnabled := FileShareConnectorImpl.IsAccountValid(Rec);
                end;
            }
            field(BasePath; Rec."Base Path")
            {
                ApplicationArea = All;
                Caption = 'Base Path';
                ToolTip = 'Specifies the a base path of the account like D:\share\.';
                ShowMandatory = true;
                NotBlank = true;

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
                    FileShareConnectorImpl.CreateAccount(Rec, LocalFileAccount);
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        LocalFileAccount: Record "File Account";
        MediaResources: Record "Media Resources";
        FileShareConnectorImpl: Codeunit "Local File Connector Impl.";
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
        if IsNullGuid(LocalFileAccount."Account Id") then
            exit(false);

        FileAccount := LocalFileAccount;

        exit(true);
    end;
}