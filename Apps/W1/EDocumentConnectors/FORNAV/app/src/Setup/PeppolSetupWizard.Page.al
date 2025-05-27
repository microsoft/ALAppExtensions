namespace Microsoft.EServices.EDocumentConnector.ForNAV;

using System.Utilities;
using System.Environment;
page 6414 "ForNAV Peppol Setup Wizard"
{
    PageType = NavigatePage;
    SourceTable = "ForNAV Peppol Setup";
    SourceTableTemporary = true;
    Caption = 'ForNAV Peppol Setup Wizard';
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(TopBanner)
            {
                Editable = false;
                ShowCaption = false;
                Visible = TopBannerVisible and not FinalStepVisible;
                field(MediaRepositoryStandardImage; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(TopBannerFinal)
            {
                Editable = false;
                ShowCaption = false;
                Visible = TopBannerVisible and FinalStepVisible;
                field(MediaRepositoryDoneImage; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Step1)
            {
                Caption = 'Setup the ForNAV Peppol connector.', Locked = true;
                Visible = Step1Visible;
                InstructionalText = 'Set up the ForNAV Peppol connection.', Locked = true;
                group(welcome)
                {
                    ShowCaption = false;
                    InstructionalText = 'This wizard will help you to connect to the ForNAV Peppol network.', Locked = true;
                }
            }
            group(Step2)
            {
                Visible = Step2Visible;
                Caption = 'Grant Access', Locked = true;
                InstructionalText = 'Step 1 - Grant Access.', Locked = true;
                group(Go1)
                {
                    ShowCaption = false;
                    InstructionalText = 'In order to publish you need to give concent to allow for Incoming Pepol documents', Locked = true;
                }
                group(AdminNote)
                {
                    ShowCaption = false;
                    InstructionalText = 'NOTE: You will be asked to log in as an ADMIN user on AZURE. It is not enough to be admin in Business Central.', Locked = true;
                }
            }
            group(Step3)
            {
                Visible = Step3Visible;
                Caption = 'Oauth Setup', Locked = true;
                InstructionalText = 'Step 2 - Oauth Setup.', Locked = true;
                group(Go2)
                {
                    ShowCaption = false;
                    InstructionalText = 'We need some additional information so we can connect you to the ForNAV Peppol network.', Locked = true;
                }
                field(CompanyName; Rec.Name)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the name of the company.';
                }
                field("Identification Code"; Rec."Identification Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the identification code of the company.';
                }
                field("Identification Value"; Rec."Identification Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the identification value of the company.';
                }
                field(SerialNumber; Database.SerialNumber())
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = ManualSetupEnabled;
                    Caption = 'Serial Number';
                    ToolTip = 'Specifies the Business Central license serial number.';
                }
                field(ContactPerson; ContactPerson)
                {
                    ApplicationArea = All;
                    Caption = 'Contact Person';
                    ToolTip = 'Specifies the contact person of the company.';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        Rec.Validate("Contact Person", ContactPerson);
                    end;
                }
                field(EMail; EMail)
                {
                    ApplicationArea = All;
                    Caption = 'E-Mail';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the email of the contact person.';
                    trigger OnValidate()
                    begin
                        Rec.Validate("E-Mail", EMail);
                    end;
                }
                group(AutoOauthSetup)
                {
                    ShowCaption = false;
                    Visible = not ManualSetupEnabled;
                    InstructionalText = 'We will now add the Oauth keys so you can connect to the ForNAV Peppol network. This may take a while.', Locked = true;
                }
                group(ManualOauthSetup)
                {
                    ShowCaption = false;
                    Visible = ManualSetupEnabled;
                    InstructionalText = 'We will now sned your information to ForNAV. When you have been approved you will receive an Oauth setup file so you can connect to the ForNAV Peppol network.', Locked = true;
                }
            }
            group(Step4)
            {
                Visible = Step4Visible;
                InstructionalText = 'Step 3 - Upload setupfile.', Locked = true;
                Caption = 'Done', Locked = true;
                group(Go3)
                {
                    ShowCaption = false;
                    Visible = Rec.Authorized;
                    InstructionalText = 'Please upload the setup file you have received.', Locked = true;
                }
                field(SetupPasscode; SetupPasscode)
                {
                    ApplicationArea = All;
                    Caption = 'Setup Passcode';
                    ToolTip = 'Specifies the Oauth setup passcode. You will get this from your ForNAV partner after your application has been approved.';

                    trigger OnValidate()
                    begin
                        ValidateSetupPasscode();
                    end;
                }
            }
            group(FinalStep)
            {
                Visible = FinalStepVisible;
                InstructionalText = 'Done - Test Setup.', Locked = true;
                Caption = 'Done', Locked = true;
                group(Go4)
                {
                    ShowCaption = false;
                    Visible = Rec.Authorized;
                    InstructionalText = 'That''s it, you are now ready to connect to the ForNAV Peppol network.', Locked = true;
                }
                group(Fault)
                {
                    ShowCaption = false;
                    Visible = not Rec.Authorized;
                    InstructionalText = 'We were unable to connect to the ForNAV Peppol network. Contact your ForNAV Partner for help.', Locked = true;
                }
                field(ClientId; GetClientID())
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Client Id';
                    ToolTip = 'Specifies the Oauth Client Id. You can get this from your ForNAV partner.';
                }
                field(Authorized; Rec.Authorized)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies if the Oauth setup has been tested.';
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
                ApplicationArea = All;
                Caption = 'Back', Locked = true;
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(true)
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next', Locked = true;
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(false)
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish', Locked = true;
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

    trigger OnInit()
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage()
    var
        Setup: Record "ForNAV Peppol Setup";
    begin
        Setup.InitSetup();
        Rec := Setup;
        ContactPerson := Rec."Contact Person";
        EMail := Rec."E-Mail";
        Step := Step::Step1;
        SetManualSetup();
        EnableControls();
    end;

    var
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        Step: Option Step1,Step2,Step3,Step4,Finish;
        SetupPasscode: text;
        ContactPerson: Text[50];
        EMail: Text[80];
        TopBannerVisible: Boolean;
        Step1Visible: Boolean;
        Step2Visible: Boolean;
        Step3Visible: Boolean;
        Step4Visible: Boolean;
        FinalStepVisible: Boolean;
        BackActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        ManualSetupEnabled: Boolean;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) and
            MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") AND
                MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    local procedure EnableControls()
    begin
        ResetControls();

        case Step of
            Step::Step1:
                if ManualSetupEnabled and (Rec."Oauth Setup Request Sent" <> 0D) then
                    ShowStep4()
                else
                    ShowStep1();
            Step::Step2:
                if ManualSetupEnabled then
                    ShowStep3()
                else
                    ShowStep2();
            Step::Step3:
                ShowStep3();
            Step::Step4:
                if ManualSetupEnabled then
                    ShowStep4()
                else
                    ShowFinishStep();
            Step::Finish:
                ShowFinishStep();
        end;
    end;

    local procedure SetManualSetup()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        ManualSetupEnabled := not EnvironmentInformation.IsSaaSInfrastructure();
    end;

    local procedure ProcessStepAction()
    var
        Setup: Record "ForNAV Peppol Setup";
        PeppolAadApp: Codeunit "ForNAV Peppol Aad App";
    begin
        case Step of
            Step::Step1:
                ;
            Step::Step2:
                begin
                    PeppolAadApp.CreateAADApplication(false);
                    PeppolAadApp.GrantAccess();
                end;
            Step::Step3:
                begin
                    // TODO add processing bar
                    Rec.TestField(Name);
                    Rec.TestField("Identification Code");
                    Rec.TestField("Identification Value");
                    Rec.TestField("Contact Person");
                    Rec.TestField("E-Mail");
                    Setup.FindFirst();
                    Setup."Contact Person" := Rec."Contact Person";
                    Setup."E-Mail" := Rec."E-Mail";
                    Setup.Modify();
                    Setup.SetupOauth();
                    Rec := Setup;
                    CurrPage.Update();
                end;
            Step::Step4:
                Rec.ProcessStoredOauthRequest(SetupPasscode);
            Step::Finish:
                ;
        end;
    end;

    local procedure ShowStep1()
    begin
        Step := Step::Step1;
        Step1Visible := true;
        BackActionEnabled := false;
        NextActionEnabled := true;
    end;

    local procedure ShowStep2()
    begin
        Step := Step::Step2;
        Step2Visible := true;
        NextActionEnabled := true;
    end;

    local procedure ShowStep3()
    begin
        Step := Step::Step3;
        Step3Visible := true;
        NextActionEnabled := true;
    end;

    local procedure ShowStep4()
    begin
        Step := Step::Step4;
        Step4Visible := true;
        // BackActionEnabled := false;
        NextActionEnabled := false;
    end;

    local procedure ShowFinishStep()
    begin
        Step := Step::Finish;
        NextActionEnabled := false;
        FinalStepVisible := true;
        FinishActionEnabled := Rec.Authorized;
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        Step1Visible := false;
        Step2Visible := false;
        Step3Visible := false;
        Step4Visible := false;
        FinalStepVisible := false;
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        ProcessStepAction();
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;
        EnableControls();
    end;

    local procedure FinishAction()
    begin
        CurrPage.Close();
    end;

    local procedure ValidateSetupPasscode()
    var
        PasscodeErr: Label 'Invalid setup passcode', Locked = true;
    begin
        case false of
            StrLen(SetupPasscode) = 30:
                Error(PasscodeErr);
        end;

        NextActionEnabled := true;
    end;

    local procedure GetClientID(): Text
    var
        PeppolOauth: Codeunit "ForNAV Peppol Oauth";
    begin
        exit(PeppolOauth.GetClientID());
    end;
}