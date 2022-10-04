﻿codeunit 1450 "MS - Yodlee Service Mgt."
{
    var
        ResponseTempBlob: Codeunit "Temp Blob";
        YodleeAPIStrings: Codeunit "Yodlee API Strings";
        SetupSuccessMsg: Label 'The setup test was successful. The settings are valid.';
        NotEnabledErr: Label 'The bank feed service is not enabled.\\In the Envestnet Yodlee Bank Feeds Service Setup window, select the Enabled check box.';
        GLBResponseInStream: InStream;
        BankFeedTextList: List of [Text];
        GetCobrandTokenTxt: Label 'Get the Cobrand token.';
        GetConsumerTokenTxt: Label '"Get the Consumer token. "';
        GetFastlinkTokenTxt: Label 'Get the FastLink token.';
        GetBankSiteListTxt: Label 'Get bank sites.';
        GetBankAccListTxt: Label 'Get bank accounts from site.';
        GetBankAccTxt: Label 'Get bank account.';
        GetBankTxTxt: Label 'Get bank transactions.';
        GetUnlinkAccountTxt: Label 'Unlink account.';
        LinkBankAccountTxt: Label 'Bank Account %1 linked to an online bank account.', Comment = '%1=Bank account number';
        UnlinkBankAccountTxt: Label 'Bank Account %1 unlinked from an online bank account.', Comment = '%1=Bank account number';
        RemoveConsumerTxt: Label 'Remove consumer.';
        RegisterConsumerTxt: Label 'Register consumer.';
        BankRefreshTxt: Label 'Get Latest Bank Feed.';
        AuthenticationTokenTxt: Label 'Get the authentication tokens.';
        LoggingConstTxt: Label 'Bank Feed Service';
        YodleeResponseTxt: Label 'Yodlee Response';
        GLBTraceLogEnabled: Boolean;
        InvalidResponseErr: Label 'The response was not valid.';
        UnknownErr: Label 'An unknown error has occurred.';
        CannotGetLinkedAccountsErr: Label 'The updated list of linked bank accounts could not be shown.\\Choose the Update Bank Account Linking action to try again.';
        AccountsLinkingSummaryMsg: Label '%1 bank accounts have been linked.', Comment = '%1 = Number of accounts whose linking has just been created (e.g. 2)';
        AccountLinkingSummaryMsg: Label 'Bank account %1 has been linked.', Comment = '%1 is bank account name e.g. GIRO';
        AccountUnLinkingSummaryMsg: Label '%1 bank accounts have been unlinked.', Comment = '%1 = Number of accounts whose linking has been removed (e.g. 5)';
        BankAccountsAreLinkedMsg: Label 'All bank account links are up to date, or no online bank accounts exist.';
        NoNewBankAccountsMsg: Label 'No new bank account is created or linked because all online bank accounts are already linked.';
        ConcatAccountSummaryMsg: Label '%1 %2', Comment = 'Used to concat AccountLinkingSummaryMsg (%1) and AccountUnLinkingSummaryMsg (%2)';
        UnlinkQst: Label 'The bank account has been unlinked from the online bank account.\\Do you want to clear the online bank login details?';
        PromptConsumerRemoveNoLinkingQst: Label 'No online bank accounts are connected to Envestnet Yodlee.\\Do you want to clear the online bank login details?';
        SuccessTxt: Label 'The request succeeded.';
        SuccessToFindAccountTxt: Label 'Found accounts for bank %1.', Comment = '%1 = online bank id (e.g. 1052352)';
        SuccessAccountUnlinkTxt: Label 'Bank account was unlinked.';
        SuccessGetTxForAccTxt: Label 'Transactions for bank account %1 have been downloaded.', Comment = '%1=bank account no';
        SuccessRemoveConsumerTxt: Label 'Consumer has been removed.';
        SuccessRegisterConsumerTxt: Label 'Consumer has been registered.';
        FailedTxt: Label 'The request was unsuccessful.';
        FailedToFindAccountTxt: Label 'Could not get the list of accounts for bank %1.', Comment = '%1 = online bank id (e.g. 1052352)';
        FailedAccountUnlinkTxt: Label 'Bank account %1 could not be unlinked.', Comment = '%1=Bank account number';
        FailedRemoveConsumerMsg: Label 'Failed to remove the consumer.';
        FailedRegisterConsumerTxt: Label 'Failed to register the consumer.';
        BadCobrandTxt: Label 'The cobrand credentials or the Service URL are not valid.';
        BadConsumerTxt: Label 'The consumer credentials are not valid.';
        RefreshStatusErr: Label 'Error code: %1.%2\\For more information, see https://developer.yodlee.com/Yodlee_API/docs/v1_1/Data_Model/Resource_Account#Dataset_Additional_Statuses.', Comment = '%1 Specific error code, %2 Extra comment';
        CredentialsCommentTxt: Label 'Yodlee is unable to retrieve the newest bank feeds without user assistance. To perform this activity manually, you must open the corresponding bank account card, and choose action Refresh Online Bank Account.';
        CurrencyMismatchErr: Label 'The currency your bank account is using (%1) does not match the currency for your online bank account (%2).', Comment = '%1 and %2 are company and Yodlee currency codes.';
        RefreshMsg: Label 'The value in the To Date field is later than the date of the current bank feed. The latest bank feed is from %1.', Comment = '%1 = the date the bank feed was last updated';
        BankStmtServiceInvalidConsumerErrTxt: Label 'Invalid User Credentials', Locked = true;
        BankStmtServiceStaleConversationCredentialsErrTxt: Label 'Stale conversation credentials', Locked = true;
        BankStmtServiceStaleConversationCredentialsExceptionTxt: Label 'StaleConversationCredentialsException', Locked = true;
        BankStmtServiceStaleIllegalArgumentValueExceptionTxt: Label 'IllegalArgumentValueException', Locked = true;
        RegisterConsumerVerifyLCYCodeTxt: Label 'Registering a consumer account failed because of an invalid argument value. Open General Ledger Setup window and verify that the field LCY Code contains the ISO standard code for your local currency.';
        StaleCredentialsErr: Label 'Your session has expired. Please try the operation again.';
        BankAccountRefreshInvalidCredentialsTxt: Label 'Yodlee could not update your account because your username and/or password were reported to be incorrect. You must open the corresponding bank account card and choose action Edit Online Bank Account Information.';
        BankAccountRefreshUnknownErrorTxt: Label 'We are sorry, Yodlee encountered a technical problem while updating your account. Please try again later.';
        BankAccountRefreshAccountLockedTxt: Label 'Yodlee could not update your account because it appears to be locked by your bank. This usually results from too many unsuccessful login attempts in a short period of time. Please visit the bank or contact its customer support to resolve this issue. Once done, please update your account credentials in case they are changed.';
        BankAccountRefreshBankDownTxt: Label 'Yodlee was unable to update your account as the online bank is experiencing technical difficulties. We apologize for the inconvenience. Please try again later.';
        BankAccountRefreshBankDownForMaintenanceTxt: Label 'Yodlee was unable to update your account as the online bank is temporarily down for maintenance. We apologize for the inconvenience. This problem is typically resolved in a few hours. Please try again later.';
        BankAccountRefreshBankInBetaMaintenanceTxt: Label 'Yodlee was unable to update your account because it has started providing data updates for this online bank, and it may take a few days to be successful. Please try again later.';
        BankAccountRefreshTimedOutTxt: Label 'Your request timed out due to technical reasons. Please try again.';
        BankAccountRefreshAdditionalAuthInfoNeededTxt: Label 'Additional authentication information is required. Open the corresponding bank account card and choose action Edit Online Bank Account Information.';
        YodleeFastlinkUrlTxt: Label 'YODLEE_FASTLINKURL', Locked = true;
        GLBDisableRethrowException: Boolean;
        ErrorsIgnoredTxt: Label 'This failure has been ignored.';
        ErrorsIgnoredByUserTxt: Label 'This failure has been ignored. User has wished to continue.';
        EnableYodleeQst: Label 'The Envestnet Yodlee Bank Feeds Service has not been enabled. Do you want to enable it?';
        TermsOfUseNotAcceptedErr: Label 'You must accept the Envestnet Yodlee terms of use before you can use the service.';
        GLBSetupPageIsCallee: Boolean;
        ServiceUrlTok: Label 'https://rest.developer.yodlee.com/services/srest/restserver/v1.0/', Locked = true;
        BankAccLinkingUrlTok: Label 'https://node.developer.yodlee.com/authenticate/restserver/', Locked = true;
        DemoCompanyWithDefaultCredentialMsg: Label 'You cannot use the Envestnet Yodlee Bank Feeds Service on the demonstration company. Open another company and try again.';
        NoAccountLinkedMsg: Label 'The bank account is not linked to an online bank account.';
        YodleeCobrandSecretEnvironmentNameTok: Label 'YodleeCobrandEnvironmentName';
        YodleeCobrandSecretNameTok: Label 'YodleeCobrandName';
        YodleeCobrandPasswordSecretNameTok: Label 'YodleeCobrandPassword';
        YodleeServiceUrlSecretNameTok: Label 'YodleeServiceUri';
        YodleeFastlinkUrlTok: Label 'YodleeFastlinkUrl';
        YodleeBusinessSetupDescriptionTxt: Label 'Set up and enable the Envestnet Yodlee Bank Feeds service.';
        YodleeBusinessSetupKeywordsTxt: Label 'Finance,Bank Feeds,Yodlee,Payment';
        YodleeTelemetryCategoryTok: Label 'AL Yodlee', Locked = true;
        TelemetryActivitySuccessTxt: Label 'Successful Activity "%1", Message "%2".', Locked = true;
        TelemetryActivityFailureTxt: Label 'Failed Activity "%1", Message "%2".', Locked = true;
        GLBConsumerName: Text;
        FailureAction: Option IgnoreError,RethrowError,RethrowErrorWithConfirm;
        CobrandTokenExpiredTxt: Label 'Cached cobrand token has expired.', Locked = true;
        ConsumerTokenExpiredTxt: Label 'Cached consumer token has expired.', Locked = true;
        ConsumerUnitializedTxt: Label 'Consumer is not initialized.', Locked = true;
        ProcessingWindowMsg: Label 'Please wait while the server is processing your request.\This may take several minutes.';
        RemoteServerErr: Label 'The remote server returned an error: (%1) %2.', Locked = true;
        LCYCurrencyCodeMostBeInISOFormatErr: Label 'The Currency code must be in ISO 4217 format eq use USD instead of US';
        LinkingToAccountWithEmptyCurrencyQst: Label 'The online bank account %1 has no currency code.\Do you want to link it to your bank account?', Comment = '%1 - bank account name';
        EmptyCurrencyOnOnlineAccountMsg: Label 'The online bank account has no currency code.', Locked = true;
        TransactionsDownloadedTelemetryTxt: Label 'Transactions downloaded for 1 of %1 linked bank account(s).', Locked = true;
        RefreshingBankAccountTelemetryTxt: Label 'Refreshing transaction data for online bank account %1 with refresh mode %2.', Locked = true;
        YodleeAwarenessNotificationTxt: Label 'You can use the Envestnet Yodlee Bank Feeds extension to link your bank accounts to online bank accounts.';
        YodleeAwarenessNotificationNameTxt: Label 'Notify the user of Envestnet Yodlee Bank Feeds extension capabilities.';
        YodleeAwarenessNotificationDescriptionTxt: Label 'Turns the user''s attention to the capabilities of Envestnet Yodlee Bank Feeds extension.';
        PaymentReconAwarenessNotificationTxt: Label 'You can use the Payment Reconciliation Journals window to import bank transactions.';
        PaymentReconAwarenessNotificationNameTxt: Label 'Notify the user of payment reconciliation journals.';
        PaymentReconAwarenessNotificationDescriptionTxt: Label 'Turns the user''s attention to the capabilities of payment reconciliation journals.';
        AutoBankStmtImportNotificationTxt: Label 'You can set up automatic bank statement import for this bank account.';
        AutoBankStmtImportNotificationNameTxt: Label 'Notify the user of the capabilities of automatic bank statement import.';
        AutoBankStmtImportNotificationDescriptionTxt: Label 'Turns the user''s attention to the capabilities of automatic bank statement import.';
        SetUpNotificationActionTxt: Label 'Set it up here.';
        UsageNotificationActionTxt: Label 'Try it out here.';
        DisableNotificationTxt: Label 'Disable this notification.';
        UserOpenedAutoBankStmtSetupViaNotificationTxt: Label 'The user opened automatic bank statement import setup via a notification.', Locked = true;
        UserStartedLinkingNewBankAccountViaNotificationTxt: Label 'The user started linking new bank account via via a notification.', Locked = true;
        UserOpenedYodleeSetupPageViaNotificationTxt: Label 'The user started linking new bank account via a notification.', Locked = true;
        UserOpenedPaymentReconJournalsViaNotificationTxt: Label 'The user opened payment reconciliation journals via a notification.', Locked = true;
        UserDisabledNotificationTxt: Label 'The user disabled notification %1.', Locked = true;
        YodleeServiceNameTxt: Label 'Envestnet Yodlee Bank Feeds Service';
        YodleeServiceIdentifierTxt: Label 'Yodlee', Locked = true;
        MissingCredentialsQst: Label 'The password is missing in the Envestnet Yodlee Bank Feeds Service Setup window.\\Do you want to open the Envestnet Yodlee Bank Feeds Service Setup window?';
        MissingCredentialsErr: Label 'The password is missing in the Envestnet Yodlee Bank Feeds Service Setup window.';
        ProgressWindowMsg: Label 'Waiting for Envestnet Yodlee to complete the bank account refresh #1', Comment = '#1 is a number tracking the progress of the refresh';
        ProgressWindowUpdateTxt: Label '%1 seconds', Comment = '%1 - an integer';
        RefreshTakingTooLongTxt: Label 'Refreshing the bank account on Envestnet Yodlee is taking longer than expected.\\The refresh on Envestnet Yodlee can take up to 5 minutes to complete. You can import transactions up to the last successful refresh date while the refresh is running.';
        RefreshingBankAccountsTooLongTelemetryTxt: Label 'Refreshing bank accounts data for bank %1 is taking more than 90 seconds.', Locked = true;
        VideoBankintegrationNameTxt: Label 'Set up bank integration';
        VideoBankintegrationTxt: Label 'https://go.microsoft.com/fwlink/?linkid=828679', Locked = true;
        RequestUnsuccessfulErr: Label 'The request failed due to an underlying issue such as network connectivity, DNS failure, server certificate validation or timeout.';
        UnauthorizedResponseCodeTok: Label '(401)', Locked = true;
        UnableToInsertUnlinkedBankAccToBufferErr: Label 'Unable to insert information about account that is linked on Yodlee. ProviderAccount id - %1, AccountId - %2.', Locked = true;
        StartingToRegisterUserTxt: Label 'Starting to register user %1 with currency code %2 on Yodlee.', Locked = true;
        FastlinkDataJsonTok: Label '{"app":"%1","rsession":"%2","token":"%3","redirectReq":"%4","extraParams":"%5"}', Locked = true;
        FastlinkLinkingExtraParamsTok: Label 'keyword=%1', Locked = true;
        Fastlink4ExtraParamsTok: Label 'configName=DefaultFL4', Locked = true;
        FastlinkMfaRefreshExtraParamsTok: Label 'siteAccountId=%1&flow=refresh&callback=%2', Locked = true;
        Fastlink4MfaRefreshExtraParamsTok: Label 'providerAccountId=%1&flow=refresh&callback=%2&configName=DefaultFL4', Locked = true;
        FastlinkAccessConsentExtraParamsTok: Label 'siteAccountId=%1&flow=manageConsent&callback=%2', Locked = true;
        FastlinkEditAccountExtraParamsTok: Label 'providerAccountId=%1&flow=edit&callback=%2', Locked = true;
        BankAccountNameDisplayLbl: Label '%1 - %2', Locked = true;
        LabelDateExprTok: Label '<%1D>', Locked = true;

    procedure SetValuesToDefault(var MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup");
    var
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
        HasCustomCredentialsInAKV: Boolean;
        ServiceURLValue: Text;
        BankAccLinkingURLValue: Text;
        DefaultSaasModeUserProfileEmailAddressTok: Text;
    begin
        MSYodleeBankServiceSetup."User Profile Email Address" := '';

        MSYodleeBankServiceSetup.ResetDefaultBankStatementImportFormat();

        HasCustomCredentialsInAKV := HasCustomCredentialsInAzureKeyVault();
        IF NOT HasCustomCredentialsInAKV THEN BEGIN
            MSYodleeBankServiceSetup."Service URL" := ServiceUrlTok;
            MSYodleeBankServiceSetup."Bank Acc. Linking URL" := BankAccLinkingUrlTok;
        END;

        IF CompanyInformationMgt.IsDemoCompany() THEN
            EXIT;

        // this is not available OnPrem, since we have the secret only in AKV
        IF NOT HasCustomCredentialsInAKV THEN BEGIN
            IF GetYodleeServiceURLFromAzureKeyVault(ServiceURLValue) THEN
                MSYodleeBankServiceSetup.VALIDATE("Service URL",
                  COPYSTR(ServiceURLValue, 1, MAXSTRLEN(MSYodleeBankServiceSetup."Service URL")));
            IF GetAzureKeyVaultSecret(BankAccLinkingURLValue, YodleeFastlinkUrlTxt) THEN
                MSYodleeBankServiceSetup.VALIDATE("Bank Acc. Linking URL",
                  COPYSTR(BankAccLinkingURLValue, 1, MAXSTRLEN(MSYodleeBankServiceSetup."Bank Acc. Linking URL")));
        END;

        DefaultSaasModeUserProfileEmailAddressTok := 'cristina@contoso.com';
        IF EnvironmentInformation.IsSaaS() THEN
            MSYodleeBankServiceSetup.VALIDATE("User Profile Email Address", DefaultSaasModeUserProfileEmailAddressTok);
    end;

    procedure CheckSetup();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        CobrandToken: Text;
        ConsumerToken: Text;
    begin
        GLBSetupPageIsCallee := TRUE;

        Authenticate(CobrandToken, ConsumerToken);
        MSYodleeBankServiceSetup.GET();
        MSYodleeBankServiceSetup.TESTFIELD("Bank Feed Import Format");
        MSYodleeBankServiceSetup.TESTFIELD("User Profile Email Address");
        GeneralLedgerSetup.Get();
        If StrLen(GeneralLedgerSetup."LCY Code") <> 3 then
            GeneralLedgerSetup.FieldError("LCY Code", LCYCurrencyCodeMostBeInISOFormatErr);

        MESSAGE(SetupSuccessMsg);
    end;

    [NonDebuggable]
    local procedure TryAuthenticate(var CobrandToken: Text; var ConsumerToken: Text; var ErrorText: Text): Boolean;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        MSYodleeBankSession: Record "MS - Yodlee Bank Session";
        CobrandTokenExpired: Boolean;
        ConsumerTokenExpired: Boolean;
        CobrandTokenLastDateUpdated: DateTime;
        ConsumerTokenLastDateUpdated: DateTime;
        ConsumerPassword: Text;
        Failure: Boolean;
        Disabled: Boolean;
    begin
        IF NOT TryVerifyTermsOfUseAccepted(ErrorText) THEN
            EXIT(FALSE);

        MSYodleeBankServiceSetup.GET();
        StoreConsumerName(MSYodleeBankServiceSetup."Consumer Name");

        CobrandToken := MSYodleeBankSession.GetCobrandSessionToken();
        IF CobrandToken = '' THEN BEGIN
            CobrandTokenExpired := TRUE;
            CobrandTokenLastDateUpdated := CURRENTDATETIME();
            OnCobrandTokenExpiredSendTelemetry();
            IF NOT GetCobrandToken(GetCobrandName(), GetCobrandPassword(), CobrandToken, ErrorText) THEN BEGIN
                Failure := TRUE;
                ErrorText := GetAdjustedErrorText(ErrorText, BadCobrandTxt);
                IF IsStaleCredentialsErr(ErrorText) THEN
                    ErrorText := StaleCredentialsErr;
                LogActivityFailed(GetCobrandTokenTxt, ErrorText, FailureAction::IgnoreError, '', STRSUBSTNO(TelemetryActivityFailureTxt, GetCobrandTokenTxt, ErrorText), VERBOSITY::Error);
            END;
        END;

        ConsumerPassword := GetConsumerPassword();
        IF NOT Failure THEN
            IF (MSYodleeBankServiceSetup."Consumer Name" = '') AND (ConsumerPassword = '') THEN
                IF MSYodleeBankServiceSetup.Enabled THEN BEGIN // if service is enabled we should create consumer
                    ConsumerTokenExpired := TRUE;
                    OnConsumerUninitializedSendTelemetry();
                    IF NOT RegisterConsumer(MSYodleeBankServiceSetup."Consumer Name", ConsumerPassword, ErrorText, CobrandToken) THEN
                        Failure := TRUE;
                END ELSE
                    Disabled := TRUE; // since service not enabled we should not create a consumer account yet

        IF (NOT Failure) AND (NOT Disabled) THEN BEGIN
            IF NOT CobrandTokenExpired THEN
                ConsumerToken := MSYodleeBankSession.GeConsumerSessionToken()
            ELSE
                ConsumerToken := '';
            IF ConsumerToken = '' THEN BEGIN
                ConsumerTokenExpired := TRUE;
                ConsumerTokenLastDateUpdated := CURRENTDATETIME();
                OnConsumerTokenExpiredSendTelemetry();
                IF NOT GetConsumerToken(MSYodleeBankServiceSetup."Consumer Name", GetConsumerPassword(), CobrandToken, ConsumerToken, ErrorText) THEN BEGIN
                    Failure := TRUE;
                    IF ErrorText = BankStmtServiceInvalidConsumerErrTxt THEN
                        ErrorText := BadConsumerTxt
                    ELSE
                        ErrorText += '\' + BadConsumerTxt;
                    IF IsStaleCredentialsErr(ErrorText) THEN BEGIN
                        ErrorText := StaleCredentialsErr;
                        LogActivityFailed(GetConsumerTokenTxt, ErrorText, FailureAction::RethrowError, '', STRSUBSTNO(TelemetryActivityFailureTxt, GetConsumerTokenTxt, ErrorText), VERBOSITY::Warning)
                    END ELSE
                        LogActivityFailed(GetConsumerTokenTxt, ErrorText, FailureAction::IgnoreError, '', STRSUBSTNO(TelemetryActivityFailureTxt, GetConsumerTokenTxt, ErrorText), VERBOSITY::Error)
                END;
            END;
        END;

        IF CobrandTokenExpired THEN
            MSYodleeBankSession.UpdateSessionTokens(CobrandToken, CobrandTokenLastDateUpdated, ConsumerToken, ConsumerTokenLastDateUpdated)
        ELSE
            IF ConsumerTokenExpired THEN
                MSYodleeBankSession.UpdateConsumerSessionToken(ConsumerToken, ConsumerTokenLastDateUpdated);

        IF Failure THEN
            EXIT(FALSE);

        LogActivitySucceed(AuthenticationTokenTxt, SuccessTxt, StrSubstNo(TelemetryActivitySuccessTxt, AuthenticationTokenTxt, SuccessTxt));
        EXIT(TRUE);
    end;

    local procedure Authenticate(var CobrandToken: Text; var ConsumerToken: Text);
    var
        ErrorText: Text;
    begin
        IF NOT TryAuthenticate(CobrandToken, ConsumerToken, ErrorText) THEN
            IF NOT GLBDisableRethrowException THEN
                ERROR(ErrorText);
    end;

    local procedure GetCobrandToken(Username: Text; Password: Text; var CobrandToken: Text; var ErrorText: Text): Boolean;
    begin
        ExecuteWebServiceRequest(YodleeAPIStrings.GetCobrandTokenURL(), 'POST', YodleeAPIStrings.GetCobrandTokenBody(Username, Password), '', ErrorText);

        IF ErrorText <> '' THEN
            EXIT(FALSE);

        EXIT(GetResponseValue(YodleeAPIStrings.GetCobrandTokenXPath(), CobrandToken, ErrorText));
    end;

    local procedure GetConsumerToken(Username: Text; Password: Text; CobrandToken: Text; var ConsumerToken: Text; var ErrorText: Text): Boolean;
    var
        AuthorizationHeaderValue: Text;
    begin
        AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken, '');
        ExecuteWebServiceRequest(YodleeAPIStrings.GetConsumerTokenURL(), 'POST', YodleeAPIStrings.GetConsumerTokenBody(Username, Password, CobrandToken), AuthorizationHeaderValue, ErrorText);

        IF ErrorText <> '' THEN
            EXIT(FALSE);

        EXIT(GetResponseValue(YodleeAPIStrings.GetConsumerTokenXPath(), ConsumerToken, ErrorText));
    end;

    local procedure GetFastlinkToken(CobrandToken: Text; ConsumerToken: Text; var FastLinkToken: Text; var ErrorText: Text): Boolean;
    var
        AuthorizationHeaderValue: Text;
    begin
        AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken, ConsumerToken);
        ExecuteWebServiceRequest(YodleeAPIStrings.GetFastLinkTokenURL(), YodleeAPIStrings.GetFastLinkTokenRequestMethod(),
          YodleeAPIStrings.GetFastLinkTokenBody(CobrandToken, ConsumerToken), AuthorizationHeaderValue, ErrorText);

        IF ErrorText <> '' THEN
            EXIT(FALSE);

        EXIT(GetResponseValue(YodleeAPIStrings.GetFastLinkTokenXPath(), FastLinkToken, ErrorText));
    end;

    local procedure GetFastlinkData(ExtraParams: Text; var ErrorText: Text): Text;
    var
        TypeHelper: Codeunit "Type Helper";
        Data: Text;
        CobrandToken: Text;
        ConsumerToken: Text;
        FastlinkToken: Text;
    begin
        IF NOT TryCheckServiceEnabled(ErrorText) THEN
            EXIT('');

        IF NOT TryAuthenticate(CobrandToken, ConsumerToken, ErrorText) THEN
            EXIT('');

        IF NOT GetFastlinkToken(CobrandToken, ConsumerToken, FastlinkToken, ErrorText) THEN BEGIN
            ErrorText := GetAdjustedErrorText(ErrorText, FailedTxt);
            IF IsStaleCredentialsErr(ErrorText) THEN BEGIN
                ErrorText := StaleCredentialsErr;
                LogActivityFailed(GetFastlinkTokenTxt, ErrorText, FailureAction::RethrowError, '', STRSUBSTNO(TelemetryActivityFailureTxt, GetFastLinkTokenTxt, ErrorText), VERBOSITY::Warning)
            END ELSE
                LogActivityFailed(GetFastlinkTokenTxt, ErrorText, FailureAction::IgnoreError, '', STRSUBSTNO(TelemetryActivityFailureTxt, GetFastLinkTokenTxt, ErrorText), VERBOSITY::Error);
            EXIT('');
        END;

        Data := STRSUBSTNO(FastlinkDataJsonTok,
            '10003600',
            ConsumerToken,// encoded by GetFastlinkToken
            TypeHelper.UrlEncode(FastlinkToken),
            'true',
            ExtraParams);

        LogActivitySucceed(GetFastlinkTokenTxt, SuccessTxt, STRSUBSTNO(TelemetryActivitySuccessTxt, GetFastLinkTokenTxt, SuccessTxt));

        EXIT(Data);
    end;

    procedure GetFastlinkDataForLinking(BankName: Text; var Data: Text; var ErrorText: Text): Boolean;
    var
        TypeHelper: Codeunit "Type Helper";
        ExtraParams: Text;
    begin
        // strip '&' as Yodlee seems to discard any text after this
        BankName := DELCHR(BankName, '=', '&');

        if UsingFastlink4() then
            ExtraParams := Fastlink4ExtraParamsTok
        else
            ExtraParams := STRSUBSTNO(FastlinkLinkingExtraParamsTok, TypeHelper.UrlEncode(BankName)); // prepopulate search with bank name

        Data := GetFastlinkData(ExtraParams, ErrorText);
        EXIT(ErrorText = '');
    end;

    procedure GetFastlinkDataForMfaRefresh(BankStatementServiceId: Text; CallbackUrl: Text; var Data: Text; var ErrorText: Text): Boolean;
    var
        TypeHelper: Codeunit "Type Helper";
        ExtraParams: Text;
    begin
        if UsingFastlink4() then
            ExtraParams := StrSubstNo(Fastlink4MfaRefreshExtraParamsTok, TypeHelper.UrlEncode(BankStatementServiceId), TypeHelper.UrlEncode(CallbackUrl))
        else
            ExtraParams := StrSubstNo(FastlinkMfaRefreshExtraParamsTok, TypeHelper.UrlEncode(BankStatementServiceId), TypeHelper.UrlEncode(CallbackUrl));

        Data := GetFastlinkData(ExtraParams, ErrorText);
        EXIT(ErrorText = '');
    end;

    procedure GetFastlinkDataForAccessConsent(OnlineBankAccountId: Text; CallbackUrl: Text; var Data: Text; var ErrorText: Text): Boolean;
    var
        TypeHelper: Codeunit "Type Helper";
        ExtraParams: Text;
    begin
        ExtraParams := StrSubstNo(FastlinkAccessConsentExtraParamsTok, TypeHelper.UrlEncode(OnlineBankAccountId), TypeHelper.UrlEncode(CallbackUrl));

        if UsingFastlink4() then
            ExtraParams += ('&' + Fastlink4ExtraParamsTok);

        Data := GetFastlinkData(ExtraParams, ErrorText);
        EXIT(ErrorText = '');
    end;

    procedure GetFastlinkDataForEditAccount(OnlineBankAccountId: Text; CallbackUrl: Text; var Data: Text; var ErrorText: Text): Boolean;
    var
        TypeHelper: Codeunit "Type Helper";
        ExtraParams: Text;
    begin
        ExtraParams := StrSubstNo(FastlinkEditAccountExtraParamsTok, TypeHelper.UrlEncode(OnlineBankAccountId), TypeHelper.UrlEncode(CallbackUrl));

        if UsingFastlink4() then
            ExtraParams += ('&' + Fastlink4ExtraParamsTok);

        Data := GetFastlinkData(ExtraParams, ErrorText);
        EXIT(ErrorText = '');
    end;

    procedure LinkBankAccount(var BankAccount: Record "Bank Account");
    begin
        CheckServiceEnabled();

        IF ShowFastLinkPage(BankAccount.Name) THEN
            UpdateBankAccountLinking(BankAccount, FALSE);
    end;

    procedure UnlinkBankAccount(BankAccount: Record "Bank Account"): Boolean;
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        UnlinkQuestion: Text;
        LinkedAccounts: Integer;
    begin
        LinkedAccounts := MSYodleeBankAccLink.COUNT();

        IF NOT MSYodleeBankAccLink.GET(BankAccount."No.") THEN
            EXIT(FALSE);

        IF LinkedAccounts = 1 THEN
            UnlinkQuestion := PromptConsumerRemoveNoLinkingQst
        ELSE
            UnlinkQuestion := UnlinkQst;

        IF NOT CONFIRM(UnlinkQuestion) THEN BEGIN
            MarkBankAccountAsUnlinked(BankAccount."No.");
            EXIT(FALSE);
        END;

        UnlinkBankAccountFromYodlee(MSYodleeBankAccLink);
        EXIT(TRUE);
    end;

    procedure UnlinkBankAccountFromYodlee(var MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link");
    var
        CobrandToken: Text;
        ConsumerToken: Text;
        Response: Text;
        ErrorText: Text;
        AccountID: Text;
        AuthorizationHeaderValue: Text;
    begin
        CheckServiceEnabled();
        Authenticate(CobrandToken, ConsumerToken);
        AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken, ConsumerToken);

        AccountID := MSYodleeBankAccLink."Online Bank Account ID";
        ExecuteWebServiceRequest(YodleeAPIStrings.GetUnlinkBankAccountURL(AccountID), YodleeAPIStrings.GetUnlinkBankAccountRequestMethod(),
          YodleeAPIStrings.GetUnlinkBankAccountBody(CobrandToken, ConsumerToken, AccountID), AuthorizationHeaderValue, ErrorText);

        if not GLBResponseInStream.EOS() then
            if not GetResponseValue('/', Response, ErrorText) then begin
                ErrorText := GetAdjustedErrorText(ErrorText, STRSUBSTNO(FailedAccountUnlinkTxt, MSYodleeBankAccLink."No."));
                LogActivityFailed(
                GetUnlinkAccountTxt,
                ErrorText, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, GetUnlinkAccountTxt, ErrorText), Verbosity::Error);
            end;

        LogActivitySucceed(
          GetUnlinkAccountTxt,
          SuccessAccountUnlinkTxt, StrSubstNo(TelemetryActivitySuccessTxt, GetUnlinkAccountTxt, SuccessAccountUnlinkTxt));

        MarkBankAccountAsUnlinked(MSYodleeBankAccLink."No.");

        IF MSYodleeBankAccLink.ISTEMPORARY() THEN
            MSYodleeBankAccLink.DELETE(TRUE)
    end;

    [Scope('OnPrem')]
    procedure UnregisterConsumer(): Boolean;
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        CobrandToken: Text;
        ConsumerToken: Text;
        Response: Text;
        ErrorText: Text;
        AuthorizationHeaderValue: Text;
    begin
        MSYodleeBankServiceSetup.GET();

        IF NOT MSYodleeBankServiceSetup."Accept Terms of Use" THEN
            EXIT(FALSE); // Keep data.

        Authenticate(CobrandToken, ConsumerToken);

        AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken, ConsumerToken);
        ExecuteWebServiceRequest(YodleeAPIStrings.GetRemoveConsumerURL(), YodleeAPIStrings.GetRemoveConsumerRequestMethod(),
          YodleeAPIStrings.GetRemoveConsumerRequestBody(CobrandToken, ConsumerToken), AuthorizationHeaderValue, ErrorText);

        IF NOT GetResponseValue('/', Response, ErrorText) THEN BEGIN
            LogActivityFailed(RemoveConsumerTxt, ErrorText, FailureAction::IgnoreError, '', StrSubstNo(TelemetryActivityFailureTxt, RemoveConsumerTxt, ErrorText), Verbosity::Error);

            // We may be ignoring errors so we should still remove data if the consumer account is invalid (i.e. we could not get a valid consumer token)
            IF (CobrandToken <> '') AND (ConsumerToken <> '') THEN BEGIN
                IF GUIALLOWED() THEN
                    MESSAGE(FailedRemoveConsumerMsg); // Notify user - no error as we don't want to rollback if we get this far.
                EXIT(FALSE); // Keep data so support can debug issue/decrease chance of creating orphaned accounts.
            END;
        END;

        LogActivitySucceed(RemoveConsumerTxt, SuccessRemoveConsumerTxt, StrSubstNo(TelemetryActivitySuccessTxt, RemoveConsumerTxt, SuccessRemoveConsumerTxt));

        MSYodleeBankAccLink.DELETEALL(TRUE);

        // Update Setup
        MSYodleeBankServiceSetup.DeleteFromIsolatedStorage(MSYodleeBankServiceSetup."Consumer Password");

        MSYodleeBankServiceSetup.GET();
        CLEAR(MSYodleeBankServiceSetup."Consumer Password");
        CLEAR(MSYodleeBankServiceSetup."Consumer Name");
        MSYodleeBankServiceSetup.MODIFY(TRUE);
        StoreConsumerName('');

        EXIT(TRUE);
    end;

    procedure RegisterConsumer(var Username: Text[250]; var Password: Text; var ErrorText: Text; CobrandToken: Text): Boolean;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        PasswordHelper: Codeunit "Password Helper";
        Response: Text;
        LcyCode: Text;
        Email: Text;
        AuthorizationHeaderValue: Text;
        AlphanumericCharsTxt: Text;
    begin
        AlphanumericCharsTxt := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        CheckServiceEnabled();
        Username := DelChr(CompanyName(), '=', DelChr(CompanyName(), '=', AlphanumericCharsTxt)) + '_' + FORMAT(CREATEGUID());

        GeneralLedgerSetup.GET();
        GeneralLedgerSetup.TESTFIELD("LCY Code");
        LcyCode := GeneralLedgerSetup."LCY Code";

        MSYodleeBankServiceSetup.GET();
        Email := MSYodleeBankServiceSetup."User Profile Email Address";
        Password := COPYSTR(PasswordHelper.GeneratePassword(50), 1, 50);

        AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken, '');
        Session.LogMessage('0000DL9', StrSubstNo(StartingToRegisterUserTxt, UserName, LcyCode), Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
        ExecuteWebServiceRequest(YodleeAPIStrings.GetRegisterConsumerURL(), 'POST',
            YodleeAPIStrings.GetRegisterConsumerBody(CobrandToken, UserName, Password, Email, LcyCode), AuthorizationHeaderValue,
            ErrorText);

        IF NOT GetResponseValue('/', Response, ErrorText) THEN BEGIN
            ErrorText := GetAdjustedErrorText(ErrorText, FailedRegisterConsumerTxt);
            IF IsStaleCredentialsErr(ErrorText) THEN BEGIN
                ErrorText := StaleCredentialsErr;
                LogActivityFailed(RegisterConsumerTxt, ErrorText, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, RegisterConsumerTxt, ErrorText), Verbosity::Warning);
                EXIT(FALSE);
            END;
            IF ErrorText.Contains(BankStmtServiceStaleIllegalArgumentValueExceptionTxt) THEN BEGIN
                ErrorText := RegisterConsumerVerifyLCYCodeTxt;
                LogActivityFailed(RegisterConsumerTxt, ErrorText, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, RegisterConsumerTxt, ErrorText), Verbosity::Warning);
            END ELSE
                LogActivityFailed(RegisterConsumerTxt, ErrorText, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, RegisterConsumerTxt, ErrorText), Verbosity::Error);

            EXIT(FALSE);
        END;

        LogActivitySucceed(RegisterConsumerTxt, SuccessRegisterConsumerTxt, StrSubstNo(TelemetryActivitySuccessTxt, RegisterConsumerTxt, SuccessRegisterConsumerTxt));

        MSYodleeBankServiceSetup.VALIDATE("Consumer Name", COPYSTR(Username, 1, MAXSTRLEN(MSYodleeBankServiceSetup."Consumer Name")));
        MSYodleeBankServiceSetup.SaveConsumerPassword(MSYodleeBankServiceSetup."Consumer Password", Password);
        MSYodleeBankServiceSetup.MODIFY(TRUE);
        StoreConsumerName(MSYodleeBankServiceSetup."Consumer Name");
        EXIT(TRUE);
    end;

    local procedure TryGetLinkedSites(var SiteListXML: Text; CobrandToken: Text; ConsumerToken: Text): Boolean;
    var
        ErrorText: Text;
        AuthorizationHeaderValue: Text;
    begin
        AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken, ConsumerToken);
        ExecuteWebServiceRequest(YodleeAPIStrings.GetLinkedSiteListURL(), YodleeAPIStrings.GetLinkedSiteListRequestMethod(),
          YodleeAPIStrings.GetLinkedSiteListBody(CobrandToken, ConsumerToken), AuthorizationHeaderValue, ErrorText);

        EXIT(GetResponseValue(YodleeAPIStrings.GetRootXPath(), SiteListXML, ErrorText));
    end;

    local procedure GetLinkedSites(): Text;
    var
        SiteListXML: Text;
        CobrandToken: Text;
        ConsumerToken: Text;
    begin
        CheckServiceEnabled();
        Authenticate(CobrandToken, ConsumerToken);
        IF NOT TryGetLinkedSites(SiteListXML, CobrandToken, ConsumerToken) THEN
            LogActivityFailed(GetBankSiteListTxt, CannotGetLinkedAccountsErr, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, GetBankSiteListTxt, CannotGetLinkedAccountsErr), Verbosity::Warning);
        LogActivitySucceed(GetBankSiteListTxt, SuccessTxt, StrSubstNo(TelemetryActivitySuccessTxt, GetBankSiteListTxt, SuccessTxt));
        EXIT(SiteListXML);
    end;

    procedure UpdateBankAccountLinking(var BankAccount: Record "Bank Account"; ForceManualLinking: Boolean);
    var
        TempMissingMSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link" temporary;
        SiteListXML: Text;
        Summary: Text;
        UnlinkedAccounts: Integer;
        LinkedAccounts: Integer;
    begin
        CheckServiceEnabled();

        SiteListXML := GetLinkedSites();
        UnlinkedAccounts := MatchBankAccountIDs(SiteListXML, TempMissingMSYodleeBankAccLink);
        LinkedAccounts := CreateNewAccountLinking(BankAccount, TempMissingMSYodleeBankAccLink, ForceManualLinking);

        Summary := GetLinkingSummaryMessage(LinkedAccounts, UnlinkedAccounts, ForceManualLinking, TempMissingMSYodleeBankAccLink);
        IF Summary <> '' THEN
            MESSAGE(Summary);
    end;

    local procedure GetLinkedBankAccountsFromSite(ProviderAccountId: Text; var AccountsNode: XmlNode);
    var
        CobrandToken: Text;
        ConsumerToken: Text;
        BankAccountXML: Text;
        ErrorText: Text;
        AuthorizationHeaderValue: Text;
    begin
        CheckServiceEnabled();
        Authenticate(CobrandToken, ConsumerToken);
        AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken, ConsumerToken);
        Session.LogMessage('00006PN', ProviderAccountId, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
        ExecuteWebServiceRequest(YodleeAPIStrings.GetLinkedBankAccountsURL(ProviderAccountId), YodleeAPIStrings.GetLinkedBankAccountsRequestMethod(),
          YodleeAPIStrings.GetLinkedBankAccountsBody(CobrandToken, ConsumerToken, ProviderAccountId), AuthorizationHeaderValue, ErrorText);

        IF ErrorText <> '' THEN BEGIN
            LogActivityFailed(
              GetBankAccListTxt, ErrorText, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, GetBankAccListTxt, ErrorText), Verbosity::Error);
            ERROR(ErrorText);
        END;

        IF NOT GetResponseValue(YodleeAPIStrings.GetRootXPath(), BankAccountXML, ErrorText) THEN
            IF IsStaleCredentialsErr(ErrorText) THEN BEGIN
                ErrorText := StaleCredentialsErr;
                LogActivityFailed(GetBankAccListTxt, GetAdjustedErrorText(STRSUBSTNO(FailedToFindAccountTxt, ProviderAccountId), ErrorText), FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, GetBankAccListTxt, GetAdjustedErrorText(STRSUBSTNO(FailedToFindAccountTxt, ProviderAccountId), ErrorText)), Verbosity::Warning);
            END ELSE
                LogActivityFailed(GetBankAccListTxt, GetAdjustedErrorText(STRSUBSTNO(FailedToFindAccountTxt, ProviderAccountId), ErrorText), FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, GetBankAccListTxt, GetAdjustedErrorText(STRSUBSTNO(FailedToFindAccountTxt, ProviderAccountId), ErrorText)), Verbosity::Error);

        LogActivitySucceed(GetBankAccListTxt, STRSUBSTNO(SuccessToFindAccountTxt, ProviderAccountId), StrSubstNo(TelemetryActivitySuccessTxt, GetBankAccListTxt, STRSUBSTNO(SuccessToFindAccountTxt, ProviderAccountId)));

        LoadXMLNodeFromText(BankAccountXML, AccountsNode);
    end;

    local procedure GetLinkedBankAccount(AccountId: Text; var AccountNode: XmlNode);
    var
        CobrandToken: Text;
        ConsumerToken: Text;
        BankAccountXML: Text;
        ErrorText: Text;
        AuthorizationHeaderValue: Text;
    begin
        CheckServiceEnabled();
        Authenticate(CobrandToken, ConsumerToken);
        AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken, ConsumerToken);
        ExecuteWebServiceRequest(YodleeAPIStrings.GetLinkedBankAccountURL(AccountId), 'GET',
          '', AuthorizationHeaderValue, ErrorText);

        IF ErrorText <> '' THEN BEGIN
            LogActivityFailed(
              GetBankAccTxt, ErrorText, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, GetBankAccTxt, ErrorText), Verbosity::Error);
            ERROR(ErrorText);
        END;

        IF NOT GetResponseValue(YodleeAPIStrings.GetRootXPath(), BankAccountXML, ErrorText) THEN
            IF IsStaleCredentialsErr(ErrorText) THEN BEGIN
                ErrorText := StaleCredentialsErr;
                LogActivityFailed(GetBankAccTxt, GetAdjustedErrorText(STRSUBSTNO(FailedToFindAccountTxt, AccountId), ErrorText), FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, GetBankAccTxt, GetAdjustedErrorText(STRSUBSTNO(FailedToFindAccountTxt, AccountId), ErrorText)), Verbosity::Warning);
            END ELSE
                LogActivityFailed(GetBankAccTxt, GetAdjustedErrorText(STRSUBSTNO(FailedToFindAccountTxt, AccountId), ErrorText), FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, GetBankAccTxt, GetAdjustedErrorText(STRSUBSTNO(FailedToFindAccountTxt, AccountId), ErrorText)), Verbosity::Error);

        LogActivitySucceed(GetBankAccListTxt, STRSUBSTNO(SuccessToFindAccountTxt, AccountId), StrSubstNo(TelemetryActivitySuccessTxt, GetBankAccTxt, STRSUBSTNO(SuccessToFindAccountTxt, AccountId)));

        LoadXMLNodeFromText(BankAccountXML, AccountNode);
    end;

    procedure LazyBankDataRefresh(OnlineBankId: Text; OnlineBankAccountId: Text; ToDate: Date);
    var
        AccountNode: XmlNode;
        RefreshMode: Text;
    begin
        IF NOT VerifyRefreshBankData(OnlineBankId, OnlineBankAccountId, ToDate, AccountNode) THEN BEGIN
            IF IsAutomaticLogonPossible(OnlineBankAccountId) THEN
                EXIT;

            RefreshMode := 'MFA';
            Session.LogMessage('000023V', STRSUBSTNO(RefreshingBankAccountTelemetryTxt, OnlineBankId, RefreshMode), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            MFABankDataRefresh(OnlineBankId, OnlineBankAccountId);

            IF NOT VerifyRefreshBankData(OnlineBankId, OnlineBankAccountId, ToDate, AccountNode) THEN
                MESSAGE(STRSUBSTNO(RefreshMsg, GetRefreshBankDate(OnlineBankId, OnlineBankAccountId, AccountNode)));
        END;
    end;

    local procedure MFABankDataRefresh(OnlineBankId: Text; OnlineBankAccountId: Text);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        CheckServiceEnabled();

        MSYodleeBankAccLink.SETRANGE("Online Bank Account ID", OnlineBankAccountId);
        MSYodleeBankAccLink.FINDFIRST();

        COMMIT();
        PAGE.RUNMODAL(PAGE::"MS - Yodlee Get Latest Stmt", MSYodleeBankAccLink);

        PollRefreshBankDataState(OnlineBankId, OnlineBankAccountId);
    end;

    local procedure OnlineBankAccountAccessConsent(OnlineBankAccountId: Text);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        CheckServiceEnabled();

        MSYodleeBankAccLink.SETRANGE("Online Bank Account ID", OnlineBankAccountId);
        MSYodleeBankAccLink.FINDFIRST();

        COMMIT();
        PAGE.RUNMODAL(PAGE::"MS - Yodlee Access Consent", MSYodleeBankAccLink);
    end;

    local procedure OnlineBankAccountEdit(OnlineBankAccountId: Text);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        CheckServiceEnabled();

        MSYodleeBankAccLink.SETRANGE("Online Bank Account ID", OnlineBankAccountId);
        MSYodleeBankAccLink.FINDFIRST();

        COMMIT();
        PAGE.RUNMODAL(PAGE::"MS - Yodlee Edit Account", MSYodleeBankAccLink);
    end;

    local procedure PollRefreshBankDataState(OnlineBankId: Text; OnlineBankAccountId: Text);
    var
        Iterations: Integer;
        SecondsToGo: Integer;
        ProgressDialog: Dialog;
    begin
        Iterations := 0;
        SecondsToGo := 90;
        ProgressDialog.Open(ProgressWindowMsg);
        ProgressDialog.Update(1, StrSubstNo(ProgressWindowUpdateTxt, SecondsToGo));
        // loop for max one minute and a half
        REPEAT
            SLEEP(3000);
            Iterations += 1;
            SecondsToGo -= 3;
            ProgressDialog.Update(1, StrSubstNo(ProgressWindowUpdateTxt, SecondsToGo));
        UNTIL RefreshDone(OnlineBankAccountId) OR (Iterations > 30);
        ProgressDialog.Close();

        IF Iterations > 30 THEN BEGIN
            Session.LogMessage('00008OE', STRSUBSTNO(RefreshingBankAccountsTooLongTelemetryTxt, OnlineBankId), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            MESSAGE(RefreshTakingTooLongTxt);
        END;
    end;

    local procedure RefreshDone(OnlineBankAccountId: Text): Boolean;
    begin
        exit(RefreshBankAccountDone(OnlineBankAccountId));
    end;

    local procedure RefreshBankAccountDone(OnlineBankAccountId: Text): Boolean;
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        AccountNode: XmlNode;
        DatasetRefreshStatus: Text;
        ExtraComment: Text;
        ErrorText: Text;
        EmittedError: Text;
    begin
        GetLinkedBankAccount(OnlineBankAccountID, AccountNode);
        DatasetRefreshStatus := FindNodeText(AccountNode, '/root/root/account/dataset[./name/text()=''BASIC_AGG_DATA'']/additionalStatus');

        if DatasetRefreshStatus in ['LOGIN_IN_PROGRESS', 'DATA_RETRIEVAL_IN_PROGRESS', 'ACCT_SUMMARY_RECEIVED', ''] then
            exit(false);

        if DatasetRefreshStatus = 'AVAILABLE_DATA_RETRIEVED' then begin
            LogActivitySucceed(BankRefreshTxt, SuccessTxt, StrSubstNo(TelemetryActivitySuccessTxt, BankRefreshTxt, SuccessTxt));
            exit(true);
        end;

        if DatasetRefreshStatus in ['DATA_RETRIEVAL_FAILED', 'PARTIAL_DATA_RETRIEVED'] then begin
            LogActivityFailed(BankRefreshTxt, CredentialsCommentTxt, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, BankRefreshTxt, CredentialsCommentTxt), Verbosity::Warning);
            exit(true);
        end;

        ExtraComment := UserFriendlyRefreshErrorMessage(DatasetRefreshStatus);
        ErrorText := StrSubstNo(RefreshStatusErr, DatasetRefreshStatus, ExtraComment);
        EmittedError := 'Refresh Code ' + DatasetRefreshStatus;

        if (ExtraComment <> '') then begin
            EmittedError += ':' + ExtraComment;
            LogActivityFailed(BankRefreshTxt, ErrorText, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, BankRefreshTxt, ErrorText), Verbosity::Warning);
        end
        else
            LogActivityFailed(BankRefreshTxt, ErrorText, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, BankRefreshTxt, ErrorText), Verbosity::Error);

        FeatureTelemetry.LogError('0000GYK', 'Yodlee', 'Polling bank data refresh', EmittedError);
        exit(true);
    end;

    local procedure UserFriendlyRefreshErrorMessage(RefreshCode: Text): Text;
    begin
        case RefreshCode of
            '402', 'CREDENTIALS_UPDATE_NEEDED', 'INCORRECT_CREDENTIALS':
                EXIT(BankAccountRefreshInvalidCredentialsTxt);
            '404', 'TECH_ERROR':
                EXIT(BankAccountRefreshUnknownErrorTxt);
            '407', 'ACCOUNT_LOCKED':
                EXIT(BankAccountRefreshAccountLockedTxt);
            '409', 'UNEXPECTED_SITE_ERROR', 'SITE_UNAVAILABLE':
                EXIT(BankAccountRefreshBankDownTxt);
            '424':
                EXIT(BankAccountRefreshBankDownForMaintenanceTxt);
            '507', 'BETA_SITE_DEV_IN_PROGRESS':
                EXIT(BankAccountRefreshBankInBetaMaintenanceTxt);
            '508', 'REQUEST_TIME_OUT', 'SITE_SESSION_INVALIDATED':
                EXIT(BankAccountRefreshTimedOutTxt);
            '518', '519', '520', '522', '523', '524', '526', 'ADDL_AUTHENTICATION_REQUIRED', 'INVALID_ADDL_INFO_PROVIDED', 'NEW_AUTHENTICATION_REQUIRED':
                EXIT(BankAccountRefreshAdditionalAuthInfoNeededTxt);
        end;
        EXIT('');
    end;

    local procedure VerifyRefreshBankData(OnlineBankID: Text; OnlineBankAccountID: Text; TargetDate: Date; var AccountNode: XmlNode): Boolean;
    var
        RefreshDateTime: DateTime;
    begin
        RefreshDateTime := GetRefreshBankDate(OnlineBankID, OnlineBankAccountID, AccountNode);

        EXIT(RefreshDateTime > CREATEDATETIME(TargetDate, 0T)); // True if refreshed data is newer than the target date
    end;

    local procedure GetRefreshBankDate(OnlineBankID: Text; OnlineBankAccountID: Text; var AccountNode: XmlNode): DateTime;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        RefreshDateTime: DateTime;
        RefreshDateTimeTxt: Text;
        ProviderId: Text;
        ProviderName: Text;
    begin
        CheckServiceEnabled();
        GetLinkedBankAccount(OnlineBankAccountID, AccountNode);
        ProviderName := FindNodeText(AccountNode, '/root/root/account/providerName');
        ProviderId := FindNodeText(AccountNode, '/root/root/account/providerId');
        Session.LogMessage('0000A07', ProviderName, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
        Session.LogMessage('0000A08', ProviderId, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
        if MSYodleeBankServiceSetup.Get() then
            Session.LogMessage('0000F76', MSYodleeBankServiceSetup."Consumer Name", Verbosity::Normal, DataClassification::OrganizationIdentifiableInformation, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
        Session.LogMessage('00006PN', OnlineBankID, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
        RefreshDateTimeTxt := FindNodeText(AccountNode, '/root/root/account/lastUpdated');
        if Evaluate(RefreshDateTime, RefreshDateTimeTxt, 9) then;

        exit(RefreshDateTime);
    end;

    local procedure IsAutomaticLogonPossible(OnlineBankAccountID: Text): Boolean;
    var
        OnlineBankAccountNode: XmlNode;
        AutoRefreshStatus: Text;
        AutoRefreshAdditionalStatus: Text;
    begin
        GetLinkedBankAccount(OnlineBankAccountID, OnlineBankAccountNode);
        AutoRefreshStatus := FindNodeText(OnlineBankAccountNode, '/root/root/account/autoRefresh/status');
        AutoRefreshAdditionalStatus := FindNodeText(OnlineBankAccountNode, '/root/root/account/autoRefresh/additionalStatus');
        exit((AutoRefreshStatus = 'ENABLED') and (AutoRefreshAdditionalStatus = 'SCHEDULED'));
    end;

    procedure FindNodeText(Node: XmlNode; NodePath: Text): Text;
    var
        RootElement: XmlElement;
        FoundXmlNode: XmlNode;
    begin
        IF Node.SelectSingleNode(NodePath, FoundXmlNode) THEN BEGIN
            IF FoundXmlNode.IsXmlElement() THEN
                EXIT(FoundXmlNode.AsXmlElement().InnerText());

            IF FoundXmlNode.IsXmlDocument() THEN BEGIN
                FoundXmlNode.AsXmlDocument().GetRoot(RootElement);
                EXIT(RootElement.InnerText());
            END;
        END;

        EXIT('');
    end;

    local procedure FindNodeXML(Node: XmlNode; NodePath: Text): Text;
    var
        RootElement: XmlElement;
        FoundXmlNode: XmlNode;
    begin
        IF Node.SelectSingleNode(NodePath, FoundXmlNode) THEN BEGIN
            IF FoundXmlNode.IsXmlElement() THEN
                EXIT(FoundXmlNode.AsXmlElement().InnerXml());

            IF FoundXmlNode.IsXmlDocument() THEN BEGIN
                FoundXmlNode.AsXmlDocument().GetRoot(RootElement);
                EXIT(RootElement.InnerXml());
            END;
        END;

        EXIT('');
    end;

    local procedure LoadXMLNodeFromtext(Txt: Text; var Node: XmlNode);
    var
        XmlDoc: XmlDocument;
        XmlElem: XmlElement;
    begin
        RemoveInvalidXMLCharacters(Txt);
        XmlDocument.ReadFrom(Txt, XmlDoc);
        XmlDoc.GetRoot(XmlElem);
        Node := XmlElem.AsXmlNode();
    end;

    local procedure GetTransactions(OnlineBankAccountId: Text; FromDate: Date; ToDate: Date);
    var
        CobrandToken: Text;
        ConsumerToken: Text;
        ErrorText: Text;
        AuthorizationHeaderValue: Text;
        PaginationLink: Text;
    begin
        CheckServiceEnabled();
        Authenticate(CobrandToken, ConsumerToken);
        AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken, ConsumerToken);

        // empty the list of bank feed responses
        // the call(s) below will populate it with new response(s)
        if BankFeedTextList.Count() > 0 then
            BankFeedTextList.RemoveRange(1, BankFeedTextList.Count());

        PaginationLink := ExecuteWebServiceRequest(
            YodleeAPIStrings.GetTransactionSearchURL(OnlineBankAccountId, FromDate, ToDate),
            YodleeAPIStrings.GetTransactionSearchRequestMethod(),
            YodleeAPIStrings.GetTransactionSearchBody(CobrandToken, ConsumerToken, OnlineBankAccountId, FromDate, ToDate),
            AuthorizationHeaderValue,
            ErrorText);

        // keep requesting more transactions until there is no more pagination link in the response header
        while PaginationLink <> '' do
            PaginationLink := ExecuteWebServiceRequest(
            PaginationLink,
            YodleeAPIStrings.GetTransactionSearchRequestMethod(),
            YodleeAPIStrings.GetTransactionSearchBody(CobrandToken, ConsumerToken, OnlineBankAccountId, FromDate, ToDate),
            AuthorizationHeaderValue,
            ErrorText);

        Session.LogMessage('00001SX', STRSUBSTNO(TransactionsDownloadedTelemetryTxt, NumberOfLinkedBankAccounts()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
    end;

    local procedure NumberOfLinkedBankAccounts(): Integer;
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        IF NOT MSYodleeBankServiceSetup.GET() THEN
            EXIT(0);
        BankAccount.SETRANGE("Bank Stmt. Service Record ID", MSYodleeBankServiceSetup.RECORDID());
        EXIT(BankAccount.COUNT());
    end;

    local procedure MatchBankAccountIDs(SiteListXML: Text; var MissingTempMSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link" temporary): Integer;
    begin
        exit(MatchBankAccountIDsAPI11(SiteListXML, MissingTempMSYodleeBankAccLink));
    end;

    local procedure MatchBankAccountIDsAPI11(ProviderAccountsXML: Text; var MissingTempMSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link" temporary): Integer;
    var
        TempBankAccount: Record "Bank Account" temporary;
        XmlDoc: XmlDocument;
        ProviderAccountNode: XmlNode;
        BankAccountsRootNode: XmlNode;
        BankAccountsNodeList: XmlNodeList;
        ProviderAccountsNodeList: XmlNodeList;
        XmlRootElement: XmlElement;
        BankAccountNode: XmlNode;
        ProviderAccountId: Text[50];
        BankAccountID: Text[50];
    begin
        XmlDocument.ReadFrom(ProviderAccountsXML, XmlDoc);
        XmlDoc.GetRoot(XmlRootElement);
        CopyLinkedBankAccountsToTemp(TempBankAccount);
        XmlRootElement.SelectNodes(YodleeAPIStrings.GetProviderAccountXPath(), ProviderAccountsNodeList);

        FOREACH ProviderAccountNode IN ProviderAccountsNodeList DO BEGIN
            ProviderAccountId := COPYSTR(FindNodeXML(ProviderAccountNode, YodleeAPIStrings.GetProviderAccountIdXPath()), 1, 50);

            IF ProviderAccountId <> '' THEN BEGIN
                GetLinkedBankAccountsFromSite(ProviderAccountID, BankAccountsRootNode);
                BankAccountsRootNode.SelectNodes(YodleeAPIStrings.GetBankAccountsListXPath(), BankAccountsNodeList);
                FOREACH BankAccountNode IN BankAccountsNodeList DO BEGIN
                    BankAccountID := COPYSTR(FindNodeXML(BankAccountNode, YodleeAPIStrings.GetBankAccountIdXPath()), 1, 50);
                    IF FindMatchingBankAccountId(TempBankAccount, ProviderAccountId, BankAccountID) THEN
                        TempBankAccount.DELETE()
                    ELSE
                        CreateTempBankAccountFromBankStatement(ProviderAccountId, BankAccountID, BankAccountNode, MissingTempMSYodleeBankAccLink);
                END;
            END;
        END;

        EXIT(MarkUnlinkedRemainingBankAccounts(TempBankAccount));
    end;

    local procedure CreateNewAccountLinking(var BankAccount: Record "Bank Account"; var MissingTempMSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link" temporary; ForceManualLinking: Boolean): Integer;
    var
        LinkedAccounts: Integer;
    begin
        LinkedAccounts := MissingTempMSYodleeBankAccLink.COUNT();

        IF LinkedAccounts = 0 THEN
            EXIT(0);

        IF NOT ForceManualLinking THEN
            IF LinkedAccounts = 1 THEN BEGIN
                IF BankAccount."No." <> '' THEN BEGIN
                    IF MarkBankAccountAsLinked(BankAccount."No.", MissingTempMSYodleeBankAccLink) THEN
                        EXIT(1);
                    EXIT(0);
                END;
                IF CreateNewBankAccountFromTemp(BankAccount, MissingTempMSYodleeBankAccLink) THEN
                    EXIT(1);
                EXIT(0);
            END;

        EXIT(LinkNonLinkedBankAccounts(MissingTempMSYodleeBankAccLink, BankAccount));
    end;

    procedure CreateNewBankAccountFromTemp(var BankAccount: Record "Bank Account"; var TempMSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link" temporary): Boolean;
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        BankAccountNo: Code[20];
        Linked: Boolean;
    begin
        TempMSYodleeBankAccLink.CreateBankAccount(BankAccount);

        BankAccountNo := BankAccount."No.";
        MarkBankAccountAsLinked(BankAccountNo, TempMSYodleeBankAccLink);

        COMMIT();
        PAGE.RUNMODAL(PAGE::"Bank Account Card", BankAccount);

        MSYodleeBankAccLink.SetRange("No.", BankAccountNo);
        Linked := not MSYodleeBankAccLink.IsEmpty();
        EXIT(Linked);
    end;

    local procedure LinkNonLinkedBankAccounts(var MissingTempMSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link" temporary; var BankAccount: Record "Bank Account"): Integer;
    begin
        COMMIT();
        PAGE.RUNMODAL(PAGE::"MS - Yodlee NonLinked Accounts", MissingTempMSYodleeBankAccLink);

        MissingTempMSYodleeBankAccLink.RESET();
        MissingTempMSYodleeBankAccLink.SETFILTER("Temp Linked Bank Account No.", '<>%1', '');
        IF MissingTempMSYodleeBankAccLink.FINDFIRST() THEN
            BankAccount.GET(MissingTempMSYodleeBankAccLink."Temp Linked Bank Account No.");

        EXIT(MissingTempMSYodleeBankAccLink.COUNT());
    end;

    local procedure GetLinkingSummaryMessage(LinkedAccounts: Integer; UnlinkedAccounts: Integer; ForceManualLinking: Boolean; var MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link"): Text;
    var
        Summary: Text;
        UnlinkedText: Text;
    begin
        Summary := '';

        IF LinkedAccounts = 1 THEN
            Summary := STRSUBSTNO(AccountLinkingSummaryMsg, MSYodleeBankAccLink.Name);

        IF LinkedAccounts > 1 THEN
            Summary := STRSUBSTNO(AccountsLinkingSummaryMsg, LinkedAccounts);

        IF UnlinkedAccounts > 0 THEN BEGIN
            UnlinkedText := STRSUBSTNO(AccountUnLinkingSummaryMsg, UnlinkedAccounts);
            IF Summary <> '' THEN
                Summary := STRSUBSTNO(ConcatAccountSummaryMsg, Summary, UnlinkedText)
            ELSE
                Summary := UnlinkedText;
        END;

        IF (Summary = '') AND (MSYodleeBankAccLink."Online Bank Account ID" = '') THEN
            IF ForceManualLinking THEN
                Summary := BankAccountsAreLinkedMsg
            ELSE
                Summary := NoNewBankAccountsMsg;

        EXIT(Summary);
    end;

    procedure MarkBankAccountLinked(var BankAccount: Record "Bank Account"; var TempMSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link" temporary): Boolean;
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        BankAccountCurrencyCode: Code[10];
    begin
        MSYodleeBankServiceSetup.GET();
        GeneralLedgerSetup.GET();

        BankAccountCurrencyCode := BankAccount."Currency Code";
        IF BankAccountCurrencyCode = '' THEN
            BankAccountCurrencyCode := GeneralLedgerSetup.GetCurrencyCode(BankAccountCurrencyCode);

        IF (TempMSYodleeBankAccLink."Currency Code" <> '') THEN
            IF (BankAccountCurrencyCode <> TempMSYodleeBankAccLink."Currency Code") THEN
                ERROR(CurrencyMismatchErr, BankAccountCurrencyCode, TempMSYodleeBankAccLink."Currency Code");

        IF (TempMSYodleeBankAccLink."Currency Code" = '') AND (BankAccount."Currency Code" <> '') THEN
            IF NOT CONFIRM(STRSUBSTNO(LinkingToAccountWithEmptyCurrencyQst, TempMSYodleeBankAccLink.Name)) THEN
                EXIT(false);

        BankAccount.VALIDATE("Bank Stmt. Service Record ID", MSYodleeBankServiceSetup.RECORDID());
        // set default value for Transaction Import Timespan (in days)
        IF BankAccount."Transaction Import Timespan" = 0 THEN
            BankAccount."Transaction Import Timespan" := 7;
        BankAccount.MODIFY(TRUE);

        MSYodleeBankAccLink.TRANSFERFIELDS(TempMSYodleeBankAccLink);
        MSYodleeBankAccLink."No." := BankAccount."No.";
        MSYodleeBankAccLink.INSERT();

        LogActivitySucceed(STRSUBSTNO(LinkBankAccountTxt, BankAccount."No."), SuccessTxt, StrSubstNo(TelemetryActivitySuccessTxt, LinkBankAccountTxt, SuccessTxt));
        EXIT(true);
    end;

    procedure MarkBankAccountAsLinked(BankAccountNo: Code[20]; var TempMSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link" temporary): Boolean;
    var
        BankAccount: Record "Bank Account";
    begin
        BankAccount.GET(BankAccountNo);
        IF NOT MarkBankAccountLinked(BankAccount, TempMSYodleeBankAccLink) THEN
            EXIT(false);

        TempMSYodleeBankAccLink."Temp Linked Bank Account No." := BankAccount."No.";
        TempMSYodleeBankAccLink.MODIFY();
        EXIT(True);
    end;

    procedure MarkBankAccountAsUnlinked(BankAccountNo: Code[20]);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        BankAccount: Record "Bank Account";
    begin
        IF MSYodleeBankAccLink.GET(BankAccountNo) THEN
            MSYodleeBankAccLink.DELETE(TRUE);

        IF BankAccount.GET(BankAccountNo) THEN BEGIN
            CLEAR(BankAccount."Bank Stmt. Service Record ID");
            IF BankAccount."Automatic Stmt. Import Enabled" THEN
                BankAccount.VALIDATE("Automatic Stmt. Import Enabled", FALSE);
            BankAccount.MODIFY(TRUE);
            LogActivitySucceed(STRSUBSTNO(UnlinkBankAccountTxt, BankAccount."No."), SuccessTxt, StrSubstNo(TelemetryActivitySuccessTxt, UnLinkBankAccountTxt, SuccessTxt));
        END;
    end;

    local procedure MarkUnlinkedRemainingBankAccounts(var TempBankAccount: Record "Bank Account" temporary): Integer;
    begin
        TempBankAccount.RESET();
        IF TempBankAccount.FINDSET() THEN
            REPEAT
                MarkBankAccountAsUnlinked(TempBankAccount."No.");
            UNTIL TempBankAccount.NEXT() = 0;
        EXIT(TempBankAccount.COUNT());
    end;

    local procedure FindMatchingBankAccountId(var TempBankAccount: Record "Bank Account" temporary; SiteID: Text; BankAccountID: Text): Boolean;
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        IF (SiteID = '') OR (BankAccountID = '') THEN
            EXIT(FALSE);

        MSYodleeBankAccLink.SETRANGE("Online Bank Account ID", BankAccountID);
        MSYodleeBankAccLink.SETRANGE("Online Bank ID", SiteID);
        IF NOT MSYodleeBankAccLink.FINDFIRST() THEN
            EXIT(FALSE);
        EXIT(TempBankAccount.GET(MSYodleeBankAccLink."No."));
    end;

    local procedure CreateTempBankAccountFromBankStatement(SiteID: Text; BankAccountID: Text; BankAccountNode: XmlNode; var TempMSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link" temporary);
    var
        CurrBalCurrencyCode: Text;
        AvlblBalCurrencyCode: Text;
        RunningBalanceCurrencyCode: Text;
        CurrencyCode: Text;
        BankAccountName: Text;
    begin
        IF (SiteID = '') OR (BankAccountID = '') THEN
            EXIT;

        TempMSYodleeBankAccLink.INIT();

        TempMSYodleeBankAccLink."No." := COPYSTR(BankAccountID, 1, MAXSTRLEN(TempMSYodleeBankAccLink."No."));

        TempMSYodleeBankAccLink."Online Bank Account ID" :=
          COPYSTR(BankAccountID, 1, MAXSTRLEN(TempMSYodleeBankAccLink."Online Bank Account ID"));

        BankAccountName := GetBankAccountName(BankAccountNode);

        TempMSYodleeBankAccLink.Name :=
          COPYSTR(
            BankAccountName, 1,
            MAXSTRLEN(TempMSYodleeBankAccLink.Name));

        TempMSYodleeBankAccLink."Bank Account No." :=
          COPYSTR(
            FindNodeText(BankAccountNode, './accountNumber'), 1, MAXSTRLEN(TempMSYodleeBankAccLink."Bank Account No."));

        CurrBalCurrencyCode := FindNodeText(BankAccountNode, YodleeAPIStrings.GetBankAccountCurrentBalanceXPath());
        AvlblBalCurrencyCode := FindNodeText(BankAccountNode, YodleeAPIStrings.GetBankAccountAvailableBalanceXPath());
        RunningBalanceCurrencyCode := FindNodeText(BankAccountNode, YodleeAPIStrings.GetBankAccountRunningBalanceXPath());

        IF RunningBalanceCurrencyCode <> '' THEN
            CurrencyCode := RunningBalanceCurrencyCode;

        IF (CurrencyCode = '') AND (CurrBalCurrencyCode <> '') THEN
            CurrencyCode := CurrBalCurrencyCode;

        IF (CurrencyCode = '') AND (AvlblBalCurrencyCode <> '') THEN
            CurrencyCode := AvlblBalCurrencyCode;

        IF CurrencyCode = '' THEN
            OnOnlineAccountEmptyCurrencySendTelemetry(EmptyCurrencyOnOnlineAccountMsg);

        TempMSYodleeBankAccLink."Currency Code" :=
          COPYSTR(
            CurrencyCode, 1,
            MAXSTRLEN(TempMSYodleeBankAccLink."Currency Code"));

        TempMSYodleeBankAccLink.Contact :=
          COPYSTR(FindNodeText(BankAccountNode, YodleeAPIStrings.GetBankAccountHolderNameXPath()), 1, MAXSTRLEN(TempMSYodleeBankAccLink.Contact));

        TempMSYodleeBankAccLink."Online Bank ID" :=
          COPYSTR(SiteID, 1, MAXSTRLEN(TempMSYodleeBankAccLink."Online Bank ID"));

        TempMSYodleeBankAccLink."Automatic Logon Possible" :=
          IsAutomaticLogonPossible(BankAccountID);

        IF NOT TempMSYodleeBankAccLink.INSERT() THEN
            Session.LogMessage('0000BI8', StrSubstNo(UnableToInsertUnlinkedBankAccToBufferErr, TempMSYodleeBankAccLink."Online Bank ID", TempMSYodleeBankAccLink."No."), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
    end;

    local procedure GetBankAccountName(BankAccountNode: XmlNode): Text;
    begin
        exit(StrSubstNo(BankAccountNameDisplayLbl, FindNodeText(BankAccountNode, YodleeAPIStrings.GetProviderNameXPath()), FindNodeText(BankAccountNode, YodleeAPIStrings.GetBankAccountNameXPath())));
    end;

    local procedure VerifyTermsOfUseAccepted();
    var
        ErrorText: Text;
    begin
        IF NOT TryVerifyTermsOfUseAccepted(ErrorText) THEN
            ERROR(ErrorText);
    end;

    local procedure TryVerifyTermsOfUseAccepted(var ErrorText: Text): Boolean;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        MSYodleeBankServiceSetup.GET();
        IF MSYodleeBankServiceSetup."Accept Terms of Use" THEN
            EXIT(TRUE);

        IF NOT GUIALLOWED() THEN BEGIN
            ErrorText := TermsOfUseNotAcceptedErr;
            EXIT(FALSE);
        END;

        PAGE.RUNMODAL(PAGE::"MS - Yodlee Terms of use");

        MSYodleeBankServiceSetup.GET();

        IF NOT MSYodleeBankServiceSetup."Accept Terms of Use" THEN BEGIN
            ErrorText := TermsOfUseNotAcceptedErr;
            EXIT(FALSE);
        END;

        EXIT(TRUE);
    end;

    local procedure GetResponseValue(XPath: Text; var Response: Text; var ErrorText: Text): Boolean;
    var
        MSYodleeBankSession: Record "MS - Yodlee Bank Session";
        TempBlob: Codeunit "Temp Blob";
        Success: Boolean;
    begin
        Success := TryGetResponseValue(XPath, Response, TempBlob, ErrorText);
        IF Success THEN
            EXIT(TRUE);
        IF ErrorText = StaleCredentialsErr THEN
            MSYodleeBankSession.ResetSessionTokens();
        EXIT(FALSE);
    end;

    local procedure TryGetResponseValue(XPath: Text; var Response: Text; var TempBlob: Codeunit "Temp Blob"; var ErrorText: Text): Boolean;
    var
        GetJsonStructure: Codeunit "Get Json Structure";
        XmlInStream: InStream;
        OutStream: OutStream;
        XMLRootNode: XmlNode;
        XmlDoc: XmlDocument;
        XmlElem: XmlElement;
        XmlResponseText: Text;
        InStreamText: Text;
    begin
        // response 204 has no content, so empty response is fine
        if GLBResponseInStream.EOS() then
            exit(true);

        TempBlob.CreateOutStream(OutStream);
        IF NOT GetJsonStructure.JsonToXMLCreateDefaultRoot(GLBResponseInStream, OutStream) THEN BEGIN
            ErrorText := InvalidResponseErr;
            EXIT(FALSE);
        END;

        TempBlob.CreateInStream(XmlInStream);
        while not XmlInStream.EOS() do begin
            XmlInStream.ReadText(InStreamText);
            XmlResponseText += InStreamText;
        end;

        RemoveInvalidXMLCharacters(XmlResponseText);
        XmlDocument.ReadFrom(XmlResponseText, XmlDoc);
        XmlDoc.GetRoot(XmlElem);
        XMLRootNode := XmlElem.AsXmlNode();

        IF NOT CheckForErrors(XMLRootNode, ErrorText) THEN
            EXIT(FALSE);

        IF XPath = YodleeAPIStrings.GetRootXPath() then
            XmlDoc.WriteTo(Response)
        else
            Response := FindNodeXML(XMLRootNode, XPath);
        EXIT(TRUE);
    end;

    [TryFunction]
    local procedure TryVerifyXMLChars(InputText: Text)
    var
        "System.Xml.XmlConvert": DotNet XmlConvert;
    begin
        "System.Xml.XmlConvert".VerifyXmlChars(InputText);
    end;

    local procedure RemoveInvalidXMLCharacters(var InputText: Text)
    var
        "System.Xml.XmlConvert": DotNet XmlConvert;
        "System.String": DotNet String;
        Character: Char;
    begin
        if not TryVerifyXMLChars(InputText) then begin
            "System.String" := InputText;
            InputText := '';
            foreach Character in "System.String" do
                if "System.Xml.XmlConvert".IsXmlChar(Character) then
                    InputText += Character;
        end;
        // so far, in icms we have only seen Char x014 coming from Yodlee
        // therefore remove this one first and continue only if there are more
        InputText := InputText.Replace('&#x14', '');
        if StrPos(InputText, '&#x') = 0 then
            exit;

        InputText := InputText.Replace('&#x00', '');
        InputText := InputText.Replace('&#x01', '');
        InputText := InputText.Replace('&#x02', '');
        InputText := InputText.Replace('&#x03', '');
        InputText := InputText.Replace('&#x04', '');
        InputText := InputText.Replace('&#x05', '');
        InputText := InputText.Replace('&#x06', '');
        InputText := InputText.Replace('&#x07', '');
        InputText := InputText.Replace('&#x08', '');
        InputText := InputText.Replace('&#x0B', '');
        InputText := InputText.Replace('&#x0C', '');
        InputText := InputText.Replace('&#x0E', '');
        InputText := InputText.Replace('&#x0F', '');
        InputText := InputText.Replace('&#x10', '');
        InputText := InputText.Replace('&#x11', '');
        InputText := InputText.Replace('&#x12', '');
        InputText := InputText.Replace('&#x13', '');
        InputText := InputText.Replace('&#x15', '');
        InputText := InputText.Replace('&#x16', '');
        InputText := InputText.Replace('&#x17', '');
        InputText := InputText.Replace('&#x18', '');
        InputText := InputText.Replace('&#x19', '');
        InputText := InputText.Replace('&#x1A', '');
        InputText := InputText.Replace('&#x1B', '');
        InputText := InputText.Replace('&#x1C', '');
        InputText := InputText.Replace('&#x1D', '');
        InputText := InputText.Replace('&#x1E', '');
        InputText := InputText.Replace('&#x1F', '');
    end;

    local procedure CopyLinkedBankAccountsToTemp(var TempBankAccount: Record "Bank Account" temporary);
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        IF MSYodleeBankAccLink.FINDSET() THEN
            REPEAT
                IF BankAccount.GET(MSYodleeBankAccLink."No.") THEN BEGIN
                    TempBankAccount := BankAccount;
                    TempBankAccount.INSERT();
                END;
            UNTIL MSYodleeBankAccLink.NEXT() = 0;
    end;

    local procedure TryCheckCredentials(var ErrorText: Text): Boolean;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        IF HasCustomCredentialsInAzureKeyVault() THEN
            EXIT(TRUE);

        IF NOT MSYodleeBankServiceSetup.GET() OR
           NOT MSYodleeBankServiceSetup.HasCobrandPassword(MSYodleeBankServiceSetup."Cobrand Password")
        THEN
            IF NOT GLBSetupPageIsCallee AND GUIALLOWED() THEN BEGIN
                IF CONFIRM(MissingCredentialsQst, TRUE) THEN BEGIN
                    COMMIT();
                    PAGE.RUNMODAL(PAGE::"MS - Yodlee Bank Service Setup", MSYodleeBankServiceSetup);
                    IF NOT MSYodleeBankServiceSetup.GET() OR
                       NOT MSYodleeBankServiceSetup.HasCobrandPassword(MSYodleeBankServiceSetup."Cobrand Password")
                    THEN
                        ErrorText := MissingCredentialsErr;
                END ELSE
                    ErrorText := MissingCredentialsErr;
            END ELSE
                ErrorText := MissingCredentialsErr;

        EXIT(ErrorText = '');
    end;

    local procedure UrlIsBankStatementImport(URL: Text): Boolean
    begin
        exit(URL.ToLower().Contains('transactions'));
    end;

    local procedure ExecuteWebServiceRequest(URL: Text; Method: Text[6]; BodyText: Text; AuthorizationHeaderValue: Text; var ErrorText: Text) PaginationLink: Text
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        ActivityLog: Record "Activity Log";
        DotNetExceptionHandler: Codeunit "DotNet Exception Handler";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        IsSuccessful: Boolean;
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        GetHttpResponseMessage: HttpResponseMessage;
        ProcessingDialog: Dialog;
        ReqHttpContent: HttpContent;
        RequestHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        BankFeedText: Text;
        ResponseTxt: Text;
        ApiVersion: Text;
        CobrandEnvironmentName: Text;
        UnsuccessfulRequestTelemetryTxt: Text;
        PaginationLinks: array[1] of Text;
        PaginationRelativeLink: Text;
    begin
        IF NOT TryCheckCredentials(ErrorText) THEN
            ERROR(ErrorText);

        // prepare request message    
        HttpRequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Accept', 'application/json');
        RequestHeaders.Add('Accept-Encoding', 'utf-8');
        RequestHeaders.Add('Connection', 'Keep-alive');
        ApiVersion := YodleeAPIStrings.GetApiVersion();
        if ApiVersion <> '' then
            RequestHeaders.Add('Api-Version', ApiVersion);
        CobrandEnvironmentName := GetCobrandEnvironmentName();
        if CobrandEnvironmentName <> '' then
            RequestHeaders.Add('Cobrand-Name', CobrandEnvironmentName);
        if AuthorizationHeaderValue <> '' then
            RequestHeaders.TryAddWithoutValidation('Authorization', AuthorizationHeaderValue);
        HttpRequestMessage.SetRequestUri(URL);
        HttpRequestMessage.Method(Method);
        if BodyText <> '' then begin
            ReqHttpContent.GetHeaders(ContentHeaders);
            ReqHttpContent.WriteFrom(BodyText);
            ContentHeaders.Remove('Content-Type');
            ContentHeaders.Add('Content-Type', YodleeAPIStrings.GetWebRequestContentType());
            HttpRequestMessage.Content(ReqHttpContent);
        end;

        // Set tracing
        MSYodleeBankServiceSetup.GET();
        GLBTraceLogEnabled := MSYodleeBankServiceSetup."Log Web Requests";

        CLEAR(ResponseTempBlob);
        ResponseTempBlob.CreateInStream(GLBResponseInStream);

        IF GUIALLOWED() THEN
            ProcessingDialog.Open(ProcessingWindowMsg);

        if UrlIsBankStatementImport(URL) then
            FeatureTelemetry.LogUptake('0000GY0', 'Yodlee', Enum::"Feature Uptake Status"::Used);

        IsSuccessful := HttpClient.Send(HttpRequestMessage, GetHttpResponseMessage);

        IF GUIALLOWED() THEN
            ProcessingDialog.Close();

        if IsSuccessful then
            GetHttpResponseMessage.Content().ReadAs(GLBResponseInStream)
        else begin
            DotNetExceptionHandler.Collect();
            UnsuccessfulRequestTelemetryTxt := DotNetExceptionHandler.GetMessage();
            FeatureTelemetry.LogError('0000GXZ', 'Yodlee', 'Requesting to Yodlee', RequestUnsuccessfulErr);
            Session.LogMessage('0000B4T', UnsuccessfulRequestTelemetryTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            Session.LogMessage('00009S2', RequestUnsuccessfulErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            Error(RequestUnsuccessfulErr);
        end;

        IF NOT GetHttpResponseMessage.IsSuccessStatusCode() THEN
            Errortext := STRSUBSTNO(RemoteServerErr, GetHttpResponseMessage.HttpStatusCode(), GetHttpResponseMessage.ReasonPhrase());

        IF UrlIsBankStatementImport(URL) THEN BEGIN
            GetHttpResponseMessage.Content().ReadAs(BankFeedText);
            if GetHttpResponseMessage.Headers.Contains('Link') then begin
                GetHttpResponseMessage.Headers.GetValues('Link', PaginationLinks);
                if PaginationLinks[1].Contains(';rel=next') then begin
                    // use pagination link only up to rel=next, we are not interested in rel=count link
                    PaginationRelativeLink := CopyStr(PaginationLinks[1], PaginationLinks[1].IndexOf('/'), PaginationLinks[1].IndexOf(';rel=next') - PaginationLinks[1].IndexOf('/'));
                    // if the pagination link also contains rel=previous, cut that off as well, because we are only interesetd in rel=next link
                    if PaginationRelativeLink.Contains(';rel=previous') then
                        PaginationRelativeLink := CopyStr(PaginationRelativeLink, PaginationRelativeLink.LastIndexOf('/'));
                    PaginationLink := YodleeAPIStrings.GetFullURL(PaginationRelativeLink);
                end;
            end;
            // put the bank feed in the global list of bank feeds
            // all the other Yodlee requests process the response from GLBResponseInStream
            // after GetTransactions request, we processes them from BankFeedTextList, because it can come in multiple responses
            BankFeedTextList.Add(BankFeedText);
            FeatureTelemetry.LogUsage('0000GY1', 'Yodlee', 'Bank Statement Imported');
            Session.LogMessage('000083Y', BankFeedText, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            if GLBTraceLogEnabled then
                ActivityLog.LogActivity(MSYodleeBankServiceSetup.RecordId(), ActivityLog.Status::Success, YodleeResponseTxt, 'gettransactions', BankFeedText);
        END;

        GetHttpResponseMessage.Content().ReadAs(ResponseTxt);
        IF URL.ToLower().Contains('accounts?status=active') THEN BEGIN
            Session.LogMessage('0000BI7', ResponseTxt, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            if GLBTraceLogEnabled then
                ActivityLog.LogActivity(MSYodleeBankServiceSetup.RecordId(), ActivityLog.Status::Success, YodleeResponseTxt, 'getlinkedbankaccounts', ResponseTxt);
        END;

        IF URL.ToLower().Contains('accounts?accountid') THEN BEGIN
            Session.LogMessage('0000BLP', ResponseTxt, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            if GLBTraceLogEnabled then
                ActivityLog.LogActivity(MSYodleeBankServiceSetup.RecordId(), ActivityLog.Status::Success, YodleeResponseTxt, 'getlinkedbankaccount', ResponseTxt);
        END;

        IF URL.ToLower().Contains(YodleeAPIStrings.GetRegisterConsumerURL()) THEN BEGIN
            Session.LogMessage('0000DLA', ResponseTxt, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            if GLBTraceLogEnabled then
                ActivityLog.LogActivity(MSYodleeBankServiceSetup.RecordId(), ActivityLog.Status::Success, YodleeResponseTxt, YodleeAPIStrings.GetRegisterConsumerURL(), ResponseTxt);
        END;

        IF URL.ToLower().Contains(YodleeAPIStrings.GetLinkedSiteListURL()) THEN BEGIN
            Session.LogMessage('0000G9J', ResponseTxt, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            if GLBTraceLogEnabled then
                ActivityLog.LogActivity(MSYodleeBankServiceSetup.RecordId(), ActivityLog.Status::Success, YodleeResponseTxt, YodleeAPIStrings.GetLinkedSiteListURL(), ResponseTxt);
        END;

        Commit();
    end;

    procedure CheckServiceEnabled();
    var
        ErrorText: Text;
    begin
        IF NOT TryCheckServiceEnabled(ErrorText) THEN
            ERROR(ErrorText);
    end;

    procedure TryCheckServiceEnabled(var ErrorText: Text): Boolean;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        IF NOT MSYodleeBankServiceSetup.GET() THEN BEGIN
            MSYodleeBankServiceSetup.INIT();
            SetValuesToDefault(MSYodleeBankServiceSetup);
            MSYodleeBankServiceSetup.INSERT(TRUE);
            Commit();
        END;

        IF (NOT MSYodleeBankServiceSetup.Enabled) AND GUIALLOWED() THEN BEGIN
            IF NOT MSYodleeBankServiceSetup.HasDefaultCredentials() THEN BEGIN
                ErrorText := NotEnabledErr;
                EXIT(FALSE);
            END;

            IF NOT CONFIRM(EnableYodleeQst) THEN BEGIN
                ErrorText := NotEnabledErr;
                EXIT(FALSE);
            END;

            MSYodleeBankServiceSetup.VALIDATE(Enabled, TRUE);
            MSYodleeBankServiceSetup.MODIFY(TRUE);
            COMMIT();
        END;

        IF NOT MSYodleeBankServiceSetup."Accept Terms of Use" THEN BEGIN
            IF NOT TryVerifyTermsOfUseAccepted(ErrorText) THEN
                EXIT(FALSE);
            COMMIT();
        END;
        EXIT(TRUE);
    end;

    procedure EnableServiceInSaas();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        IF NOT MSYodleeBankServiceSetup.GET() THEN BEGIN
            MSYodleeBankServiceSetup.INIT();
            SetValuesToDefault(MSYodleeBankServiceSetup);
            MSYodleeBankServiceSetup.INSERT(TRUE);
        END;

        IF (NOT MSYodleeBankServiceSetup.Enabled) AND GUIALLOWED() THEN BEGIN
            IF NOT MSYodleeBankServiceSetup.HasDefaultCredentials() THEN
                ERROR(NotEnabledErr);

            MSYodleeBankServiceSetup.VALIDATE(Enabled, TRUE);
            MSYodleeBankServiceSetup.MODIFY(TRUE);
            COMMIT();
        END;

        IF NOT MSYodleeBankServiceSetup."Accept Terms of Use" THEN BEGIN
            VerifyTermsOfUseAccepted();
            COMMIT();
        END;
    end;

    local procedure CheckForErrors(XMLRootNode: XmlNode; var ErrorText: Text): Boolean;
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ErrorCode: Text;
    begin
        ErrorText := FindNodeText(XMLRootNode, YodleeAPIStrings.GetErrorDetailXPath());
        IF ErrorText <> '' THEN BEGIN
            ErrorCode := FindNodeText(XMLRootNode, YodleeAPIStrings.GetErrorCodeXPath());
            IF ErrorCode = '415' THEN begin
                ErrorText := StaleCredentialsErr;
                FeatureTelemetry.LogError('0000GYL', 'Yodlee', 'Getting Response Value', StaleCredentialsErr);
            end;
            EXIT(FALSE);
        END;

        ErrorText := FindNodeText(XMLRootNode, YodleeAPIStrings.GetExceptionXPath());
        IF ErrorText <> '' THEN
            EXIT(FALSE);

        IF FindNodeText(XMLRootNode, YodleeAPIStrings.GetErrorOccurredXPath()) = 'true' THEN BEGIN
            ErrorText := FindNodeText(XMLRootNode, YodleeAPIStrings.GetDetailedMessageXPath());
            IF ErrorText = '' THEN begin
                ErrorText := UnknownErr;
                FeatureTelemetry.LogError('0000GYM', 'Yodlee', 'Getting Response Value', UnknownErr);
            end;

            EXIT(FALSE);
        END;

        EXIT(TRUE);
    end;

    [Scope('OnPrem')]
    procedure GetCobrandEnvironmentName(): Text;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        SecretValue: Text;
    begin
        IF GetYodleeCobrandEnvironmentNameFromAzureKeyVault(SecretValue) THEN
            EXIT(SecretValue);

        MSYodleeBankServiceSetup.GET();
        EXIT(MSYodleeBankServiceSetup.GetCobrandEnvironmentName(MSYodleeBankServiceSetup."Cobrand Environment Name"));
    end;

    [Scope('OnPrem')]
    procedure GetCobrandName(): Text;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        SecretValue: Text;
    begin
        IF GetYodleeCobrandNameFromAzureKeyVault(SecretValue) THEN
            EXIT(SecretValue);

        MSYodleeBankServiceSetup.GET();
        EXIT(MSYodleeBankServiceSetup.GetCobrandName(MSYodleeBankServiceSetup."Cobrand Name"));
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    procedure GetCobrandPassword(): Text;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        SecretValue: Text;
    begin
        IF GetYodleeCobrandPassFromAzureKeyVault(SecretValue) THEN
            EXIT(SecretValue);

        MSYodleeBankServiceSetup.GET();
        EXIT(MSYodleeBankServiceSetup.GetCobrandPassword(MSYodleeBankServiceSetup."Cobrand Password"));
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    procedure GetConsumerPassword(): Text;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        MSYodleeBankServiceSetup.GET();
        EXIT(MSYodleeBankServiceSetup.GetPassword(MSYodleeBankServiceSetup."Consumer Password"));
    end;

    [Scope('OnPrem')]
    procedure GetYodleeFastlinkUrl(): Text;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        SecretValue: Text;
    begin
        IF GetAzureKeyVaultSecret(SecretValue, YodleeFastlinkUrlTok) THEN
            EXIT(SecretValue);

        MSYodleeBankServiceSetup.GET();
        MSYodleeBankServiceSetup.TESTFIELD("Bank Acc. Linking URL");
        EXIT(MSYodleeBankServiceSetup."Bank Acc. Linking URL");
    end;

    internal procedure UsingFastlink4(): Boolean;
    begin
        Exit(GetYodleeFastlinkUrl().Contains('fl4'));
    end;

    [Scope('OnPrem')]
    procedure HasCustomCredentialsInAzureKeyVault(): Boolean;
    var
        SecretValue: Text;
    begin
        exit(GetAzureKeyVaultSecret(SecretValue, YodleeCobrandSecretNameTok));
    end;

    [Scope('OnPrem')]
    procedure GetYodleeCobrandNameFromAzureKeyVault(var YodleeCobrandNameValue: Text): Boolean;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(YodleeCobrandSecretNameTok, YodleeCobrandNameValue) then
            exit(false);

        if YodleeCobrandNameValue = '' then
            exit(false);

        exit(true);
    end;

    [Scope('OnPrem')]
    procedure GetYodleeCobrandEnvironmentNameFromAzureKeyVault(var YodleeCobrandEnvironmentNameValue: Text): Boolean;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(YodleeCobrandSecretEnvironmentNameTok, YodleeCobrandEnvironmentNameValue) then
            exit(false);

        if YodleeCobrandEnvironmentNameValue = '' then
            exit(false);

        exit(true);
    end;

    [Scope('OnPrem')]
    procedure GetYodleeCobrandPassFromAzureKeyVault(var YodleeCobrandPasswordValue: Text): Boolean;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(YodleeCobrandPasswordSecretNameTok, YodleeCobrandPasswordValue) then
            exit(false);

        if YodleeCobrandPasswordValue = '' then
            exit(false);

        exit(true);
    end;

    [Scope('OnPrem')]
    procedure GetYodleeServiceURLFromAzureKeyVault(var YodleeServiceURLValue: Text): Boolean;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(YodleeServiceUrlSecretNameTok, YodleeServiceURLValue) then
            exit(false);

        if YodleeServiceURLValue = '' then
            exit(false);

        exit(true);
    end;

    local procedure GetAzureKeyVaultSecret(var SecretValue: Text; SecretName: Text): Boolean;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(SecretName, SecretValue) then
            exit(false);

        if SecretValue = '' then
            exit(false);

        exit(true);
    end;

    local procedure LogActivitySucceed(ActivityDescription: Text; ActivityMessage: Text; TelemetryMsg: Text);
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        ActivityLog: Record "Activity Log";
    begin
        OnAfterSuccessfulActivitySendTelemetry(TelemetryMsg);

        MSYodleeBankServiceSetup.Get();
        if GLBTraceLogEnabled then
            ActivityLog.LogActivity(MSYodleeBankServiceSetup.RecordId(), ActivityLog.Status::Success, LoggingConstTxt, ActivityDescription, ActivityMessage);
    end;

    local procedure LogActivityFailed(ActivityDescription: Text; ActivityMessage: Text; "Action": Option IgnoreError,RethrowError,RethrowErrorWithConfirm; ConfirmMessage: Text; TelemetryMsg: Text; VerbosityLevel: Verbosity);
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        ActivityLog: Record "Activity Log";
        IsEmptyMessage: Boolean;
        IgnoreError: Boolean;
    begin
        IsEmptyMessage := DELCHR(ActivityMessage, '<>', ' ') = '';
        IgnoreError := GLBDisableRethrowException OR (Action = Action::IgnoreError) OR IsEmptyMessage;

        IF IgnoreError THEN
            ActivityMessage += '\' + ErrorsIgnoredTxt
        ELSE
            IF Action = Action::RethrowErrorWithConfirm THEN BEGIN
                IgnoreError := CONFIRM(ConfirmMessage);
                IF IgnoreError THEN
                    ActivityMessage += '\' + ErrorsIgnoredByUserTxt;
            END;

        SendTelemetryAfterFailedActivity(VerbosityLevel, TelemetryMsg);

        MSYodleeBankServiceSetup.Get();
        if GLBTraceLogEnabled then
            ActivityLog.LogActivity(MSYodleeBankServiceSetup.RecordId(), ActivityLog.Status::Failed, LoggingConstTxt, ActivityDescription, ActivityMessage);

        IF IsEmptyMessage and GLBTraceLogEnabled THEN
            ActivityLog.SetDetailedInfoFromStream(GLBResponseInStream);

        IF GLBDisableRethrowException THEN
            EXIT;

        COMMIT(); // do not roll back logging

        IF NOT IgnoreError THEN
            ERROR(ActivityMessage);
    end;

    local procedure StoreConsumerName(ConsumerName: Text);
    begin
        GLBConsumerName := ConsumerName;
    end;

    procedure EnableTraceLog(NewTraceLogEnabled: Boolean);
    begin
        GLBTraceLogEnabled := NewTraceLogEnabled;
    end;

    procedure SetDisableRethrowException(NewSetting: Boolean);
    begin
        GLBDisableRethrowException := NewSetting;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', false, false)]
#pragma warning disable AA0207
    procedure HandleVANRegisterServiceConnection(var ServiceConnection: Record 1400)
#pragma warning restore
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        RecRef: RecordRef;
    begin
        IF NOT MSYodleeBankServiceSetup.GET() THEN BEGIN
            MSYodleeBankServiceSetup.INIT();
            SetValuesToDefault(MSYodleeBankServiceSetup);
            MSYodleeBankServiceSetup.INSERT(TRUE);
        END;

        RecRef.GETTABLE(MSYodleeBankServiceSetup);

        IF MSYodleeBankServiceSetup.Enabled THEN
            ServiceConnection.Status := ServiceConnection.Status::Enabled
        ELSE
            ServiceConnection.Status := ServiceConnection.Status::Disabled;

        ServiceConnection.InsertServiceConnection(
          ServiceConnection, RecRef.RECORDID(), YodleeServiceNameTxt,
          MSYodleeBankServiceSetup."Service URL", PAGE::"MS - Yodlee Bank Service Setup");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::Video, 'OnRegisterVideo', '', false, false)]
    local procedure OnRegisterVideo(sender: Codeunit Video)
    var
        Info: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(Info);
        sender.Register(Info.Id(), VideoBankintegrationNameTxt, VideoBankintegrationTxt);
    end;

    local procedure IsLinkedToYodleeService(BankAccount: Record "Bank Account"): Boolean;
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecordRef: RecordRef;
        TestRecordRef: RecordRef;
    begin
        IF NOT TestRecordRef.GET(BankAccount."Bank Stmt. Service Record ID") THEN
            EXIT(FALSE);
        IF NOT DataTypeManagement.GetRecordRef(BankAccount."Bank Stmt. Service Record ID", RecordRef) THEN
            EXIT(FALSE);

        EXIT(RecordRef.NUMBER() = DATABASE::"MS - Yodlee Bank Service Setup");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnGetDataExchangeDefinitionEvent', '', false, false)]
    local procedure OnGetDataExchangeDefinition(Sender: Record "Bank Account"; var DataExchDefCodeResponse: Code[20]; var Handled: Boolean);
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        MSYodleeDataExchangeDef: Record "MS - Yodlee Data Exchange Def";
        DataExchDef: Record "Data Exch. Def";
    begin
        // identify that we are the subscriber supposed to handle the request
        IF Handled THEN
            EXIT;
        IF MSYodleeBankServiceSetup.GET(Sender."Bank Stmt. Service Record ID") THEN BEGIN
            if MSYodleeBankServiceSetup."Bank Feed Import Format" <> MSYodleeDataExchangeDef.GetYodleeAPI11DataExchDefinitionCode() then begin
                DataExchDef.SetRange(Code, MSYodleeDataExchangeDef.GetYodleeAPI11DataExchDefinitionCode());
                if DataExchDef.IsEmpty() then
                    MSYodleeDataExchangeDef.ResetYSL11DataExchDefinitionToDefault();
                MSYodleeBankServiceSetup."Bank Feed Import Format" := MSYodleeDataExchangeDef.GetYodleeAPI11DataExchDefinitionCode();
                MSYodleeBankServiceSetup.Modify();
                MSYodleeDataExchangeDef.ResetBankImportToDefault();

                // committing because this is a part of a process that launches a modal page later on (to set from and to dates for bank statement import)
                Commit();
            end;

            MSYodleeBankServiceSetup.TestField("Bank Feed Import Format");
            DataExchDefCodeResponse := MSYodleeBankServiceSetup."Bank Feed Import Format";
            Handled := TRUE;
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Read Data Exch. from Stream", 'OnGetDataExchFileContentEvent', '', false, false)]
    local procedure OnGetDataExchFileContent(DataExchIdentifier: Record "Data Exch."; var TempBlobResponse: Codeunit "Temp Blob"; var Handled: Boolean);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        BankAccount: Record "Bank Account";
        BankStatementFilter: Page "Bank Statement Filter";
        FromDate: Date;
        ToDate: Date;
    begin
        // identify that we are the subscriber supposed to handle the request
        IF Handled THEN
            EXIT;

        IF NOT BankAccount.GET(DataExchIdentifier."Related Record") THEN
            EXIT;

        IF NOT IsLinkedToYodleeService(BankAccount) THEN
            EXIT;

        FromDate := CALCDATE(STRSUBSTNO(LabelDateExprTok, -BankAccount."Transaction Import Timespan"), TODAY());
        ToDate := TODAY();

        // open filter page
        IF GUIALLOWED() THEN BEGIN
            IF FromDate = ToDate THEN
                FromDate := CALCDATE('<-7D>', ToDate);
            BankStatementFilter.SetDates(FromDate, ToDate);
            BankStatementFilter.LOOKUPMODE := TRUE;
            IF NOT (BankStatementFilter.RUNMODAL() = ACTION::LookupOK) THEN
                EXIT;
            BankStatementFilter.GetDates(FromDate, ToDate);
        END;

        // Get data and pass back to caller
        MSYodleeBankAccLink.GET(BankAccount."No.");
        LazyBankDataRefresh(MSYodleeBankAccLink."Online Bank ID", MSYodleeBankAccLink."Online Bank Account ID", ToDate);
        GetTransactions(MSYodleeBankAccLink."Online Bank Account ID", FromDate, ToDate);
        LogActivitySucceed(GetBankTxTxt, STRSUBSTNO(SuccessGetTxForAccTxt, BankAccount."No."), StrSubstNo(TelemetryActivitySuccessTxt, GetBankTxTxt, SuccessGetTxForAccTxt));

        ReturnOnlyPostedTransactions(TempBlobResponse);
        Handled := TRUE;
    end;

    local procedure ReturnOnlyPostedTransactions(var TempBlobResponse: Codeunit "Temp Blob");
    var
        BankFeedTempBlob: Codeunit "Temp Blob";
        PendingTransactionsTempBlob: Codeunit "Temp Blob";
        GetJsonStructure: Codeunit "Get Json Structure";
        BankFeedJSONInStream: InStream;
        BankFeedJSONOutStream: OutStream;
        OutStreamWithAllTransactions: OutStream;
        OutStreamWithPostedTransactions: OutStream;
        InStreamWithAllTransactions: InStream;
        PostedTransactionsNodeList: XmlNodeList;
        AllTransactionsXml: XmlNode;
        TransactionNode: XmlNode;
        AllTransactionsTxt: Text;
        PostedTransactionsTxt: Text;
        TransactionResponseLine: Text;
        TransactionNodeTxt: Text;
        BankFeedJSONTxt: Text;
        cr: Char;
    begin
        cr := 10;
        if BankFeedTextList.Count = 0 then
            exit;

        PostedTransactionsTxt += ('<root>' + Format(cr));
        PostedTransactionsTxt += ('<root>' + Format(cr));

        foreach BankFeedJSONTxt in BankFeedTextList do begin
            Clear(BankFeedTempBlob);
            Clear(PendingTransactionsTempBlob);
            Clear(GetJsonStructure);
            AllTransactionsTxt := '';
            BankFeedTempBlob.CreateOutStream(BankFeedJSONOutStream);
            BankFeedJSONOutStream.WriteText(BankFeedJSONTxt, StrLen(BankFeedJSONTxt));
            BankFeedTempBlob.CreateInStream(BankFeedJSONInStream);
            PendingTransactionsTempBlob.CreateOutStream(OutStreamWithAllTransactions);
            IF NOT GetJsonStructure.JsonToXMLCreateDefaultRoot(BankFeedJSONInStream, OutStreamWithAllTransactions) THEN
                LogInternalError(InvalidResponseErr, DataClassification::SystemMetadata, Verbosity::Error);
            PendingTransactionsTempBlob.CreateInStream(InStreamWithAllTransactions);
            while not InStreamWithAllTransactions.EOS() do begin
                InStreamWithAllTransactions.ReadText(TransactionResponseLine);
                AllTransactionsTxt += (TransactionResponseLine + Format(cr));
            end;
            LoadXMLNodeFromtext(AllTransactionsTxt, AllTransactionsXml);
            if AllTransactionsXml.SelectNodes('/root/root/transaction[status=''POSTED'']', PostedTransactionsNodeList) then
                foreach TransactionNode in PostedTransactionsNodeList do begin
                    TransactionNode.WriteTo(TransactionNodeTxt);
                    PostedTransactionsTxt += TransactionNodeTxt;
                end;
        end;

        PostedTransactionsTxt += ('</root>' + Format(cr));
        PostedTransactionsTxt += ('</root>' + Format(cr));

        TempBlobResponse.CreateOutStream(OutStreamWithPostedTransactions, TextEncoding::UTF8);
        OutStreamWithPostedTransactions.WriteText(PostedTransactionsTxt);
        BankFeedTextList.RemoveRange(1, BankFeedTextList.Count());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnCheckLinkedToStatementProviderEvent', '', false, false)]
    local procedure OnCheckLinkedToStatementProvider(var BankAccount: Record "Bank Account"; var IsLinked: Boolean);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        IF IsLinked = TRUE THEN
            EXIT;

        IF NOT IsLinkedToYodleeService(BankAccount) THEN
            EXIT;

        IF MSYodleeBankAccLink.GET(BankAccount."No.") THEN
            IF MSYodleeBankAccLink."Online Bank Account ID" <> '' THEN
                IsLinked := TRUE;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnCheckAutoLogonPossibleEvent', '', false, false)]
    local procedure OnCheckAutoLogonPossible(var BankAccount: Record "Bank Account"; var AutoLogonPossible: Boolean);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        IF AutoLogonPossible = FALSE THEN
            EXIT;

        IF NOT IsLinkedToYodleeService(BankAccount) THEN
            EXIT;

        IF MSYodleeBankAccLink.GET(BankAccount."No.") THEN
            IF NOT MSYodleeBankAccLink."Automatic Logon Possible" THEN
                AutoLogonPossible := FALSE;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnUnlinkStatementProviderEvent', '', false, false)]
    local procedure OnUnlinkStatementProvider(var BankAccount: Record "Bank Account"; Handled: Boolean);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        LinkRemovedFromYodlee: Boolean;
    begin
        IF Handled THEN
            EXIT;

        IF NOT IsLinkedToYodleeService(BankAccount) THEN
            EXIT;

        IF NOT ValidateNotDemoCompanyOnSaas() THEN
            EXIT;

        LinkRemovedFromYodlee := UnlinkBankAccount(BankAccount);

        IF MSYodleeBankAccLink.ISEMPTY() AND LinkRemovedFromYodlee THEN
            UnregisterConsumer();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnLinkStatementProviderEvent', '', false, false)]
    local procedure OnLinkStatementProvider(var BankAccount: Record "Bank Account"; StatementProvider: Text);
    begin
        IF StatementProvider <> YodleeServiceIdentifierTxt THEN
            EXIT;

        IF NOT ValidateNotDemoCompanyOnSaas() THEN
            EXIT;

        LinkBankAccount(BankAccount);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnRefreshStatementProviderEvent', '', false, false)]
    local procedure OnRefreshStatementProvider(var BankAccount: Record "Bank Account"; StatementProvider: Text);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        IF StatementProvider <> YodleeServiceIdentifierTxt THEN
            EXIT;

        IF NOT ValidateNotDemoCompanyOnSaas() THEN
            EXIT;

        IF NOT IsLinkedToYodleeService(BankAccount) THEN
            EXIT;

        MSYodleeBankAccLink.GET(BankAccount."No.");
        MFABankDataRefresh(MSYodleeBankAccLink."Online Bank ID", MSYodleeBankAccLink."Online Bank Account ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnRenewAccessConsentStatementProviderEvent', '', false, false)]
    local procedure OnRenewAccessConsentStatementProvider(var BankAccount: Record "Bank Account"; StatementProvider: Text);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        IF StatementProvider <> YodleeServiceIdentifierTxt THEN
            EXIT;

        IF NOT ValidateNotDemoCompanyOnSaas() THEN
            EXIT;

        IF NOT IsLinkedToYodleeService(BankAccount) THEN
            EXIT;

        MSYodleeBankAccLink.GET(BankAccount."No.");
        OnlineBankAccountAccessConsent(MSYodleeBankAccLink."Online Bank Account ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnEditAccountStatementProviderEvent', '', false, false)]
    local procedure OnEditAccountStatementProvider(var BankAccount: Record "Bank Account"; StatementProvider: Text);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        IF StatementProvider <> YodleeServiceIdentifierTxt THEN
            EXIT;

        IF NOT ValidateNotDemoCompanyOnSaas() THEN
            EXIT;

        IF NOT IsLinkedToYodleeService(BankAccount) THEN
            EXIT;

        MSYodleeBankAccLink.GET(BankAccount."No.");
        OnlineBankAccountEdit(MSYodleeBankAccLink."Online Bank Account ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnSimpleLinkStatementProviderEvent', '', false, false)]
    local procedure OnSimpleLinkStatementProvider(var OnlineBankAccLink: Record "Online Bank Acc. Link"; StatementProvider: Text);
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        TempMissingMSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link" temporary;
        SiteListXML: Text;
    begin
        IF StatementProvider <> YodleeServiceIdentifierTxt THEN
            EXIT;
        IF NOT ValidateNotDemoCompanyOnSaas() THEN
            EXIT;

        // In simple linking scenario, user accept the terms and condition in the wizard.
        SetAcceptTermsOfUse(MSYodleeBankServiceSetup);
        EnableServiceInSaas();

        IF NOT ShowFastLinkPage('') THEN
            EXIT;

        SiteListXML := GetLinkedSites();
        MatchBankAccountIDs(SiteListXML, TempMissingMSYodleeBankAccLink);

        IF TempMissingMSYodleeBankAccLink.COUNT() = 0 THEN BEGIN
            UnregisterConsumer();
            MESSAGE(NoAccountLinkedMsg);
        END ELSE BEGIN
            TempMissingMSYodleeBankAccLink.FINDSET();
            REPEAT
                OnlineBankAccLink.INIT();
                OnlineBankAccLink.TRANSFERFIELDS(TempMissingMSYodleeBankAccLink);
                OnlineBankAccLink.ProviderId := YodleeServiceIdentifierTxt;
                OnlineBankAccLink.INSERT();
            UNTIL TempMissingMSYodleeBankAccLink.NEXT() = 0
        END;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnDisableStatementProviderEvent', '', false, false)]
    local procedure OnDisableStatementProvider(ProviderName: Text);
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        IF ProviderName <> YodleeServiceIdentifierTxt THEN
            EXIT;

        IF NOT MSYodleeBankServiceSetup.GET() THEN
            EXIT;

        IF MSYodleeBankServiceSetup.Enabled = false THEN
            EXIT;

        MSYodleeBankServiceSetup.Validate(Enabled, false);
        MSYodleeBankServiceSetup.Modify(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnUpdateBankAccountLinkingEvent', '', false, false)]
    local procedure OnUpdateBankAccountLinking(var BankAccount: Record "Bank Account"; StatementProvider: Text);
    begin
        IF StatementProvider <> YodleeServiceIdentifierTxt THEN
            EXIT;

        IF NOT ValidateNotDemoCompanyOnSaas() THEN
            EXIT;

        UpdateBankAccountLinking(BankAccount, TRUE);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnGetStatementProvidersEvent', '', false, false)]
    local procedure OnGetStatementProviders(var TempNameValueBuffer: Record 823 temporary);
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        IF HasCustomCredentialsInAzureKeyVault() THEN BEGIN
            PopulateNameValueBufferWithYodleeInfo(TempNameValueBuffer);
            EXIT;
        END;

        IF MSYodleeBankServiceSetup.GET() THEN;
        IF NOT MSYodleeBankServiceSetup.HasCobrandName(MSYodleeBankServiceSetup."Cobrand Name") THEN
            EXIT;

        PopulateNameValueBufferWithYodleeInfo(TempNameValueBuffer);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnMarkAccountLinkedEvent', '', false, false)]
    local procedure OnMarkAccountLinked(var OnlineBankAccLink: Record "Online Bank Acc. Link"; var BankAccount: Record "Bank Account");
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        IF OnlineBankAccLink.ProviderId <> YodleeServiceIdentifierTxt THEN
            EXIT;

        MSYodleeBankAccLink.TRANSFERFIELDS(OnlineBankAccLink);
        MarkBankAccountLinked(BankAccount, MSYodleeBankAccLink);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', false, false)]
    local procedure HandleRegisterBusinessSetup()
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        GuidedExperience: Codeunit "Guided Experience";
        ManualSetupCategory: Enum "Manual Setup Category";
    begin
        IF NOT MSYodleeBankServiceSetup.GET() THEN BEGIN
            MSYodleeBankServiceSetup.INIT();
            SetValuesToDefault(MSYodleeBankServiceSetup);
            MSYodleeBankServiceSetup.INSERT(TRUE);
        END;

        GuidedExperience.InsertManualSetup(
            YodleeServiceNameTxt, CopyStr(YodleeServiceNameTxt, 1, 50), YodleeBusinessSetupDescriptionTxt,
            0, ObjectType::Page, PAGE::"MS - Yodlee Bank Service Setup", ManualSetupCategory::Service,
            YodleeBusinessSetupKeywordsTxt
        );
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnAfterDeleteEvent', '', false, false)]
    local procedure RemoveYodleeBankAccLinkOnAfterBankAccountDelete(var Rec: Record "Bank Account"; RunTrigger: Boolean);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        IF Rec.ISTEMPORARY() THEN
            EXIT;

        IF MSYodleeBankAccLink.GET(Rec."No.") THEN BEGIN // this was a linked account
            Rec.VALIDATE("Automatic Stmt. Import Enabled", FALSE); // remove job queue entry

            MSYodleeBankAccLink.DELETE(TRUE);

            IF MSYodleeBankAccLink.ISEMPTY() THEN
                IF CONFIRM(PromptConsumerRemoveNoLinkingQst, TRUE) THEN
                    UnregisterConsumer();
        END;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Bank Account List", 'OnOpenPageEvent', '', false, false)]
    local procedure NotifyUserOnBankAccountListOpened(var Rec: Record "Bank Account");
    begin
        NotifyUserAboutYodleeCapabilities();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Pmt. Reconciliation Journals", 'OnOpenPageEvent', '', false, false)]
    local procedure NotifyUserOnPaymentReconJournalsOpened(var Rec: Record "Bank Acc. Reconciliation");
    begin
        NotifyUserAboutYodleeCapabilities();
    end;

    local procedure NotifyUserAboutYodleeCapabilities()
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        BankAccount: Record "Bank Account";
        MyNotifications: Record "My Notifications";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
        YodleeAwarenessNotification: Notification;
    begin
        IF CompanyInformationMgt.IsDemoCompany() AND EnvironmentInformation.IsSaaS() THEN
            EXIT;

        IF NOT MyNotifications.IsEnabled(GetYodleeAwarenessNotificationId()) then
            EXIT;

        YodleeAwarenessNotification.Id(GetYodleeAwarenessNotificationId());
        YodleeAwarenessNotification.SetData('NotificationId', GetYodleeAwarenessNotificationId());
        YodleeAwarenessNotification.Message(YodleeAwarenessNotificationTxt);

        if not MSYodleeBankServiceSetup.GET() then begin
            YodleeAwarenessNotification.AddAction(SetUpNotificationActionTxt, Codeunit::"MS - Yodlee Service Mgt.", 'OpenSetupPageFromNotification');
            YodleeAwarenessNotification.AddAction(DisableNotificationTxt, Codeunit::"MS - Yodlee Service Mgt.", 'DisableNotification');
            YodleeAwarenessNotification.Send();
            exit;
        end;

        BankAccount.SETRANGE("Bank Stmt. Service Record ID", MSYodleeBankServiceSetup.RECORDID());
        if MSYodleeBankServiceSetup.Enabled and BankAccount.IsEmpty() then begin
            YodleeAwarenessNotification.AddAction(UsageNotificationActionTxt, Codeunit::"MS - Yodlee Service Mgt.", 'LinkNewBankAccountFromNotification');
            YodleeAwarenessNotification.AddAction(DisableNotificationTxt, Codeunit::"MS - Yodlee Service Mgt.", 'DisableNotification');
            YodleeAwarenessNotification.Send();
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"General Journal", 'OnOpenPageEvent', '', false, false)]
    local procedure NotifyUserOnGeneralJournalOpened(var Rec: Record "Gen. Journal Line");
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        PostedPaymentReconHdr: Record "Posted Payment Recon. Hdr";
        BankAccount: Record "Bank Account";
        MyNotifications: Record "My Notifications";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        EnvironmentInfo: Codeunit "Environment Information";
        PaymentReconAwarenessNotification: Notification;
    begin
        IF CompanyInformationMgt.IsDemoCompany() AND EnvironmentInfo.IsSaaS() THEN
            EXIT;

        IF NOT MyNotifications.IsEnabled(GetPaymentReconJournalsAwarenessNotificationId()) then
            EXIT;

        // if the user has set up automatic bank feed fetching, do not notify the user - he already uses bank feed fetching
        BankAccount.SetRange("Automatic Stmt. Import Enabled", true);
        if not BankAccount.IsEmpty() then
            exit;

        // if the user already created or posted a Payment Reconciliation Journal, do not notify
        BankAccReconciliation.SetRange("Statement Type", BankAccReconciliation."Statement Type"::"Payment Application");
        if not BankAccReconciliation.IsEmpty() or not PostedPaymentReconHdr.IsEmpty() then
            exit;

        // notify the user that he can pull bank feeds from Payment Reconciliation Journal
        PaymentReconAwarenessNotification.Id(GetPaymentReconJournalsAwarenessNotificationId());
        PaymentReconAwarenessNotification.Message(PaymentReconAwarenessNotificationTxt);
        PaymentReconAwarenessNotification.AddAction(UsageNotificationActionTxt, Codeunit::"MS - Yodlee Service Mgt.", 'OpenPaymentReconJnlFromNotification');
        PaymentReconAwarenessNotification.SetData('NotificationId', GetPaymentReconJournalsAwarenessNotificationId());
        PaymentReconAwarenessNotification.AddAction(DisableNotificationTxt, Codeunit::"MS - Yodlee Service Mgt.", 'DisableNotification');
        PaymentReconAwarenessNotification.Send();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Bank Account Card", 'OnOpenPageEvent', '', false, false)]
    local procedure NotifyUserOnBankAccountCardOpened(var Rec: Record "Bank Account");
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        MyNotifications: Record "My Notifications";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        EnvironmentInfo: Codeunit "Environment Information";
        AutomaticBankStatementImportNotification: Notification;
    begin
        IF CompanyInformationMgt.IsDemoCompany() AND EnvironmentInfo.IsSaaS() THEN
            EXIT;

        IF NOT MyNotifications.IsEnabled(GetAutomaticBankStatementImportNotificationId()) then
            EXIT;

        if not MSYodleeBankServiceSetup.GET() then
            exit;

        if not MSYodleeBankServiceSetup.Enabled then
            exit;

        IF (Rec."Bank Stmt. Service Record ID" = MSYodleeBankServiceSetup.RECORDID()) and (Rec."Automatic Stmt. Import Enabled" = false) then begin
            // notify the user that he can set up automatic bank statement import
            AutomaticBankStatementImportNotification.Id(GetAutomaticBankStatementImportNotificationId());
            AutomaticBankStatementImportNotification.Message(AutoBankStmtImportNotificationTxt);
            AutomaticBankStatementImportNotification.SetData('BankAccNo', Rec."No.");
            AutomaticBankStatementImportNotification.AddAction(SetupNotificationActionTxt, Codeunit::"MS - Yodlee Service Mgt.", 'OpenAutoBankStmtImportSetupFromNotification');
            AutomaticBankStatementImportNotification.SetData('NotificationId', GetAutomaticBankStatementImportNotificationId());
            AutomaticBankStatementImportNotification.AddAction(DisableNotificationTxt, Codeunit::"MS - Yodlee Service Mgt.", 'DisableNotification');
            AutomaticBankStatementImportNotification.Send();
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"My Notifications", 'OnInitializingNotificationWithDefaultState', '', false, false)]
    local procedure OnInitializingNotificationWithDefaultState();
    var
        MyNotifications: Record "My Notifications";
    begin
        MyNotifications.InsertDefault(GetYodleeAwarenessNotificationId(), YodleeAwarenessNotificationNameTxt, YodleeAwarenessNotificationDescriptionTxt, true);
        MyNotifications.InsertDefault(GetPaymentReconJournalsAwarenessNotificationId(), PaymentReconAwarenessNotificationNameTxt, PaymentReconAwarenessNotificationDescriptionTxt, true);
        MyNotifications.InsertDefault(GetAutomaticBankStatementImportNotificationId(), AutoBankStmtImportNotificationNameTxt, AutoBankStmtImportNotificationDescriptionTxt, true);
    end;

    procedure GetYodleeAwarenessNotificationId(): Guid;
    begin
        exit('2656eb81-8d3f-4745-b1b7-0ea0a90b7846');
    end;

    procedure GetPaymentReconJournalsAwarenessNotificationId(): Guid;
    begin
        exit('37f28ac4-7a26-4331-88fe-d10547cb4d2d');
    end;

    procedure GetAutomaticBankStatementImportNotificationId(): Guid;
    begin
        exit('0b2aaa47-4aaa-44ae-8621-be0ebdaa4804');
    end;

    local procedure GetNotificationName(NotificationId: Guid): Text[128];
    begin
        case NotificationId of
            GetYodleeAwarenessNotificationId():
                EXIT(YodleeAwarenessNotificationNameTxt);
            GetPaymentReconJournalsAwarenessNotificationId():
                EXIT(PaymentReconAwarenessNotificationNameTxt);
            GetAutomaticBankStatementImportNotificationId():
                EXIT(AutoBankStmtImportNotificationNameTxt);
        end;
        exit('');
    end;

    local procedure GetNotificationDescription(NotificationId: Guid): Text;
    begin
        case NotificationId of
            GetYodleeAwarenessNotificationId():
                EXIT(YodleeAwarenessNotificationDescriptionTxt);
            GetPaymentReconJournalsAwarenessNotificationId():
                EXIT(PaymentReconAwarenessNotificationDescriptionTxt);
            GetAutomaticBankStatementImportNotificationId():
                EXIT(AutoBankStmtImportNotificationDescriptionTxt);
        end;
        exit('');
    end;

    local procedure ValidateNotDemoCompanyOnSaas(): Boolean;
    var
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        IF CompanyInformationMgt.IsDemoCompany() AND EnvironmentInformation.IsSaaS() THEN BEGIN
            MESSAGE(DemoCompanyWithDefaultCredentialMsg);
            EXIT(FALSE);
        END;
        EXIT(TRUE);
    end;

    procedure LinkNewBankAccountFromNotification(HostNotification: Notification)
    var
        BankAccount: Record "Bank Account";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        IF CompanyInformationMgt.IsDemoCompany() AND EnvironmentInformation.IsSaaS() THEN
            EXIT;

        BankAccount.INIT();
        LinkBankAccount(BankAccount);
        Session.LogMessage('000020H', UserStartedLinkingNewBankAccountViaNotificationTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
    end;

    procedure DisableNotification(HostNotification: Notification)
    var
        MyNotifications: Record "My Notifications";
        NotificationId: Text;
    begin
        NotificationId := HostNotification.GetData('NotificationId');
        IF MyNotifications.Get(UserId(), NotificationId) THEN
            MyNotifications.Disable(NotificationId)
        ELSE
            MyNotifications.InsertDefault(NotificationId, GetNotificationName(NotificationId), GetNotificationDescription(NotificationId), false);
        Session.LogMessage('000020K', StrSubstNo(UserDisabledNotificationTxt, HostNotification.GetData('NotificationId')), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
    end;


    procedure OpenAutoBankStmtImportSetupFromNotification(HostNotification: Notification)
    var
        BankAccount: Record "Bank Account";
        AutoBankStmtImportSetup: Page "Auto. Bank Stmt. Import Setup";
    begin
        if NOT BankAccount.Get(HostNotification.GetData('BankAccNo')) then
            exit;

        AutoBankStmtImportSetup.SetRecord(BankAccount);
        AutoBankStmtImportSetup.Run();
        Session.LogMessage('000020I', UserOpenedAutoBankStmtSetupViaNotificationTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
    end;

    procedure OpenSetupPageFromNotification(HostNotification: Notification)
    var
        MSYodleeBankServiceSetup: Page "MS - Yodlee Bank Service Setup";
    begin
        MSYodleeBankServiceSetup.Run();
        Session.LogMessage('000020J', UserOpenedYodleeSetupPageViaNotificationTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
    end;

    procedure OpenPaymentReconJnlFromNotification(HostNotification: Notification)
    var
        PmtReconciliationJournals: Page "Pmt. Reconciliation Journals";
    begin
        PmtReconciliationJournals.Run();
        Session.LogMessage('000020L', UserOpenedPaymentReconJournalsViaNotificationTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
    end;

    local procedure ShowFastLinkPage(SearchKeyWord: Text): Boolean;
    var
        MSYodleeAccountLinking: Page "MS - Yodlee Account Linking";
    begin
        MSYodleeAccountLinking.SetSearchKeyword(SearchKeyWord);
        MSYodleeAccountLinking.LOOKUPMODE := TRUE;
        IF MSYodleeAccountLinking.RUNMODAL() = ACTION::LookupOK THEN
            EXIT(TRUE);

        EXIT(FALSE);
    end;

    local procedure SetAcceptTermsOfUse(var MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup");
    begin
        IF NOT MSYodleeBankServiceSetup.GET() THEN BEGIN
            MSYodleeBankServiceSetup.INIT();
            SetValuesToDefault(MSYodleeBankServiceSetup);
            MSYodleeBankServiceSetup.INSERT(TRUE);
        END;

        MSYodleeBankServiceSetup."Accept Terms of Use" := TRUE;
        MSYodleeBankServiceSetup.MODIFY(TRUE);
        COMMIT();
    end;

    procedure UnlinkAllBankAccounts();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        BankAccount: Record "Bank Account";
    begin
        IF NOT MSYodleeBankServiceSetup.GET() THEN
            EXIT;

        BankAccount.SETRANGE("Bank Stmt. Service Record ID", MSYodleeBankServiceSetup.RECORDID());
        IF BankAccount.FINDSET() THEN
            REPEAT
                MarkBankAccountAsUnlinked(BankAccount."No.");
            UNTIL BankAccount.NEXT() = 0;
    end;

    local procedure GetAdjustedErrorText(ErrorText: Text; AdditionalErrorText: Text): Text;
    var
        AdjustedErrorText: Text;
    begin
        IF ErrorText <> '' THEN
            AdjustedErrorText := ErrorText + '\';

        AdjustedErrorText += AdditionalErrorText;
        EXIT(AdjustedErrorText);
    end;

    local procedure PopulateNameValueBufferWithYodleeInfo(var TempNameValueBuffer: Record 823 temporary);
    var
        LastId: Integer;
    begin
        LastId := 0;
        IF TempNameValueBuffer.FINDLAST() THEN
            LastId := TempNameValueBuffer.ID;

        TempNameValueBuffer.INIT();
        TempNameValueBuffer.ID := LastId + 1;
        TempNameValueBuffer.Name := YodleeServiceIdentifierTxt;
        TempNameValueBuffer.Value := YodleeServiceNameTxt;
        TempNameValueBuffer.INSERT();
    end;

    procedure Cleanup(): Boolean;
    var
        ErrorOccured: Boolean;
    begin
        IF NOT HasCapability() THEN
            exit(FALSE);

        ErrorOccured := FALSE;
        OnCleanUpEvent(ErrorOccured);

        exit(NOT ErrorOccured);
    end;

    local procedure HasCapability(): Boolean;
    var
        CryptographyManagement: Codeunit "Cryptography Management";
    begin
        exit(CryptographyManagement.IsEncryptionEnabled() AND CryptographyManagement.IsEncryptionPossible());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCleanUpEvent(VAR ErrorOccured: Boolean)
    // The subscriber of this event should perform any clean up that is dependant on the Isolated Storage table.
    // If an error occurs it should set ErrorOccured to true.
    begin
    end;

    local procedure IsStaleCredentialsErr(ErrTxt: Text): Boolean;
    begin
        exit(ErrTxt.Contains(BankStmtServiceStaleConversationCredentialsErrTxt) or ErrTxt.Contains(BankStmtServiceStaleConversationCredentialsExceptionTxt) or ErrTxt.Contains(StaleCredentialsErr) or ErrTxt.Contains(UnauthorizedResponseCodeTok));
    end;

#if NOT CLEAN20
    [IntegrationEvent(false, false)]
    [Obsolete('This event is not being executed in code.', '20.0')]
    local procedure OnAfterFailedActivitySendTelemetry(Message: Text);
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnAfterSuccessfulActivitySendTelemetry(Message: Text);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCobrandTokenExpiredSendTelemetry();
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnConsumerTokenExpiredSendTelemetry();
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnConsumerUninitializedSendTelemetry();
    begin
    end;

#if not CLEAN20
    [IntegrationEvent(false, false)]
    [Obsolete('This event is not being executed in code.', '20.0')]
    local procedure OnOnlineBankAccountCurrencyMismatchSendTelemetry(Message: Text);
    begin
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnOnlineAccountEmptyCurrencySendTelemetry(Message: Text);
    begin
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure HandleOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        MSYodleeBankSession: Record "MS - Yodlee Bank Session";
    begin
        MSYodleeBankServiceSetup.ChangeCompany(NewCompanyName);
        MSYodleeBankServiceSetup.DeleteAll();
        MSYodleeBankAccLink.ChangeCompany(NewCompanyName);
        MSYodleeBankAccLink.DeleteAll();
        MSYodleeBankSession.ChangeCompany(NewCompanyName);
        MSYodleeBankSession.DeleteAll();
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MS - Yodlee Service Mgt.", 'OnAfterSuccessfulActivitySendTelemetry', '', false, false)]
    local procedure SendTelemetryAfterSuccessfulActivity(Message: Text);
    begin
        Session.LogMessage('000015V', Message, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
    end;

    local procedure SendTelemetryAfterFailedActivity(VerbosityLevel: Verbosity; Message: Text);
    begin
        Session.LogMessage('000015W', Message, VerbosityLevel, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MS - Yodlee Service Mgt.", 'OnCobrandTokenExpiredSendTelemetry', '', false, false)]
    local procedure SendTelemetryOnCobrandTokenExpired();
    begin
        Session.LogMessage('00001FT', CobrandTokenExpiredTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MS - Yodlee Service Mgt.", 'OnConsumerTokenExpiredSendTelemetry', '', false, false)]
    local procedure SendTelemetryOnConsumerTokenExpired();
    begin
        Session.LogMessage('00001FU', ConsumerTokenExpiredTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MS - Yodlee Service Mgt.", 'OnConsumerUninitializedSendTelemetry', '', false, false)]
    local procedure SendTelemetryOnConsumerUnitialized();
    begin
        Session.LogMessage('00001FV', ConsumerUnitializedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MS - Yodlee Service Mgt.", 'OnOnlineAccountEmptyCurrencySendTelemetry', '', false, false)]
    LOCAL PROCEDURE SendTelemetryOnOnlineAccountEmptyCurrency(Message: Text);
    BEGIN
        Session.LogMessage('00001QG', Message, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
    END;
}




