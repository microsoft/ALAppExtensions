page 10674 "SAF-T Setup Wizard"
{
    Caption = 'SAF-T Setup Guide';
    PageType = NavigatePage;
    SourceTable = "SAF-T Mapping Range";
    RefreshOnActivate = true;

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
                        InstructionalText = 'The SAF-T (Standard Audit File - Tax) is a standard file format for exporting various types of accounting transactional data using the XML format. This guide helps you set up SAF-T for the Norwegian version of Dynamics 365 Business Central. If you do not have a chart of accounts, this guide helps you to create it based on SAF-T standard chart of accounts. If you do not want to set this up right now, close this page.';
                    }
                }
            }

            group(ChooseMappingTypeParent)
            {
                Visible = MappingTypeStepVisible;
                group(MappingSourceNotLoaded)
                {
                    Caption = 'Select chart of accounts mapping';
                    InstructionalText = 'When sending your SAF-T file to the tax authorities, each G/L account must be mapped to either a financial standard account or the income statement for the type of business.';
                }
                group(MappingSourceOnPrem)
                {
                    Visible = not MappingSourceImported;
                    ShowCaption = false;
                    InstructionalText = 'Specify the preferred mapping type and then choose the Import the source files for mapping button. Import the mapping codes for standard tax and according to the mapping type specified in the field. Then choose Next.';
                }
                group(MappingSourceLoaded)
                {
                    Visible = MappingSourceImported;
                    ShowCaption = false;
                    InstructionalText = 'Specify the preferred mapping type and choose Next.';
                }
                group(MappingTypeChild)
                {
                    ShowCaption = false;
                    field(MappingType; "Mapping Type")
                    {
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                        Caption = 'Mapping Type';

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                            SAFTStandardAccMappingSelected := IsStandardAccountMapping();
                            MappingTypeSpecified := "Mapping Type" <> 0;
                            CalcMappingTypeNextStepVisibility();
                        end;
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

                    field(MappingRange; "Range Type")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Range Type';
                        Editable = false;
                    }
                    field(AccountingPeriod; "Accounting Period")
                    {
                        ApplicationArea = Basic, Suite;
                        Visible = AccountingPeriodVisible;
                        Caption = 'Accounting Period';
                    }
                    field(StartingDate; "Starting Date")
                    {
                        ApplicationArea = Basic, Suite;
                        Visible = DateRangeVisible;
                        Caption = 'Starting Date';
                    }
                    field(EndingDate; "Ending Date")
                    {
                        ApplicationArea = Basic, Suite;
                        Visible = DateRangeVisible;
                        Caption = 'Ending Date';
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
                            SAFTMappingSetupCard: Page "SAF-T Mapping Setup Card";
                        begin
                            SAFTMappingSetupCard.SetTableView(Rec);
                            SAFTMappingSetupCard.RunModal();
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
                    field(GLAccountMappingRemainder2; GLAccountMappingRemainder2Txt)
                    {
                        ShowCaption = false;
                        Editable = false;
                        ApplicationArea = Basic, Suite;
                    }
                }
            }

            group(VATMappingParent)
            {
                ShowCaption = false;
                Visible = MappingVATVisible;
                group(VATMappingGeneral)
                {
                    Caption = 'Map VAT posting setup to VAT codes';
                    InstructionalText = 'Specify a value in the Sales SAF-T Standard Tax Code field and/or the Purchase SAF-T Standard Tax Code field depending on type of operations you perform with the certain combination.';
                }
                group(OpenVATMappingGroup)
                {
                    ShowCaption = false;
                    field(OpenVATMapping; OpenVATMappingSetupLbl)
                    {
                        ShowCaption = false;
                        StyleExpr = true;
                        Style = StandardAccent;
                        ApplicationArea = Basic, Suite;

                        trigger OnDrillDown()
                        begin
                            Page.RunModal(PAGE::"SAF-T VAT Posting Setup");
                            UpdateVATPostingSetupMappedInfo();
                        end;
                    }
                    field(VATMappedInfo; VATMapped)
                    {
                        Caption = 'VAT Posting Setup mapped:';
                        Editable = false;
                        ApplicationArea = Basic, Suite;
                    }
                    field(VATMappingRemainder; VATMappingRemainderTxt)
                    {
                        ShowCaption = false;
                        Editable = false;
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
                    Caption = 'Export dimensions to SAF-T';
                    InstructionalText = 'Change the value of Export to SAF-T on Dimensions page if a certain dimension must be skipped from export to the SAF-T File.';
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
                            Page.RunModal(PAGE::"Dimensions");
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
                    field(SAFTContactNo; CompanyInformation."SAF-T Contact No.")
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
                        InstructionalText = 'You''re ready to use the SAF-T functionality. Do an additional mapping on the SAF-T Mapping Setup page if needed. Open the SAF-T Exports page to export the data in the SAF-T format.';
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
                Visible = MappingAccountVisible and SAFTStandardAccMappingSelected;
                Image = MapAccounts;
                InFooterBar = true;
                trigger OnAction();
                var
                    SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
                begin
                    SAFTMappingHelper.MatchChartOfAccounts(Rec);
                    UpdateGLAccountsMappedInfo();
                    CurrPage.Update();
                end;
            }
            action(CreateChartOfAccounts)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Create chart of accounts';
                ToolTip = 'Create a chart of accounts in Business Central from SAF-T standard accounts codes, with either two or four digits depending on mapping type selected in the previous step.';
                Visible = MappingRangeStepVisible and SAFTStandardAccMappingSelected;
                Image = MapAccounts;
                InFooterBar = true;
                trigger OnAction();
                var
                    SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
                begin
                    SAFTMappingHelper.CreateChartOfAccounts(Rec);
                    UpdateGLAccountsMappedInfo();
                    CurrPage.Update();
                end;
            }
            action(ImportMappingSourceFiles)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Import the source files for mapping';
                Visible = MappingTypeStepVisible and MappingTypeSpecified and (not MappingSourceImported);
                Image = ImportCodes;
                InFooterBar = true;
                trigger OnAction();
                var
                    SAFTMappingSource: Page "SAF-T Mapping Source";
                begin
                    if "Mapping Type" = 0 then
                        error(MappingTypeNotSpecifiedErr);
                    SAFTMappingSource.RunModal();
                    CalcMappingTypeNextStepVisibility();
                end;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean;
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        if GetLastErrorText() <> '' then
            exit(true);
        if CloseAction = CloseAction::OK then
            If not AssistedSetup.IsComplete(PAGE::"SAF-T Setup Wizard") then
                if not Confirm(SetupNotCompletedQst) then
                    Error('');
    end;

    trigger OnInit();
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage();
    var
        SAFTSetup: Record "SAF-T Setup";
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        if not SAFTSetup.Get() then
            SAFTSetup.Insert();
        SAFTMappingHelper.GetDefaultSAFTMappingRange(Rec);
        SetRecFilter();
        CompanyInformation.Get();
        MappingTypeSpecified := "Mapping Type" <> 0;
        SAFTStandardAccMappingSelected := IsStandardAccountMapping();
        Step := Step::Start;
        EnableControls();
        UpdateVATPostingSetupMappedInfo();
        SAFTMappingHelper.MapRestSourceCodesToAssortedJournals();
    end;

    var
        CompanyInformation: Record "Company Information";
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesFinished: Record "Media Resources";
        MediaResourcesStd: Record "Media Resources";
        Step: Option Start,MappingType,MappingSourceLoaded,MappingAccount,MappingVAT,DimensionExport,Contact,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        WelcomeStepVisible: Boolean;
        MappingTypeStepVisible: Boolean;
        MappingRangeStepVisible: Boolean;
        MappingAccountVisible: Boolean;
        MappingVATVisible: Boolean;
        DimensionExportVisible: Boolean;
        ContactVisible: Boolean;
        SourceCodeMappingVisible: Boolean;
        TopBannerVisible: Boolean;
        SAFTStandardAccMappingSelected: Boolean;
        AccountingPeriodVisible: Boolean;
        DateRangeVisible: Boolean;
        MappingSourceImported: Boolean;
        MappingTypeSpecified: Boolean;
        GLAccountsMapped: Text[20];
        VATMapped: Text[20];
        MappingTypeNotSpecifiedErr: Label 'A mapping type is not specified.';
        SetupNotCompletedQst: Label 'Set up SAF-T has not been completed.\\Are you sure that you want to exit?', Comment = '%1 = Set-up of SAFT';
        MappingSourceNotLoadedMsg: Label 'A source for mapping was not loaded due to the following error: %1.';
        MappingRangeNotSetupMsg: Label 'A mapping range was not set up due to the following error: %1.';
        OpenMappingSetupLbl: Label 'Open the setup page to define G/L account mappings.';
        OpenVATMappingSetupLbl: Label 'Open the setup page to define a VAT Posting Setup mapping.';
        OpenDimensionExportSetupLbl: Label 'Open the setup page to define which dimensions to export to SAF-T.';
        GLAccountMappingRemainderTxt: Label 'Mapping is not mandatory if no G/L entries are posted in the reported period.';
        GLAccountMappingRemainder2Txt: Label 'For G/L account with no mapping code, enter NA.';
        VATMappingRemainderTxt: Label 'VAT posting setups without a mapping will be exported with the NA value to the XML file.';

    local procedure EnableControls();
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowWelcomeStep();
            Step::MappingType:
                ShowMappingTypeStep();
            Step::MappingSourceLoaded:
                ShowMappingSourceLoadedStep();
            Step::MappingAccount:
                ShowMappingAccountStep();
            Step::MappingVAT:
                ShowMappingVAT();
            Step::DimensionExport:
                ShowDimensionExport();
            Step::Contact:
                ShowContact();
            Step::Finish:
                ShowFinish();
        end;
    end;

    local procedure FinishAction();
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        AssistedSetup.Complete(PAGE::"SAF-T Setup Wizard");
        CurrPage.Close();
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        ValidateControlsBeforeStep(Backwards);
        if Backwards then
            Step := Step - 1
        ELSE
            Step := Step + 1;
        EnableControls();
    end;

    local procedure ValidateControlsBeforeStep(Backwards: Boolean)
    var
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        if MappingTypeStepVisible and ("Mapping Type" = 0) then
            error(MappingTypeNotSpecifiedErr);
        if MappingTypeStepVisible and (not Backwards) then begin
            ClearLastError();
            commit();
            if NOT SAFTXMLImport.Run(Rec) then
                Error(MappingSourceNotLoadedMsg, GetLastErrorText());
            UpdateGLAccountsMappedInfo();
        end;

        if MappingRangeStepVisible then begin
            SAFTMappingHelper.ValidateMappingRange(Rec);
            Commit();
            if not Backwards then begin
                ClearLastError();
                if not SAFTMappingHelper.Run(Rec) then
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
        MappingTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        MappingVATVisible := false;
        ContactVisible := false;
        DimensionExportVisible := false;
        SourceCodeMappingVisible := false;
        BackActionEnabled := false;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowMappingTypeStep();
    begin
        WelcomeStepVisible := false;
        MappingTypeStepVisible := true;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        MappingVATVisible := false;
        DimensionExportVisible := false;
        ContactVisible := false;
        SourceCodeMappingVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
        CalcMappingTypeNextStepVisibility();
    end;

    local procedure ShowMappingSourceLoadedStep();
    begin
        WelcomeStepVisible := false;
        MappingTypeStepVisible := false;
        MappingRangeStepVisible := true;
        MappingAccountVisible := false;
        MappingVATVisible := false;
        DimensionExportVisible := false;
        ContactVisible := false;
        SourceCodeMappingVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowMappingAccountStep();
    begin
        WelcomeStepVisible := false;
        MappingTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := true;
        MappingVATVisible := false;
        DimensionExportVisible := false;
        ContactVisible := false;
        SourceCodeMappingVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowMappingVAT()
    begin
        WelcomeStepVisible := false;
        MappingTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        MappingVATVisible := true;
        DimensionExportVisible := false;
        ContactVisible := false;
        SourceCodeMappingVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowDimensionExport()
    begin
        WelcomeStepVisible := false;
        MappingTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        MappingVATVisible := false;
        DimensionExportVisible := true;
        ContactVisible := false;
        SourceCodeMappingVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowContact()
    begin
        WelcomeStepVisible := false;
        MappingTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        MappingVATVisible := false;
        DimensionExportVisible := false;
        ContactVisible := true;
        SourceCodeMappingVisible := false;
        BackActionEnabled := true;
        NextActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowFinish();
    begin
        WelcomeStepVisible := false;
        MappingTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        MappingVATVisible := false;
        DimensionExportVisible := false;
        ContactVisible := false;
        SourceCodeMappingVisible := false;
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
        MappingTypeStepVisible := false;
        MappingRangeStepVisible := false;
        MappingAccountVisible := false;
        MappingVATVisible := false;
        DimensionExportVisible := false;
        ContactVisible := false;
        SourceCodeMappingVisible := false;
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

    local procedure CalcMappingTypeNextStepVisibility()
    var
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        MappingSourceImported := SAFTXMLImport.MappingSourceLoaded(Rec);
        if not (Step in [Step::Start, Step::Finish]) then
            NextActionEnabled := MappingSourceImported;
    end;

    local procedure UpdateGLAccountsMappedInfo()
    var
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        GLAccountsMapped := SAFTMappingHelper.GetGLAccountsMappedInfo(Code);
    end;

    local procedure UpdateVATPostingSetupMappedInfo()
    var
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        VATMapped := SAFTMappingHelper.GetVATPostingSetupMappedInfo();
    end;
}
