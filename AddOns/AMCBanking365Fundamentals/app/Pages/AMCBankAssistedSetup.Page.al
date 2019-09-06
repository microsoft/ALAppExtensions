page 20105 "AMC Bank Assisted Setup"
{
    Caption = 'AMC Banking 365 Foundation Assisted Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    ShowFilter = false;
    SourceTable = "AMC Banking Setup";
    SourceTableTemporary = true;
    ContextSensitiveHelpPage = '306';

    layout
    {
        area(content)
        {
            group(Control19)
            {
                Caption = ' ';
                Editable = false;
                Visible = TopBannerVisible AND NOT DoneVisible;
                field(MediaResourcesStandard; MediaResourcesStandardRecord."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Control17)
            {
                Caption = ' ';
                Editable = false;
                Visible = TopBannerVisible AND DoneVisible;
                field(MediaResourcesDone; MediaResourcesDoneRecord."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Step1)
            {
                Caption = ' ';
                Visible = IntroVisible;
                group("Para1.1")
                {
                    Caption = 'Welcome';
                    group("Para1.1.1")
                    {
                        Caption = ' ';
                        InstructionalText = 'The AMC Banking 365 Foundation extension saves you time and reduces errors when you send data to your bank. The extension uses the AMC Banking 365 Business service to transform data from Microsoft Dynamics 365 Business Central into formats that banks require. You specify the bank, and the extension does the rest. For more information, see the documentation.';
                    }
                    field(AMCBankingHelpLink; 'AMC Banking 365 Foundation documentation')
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            Hyperlink('https://go.microsoft.com/fwlink/?linkid=2101583');
                        end;
                    }
                    field(ConsentPart; 'By enabling this extension you consent to sharing your data with an external system. Your use of this extension may be subject to additional licensing terms from AMC. To enable the service you must read and accept the terms of use.')
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;
                        MultiLine = true;
                    }
                    field(TermsOfUseLink; 'AMC Banking 365 Foundation terms of use')
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;

                        trigger OnDrillDown()
                        begin
                            Hyperlink('https://go.microsoft.com/fwlink/?linkid=2102117');
                        end;
                    }
                    field(AcceptConsent; ConsentAccepted)
                    {
                        ApplicationArea = Basic, Suite;
                        MultiLine = true;
                        Editable = true;
                        Caption = 'I understand and accept these terms';
                        trigger OnValidate()
                        begin
                            if not ConsentAccepted then
                                ShowIntroStep();
                            StartEnabled := ConsentAccepted;
                        end;
                    }
                    group("Para1.1.2")
                    {
                        Caption = 'Let''s get started';
                        Enabled = ConsentAccepted;
                        field(UpdAll1; UpdALL)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Use default values for AMC Banking setup';
                            ToolTip = 'Use the default settings for back formats, payment methods, and data exchange definitions.';

                            trigger OnValidate();
                            begin
                                SetDefaultValues();
                            end;
                        }
                    }
                }
            }
            group("Para2.1")
            {
                Caption = ' ';
                Visible = ChoseUpdVisible;
                group("Para2.1.1")
                {
                    Caption = 'Please choose what to setup:';
                    Visible = ChoseUpdVisible;
                    group("Para2.1.2")
                    {
                        Caption = ' ';
                        Visible = ChoseUpdVisible;
                        group("Para2.1.3")
                        {
                            Caption = ' ';
                            Visible = ChoseUpdVisible;
                            group("Para2.1.3.1")
                            {
                                Caption = 'Change the Service, Support and Sign-up URLs to their default values.';
                                Visible = ChoseUpdVisible;
                                field(UpdURL; UpdURLBoolean)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Caption = 'Set URLs to Default';
                                    ToolTip = 'Change the Service, Support and Sign-up URLs to their default values.';

                                    trigger OnValidate();
                                    begin
                                        EnableNextStep();
                                    end;
                                }
                            }
                        }
                        group("Para2.1.4")
                        {
                            Caption = ' ';
                            Visible = ChoseUpdVisible;
                            group("Para2.1.4.1")
                            {
                                Caption = 'Update the list of banks in your country/region that you can use to import or export bank account data using the AMC Banking.';
                                Visible = ChoseUpdVisible;
                                field(UpdBank; UpdBankBoolean)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Caption = 'Update Bank Name List';
                                    ToolTip = 'Update the list of banks in your country/region that you can use to import or export bank account data using the AMC Banking.';

                                    trigger OnValidate();
                                    begin
                                        EnableNextStep();
                                    end;
                                }
                            }
                        }
                        group("Para2.1.5")
                        {
                            Caption = ' ';
                            Visible = ChoseUpdVisible;
                            group("Para2.1.5.1")
                            {
                                Caption = 'Setup Data Exchange Definitions to current version of your system for AMC Banking.';
                                Visible = ChoseUpdVisible;
                                field(UpdDataExchDef; UpdDataExchDefBoolean)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Caption = 'Setup Data Exchange Definitions';
                                    ToolTip = 'Setup Data Exchange Definitions to current version of your system for AMC Banking.';

                                    trigger OnValidate();
                                    begin
                                        EnableNextStep();
                                    end;
                                }
                            }
                        }
                        group("Para2.1.6")
                        {
                            Caption = ' ';
                            Visible = ChoseUpdVisible and UpdPayMethVisible;
                            group("Para2.1.6.1")
                            {
                                Caption = 'Setup basic paymentmethods for AMC Banking to current version of your system.';
                                Visible = ChoseUpdVisible and UpdPayMethVisible;
                                field(UpdPayMeth; UpdPayMethBoolean)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Caption = 'Setup basic paymentmethods';
                                    ToolTip = 'Setup basic paymentmethods for AMC Banking to current version of your system.';

                                    trigger OnValidate();
                                    begin
                                        EnableNextStep();
                                    end;
                                }
                            }
                        }
                        group("Para2.1.7")
                        {
                            Caption = ' ';
                            Visible = ChoseUpdVisible and UpdBankClearStdVisible;
                            group("Para2.1.7.1")
                            {
                                Caption = 'Setup Bank Clearing Standards to be used on vendors bank accounts.';
                                Visible = ChoseUpdVisible and UpdBankClearStdVisible;
                                field(UpdBankClearStd; UpdBankClearStdBoolean)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Caption = 'Setup Bank Clearing Standards';
                                    ToolTip = 'Setup Bank Clearing Standards to be used on vendors bank accounts.';

                                    trigger OnValidate();
                                    begin
                                        EnableNextStep();
                                    end;
                                }
                            }
                        }

                        group("Para2.1.8")
                        {
                            Caption = ' ';
                            Visible = ChoseUpdVisible;
                            group("Para2.1.8.1")
                            {
                                Caption = 'Setup own Bank Account with DataExchangeDef. and Credit Msg. No.';
                                Visible = ChoseUpdVisible;
                                field(UpdBankAccounts; UpdBankAccountsBoolean)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Caption = 'Setup Bank Accounts';
                                    ToolTip = 'Setup own Bank Account with DataExchangeDef. and Credit Msg. No.';

                                    trigger OnValidate();
                                    begin
                                        EnableNextStep();
                                    end;
                                }
                            }
                        }
                    }
                }
            }
            group(UpdateURLS)
            {
                Caption = ' ';
                Visible = URLVisible;
                group("UpdateURLS1.1")
                {
                    Caption = 'Set URLs to Default';
                    Visible = URLVisible;
                    group("UpdateURLS1.1.1")
                    {
                        Caption = ' ';
                        Visible = URLVisible;
                        group("UpdateURLS1.2.1")
                        {
                            Caption = ' ';
                            Visible = URLVisible;
                            field(SignupURL; SignupURLText)
                            {
                                ApplicationArea = Basic, Suite;
                                Caption = 'Sign-up URL';
                                ExtendedDatatype = URL;
                                ToolTip = 'Specifies the sign-up page for the service that converts bank data to the format required by your bank when you export payment bank files and import bank statement files. This is the web page where you enter your company''s user name and password to sign up for the service.';

                                trigger OnValidate();
                                begin
                                    URLSChanged := true;
                                end;
                            }
                            field(ServiceURL; ServiceURLText)
                            {
                                ApplicationArea = Basic, Suite;
                                Caption = 'Service URL';
                                ToolTip = 'Specifies the address of the service that converts bank data to the format required by your bank when you export payment bank files and import bank statement files. The service specified in the Service URL field is called when users export or import bank files.';

                                trigger OnValidate();
                                begin
                                    URLSChanged := true;
                                end;
                            }
                            field(SupportURL; SupportURLText)
                            {
                                ApplicationArea = Basic, Suite;
                                Caption = 'Support URL';
                                ExtendedDatatype = URL;
                                ToolTip = 'Specifies the web site where the provider of the AMC Banking publishes status and support information about the service.';

                                trigger OnValidate();
                                begin
                                    URLSChanged := true;
                                end;
                            }
                        }
                    }
                }
            }
            group(UpdateBanks)
            {
                Caption = ' ';
                Visible = BankVisible;
                group("UpdateBanks1.1")
                {
                    Caption = 'Update Bank Name List';
                    Visible = BankVisible;
                    group("UpdateBanks1.2")
                    {
                        Caption = ' ';
                        InstructionalText = ' ';
                        Visible = BankVisible;
                        group(Control85)
                        {
                            Caption = 'Update the list of banks in your country/region that you can use to import or export bank account data using the AMC Banking.';
                            Visible = BankVisible;
                        }
                        group(Control29)
                        {
                            Caption = ' ';
                            InstructionalText = 'The Bank Name List shows a list of bank names representing bank data formats that are supported by the AMC Banking.';
                            Visible = BankVisible;
                        }
                        group(Control6)
                        {
                            Caption = ' ';
                            InstructionalText = ' ';
                            Visible = BankVisible;
                        }
                        group(Control82)
                        {
                            Caption = ' ';
                            InstructionalText = 'The list of bank data formats that are supported by the AMC Banking will be updated.';
                            Visible = BankVisible;
                        }
                        group(Control81)
                        {
                            Caption = ' ';
                            InstructionalText = ' ';
                            Visible = BankVisible;
                        }
                        group(Control84)
                        {
                            Caption = ' ';
                            InstructionalText = 'This list of bank names, filtered by the country/region, can be selected in the Bank Name Format field in the Bank Account Card page.';
                            Visible = BankVisible;
                        }
                        group(Control83)
                        {
                            Caption = ' ';
                            InstructionalText = ' ';
                            Visible = BankVisible;
                        }
                    }
                }
            }
            group(UpdateDataExchDef)
            {
                Caption = 'Setup Data Exchange Definitions';
                Visible = DataExchDefVisible;
            }
            group("Para3.1")
            {
                Caption = ' ';
                Visible = DataExchDefVisible;
                group("Para3.1.1")
                {
                    Caption = 'Please chose Data Exchange Definitions to setup:';
                    Visible = DataExchDefVisible;
                    group("Para3.1.2")
                    {
                        Caption = ' ';
                        Visible = DataExchDefVisible;
                        group("Para3.1.3")
                        {
                            Caption = ' ';
                            Visible = DataExchDefVisible;
                            group("Para3.1.3.1")
                            {
                                Caption = 'Applicationversion and buildnumber to get Data Exchange Definition for:';
                                Visible = DataExchDefVisible;
                                field(ApplVer; ApplVerText)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Caption = 'Applicationversion';
                                }
                                field(BuildNo; BuildNoText)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Caption = 'Buildnumber';
                                }
                            }
                        }
                        group("Para3.1.4")
                        {
                            Caption = ' ';
                            Visible = DataExchDefVisible;
                            group("Para3.1.4.1")
                            {
                                Caption = 'Setup AMC Banking - Credit Transfer, to be able to make outgoing payments';
                                Visible = DataExchDefVisible;
                                field(BANKDATACONVSERVCT; BANKDATACONVSERVCTBoolean)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Caption = 'AMC Banking - Credit Transfer';
                                    ToolTip = 'Setup AMC Banking - Credit Transfer, to be able to make outgoing payments';

                                    trigger OnValidate();
                                    begin
                                        EnableNextStep();
                                    end;
                                }
                            }
                        }
                        group("Para3.1.5")
                        {
                            Caption = ' ';
                            Visible = BankDataConvServPPVisible;
                            group("Para3.1.5.1")
                            {
                                Caption = 'Setup AMC Banking - Positive Pay, to be able to make Positive Pay file for printed checks.';
                                Visible = BankDataConvServPPVisible;
                                field(BANKDATACONVSERVPP; BANKDATACONVSERVPPBoolean)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Caption = 'AMC Banking - Positive Pay';
                                    ToolTip = 'Setup AMC Banking - Positive Pay, to be able to make Positive Pay file for printed checks.';

                                    trigger OnValidate();
                                    begin
                                        EnableNextStep();
                                    end;
                                }
                            }
                        }
                        group("Para3.1.6")
                        {
                            Caption = ' ';
                            Visible = DataExchDefVisible;
                            group("Para3.1.6.1")
                            {
                                Caption = 'Setup AMC Banking - Bank Statement, to be able to import Bank statements from your banks.';
                                Visible = DataExchDefVisible;
                                field(BANKDATACONVSERVSTMT; BANKDATACONVSERVSTMTBoolean)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Caption = 'AMC Banking - Bank Statement';
                                    ToolTip = 'Setup AMC Banking - Bank Statement, to be able to import Bank statements from your banks.';

                                    trigger OnValidate();
                                    begin
                                        EnableNextStep();
                                    end;
                                }
                            }
                        }
                        group("Para3.1.7")
                        {
                            Caption = ' ';
                            Visible = BankDataConvServCREMVisible;
                            group("Para3.1.7.1")
                            {
                                Caption = 'Setup AMC Banking - Credit Advice, to be able to import Customer payments from your banks.';
                                Visible = BankDataConvServCREMVisible;
                                field(BANKDATACONVSERVCREM; BANKDATACONVSERVCREMBoolean)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Caption = 'AMC Banking - Credit Advice';
                                    ToolTip = 'Setup AMC Banking - Credit Advice, to be able to import Customer payments from your banks.';

                                    trigger OnValidate();
                                    begin
                                        EnableNextStep();
                                    end;
                                }
                            }
                        }
                    }
                }
            }
            group(UpdatePayMeth)
            {
                Caption = 'Setup basic paymentmethods';
                Visible = PayMethVisible;
            }
            group("Para4.1")
            {
                Caption = ' ';
                Visible = PayMethVisible;
                group("Para4.1.1")
                {
                    Caption = 'Please choose Contrycode for Paymentmethods to setup:';
                    Visible = PayMethVisible;
                    group("Para4.1.2")
                    {
                        Caption = ' ';
                        Visible = PayMethVisible;
                        group("Para4.1.3")
                        {
                            Caption = ' ';
                            Visible = PayMethVisible;
                            group("Para4.1.3.1")
                            {
                                Caption = 'Setup paymentmethods for the selected countrycode.';
                                Visible = PayMethVisible;
                                field(CountryCode; CountryCodeCode)
                                {
                                    ApplicationArea = Basic, Suite;
                                    Caption = 'Countrycode';
                                    TableRelation = "Country/Region".Code;
                                    ToolTip = 'Setup paymentmethods for the selected countrycode.';
                                }
                            }
                        }
                    }
                }
            }
            group(UpdateBankClearStd)
            {
                Visible = BankClearStdVisible;
                group("UpdateBankClearStd1.1")
                {
                    Caption = 'Setup Bank Clearing Standards to be used on vendors bank accounts.';
                    Visible = BankClearStdVisible;
                    group("UpdateBankClearStd1.2")
                    {
                        Caption = ' ';
                        InstructionalText = ' ';
                        Visible = BankClearStdVisible;
                        group(Control32)
                        {
                            Caption = ' ';
                            InstructionalText = 'Specifies the format standard to be used in bank transfers if you use the Bank Clearing Code field to identify you as the sender.';
                            Visible = BankClearStdVisible;
                        }
                        group(Control95)
                        {
                            Caption = ' ';
                            InstructionalText = ' ';
                            Visible = BankClearStdVisible;
                        }
                        group(Control94)
                        {
                            Caption = ' ';
                            InstructionalText = 'This list of Bank Clearing Standards, can be selected in the Bank Clearing Standard field in the Vendor Bank Account Card page.';
                            Visible = BankClearStdVisible;
                        }
                        group(Control93)
                        {
                            Caption = ' ';
                            InstructionalText = ' ';
                            Visible = BankClearStdVisible;
                        }
                    }
                }
            }
            group(UpdateBankAccounts)
            {
                Visible = BankAccountVisible;
                group("UpdateBankAccounts1.1")
                {
                    Caption = 'Setup own Bank accounts';
                    Visible = BankAccountVisible;
                    group("UpdateBankAccounts1.2")
                    {
                        Caption = ' ';
                        InstructionalText = ' ';
                        Visible = BankAccountVisible;
                        group("UpdateBankAccounts1.2.1")
                        {
                            Caption = ' ';
                            InstructionalText = 'Own Bank accounts are setup to use Data Exchange Def. for AMC Banking';
                            Visible = BankAccountVisible;
                        }
                        group("UpdateBankAccounts1.2.2")
                        {
                            Caption = ' ';
                            InstructionalText = ' ';
                            Visible = BankAccountVisible;
                        }
                        group("UpdateBankAccounts1.2.3")
                        {
                            Caption = ' ';
                            InstructionalText = 'Own Bank accounts are setup to use Credit Msg. No. for AMC Banking';
                            Visible = BankAccountVisible;
                        }
                        group("UpdateBankAccounts1.2.4")
                        {
                            Caption = ' ';
                            InstructionalText = ' ';
                            Visible = BankAccountVisible;
                        }
                    }
                }
            }
            group("UpdateDone1.1")
            {
                Visible = DoneVisible;
                group("UpdateDone1.1.1")
                {
                    Caption = ' ';
                    Visible = DoneVisible;
                    group("UpdateDone1.1.2")
                    {
                        Caption = ' ';
                        Visible = DoneVisible;
                        group("UpdateDone1.1.3")
                        {
                            Caption = 'Setup is done!';
                            InstructionalText = 'You can start using the AMC Banking now.';
                            Visible = DoneVisible;
                        }
                    }
                }
            }
            group("UpdateError1.1")
            {
                Visible = ErrorVisible;
                group("UpdateError1.1.1")
                {
                    Caption = ' ';
                    Visible = ErrorVisible;
                    group("UpdateError1.1.2")
                    {
                        Caption = ' ';
                        Visible = ErrorVisible;
                        group("UpdateError1.1.3")
                        {
                            Caption = 'An error occurred during setup!';
                            InstructionalText = 'Please look into the activity log in AMC Banking setup and correct the errors, then run the assisted setup again';
                            Visible = ErrorVisible;
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Back)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Back';
                Enabled = BackEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                ShortCutKey = 'Ctrl+B';

                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }
            action(Next)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Next';
                Enabled = NextEnabled;
                Image = NextRecord;
                InFooterBar = true;
                ShortCutKey = 'Ctrl+N';

                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }
            action("Start update")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Start update';
                Enabled = StartEnabled;
                Image = Approve;
                InFooterBar = true;
                ShortCutKey = 'Ctrl+S';

                trigger OnAction();
                var
                begin
                    RunUpdates();
                    if (BasisSetupRanOK) then begin
                        Step := Step::Done;
                        ShowDoneStep();
                    end
                    else
                        ShowErrorStep();
                end;
            }
        }
    }

    trigger OnInit();
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage();
    begin
        AMCBankAssistedMgt.OnOpenAssistedSetupPage(BankDataConvServPPVisible, BankDataConvServCREMVisible, UpdPayMethVisible, UpdBankClearStdVisible);
        ShowIntroStep();
    end;

    var
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResourcesStandardRecord: Record "Media Resources";
        MediaResourcesDoneRecord: Record "Media Resources";
        AMCBankAssistedMgt: Codeunit "AMC Bank Assisted Mgt.";
        ClientTypeManagement: Codeunit "Client Type Management";
        BankDataConvServMgt: Codeunit "AMC Banking Mgt.";
        Step: Option Intro,"Chose updates","Update URLs","Update Banks","Update Data Exch. Def.","Update PayMethods","Update Bank Clear Std","Update Bank Accounts",Done;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        StartEnabled: Boolean;
        TopBannerVisible: Boolean;
        DoneVisible: Boolean;
        ErrorVisible: Boolean;
        IntroVisible: Boolean;
        ChoseUpdVisible: Boolean;
        URLVisible: Boolean;
        BankVisible: Boolean;
        DataExchDefVisible: Boolean;
        PayMethVisible: Boolean;
        BankClearStdVisible: Boolean;
        BankAccountVisible: Boolean;
        UpdALL: Boolean;
        UpdURLBoolean: Boolean;
        UpdBankBoolean: Boolean;
        UpdDataExchDefBoolean: Boolean;
        UpdPayMethBoolean: Boolean;
        UpdBankClearStdBoolean: Boolean;
        UpdBankAccountsBoolean: Boolean;
        Para12Visible: Boolean;
        CountryCodeCode: Code[10];
        BANKDATACONVSERVSTMTBoolean: Boolean;
        BANKDATACONVSERVPPBoolean: Boolean;
        BankDataConvServPPVisible: Boolean;
        BANKDATACONVSERVCTBoolean: Boolean;
        BANKDATACONVSERVCREMBoolean: Boolean;
        BankDataConvServCREMVisible: Boolean;
        UpdPayMethVisible: Boolean;
        UpdBankClearStdVisible: Boolean;
        ConsentAccepted: Boolean;
        ApplVerText: Text;
        BuildNoText: Text;

        URLSChanged: Boolean;
        SignupURLText: Text[250];
        ServiceURLText: Text[250];
        SupportURLText: Text[250];

        BasisSetupRanOK: Boolean;

    local procedure LoadTopBanners();
    begin
        if MediaRepositoryStandard.GET('AssistedSetup-NoText-400px.png', FORMAT(ClientTypeManagement.GetCurrentClientType())) and
           MediaRepositoryDone.GET('AssistedSetupDone-NoText-400px.png', FORMAT(ClientTypeManagement.GetCurrentClientType()))
        then
            if MediaResourcesStandardRecord.GET(MediaRepositoryStandard."Media Resources Ref") and
               MediaResourcesDoneRecord.GET(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDoneRecord."Media Reference".HASVALUE();
    end;

    local procedure SetDefaultValues();
    var
        CompanyInformation: Record "Company Information";
    begin
        // Buttons
        if (UpdALL) then
            NextEnabled := false
        else
            NextEnabled := true;

        StartEnabled := UpdALL;

        if (UpdALL) then
            Para12Visible := false
        else
            Para12Visible := true;

        UpdURLBoolean := UpdALL;
        UpdBankBoolean := UpdALL;
        UpdDataExchDefBoolean := UpdALL;
        UpdPayMethBoolean := UpdALL;
        UpdBankClearStdBoolean := UpdALL;
        UpdBankAccountsBoolean := UpdALL;

        BANKDATACONVSERVCTBoolean := UpdALL;
        if (BankDataConvServPPVisible) then
            BANKDATACONVSERVPPBoolean := UpdALL
        else
            BANKDATACONVSERVPPBoolean := BankDataConvServPPVisible;

        BANKDATACONVSERVSTMTBoolean := UpdALL;
        if (BankDataConvServCREMVisible) then
            BANKDATACONVSERVCREMBoolean := UpdALL
        else
            BANKDATACONVSERVCREMBoolean := BankDataConvServCREMVisible;

        CompanyInformation.GET();
        CountryCodeCode := CompanyInformation."Country/Region Code";

        ApplVerText := AMCBankAssistedMgt.GetApplVersion();
        BuildNoText := AMCBankAssistedMgt.GetBuildNumber();

        URLSChanged := false;
    end;

    local procedure ResetWizardControls();
    begin
        // Buttons
        BackEnabled := true;
        NextEnabled := true;
        StartEnabled := false;

        // Tabs
        IntroVisible := false;
        ChoseUpdVisible := false;
        URLVisible := false;
        BankVisible := false;
        DataExchDefVisible := false;
        PayMethVisible := false;
        BankClearStdVisible := false;
        BankAccountVisible := false;
        DoneVisible := false;
        ErrorVisible := false;
    end;

    local procedure NextStep(Backwards: Boolean);
    begin
        if (Step = Step::Intro) then begin
            if not Backwards then
                ShowChose();
        end
        else
            if (Step = Step::"Chose updates") then begin
                if Backwards then
                    ShowIntroStep()
                else
                    if (UpdURLBoolean) then
                        ShowURL()
                    else
                        if (UpdBankBoolean) then
                            ShowBanks()
                        else
                            if (UpdDataExchDefBoolean) then
                                ShowDataExchDef()
                            else
                                if (UpdPayMethBoolean) then
                                    ShowPayMeth()
                                else
                                    if (UpdBankClearStdBoolean) then
                                        ShowBankClearStd()
                                    else
                                        if (UpdBankAccountsBoolean) then
                                            ShowBankAccounts();
            end
            else
                if (Step = Step::"Update URLs") then begin
                    if Backwards then
                        ShowChose()
                    else
                        if (UpdBankBoolean) then
                            ShowBanks()
                        else
                            if (UpdDataExchDefBoolean) then
                                ShowDataExchDef()
                            else
                                if (UpdPayMethBoolean) then
                                    ShowPayMeth()
                                else
                                    if (UpdBankClearStdBoolean) then
                                        ShowBankClearStd()
                                    else
                                        if (UpdBankAccountsBoolean) then
                                            ShowBankAccounts();
                end
                else
                    if (Step = Step::"Update Banks") then begin
                        if Backwards then begin
                            if (UpdURLBoolean) then
                                ShowURL()
                            else
                                ShowChose();
                        end
                        else
                            if (UpdDataExchDefBoolean) then
                                ShowDataExchDef()
                            else
                                if (UpdPayMethBoolean) then
                                    ShowPayMeth()
                                else
                                    if (UpdBankClearStdBoolean) then
                                        ShowBankClearStd()
                                    else
                                        if (UpdBankAccountsBoolean) then
                                            ShowBankAccounts();
                    end
                    else
                        if (Step = Step::"Update Data Exch. Def.") then begin
                            if Backwards then begin
                                if (UpdBankBoolean) then
                                    ShowBanks()
                                else
                                    if (UpdURLBoolean) then
                                        ShowURL()
                                    else
                                        ShowChose();
                            end
                            else
                                if (UpdPayMethBoolean) then
                                    ShowPayMeth()
                                else
                                    if (UpdBankClearStdBoolean) then
                                        ShowBankClearStd()
                                    else
                                        if (UpdBankAccountsBoolean) then
                                            ShowBankAccounts();
                        end
                        else
                            if (Step = Step::"Update PayMethods") then begin
                                if Backwards then begin
                                    if (UpdDataExchDefBoolean) then
                                        ShowDataExchDef()
                                    else
                                        if (UpdBankBoolean) then
                                            ShowBanks()
                                        else
                                            if (UpdURLBoolean) then
                                                ShowURL()
                                            else
                                                ShowChose();
                                end
                                else
                                    if (UpdBankClearStdBoolean) then
                                        ShowBankClearStd()
                                    else
                                        if (UpdBankAccountsBoolean) then
                                            ShowBankAccounts();

                            end
                            else
                                if (Step = Step::"Update Bank Clear Std") then begin
                                    if Backwards then begin
                                        if (UpdPayMethBoolean) then
                                            ShowPayMeth()
                                        else
                                            if (UpdDataExchDefBoolean) then
                                                ShowDataExchDef()
                                            else
                                                if (UpdBankBoolean) then
                                                    ShowBanks()
                                                else
                                                    if (UpdURLBoolean) then
                                                        ShowURL()
                                                    else
                                                        ShowChose();
                                    end
                                    else
                                        if (UpdBankAccountsBoolean) then
                                            ShowBankAccounts();
                                end
                                else
                                    if (Step = Step::"Update Bank Accounts") then begin
                                        if Backwards then
                                            if (UpdBankClearStdBoolean) then
                                                ShowBankClearStd()
                                            else
                                                if (UpdPayMethBoolean) then
                                                    ShowPayMeth()
                                                else
                                                    if (UpdDataExchDefBoolean) then
                                                        ShowDataExchDef()
                                                    else
                                                        if (UpdBankBoolean) then
                                                            ShowBanks()
                                                        else
                                                            if (UpdURLBoolean) then
                                                                ShowURL()
                                                            else
                                                                ShowChose();
                                    end
                                    else
                                        if (Step = Step::Done) then
                                            ShowDoneStep();

        EnableNextStep();

        CurrPage.UPDATE(true);
    end;

    local procedure EnableNextStep();
    begin
        StartEnabled := false;
        NextEnabled := false;

        case Step of
            Step::Intro:
                if (UpdALL) then
                    StartEnabled := true;
            Step::"Chose updates":
                if (UpdURLBoolean) or (UpdBankBoolean) or (UpdDataExchDefBoolean) or (UpdPayMethBoolean) or (UpdBankClearStdBoolean) or (UpdBankAccountsBoolean) then
                    NextEnabled := true;
            Step::"Update URLs":
                if (UpdURLBoolean) and (not UpdBankBoolean) and (not UpdDataExchDefBoolean) and (not UpdPayMethBoolean) and (not UpdBankClearStdBoolean) and (not UpdBankAccountsBoolean) then
                    StartEnabled := true
                else
                    NextEnabled := true;
            Step::"Update Banks":
                if (UpdBankBoolean) and (not UpdDataExchDefBoolean) and (not UpdPayMethBoolean) and (not UpdBankClearStdBoolean) and (not UpdBankAccountsBoolean) then
                    StartEnabled := true
                else
                    NextEnabled := true;
            Step::"Update Data Exch. Def.":
                if (UpdDataExchDefBoolean) and (not UpdPayMethBoolean) and (not UpdBankClearStdBoolean) and (not UpdBankAccountsBoolean) then begin
                    if ((BANKDATACONVSERVCTBoolean) or (BANKDATACONVSERVPPBoolean)
                    or (BANKDATACONVSERVSTMTBoolean) or (BANKDATACONVSERVCREMBoolean)) then
                        StartEnabled := true
                    else
                        StartEnabled := false;
                end
                else
                    if ((BANKDATACONVSERVCTBoolean) or (BANKDATACONVSERVPPBoolean)
                    or (BANKDATACONVSERVSTMTBoolean) or (BANKDATACONVSERVCREMBoolean)) then
                        NextEnabled := true
                    else
                        NextEnabled := false;
            Step::"Update PayMethods":
                if (UpdPayMethBoolean) and (not UpdBankClearStdBoolean) and (not UpdBankAccountsBoolean) then
                    StartEnabled := true
                else
                    NextEnabled := true;
            Step::"Update Bank Clear Std":
                if (UpdBankClearStdBoolean) and (not UpdBankAccountsBoolean) then
                    StartEnabled := true
                else
                    NextEnabled := true;
            Step::"Update Bank Accounts":
                StartEnabled := true
        end;
    end;

    local procedure ShowIntroStep();
    begin
        ResetWizardControls();
        IntroVisible := true;
        UpdALL := true;
        BackEnabled := false;
        SetDefaultValues();
        Step := Step::Intro;
        StartEnabled := ConsentAccepted;
    end;

    local procedure ShowChose();
    begin
        ResetWizardControls();
        NextEnabled := true;
        ChoseUpdVisible := true;
        Step := Step::"Chose updates";
    end;

    local procedure ShowURL();
    var
        AMCBankServiceSetup: Record "AMC Banking Setup" temporary;
    begin
        ResetWizardControls();
        Step := Step::"Update URLs";
        URLVisible := true;
        if (URLSChanged = false) then begin
            BankDataConvServMgt.InitDefaultURLs(AMCBankServiceSetup);
            SignupURLText := LowerCase(AMCBankServiceSetup."Sign-up URL");
            ServiceURLText := AMCBankServiceSetup."Service URL";
            SupportURLText := AMCBankServiceSetup."Support URL";
        end;
    end;

    local procedure ShowBanks();
    begin
        ResetWizardControls();
        Step := Step::"Update Banks";
        BankVisible := true;
    end;

    local procedure ShowDataExchDef();
    begin
        ResetWizardControls();
        Step := Step::"Update Data Exch. Def.";
        DataExchDefVisible := true;
    end;

    local procedure ShowPayMeth();
    begin
        ResetWizardControls();
        Step := Step::"Update PayMethods";
        PayMethVisible := true;
    end;

    local procedure ShowBankClearStd();
    begin
        ResetWizardControls();
        Step := Step::"Update Bank Clear Std";
        BankClearStdVisible := true;
    end;

    local procedure ShowBankAccounts();
    begin
        ResetWizardControls();
        Step := Step::"Update Bank Accounts";
        BankAccountVisible := true;
    end;

    local procedure ShowDoneStep();
    begin
        ResetWizardControls();
        DoneVisible := true;
        BackEnabled := false;
        NextEnabled := false;
        StartEnabled := false;
        Step := Step::Done;
    end;

    local procedure ShowErrorStep();
    begin
        ResetWizardControls();
        ErrorVisible := true;
        DoneVisible := false;
        BackEnabled := false;
        NextEnabled := false;
        StartEnabled := false;
    end;

    local procedure CheckPath(Var Path: Text)
    begin
        IF (COPYSTR(Path, STRLEN(Path), 1) <> '\') THEN
            Path := Path + '\';
    end;

    local procedure RunUpdates();
    var
        CallLicenseServer: Boolean;
    begin
        CallLicenseServer := true;
        BasisSetupRanOK := AMCBankAssistedMgt.RunBasisSetup(UpdURLBoolean, URLSChanged, SignupURLText, ServiceURLText, SupportURLText, UpdBankBoolean, UpdPayMethBoolean, CountryCodeCode,
                                                        UpdDataExchDefBoolean, BANKDATACONVSERVCTBoolean, BANKDATACONVSERVPPBoolean, BANKDATACONVSERVSTMTBoolean, BANKDATACONVSERVCREMBoolean, ApplVerText, BuildNoText,
                                                        UpdBankClearStdBoolean, UpdBankAccountsBoolean, CallLicenseServer);

        AMCBankAssistedMgt.OnAfterRunBasisSetup(UpdURLBoolean, URLSChanged, SignupURLText, ServiceURLText, SupportURLText, UpdBankBoolean, UpdPayMethBoolean, CountryCodeCode,
                                                   UpdDataExchDefBoolean, BANKDATACONVSERVCTBoolean, BANKDATACONVSERVPPBoolean, BANKDATACONVSERVSTMTBoolean, BANKDATACONVSERVCREMBoolean, ApplVerText, BuildNoText,
                                                   UpdBankClearStdBoolean, UpdBankAccountsBoolean, CallLicenseServer);
    end;

}
