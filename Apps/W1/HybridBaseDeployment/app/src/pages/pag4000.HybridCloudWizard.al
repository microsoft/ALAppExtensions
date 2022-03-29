page 4000 "Hybrid Cloud Setup Wizard"
{
    Caption = 'Cloud Migration Setup';
    AdditionalSearchTerms = 'migration,data migration,cloud migration,intelligent,cloud,sync,replication,hybrid';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    ShowFilter = false;
    SourceTable = "Intelligent Cloud Setup";
    Permissions = tabledata 4003 = rimd;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(Banner1)
            {
                Editable = false;
                Visible = TopBannerVisible and not DoneVisible;
                ShowCaption = false;
                field(MediaResourcesStandard; MediaResources_Standard."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Banner2)
            {
                Editable = false;
                Visible = TopBannerVisible and DoneVisible;
                ShowCaption = false;
                field(MediaResourcesDone; MediaResources_Done."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Step1)
            {
                ShowCaption = false;
                Visible = IntroVisible;
                group("Para1.1")
                {
                    Caption = 'Welcome to the on-premises to Business Central cloud Data Migration Setup';
                    group("Para1.1.1")
                    {
                        ShowCaption = false;
                        InstructionalText = 'This assisted setup will guide you through the necessary steps to create a configuration that will enable data migration from your on-premises Dynamics solution to your Business Central cloud tenant.  Upon completion of the migration, additional steps may be required before transacting in your Business Central cloud tenant.  See setup checklists for more information.';
                    }
                }
                group("Para1.2")
                {
                    Caption = 'Warning';
                    group("Para1.2.1")
                    {
                        ShowCaption = false;
                        InstructionalText = 'Migrating data from on-premises to your Business Central cloud solution may overwrite any existing data in your Business Central cloud tenant. Refer to Help for more information.';

                        field(HelpTxt; HelpStringTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;

                            trigger OnDrillDown()
                            begin
                                Hyperlink(HelpUrlTxt);
                            end;
                        }
                        group("Para1.2.2")
                        {
                            ShowCaption = false;
                            InstructionalText = 'This migration process leverages Microsoft’s Azure Data Factory, which may offer varying levels of compliance. Refer to the Privacy Notice for more information.';

                            field(PrivacyNotice; PrivacyNoticeTxt)
                            {
                                ApplicationArea = Basic, Suite;
                                ShowCaption = false;

                                trigger OnDrillDown()
                                begin
                                    Hyperlink(PrivacyNoticeUrlTxt);
                                end;
                            }
#pragma warning disable AA0218
                            field(AgreePrivacy; InAgreementWithPolicy)
                            {
                                ApplicationArea = Basic, Suite;
                                Caption = 'I accept warning & privacy notice.';
                                ShowCaption = true;

                                trigger OnValidate()
                                begin
                                    if InAgreementWithPolicy then
                                        NextEnabled := true
                                    else
                                        NextEnabled := false;
                                end;
                            }
#pragma warning restore
                        }
                    }
                }
            }
            group(Step2)
            {
                Caption = '';
                Visible = ProductTypeVisible;
                group("Para2.1")
                {
                    Caption = 'Choose Your Product';
                    InstructionalText = 'Select the product that you want to migrate data from';
                    group("Para2.1.1")
                    {
                        Caption = '';
#pragma warning disable AA0218
                        field("Product Name"; TempHybridProductType."Display Name")
                        {
                            Caption = 'Product';
                            ApplicationArea = Basic, Suite;
                            AssistEdit = true;
                            Editable = false;

                            trigger OnAssistEdit()
                            var
                                HybridProduct: Page "Hybrid Product Types";
                            begin
                                HybridProduct.SetTableView(TempHybridProductType);
                                HybridProduct.SetRecord(TempHybridProductType);
                                HybridProduct.LookupMode(true);
                                if HybridProduct.RunModal() in [Action::LookupOK, Action::OK, Action::Yes] then begin
                                    HybridProduct.GetRecord(TempHybridProductType);
                                    if TempHybridProductType.ID = '' then begin
                                        Session.LogMessage('SmbMig-005', StrSubstNo(BlankProductFoundTxt, Format(TempHybridProductType)), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', 'CloudMigration');
                                        Error(BlankProductIdErr);
                                    end;
                                end
                                else
                                    exit;

                                HybridCloudManagement.OnGetHybridProductDescription(TempHybridProductType.ID, SelectedProductDescription);
                                SelectedProductDescriptionVisible := SelectedProductDescription <> '';
                                Rec."Product ID" := TempHybridProductType.ID;

                                Rec.Modify();
                                NextEnabled := true;
                            end;
                        }
#pragma warning restore                        
                    }

                    group("Para2.1.2")
                    {
                        Caption = '';
                        Visible = SelectedProductDescriptionVisible;

                        field(SelectedProductDescription; SelectedProductDescription)
                        {
                            ApplicationArea = Basic, Suite;
                            Editable = false;
                            MultiLine = true;
                            ShowCaption = false;
                        }
                    }
                }
            }

            group(Step21)
            {
                Caption = '';
                Visible = DelegatedAdminStepVisible;
                group("Para21.1")
                {
                    Caption = 'Delegated Admin Setup';
                    InstructionalText = 'You are signed in as a delegated administrator. You must get approval from a licensed user with SUPER permissions to run the cloud migration on their behalf. Send the following link to the licensed user so that they can grant or revoke the permission to run the cloud migration. Once your request is accepted, you can start this setup guide again.';
                    group("Para22.1.1")
                    {
                        Caption = 'Link to approval page';
                        field(ApprovalPageLinkTxt; ApprovalPageLinkTxt)
                        {
                            ShowCaption = false;
                            ApplicationArea = Basic, Suite;
                            Editable = false;
                            MultiLine = true;
                        }
                    }
                }
            }

            group(Step3)
            {
                Caption = '';
                Visible = SQLServerTypeVisible;
                group("Para3.1")
                {
                    Caption = 'Define your SQL database connection';
#pragma warning disable AA0218
                    field("Sql Server Type"; "Sql Server Type")
                    {
                        Caption = 'SQL Configuration';
                        ApplicationArea = Basic, Suite;
                        OptionCaption = 'SQL Server,Azure SQL';

                        trigger OnValidate()
                        begin
                            IsChanged := IsChanged or (Rec."Sql Server Type" <> xRec."Sql Server Type");
                        end;
                    }
#pragma warning restore                    
                }
                group("Para3.2")
                {
                    Caption = '';
                    InstructionalText = 'Enter the connection string to your SQL database';
                    field(SqlConnectionString; SqlConnectionStringTxt)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'SQL Connection String';
                        ExtendedDatatype = Masked;
                        ToolTip = ': Server=myServerName\myInstanceName;Database=myDataBase;User Id=myUsername;Password=myPassword;';

                        trigger OnValidate()
                        begin
                            IsChanged := true;
                        end;
                    }
                }
                group("Para3.3")
                {
                    Caption = '';
                    InstructionalText = 'If you already have an integration runtime service instance installed and want to reuse it, specify the Integration Runtime; otherwise leave the field empty to create a new Integration Runtime.';
                    Enabled = ("Sql Server Type" = "Sql Server Type"::SQLServer);
                    field(RuntimeName; RuntimeNameTxt)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Integration Runtime Name';
                        ToolTip = 'The Integration Runtime name is found in the Microsoft Integration Configuration Manager.';

                        trigger OnValidate()
                        begin
                            IsChanged := true;
                            if RuntimeNameTxt = '' then
                                IsRunTimeNameCleared := true;
                        end;
                    }
                }
            }
            group(Step4)
            {
                Caption = '';
                Visible = IRInstructionsVisible;
                group("Para4.1")
                {
                    Caption = 'Instructions';
                    group("Para4.1.1")
                    {
                        Caption = '';
                        InstructionalText = 'The data migration requires an integration runtime service. The runtime service provides a connection between your on-premises solution and your Business Central cloud tenant.';

#pragma warning disable AA0218, AA0225
                        field(DownloadShir; DownloadShirLinkTxt)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = '';
                            trigger OnDrillDown()
                            begin
                                Hyperlink(DownloadShirURLTxt);
                            end;
                        }
#pragma warning restore
                        field(RuntimeInstructions2; '2. Install the integration runtime on your on-premises database server')
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                        }
                        field(RuntimeInstructions3; '3. Use the authentication key below to set up your integration runtime')
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                        }
                        field(RuntimeInstructions4; '4. Choose Next to verify all the connections are working')
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                        }

                    }
                }
                group("4.2")
                {
                    Caption = '';
#pragma warning disable AA0218
                    field(RuntimeKey; RuntimeKeyTxt)
                    {
                        ApplicationArea = Basic, Suite;
                        Enabled = false;
                        Caption = 'Authentication Key:';
                    }
#pragma warning restore
                }
            }
            group(Step5)
            {
                ShowCaption = false;
                Visible = CompanySelectionVisible;
                group("Para5.1")
                {
                    ShowCaption = false;
                    group("Para5.1.1")
                    {
                        ShowCaption = false;
                        part(pageHybridCompanies; "Hybrid Companies")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = '';
                            UpdatePropagation = Both;
                        }
                    }
                    group("Para5.1.2")
                    {
                        ShowCaption = false;
#pragma warning disable AA0218
                        field(SelectAll; ChooseAll)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Migrate all companies';
                            trigger OnValidate();
                            var
                                HybridCompany: Record "Hybrid Company";
                            begin
                                HybridCompany.SetSelected(ChooseAll);
                                Commit();
                                CurrPage.Update();
                            end;
                        }
#pragma warning restore
                    }

                    group("Para5.1.3")
                    {
                        ShowCaption = false;
                        group("Para5.1.3.1")
                        {
                            ShowCaption = false;
                            InstructionalText = 'If you have selected a company that does not exist in Business Central, it will automatically be created for you. This may take a few minutes.';

                            field(Instruction; SetupAdditionalCompaniesInstructionTxt)
                            {
                                ShowCaption = false;
                                MultiLine = true;
                                Editable = false;
                                Enabled = false;
                                Style = Strong;
                                ApplicationArea = All;
                            }
                        }
                    }
                }
            }

