// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.AuditFileExport;
using System.Environment;
using System.Environment.Configuration;
using System.Security.Authentication;
using System.Utilities;

page 10696 "Elec. VAT Submission Wizard"
{
    Caption = 'Electronic VAT Submission Wizard';
    PageType = NavigatePage;
    RefreshOnActivate = true;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(StandardBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and not FinishActionEnabled;
                field(MediaResourcesStandard; MediaResourcesStd."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(FinishedBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and FinishActionEnabled;
                field(MediaResourcesDone; MediaResourcesFinished."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Start)
            {
                Visible = WelcomeStepVisible;
                group(Welcome)
                {
                    Caption = 'Welcome to the setup of Electronic VAT submission.';
                    Visible = WelcomeStepVisible;
                    group(WizardDescription)
                    {
                        Caption = '';
                        InstructionalText = 'This guide helps you to set up the integration with the ID-Porten and use the Skatteetaten API to submit VAT returns.';
                    }
                }
            }
            group(Authentication)
            {
                Visible = AuthenticationStepVisible;
                group(AuthenticationDetails)
                {
                    Caption = 'Set up the connection to the ID-Porten to use the Skatteetaten API.';
                    InstructionalText = 'Check your authorization status. If your status is Authorized, choose Next. If you are not authorized and have not yet specified the client ID and the client secret, choose Open Electronic VAT Setup. Then click the Status below to open the OAuth 2.0 setup page and use the Authorize action to complete the process.';
                }
                group(AuthenticationActionGroup)
                {
                    ShowCaption = false;
                    field(OpenElecVATSetupControl; OpenElecVATSetupLbl)
                    {
                        ShowCaption = false;
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        ToolTip = 'Opens the Electronic VAT Setup to specify client ID and client secret.';

                        trigger OnDrillDown()
                        begin
                            page.RunModal(Page::"Electronic VAT Setup Card");
                            ElecVATSetup.Get();
                        end;
                    }
                    field(AuthorizationStatusControl; StrSubstNo(StatusMsg, AuthorizationStatus))
                    {
                        ShowCaption = false;
                        ApplicationArea = Basic, Suite;
                        StyleExpr = AuthorizationStatusStyleExpr;
                        Editable = false;
                        ToolTip = 'Opens the OAuth 2.0 setup page where you can specify the data and authorize.';

                        trigger OnDrillDown()
                        var
                            OAuth20SetupPage: Page "OAuth 2.0 Setup";
                        begin
                            ElecVATSetup.TestField("Client ID");
                            ElecVATSetup.TestField("Client Secret");
                            OAuth20SetupPage.SetRecord(OAuth20Setup);
                            OAuth20SetupPage.RunModal();
                            OAuth20Setup.Find();
                            UpdateAuthorizationStatus();
                        end;
                    }
                }
            }
            group(VATCodes)
            {
                Visible = VATCodesStepVisible;
                group(VATCodesHeaderGroup)
                {
                    Caption = 'Set up your VAT Codes';
                    InstructionalText = 'Make sure your VAT codes are ready for reporting.';
                }
                group(AddVATCodesGroup)
                {
                    Visible = MissingVATCodesExist;
                    ShowCaption = false;
                    InstructionalText = 'One or more required codes does not exist. Click Show Codes to see missing codes. Click Add Codes to add missing codes.';
                    field(ShowMissingCodesControl; ShowCodesLbl)
                    {
                        ShowCaption = false;
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        ToolTip = 'Opens the list of missing VAT codes.';

                        trigger OnDrillDown()
                        begin
                            Page.Run(Page::"VAT Reporting Codes", TempMissingVATReportingCode);
                        end;
                    }
                    field(AddMissingCodesControl; AddCodesLbl)
                    {
                        ShowCaption = false;
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        ToolTip = 'Adds missing VAT codes.';

                        trigger OnDrillDown()
                        begin
                            ElecVATDataMgt.AddVATReportingCodes(TempMissingVATReportingCode);
                            Message(MissingCodesAddedLbl);
                        end;
                    }
                }
                group(UpdateVATCodesGroup)
                {
                    ShowCaption = false;
                    InstructionalText = 'Some of the VAT codes must be set up to also report the VAT rate. Choose Update to make sure all the VAT codes are ready for reporting.';
                    field(AlreadyUpdatedVATCodesControl; VATCodesUpdatedText)
                    {
                        Caption = 'Codes for reporting VAT rate:';
                        ToolTip = 'Specifies how many VAT codes are marked to report VAT Rate.';
                        ApplicationArea = Basic, Suite;
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            Page.Run(Page::"VAT Reporting Codes");
                        end;
                    }
                    field(UpdateVATCodesControl; UpdateLbl)
                    {
                        ShowCaption = false;
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        ToolTip = 'Updates the VAT codes that are required to report VAT rate and assigns the relevant VAT rate.';

                        trigger OnDrillDown()
                        var
                            ElecVATDataMgt: Codeunit "Elec. VAT Data Mgt.";
                        begin
                            ElecVATDataMgt.SetVATRatesForReportingOnVATReportingCodes();
                            SetVATCodesUpdatedText();
                        end;
                    }
                }
            }
            group(VATStatement)
            {
                Visible = VATStatementStepVisible;
                Caption = 'VAT Statement';
                InstructionalText = 'Create a VAT statement with all required VAT codes. Make sure that VAT codes are specified in the VAT posting setup in advance. Select the template name, specify the name of the VAT statement and click Create VAT statement. If you do not want to create a VAT statement, click Next.';

                group(VATStatementActionGroup)
                {
                    ShowCaption = false;
                    field(OpenVATPostingSetupControl; OpenVATPostingSetupLbl)
                    {
                        ShowCaption = false;
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        ToolTip = 'Opens the VAT posting setup page.';

                        trigger OnDrillDown()
                        begin
                            Page.Run(Page::"SAF-T VAT Posting Setup");
                        end;
                    }
                    field(VATStatementTemplateNameControl; VATStatementTemplateName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'VAT Statement Template Name';
                        ToolTip = 'Specifies the name of the template.';
                        ShowMandatory = true;
                        TableRelation = "VAT Statement Template";
                    }
                    field(VATStatementNameControl; VATStatementName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'VAT Statement Name';
                        ToolTip = 'Specifies the name for the new VAT statement.';
                        ShowMandatory = true;
                    }
                    field(CreateVATStatementControl; CreateVATStatementLbl)
                    {
                        ShowCaption = false;
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        ToolTip = 'Creates the VAT statement with required VAT codes.';

                        trigger OnDrillDown()
                        var
                            VATStatement: Record "VAT Statement Name";
                            ConfirmMgt: Codeunit "Confirm Management";
                            VATSmtMgt: Codeunit VATStmtManagement;
                        begin
                            ElecVATDataMgt.CreateVATStatement(VATStatementTemplateName, VATStatementName);
                            if ConfirmMgt.GetResponse(VATStatementCreatedQst, true) then begin
                                VATStatement.Get(VATStatementTemplateName, VATStatementName);
                                VATSmtMgt.TemplateSelectionFromBatch(VATStatement);
                            end;
                        end;
                    }
                }
            }
            group(FinishedParent)
            {
                ShowCaption = false;
                Visible = FinishActionEnabled;
                group(FinishedChild)
                {
                    Caption = 'The Electronic VAT submission setup is complete.';
                    Visible = FinishActionEnabled;
                    group(FinishDescription)
                    {
                        Caption = '';
                        InstructionalText = 'You''re ready to create and submit VAT returns.';
                    }
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;
                trigger OnAction();
                begin
                    FinishAction();
                end;
            }
        }
    }

    var
        ElecVATSetup: Record "Elec. VAT Setup";
        TempMissingVATReportingCode: Record "VAT Reporting Code" temporary;
        OAuth20Setup: Record "OAuth 2.0 Setup";
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesFinished: Record "Media Resources";
        MediaResourcesStd: Record "Media Resources";
        ElecVATDataMgt: Codeunit "Elec. VAT Data Mgt.";
        Step: Option Start,Authentication,VATCodes,VATStatement,Finish;
        AuthorizationStatus: Option "Not authorized",Authorized;
        VATStatementTemplateName: Code[10];
        VATStatementName: Code[10];
        AuthorizationStatusStyleExpr: Text;
        VATCodesUpdatedText: Text;
        TopBannerVisible: Boolean;
        WelcomeStepVisible: Boolean;
        AuthenticationStepVisible: Boolean;
        VATCodesStepVisible: Boolean;
        VATStatementStepVisible: Boolean;
        BackActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        MissingVATCodesExist: Boolean;
        SetupNotCompletedQst: Label 'A setup has not been completed.\\Are you sure that you want to exit?';
        AuthorizationNotCompletedQst: Label 'The authorization has not been completed. You would not be able to submit your VAT return electronically. Do you want to continue?';
        ShowCodesLbl: Label 'Show Codes';
        AddCodesLbl: Label 'Add Codes';
        UpdateLbl: Label 'Update';
        OpenElecVATSetupLbl: Label 'Open Electronic VAT Setup';
        OpenVATPostingSetupLbl: Label 'Open VAT Posting Setup';
        CreateVATStatementLbl: Label 'Create VAT statement';
        MissingCodesAddedLbl: Label 'Missing VAT codes have been added.';
        VATStatementCreatedQst: Label 'VAT statement has been successfully created. Do you want to view it now?';
        PartInfoMsg: Label '%1/%2', Comment = '%1,%2 = numbers', Locked = true;
        StatusMsg: Label 'Status: %1', Comment = '%1 = either "not authorized" or "authorized';

    trigger OnInit();
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage()
    var
        ElectronicVATInstallation: Codeunit "Electronic VAT Installation";
        ElecVATOAuthMgt: Codeunit "Elec. VAT OAuth Mgt.";
    begin
        ElectronicVATInstallation.RunExtensionSetup();
        ElecVATSetup.Get();
        ElecVATOAuthMgt.GetOAuthSetup(OAuth20Setup);
        UpdateAuthorizationStatus();
        ElecVATDataMgt.InsertMissingVATSpecificationsAndNotes();
        MissingVATCodesExist := ElecVATDataMgt.GetMissingVATReportingCodes(TempMissingVATReportingCode);
        SetVATCodesUpdatedText();
        EnableControls();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean;
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if GetLastErrorText() <> '' then
            exit(true);
        if CloseAction = CloseAction::OK then
            If not GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, Page::"Elec. VAT Submission Wizard") then
                if not Confirm(SetupNotCompletedQst) then
                    Error('');
    end;

    local procedure LoadTopBanners();
    begin
        if MediaRepositoryStandard.GET('AssistedSetup-NoText-400px.png', FORMAT(CurrentClientType())) AND
           MediaRepositoryDone.GET('AssistedSetupDone-NoText-400px.png', FORMAT(CurrentClientType()))
        then
            if MediaResourcesStd.GET(MediaRepositoryStandard."Media Resources Ref") AND
                MediaResourcesFinished.GET(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesFinished."Media Reference".HasValue();
    end;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowWelcomeStep();
            Step::Authentication:
                ShowAuthenticationStep();
            Step::VATCodes:
                ShowVATCodesStep();
            Step::VATStatement:
                ShowVATStatementStep();
            Step::Finish:
                ShowFinish();
        end;
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        if not ValidateControlsBeforeStep(Backwards) then
            exit;
        if Backwards then
            Step := Step - 1
        ELSE
            Step := Step + 1;
        EnableControls();
    end;

    local procedure ResetControls();
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        WelcomeStepVisible := false;
        AuthenticationStepVisible := false;
        VATCodesStepVisible := false;
        VATStatementStepVisible := false;
    end;

    local procedure ValidateControlsBeforeStep(Backwards: Boolean): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if (not Backwards) and WelcomeStepVisible and (not ElecVATSetup.Enabled) then
            if not ConfirmCustomerConsent() then
                exit(false);
        if (Not Backwards) and AuthenticationStepVisible and (AuthorizationStatus <> AuthorizationStatus::Authorized) then
            if not ConfirmManagement.GetResponse(AuthorizationNotCompletedQst, false) then
                exit(false);
        exit(true);
    end;

    local procedure ShowWelcomeStep();
    begin
        WelcomeStepVisible := true;
        AuthenticationStepVisible := false;
        BackActionEnabled := false;
        NextActionEnabled := true;
        AuthenticationStepVisible := false;
        VATCodesStepVisible := false;
        VATStatementStepVisible := false;
        FinishActionEnabled := false;
    end;

    local procedure ShowAuthenticationStep()
    begin
        WelcomeStepVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        AuthenticationStepVisible := true;
        VATCodesStepVisible := false;
        VATStatementStepVisible := false;
        FinishActionEnabled := false;
    end;

    local procedure ShowVATCodesStep()
    begin
        WelcomeStepVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        AuthenticationStepVisible := false;
        VATCodesStepVisible := true;
        VATStatementStepVisible := false;
        FinishActionEnabled := false;
    end;

    local procedure ShowVATStatementStep()
    begin
        WelcomeStepVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        AuthenticationStepVisible := false;
        VATCodesStepVisible := false;
        VATStatementStepVisible := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowFinish()
    begin
        WelcomeStepVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := false;
        AuthenticationStepVisible := false;
        VATCodesStepVisible := false;
        VATStatementStepVisible := false;
        FinishActionEnabled := true;
    end;

    local procedure FinishAction();
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Elec. VAT Submission Wizard");
        ElecVATSetup.Enabled := true;
        ElecVATSetup.Modify(true);
        CurrPage.Close();
    end;

    local procedure ConfirmCustomerConsent(): Boolean
    begin
        ElecVATSetup.Validate(Enabled, true);
        exit(ElecVATSetup.Enabled);
    end;

    local procedure UpdateAuthorizationStatus()
    begin
        if OAuth20Setup.Status = OAuth20Setup.Status::Enabled then begin
            AuthorizationStatus := AuthorizationStatus::Authorized;
            AuthorizationStatusStyleExpr := 'Favorable';
        end else begin
            AuthorizationStatus := AuthorizationStatus::"Not authorized";
            AuthorizationStatusStyleExpr := 'Unfavorable';
        end;
        CurrPage.Update(false);
    end;

    local procedure SetVATCodesUpdatedText()
    var
        VATReportingCode: Record "VAT Reporting Code";
        TotalCount: Integer;
    begin
        TotalCount := VATReportingCode.Count();
        VATReportingCode.SetRange("Report VAT Rate", true);
        VATCodesUpdatedText := StrSubstNo(PartInfoMsg, VATReportingCode.Count(), TotalCount);
    end;
}
