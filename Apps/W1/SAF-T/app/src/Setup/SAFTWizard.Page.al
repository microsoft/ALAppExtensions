// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.Dimension;
using Microsoft.Foundation.Company;
using Microsoft.HumanResources.Employee;
using System.Environment;
using System.Telemetry;
using System.Utilities;

#pragma warning disable AS0030
page 5280 "SAF-T Wizard"
#pragma warning restore AS0030
{
    Caption = 'SAF-T Setup Guide';
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
                    Caption = 'Welcome to the setup of SAF-T';
                    Visible = WelcomeStepVisible;
                    group(SAFTDescription)
                    {
                        Caption = '';
                        InstructionalText = 'The SAF-T (Standard Audit File - Tax) is a standard file format for exporting various types of accounting transactional data using the XML format. This guide helps you set up SAF-T for Dynamics 365 Business Central. If you do not have a chart of accounts, this guide helps you to create it based on SAF-T standard chart of accounts. If you do not want to set this up right now, close this page.';
                    }
                }
            }

            group(DataUpgrade)
            {
                Visible = DataUpgradeStepVisible;
                group(WhatIsUpdated)
                {
                    Caption = 'What is updated';
                    group(WhatIsUpdatedDescr)
                    {
                        ShowCaption = false;
                        field(Description; UpgradeDescription)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                            Visible = UpgradeDescription <> '';
                            Editable = false;
                            MultiLine = true;
                            ToolTip = 'Specifies the description of what is going to happen during the data update task.';
                        }
                    }
                }
                group(ReviewAffectedData)
                {
                    ShowCaption = false;
                    field(ReviewData; ReviewDataTok)
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            DataUpgradeSAFT.ReviewDataToUpgrade();
                        end;
                    }
                }
                group(DataUpgradeAgreement)
                {
                    ShowCaption = false;
                    field(Agreed; DataUpgradeAgreed)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'I accept the data update';
                        ToolTip = 'Specifies whether the user does understand the update procedure and agree to proceed.';

                        trigger OnValidate()
                        begin
                            NextActionEnabled := DataUpgradeAgreed;
                        end;
                    }
                }
            }

            group(ChooseStandardAccTypeParent)
            {
                Visible = StandardAccTypeStepVisible;
                group(MappingSourceNotLoaded)
                {
                    Caption = 'Select standard chart of accounts';
                    InstructionalText = 'When sending your SAF-T file to the tax authorities, each G/L account must be mapped to either a financial standard account or the income statement for the type of business.';
                }
                group(MappingSourceOnPrem)
                {
                    Visible = not StandardAccountsLoaded;
                    ShowCaption = false;
                    InstructionalText = 'Specify the preferred standard account type and then choose the Import the source files for mapping button. Import the mapping codes for standard tax and according to the mapping type specified in the field. Then choose Next.';
                }
                group(MappingSourceLoaded)
                {
                    Visible = StandardAccountsLoaded;
                    ShowCaption = false;
                    InstructionalText = 'Specify the preferred standard account type and choose Next.';
                }
                group(StandardAccTypeChild)
                {
                    ShowCaption = false;
                    field(StandardAccountType; Rec."Standard Account Type")
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
                    Caption = 'Specify the period of the first SAF-T file';
                    InstructionalText = 'Specify the period of the first SAF-T file. Choose Next to map your chart of accounts to the values that SAF-T requires.';

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
                    Caption = 'Map SAF-T accounts to your chart of accounts';
                    InstructionalText = 'For each general ledger account, select the SAF-T account or grouping code depending on the mapping type selected in the previous step.';
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
                        ApplicationArea = Basic, Suite;
                    }
                    field(GLAccountMappingRemainder; GLAccountMappingRemainderTxt)
                    {
                        ShowCaption = false;
                        Editable = false;
                        ApplicationArea = Basic, Suite;
                    }
                }
            }

            group(StandardTaxCodes)
            {
                ShowCaption = false;
                Visible = VATMappingVisible;
                group(StandardTaxCodesGeneral)
                {
                    Caption = 'Map VAT posting setup to VAT reporting codes';
                    InstructionalText = 'Specify a value in the Sales VAT Reporting Code field and/or the Purchase VAT Reporting Code field depending on type of operations you perform with the certain combination.';
                }
                group(VATStartingDateGeneral)
                {
                    Caption = 'Set starting date for the VAT posting setup entries';
                    InstructionalText = 'Specify a value in the Starting Date field for each VAT posting setup entry.';
                    Visible = VATSetStartingDateVisible;
                }
                group(OpenTaxMappingGroup)
                {
                    ShowCaption = false;
                    field(OpenTaxMapping; OpenTaxMappingSetupLbl)
                    {
                        ShowCaption = false;
                        StyleExpr = true;
                        Style = StandardAccent;
                        ApplicationArea = Basic, Suite;

                        trigger OnDrillDown()
                        begin
                            Page.RunModal(Page::"VAT Posting Setup SAF-T");
                            UpdateVATPostingSetupMappedCount();
                        end;
                    }
                    field(VATMappedCount; VATStartingDateSetCount)
                    {
                        Caption = 'VAT Posting Setup mapped:';
                        Editable = false;
                        ApplicationArea = Basic, Suite;
                    }
                    field(VATMappingNARemainder; VATMappingNARemainderTxt)
                    {
                        ShowCaption = false;
                        Editable = false;
                        ApplicationArea = Basic, Suite;
                        Visible = VATMappingNARemainderVisible;
                    }
                }
            }

            group(DimensionExportParent)
            {
                ShowCaption = false;
                Visible = DimensionExportVisible;
                group(DimensionExportGeneral)
                {
                    Caption = 'Export dimensions to SAF-T';
                    InstructionalText = 'Change the value of SAF-T Export on Dimensions page if a certain dimension must be skipped from export to the SAF-T File.';
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
                        begin
                            Page.RunModal(Page::"Dimensions");
                        end;
                    }
                }
            }

            group(ContactParent)
            {
                ShowCaption = false;
                Visible = ContactVisible;
                group(ContactGeneral)
                {
                    Caption = 'Specify the employee to contact';
                    InstructionalText = 'Specify the employee responsible for the content of the SAF-T File. The information about the contact will be exported to the SAF-T file.';
                }
                group(ContactGroup)
                {
                    ShowCaption = false;
                    field(SAFTContactNo; CompanyInformation."Contact No. SAF-T")
                    {
                        Caption = 'Employee No.';
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                        TableRelation = Employee;
                    }
                }
            }

            group(FinishedParent)
            {
                ShowCaption = false;
                Visible = FinishActionEnabled;
                group(FinishedChild)
                {
                    Caption = 'The SAF-T setup is completed!';
                    Visible = FinishActionEnabled;
                    group(FinishDescription)
                    {
                        Caption = '';
                        InstructionalText = 'You''re ready to use the SAF-T functionality. Do an additional mapping on the G/L Account Mapping page if needed. Open the Audit File Export Document page to export the data in the SAF-T format.';
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
            action(MatchChartOfAccounts)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Match chart of accounts';
                ToolTip = 'Automatically match existing G/L accounts with SAF-T standard accounts codes, with either two or four digits depending on the mapping type selected in the previous step.';
                Visible = MappingAccountVisible;
                Image = MapAccounts;
                InFooterBar = true;
                trigger OnAction();
                var
                    AuditMappingHelper: Codeunit "Audit Mapping Helper";
                begin
                    AuditMappingHelper.MatchChartOfAccounts(Rec);
                    UpdateGLAccountsMappedInfo();
                    CurrPage.Update();
                end;
            }
            action(CreateChartOfAccounts)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Create chart of accounts';
                ToolTip = 'Create a chart of accounts in Business Central from SAF-T standard accounts codes, with either two or four digits depending on mapping type selected in the previous step.';
                Visible = MappingRangeStepVisible;
                Image = MapAccounts;
                InFooterBar = true;
                trigger OnAction();
                var
                    AuditMappingHelper: Codeunit "Audit Mapping Helper";
                begin
                    AuditMappingHelper.CreateChartOfAccounts(Rec);
                    UpdateGLAccountsMappedInfo();
                    CurrPage.Update();
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
        MappingHelperSAFT: Codeunit "Mapping Helper SAF-T";
    begin
        FeatureTelemetry.LogUptake('0000KTC', SAFTExportTok, Enum::"Feature Uptake Status"::Discovered);
        Commit();

        AuditFileExportSetup.InitSetup(Enum::"Audit File Export Format"::SAFT);
        AuditFileExportFormatSetup.InitSetup(Enum::"Audit File Export Format"::SAFT, SAFTDataMgt.GetZipFileName(), true);
        DataHandlingSAFT.InitAuditExportDataTypeSetup();
        AuditMappingHelper.GetDefaultGLAccountMappingHeader(Rec, Enum::"Audit File Export Format"::SAFT);
        Rec.SetRecFilter();
        CompanyInformation.Get();
        Step := Step::Start;
        EnableControls();
        UpdateVATPostingSetupMappedCount();
        MappingHelperSAFT.MapRestSourceCodesToAssortedJournals();
        MappingHelperSAFT.InitDimensionFieldsSAFT();
        MappingHelperSAFT.InitVATPostingSetupFieldsSAFT();

        InitDataUpgradeInterface();
        DataUpgradeRequired := DataUpgradeSAFT.IsDataUpgradeRequired();
        UpgradeDescription := DataUpgradeSAFT.GetDataUpgradeDescription();
    end;

    var
        CompanyInformation: Record "Company Information";
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesFinished: Record "Media Resources";
        MediaResourcesStd: Record "Media Resources";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SAFTDataMgt: Codeunit "SAF-T Data Mgt.";
        DataHandlingSAFT: Codeunit "Audit Data Handling SAF-T";
        DataUpgradeSAFT: Interface DataUpgradeSAFT;
        Step: Option Start,DataUpgrade,StandardAccType,MappingSourceLoaded,MappingAccount,MappingVAT,DimensionExport,Contact,Finish;
        UpgradeDescription: Text;
        GLAccountsMapped: Text[20];
        VATStartingDateSetCount: Text[20];
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        WelcomeStepVisible: Boolean;
        DataUpgradeStepVisible: Boolean;
        StandardAccTypeStepVisible: Boolean;
        MappingRangeStepVisible: Boolean;
        MappingAccountVisible: Boolean;
        VATMappingVisible: Boolean;
        VATSetStartingDateVisible: Boolean;
        VATMappingNARemainderVisible: Boolean;
        DimensionExportVisible: Boolean;
        ContactVisible: Boolean;
        TopBannerVisible: Boolean;
        StandardAccountsLoaded: Boolean;
        SetupCompleted: Boolean;
        DataUpgradeAgreed: Boolean;
        DataUpgradeRequired: Boolean;
        StandardAccTypeNotSpecifiedErr: label 'A standard account type is not specified.';
        SetupNotCompletedQst: label 'Set up SAF-T has not been completed.\\Are you sure that you want to exit?';
        MappingSourceNotLoadedMsg: label 'A source for mapping was not loaded due to the following error: %1.', Comment = '%1 - error text';
        MappingRangeNotSetupMsg: label 'A mapping range was not set up due to the following error: %1.', Comment = '%1 - error text';
        OpenMappingSetupLbl: label 'Open the setup page to define G/L account mappings.';
        OpenTaxMappingSetupLbl: label 'Open the setup page to define VAT Posting Setup necessary field values.';
        OpenDimensionExportSetupLbl: label 'Open the setup page to define which dimensions to export to SAF-T.';
        GLAccountMappingRemainderTxt: label 'You must provide mapping for all G/L accounts in the company.';
        VATMappingNARemainderTxt: label 'VAT posting setups without a mapping will be exported with the NA value to the XML file.';
        ReviewDataTok: Label 'Review affected data';
        DKCountryCodeTxt: label 'DK', Locked = true;
        NOCountryCodeTxt: label 'NO', Locked = true;
        SAFTExportTok: label 'Audit File Export SAFT', Locked = true;

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowWelcomeStep();
            Step::DataUpgrade:
                ShowDataUpgradeStep();
            Step::StandardAccType:
                ShowStandardAccTypeStep();
            Step::MappingSourceLoaded:
                ShowMappingSourceLoadedStep();
            Step::MappingAccount:
                ShowMappingAccountStep();
            Step::MappingVAT:
                ShowVATSettings();
            Step::DimensionExport:
                ShowDimensionExport();
            Step::Contact:
                ShowContact();
            Step::Finish:
                ShowFinish();
        end;
    end;

    local procedure FinishAction();
    begin
        FeatureTelemetry.LogUptake('0000KTD', SAFTExportTok, Enum::"Feature Uptake Status"::"Set up");
        SetupCompleted := true;
        CurrPage.Close();
    end;

    procedure IsSetupCompleted(): Boolean
    begin
        exit(SetupCompleted);
    end;

    local procedure NextStep(Backwards: Boolean);
    var
        SkipUpgradeStep: Boolean;
        StepsCount: Integer;
    begin
        DoActionOnNext(Step, Backwards);
        ValidateControlsBeforeStep(Backwards);

        StepsCount := 1;
        if not DataUpgradeRequired then
            SkipUpgradeStep := ((Step = Step::Start) and not Backwards) or ((Step = Step::StandardAccType) and Backwards);
        if SkipUpgradeStep then
            StepsCount += 1;

        if Backwards then
            Step := Step - StepsCount
        else
            Step := Step + StepsCount;
        EnableControls();
    end;

    local procedure DoActionOnNext(CurrentStep: Option; Backward: Boolean)
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        LoadStandardDataSAFT: Interface CreateStandardDataSAFT;
    begin
        case CurrentStep of
            Step::DataUpgrade:
                if not Backward then begin
                    if not DataUpgradeAgreed then
                        Error('');
                    if not DataUpgradeSAFT.UpgradeData() then
                        Error('');
                end;
            Step::StandardAccType:
                if not Backward then begin
                    StandardAccountsLoaded := DataHandlingSAFT.LoadStandardAccounts(Rec."Standard Account Type");
                    AuditFileExportSetup.UpdateStandardAccountType(Rec."Standard Account Type");

                    AuditFileExportSetup.Get();
                    LoadStandardDataSAFT := AuditFileExportSetup."SAF-T Modification";
                    LoadStandardDataSAFT.LoadStandardTaxCodes();
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

        if ContactVisible and (not Backwards) then
            CompanyInformation.Modify(true);
    end;

    local procedure ShowWelcomeStep();
    begin
        WelcomeStepVisible := true;
        DataUpgradeStepVisible := false;
        StandardAccTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        VATMappingVisible := false;
        VATSetStartingDateVisible := false;
        ContactVisible := false;
        DimensionExportVisible := false;
        BackActionEnabled := false;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowDataUpgradeStep();
    begin
        WelcomeStepVisible := false;
        DataUpgradeStepVisible := DataUpgradeRequired;
        StandardAccTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        VATMappingVisible := false;
        VATSetStartingDateVisible := false;
        ContactVisible := false;
        DimensionExportVisible := false;
        BackActionEnabled := false;
        NextActionEnabled := DataUpgradeAgreed;
        FinishActionEnabled := false;
    end;

    local procedure ShowStandardAccTypeStep();
    begin
        WelcomeStepVisible := false;
        DataUpgradeStepVisible := false;
        StandardAccTypeStepVisible := true;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        VATMappingVisible := false;
        VATSetStartingDateVisible := false;
        DimensionExportVisible := false;
        ContactVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowMappingSourceLoadedStep();
    begin
        WelcomeStepVisible := false;
        DataUpgradeStepVisible := false;
        StandardAccTypeStepVisible := false;
        MappingRangeStepVisible := true;
        MappingAccountVisible := false;
        VATMappingVisible := false;
        VATSetStartingDateVisible := false;
        DimensionExportVisible := false;
        ContactVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowMappingAccountStep();
    begin
        WelcomeStepVisible := false;
        DataUpgradeStepVisible := false;
        StandardAccTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := true;
        VATMappingVisible := false;
        VATSetStartingDateVisible := false;
        DimensionExportVisible := false;
        ContactVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowVATSettings()
    var
        CountryCode: Text;
    begin
        CountryCode := SAFTDataMgt.GetEnvironmentCountryCode();

        WelcomeStepVisible := false;
        DataUpgradeStepVisible := false;
        StandardAccTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        VATMappingVisible := true;

        case CountryCode of
            NOCountryCodeTxt:
                begin
                    VATSetStartingDateVisible := false;
                    VATMappingNARemainderVisible := true;
                end;
            DKCountryCodeTxt:
                begin
                    VATSetStartingDateVisible := true;
                    VATMappingNARemainderVisible := false;
                end;
        end;

        DimensionExportVisible := false;
        ContactVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowDimensionExport()
    begin
        WelcomeStepVisible := false;
        DataUpgradeStepVisible := false;
        StandardAccTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        VATMappingVisible := false;
        VATSetStartingDateVisible := false;
        DimensionExportVisible := true;
        ContactVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowContact()
    begin
        WelcomeStepVisible := false;
        DataUpgradeStepVisible := false;
        StandardAccTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        VATMappingVisible := false;
        VATSetStartingDateVisible := false;
        DimensionExportVisible := false;
        ContactVisible := true;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowFinish();
    begin
        WelcomeStepVisible := false;
        DataUpgradeStepVisible := false;
        StandardAccTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        VATMappingVisible := false;
        VATSetStartingDateVisible := false;
        DimensionExportVisible := false;
        ContactVisible := false;
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
        DataUpgradeStepVisible := false;
        StandardAccTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        VATMappingVisible := false;
        VATSetStartingDateVisible := false;
        DimensionExportVisible := false;
        ContactVisible := false;
    end;

    local procedure InitDataUpgradeInterface()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
    begin
        AuditFileExportSetup.Get();
        DataUpgradeSAFT := AuditFileExportSetup."SAF-T Modification";
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

    local procedure UpdateGLAccountsMappedInfo()
    var
        AuditMappingHelper: Codeunit "Audit Mapping Helper";
    begin
        GLAccountsMapped := AuditMappingHelper.GetGLAccountsMappedInfo(Rec.Code);
    end;

    local procedure UpdateVATPostingSetupMappedCount()
    var
        MappingHelperSAFT: Codeunit "Mapping Helper SAF-T";
    begin
        VATStartingDateSetCount := MappingHelperSAFT.GetVATPostingSetupMappedCount();
    end;
}
