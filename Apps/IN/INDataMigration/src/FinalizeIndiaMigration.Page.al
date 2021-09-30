page 19010 "Finalize India Migration"
{
    Caption = 'Finalize India Migration Wizard';
    PageType = NavigatePage;

    layout
    {
        area(content)
        {
            group(Control96)
            {
                Editable = false;
                ShowCaption = false;
                Visible = TopBannerVisible AND not FinalStepVisible;
            }
            group(Control98)
            {
                Editable = false;
                ShowCaption = false;
                Visible = TopBannerVisible AND FinalStepVisible;
            }
            group("<MediaRepositoryDone>")
            {
                Visible = FirstStepVisible;

                group("Welcome to Tax Engine Setup")
                {
                    Caption = 'We are almost done !!!';
                    Visible = FirstStepVisible;

                    group(Control28)
                    {
                        InstructionalText = 'This assisted setup guide helps Finalize India data migration .';
                        ShowCaption = false;
                    }
                }
                group("Let's go!")
                {
                    Caption = 'Let''s go!';
                    group(Control22)
                    {
                        InstructionalText = 'Choose Next to get started.';
                        ShowCaption = false;
                    }
                }
            }
            group(Control17)
            {
                ShowCaption = false;
                Visible = FinalStepVisible;

                group("That's it!")
                {
                    Caption = 'That''s it!';
                    InstructionalText = 'Wizard is ready to go.';
                    Visible = FinalStepVisible;
                }
                group(Control30)
                {
                    InstructionalText = 'To apply the settings, choose Finish.';
                    ShowCaption = false;
                    Visible = FinalStepVisible;
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
                ApplicationArea = Invoicing, Basic, Suite;
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
                ApplicationArea = Invoicing, Basic, Suite;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = Invoicing, Basic, Suite;
                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                var
                    TaxJsonSingleInstance: Codeunit "Tax Json Single Instance";
                begin
                    FinishAction();
                    TaxJsonSingleInstance.OpenReplcedTaxUseCases();
                end;
            }
        }
    }

    trigger OnInit()
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage()
    begin
        WizardNotification.Id := Format(CreateGuid());
        EnableControls();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        AssistedSetup: Codeunit "Assisted Setup";
    begin
        if CloseAction = Action::OK then
            if AssistedSetup.ExistsAndIsNotComplete(Page::"Tax Engine Setup Wizard") then
                if not Confirm(NAVNotSetUpQst, false) then
                    Error('');
    end;

    var
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        ClientTypeManagement: Codeunit "Client Type Management";
        WizardNotification: Notification;
        Step: Option Start,Preperation,Finish;
        TopBannerVisible: Boolean;
        FirstStepVisible: Boolean;
        FinalStepVisible: Boolean;
        FinishActionEnabled: Boolean;
        BackActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        NAVNotSetUpQst: Label 'Migration steps were not completed.\\Are you sure you want to exit?';

    local procedure EnableControls()
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowStartStep();
            Step::Finish:
                ShowFinishStep()
        end;
    end;

    local procedure FinishAction()
    var
        AssistedSetup: Codeunit "Assisted Setup";
        CallTaxEngine: Codeunit "Call Tax Engine";
    begin
        CallTaxEngine.CalculateTax();
        AssistedSetup.Complete(Page::"Tax Engine Setup Wizard");
        CurrPage.Close();
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        HideNotification();

        if Backwards then
            Step := Step - 1
        else
            if StepValidation() then
                Step := Step + 1;

        UpdateMigrationStep(Backwards);

        EnableControls();
    end;

    local procedure UpdateMigrationStep(Backwards: Boolean)
    begin
        if Step <> Step::Preperation then
            exit;

        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;
    end;

    local procedure ShowStartStep()
    begin
        FirstStepVisible := true;
        FinishActionEnabled := false;
        BackActionEnabled := false;
    end;

    local procedure ShowFinishStep()
    begin
        FinalStepVisible := true;
        NextActionEnabled := false;
        FinishActionEnabled := true;
        FirstStepVisible := false;
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        FirstStepVisible := false;
        FinalStepVisible := false;
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(ClientTypeManagement.GetCurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(ClientTypeManagement.GetCurrentClientType()))
        then
            TopBannerVisible := MediaRepositoryDone.Image.HasValue;
    end;

    local procedure StepValidation(): Boolean
    var
        ErrorMessage: Text;
    begin
        case Step of
        end;

        if ErrorMessage = '' then
            exit(true);

        TrigerNotification(ErrorMessage);
        exit(false);
    end;

    local procedure TrigerNotification(NotificationMsg: Text)
    begin
        WizardNotification.Recall();
        WizardNotification.Message(NotificationMsg);
        WizardNotification.Send();
    end;

    local procedure HideNotification()
    begin
        WizardNotification.Message := '';
        WizardNotification.Recall();
    end;
}