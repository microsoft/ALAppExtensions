// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Allows users to upload an extension and schedule its deployment.
/// </summary>
page 2507 "Upload And Deploy Extension"
{
    Extensible = false;
    PageType = NavigatePage;
    SourceTable = "Published Application";
    SourceTableTemporary = true;
    ContextSensitiveHelpPage = 'ui-extensions';

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
            field(FileName; FilePath)
            {
                ApplicationArea = All;
                Caption = 'Select .app file';
                ToolTip = 'Specifies the file path of the extension.';
                Editable = false;

                trigger OnAssistEdit()
                begin
                    UploadIntoStream(DialogTitleTxt, '', AppFileFilterTxt, FilePath, FileStream);
                end;
            }
            label("Deploy Extension")
            {
                ApplicationArea = All;
                Caption = 'Deploy Extension';
                Style = StrongAccent;
                StyleExpr = TRUE;
            }
            field(DeployTo; DeployToValue)
            {
                ApplicationArea = All;
                Caption = 'Deploy to';
                ToolTip = 'Specifies which version to deploy to.';
            }
            field(Language; LanguageName)
            {
                ApplicationArea = All;
                Caption = 'Language';
                ToolTip = 'Language';
                Editable = false;

                trigger OnAssistEdit()
                var
                    LanguageManagement: Codeunit Language;
                begin
                    LanguageManagement.LookupApplicationLanguageId(LanguageID);
                    LanguageName := LanguageManagement.GetWindowsLanguageName(LanguageID);
                end;
            }
            field(SyncMode; SyncModeValue)
            {
                ApplicationArea = All;
                Caption = 'Schema Sync Mode';
                ToolTip = 'Specifies how to update the database schema for the extension. The Add option will warn you if the schemas are incompatible and will not apply the change. Force Sync will overwrite the current schema with the new version without warning. Force Sync can lead to data loss.';

                trigger OnValidate()
                begin
                    if SyncModeValue = SyncModeValue::"Force Sync" then
                        if not Confirm(ForceSyncQst, false) then
                            SyncModeValue := SyncModeValue::Add;
                end;
            }
            field(Disclaimer; DisclaimerLbl)
            {
                ApplicationArea = All;
                Caption = 'Disclaimer';
                ToolTip = 'View the disclaimer.';
                Editable = false;
                ShowCaption = false;
                Style = None;

                trigger OnDrillDown()
                begin
                    Message(DisclaimerMsg);
                end;
            }
            field(Accepted; IsAccepted)
            {
                ApplicationArea = All;
                Caption = 'Accept';
                ToolTip = 'Specifies that you accept Disclaimer.';
            }
            field(BestPractices; 'Read more about the best practices for installing and publishing extensions')
            {
                ApplicationArea = All;
                ShowCaption = false;
                Editable = false;
                ToolTip = 'Read more about the best practices for installing and publishing extensions.';

                trigger OnDrillDown()
                var
                    ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
                begin
                    Hyperlink(ExtensionInstallationImpl.GetInstallationBestPracticesURL());
                end;
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
                ToolTip = 'Deploy';
                Image = ServiceOrderSetup;
                Enabled = IsAccepted;
                InFooterBar = true;
                Promoted = true;
                RunPageMode = Edit;

                trigger OnAction()
                var
                    ExtensionOperationImpl: Codeunit "Extension Operation Impl";
                begin
                    if FilePath = '' then
                        Message(ExtensionNotUploadedMsg)
                    else begin
                        ExtensionOperationImpl.DeployAndUploadExtension(FileStream, LanguageID, DeployToValue, SyncModeValue);
                        CurrPage.Close();
                    end;
                end;
            }
            action(Cancel)
            {
                ApplicationArea = All;
                Image = Cancel;
                Caption = 'Cancel';
                ToolTip = 'Cancel';
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
        LanguageManagement: Codeunit Language;
    begin
        LanguageID := GlobalLanguage();
        LanguageName := LanguageManagement.GetWindowsLanguageName(LanguageID);
    end;

    var
        FileStream: InStream;
        DeployToValue: Enum "Extension Deploy To";
        FilePath: Text;
        LanguageName: Text;
        LanguageID: Integer;
        SyncModeValue: Enum "Extension Sync Mode";
        ForceSyncQst: Label 'Are you sure that you want to force the schema update for this extension? Forcing schema updates can lead to unintentional data loss if invoked improperly.';
        DialogTitleTxt: Label 'Select .APP';
        AppFileFilterTxt: Label 'Extension Files|*.app', Locked = true;
        ExtensionNotUploadedMsg: Label 'Please upload an extension file before clicking "Deploy" button.';
        DisclaimerLbl: Label 'Disclaimer';
        DisclaimerMsg: Label 'The creator of this customized extension is responsible for its licensing. The customized extension is subject to the terms and conditions, privacy policy, support and billing offered by the creator, as applicable, and does not create any liability or obligation for Microsoft.\\The publisher of the customized extension must maintain compatibility with new releases of Dynamics 365 Business Central. An extension that is not compatible with a new release within 90 days of the release will be removed and the tenant upgraded.';
        IsAccepted: Boolean;
}

