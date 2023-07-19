page 2718 "Page Summary Settings"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Card Settings';
    AdditionalSearchTerms = 'teams,adaptive card,link preview,summary,power automate,O365,M365,Microsoft 365';
    DelayedInsert = true;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    Extensible = false;
    AccessByPermission = tabledata "Page Summary Settings" = M;
    Permissions = tabledata Media = r, tabledata "Media Resources" = r;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(NotCompletedTopBanner)
            {
                Editable = false;
                ShowCaption = false;
                Visible = TopBannerVisible and not DoneStepVisible and not TryItOutStepVisible;
                field(NotDoneIcon; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(CompletedTopBanner)
            {
                Editable = false;
                ShowCaption = false;
                Visible = CompletedBannerVisible and (DoneActionVisible or TryItOutStepVisible);
                field(CompletedIcon; CompletedMediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }

            group(IntroSaasStep)
            {
                Visible = IntroSaasStepVisible;
                ShowCaption = false;

                group("IntroductionSaasGroup")
                {
                    ShowCaption = false;

                    label(IntroductionSaasLabel)
                    {
                        ApplicationArea = All;
                        CaptionClass = IntroductionText;
                    }

                    label(IntroductionPart2Label)
                    {
                        ApplicationArea = All;
                        CaptionClass = IntroductionPart2Text;
                    }

                    field(LearnMoreSaas; LearnMoreSaasText)
                    {
                        ShowCaption = false;
                        Editable = false;
                        ApplicationArea = All;

                        trigger OnDrillDown()
                        begin
                            Hyperlink(LearnMoreSaaSUrlLbl);
                        end;
                    }
                }

                group("Let's go!")
                {
                    Caption = 'Let''s go!';

                    group(GetStartedGroup)
                    {
                        Caption = '';
                        InstructionalText = 'Choose Next to get started.';
                        Visible = NextActionVisible;
                    }

                    group(MissingPermissions)
                    {
                        Caption = '';
                        InstructionalText = 'You do not have sufficient permissions to run this setup.';
                        Visible = not NextActionVisible;
                    }
                }
            }

            group(IntroSaasOnPrem)
            {
                Visible = IntroOnPremStepVisible;
                ShowCaption = false;

                group("IntroductionOnPremGroup")
                {
                    Caption = 'Card settings are not available';

                    label(IntroductionOnPremLabel)
                    {
                        ApplicationArea = All;
                        CaptionClass = IntroductionText;
                    }

                    field(LearnMoreOnPrem; LearnMoreOnPremLbl)
                    {
                        ShowCaption = false;
                        Editable = false;
                        ApplicationArea = All;

                        trigger OnDrillDown()
                        begin
                            Hyperlink(LearnMoreOnPremUrlLbl);
                        end;
                    }
                }
            }

            group(ConfigureStep)
            {
                Visible = ConfigureStepVisible;
                ShowCaption = false;

                group(ConfigureIntroduction)
                {
                    Caption = 'Data visibility';

                    group(ConfigureDataVisibilty)
                    {
                        ShowCaption = false;

                        label(ConfigureDataVisibiltyIntro)
                        {
                            ApplicationArea = All;
                            CaptionClass = ConfigureDataVisibiltyIntroText;
                        }

                        field(ShowRecordSummary; ShowRecordSummary)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies if the card shows the summary fields and images of the record.';
                            Caption = 'Show record summary';
                        }
                    }
                }
            }
            group(SuccessStep)
            {
                Visible = DoneStepVisible;
                ShowCaption = false;

                group(SucessGroup)
                {
                    Caption = 'Success!';

                    group(SuccessPart1)
                    {
                        ShowCaption = false;
                        InstructionalText = 'Your settings will be applied to all newly created cards. Any cards that were shared previously will not be affected.';
                    }
                    group(SuccessPart2)
                    {
                        ShowCaption = false;
                        InstructionalText = 'Settings affect cards with data from all companies in this environment. To apply similar settings to other environments, use the switcher (Ctrl+O) then run this guided setup again.';
                    }
                    group(SuccessPart3)
                    {
                        ShowCaption = false;
                        InstructionalText = 'Choose ‘Try it out’ to experience how cards are shared in Microsoft Teams.';
                    }
                }
            }

            group(TryItOut)
            {
                Visible = TryItOutStepVisible;
                ShowCaption = false;

                group(TryItOutGroup)
                {
                    Caption = 'Share something with your coworkers';

                    group(TryItOutPart1)
                    {
                        ShowCaption = false;
                        InstructionalText = 'Go to any list or card page and use the Share to Teams action.';
                    }

                    group(TryItOutPara3)
                    {
                        ShowCaption = false;
                        InstructionalText = '💡 If you have not yet installed the Business Central app for Teams, a banner will appear when you share the link to a Business Central page. Follow the link in the banner to install the app.';
                    }

                    field(LearnMoreTryItOut; LearnMoreTryItOutLbl)
                    {
                        ShowCaption = false;
                        Editable = false;
                        ApplicationArea = All;

                        trigger OnDrillDown()
                        begin
                            Hyperlink(LearnMoreSaasUrlLbl);
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
                Visible = BackActionVisible;
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
                Visible = NextActionVisible;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(false);
                end;
            }

            action(ActionTryItOut)
            {
                ApplicationArea = All;
                Caption = 'Try it out';
                Visible = TryItOutActionVisible;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(false);
                end;
            }

            action(ActionClose)
            {
                ApplicationArea = All;
                Caption = 'Close';
                Visible = CloseActionVisible;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CloseAction();
                end;
            }
            action(ActionDone)
            {
                ApplicationArea = All;
                Caption = 'Done';
                Visible = DoneActionVisible;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CloseAction();
                end;
            }
        }
    }

    trigger OnInit()
    var
        ProductNameShort: Text;
    begin
        LoadTopBanner();
        ProductNameShort := ProductName.Short();
        IntroductionText := StrSubstNo(IntroductionSaasLbl, ProductName.Short());
        IntroductionPart2Text := StrSubstNo(IntroductionSaasPart2Lbl, ProductNameShort);
        ConfigureDataVisibiltyIntroText := StrSubstNo(ConfigureDataVisibiltyIntroLbl, ProductNameShort);
        LearnMoreSaasText := StrSubstNo(LearnMoreSaasLbl, ProductNameShort);
    end;

    trigger OnOpenPage()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        IsSaaS := EnvironmentInformation.IsSaaSInfrastructure();
        ShowRecordSummary := true;
        Step := Step::Intro;
        EnableControls();
    end;

    local procedure CloseAction()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        // Mark setup completed
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Page Summary Settings");
        CurrPage.Close();
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        EnableControls();
    end;

    local procedure EnableControls()
    begin
        ResetControls();

        case Step of
            Step::Intro:
                ShowIntroStep();
            Step::Configure:
                ShowConfigureStep();
            Step::Done:
                ShowDoneStep();
            Step::TryItOut:
                ShowTryItOutStep();
        end;
    end;

    local procedure ShowIntroStep()
    var
        PageSummaryProviderSettings: Record "Page Summary Settings";
    begin
        If IsSaaS then begin
            IntroSaasStepVisible := true;
            NextActionVisible := PageSummaryProviderSettings.ReadPermission() and PageSummaryProviderSettings.WritePermission();
        end else
            ShowIntroOnPrem();

    end;

    local procedure ShowIntroOnPrem()
    begin
        IntroductionText := StrSubstNo(IntroductionOnPremLbl, ProductName.Short());
        IntroOnPremStepVisible := true;
        CloseActionVisible := true;
    end;

    local procedure ShowConfigureStep()
    var
        PageSummarySettings: Codeunit "Page Summary Settings";
    begin
        ConfigureStepVisible := true;

        BackActionVisible := true;
        NextActionVisible := true;
        ShowRecordSummary := PageSummarySettings.IsShowRecordSummaryEnabled();
    end;

    local procedure ShowDoneStep()
    begin
        SaveSettings();

        DoneStepVisible := true;

        BackActionVisible := true;
        TryItOutActionVisible := true;
        DoneActionVisible := true;
    end;

    local procedure ShowTryItOutStep()
    begin
        TryItOutStepVisible := true;

        BackActionVisible := true;
        CloseActionVisible := true;
    end;

    local procedure ResetControls()
    begin
        // Reset actions visibilty
        NextActionVisible := false;
        BackActionVisible := false;
        DoneActionVisible := false;
        CloseActionVisible := false;
        TryItOutActionVisible := false;

        // Reset steps visibilty
        IntroSaasStepVisible := false;
        IntroOnPremStepVisible := false;
        ConfigureStepVisible := false;
        DoneStepVisible := false;
        TryItOutStepVisible := false;
    end;

    local procedure LoadTopBanner()
    begin
        if MediaResourcesStandard.Get('ASSISTEDSETUP-NOTEXT-400PX.PNG') and (CurrentClientType() = ClientType::Web) then
            TopBannerVisible := MediaResourcesStandard."Media Reference".HasValue();

        if CompletedMediaResourcesStandard.Get('ASSISTEDSETUPDONE-NOTEXT-400px.PNG') and (CurrentClientType() = ClientType::Web) then
            CompletedBannerVisible := CompletedMediaResourcesStandard."Media Reference".HasValue();
    end;

    local procedure SaveSettings()
    var
        PageSummaryProviderSettings: Record "Page Summary Settings";
        NullGuid: Guid;
    begin
        PageSummaryProviderSettings.DeleteAll(); // Clear setups for all companies

        // Configure a setup for all companies
        PageSummaryProviderSettings.Validate(Company, NullGuid);
        PageSummaryProviderSettings.Validate("Show Record summary", ShowRecordSummary);
        PageSummaryProviderSettings.Insert(true);
        Session.LogMessage('0000JLU', StrSubstNo(CompletedGuideTelemetryTxt, ShowRecordSummary), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PageSummaryCategoryLbl);
    end;

    var
        MediaResourcesStandard, CompletedMediaResourcesStandard : Record "Media Resources";
        Step: Option Intro,Configure,Done,TryItOut;
        TopBannerVisible, CompletedBannerVisible : Boolean;
        IntroSaasStepVisible, IntroOnPremStepVisible, ConfigureStepVisible, DoneStepVisible, TryItOutStepVisible : Boolean;
        NextActionVisible, BackActionVisible, DoneActionVisible, CloseActionVisible, TryItOutActionVisible : Boolean;
        IsSaaS: Boolean;
        ShowRecordSummary: Boolean;
        IntroductionText, IntroductionPart2Text, ConfigureDataVisibiltyIntroText, LearnMoreSaasText : Text;
        IntroductionSaasLbl: Label '%1 data can be displayed as compact cards in Microsoft Teams or in Power Automate flows.', Comment = '%1=The short product name (e.g. Business Central)';
        IntroductionSaasPart2Lbl: Label 'Administrators can configure security settings that determine whether content is summarized and displayed directly on any card. Card settings do not affect what is displayed when users choose the Details button on a card: that information is governed by %1’s other security, privacy and licensing controls.', Comment = '%1=The short product name (e.g. Business Central)';
        LearnMoreSaasLbl: Label 'Learn about sharing %1 records to Teams', Comment = '%1=The short product name (e.g. Business Central)';
        LearnMoreSaasUrlLbl: Label 'https://go.microsoft.com/fwlink/?linkid=2219744', Locked = true;
        IntroductionOnPremLbl: Label 'Adaptive cards and other features that connect to Microsoft Teams are only available with %1 online.', Comment = '%1=The short product name (e.g. Business Central)';
        LearnMoreOnPremLbl: Label 'Learn about minimum requirements for Teams integration';
        LearnMoreOnPremUrlLbl: Label 'https://go.microsoft.com/fwlink/?linkid=2222842', Locked = true;
        ConfigureDataVisibiltyIntroLbl: Label 'When a card is shared with others, all recipients can view a summary of the record as fields displayed directly on the card, regardless of their license or permissions in %1. Hiding the record summary removes all fields and images, but continues to show the Details button and other non-record information on the card.', Comment = '%1=The short product name (e.g. Business Central)';
        LearnMoreTryItOutLbl: Label 'Learn about other ways to share data as cards in Teams';
        CompletedGuideTelemetryTxt: Label 'Card settings guide completed with Show Record Summary status: %1.', Locked = true;
        PageSummaryCategoryLbl: Label 'Page Summary Provider', Locked = true;
}
