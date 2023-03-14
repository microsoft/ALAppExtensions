page 20105 "AMC Bank Assisted Setup"
{
    Caption = 'AMC Banking 365 Fundamentals Assisted Setup';
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
                field(MediaResourcesStandard; StandardRecordMediaResources."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = ' ';
                }
            }
            group(Control17)
            {
                Caption = ' ';
                Editable = false;
                Visible = TopBannerVisible AND DoneVisible;
                field(MediaResourcesDone; DoneRecordMediaResources."Media Reference")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ShowCaption = false;
                    ToolTip = ' ';
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
                        InstructionalText = 'The AMC Banking 365 Fundamentals extension saves you time and reduces errors when you send data to your bank. The extension uses the AMC Banking 365 Business service to transform data from Microsoft Dynamics 365 Business Central into formats that banks require. You specify the bank, and the extension does the rest. For more information, see the documentation.';
                    }
                    field(AMCBankingHelpLink; 'AMC Banking 365 Fundamentals documentation')
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;
                        ToolTip = 'AMC Banking 365 Fundamentals documentation';

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
                        ToolTip = 'By enabling this extension you consent to sharing your data with an external system. Your use of this extension may be subject to additional licensing terms from AMC. To enable the service you must read and accept the terms of use.';
                    }
                    field(TermsOfUseLink; 'AMC Banking 365 Fundamentals terms of use')
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;
                        ToolTip = 'AMC Banking 365 Fundamentals terms of use';

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
                        ToolTip = 'I understand and accept these terms';
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
            group(Step2)
            {
                Caption = '  ';
                Visible = ChoseUpdVisible;
                group("Para2.1")
                {
                    Caption = 'Please choose what to setup:';

                    field(URLContent; 'Change the Service, Support and Sign-up URLs to their default values.')
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;
                        ToolTip = 'Change the Service, Support and Sign-up URLs to their default values.';
                    }
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
                    field(BankListContent; 'Update the list of banks in your country/region that you can use to import or export bank account data using the AMC Banking.')
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;
                        ToolTip = 'Update the list of banks in your country/region that you can use to import or export bank account data using the AMC Banking.';
                    }
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
                    field(DataExchContent; 'Setup Data Exchange Definitions to current version of your system for AMC Banking.')
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;
                        ToolTip = 'Setup Data Exchange Definitions to current version of your system for AMC Banking.';
                    }
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
                    field(OwnBankContent; 'Setup own Bank Account with DataExchangeDef. and Credit Msg. No.')
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;
                        ToolTip = 'Setup own Bank Account with DataExchangeDef. and Credit Msg. No.';
                    }
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
                    group(UpdPayMethGrp)
                    {
                        Caption = '  ';
                        InstructionalText = 'Setup basic paymentmethods for AMC Banking to current version of your system.';
                        Visible = UpdPayMethVisible;

                        field(UpdPayMethFld; UpdPayMethBoolean)
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
                    group(UpdBankClearGrp)
                    {
                        Caption = '  ';
                        InstructionalText = 'Setup Bank Clearing Standards to be used on vendors bank accounts';
                        Visible = UpdBankClearStdVisible;

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
                                    if SignupURLText <> '' then
                                        WebRequestHelper.IsSecureHttpUrl(SignupURLText);

                                    URLSChanged := true;
                                end;

                                trigger OnDrillDown()
                                begin
                                    Hyperlink(SignupURLText);
                                end;
                            }
                            field(ServiceURL; ServiceURLText)
                            {
                                ApplicationArea = Basic, Suite;
                                Caption = 'Service URL';
                                ExtendedDatatype = URL;
                                ToolTip = 'Specifies the address of the service that converts bank data to the format required by your bank when you export payment bank files and import bank statement files. The service specified in the Service URL field is called when users export or import bank files.';

                                trigger OnValidate();
                                begin
                                    if ServiceURLText <> '' then
                                        WebRequestHelper.IsSecureHttpUrl(ServiceURLText);

                                    URLSChanged := true;
                                end;

                                trigger OnDrillDown()
                                begin
                                    Hyperlink(CopyStr(ServiceURLText, 1, StrLen(ServiceURLText) - StrLen("Namespace API Version")));
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
                                    if SupportURLText <> '' then
                                        WebRequestHelper.IsSecureHttpUrl(SupportURLText);

                                    URLSChanged := true;
                                end;

                                trigger OnDrillDown()
                                begin
                                    Hyperlink(SupportURLText);
                                end;
                            }
                        }
                    }
                }
            }
            group(UpdateBanks)
            {
                Caption = '  ';
                Visible = BankVisible;
                group("UpdateBanks1.1")
                {
                    Caption = 'Update Bank Name List';
                    group("UpdateBanks1.2")
                    {
                        Caption = ' ';
                        InstructionalText = 'Update the list of banks in your country/region that you can use to import or export bank account data using the AMC Banking.';
                    }
                    field(SelctCountryContent; 'Select countrycode to filter banklist.')
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;
                        ToolTip = 'Select countrycode to filter banklist.';
                    }
                    field(BankCountryCodeCodeFld; BankCountryCodeCode)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Countrycode';
                        TableRelation = "Country/Region".Code;
                        ToolTip = 'Only select a countrycode, if you want to filter the banklist for the selected countrycode. Otherwise leave empty';
                    }
                    field(CountryFilterContent; 'Only select a countrycode, if you want to filter the banklist for the selected countrycode, otherwise leave empty')
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;
                        ToolTip = 'Only select a countrycode, if you want to filter the banklist for the selected countrycode, otherwise leave empty';
                    }
                }
            }
            group(UpdateDataExchDef)
            {
                Caption = ' ';
                Visible = DataExchDefVisible;

                group("Para3.1")
                {
                    Caption = 'Setup Data Exchange Definitions';
                    Visible = DataExchDefVisible;
                    field(ApplVerContent; 'Applicationversion and buildnumber to get Data Exchange Definition for:')
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;
                        ToolTip = 'Applicationversion and buildnumber to get Data Exchange Definition for:';
                    }
                    field(ApplVer; ApplVerText)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Applicationversion';
                        ToolTip = 'Applicationversion of your Business Central, used for fetching the correspondent Data Exchange def. from AMC Banking';
                    }
                    field(BuildNo; BuildNoText)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Buildnumber';
                        ToolTip = 'Buildnumber of your Business Central, used for fetching the correspondent Data Exchange def. from AMC Banking';
                    }
                    field(CTContent; 'Setup AMC Banking - Credit Transfer, to be able to make outgoing payments')
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;
                        ToolTip = 'Setup AMC Banking - Credit Transfer, to be able to make outgoing payments';
                    }
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
                    field(StmtContent; 'Setup AMC Banking - Bank Statement, to be able to import Bank statements from your banks.')
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;
                        ToolTip = 'Setup AMC Banking - Bank Statement, to be able to import Bank statements from your banks.';
                    }
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
                    group(Business)
                    {
                        Caption = ' ';
                        Visible = BankDataConvServPPVisible and BankDataConvServCREMVisible;
                        field(PPContent; 'Setup AMC Banking - Positive Pay, to be able to make Positive Pay file for printed checks.')
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                            Editable = false;
                            ToolTip = 'Setup AMC Banking - Positive Pay, to be able to make Positive Pay file for printed checks.';
                        }
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
                        field(CAContent; 'Setup AMC Banking - Credit Advice, to be able to import Customer payments from your banks.')
                        {
                            ApplicationArea = Basic, Suite;
                            ShowCaption = false;
                            Editable = false;
                            ToolTip = 'Setup AMC Banking - Credit Advice, to be able to import Customer payments from your banks.';
                        }
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
            group(UpdateBankAccounts)
            {
                Visible = BankAccountVisible;
                group("UpdateBankAccounts1.1")
                {
                    Caption = 'Setup own Bank accounts';
                    Visible = BankAccountVisible;

                    part(AMCBankAssistBankAccount; "AMC Bank Assist Bank Account")
                    {
                        ApplicationArea = Basic, Suite;
                        Enabled = BankAccountVisible;
                    }

                }
            }
            group(UpdatePayMeth)
            {
                Caption = ' ';
                Visible = PayMethVisible;
                group("Para4.1.1")
                {
                    Caption = 'Setup basic paymentmethods';
                    field(UpdPayMethContent; 'Please choose Contrycode for Paymentmethods to setup:')
                    {
                        ApplicationArea = Basic, Suite;
                        ShowCaption = false;
                        Editable = false;
                        ToolTip = 'Please choose Contrycode for Paymentmethods to setup.';
                    }
                    field(PaymCountryCode; PaymCountryCodeCode)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Countrycode';
                        TableRelation = "Country/Region".Code;
                        ToolTip = 'Setup paymentmethods for the selected countrycode.';
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
                Visible = ButtonVisible;
                Image = PreviousRecord;
                InFooterBar = true;
                ShortCutKey = 'Ctrl+B';
                ToolTip = 'Go back to previous step.';

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
                Visible = ButtonVisible;
                Image = NextRecord;
                InFooterBar = true;
                ShortCutKey = 'Ctrl+N';
                ToolTip = 'Go to next step.';

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
                Visible = ButtonVisible;
                Image = Approve;
                InFooterBar = true;
                ShortCutKey = 'Ctrl+S';
                ToolTip = 'Start update of data.';

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
            action("Finished")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Close';
                Enabled = DoneVisible;
                Visible = not ButtonVisible;
                Image = Close;
                InFooterBar = true;
                ToolTip = 'Click button to close the assisted setup page';

                trigger OnAction();
                var
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnInit();
    var
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        LoadTopBanners();
        if not AMCBankingSetup.Get() then begin
            AMCBankingSetup.Init();
            AMCBankingSetup.Insert(true);
            Commit();
        end;
    end;

    trigger OnOpenPage();
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000ZXC', 'AMC Banking 365 Fundamentals', Enum::"Feature Uptake Status"::Discovered);
        AMCBankAssistedMgt.OnOpenAssistedSetupPage(BankDataConvServPPVisible, BankDataConvServCREMVisible, UpdPayMethVisible, UpdBankClearStdVisible);
        ShowIntroStep();
    end;

    var
        StandardMediaRepository: Record "Media Repository";
        DoneMediaRepository: Record "Media Repository";
        StandardRecordMediaResources: Record "Media Resources";
        DoneRecordMediaResources: Record "Media Resources";
        TempOnlineBankAccLink: Record "Online Bank Acc. Link" temporary;
        AMCBankAssistedMgt: Codeunit "AMC Bank Assisted Mgt.";
        ClientTypeManagement: Codeunit "Client Type Management";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        WebRequestHelper: Codeunit "Web Request Helper";
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
        BankAccountVisible: Boolean;
        UpdALL: Boolean;
        UpdURLBoolean: Boolean;
        UpdBankBoolean: Boolean;
        UpdDataExchDefBoolean: Boolean;
        UpdPayMethBoolean: Boolean;
        UpdBankClearStdBoolean: Boolean;
        UpdBankAccountsBoolean: Boolean;
        BankCountryCodeCode: Code[10];
        PaymCountryCodeCode: Code[10];
        BANKDATACONVSERVSTMTBoolean: Boolean;
        BANKDATACONVSERVPPBoolean: Boolean;
        BANKDATACONVSERVCTBoolean: Boolean;
        BANKDATACONVSERVCREMBoolean: Boolean;
        BankDataConvServPPVisible: Boolean;
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
        ButtonVisible: Boolean;

    local procedure LoadTopBanners();
    begin
        if StandardMediaRepository.GET('AssistedSetup-NoText-400px.png', FORMAT(ClientTypeManagement.GetCurrentClientType())) and
           DoneMediaRepository.GET('AssistedSetupDone-NoText-400px.png', FORMAT(ClientTypeManagement.GetCurrentClientType()))
        then
            if StandardRecordMediaResources.GET(StandardMediaRepository."Media Resources Ref") and
               DoneRecordMediaResources.GET(DoneMediaRepository."Media Resources Ref")
            then
                TopBannerVisible := DoneRecordMediaResources."Media Reference".HASVALUE();
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
        PaymCountryCodeCode := CompanyInformation."Country/Region Code";

        ApplVerText := AMCBankAssistedMgt.GetApplVersion();
        BuildNoText := AMCBankAssistedMgt.GetBuildNumber();

        URLSChanged := false;

        if (TempOnlineBankAccLink.FindSet()) then
            TempOnlineBankAccLink.DeleteAll();

        CurrPage.AMCBankAssistBankAccount.Page.ClearRecs();
    end;

    local procedure ResetWizardControls();
    begin
        // Buttons
        BackEnabled := true;
        NextEnabled := true;
        StartEnabled := false;
        ButtonVisible := true;

        // Tabs
        IntroVisible := false;
        ChoseUpdVisible := false;
        URLVisible := false;
        BankVisible := false;
        DataExchDefVisible := false;
        PayMethVisible := false;
        BankAccountVisible := false;
        DoneVisible := false;
        ErrorVisible := false;

        //Get TempOnlineBankAccLink from page AMCBankAssistBankAccount, if setup
        if Step = Step::Done then
            CurrPage.AMCBankAssistBankAccount.Page.ClearRecs()
        else
            CurrPage.AMCBankAssistBankAccount.Page.GetRecs(TempOnlineBankAccLink);
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
                                if (UpdBankAccountsBoolean) then
                                    ShowBankAccounts()
                                else
                                    if (UpdPayMethBoolean) then
                                        ShowPayMeth()
                                    else
                                        if (UpdBankClearStdBoolean) then
                                            ShowBankClearStd();
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
                                if (UpdBankAccountsBoolean) then
                                    ShowBankAccounts()
                                else
                                    if (UpdPayMethBoolean) then
                                        ShowPayMeth()
                                    else
                                        if (UpdBankClearStdBoolean) then
                                            ShowBankClearStd();
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
                                if (UpdBankAccountsBoolean) then
                                    ShowBankAccounts()
                                else
                                    if (UpdPayMethBoolean) then
                                        ShowPayMeth()
                                    else
                                        if (UpdBankClearStdBoolean) then
                                            ShowBankClearStd();
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
                                if (UpdBankAccountsBoolean) then
                                    ShowBankAccounts()
                                else
                                    if (UpdPayMethBoolean) then
                                        ShowPayMeth()
                                    else
                                        if (UpdBankClearStdBoolean) then
                                            ShowBankClearStd();
                        end
                        else
                            if (Step = Step::"Update Bank Accounts") then begin
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
                                    if (UpdPayMethBoolean) then
                                        ShowPayMeth()
                                    else
                                        if (UpdBankClearStdBoolean) then
                                            ShowBankClearStd();
                            end
                            else
                                if (Step = Step::"Update PayMethods") then begin
                                    if Backwards then begin
                                        if (UpdBankAccountsBoolean) then
                                            ShowBankAccounts()
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
                                                        ShowChose()
                                    end
                                    else
                                        if (UpdBankClearStdBoolean) then
                                            ShowBankClearStd();
                                end
                                else
                                    if (Step = Step::"Update Bank Clear Std") then
                                        if Backwards then begin
                                            if (UpdPayMethBoolean) then
                                                ShowPayMeth()
                                            else
                                                if (UpdBankAccountsBoolean) then
                                                    ShowBankAccounts()
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
                if (UpdURLBoolean) or (UpdBankBoolean) or (UpdDataExchDefBoolean) or (UpdBankAccountsBoolean) or (UpdPayMethBoolean) or (UpdBankClearStdBoolean) then
                    if (not UpdURLBoolean) and (not UpdBankBoolean) and (not UpdDataExchDefBoolean) and (not UpdBankAccountsBoolean) and (not UpdPayMethBoolean) and (UpdBankClearStdBoolean) then
                        StartEnabled := true
                    else
                        NextEnabled := true;
            Step::"Update URLs":
                if (UpdURLBoolean) and (not UpdBankBoolean) and (not UpdDataExchDefBoolean) and (not UpdBankAccountsBoolean) and (not UpdPayMethBoolean) then
                    StartEnabled := true
                else
                    NextEnabled := true;
            Step::"Update Banks":
                if (UpdBankBoolean) and (not UpdDataExchDefBoolean) and (not UpdBankAccountsBoolean) and (not UpdPayMethBoolean) then
                    StartEnabled := true
                else
                    NextEnabled := true;
            Step::"Update Data Exch. Def.":
                if (UpdDataExchDefBoolean) and (not UpdBankAccountsBoolean) and (not UpdPayMethBoolean) then begin
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
            Step::"Update Bank Accounts":
                if (UpdBankAccountsBoolean) and (not UpdPayMethBoolean) then
                    StartEnabled := true
                else
                    NextEnabled := true;
            Step::"Update PayMethods":
                if (UpdPayMethBoolean) then
                    StartEnabled := true;
            Step::"Update Bank Clear Std":
                StartEnabled := true;
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
        CollectBankAccounts();
        NextEnabled := true;
        ChoseUpdVisible := true;
        Step := Step::"Chose updates";
    end;

    local procedure ShowURL();
    var
        TempAMCBankServiceSetup: Record "AMC Banking Setup" temporary;
    begin
        ResetWizardControls();
        Step := Step::"Update URLs";
        URLVisible := true;
        if (URLSChanged = false) then begin
            AMCBankingMgt.InitDefaultURLs(TempAMCBankServiceSetup);
            SignupURLText := LowerCase(TempAMCBankServiceSetup."Sign-up URL");
            ServiceURLText := TempAMCBankServiceSetup."Service URL";
            SupportURLText := TempAMCBankServiceSetup."Support URL";
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

    local procedure ShowBankAccounts();
    begin
        ResetWizardControls();
        Step := Step::"Update Bank Accounts";
        if TempOnlineBankAccLink.FindFirst() then
            if not TempOnlineBankAccLink.IsEmpty() then
                CurrPage.AMCBankAssistBankAccount.PAGE.SetRecs(TempOnlineBankAccLink);

        BankAccountVisible := true;
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
    end;

    local procedure ShowDoneStep();
    begin
        ResetWizardControls();
        ButtonVisible := false;
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

    local procedure CollectBankAccounts()
    var
        BankAccount: Record "Bank Account";
    begin
        TempOnlineBankAccLink.Reset();
        TempOnlineBankAccLink.DeleteAll();

        BankAccount.SetRange(Blocked, false);
        if (BankAccount.FindSet()) then
            repeat
                TempOnlineBankAccLink.Init();
                TempOnlineBankAccLink."No." := BankAccount."No.";
                TempOnlineBankAccLink.Name := CopyStr(BankAccount.Name, 1, 50);
                TempOnlineBankAccLink."Currency Code" := BankAccount."Currency Code";
                TempOnlineBankAccLink."Bank Account No." := CopyStr(BankAccount.GetBankAccountNo(), 1, 30);
                TempOnlineBankAccLink."Automatic Logon Possible" := false;
                TempOnlineBankAccLink.Insert(false);
            until BankAccount.Next() = 0;
    end;

    local procedure RunUpdates();
    var
        //UpdOnlineBankAccLink: Record "Online Bank Acc. Link" temporary;
        CallLicenseServer: Boolean;
    begin
        CallLicenseServer := true;
        if (not UpdALL) then
            CurrPage.AMCBankAssistBankAccount.Page.GetRecs(TempOnlineBankAccLink);

        BasisSetupRanOK := AMCBankAssistedMgt.RunBasisSetupV162(UpdURLBoolean, URLSChanged, SignupURLText, ServiceURLText, SupportURLText, UpdBankBoolean, UpdPayMethBoolean, BankCountryCodeCode, PaymCountryCodeCode,
                                                            UpdDataExchDefBoolean, BANKDATACONVSERVCTBoolean, BANKDATACONVSERVPPBoolean, BANKDATACONVSERVSTMTBoolean, BANKDATACONVSERVCREMBoolean, ApplVerText, BuildNoText,
                                                            UpdBankClearStdBoolean, UpdBankAccountsBoolean, TempOnlineBankAccLink, CallLicenseServer);

        AMCBankAssistedMgt.OnAfterRunBasisSetupV19(UpdURLBoolean, URLSChanged, SignupURLText, ServiceURLText, SupportURLText, UpdBankBoolean, UpdPayMethBoolean, BankCountryCodeCode, PaymCountryCodeCode,
                                                   UpdDataExchDefBoolean, BANKDATACONVSERVCTBoolean, BANKDATACONVSERVPPBoolean, BANKDATACONVSERVSTMTBoolean, BANKDATACONVSERVCREMBoolean, ApplVerText, BuildNoText,
                                                   UpdBankClearStdBoolean, UpdBankAccountsBoolean, TempOnlineBankAccLink, CallLicenseServer, BasisSetupRanOK);
    end;




}
