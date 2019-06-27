// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 2507 "Upload And Deploy Extension"
{
    Extensible = false;
    PageType = NavigatePage;
    SourceTable = "NAV App";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            label("Upload Extension")
            {
                ApplicationArea = All;
                Caption = 'Upload Extension';
                Style = StrongAccent;
                StyleExpr = TRUE;
            }
            field(FileName; FileName)
            {
                ApplicationArea = All;
                Caption = 'Select .app file';
                Editable = false;

                trigger OnAssistEdit()
                begin
                    UploadIntoStream(DialogTitleTxt, '', FromFilterTxt, FileName, FileStream);
                end;
            }
            label(Control11)
            {
                ShowCaption = false;
            }
            label("Deploy Extension")
            {
                ApplicationArea = All;
                Caption = 'Deploy Extension';
                Style = StrongAccent;
                StyleExpr = TRUE;
            }
            field(DeployTo; DeployTo)
            {
                ApplicationArea = All;
                Caption = 'Deploy to';
            }
            field(Language; LanguageName)
            {
                ApplicationArea = All;
                Caption = 'Language';
                Editable = false;

                trigger OnAssistEdit()
                var
                    LanguageManagement: Codeunit "Language Management";
                begin
                    LanguageManagement.LookupApplicationLanguageId(LanguageID);
                    LanguageName := LanguageManagement.GetWindowsLanguageNameByLanguageId(LanguageID);
                end;
            }
            field(Disclaimer; DisclaimerLbl)
            {
                ApplicationArea = All;
                Editable = false;
                ShowCaption = false;
                Style = None;

                trigger OnDrillDown()
                begin
                    Message(DisclaimerMsg);
                end;
            }
            field(Accepted; Accepted)
            {
                ApplicationArea = All;
                Caption = 'Accept';
                ToolTip = 'Specifies that you accept Disclaimer.';
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Deploy)
            {
                ApplicationArea = All;
                Caption = 'Deploy';
                Enabled = Accepted;
                InFooterBar = true;
                Promoted = true;
                RunPageMode = Edit;

                trigger OnAction()
                var
                    ExtensionOperationImpl: Codeunit "Extension Operation Impl";
                begin
                    if FileName = '' then
                        Message(ExtensionNotUploadedMsg)
                    else begin
                        ExtensionOperationImpl.DeployAndUploadExtension(FileStream, LanguageID, DeployTo);
                        CurrPage.Close();
                    end;
                end;
            }
            action(Cancel)
            {
                ApplicationArea = All;
                Image = Cancel;
                Caption = 'Cancel';
                InFooterBar = true;
                RunPageMode = Edit;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        LanguageManagement: Codeunit "Language Management";
    begin
        LanguageID := GlobalLanguage();
        LanguageName := LanguageManagement.GetWindowsLanguageNameByLanguageId(LanguageID);
    end;

    var
        FileStream: InStream;
        DeployTo: Option "Current version","Next minor version","Next major version";
        FileName: Text;
        LanguageName: Text;
        LanguageID: Integer;
        DialogTitleTxt: Label 'ENU=Select .APP';
        FromFilterTxt: Label 'ENU=Extension Files|*.app';
        ExtensionNotUploadedMsg: Label 'Please upload an extension file before clicking "Deploy" button.';
        DisclaimerLbl: Label 'Disclaimer';
        DisclaimerMsg: Label 'The creator of this customized extension is responsible for its licensing. The customized extension is subject to the terms and conditions, privacy policy, support and billing offered by the creator, as applicable, and does not create any liability or obligation for Microsoft.\\The publisher of the customized extension must maintain compatibility with new releases of Dynamics 365 Business Central. An extension that is not compatible with a new release within 90 days of the release will be removed and the tenant upgraded.';
        Accepted: Boolean;
}

