page 20364 "Tax Engine Setup Wizard"
{
    Caption = 'Tax Engine Setup';
    PageType = NavigatePage;
    Permissions = TableData "Tax Type" = rimd,
                  TableData "Tax Attribute" = rimd,
                  TableData "Tax Component" = rimd,
                  Tabledata "Tax Engine Notification" = rd;

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
                    Caption = 'Welcome to Tax Engine Setup';
                    Visible = FirstStepVisible;

                    group(Control28)
                    {
                        InstructionalText = 'This assisted setup guide helps you automate Tax Engine setup.';
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
            group(SecondStep)
            {
                ShowCaption = false;
                Visible = SecondStepVisible;

                group(SecondStepControl1)
                {
                    Caption = 'Looks like you already have Tax Configuration.';
                    InstructionalText = 'You can either append your changes for a Tax Type or Replace the existing configuration.';
                    Visible = SecondStepVisible;
                }
                group(SecondStepControl2)
                {
                    InstructionalText = 'But changes in Use cases will archive the previous version and create the new version.';
                    ShowCaption = false;
                    Visible = SecondStepVisible;
                }
                group(SecondStepControl3)
                {
                    Visible = SecondStepVisible;
                    ShowCaption = false;
                    field(AppendOrReplace; AppendOrReplace)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Do you want Replace your Tax Types or Append to existing Tax Types';
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
                    InstructionalText = 'Tax Engine is set up and ready to go.';
                    Visible = FinalStepVisible;
                }
                group(Control30)
                {
                    InstructionalText = 'To apply the settings, choose Finish.';
                    ShowCaption = false;
                    Visible = FinalStepVisible;
                }
                group(Control25)
                {
                    InstructionalText = 'To review your Tax Engine settings later, open the Tax Types window.';
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
            action(ExportModified)
            {
                ApplicationArea = Invoicing, Basic, Suite;
                Caption = 'Export Modified Use Cases';
                Enabled = FinishActionEnabled;
                Image = ExportFile;
                InFooterBar = true;

                trigger OnAction()
                var
                    i: Integer;
                begin
                    i := 0;
                    //blank OnAction created as we have a subscriber of this action in Use Case Archival mgmt codeunit 
                    //and ruleset doesn't allow  to create a action without the OnAction trigger
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
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if CloseAction = Action::OK then
            if GuidedExperience.AssistedSetupExistsAndIsNotComplete(ObjectType::Page, Page::"Tax Engine Setup Wizard") then
                if not Confirm(NAVNotSetUpQst, false) then
                    Error('');
    end;

    var
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        ClientTypeManagement: Codeunit "Client Type Management";
        WizardNotification: Notification;
        Step: Option Start,Preperation,Finish;
        AppendOrReplace: Option Append,Replace;
        TopBannerVisible: Boolean;
        FirstStepVisible: Boolean;
        SecondStepVisible: Boolean;
        FinalStepVisible: Boolean;
        FinishActionEnabled: Boolean;
        BackActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        NAVNotSetUpQst: Label 'Tax Engine has not been set up.\\Are you sure you want to exit?';

    local procedure EnableControls()
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowStartStep();
            Step::Preperation:
                ShowSecondStep();
            Step::Finish:
                ShowFinishStep()
        end;
    end;

    local procedure FinishAction()
    var
        TaxEngineAssistedSetup: Codeunit "Tax Engine Assisted Setup";
        GuidedExperience: Codeunit "Guided Experience";
    begin
        if AppendOrReplace = AppendOrReplace::Replace then
            ClearTaxEngineSetup();

        TaxEngineAssistedSetup.SetupTaxEngineWithUseCases();
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Tax Engine Setup Wizard");
        OnAfterFinishTaxEngineAssistedSetup();
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

        UpdateTaxTypeStep(Backwards);

        EnableControls();
    end;

    local procedure UpdateTaxTypeStep(Backwards: Boolean)
    var
        TaxType: Record "Tax Type";
    begin
        if not TaxType.IsEmpty then
            exit;

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

    local procedure ShowSecondStep()
    begin
        FirstStepVisible := false;
        FinishActionEnabled := false;
        SecondStepVisible := true;
        BackActionEnabled := true;
    end;

    local procedure ShowFinishStep()
    begin
        FinalStepVisible := true;
        NextActionEnabled := false;
        FinishActionEnabled := true;
        SecondStepVisible := false;
        FirstStepVisible := false;
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        FirstStepVisible := false;
        SecondStepVisible := false;
        FinalStepVisible := false;
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(ClientTypeManagement.GetCurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(ClientTypeManagement.GetCurrentClientType()))
        then
            TopBannerVisible := MediaRepositoryDone.Image.HasValue;
    end;

    local procedure ClearTaxEngineSetup()
    var
        TaxType: Record "Tax Type";
        TaxTypeObjectHelper: Codeunit "Tax Type Object Helper";
    begin
        if not TaxType.IsEmpty() then begin
            TaxTypeObjectHelper.DisableSelectedTaxTypes(TaxType);
            TaxType.DeleteAll(true);
        end;
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

    [IntegrationEvent(true, false)]
    local procedure OnAfterFinishTaxEngineAssistedSetup()
    begin
    end;
}