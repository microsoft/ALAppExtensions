// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This is a wizard which guides the user through setting up their tenant for using Edit in Excel with Excel add-in installed through centralized deployments.
/// </summary>
page 1480 "Excel Centralized Depl. Wizard"
{
    Caption = 'Excel Add-in Centralized Deployment';
    AdditionalSearchTerms = 'addin,addon,app,plugin,Office,O365,M365,Microsoft 365';
    PageType = NavigatePage;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Edit in Excel Settings";
    Extensible = false;
    AccessByPermission = tabledata "Edit in Excel Settings" = M;
    Permissions = tabledata "Media Resources" = r;

    layout
    {
        area(content)
        {
            group(Done)
            {
                Editable = false;
                ShowCaption = false;
                Visible = TopBannerVisible;
                field(NotDoneIcon; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = ' ';
                    Caption = ' ';
                }
            }

            group(Step1)
            {
                Visible = Step1Visible;
                group("Welcome to Excel Centralized Deployment")
                {
                    Caption = 'Business Central Excel add-in setup';

                    group("IntroductionSubgroup")
                    {
                        Caption = '';

                        group(IntroductionGroup)
                        {
                            Caption = '';
                            InstructionalText = 'If your organization does not allow users to access the Office Store (AppSource), administrators can configure Centralized Deployment to control which users or groups can continue accessing the Excel add-in.';
                        }
                        field(LearnHowExcelFilesAreImpactedField; LearnHowExcelFilesAreImpactedTxt)
                        {
                            ShowCaption = false;
                            Editable = false;
                            ApplicationArea = All;

                            trigger OnDrillDown()
                            begin
                                Hyperlink('https://go.microsoft.com/fwlink/?linkid=2168300');
                            end;
                        }
                        field(CentralizedDeploymentLinkField; CentralizedDeploymentLinkTxt)
                        {
                            ShowCaption = false;
                            Editable = false;
                            ApplicationArea = All;

                            trigger OnDrillDown()
                            begin
                                Hyperlink('https://go.microsoft.com/fwlink/?linkid=2164357');
                            end;
                        }
                        group(AffectsGroup)
                        {
                            Caption = '';
                            InstructionalText = 'Enabling Centralized Deployment affects features that use the Excel add-in, such as the ‘Edit in Excel’ action, but has no impact on other Excel-related features and does not affect permissions assigned to users in Business Central.';
                        }
                    }
                }

                group("Let's go!")
                {
                    Caption = 'Let''s go!';
                    group(GetStartedGroup)
                    {
                        Caption = '';
                        InstructionalText = 'Centralized Deployment requires configuring both Microsoft 365 and Business Central. Choose Next to get started.';
                    }
                }
            }

            group(Step2)
            {
                Visible = Step2Visible;
                group(ConfigureIntroduction)
                {
                    Caption = 'Configure Microsoft 365';

                    group(ConfigureMicrosoft365)
                    {
                        Caption = '';
                        InstructionalText = 'Let’s start by configuring app settings in Microsoft 365. You must be part of the Office apps admin role or Global admin role to do this.';
                    }
                    group(ConfigureMicrosoft365Step1)
                    {
                        Caption = '';

                        field(IntegratedAppsSetup; GoToIntegratedAppsLinkTxt)
                        {
                            ShowCaption = false;
                            Editable = false;
                            ApplicationArea = All;

                            trigger OnDrillDown()
                            begin
                                Hyperlink('https://go.microsoft.com/fwlink/?linkid=2163967');
                            end;
                        }
                    }
                    group(ConfigureMicrosoft365Step2)
                    {
                        Caption = '';
                        InstructionalText = '2. Choose ‘Get apps’, then search for and add ‘Microsoft Dynamics Office Add-in´.';
                    }
                    group(ConfigureMicrosoft365Step3)
                    {
                        Caption = '';
                        InstructionalText = '3. Follow the deployment instructions and choose who has access to the add-in.';
                    }
                }

                group(AllDoneQuestionGroup)
                {
                    Caption = 'All done?';
                    group(SetupBusinessCentralExplanationGroup)
                    {
                        Caption = '';
                        InstructionalText = 'After the add-in has been deployed, choose Next to configure Business Central.';
                    }
                }
            }

            group(Step3)
            {
                Visible = Step3Visible;
                group(ConfigureBusinessCentralGroup)
                {
                    Caption = 'Configure Business Central';
                    group(AcquisitionExplanationPart1)
                    {
                        Caption = '';
                        InstructionalText = 'Users of this environment can either receive the add-in through Centralized Deployment or through individual acquisition from the Office Store, but not both.';
                    }
                    group(AcquisitionExplanationPart2)
                    {
                        Caption = '';
                        InstructionalText = 'Enabling Centralized Deployment on this environment requires users to have their identity assigned to the add-in in Microsoft 365 as specified in the previous step to continue using the Edit in Excel feature.';
                    }
                    field(DeploymentType; Rec."Use Centralized deployments")
                    {
                        Caption = 'Use Centralized Deployment';
                        Tooltip = 'Enables Centralized Deployment on this environment.';
                        ApplicationArea = All;
                    }
                    field(LearnAboutConfiguringBcForCentralizedDeployment; LearnAboutConfiguringBcForCentralizedDeploymentLinkTxt)
                    {
                        ShowCaption = false;
                        Editable = false;
                        ApplicationArea = All;

                        trigger OnDrillDown()
                        begin
                            Hyperlink('https://go.microsoft.com/fwlink/?linkid=2163968');
                        end;
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
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Visible = not FinishActionEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Visible = FinishActionEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    FinishAction();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Get() then
            Insert();

        Step := Step::Start;
        EnableControls();
    end;

    trigger OnInit()
    begin
        LoadTopBanners();
    end;

    local procedure EnableControls()
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowStep1();
            Step::Step2:
                ShowStep2();
            Step::Finish:
                ShowStep3();
        end;
    end;

    local procedure FinishAction()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Excel Centralized Depl. Wizard");
        CurrPage.Close();
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if Backwards then
            Step := Step - 1
        ELSE
            Step := Step + 1;

        EnableControls();
    end;

    local procedure ShowStep1()
    begin
        Step1Visible := true;

        FinishActionEnabled := false;
        BackActionEnabled := false;
    end;

    local procedure ShowStep2()
    begin
        Step2Visible := true;
    end;

    local procedure ShowStep3()
    begin
        Step3Visible := true;

        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        Step1Visible := false;
        Step2Visible := false;
        Step3Visible := false;
    end;

    local procedure LoadTopBanners()
    begin
        if MediaResourcesStandard.Get('ASSISTEDSETUP-NOTEXT-400PX.PNG') and (CurrentClientType() = ClientType::Web)
        then
            TopBannerVisible := MediaResourcesStandard."Media Reference".HasValue();
    end;

    var
        MediaResourcesStandard: Record "Media Resources";
        TopBannerVisible: Boolean;
        Step: Option Start,Step2,Finish;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        Step1Visible: Boolean;
        Step2Visible: Boolean;
        Step3Visible: Boolean;
        CentralizedDeploymentLinkTxt: Label 'Requirements for Centralized Deployment of Add-ins';
        LearnHowExcelFilesAreImpactedTxt: Label 'Learn how Excel files are impacted by removing AppSource access';
        GoToIntegratedAppsLinkTxt: Label '1. In the Microsoft 365 admin center, go to Integrated Apps.';
        LearnAboutConfiguringBcForCentralizedDeploymentLinkTxt: Label 'Learn more about Configuring Business Central for Centralized Deployment​';
}