#if not CLEAN19
#pragma warning disable AA0218, AA0225
            group(Step6)
            {
                Caption = '';
                Visible = false;

                ObsoleteReason = 'Scheduling is not supported and will be removed';
                ObsoleteState = Pending;
                ObsoleteTag = '19.0';

                group("Para6.1")
                {
                    Caption = 'Schedule Data Migration';
                    group("Para6.1.1")
                    {
                        Caption = '';
                        Visible = ScheduleVisible;
                        InstructionalText = 'Specify when to migrate your data to Business Central. To skip this step, select Next. To setup or change your migration schedule in Business Central, search for ''Cloud Migration Management''.';
                        field("Replication Enabled"; "Replication Enabled")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Activate Schedule';
                            ToolTip = 'Activate Migration Schedule';

                            trigger OnValidate()
                            begin
                                IsChanged := IsChanged or (Rec."Replication Enabled" <> xRec."Replication Enabled");
                            end;
                        }
                        field(Recurrence; Recurrence)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Recurrence';
                        }
                        group("Para6.1.1.2")
                        {
                            ShowCaption = false;
                            Visible = (Recurrence = Recurrence::Weekly);
                            grid("Days1")
                            {
                                ShowCaption = false;

                                field(Sunday; Sunday)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Enabled = Recurrence = Recurrence::Weekly;

                                    trigger OnValidate()
                                    begin
                                        IsChanged := IsChanged or (rec.Sunday <> xRec.Sunday);
                                    end;
                                }
                                field(Monday; Monday)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Enabled = Recurrence = Recurrence::Weekly;

                                    trigger OnValidate()
                                    begin
                                        IsChanged := IsChanged or (rec.Monday <> xRec.Monday);
                                    end;
                                }
                                field(Tuesday; Tuesday)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Enabled = Recurrence = Recurrence::Weekly;

                                    trigger OnValidate()
                                    begin
                                        IsChanged := IsChanged or (rec.Tuesday <> xRec.Tuesday);
                                    end;
                                }
                            }
                            grid("Days2")
                            {
                                ShowCaption = false;
                                field(Wednesday; Wednesday)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Enabled = Recurrence = Recurrence::Weekly;

                                    trigger OnValidate()
                                    begin
                                        IsChanged := IsChanged or (rec.Wednesday <> xRec.Wednesday);
                                    end;
                                }
                                field(Thursday; Thursday)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Enabled = Recurrence = Recurrence::Weekly;

                                    trigger OnValidate()
                                    begin
                                        IsChanged := IsChanged or (rec.Thursday <> xRec.Thursday);
                                    end;
                                }
                                field(Friday; Friday)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Enabled = Recurrence = Recurrence::Weekly;

                                    trigger OnValidate()
                                    begin
                                        IsChanged := IsChanged or (rec.Friday <> xRec.Friday);
                                    end;
                                }
                            }
                            grid("Days4")
                            {
                                ShowCaption = false;
                                field(Saturday; Saturday)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Enabled = Recurrence = Recurrence::Weekly;

                                    trigger OnValidate()
                                    begin
                                        IsChanged := IsChanged or (rec.Saturday <> xRec.Saturday);
                                    end;
                                }
                                field(Empty1; '')
                                {
                                    ApplicationArea = Basic, Suite;
                                    Caption = '';
                                }
                                field(Empty2; '')
                                {
                                    ApplicationArea = Basic, Suite;
                                    Caption = '';
                                }
                            }
                        }
                    }
                    group("Para6.2.1")
                    {
                        Caption = '';
                        field("Time to Run"; "Time to Run")
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Start time';
                            ToolTip = 'Specifies the time at which to start the migration.';

                            trigger OnValidate()
                            begin
                                IsChanged := IsChanged or (rec."Time to Run" <> xRec."Time to Run");
                            end;
                        }
                    }
                }
            }
