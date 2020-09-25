page 27032 "DIOT Setup Wizard"
{
    Caption = 'DIOT Setup Guide';
    PageType = NavigatePage;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(Welcome)
            {
                Visible = WelcomeStepVisible;
                group(DIOTDescription)
                {
                    Caption = 'Welcome to the DIOT Setup Wizard';
                    InstructionalText = 'The DIOT is a monthly/quarterly declaration that is required by Mexican SAT. This extension will export your data to a properly formatted file that you can import into the government-provided tool. This wizard will guide you through setting up DIOT for the Mexico version of Dynamics 365 Business Central. If you do not want to set this up right now, close this page.';
                }
            }
            group(FirstStep)
            {
                Visible = FirstStepVisible;
                group(DIOTOperationTypeDescription)
                {
                    Caption = 'Set up default DIOT Type of Operation';
                    InstructionalText = 'DIOT requires all reported operations with vendors to have a type. In this step, you can set up a default value that all new vendors will get upon creation. If you specify this value with the wizard now, all vendors in your database will be updated with the value. Note that vendors that do not operate in Mexico cannot have the Lease and Rent operation type. Do not select Lease and Rent unless all the vendors you work with operate in Mexico.';
                }

                field(DefaultDIOTVendorType; PurchasesPayablesSetup."Default Vendor DIOT Type")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Default Vendor DIOT Type of Operation';
                    ToolTip = 'Specifies the default DIOT operation type to be used for all vendors.';
                    trigger OnValidate()
                    begin
                        PurchasesPayablesSetup.Modify(true);
                    end;
                }

            }
            group(SecondStep)
            {
                Visible = SecondStepVisible;
                group(VendorDIOTTypeDescription)
                {
                    Caption = 'Set up individual DIOT Type of Operation for Vendors';
                    InstructionalText = 'DIOT requires all reported operations with vendors to have a type. In this step, you can set up a type for each vendor individually. This value will be used for all operations with the vendor, unless you specifically set another value in the individual document when posting. Currently, all vendors have a DIOT operation type equal to the default value that you selected in the previous step. If you do not want to change any existing vendors, you can ignore this step.';
                }
            }
            group(ThirdStep)
            {
                Visible = ThirdStepVisible;
                group(DIOTConceptDescription)
                {
                    Caption = 'Set up DIOT Concepts';
                    InstructionalText = 'DIOT uses several concept definitions to provide VAT-related information to SAT. You must link your existing or future VAT posting setups to the appropriate concepts for this report to produce correct and valid numbers. Please set the links up on the DIOT Concept Links page.';
                }
            }
            group(Finish)
            {
                Visible = FinishStepVisible;
                group(FinishDescription)
                {
                    Caption = 'All done!';
                    InstructionalText = 'Seems like you are all done! Now you can choose the Generate DIOT Report action to generate the DIOT file from your data.';
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
            action(OpenDIOTConceptList)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open DIOT Concepts';
                Visible = ThirdStepVisible;
                Image = SetupList;
                InFooterBar = true;
                trigger OnAction();
                begin
                    DIOTConceptsPage.RunModal();
                    Clear(DIOTConceptsPage);
                end;
            }
            action(OpenVendorDIOTTypeList)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open Vendor List';
                Visible = SecondStepVisible;
                Image = SetupList;
                InFooterBar = true;
                trigger OnAction();
                begin
                    SetupVendorDIOTTypePage.RunModal();
                    Clear(SetupVendorDIOTTypePage);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        PurchasesPayablesSetup.Get();

        Step := Step::Welcome;
        EnableControls();
    end;

    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        DIOTDataMgmt: Codeunit "DIOT Data Management";
        DIOTConceptsPage: Page "DIOT Concepts";
        SetupVendorDIOTTypePage: Page "Setup Vendor DIOT Type";
        BackActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        WelcomeStepVisible: Boolean;
        FirstStepVisible: Boolean;
        SecondStepVisible: Boolean;
        ThirdStepVisible: Boolean;
        FinishStepVisible: Boolean;
        Step: Option Welcome,First,Second,Third,Finish;
        SetupNotCompletedQst: Label 'Setup of DIOT has not been completed.\\Are you sure that you want to exit?';


    trigger OnQueryClosePage(CloseAction: Action): Boolean;
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        If not DIOTDataMgmt.GetAssistedSetupComplete() then
            if not ConfirmManagement.GetResponseOrDefault(SetupNotCompletedQst, false) then
                exit(false);
        exit(true);
    end;

    local procedure FinishAction();
    begin
        DIOTDataMgmt.SetAssistedSetupComplete();
        CurrPage.Close();
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        DoActionOnNext(Step);
        if Backwards then
            Step := Step - 1
        ELSE
            Step := Step + 1;
        EnableControls();
    end;

    local procedure EnableControls();
    begin
        HideAllControls();

        case Step of
            Step::Welcome:
                ShowWelcomeStep();
            Step::First:
                ShowFirstStep();
            Step::Second:
                ShowSecondStep();
            Step::Third:
                ShowThirdStep();
            Step::Finish:
                ShowFinish();
        end;
    end;

    local procedure ShowWelcomeStep();
    begin
        NextActionEnabled := true;
        WelcomeStepVisible := true;
    end;

    local procedure ShowFirstStep();
    begin
        BackActionEnabled := true;
        NextActionEnabled := true;
        FirstStepVisible := true;
    end;

    local procedure ShowSecondStep();
    begin
        BackActionEnabled := true;
        NextActionEnabled := true;
        SecondStepVisible := true;
    end;

    local procedure ShowThirdStep();
    begin
        BackActionEnabled := true;
        NextActionEnabled := true;
        ThirdStepVisible := true;
    end;

    local procedure ShowFinish();
    begin
        BackActionEnabled := true;
        FinishActionEnabled := true;
        FinishStepVisible := true;
    end;

    local procedure HideAllControls();
    begin
        FinishActionEnabled := false;
        BackActionEnabled := false;
        NextActionEnabled := false;

        WelcomeStepVisible := false;
        FirstStepVisible := false;
        SecondStepVisible := false;
        ThirdStepVisible := false;
        FinishStepVisible := false;
    end;

    local procedure DoActionOnNext(CurrentStep: Option)
    begin
        case CurrentStep of
            Step::First:
                UpdateTypeOnVendors();
        end;
    end;

    local procedure UpdateTypeOnVendors()
    var
        Vendor: Record Vendor;
        PurchaseAndPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchaseAndPayablesSetup.Get();
        if PurchaseAndPayablesSetup."Default Vendor DIOT Type" = PurchaseAndPayablesSetup."Default Vendor DIOT Type"::" " then
            exit;
        if not Vendor.IsEmpty() then
            Vendor.ModifyAll("DIOT Type of Operation", PurchaseAndPayablesSetup."Default Vendor DIOT Type");
    end;
}