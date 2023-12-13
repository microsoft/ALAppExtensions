// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Environment;
using System.Telemetry;
using System.Utilities;

page 5314 "SIE Setup Wizard"
{
    Caption = 'SIE Audit File Export Setup Guide';
    PageType = NavigatePage;
    SourceTable = "G/L Account Mapping Header";
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
                    Caption = 'Welcome to the setup of SIE';
                    Visible = WelcomeStepVisible;
                    group(SIEDescription)
                    {
                        Caption = '';
                        InstructionalText = 'The SIE (Standard Import Export) is a standard file format for exporting various types of accounting transactional data. This guide helps you set up SIE for Dynamics 365 Business Central. If you do not want to set this up right now, close this page.';
                    }
                }
            }

            group(ChooseStandardAccTypeParent)
            {
                Visible = StandardAccTypeStepVisible;
                group(MappingSourceNotLoaded)
                {
                    Caption = 'Select the standard chart of accounts';
                    InstructionalText = 'When sending your SIE file to the tax authorities, each G/L account must be mapped to a financial standard account.';
                }
                group(MappingSourceLoaded)
                {
                    ShowCaption = false;
                    InstructionalText = 'Specify the preferred standard account type and choose Next.';
                }
                group(StandardAccTypeChild)
                {
                    ShowCaption = false;
                    field(StandardAccountTypeField; Rec."Standard Account Type")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                        Caption = 'Standard Account Type';
                        ToolTip = 'Specifies the type of the standard general ledger accounts.';
                    }
                }
            }

            group(ChooseMappingRangeParent)
            {
                Visible = MappingRangeStepVisible;
                group(ChooseMappingRangeChild)
                {
                    Caption = 'Specify the period of the first SIE file';
                    InstructionalText = 'Specify the period of the first SIE file. Choose Next to map your chart of accounts to the values that SIE requires.';

                    field(PeriodType; Rec."Period Type")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Accounting Period Type';
                        ToolTip = 'Specifies the type of the accounting period.';
                        Editable = false;
                    }
                    field(AccountingPeriod; Rec."Accounting Period")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Accounting Period';
                        ToolTip = 'Specifies the starting date of the accounting period.';
                    }
                    field(StartingDate; Rec."Starting Date")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Starting Date';
                        ToolTip = 'Specifies the starting date of the period in which the mapping is valid.';
                    }
                    field(EndingDate; Rec."Ending Date")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Ending Date';
                        ToolTip = 'Specifies the ending date of the period in which the mapping is valid.';
                    }
                }
            }

            group(DoMappingParent)
            {
                ShowCaption = false;
                Visible = MappingAccountVisible;
                group(DoMappingGeneral)
                {
                    Caption = 'Map SIE accounts to your chart of accounts';
                    InstructionalText = 'For each general ledger account, select the SIE account.';
                }
                group(OpenMappingSetupGroup)
                {
                    ShowCaption = false;
                    field(OpenMappingSetup; OpenMappingSetupLbl)
                    {
                        ShowCaption = false;
                        StyleExpr = true;
                        Style = StandardAccent;
                        ApplicationArea = Basic, Suite;

                        trigger OnDrillDown()
                        var
                            GLAccMappingCard: Page "G/L Acc. Mapping Card";
                        begin
                            GLAccMappingCard.SetTableView(Rec);
                            GLAccMappingCard.RunModal();
                            UpdateGLAccountsMappedInfo();
                        end;
                    }
                    field(GLAccountsMappedInfo; GLAccountsMapped)
                    {
                        Caption = 'G/L Accounts Mapped:';
                        Editable = false;
                        ToolTip = 'Specifies the number of mapped G/L accounts out of the total number of G/L accounts to map.';
                        ApplicationArea = Basic, Suite;
                    }
                }
            }

            group(DimensionExportParent)
            {
                ShowCaption = false;
                Visible = DimensionExportVisible;
                group(DimensionExportGeneral)
                {
                    Caption = 'Export dimensions to SIE';
                    InstructionalText = 'Add SIE dimensions if necessary, and set Selected for those dimensions which must be exported to the SIE file. You can update the dimensions later on the Dimensions SIE page.';
                }
                group(OpenDimensionExportGroup)
                {
                    ShowCaption = false;
                    field(OpenDimensionExport; OpenDimensionExportSetupLbl)
                    {
                        ShowCaption = false;
                        StyleExpr = true;
                        Style = StandardAccent;
                        ApplicationArea = Basic, Suite;

                        trigger OnDrillDown()
                        var
                            DimensionsSIE: Page "Dimensions SIE";
                        begin
#if not CLEAN22
                            DimensionsSIE.SetRunFromWizard(true);
#endif
                            DimensionsSIE.RunModal();
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
                    Caption = 'The SIE setup is completed!';
                    Visible = FinishActionEnabled;
                    group(FinishDescription)
                    {
                        Caption = '';
                        InstructionalText = 'You''re ready to use the SIE functionality. Do an additional mapping on the G/L Account Mapping page if needed. Open the Audit File Export Document page to export the data in the SIE format.';
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

    trigger OnQueryClosePage(CloseAction: action): Boolean;
    begin
        if GetLastErrorText() <> '' then
            exit(true);
        if CloseAction = CloseAction::OK then
            if not SetupCompleted then
                if not Confirm(SetupNotCompletedQst) then
                    Error('');
    end;

    trigger OnInit();
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage();
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        AuditFileExportFormatSetup: Record "Audit File Export Format Setup";
        AuditMappingHelper: Codeunit "Audit Mapping Helper";
        SIEManagement: Codeunit "SIE Management";
        AuditFileExportFormat: Enum "Audit File Export Format";
    begin
#if not CLEAN22
        if not SIEManagement.IsFeatureEnabled() then
            if not IsRunFromFeatureMgt then begin
                SIEManagement.ShowNotEnabledMessage(CurrPage.Caption());
                Error('');
            end;
#endif
        FeatureTelemetry.LogUptake('0000JPP', SIEExportTok, Enum::"Feature Uptake Status"::Discovered);
        Commit();

        AuditFileExportSetup.InitSetup(AuditFileExportFormat::SIE);
        AuditFileExportFormatSetup.InitSetup(AuditFileExportFormat::SIE, SIEManagement.GetAuditFileName(), false);
        AuditMappingHelper.GetDefaultGLAccountMappingHeader(Rec, Enum::"Audit File Export Format"::SIE);
        Rec.SetRecFilter();
        Step := Step::Start;
        EnableControls();
    end;

    var
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesFinished: Record "Media Resources";
        MediaResourcesStd: Record "Media Resources";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SIEExportTok: label 'SIE Export Data', Locked = true;
        Step: Option Start,StandardAccType,MappingSourceLoaded,MappingAccount,DimensionExport,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        WelcomeStepVisible: Boolean;
        StandardAccTypeStepVisible: Boolean;
        MappingRangeStepVisible: Boolean;
        MappingAccountVisible: Boolean;
        DimensionExportVisible: Boolean;
        TopBannerVisible: Boolean;
        SetupCompleted: Boolean;
#if not CLEAN22
        IsRunFromFeatureMgt: Boolean;
#endif
        GLAccountsMapped: Text[20];
        StandardAccTypeNotSpecifiedErr: label 'A standard account type is not specified.';
        SetupNotCompletedQst: label 'Set up SIE has not been completed.\\Are you sure that you want to exit?', Comment = '%1 = Set-up of SIE';
        MappingSourceNotLoadedMsg: label 'A source for mapping was not loaded due to the following error: %1.', Comment = '%1 - error text';
        MappingRangeNotSetupMsg: label 'A mapping range was not set up due to the following error: %1.', Comment = '%1 - error text';
        OpenMappingSetupLbl: label 'Open the setup page to define G/L account mappings.';
        OpenDimensionExportSetupLbl: label 'Open the setup page to define which dimensions to export to SIE.';

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowWelcomeStep();
            Step::StandardAccType:
                ShowStandardAccTypeStep();
            Step::MappingSourceLoaded:
                ShowMappingSourceLoadedStep();
            Step::MappingAccount:
                ShowMappingAccountStep();
            Step::DimensionExport:
                ShowDimensionExport();
            Step::Finish:
                ShowFinish();
        end;
    end;

    local procedure FinishAction();
    begin
        FeatureTelemetry.LogUptake('0000JPQ', SIEExportTok, Enum::"Feature Uptake Status"::"Set up");
        SetupCompleted := true;
        CurrPage.Close();
    end;

    procedure IsSetupCompleted(): Boolean
    begin
        exit(SetupCompleted);
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        DoActionOnNext(Step, Backwards);
        ValidateControlsBeforeStep(Backwards);
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;
        EnableControls();
    end;

    local procedure DoActionOnNext(CurrentStep: Option; Backward: Boolean)
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
    begin
        case CurrentStep of
            Step::StandardAccType:
                if not Backward then begin
                    LoadStandardAccounts(Rec."Standard Account Type");
                    AuditFileExportSetup.UpdateStandardAccountType(Rec."Standard Account Type");
                end;
        end;
    end;

    local procedure ValidateControlsBeforeStep(Backwards: Boolean)
    var
        AuditMappingHelper: Codeunit "Audit Mapping Helper";
        ImportAuditDataMgt: Codeunit "Import Audit Data Mgt.";
    begin
        if StandardAccTypeStepVisible and (Rec."Standard Account Type" = Rec."Standard Account Type"::None) then
            Error(StandardAccTypeNotSpecifiedErr);
        if StandardAccTypeStepVisible and (not Backwards) then begin
            ClearLastError();
            Commit();
            if not ImportAuditDataMgt.Run(Rec) then
                Error(MappingSourceNotLoadedMsg, GetLastErrorText());
            UpdateGLAccountsMappedInfo();
        end;

        if MappingRangeStepVisible then begin
            AuditMappingHelper.ValidateGLAccMapping(Rec);
            Commit();
            if not Backwards then begin
                ClearLastError();
                if not AuditMappingHelper.Run(Rec) then
                    Error(MappingRangeNotSetupMsg, GetLastErrorText());
            end;
            CurrPage.Update();
        end;
    end;

    local procedure ShowWelcomeStep();
    begin
        WelcomeStepVisible := true;
        StandardAccTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        DimensionExportVisible := false;
        BackActionEnabled := false;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowStandardAccTypeStep();
    begin
        WelcomeStepVisible := false;
        StandardAccTypeStepVisible := true;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        DimensionExportVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowMappingSourceLoadedStep();
    begin
        WelcomeStepVisible := false;
        StandardAccTypeStepVisible := false;
        MappingRangeStepVisible := true;
        MappingAccountVisible := false;
        DimensionExportVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowMappingAccountStep();
    begin
        WelcomeStepVisible := false;
        StandardAccTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := true;
        DimensionExportVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowDimensionExport()
    begin
        WelcomeStepVisible := false;
        StandardAccTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        DimensionExportVisible := true;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowFinish();
    begin
        WelcomeStepVisible := false;
        StandardAccTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        DimensionExportVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure ResetControls();
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        WelcomeStepVisible := false;
        StandardAccTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        DimensionExportVisible := false;
    end;

    local procedure LoadTopBanners();
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType()))
        then
            if MediaResourcesStd.Get(MediaRepositoryStandard."Media Resources Ref") and
                MediaResourcesFinished.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesFinished."Media Reference".HasValue();
    end;

    local procedure LoadStandardAccounts(StandardAccountType: enum "Standard Account Type")
    var
        IAuditFileExportDataHandling: Interface "Audit File Export Data Handling";
        AuditFileExportFormat: Enum "Audit File Export Format";
    begin
        IAuditFileExportDataHandling := AuditFileExportFormat::SIE;
        IAuditFileExportDataHandling.LoadStandardAccounts(StandardAccountType)
    end;

    local procedure UpdateGLAccountsMappedInfo()
    var
        AuditMappingHelper: Codeunit "Audit Mapping Helper";
    begin
        GLAccountsMapped := AuditMappingHelper.GetGLAccountsMappedInfo(Rec.Code);
    end;
#if not CLEAN22
#pragma warning disable AS0072
    [Obsolete('Feature will be enabled by default.', '22.0')]
    procedure SetRunFromFeatureMgt()
    begin
        IsRunFromFeatureMgt := true;
    end;
#pragma warning restore AS0072
#endif
}
