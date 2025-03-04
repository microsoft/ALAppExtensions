// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

Using System.Environment;

/// <summary>
/// Displays an account that is being registered via the Local File connector.
/// </summary>
page 4821 "Ext. Local File Account Wizard"
{
    Caption = 'Setup Local File Account';
    Editable = true;
    Extensible = false;
    PageType = NavigatePage;
    Permissions = tabledata "Ext. Local File Account" = rimd;
    SourceTable = "Ext. Local File Account";
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
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = ' ', Locked = true;
                }
            }
            field(NameField; Rec.Name)
            {
                ApplicationArea = All;
                NotBlank = true;
                ShowMandatory = true;
                ToolTip = 'Specifies the name of the Local File account.';

                trigger OnValidate()
                begin
                    IsNextEnabled := FileShareConnectorImpl.IsAccountValid(Rec);
                end;
            }
            field(BasePath; Rec."Base Path")
            {
                ApplicationArea = All;
                NotBlank = true;
                ShowMandatory = true;
                ToolTip = 'Specifies the a base path of the account like D:\share\.';

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
                Image = Cancel;
                InFooterBar = true;
                ToolTip = 'Move to the previous step.';

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }

            action(Next)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = IsNextEnabled;
                Image = NextRecord;
                InFooterBar = true;
                ToolTip = 'Move to the next step.';

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
        FileShareConnectorImpl: Codeunit "Ext. Local File Connector Impl";
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