page 1830 "MS - QBO Data Migration"
{
    Caption = 'QuickBooks Online Migration Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    ShowFilter = false;

    layout
    {
        area(content)
        {
            group("1")
            {
                Visible = InitialVisible;
                ShowCaption = false;

                group(Authenticate)
                {
                    Caption = 'Authenticate';
                    InstructionalText = 'Authenticate to QuickBooks Online';
                    Visible = AuthorizationVisible;
                    field(Status; StatusTxt)
                    {
                        ApplicationArea = Basic, Suite;
                        Editable = false;
                        MultiLine = true;
                        ShowCaption = false;
                    }
                    usercontrol(OAuthIntegration; OAuthControlAddIn)
                    {
                        ApplicationArea = Basic, Suite;

                        trigger AuthorizationCodeRetrieved(code: Text)
                        begin
                            CompleteAuthorizationProcess(code);
                        end;

                        trigger AuthorizationErrorOccurred(error: Text; desc: Text);
                        begin
                            StatusTxt := StrSubstNo(StatusLbl, error, desc);
                        end;

                        trigger ControlAddInReady();
                        begin
                            CRLF := '';
                            CRLF[1] := 13;
                            CRLF[2] := 10;
                            OAuthAddinReady := true;
                            StartAuthorizationProcess();
                        end;
                    }
                }
            }
#if not CLEAN25
            group("2")
            {
                ObsoleteState = Pending;
                ObsoleteReason = 'Not used anymore';
                ObsoleteTag = '17.0';

                Visible = false;
                ShowCaption = false;
                field(Instructions1; '')
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    MultiLine = true;
                    ShowCaption = false;
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Not used anymore';
                    ObsoleteTag = '25.0';
                }
            }
#endif
            group("3")
            {
                InstructionalText = 'Enter the accounts to use when you post sales and purchase transactions to the general ledger.';
                Visible = FirstGroupVisible;
                ShowCaption = false;
                field("Sales Account"; SalesAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Account';
                    ToolTip = 'Specifies the account number of the QuickBooks sales account.';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Sales Credit Memo Account"; SalesCreditMemoAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Credit Memo Account';
                    ToolTip = 'Specifies the account number of the QuickBooks sales credit memo account.';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Sales Line Disc. Account"; SalesLineDiscAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Line Disc. Account';
                    ToolTip = 'Specifies the account number of the QuickBooks sales line discount account.';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Sales Inv. Disc. Account"; SalesInvDiscAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Inv. Disc. Account';
                    ToolTip = 'Specifies the account number of the QuickBooks sales invoice discount account.';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("10"; '')
                {
                    Caption = ' ';
                    ToolTip = ' ';
                    ShowCaption = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Purch. Account"; PurchAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purch. Account';
                    ToolTip = 'Specifies the account number of the QuickBooks purchase account.';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Purch. Credit Memo Account"; PurchCreditMemoAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purch. Credit Memo Account';
                    ToolTip = 'Specifies the account number of the QuickBooks purchase credit memo account.';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Purch. Line Disc. Account"; PurchLineDiscAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purch. Line Disc. Account';
                    ToolTip = 'Specifies the account number of the QuickBooks purchase line discount account.';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Purch. Inv. Disc. Account"; PurchInvDiscAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purch. Inv. Disc. Account';
                    ToolTip = 'Specifies the account number of the QuickBooks purchase invoice discount account.';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("11"; '')
                {
                    Caption = ' ';
                    ToolTip = ' ';
                    ShowCaption = true;
                    ApplicationArea = Basic, Suite;
                }
            }
            group("4")
            {
                Visible = SecondGroupVisible;
                InstructionalText = 'Enter the accounts to use when you post transactions for items, and for the sale or purchase of services.';
                ShowCaption = false;
                field("COGS Account"; COGSAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'COGS Account';
                    ToolTip = 'Specifies the account number of the QuickBooks COGS account.';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Inventory Adjmt. Account"; InventoryAdjmtAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory Adjmt. Account';
                    ToolTip = 'Specifies the account number of the QuickBooks inventory adjustment account.';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Inventory Account"; InventoryAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory Account';
                    ToolTip = 'Specifies the account number of the QuickBooks inventory account.';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("12"; '')
                {
                    Caption = ' ';
                    ToolTip = ' ';
                    ShowCaption = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Receivables Account"; ReceivablesAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Receivables Account';
                    ToolTip = 'Specifies the account number of the QuickBooks receivables account.';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Service Charge Acc."; ServiceChargeAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Service Charge Acc.';
                    ToolTip = 'Specifies the account number of the QuickBooks service charge account.';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("13"; '')
                {
                    Caption = ' ';
                    ToolTip = ' ';
                    ShowCaption = true;
                    ApplicationArea = Basic, Suite;
                }
                field("Payables Account"; PayablesAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payables Account';
                    ToolTip = 'Specifies the account number of the QuickBooks payables account.';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
                field("Purch. Service Charge Acc."; PurchServiceChargeAccount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purch. Service Charge Acc.';
                    ToolTip = 'Specifies the account number of the QuickBooks purchase service charge account.';
                    TableRelation = "MigrationQB Account".AcctNum;
                }
            }
            group("5")
            {
                Visible = ThirdGroupVisible;
                InstructionalText = 'Choose the unit of measure to assign to all inventory and service items that you import.';
                ShowCaption = false;
                field("Unit Of Measure"; UnitOfMeasure)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Unit of Measure';
                    ToolTip = 'Specifies the unit of measure.';
                    TableRelation = "Unit of Measure";

                    trigger OnValidate()
                    var
                        MigrationQBConfig: Record "MigrationQB Config";
                    begin
                        if MigrationQBConfig.Get() then
                            if (UnitOfMeasure <> '') AND (MigrationQBConfig."Total Items" > 0) then
                                NextEnabled := true
                            else
                                NextEnabled := false;
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ActionAuthenticate)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Reconnect';
                InFooterBar = true;
                Visible = AuthorizationVisible;
                Image = Action;

                trigger OnAction()
                begin
                    if OAuthAddinReady then begin
                        if Confirm(ResetAuthQst, false) then begin
                            Session.LogMessage('00007FV', 'Resetting Authorization', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
                            ClearConfigTable();
                            StartAuthorizationProcess();
                            exit;
                        end;

                        StatusTxt := GetStatusText(true);
                        NextEnabled := true;
                        CurrPage.Update(true);
                        exit;
                    end;
                end;
            }
            separator("20")
            {
            }
            action(ActionBack)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Back';
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
                InFooterBar = true;

                trigger OnAction()
                begin
                    NextStep(false);
                end;
            }
        }
    }

    trigger OnClosePage()
    begin
        if Authorized AND not HasErrors then
            SetAccountNumbers();
    end;

    trigger OnOpenPage()
    begin
        ShowAuthorization();
        Authorized := false;
    end;

    var
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
        SalesAccount: Code[20];
        SalesCreditMemoAccount: Code[20];
        SalesLineDiscAccount: Code[20];
        SalesInvDiscAccount: Code[20];
        PurchAccount: Code[20];
        PurchCreditMemoAccount: Code[20];
        PurchLineDiscAccount: Code[20];
        PurchInvDiscAccount: Code[20];
        COGSAccount: Code[20];
        InventoryAdjmtAccount: Code[20];
        InventoryAccount: Code[20];
        ReceivablesAccount: Code[20];
        ServiceChargeAccount: Code[20];
        PayablesAccount: Code[20];
        PurchServiceChargeAccount: Code[20];
        UnitOfMeasure: Code[20];
        AuthorizationVisible: Boolean;
        InitialVisible: Boolean;
        FirstGroupVisible: Boolean;
        SecondGroupVisible: Boolean;
        ThirdGroupVisible: Boolean;
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        OAuthAddinReady: Boolean;
        Authorized: Boolean;
        HasErrors: Boolean;
        Step: Option Authorization,PageOne,PageTwo,PageThree,Done;
        StatusTxt: Text;
        CRLF: Text[2];
        SyncSetupFailed1Txt: Label 'We are unable to connect to your QuickBooks company.';
        SyncSetupFailed2Txt: Label 'Select Reconnect to try and authenticate.';
        AuthInProgressTxt: Label 'QuickBooks Online authorization is in progress. Please complete the authorization process in the pop-up window.';
        SyncSuccessful1Txt: Label 'Great! We''re connected to your QuickBooks company, and ready to import data.';
        SyncSuccessful2Txt: Label 'Choose Next to continue.';
        RequestTokenUrlTxt: Label 'https://appcenter.intuit.com/connect/oauth2', Locked = true;
        AccessTokenUrlTxt: Label 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer', Locked = true;
        ScopeTxt: Label 'com.intuit.quickbooks.accounting', Locked = true;
        ResetAuthQst: Label 'Reset Authentication?';
        NoAccountNumberMsg: Label 'You have at least one account with no account number. Please assign account numbers in QuickBooks and rerun the migration.';
        ConsumerKeyTxt: Label 'datamigration-qbo-clientid', Locked = true;
        ConsumerSecretTxt: Label 'datamigration-qbo-clientsecret', Locked = true;
        ControlUnavailableErr: Label 'OAuthAddin control not available.', Locked = true;
        KeyInfoUnavailableErr: Label 'Unable to retrieve KeyVault Information.', Locked = true;
        AuthRequestUrlErr: Label 'Unable to retrieve authorization request url.', Locked = true;
        OAuthPropertiesErr: Label 'Unable to retrieve OAuthProperties.', Locked = true;
        TokenErr: Label 'Unable to retrieve Token(s) and\or company id.', Locked = true;
        StateErr: Label 'Unexpected State value passed back from remote call. Expected: %1; Actual: %2', Locked = true;
        StatusLbl: Label '%1: %2', Locked = true;
        CallBackUrlLbl: Label '%1/%2', Locked = true;
        ConsumerKey: SecretText;
        ConsumerSecret: SecretText;
        AuthRequestUrl: Text;
        AccessTokenKey: SecretText;
        ExpectedState: Text;

    local procedure ShowAuthorization()
    begin
        Step := Step::Authorization;
        BackEnabled := false;
        NextEnabled := Authorized;
        InitialVisible := true;
        FirstGroupVisible := false;
        SecondGroupVisible := false;
        ThirdGroupVisible := false;
        AuthorizationVisible := true;
    end;

    local procedure ShowPageOne()
    begin
        Step := Step::PageOne;
        BackEnabled := true;
        NextEnabled := true;
        InitialVisible := false;
        FirstGroupVisible := true;
        SecondGroupVisible := false;
        ThirdGroupVisible := false;
        AuthorizationVisible := false;
    end;

    local procedure ShowPageTwo()
    begin
        BackEnabled := true;
        NextEnabled := true;
        InitialVisible := false;
        FirstGroupVisible := false;
        SecondGroupVisible := true;
        ThirdGroupVisible := false;
        AuthorizationVisible := false;
    end;

    local procedure ShowPageThree()
    begin
        if not UofMRequired() then
            NextStep(false);

        if (UnitOfMeasure <> '') then
            NextEnabled := true
        else
            NextEnabled := false;

        BackEnabled := true;
        InitialVisible := false;
        FirstGroupVisible := false;
        SecondGroupVisible := false;
        ThirdGroupVisible := true;
        AuthorizationVisible := false;
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if Backwards then
            Step := Step - 1
        else
            Step := Step + 1;

        case Step of
            Step::Authorization:
                ShowAuthorization();
            Step::PageOne:
                ShowPageOne();
            Step::PageTwo:
                ShowPageTwo();
            Step::PageThree:
                ShowPageThree();
            Step::Done:
                CurrPage.Close();
        end;

        CurrPage.Update(true);
    end;

    procedure SetAccountNumbers()
    var
        MigrationQBAccountSetup: Record "MigrationQB Account Setup";
    begin
        MigrationQBAccountSetup.DeleteAll();

        MigrationQBAccountSetup.Init();
        MigrationQBAccountSetup.SalesAccount := SalesAccount;
        MigrationQBAccountSetup.SalesCreditMemoAccount := SalesCreditMemoAccount;
        MigrationQBAccountSetup.SalesInvDiscAccount := SalesInvDiscAccount;
        MigrationQBAccountSetup.SalesLineDiscAccount := SalesLineDiscAccount;

        MigrationQBAccountSetup.PurchAccount := PurchAccount;
        MigrationQBAccountSetup.PurchCreditMemoAccount := PurchCreditMemoAccount;
        MigrationQBAccountSetup.PurchLineDiscAccount := PurchLineDiscAccount;
        MigrationQBAccountSetup.PurchInvDiscAccount := PurchInvDiscAccount;

        MigrationQBAccountSetup.COGSAccount := COGSAccount;
        MigrationQBAccountSetup.InventoryAdjmtAccount := InventoryAdjmtAccount;
        MigrationQBAccountSetup.InventoryAccount := InventoryAccount;

        MigrationQBAccountSetup.ReceivablesAccount := ReceivablesAccount;
        MigrationQBAccountSetup.ServiceChargeAccount := ServiceChargeAccount;

        MigrationQBAccountSetup.PayablesAccount := PayablesAccount;
        MigrationQBAccountSetup.PurchServiceChargeAccount := PurchServiceChargeAccount;

        MigrationQBAccountSetup.UnitOfMeasure := UnitOfMeasure;

        MigrationQBAccountSetup.Insert();
        Commit();
    end;

    local procedure StartAuthorizationProcess(): Boolean
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        ResetQBOAuthenticationDialog();
        if not OAuthAddinReady then begin
            StatusTxt := GetStatusText(false);
            Session.LogMessage('00007EP', ControlUnavailableErr, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
            exit(false);
        end;

        if ConsumerKey.IsEmpty() then
            if not AzureKeyVault.GetAzureKeyVaultSecret(ConsumerKeyTxt, ConsumerKey) then;

        if ConsumerSecret.IsEmpty() then
            if not AzureKeyVault.GetAzureKeyVaultSecret(ConsumerSecretTxt, ConsumerSecret) then;

        if ConsumerKey.IsEmpty() or ConsumerSecret.IsEmpty() then begin
            StatusTxt := GetStatusText(false);
            Session.LogMessage('00007EQ', KeyInfoUnavailableErr, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
            exit(false);
        end;

        ExpectedState := HelperFunctions.FormatGuid(CreateGuid());

        if not HelperFunctions.GetAuthRequestUrl(ConsumerKey, ConsumerSecret, ScopeTxt, RequestTokenUrlTxt, StrSubstNo(CallBackUrlLbl, GetCallBackUrl(), 'OAuthLanding.htm'), ExpectedState, AuthRequestUrl) then begin
            StatusTxt := GetStatusText(false);
            Session.LogMessage('0000AL5', AuthRequestUrlErr, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
            exit(false);
        end;

        CurrPage.OAuthIntegration.StartAuthorization(AuthRequestUrl);
        StatusTxt := AuthInProgressTxt;
    end;

    local procedure CompleteAuthorizationProcess(AuthorizationCode: SecretText)
    var
        MigrationQBConfig: Record "MigrationQB Config";
        AccountMigrator: Codeunit "MigrationQB Account Migrator";
        RealmId: Text;
        State: Text;
        AuthCode: SecretText;
    begin
        if not GetOAuthProperties(AuthorizationCode, AuthCode, State, RealmId) then begin
            StatusTxt := GetStatusText(false);
            Session.LogMessage('00007ER', OAuthPropertiesErr, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
            exit;
        end;

        if (ExpectedState <> State) then begin
            StatusTxt := GetStatusText(false);
            Session.LogMessage('0000AI7', StrSubstNo(StateErr, ExpectedState, State), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
            exit;
        end;

        StatusTxt := 'Getting response';

        if not HelperFunctions.GetAccessToken(AccessTokenUrlTxt, StrSubstNo(CallBackUrlLbl, GetCallBackUrl(), 'OAuthLanding.htm'), AuthCode, ConsumerKey, ConsumerSecret, AccessTokenKey) then begin
            StatusTxt := GetStatusText(false);
            Session.LogMessage('00007ES', TokenErr, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetMigrationTypeTxt());
            exit;
        end;

        MigrationQBConfig.InitializeOnlineConfig(AccessTokenKey, RealmId);
        StatusTxt := GetStatusText(true);
        NextEnabled := true;
        HasErrors := false;

        HelperFunctions.GetOnlineRecordCounts();
        AccountMigrator.GetAll(true);
        Commit();
        if not AccountMigrator.PreDataIsValid() then begin
            Message(NoAccountNumberMsg);
            HasErrors := true;
            NextEnabled := false;
            CleanupOnErrors();
            StatusTxt := NoAccountNumberMsg;
        end;
    end;

    local procedure ResetQBOAuthenticationDialog()
    begin
        NextEnabled := false;
        BackEnabled := false;
        StatusTxt := ''
    end;

    local procedure GetStatusText(Success: Boolean): Text
    begin
        if Success then begin
            Authorized := true;
            exit(SyncSuccessful1Txt + CRLF + CRLF + SyncSuccessful2Txt);
        end;

        Authorized := false;
        exit(SyncSetupFailed1Txt + CRLF + CRLF + SyncSetupFailed2Txt)
    end;

    local procedure UofMRequired(): Boolean
    var
        MigrationQBConfig: Record "MigrationQB Config";
    begin
        if MigrationQBConfig.Get() then
            if MigrationQBConfig."Total Items" > 0 then
                exit(true);

        exit(false);
    end;

    local procedure CleanupOnErrors()
    var
        MigrationQBAccount: Record "MigrationQB Account";
    begin
        MigrationQBAccount.DeleteAll();
        ClearConfigTable();
    end;

    [NonDebuggable]
    local procedure GetOAuthProperties(AuthorizationCode: SecretText; var CodeOut: SecretText; var StateOut: Text; var RealmIDOut: Text): Boolean
    var
        JObject: JsonObject;
        JToken: JsonToken;
        AuthorizationCodeAsText: Text;
    begin
        AuthorizationCodeAsText := AuthorizationCode.Unwrap();
        if JObject.ReadFrom(AuthorizationCodeAsText) then
            if JObject.Get('code', JToken) then
                if JToken.IsValue() then
                    if JToken.WriteTo(AuthorizationCodeAsText) then
                        AuthorizationCodeAsText := HelperFunctions.TrimStringQuotes(AuthorizationCodeAsText);
        CodeOut := HelperFunctions.GetPropertyFromCode(AuthorizationCodeAsText, 'code');
        StateOut := HelperFunctions.GetPropertyFromCode(AuthorizationCodeAsText, 'state');
        RealmIDOut := HelperFunctions.GetPropertyFromCode(AuthorizationCodeAsText, 'realmId');

        if (StateOut = '') or (RealmIDOut = '') then
            exit(false);

        exit(true);
    end;

    local procedure GetCallBackUrl(): Text
    var
        EnvironmentInfo: Codeunit "Environment Information";
        CallBackUrl: Text;
        EnvironmentName: Text;
    begin
        CallBackUrl := GetUrl(ClientType::Web);
        CallBackUrl := ConvertStr(CallBackUrl, '?', ',');
        CallBackUrl := SelectStr(1, CallBackUrl);
        CallBackUrl := CallBackUrl.TrimEnd('/');
        EnvironmentName := EnvironmentInfo.GetEnvironmentName();
        if EnvironmentName <> '' then begin
            CallBackUrl := CallBackUrl.TrimEnd(EnvironmentName);
            CallBackUrl := CallBackUrl.TrimEnd('/');
        end;

        if IsGuid(CallBackUrl.Substring(CallBackUrl.LastIndexOf('/') + 1, 36)) then
            CallBackUrl := CallBackUrl.TrimEnd(CallBackUrl.Substring(CallBackUrl.LastIndexOf('/'), 37));

        exit(CallBackUrl);
    end;

    local procedure ClearConfigTable()
    var
        MigrationQBConfig: Record "MigrationQB Config";
    begin
        MigrationQBConfig.DeleteAll();
    end;

    [TryFunction]
    [Scope('OnPrem')]
    local procedure IsGuid(StringToTest: Text[36])
    var
        GuidTest: Guid;
    begin
        Evaluate(GuidTest, StringToTest);
    end;
}