#pragma warning restore
#endif

            group(StepFinish)
            {
                Caption = '';
                Visible = DoneVisible;
                group(AllDone)
                {
                    Caption = 'That''s It!';
                    InstructionalText = 'Choose finish to close the wizard.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionBack)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Back';
                ToolTip = 'Go to the previous page.';
                Enabled = BackEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Next';
                Enabled = NextEnabled;
                Image = NextRecord;
                ToolTip = 'Next';
                InFooterBar = true;

                trigger OnAction()
                var
                    HybridCompany: Record "Hybrid Company";
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                begin
                    if (Step = Step::Intro) and (not IsSaas) then begin
                        NavigateToBusinessCentral();
                        CurrPage.Close();
                    end;

                    if (Step = Step::SQLServerType) then
                        ValidateSqlConnectionString();

                    if Step = Step::ProductType then
                        if TempHybridProductType."Display Name" = '' then
                            Error(NoProductSelectedErr);

                    if Step = Step::CompanySelection then begin
                        HybridCompany.Reset();
                        HybridCompany.SetRange(Replicate, true);

                        if not HybridCompany.FindSet() then
                            Error(NoCompaniesSelectedErr);

                        if not HybridCloudManagement.CheckMigratedDataSize(HybridCompany) then begin
                            HybridCompany.Reset();
                            exit;
                        end;

                        HybridCompany.SetRange(Name, CompanyName());

                        if not HybridCompany.IsEmpty() then
                            Error(CannotEnableReplicationForCompanyErr);
                    end;

                    NextStep(false);
                end;
            }

            action(ActionFinish)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Finish';
                ToolTip = 'Complete and close the cloud migration setup wizard.';
                Enabled = FinishEnabled;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                begin
                    HybridCloudManagement.FinishCloudMigrationSetup(Rec);
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnInit()
    begin
        LoadTopBanners();

        if not Get() then begin
            Init();
            Insert();
            Commit();
        end;
    end;

    trigger OnOpenPage()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
    begin
        IsSaas := EnvironmentInformation.IsSaaS();

        if GetFilter("Product ID") = 'TM' then begin
            IsIntelligentCloud := true;
            Reset();
        end else
            IsIntelligentCloud := false;

        if (GetFilter("Primary Key") = HybridCloudManagement.GetRedirectFilter()) then begin
            Step := Step::ProductType;
            ShowProductTypeStep(false);
        end else
            ShowIntroStep();

        if not HybridReplicationSummary.IsEmpty() then
            if not Confirm(ConfirmCloudMigrationExistingSystemQst) then
                Error('');
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if not (CloseAction = Action::OK) then
            exit(true);

        if not IsSaas then
            exit(true);

        if not GuidedExperience.Exists("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"Hybrid Cloud Setup Wizard") then
            exit;

        if GuidedExperience.IsAssistedSetupComplete(ObjectType::Page, PAGE::"Hybrid Cloud Setup Wizard") then begin
            if Confirm(OpenCloudMigrationPageQst, true) then
                Page.Run(page::"Intelligent Cloud Management");
            exit(true);
        end else
            if not Confirm(HybridNotSetupQst, false) then
                exit(false);
    end;

    protected var
        [InDataSet]
        ProductSpecificSettingsVisible: Boolean;

    var
        TempHybridProductType: Record "Hybrid Product Type" temporary;
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResources_Standard: Record "Media Resources";
        MediaResources_Done: Record "Media Resources";
        ClientTypeManagement: Codeunit "Client Type Management";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        EnvironmentInformation: Codeunit "Environment Information";
        IsChanged: Boolean;
        TopBannerVisible: Boolean;
        IntroVisible: Boolean;
        ProductTypeVisible: Boolean;
        SQLServerTypeVisible: Boolean;
        IRInstructionsVisible: Boolean;
        CompanySelectionVisible: Boolean;
        ScheduleVisible: Boolean;
        DoneVisible: Boolean;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        FinishEnabled: Boolean;
        IsRunTimeNameCleared: Boolean;
        IsSaas: Boolean;
        ChooseAll: Boolean;
        InAgreementWithPolicy: Boolean;
        IsIntelligentCloud: Boolean;
        Step: Option Intro,DelegatedAdminStep,ProductType,SQLServerType,IRInstructions,CompanySelection,ProductSpecificSettings,Schedule,Done;
        SqlConnectionStringTxt: Text;
        RuntimeNameTxt: Text;
        RuntimeKeyTxt: Text;
        DownloadShirLinkTxt: Label '1. Download the Self-hosted Integration Runtime';
        DownloadShirURLTxt: Label 'https://www.microsoft.com/en-us/download/details.aspx?id=39717', Locked = true;
        PrivacyNoticeTxt: Label 'Privacy Notice';
        PrivacyNoticeUrlTxt: Label 'https://go.microsoft.com/fwlink/?LinkId=724009', Locked = true;
        HelpStringTxt: Label 'Help';
        HelpUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2009758', Locked = true;
        SqlConnectionStringMissingErr: Label 'Please enter a valid SQL connection string.';
        HybridNotSetupQst: Label 'Your Cloud Migration environment has not been set up.\\Are you sure that you want to exit?';
        NoProductSelectedErr: Label 'You must select a product to continue.';
        NoCompaniesSelectedErr: Label 'You must select at least one company to replicate to continue.';
        DoneWithSignupMsg: Label 'Redirecting to SaaS Business Central solution.';
        NotificationIdTxt: Label 'ce917438-506c-4724-9b01-13c1b860e851', Locked = true;
        CannotEnableReplicationForCompanyErr: Label 'You must start the cloud migration from a different company than where you are currently signed in. Change the company to a different one.';
        OpenCloudMigrationPageQst: Label 'The migration has now been set up.\\ Would you like to open the Cloud Migration Management page to manage your data migrations?';
        BlankProductIdErr: Label 'The ID of the specified product is blank. If you see this message again, contact technical support.';
        BlankProductFoundTxt: Label 'Blank product ID found for %1.', Locked = true, Comment = '%1 - Record that was selected';
        SelectedProductDescription: Text;
        SelectedProductDescriptionVisible: Boolean;
        ConfirmCloudMigrationExistingSystemQst: Label 'Do not set up cloud migration if the target environment is used for business.\\If the target environment includes even one company that is in production use, you risk that the cloud migration process overwrites any data in the database that is shared between the currently active company and any other companies in the same environment.\\Do you want to continue?';
        DelegatedAdminStepVisible: Boolean;
        ApprovalPageLinkTxt: Text;
        SetupAdditionalCompaniesInstructionTxt: Label 'Do not set up cloud migration to migrate additional companies for a production environment that is already in use for business. You risk overwriting or deleting data that is shared across companies.';


    local procedure NextStep(Backwards: Boolean)
    var
        TempStep: Option;
        ShowSettingsStep: Boolean;
    begin
        TempStep := Step;

        IncrementStep(Backwards, TempStep);

        case TempStep of
            Step::Intro:
                ShowIntroStep();
            Step::DelegatedAdminStep:
                begin
                    if not ShowDelegatedAdminStep() then begin
                        IncrementStep(Backwards, Step);
                        NextStep(Backwards);
                        exit;
                    end;

                    NextEnabled := false;
                    ApprovalPageLinkTxt := GetUrl(ClientType::Web, CurrentCompany, ObjectType::Page, Page::"Hybrid DA Approval");
                end;
            Step::ProductType:
                ShowProductTypeStep(Backwards);
            Step::SQLServerType:
                ShowSQLServerTypeStep(Backwards);
            Step::IRInstructions:
                if (HybridCloudManagement.CanSkipIRSetup("Sql Server Type", RuntimeNameTxt)) then begin
                    IncrementStep(Backwards, Step);
                    NextStep(Backwards);
                    exit;
                end else
                    ShowIRInstructionsStep(Backwards);
            Step::CompanySelection:
                if IsRunTimeNameCleared and (RuntimeKeyTxt = '') then begin
                    IncrementStep(true, Step);
                    NextStep(Backwards);
                    exit;
                end else
                    ShowCompanySelectionStep(Backwards);
            Step::ProductSpecificSettings:
                begin
                    HybridCloudManagement.OnBeforeShowProductSpecificSettingsPageStep(TempHybridProductType, ShowSettingsStep);
                    if not ShowSettingsStep then begin
                        IncrementStep(Backwards, Step);
                        NextStep(Backwards);
                        exit;
                    end else
                        ShowProductSpecificSettingsPage();
                end;
            Step::Schedule,
            Step::Done:
                ShowDoneStep(Backwards);
        end;

        Step := tempStep;
        CurrPage.Update(true);
    end;

    local procedure ShowDelegatedAdminStep(): Boolean;
    var
        DelegatedAdminStepVisible: Boolean;
    begin
        DelegatedAdminStepVisible := HybridCloudManagement.CheckNeedsApprovalToRunCloudMigration();

        ResetWizardControls();
        exit(DelegatedAdminStepVisible);
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.GET('AssistedSetup-NoText-400px.png', FORMAT(ClientTypeManagement.GetCurrentClientType())) and
           MediaRepositoryDone.GET('AssistedSetupDone-NoText-400px.png', FORMAT(ClientTypeManagement.GetCurrentClientType()))
        then
            if MediaResources_Standard.GET(MediaRepositoryStandard."Media Resources Ref") and
               MediaResources_Done.GET(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResources_Done."Media Reference".HasValue();
    end;

    local procedure ResetWizardControls()
    begin
        // Buttons
        BackEnabled := true;
        NextEnabled := true;
        FinishEnabled := false;

        // Tabs
        IntroVisible := false;
        ProductTypeVisible := false;
        SQLServerTypeVisible := false;
        IRInstructionsVisible := false;
        CompanySelectionVisible := false;
#pragma warning disable AA0206
        ProductSpecificSettingsVisible := false;
#pragma warning restore
        ScheduleVisible := false;
        DoneVisible := false;
    end;

    local procedure ShowIntroStep()
    begin
        ResetWizardControls();
        IntroVisible := true;
        if not InAgreementWithPolicy then
            NextEnabled := false;
        BackEnabled := false;
    end;

    local procedure ShowProductTypeStep(Backwards: Boolean)
    begin
        if not Backwards then
            HybridCloudManagement.OnShowProductTypeStep(TempHybridProductType);
        ResetWizardControls();
        ProductTypeVisible := true;
    end;

    local procedure ShowSQLServerTypeStep(Backwards: Boolean)
    begin
        if not Backwards then
            HybridCloudManagement.OnShowSQLServerTypeStep(TempHybridProductType);
        ResetWizardControls();
        SQLServerTypeVisible := true;
    end;

    local procedure ShowIRInstructionsStep(Backwards: Boolean)
    begin
        if not Backwards then
            HybridCloudManagement.HandleShowIRInstructionsStep(TempHybridProductType, RuntimeNameTxt, RuntimeKeyTxt);

        ResetWizardControls();
        IRInstructionsVisible := true;
    end;

    local procedure ShowCompanySelectionStep(Backwards: Boolean)
    begin
        if not Backwards and IsChanged then begin
            HybridCloudManagement.HandleShowCompanySelectionStep(TempHybridProductType, SqlConnectionStringTxt, ConvertSqlServerTypeToText(), RuntimeNameTxt);
            IsChanged := false;
        end;

        ResetWizardControls();
        CompanySelectionVisible := true;

        // Get latest changes from database to refresh the company list
        SelectLatestVersion();
        CurrPage.Update();
    end;

    local procedure ShowProductSpecificSettingsPage()
    begin
        ResetWizardControls();
#pragma warning disable AA0206
        ProductSpecificSettingsVisible := true;
#pragma warning restore
        NextEnabled := true;
    end;

    local procedure ShowDoneStep(Backwards: Boolean)
    begin
        if not Backwards then
            HybridCloudManagement.OnShowDoneStep(TempHybridProductType);
        ResetWizardControls();
        DoneVisible := true;
        NextEnabled := false;
        FinishEnabled := true;
    end;

    local procedure NavigateToBusinessCentral();
    var
        sendNotification: Notification;
    begin
        Hyperlink(HybridCloudManagement.GetSaasWizardRedirectUrl(Rec));
        sendNotification.id := NotificationIdTxt;
        sendNotification.Message := DoneWithSignupMsg;
        sendNotification.Scope := NotificationScope::LocalScope;
        sendNotification.Send();
    end;

    local procedure ValidateSqlConnectionString()
    begin
        if SqlConnectionStringTxt = '' then
            Error(SqlConnectionStringMissingErr);
    end;

    local procedure IncrementStep(Backwards: Boolean; var Step: Option)
    begin
        if (Backwards) then
            Step -= 1
        else
            Step += 1;
    end;
}