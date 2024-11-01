namespace Microsoft.Bank.StatementImport.Yodlee;

using System.Utilities;
using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Reconciliation;
using System.Media;
using System.IO;
using Microsoft.Finance.GeneralLedger.Journal;
using System.DataAdministration;
using System.Security.Encryption;
using Microsoft.Bank.Statement;
using System.Environment.Configuration;
using Microsoft.Foundation.Company;
using System.Environment;
using System.Reflection;
using System.Azure.KeyVault;
using System.Telemetry;
using System;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Utilities;

codeunit 1450 "MS - Yodlee Service Mgt."
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
        CredentialsCommentTxt: Label 'Yodlee is unable to download the latest transactions from the online bank account without user assistance. To perform this activity manually, you must open the corresponding bank account card, choose action Edit Online Bank Account and provide credentials for your online bank account and close the page. Then choose action Refresh Online Bank Account.';
        CurrencyMismatchErr: Label 'The currency your bank account is using (%1) does not match the currency for your online bank account (%2).', Comment = '%1 and %2 are company and Yodlee currency codes.';
        RefreshMsg: Label 'The value in the To Date field is later than the date of the current bank feed. The latest bank feed is from %1.', Comment = '%1 = the date the bank feed was last updated';
        BankStmtServiceInvalidConsumerErrTxt: Label 'Invalid User Credentials', Locked = true;
        BankStmtServiceStaleConversationCredentialsErrTxt: Label 'Stale conversation credentials', Locked = true;
        BankStmtServiceStaleConversationCredentialsExceptionTxt: Label 'StaleConversationCredentialsException', Locked = true;
        BankStmtServiceStaleIllegalArgumentValueExceptionTxt: Label 'IllegalArgumentValueException', Locked = true;
        RegisterConsumerVerifyLCYCodeTxt: Label 'Registering a consumer account failed because of an invalid argument value. Open General Ledger Setup window and verify that the field LCY Code contains the ISO standard code for your local currency.';
        StaleCredentialsErr: Label 'Your session has expired. Please try the operation again.';
        BankAccountRefreshInvalidCredentialsTxt: Label 'Yodlee could not download latest transactions from your online bank account because your credentials were reported to be incorrect. You must open the corresponding bank account card, choose action Edit Online Bank Account Information and provide credentials for your online bank account and close the page. Then choose action Refresh Online Bank Account.';
        BankAccountRefreshUnknownErrorTxt: Label 'Yodlee encountered a technical problem while downloading latest transactions from your online bank account. Open the corresponding bank account card, choose action Edit Online Bank Account Information and provide credentials for your online bank account and close the page. Then choose action Refresh Online Bank Account to try downloading latest transactions again.';
        BankAccountRefreshAccountLockedTxt: Label 'Yodlee could not update your account because it appears to be locked by your bank. This usually results from too many unsuccessful login attempts in a short period of time. Please visit the bank or contact its customer support to resolve this issue. Once done, open the corresponding bank account card, choose action Edit Online Bank Account Information, provide credentials for your online bank account and close the page. Then choose action Refresh Online Bank Account to try downloading latest transactions again.';
        BankAccountRefreshBankDownTxt: Label 'Yodlee was unable to update your account as the online bank is experiencing technical difficulties. We apologize for the inconvenience. Please try again later.';
        BankAccountRefreshBankDownForMaintenanceTxt: Label 'Yodlee was unable to update your account as the online bank is temporarily down for maintenance. We apologize for the inconvenience. This problem is typically resolved in a few hours. Please try again later.';
        BankAccountRefreshBankInBetaMaintenanceTxt: Label 'Yodlee was unable to update your account because it has started providing data updates for this online bank, and it may take a few days to be successful. Please try again later.';
        BankAccountRefreshTimedOutTxt: Label 'Your request timed out due to technical reasons. Open the corresponding bank account card and choose action Edit Online Bank Account Information. Provide the credentials for the online bank account, close the page and then choose action Refresh Online Bank Account.';
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
        YodleeAdminLoginNameSecretNameTok: Label 'YodleeAdminLoginName';
        YodleeClientIdSecretNameTok: Label 'YodleeClientId';
        YodleeClientSecretSecretNameTok: Label 'YodleeClientSecret';
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
        MissingCredentialsQst: Label 'The client secret is missing in the Envestnet Yodlee Bank Feeds Service Setup window.\\Do you want to open the Envestnet Yodlee Bank Feeds Service Setup window?';
        MissingCredentialsErr: Label 'The client secret is missing in the Envestnet Yodlee Bank Feeds Service Setup window.';
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
        FastlinkDataClientCredTok: Label '{"app":"%1","accessToken":"%2","redirectReq":"%3","extraParams":"%4"}', Locked = true;
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
        if not HasCustomCredentialsInAKV then begin
            MSYodleeBankServiceSetup."Service URL" := ServiceUrlTok;
            MSYodleeBankServiceSetup."Bank Acc. Linking URL" := BankAccLinkingUrlTok;
        end;

        if CompanyInformationMgt.IsDemoCompany() then
            exit;

        // this is not available OnPrem, since we have the secret only in AKV
        if not HasCustomCredentialsInAKV then begin
            if GetYodleeServiceURLFromAzureKeyVault(ServiceURLValue) then
                MSYodleeBankServiceSetup.VALIDATE("Service URL",
                  COPYSTR(ServiceURLValue, 1, MAXSTRLEN(MSYodleeBankServiceSetup."Service URL")));
            if GetAzureKeyVaultSecret(BankAccLinkingURLValue, YodleeFastlinkUrlTxt) then
                MSYodleeBankServiceSetup.VALIDATE("Bank Acc. Linking URL",
                  COPYSTR(BankAccLinkingURLValue, 1, MAXSTRLEN(MSYodleeBankServiceSetup."Bank Acc. Linking URL")));
        end;

        DefaultSaasModeUserProfileEmailAddressTok := 'cristina@contoso.com';
        if EnvironmentInformation.IsSaaS() then
            MSYodleeBankServiceSetup.VALIDATE("User Profile Email Address", DefaultSaasModeUserProfileEmailAddressTok);
    end;

    procedure CheckSetup();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        CobrandToken: Text;
        ConsumerToken: Text;
    begin
        GLBSetupPageIsCallee := true;

        Authenticate(CobrandToken, ConsumerToken);
        MSYodleeBankServiceSetup.GET();
        MSYodleeBankServiceSetup.TESTFIELD("Bank Feed Import Format");
        MSYodleeBankServiceSetup.TESTFIELD("User Profile Email Address");
        GeneralLedgerSetup.Get();
        if StrLen(GeneralLedgerSetup."LCY Code") <> 3 then
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
        ConsumerPassword: SecretText;
        Failure: Boolean;
        Disabled: Boolean;
    begin
        if not TryVerifyTermsOfUseAccepted(ErrorText) then
            exit(false);

        MSYodleeBankServiceSetup.GET();
        StoreConsumerName(MSYodleeBankServiceSetup."Consumer Name");

        CobrandToken := MSYodleeBankSession.GetCobrandSessionToken();
        if CobrandToken = '' then begin
            CobrandTokenExpired := true;
            CobrandTokenLastDateUpdated := CURRENTDATETIME();
            OnCobrandTokenExpiredSendTelemetry();
            if not GetCobrandToken(GetCobrandName(), GetCobrandPassword(), CobrandToken, ErrorText) then begin
                Failure := true;
                ErrorText := GetAdjustedErrorText(ErrorText, BadCobrandTxt);
                if IsStaleCredentialsErr(ErrorText) then
                    ErrorText := StaleCredentialsErr;
                LogActivityFailed(GetCobrandTokenTxt, ErrorText, FailureAction::IgnoreError, '', STRSUBSTNO(TelemetryActivityFailureTxt, GetCobrandTokenTxt, ErrorText), VERBOSITY::Error);
            end;
        end;

        ConsumerPassword := GetConsumerPassword();
        if not Failure then
            if (MSYodleeBankServiceSetup."Consumer Name" = '') and (ConsumerPassword.IsEmpty()) then
                if MSYodleeBankServiceSetup.Enabled then begin // if service is enabled we should create consumer
                    ConsumerTokenExpired := true;
                    OnConsumerUninitializedSendTelemetry();
                    if not RegisterConsumer(MSYodleeBankServiceSetup."Consumer Name", ConsumerPassword, ErrorText, CobrandToken) then
                        Failure := true;
                end else
                    Disabled := true; // since service not enabled we should not create a consumer account yet

        if (not Failure) and (not Disabled) then begin
            if not CobrandTokenExpired then
                ConsumerToken := MSYodleeBankSession.GeConsumerSessionToken()
            else
                ConsumerToken := '';
            if ConsumerToken = '' then begin
                ConsumerTokenExpired := true;
                ConsumerTokenLastDateUpdated := CURRENTDATETIME();
                OnConsumerTokenExpiredSendTelemetry();
                if not GetConsumerToken(MSYodleeBankServiceSetup."Consumer Name", GetConsumerPassword(), CobrandToken, ConsumerToken, ErrorText) then begin
                    Failure := true;
                    if ErrorText = BankStmtServiceInvalidConsumerErrTxt then
                        ErrorText := BadConsumerTxt
                    else
                        ErrorText += '\' + BadConsumerTxt;
                    if IsStaleCredentialsErr(ErrorText) then begin
                        ErrorText := StaleCredentialsErr;
                        LogActivityFailed(GetConsumerTokenTxt, ErrorText, FailureAction::RethrowError, '', STRSUBSTNO(TelemetryActivityFailureTxt, GetConsumerTokenTxt, ErrorText), VERBOSITY::Warning)
                    end else
                        LogActivityFailed(GetConsumerTokenTxt, ErrorText, FailureAction::IgnoreError, '', STRSUBSTNO(TelemetryActivityFailureTxt, GetConsumerTokenTxt, ErrorText), VERBOSITY::Error)
                end;
            end;
        end;

        if CobrandTokenExpired then
            MSYodleeBankSession.UpdateSessionTokens(CobrandToken, CobrandTokenLastDateUpdated, ConsumerToken, ConsumerTokenLastDateUpdated)
        else
            if ConsumerTokenExpired then
                MSYodleeBankSession.UpdateConsumerSessionToken(ConsumerToken, ConsumerTokenLastDateUpdated);

        if Failure then
            exit(false);

        LogActivitySucceed(AuthenticationTokenTxt, SuccessTxt, StrSubstNo(TelemetryActivitySuccessTxt, AuthenticationTokenTxt, SuccessTxt));
        exit(true);
    end;

    local procedure Authenticate(var CobrandToken: Text; var ConsumerToken: Text);
    var
        ErrorText: Text;
    begin
        if not TryAuthenticate(CobrandToken, ConsumerToken, ErrorText) then
            if not GLBDisableRethrowException then
                ERROR(ErrorText);
    end;

    local procedure GetCobrandToken(Username: Text; Password: Text; var CobrandToken: Text; var ErrorText: Text): Boolean;
    begin
        ExecuteWebServiceRequest(YodleeAPIStrings.GetCobrandTokenURL(), 'POST', YodleeAPIStrings.GetCobrandTokenBody(Username, Password), '', ErrorText, UserName);

        if ErrorText <> '' then
            exit(false);

        exit(GetResponseValue(YodleeAPIStrings.GetCobrandTokenXPath(), CobrandToken, ErrorText));
    end;

    local procedure GetConsumerToken(Username: Text; Password: Text; CobrandToken: Text; var ConsumerToken: Text; var ErrorText: Text): Boolean;
    var
        AuthorizationHeaderValue: Text;
    begin
        if ClientCredentialsAuthEnabled() then
            AuthorizationHeaderValue := ''
        else
            AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken, '');

        ExecuteWebServiceRequest(YodleeAPIStrings.GetConsumerTokenURL(), 'POST', YodleeAPIStrings.GetConsumerTokenBody(Username, Password, CobrandToken), AuthorizationHeaderValue, ErrorText, UserName);

        if ErrorText <> '' then
            exit(false);

        exit(GetResponseValue(YodleeAPIStrings.GetConsumerTokenXPath(), ConsumerToken, ErrorText));
    end;

    internal procedure ClientCredentialsAuthEnabled(): Boolean
    var
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
        AdminLoginName: Text;
    begin
        // don't use our client credentials if we are in demo company
        if EnvironmentInformation.IsSaaS() then
            if CompanyInformationMgt.IsDemoCompany() then
                exit(false);

        exit(GetYodleeAdminLoginName(AdminLoginName));
    end;

    local procedure GetFastlinkToken(CobrandToken: Text; ConsumerToken: Text; var FastLinkToken: Text; var ErrorText: Text): Boolean;
    var
        AuthorizationHeaderValue: Text;
        LoginName: Text;
    begin
        case ClientCredentialsAuthEnabled() of
            true:
                begin
                    AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(ConsumerToken);
                    LoginName := GetConsumerName();
                end;
            false:
                AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken, ConsumerToken);
        end;

        ExecuteWebServiceRequest(YodleeAPIStrings.GetFastLinkTokenURL(), YodleeAPIStrings.GetFastLinkTokenRequestMethod(), YodleeAPIStrings.GetFastLinkTokenBody(CobrandToken, ConsumerToken), AuthorizationHeaderValue, ErrorText, LoginName);

        if ErrorText <> '' then
            exit(false);

        exit(GetResponseValue(YodleeAPIStrings.GetFastLinkTokenXPath(), FastLinkToken, ErrorText));
    end;

    local procedure GetFastlinkData(ExtraParams: Text; var ErrorText: Text): Text;
    var
        TypeHelper: Codeunit "Type Helper";
        Data: Text;
        CobrandToken: Text;
        ConsumerToken: Text;
        FastlinkToken: Text;
    begin
        if not TryCheckServiceEnabled(ErrorText) then
            exit('');

        if not TryAuthenticate(CobrandToken, ConsumerToken, ErrorText) then
            exit('');

        case ClientCredentialsAuthEnabled() of
            true:
                Data := STRSUBSTNO(FastlinkDataClientCredTok,
                    '10003600',
                    'Bearer ' + ConsumerToken,
                    'true',
                    ExtraParams);
            false:
                begin
                    if not GetFastlinkToken(CobrandToken, ConsumerToken, FastlinkToken, ErrorText) then begin
                        ErrorText := GetAdjustedErrorText(ErrorText, FailedTxt);
                        if IsStaleCredentialsErr(ErrorText) then begin
                            ErrorText := StaleCredentialsErr;
                            LogActivityFailed(GetFastlinkTokenTxt, ErrorText, FailureAction::RethrowError, '', STRSUBSTNO(TelemetryActivityFailureTxt, GetFastLinkTokenTxt, ErrorText), VERBOSITY::Warning)
                        end else
                            LogActivityFailed(GetFastlinkTokenTxt, ErrorText, FailureAction::IgnoreError, '', STRSUBSTNO(TelemetryActivityFailureTxt, GetFastLinkTokenTxt, ErrorText), VERBOSITY::Error);
                        exit('');
                    end;

                    Data := STRSUBSTNO(FastlinkDataJsonTok,
                        '10003600',
                        ConsumerToken,// encoded by GetFastlinkToken
                        TypeHelper.UrlEncode(FastlinkToken),
                        'true',
                        ExtraParams);

                    LogActivitySucceed(GetFastlinkTokenTxt, SuccessTxt, STRSUBSTNO(TelemetryActivitySuccessTxt, GetFastLinkTokenTxt, SuccessTxt));
                end;
        end;

        exit(Data);
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
        exit(ErrorText = '');
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
        exit(ErrorText = '');
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
        exit(ErrorText = '');
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
        exit(ErrorText = '');
    end;

    procedure LinkBankAccount(var BankAccount: Record "Bank Account");
    begin
        CheckServiceEnabled();

        if ShowFastLinkPage(BankAccount.Name) then
            UpdateBankAccountLinking(BankAccount, false);
    end;

    procedure UnlinkBankAccount(BankAccount: Record "Bank Account"): Boolean;
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        UnlinkQuestion: Text;
        LinkedAccounts: Integer;
    begin
        LinkedAccounts := MSYodleeBankAccLink.COUNT();

        if not MSYodleeBankAccLink.GET(BankAccount."No.") then
            exit(false);

        if LinkedAccounts = 1 then
            UnlinkQuestion := PromptConsumerRemoveNoLinkingQst
        else
            UnlinkQuestion := UnlinkQst;

        if not CONFIRM(UnlinkQuestion) then begin
            MarkBankAccountAsUnlinked(BankAccount."No.");
            exit(false);
        end;

        UnlinkBankAccountFromYodlee(MSYodleeBankAccLink);
        exit(true);
    end;

    procedure UnlinkBankAccountFromYodlee(var MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link");
    var
        CobrandToken: Text;
        ConsumerToken: Text;
        Response: Text;
        ErrorText: Text;
        AccountID: Text;
        AuthorizationHeaderValue: Text;
        LoginName: Text;
    begin
        CheckServiceEnabled();
        Authenticate(CobrandToken, ConsumerToken);
        AccountID := MSYodleeBankAccLink."Online Bank Account ID";
        case ClientCredentialsAuthEnabled() of
            true:
                begin
                    AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(ConsumerToken);
                    LoginName := GetConsumerName();
                end;
            false:
                AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken, ConsumerToken);
        end;

        ExecuteWebServiceRequest(YodleeAPIStrings.GetUnlinkBankAccountURL(AccountID), YodleeAPIStrings.GetUnlinkBankAccountRequestMethod(), YodleeAPIStrings.GetUnlinkBankAccountBody(CobrandToken, ConsumerToken, AccountID), AuthorizationHeaderValue, ErrorText, LoginName);

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

        if MSYodleeBankAccLink.ISTEMPORARY() then
            MSYodleeBankAccLink.DELETE(true)
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

        if not MSYodleeBankServiceSetup."Accept Terms of Use" then
            exit(false); // Keep data.

        Authenticate(CobrandToken, ConsumerToken);

        if ClientCredentialsAuthEnabled() then
            AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(ConsumerToken)
        else
            AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken, ConsumerToken);

        ExecuteWebServiceRequest(YodleeAPIStrings.GetRemoveConsumerURL(), YodleeAPIStrings.GetRemoveConsumerRequestMethod(),
          YodleeAPIStrings.GetRemoveConsumerRequestBody(CobrandToken, ConsumerToken), AuthorizationHeaderValue, ErrorText, '');

        if not GetResponseValue('/', Response, ErrorText) then begin
            LogActivityFailed(RemoveConsumerTxt, ErrorText, FailureAction::IgnoreError, '', StrSubstNo(TelemetryActivityFailureTxt, RemoveConsumerTxt, ErrorText), Verbosity::Error);

            // We may be ignoring errors so we should still remove data if the consumer account is invalid (i.e. we could not get a valid consumer token)
            if (CobrandToken <> '') and (ConsumerToken <> '') then begin
                if GUIALLOWED() then
                    MESSAGE(FailedRemoveConsumerMsg); // Notify user - no error as we don't want to rollback if we get this far.
                exit(false); // Keep data so support can debug issue/decrease chance of creating orphaned accounts.
            end;
        end;

        LogActivitySucceed(RemoveConsumerTxt, SuccessRemoveConsumerTxt, StrSubstNo(TelemetryActivitySuccessTxt, RemoveConsumerTxt, SuccessRemoveConsumerTxt));

        MSYodleeBankAccLink.DELETEALL(true);

        // Update Setup
        MSYodleeBankServiceSetup.DeleteFromIsolatedStorage(MSYodleeBankServiceSetup."Consumer Password");

        MSYodleeBankServiceSetup.GET();
        CLEAR(MSYodleeBankServiceSetup."Consumer Password");
        CLEAR(MSYodleeBankServiceSetup."Consumer Name");
        MSYodleeBankServiceSetup.MODIFY(true);
        StoreConsumerName('');

        exit(true);
    end;

#if not CLEAN24
#pragma warning disable AL0432
    [NonDebuggable]
    [Obsolete('Use RegisterConsumer with SecretText data type for Password parameter.', '24.0')]
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

        if ClientCredentialsAuthEnabled() then
            AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken)
        else begin
            AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken, '');
            Password := COPYSTR(PasswordHelper.GeneratePassword(50), 1, 50);
        end;

        Session.LogMessage('0000DL9', StrSubstNo(StartingToRegisterUserTxt, UserName, LcyCode), Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
        ExecuteWebServiceRequest(YodleeAPIStrings.GetRegisterConsumerURL(), 'POST',
            YodleeAPIStrings.GetRegisterConsumerBody(CobrandToken, UserName, Password, Email, LcyCode), AuthorizationHeaderValue,
            ErrorText, '');

        if not GetResponseValue('/', Response, ErrorText) then begin
            ErrorText := GetAdjustedErrorText(ErrorText, FailedRegisterConsumerTxt);
            if IsStaleCredentialsErr(ErrorText) then begin
                ErrorText := StaleCredentialsErr;
                LogActivityFailed(RegisterConsumerTxt, ErrorText, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, RegisterConsumerTxt, ErrorText), Verbosity::Warning);
                exit(false);
            end;
            if ErrorText.Contains(BankStmtServiceStaleIllegalArgumentValueExceptionTxt) then begin
                ErrorText := RegisterConsumerVerifyLCYCodeTxt;
                LogActivityFailed(RegisterConsumerTxt, ErrorText, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, RegisterConsumerTxt, ErrorText), Verbosity::Warning);
            end else
                LogActivityFailed(RegisterConsumerTxt, ErrorText, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, RegisterConsumerTxt, ErrorText), Verbosity::Error);

            exit(false);
        end;

        LogActivitySucceed(RegisterConsumerTxt, SuccessRegisterConsumerTxt, StrSubstNo(TelemetryActivitySuccessTxt, RegisterConsumerTxt, SuccessRegisterConsumerTxt));

        MSYodleeBankServiceSetup.VALIDATE("Consumer Name", COPYSTR(Username, 1, MAXSTRLEN(MSYodleeBankServiceSetup."Consumer Name")));
        MSYodleeBankServiceSetup.SaveConsumerPassword(MSYodleeBankServiceSetup."Consumer Password", Password);
        MSYodleeBankServiceSetup.MODIFY(true);
        StoreConsumerName(MSYodleeBankServiceSetup."Consumer Name");
        exit(true);
    end;
#pragma warning restore AL0432
#endif

    [NonDebuggable]
    procedure RegisterConsumer(var Username: Text[250]; var Password: SecretText; var ErrorText: Text; CobrandToken: Text): Boolean;
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

        case ClientCredentialsAuthEnabled() of
            true:
                AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken);
            false:
                begin
                    AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken, '');
                    Password := COPYSTR(PasswordHelper.GenerateSecretPassword(50).Unwrap(), 1, 50);
                end;
        end;

        Session.LogMessage('0000DL9', StrSubstNo(StartingToRegisterUserTxt, UserName, LcyCode), Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
        ExecuteWebServiceRequest(YodleeAPIStrings.GetRegisterConsumerURL(), 'POST',
            YodleeAPIStrings.GetRegisterConsumerBody(CobrandToken, UserName, Password, Email, LcyCode), AuthorizationHeaderValue,
            ErrorText, '');

        if not GetResponseValue('/', Response, ErrorText) then begin
            ErrorText := GetAdjustedErrorText(ErrorText, FailedRegisterConsumerTxt);
            if IsStaleCredentialsErr(ErrorText) then begin
                ErrorText := StaleCredentialsErr;
                LogActivityFailed(RegisterConsumerTxt, ErrorText, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, RegisterConsumerTxt, ErrorText), Verbosity::Warning);
                exit(false);
            end;
            if ErrorText.Contains(BankStmtServiceStaleIllegalArgumentValueExceptionTxt) then begin
                ErrorText := RegisterConsumerVerifyLCYCodeTxt;
                LogActivityFailed(RegisterConsumerTxt, ErrorText, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, RegisterConsumerTxt, ErrorText), Verbosity::Warning);
            end else
                LogActivityFailed(RegisterConsumerTxt, ErrorText, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, RegisterConsumerTxt, ErrorText), Verbosity::Error);

            exit(false);
        end;

        LogActivitySucceed(RegisterConsumerTxt, SuccessRegisterConsumerTxt, StrSubstNo(TelemetryActivitySuccessTxt, RegisterConsumerTxt, SuccessRegisterConsumerTxt));

        MSYodleeBankServiceSetup.VALIDATE("Consumer Name", COPYSTR(Username, 1, MAXSTRLEN(MSYodleeBankServiceSetup."Consumer Name")));
        MSYodleeBankServiceSetup.SaveConsumerPassword(MSYodleeBankServiceSetup."Consumer Password", Password.Unwrap());
        MSYodleeBankServiceSetup.MODIFY(true);
        StoreConsumerName(MSYodleeBankServiceSetup."Consumer Name");
        exit(true);
    end;

    local procedure TryGetLinkedSites(var SiteListXML: Text; CobrandToken: Text; ConsumerToken: Text): Boolean;
    var
        ErrorText: Text;
        AuthorizationHeaderValue: Text;
        LoginName: Text;
    begin
        case ClientCredentialsAuthEnabled() of
            true:
                begin
                    AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(ConsumerToken);
                    LoginName := GetConsumerName();
                end;
            false:
                AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken, ConsumerToken);
        end;

        ExecuteWebServiceRequest(YodleeAPIStrings.GetLinkedSiteListURL(), YodleeAPIStrings.GetLinkedSiteListRequestMethod(), YodleeAPIStrings.GetLinkedSiteListBody(CobrandToken, ConsumerToken), AuthorizationHeaderValue, ErrorText, LoginName);

        exit(GetResponseValue(YodleeAPIStrings.GetRootXPath(), SiteListXML, ErrorText));
    end;

    local procedure GetLinkedSites(): Text;
    var
        SiteListXML: Text;
        CobrandToken: Text;
        ConsumerToken: Text;
    begin
        CheckServiceEnabled();
        Authenticate(CobrandToken, ConsumerToken);
        if not TryGetLinkedSites(SiteListXML, CobrandToken, ConsumerToken) then
            LogActivityFailed(GetBankSiteListTxt, CannotGetLinkedAccountsErr, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, GetBankSiteListTxt, CannotGetLinkedAccountsErr), Verbosity::Warning);
        LogActivitySucceed(GetBankSiteListTxt, SuccessTxt, StrSubstNo(TelemetryActivitySuccessTxt, GetBankSiteListTxt, SuccessTxt));
        exit(SiteListXML);
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
        if Summary <> '' then
            MESSAGE(Summary);
    end;

    local procedure GetLinkedBankAccountsFromSite(ProviderAccountId: Text; var AccountsNode: XmlNode);
    var
        CobrandToken: Text;
        ConsumerToken: Text;
        BankAccountXML: Text;
        ErrorText: Text;
        AuthorizationHeaderValue: Text;
        LoginName: Text;
    begin
        CheckServiceEnabled();
        Authenticate(CobrandToken, ConsumerToken);

        Session.LogMessage('00006PN', ProviderAccountId, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);

        case ClientCredentialsAuthEnabled() of
            true:
                begin
                    AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(ConsumerToken);
                    LoginName := GetConsumerName();
                end;
            false:
                AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken, ConsumerToken);
        end;

        ExecuteWebServiceRequest(YodleeAPIStrings.GetLinkedBankAccountsURL(ProviderAccountId), YodleeAPIStrings.GetLinkedBankAccountsRequestMethod(), YodleeAPIStrings.GetLinkedBankAccountsBody(CobrandToken, ConsumerToken, ProviderAccountId), AuthorizationHeaderValue, ErrorText, LoginName);

        if ErrorText <> '' then begin
            LogActivityFailed(
              GetBankAccListTxt, ErrorText, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, GetBankAccListTxt, ErrorText), Verbosity::Error);
            ERROR(ErrorText);
        end;

        if not GetResponseValue(YodleeAPIStrings.GetRootXPath(), BankAccountXML, ErrorText) then
            if IsStaleCredentialsErr(ErrorText) then begin
                ErrorText := StaleCredentialsErr;
                LogActivityFailed(GetBankAccListTxt, GetAdjustedErrorText(STRSUBSTNO(FailedToFindAccountTxt, ProviderAccountId), ErrorText), FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, GetBankAccListTxt, GetAdjustedErrorText(STRSUBSTNO(FailedToFindAccountTxt, ProviderAccountId), ErrorText)), Verbosity::Warning);
            end else
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
        LoginName: Text;
    begin
        CheckServiceEnabled();
        Authenticate(CobrandToken, ConsumerToken);
        case ClientCredentialsAuthEnabled() of
            true:
                begin
                    AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(ConsumerToken);
                    LoginName := GetConsumerName();
                end;
            false:
                AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(CobrandToken, ConsumerToken);
        end;

        ExecuteWebServiceRequest(YodleeAPIStrings.GetLinkedBankAccountURL(AccountId), 'GET', '', AuthorizationHeaderValue, ErrorText, LoginName);

        if ErrorText <> '' then begin
            LogActivityFailed(
              GetBankAccTxt, ErrorText, FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, GetBankAccTxt, ErrorText), Verbosity::Error);
            ERROR(ErrorText);
        end;

        if not GetResponseValue(YodleeAPIStrings.GetRootXPath(), BankAccountXML, ErrorText) then
            if IsStaleCredentialsErr(ErrorText) then begin
                ErrorText := StaleCredentialsErr;
                LogActivityFailed(GetBankAccTxt, GetAdjustedErrorText(STRSUBSTNO(FailedToFindAccountTxt, AccountId), ErrorText), FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, GetBankAccTxt, GetAdjustedErrorText(STRSUBSTNO(FailedToFindAccountTxt, AccountId), ErrorText)), Verbosity::Warning);
            end else
                LogActivityFailed(GetBankAccTxt, GetAdjustedErrorText(STRSUBSTNO(FailedToFindAccountTxt, AccountId), ErrorText), FailureAction::RethrowError, '', StrSubstNo(TelemetryActivityFailureTxt, GetBankAccTxt, GetAdjustedErrorText(STRSUBSTNO(FailedToFindAccountTxt, AccountId), ErrorText)), Verbosity::Error);

        LogActivitySucceed(GetBankAccListTxt, STRSUBSTNO(SuccessToFindAccountTxt, AccountId), StrSubstNo(TelemetryActivitySuccessTxt, GetBankAccTxt, STRSUBSTNO(SuccessToFindAccountTxt, AccountId)));

        LoadXMLNodeFromText(BankAccountXML, AccountNode);
    end;

    procedure LazyBankDataRefresh(OnlineBankId: Text; OnlineBankAccountId: Text; ToDate: Date);
    var
        AccountNode: XmlNode;
        RefreshMode: Text;
    begin
        if not VerifyRefreshBankData(OnlineBankId, OnlineBankAccountId, ToDate, AccountNode) then begin
            if IsAutomaticLogonPossible(OnlineBankAccountId) then
                exit;

            RefreshMode := 'MFA';
            Session.LogMessage('000023V', STRSUBSTNO(RefreshingBankAccountTelemetryTxt, OnlineBankId, RefreshMode), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            MFABankDataRefresh(OnlineBankId, OnlineBankAccountId);

            if not VerifyRefreshBankData(OnlineBankId, OnlineBankAccountId, ToDate, AccountNode) then
                MESSAGE(STRSUBSTNO(RefreshMsg, GetRefreshBankDate(OnlineBankId, OnlineBankAccountId, AccountNode)));
        end;
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
        repeat
            SLEEP(3000);
            Iterations += 1;
            SecondsToGo -= 3;
            ProgressDialog.Update(1, StrSubstNo(ProgressWindowUpdateTxt, SecondsToGo));
        until RefreshDone(OnlineBankAccountId) or (Iterations > 30);
        ProgressDialog.Close();

        if Iterations > 30 then begin
            Session.LogMessage('00008OE', STRSUBSTNO(RefreshingBankAccountsTooLongTelemetryTxt, OnlineBankId), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            MESSAGE(RefreshTakingTooLongTxt);
        end;
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
                exit(BankAccountRefreshInvalidCredentialsTxt);
            '404', 'TECH_ERROR':
                exit(BankAccountRefreshUnknownErrorTxt);
            '407', 'ACCOUNT_LOCKED':
                exit(BankAccountRefreshAccountLockedTxt);
            '409', 'UNEXPECTED_SITE_ERROR', 'SITE_UNAVAILABLE':
                exit(BankAccountRefreshBankDownTxt);
            '424':
                exit(BankAccountRefreshBankDownForMaintenanceTxt);
            '507', 'BETA_SITE_DEV_IN_PROGRESS':
                exit(BankAccountRefreshBankInBetaMaintenanceTxt);
            '508', 'REQUEST_TIME_OUT', 'SITE_SESSION_INVALIDATED':
                exit(BankAccountRefreshTimedOutTxt);
            '518', '519', '520', '522', '523', '524', '526', 'ADDL_AUTHENTICATION_REQUIRED', 'INVALID_ADDL_INFO_PROVIDED', 'NEW_AUTHENTICATION_REQUIRED':
                exit(BankAccountRefreshAdditionalAuthInfoNeededTxt);
        end;
        exit('');
    end;

    local procedure VerifyRefreshBankData(OnlineBankID: Text; OnlineBankAccountID: Text; TargetDate: Date; var AccountNode: XmlNode): Boolean;
    var
        RefreshDateTime: DateTime;
    begin
        RefreshDateTime := GetRefreshBankDate(OnlineBankID, OnlineBankAccountID, AccountNode);

        exit(RefreshDateTime > CREATEDATETIME(TargetDate, 0T)); // True if refreshed data is newer than the target date
    end;

    local procedure GetRefreshBankDate(OnlineBankID: Text; OnlineBankAccountID: Text; var AccountNode: XmlNode): DateTime;
    var
        RefreshDateTime: DateTime;
        RefreshDateTimeTxt: Text;
        ProviderId: Text;
        ProviderName: Text;
        OAuthMigrationStatus: Text;
        ConsentId: Text;
    begin
        CheckServiceEnabled();
        GetLinkedBankAccount(OnlineBankAccountID, AccountNode);
        ProviderName := FindNodeText(AccountNode, '/root/root/account/providerName');
        ProviderId := FindNodeText(AccountNode, '/root/root/account/providerId');
        OAuthMigrationStatus := FindNodeText(AccountNode, '/root/root/account/oauthMigrationStatus');
        ConsentId := FindNodeText(AccountNode, '/root/root/account/consentId');
        Session.LogMessage('0000A07', ProviderName, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
        Session.LogMessage('0000A08', ProviderId, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
        Session.LogMessage('0000INC', OAuthMigrationStatus, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok, 'ConsentId', ConsentId);
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
        if Node.SelectSingleNode(NodePath, FoundXmlNode) then begin
            if FoundXmlNode.IsXmlElement() then
                exit(FoundXmlNode.AsXmlElement().InnerText());

            if FoundXmlNode.IsXmlDocument() then begin
                FoundXmlNode.AsXmlDocument().GetRoot(RootElement);
                exit(RootElement.InnerText());
            end;
        end;

        exit('');
    end;

    local procedure FindNodeXML(Node: XmlNode; NodePath: Text): Text;
    var
        RootElement: XmlElement;
        FoundXmlNode: XmlNode;
    begin
        if Node.SelectSingleNode(NodePath, FoundXmlNode) then begin
            if FoundXmlNode.IsXmlElement() then
                exit(FoundXmlNode.AsXmlElement().InnerXml());

            if FoundXmlNode.IsXmlDocument() then begin
                FoundXmlNode.AsXmlDocument().GetRoot(RootElement);
                exit(RootElement.InnerXml());
            end;
        end;

        exit('');
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
        LoginName: Text;
    begin
        CheckServiceEnabled();
        Authenticate(CobrandToken, ConsumerToken);

        if ClientCredentialsAuthEnabled() then begin
            AuthorizationHeaderValue := YodleeAPIStrings.GetAuthorizationHeaderValue(ConsumerToken);
            LoginName := GetConsumerName();
        end
        else
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
            ErrorText, LoginName);

        // keep requesting more transactions until there is no more pagination link in the response header
        while PaginationLink <> '' do
            PaginationLink := ExecuteWebServiceRequest(
            PaginationLink,
            YodleeAPIStrings.GetTransactionSearchRequestMethod(),
            YodleeAPIStrings.GetTransactionSearchBody(CobrandToken, ConsumerToken, OnlineBankAccountId, FromDate, ToDate),
            AuthorizationHeaderValue,
            ErrorText, LoginName);

        Session.LogMessage('00001SX', STRSUBSTNO(TransactionsDownloadedTelemetryTxt, NumberOfLinkedBankAccounts()), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
    end;

    local procedure NumberOfLinkedBankAccounts(): Integer;
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        if not MSYodleeBankServiceSetup.GET() then
            exit(0);
        BankAccount.SETRANGE("Bank Stmt. Service Record ID", MSYodleeBankServiceSetup.RECORDID());
        exit(BankAccount.COUNT());
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

        foreach ProviderAccountNode in ProviderAccountsNodeList do begin
            ProviderAccountId := COPYSTR(FindNodeXML(ProviderAccountNode, YodleeAPIStrings.GetProviderAccountIdXPath()), 1, 50);

            if ProviderAccountId <> '' then begin
                GetLinkedBankAccountsFromSite(ProviderAccountID, BankAccountsRootNode);
                BankAccountsRootNode.SelectNodes(YodleeAPIStrings.GetBankAccountsListXPath(), BankAccountsNodeList);
                foreach BankAccountNode in BankAccountsNodeList do begin
                    BankAccountID := COPYSTR(FindNodeXML(BankAccountNode, YodleeAPIStrings.GetBankAccountIdXPath()), 1, 50);
                    if FindMatchingBankAccountId(TempBankAccount, ProviderAccountId, BankAccountID) then
                        TempBankAccount.DELETE()
                    else
                        CreateTempBankAccountFromBankStatement(ProviderAccountId, BankAccountID, BankAccountNode, MissingTempMSYodleeBankAccLink);
                end;
            end;
        end;

        exit(MarkUnlinkedRemainingBankAccounts(TempBankAccount));
    end;

    local procedure CreateNewAccountLinking(var BankAccount: Record "Bank Account"; var MissingTempMSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link" temporary; ForceManualLinking: Boolean): Integer;
    var
        LinkedAccounts: Integer;
    begin
        LinkedAccounts := MissingTempMSYodleeBankAccLink.COUNT();

        if LinkedAccounts = 0 then
            exit(0);

        if not ForceManualLinking then
            if LinkedAccounts = 1 then begin
                if BankAccount."No." <> '' then begin
                    if MarkBankAccountAsLinked(BankAccount."No.", MissingTempMSYodleeBankAccLink) then
                        exit(1);
                    exit(0);
                end;
                if CreateNewBankAccountFromTemp(BankAccount, MissingTempMSYodleeBankAccLink) then
                    exit(1);
                exit(0);
            end;

        exit(LinkNonLinkedBankAccounts(MissingTempMSYodleeBankAccLink, BankAccount));
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
        exit(Linked);
    end;

    local procedure LinkNonLinkedBankAccounts(var MissingTempMSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link" temporary; var BankAccount: Record "Bank Account"): Integer;
    begin
        COMMIT();
        PAGE.RUNMODAL(PAGE::"MS - Yodlee NonLinked Accounts", MissingTempMSYodleeBankAccLink);

        MissingTempMSYodleeBankAccLink.RESET();
        MissingTempMSYodleeBankAccLink.SETFILTER("Temp Linked Bank Account No.", '<>%1', '');
        if MissingTempMSYodleeBankAccLink.FINDFIRST() then
            BankAccount.GET(MissingTempMSYodleeBankAccLink."Temp Linked Bank Account No.");

        exit(MissingTempMSYodleeBankAccLink.COUNT());
    end;

    local procedure GetLinkingSummaryMessage(LinkedAccounts: Integer; UnlinkedAccounts: Integer; ForceManualLinking: Boolean; var MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link"): Text;
    var
        Summary: Text;
        UnlinkedText: Text;
    begin
        Summary := '';

        if LinkedAccounts = 1 then
            Summary := STRSUBSTNO(AccountLinkingSummaryMsg, MSYodleeBankAccLink.Name);

        if LinkedAccounts > 1 then
            Summary := STRSUBSTNO(AccountsLinkingSummaryMsg, LinkedAccounts);

        if UnlinkedAccounts > 0 then begin
            UnlinkedText := STRSUBSTNO(AccountUnLinkingSummaryMsg, UnlinkedAccounts);
            if Summary <> '' then
                Summary := STRSUBSTNO(ConcatAccountSummaryMsg, Summary, UnlinkedText)
            else
                Summary := UnlinkedText;
        end;

        if (Summary = '') and (MSYodleeBankAccLink."Online Bank Account ID" = '') then
            if ForceManualLinking then
                Summary := BankAccountsAreLinkedMsg
            else
                Summary := NoNewBankAccountsMsg;

        exit(Summary);
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
        if BankAccountCurrencyCode = '' then
            BankAccountCurrencyCode := GeneralLedgerSetup.GetCurrencyCode(BankAccountCurrencyCode);

        if (TempMSYodleeBankAccLink."Currency Code" <> '') then
            if (BankAccountCurrencyCode <> TempMSYodleeBankAccLink."Currency Code") then
                ERROR(CurrencyMismatchErr, BankAccountCurrencyCode, TempMSYodleeBankAccLink."Currency Code");

        if (TempMSYodleeBankAccLink."Currency Code" = '') and (BankAccount."Currency Code" <> '') then
            if not CONFIRM(STRSUBSTNO(LinkingToAccountWithEmptyCurrencyQst, TempMSYodleeBankAccLink.Name)) then
                exit(false);

        BankAccount.VALIDATE("Bank Stmt. Service Record ID", MSYodleeBankServiceSetup.RECORDID());
        // set default value for Transaction Import Timespan (in days)
        if BankAccount."Transaction Import Timespan" = 0 then
            BankAccount."Transaction Import Timespan" := 7;
        BankAccount.MODIFY(true);

        MSYodleeBankAccLink.TRANSFERFIELDS(TempMSYodleeBankAccLink);
        MSYodleeBankAccLink."No." := BankAccount."No.";
        MSYodleeBankAccLink.INSERT();

        LogActivitySucceed(STRSUBSTNO(LinkBankAccountTxt, BankAccount."No."), SuccessTxt, StrSubstNo(TelemetryActivitySuccessTxt, LinkBankAccountTxt, SuccessTxt));
        exit(true);
    end;

    procedure MarkBankAccountAsLinked(BankAccountNo: Code[20]; var TempMSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link" temporary): Boolean;
    var
        BankAccount: Record "Bank Account";
    begin
        BankAccount.GET(BankAccountNo);
        if not MarkBankAccountLinked(BankAccount, TempMSYodleeBankAccLink) then
            exit(false);

        TempMSYodleeBankAccLink."Temp Linked Bank Account No." := BankAccount."No.";
        TempMSYodleeBankAccLink.MODIFY();
        exit(true);
    end;

    procedure MarkBankAccountAsUnlinked(BankAccountNo: Code[20]);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        BankAccount: Record "Bank Account";
    begin
        if MSYodleeBankAccLink.GET(BankAccountNo) then
            MSYodleeBankAccLink.DELETE(true);

        if BankAccount.GET(BankAccountNo) then begin
            CLEAR(BankAccount."Bank Stmt. Service Record ID");
            if BankAccount."Automatic Stmt. Import Enabled" then
                BankAccount.VALIDATE("Automatic Stmt. Import Enabled", false);
            BankAccount.MODIFY(true);
            LogActivitySucceed(STRSUBSTNO(UnlinkBankAccountTxt, BankAccount."No."), SuccessTxt, StrSubstNo(TelemetryActivitySuccessTxt, UnLinkBankAccountTxt, SuccessTxt));
        end;
    end;

    local procedure MarkUnlinkedRemainingBankAccounts(var TempBankAccount: Record "Bank Account" temporary): Integer;
    begin
        TempBankAccount.RESET();
        if TempBankAccount.FINDSET() then
            repeat
                MarkBankAccountAsUnlinked(TempBankAccount."No.");
            until TempBankAccount.NEXT() = 0;
        exit(TempBankAccount.COUNT());
    end;

    local procedure FindMatchingBankAccountId(var TempBankAccount: Record "Bank Account" temporary; SiteID: Text; BankAccountID: Text): Boolean;
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        if (SiteID = '') or (BankAccountID = '') then
            exit(false);

        MSYodleeBankAccLink.SETRANGE("Online Bank Account ID", BankAccountID);
        MSYodleeBankAccLink.SETRANGE("Online Bank ID", SiteID);
        if not MSYodleeBankAccLink.FINDFIRST() then
            exit(false);
        exit(TempBankAccount.GET(MSYodleeBankAccLink."No."));
    end;

    local procedure CreateTempBankAccountFromBankStatement(SiteID: Text; BankAccountID: Text; BankAccountNode: XmlNode; var TempMSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link" temporary);
    var
        CurrBalCurrencyCode: Text;
        AvlblBalCurrencyCode: Text;
        RunningBalanceCurrencyCode: Text;
        CurrencyCode: Text;
        BankAccountName: Text;
    begin
        if (SiteID = '') or (BankAccountID = '') then
            exit;

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

        if RunningBalanceCurrencyCode <> '' then
            CurrencyCode := RunningBalanceCurrencyCode;

        if (CurrencyCode = '') and (CurrBalCurrencyCode <> '') then
            CurrencyCode := CurrBalCurrencyCode;

        if (CurrencyCode = '') and (AvlblBalCurrencyCode <> '') then
            CurrencyCode := AvlblBalCurrencyCode;

        if CurrencyCode = '' then
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

        if not TempMSYodleeBankAccLink.INSERT() then
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
        if not TryVerifyTermsOfUseAccepted(ErrorText) then
            ERROR(ErrorText);
    end;

    local procedure TryVerifyTermsOfUseAccepted(var ErrorText: Text): Boolean;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        MSYodleeBankServiceSetup.GET();
        if MSYodleeBankServiceSetup."Accept Terms of Use" then
            exit(true);

        if not GUIALLOWED() then begin
            ErrorText := TermsOfUseNotAcceptedErr;
            exit(false);
        end;

        PAGE.RUNMODAL(PAGE::"MS - Yodlee Terms of use");

        MSYodleeBankServiceSetup.GET();

        if not MSYodleeBankServiceSetup."Accept Terms of Use" then begin
            ErrorText := TermsOfUseNotAcceptedErr;
            exit(false);
        end;

        exit(true);
    end;

    local procedure GetResponseValue(XPath: Text; var Response: Text; var ErrorText: Text): Boolean;
    var
        MSYodleeBankSession: Record "MS - Yodlee Bank Session";
        TempBlob: Codeunit "Temp Blob";
        Success: Boolean;
    begin
        Success := TryGetResponseValue(XPath, Response, TempBlob, ErrorText);
        if Success then
            exit(true);
        if ErrorText = StaleCredentialsErr then
            MSYodleeBankSession.ResetSessionTokens();
        exit(false);
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
        if not GetJsonStructure.JsonToXMLCreateDefaultRoot(GLBResponseInStream, OutStream) then begin
            ErrorText := InvalidResponseErr;
            exit(false);
        end;

        TempBlob.CreateInStream(XmlInStream);
        while not XmlInStream.EOS() do begin
            XmlInStream.ReadText(InStreamText);
            XmlResponseText += InStreamText;
        end;

        RemoveInvalidXMLCharacters(XmlResponseText);
        XmlDocument.ReadFrom(XmlResponseText, XmlDoc);
        XmlDoc.GetRoot(XmlElem);
        XMLRootNode := XmlElem.AsXmlNode();

        if not CheckForErrors(XMLRootNode, ErrorText) then
            exit(false);

        if XPath = YodleeAPIStrings.GetRootXPath() then
            XmlDoc.WriteTo(Response)
        else
            Response := FindNodeXML(XMLRootNode, XPath);
        exit(true);
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
        if MSYodleeBankAccLink.FINDSET() then
            repeat
                if BankAccount.GET(MSYodleeBankAccLink."No.") then begin
                    TempBankAccount := BankAccount;
                    TempBankAccount.INSERT();
                end;
            until MSYodleeBankAccLink.NEXT() = 0;
    end;

    local procedure TryCheckCredentials(var ErrorText: Text): Boolean;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        if HasCustomCredentialsInAzureKeyVault() then
            exit(true);

        if not MSYodleeBankServiceSetup.GET() or
           not (MSYodleeBankServiceSetup.HasCobrandPassword(MSYodleeBankServiceSetup."Cobrand Password") or MSYodleeBankServiceSetup.HasClientSecret(MSYodleeBankServiceSetup."Client Secret"))
        then
            if not GLBSetupPageIsCallee and GUIALLOWED() then begin
                if CONFIRM(MissingCredentialsQst, true) then begin
                    COMMIT();
                    PAGE.RUNMODAL(PAGE::"MS - Yodlee Bank Service Setup", MSYodleeBankServiceSetup);
                    if not MSYodleeBankServiceSetup.GET() or
                       not (MSYodleeBankServiceSetup.HasCobrandPassword(MSYodleeBankServiceSetup."Cobrand Password") or MSYodleeBankServiceSetup.HasClientSecret(MSYodleeBankServiceSetup."Client Secret"))
                    then
                        ErrorText := MissingCredentialsErr;
                end else
                    ErrorText := MissingCredentialsErr;
            end else
                ErrorText := MissingCredentialsErr;

        exit(ErrorText = '');
    end;

    local procedure UrlIsBankStatementImport(URL: Text): Boolean
    begin
        exit(URL.ToLower().Contains('transactions'));
    end;

    [NonDebuggable]
    local procedure ExecuteWebServiceRequest(URL: Text; Method: Text[6]; BodyText: Text; AuthorizationHeaderValue: Text; var ErrorText: Text; LoginName: Text) PaginationLink: Text
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
        if not TryCheckCredentials(ErrorText) then
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
        if LoginName <> '' then
            if ClientCredentialsAuthEnabled() then
                RequestHeaders.TryAddWithoutValidation('LoginName', LoginName);
        if AuthorizationHeaderValue <> '' then
            RequestHeaders.TryAddWithoutValidation('Authorization', AuthorizationHeaderValue);
        HttpRequestMessage.SetRequestUri(URL);
        HttpRequestMessage.Method(Method);
        if BodyText <> '' then begin
            ReqHttpContent.GetHeaders(ContentHeaders);
            ReqHttpContent.WriteFrom(BodyText);
            ContentHeaders.Remove('Content-Type');
            if URL.EndsWith('auth/token') then
                ContentHeaders.Add('Content-Type', 'application/x-www-form-urlencoded')
            else
                ContentHeaders.Add('Content-Type', YodleeAPIStrings.GetWebRequestContentType());
            HttpRequestMessage.Content(ReqHttpContent);
        end;

        // Set tracing
        MSYodleeBankServiceSetup.GET();
        GLBTraceLogEnabled := MSYodleeBankServiceSetup."Log Web Requests";

        CLEAR(ResponseTempBlob);
        ResponseTempBlob.CreateInStream(GLBResponseInStream);

        if GUIALLOWED() then
            ProcessingDialog.Open(ProcessingWindowMsg);

        if UrlIsBankStatementImport(URL) then
            FeatureTelemetry.LogUptake('0000GY0', 'Yodlee', Enum::"Feature Uptake Status"::Used);

        IsSuccessful := HttpClient.Send(HttpRequestMessage, GetHttpResponseMessage);

        if GUIALLOWED() then
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

        if not GetHttpResponseMessage.IsSuccessStatusCode() then
            Errortext := STRSUBSTNO(RemoteServerErr, GetHttpResponseMessage.HttpStatusCode(), GetHttpResponseMessage.ReasonPhrase());

        if UrlIsBankStatementImport(URL) then begin
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
            if BankFeedText = '{}' then
                Session.LogMessage('0000JWQ', BankFeedText, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            if GLBTraceLogEnabled then
                ActivityLog.LogActivity(MSYodleeBankServiceSetup.RecordId(), ActivityLog.Status::Success, YodleeResponseTxt, 'gettransactions', BankFeedText);
        end;

        GetHttpResponseMessage.Content().ReadAs(ResponseTxt);
        if URL.ToLower().Contains('accounts?status=active') then begin
            Session.LogMessage('0000BI7', ResponseTxt, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            if GLBTraceLogEnabled then
                ActivityLog.LogActivity(MSYodleeBankServiceSetup.RecordId(), ActivityLog.Status::Success, YodleeResponseTxt, 'getlinkedbankaccounts', ResponseTxt);
        end;

        if URL.ToLower().Contains('accounts?accountid') then begin
            Session.LogMessage('0000BLP', ResponseTxt, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            if GLBTraceLogEnabled then
                ActivityLog.LogActivity(MSYodleeBankServiceSetup.RecordId(), ActivityLog.Status::Success, YodleeResponseTxt, 'getlinkedbankaccount', ResponseTxt);
        end;

        if URL.ToLower().Contains(YodleeAPIStrings.GetRegisterConsumerURL()) then begin
            Session.LogMessage('0000DLA', ResponseTxt, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            if GLBTraceLogEnabled then
                ActivityLog.LogActivity(MSYodleeBankServiceSetup.RecordId(), ActivityLog.Status::Success, YodleeResponseTxt, YodleeAPIStrings.GetRegisterConsumerURL(), ResponseTxt);
        end;

        if URL.ToLower().Contains(YodleeAPIStrings.GetLinkedSiteListURL()) then begin
            Session.LogMessage('0000G9J', ResponseTxt, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
            if GLBTraceLogEnabled then
                ActivityLog.LogActivity(MSYodleeBankServiceSetup.RecordId(), ActivityLog.Status::Success, YodleeResponseTxt, YodleeAPIStrings.GetLinkedSiteListURL(), ResponseTxt);
        end;

        Commit();
    end;

    procedure CheckServiceEnabled();
    var
        ErrorText: Text;
    begin
        if not TryCheckServiceEnabled(ErrorText) then
            ERROR(ErrorText);
    end;

    procedure TryCheckServiceEnabled(var ErrorText: Text): Boolean;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        if not MSYodleeBankServiceSetup.GET() then begin
            MSYodleeBankServiceSetup.INIT();
            SetValuesToDefault(MSYodleeBankServiceSetup);
            MSYodleeBankServiceSetup.INSERT(true);
            Commit();
        end;

        if (not MSYodleeBankServiceSetup.Enabled) and GUIALLOWED() then begin
            if not MSYodleeBankServiceSetup.HasDefaultCredentials() then begin
                ErrorText := NotEnabledErr;
                exit(false);
            end;

            if not CONFIRM(EnableYodleeQst) then begin
                ErrorText := NotEnabledErr;
                exit(false);
            end;

            MSYodleeBankServiceSetup.VALIDATE(Enabled, true);
            MSYodleeBankServiceSetup.MODIFY(true);
            COMMIT();
        end;

        if not MSYodleeBankServiceSetup."Accept Terms of Use" then begin
            if not TryVerifyTermsOfUseAccepted(ErrorText) then
                exit(false);
            COMMIT();
        end;
        exit(true);
    end;

    procedure EnableServiceInSaas();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        if not MSYodleeBankServiceSetup.GET() then begin
            MSYodleeBankServiceSetup.INIT();
            SetValuesToDefault(MSYodleeBankServiceSetup);
            MSYodleeBankServiceSetup.INSERT(true);
        end;

        if (not MSYodleeBankServiceSetup.Enabled) and GUIALLOWED() then begin
            if not MSYodleeBankServiceSetup.HasDefaultCredentials() then
                ERROR(NotEnabledErr);

            MSYodleeBankServiceSetup.VALIDATE(Enabled, true);
            MSYodleeBankServiceSetup.MODIFY(true);
            COMMIT();
        end;

        if not MSYodleeBankServiceSetup."Accept Terms of Use" then begin
            VerifyTermsOfUseAccepted();
            COMMIT();
        end;
    end;

    local procedure CheckForErrors(XMLRootNode: XmlNode; var ErrorText: Text): Boolean;
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ErrorCode: Text;
    begin
        ErrorText := FindNodeText(XMLRootNode, YodleeAPIStrings.GetErrorDetailXPath());
        if ErrorText <> '' then begin
            ErrorCode := FindNodeText(XMLRootNode, YodleeAPIStrings.GetErrorCodeXPath());
            if ErrorCode = '415' then begin
                ErrorText := StaleCredentialsErr;
                FeatureTelemetry.LogError('0000GYL', 'Yodlee', 'Getting Response Value', StaleCredentialsErr);
            end;
            exit(false);
        end;

        ErrorText := FindNodeText(XMLRootNode, YodleeAPIStrings.GetExceptionXPath());
        if ErrorText <> '' then
            exit(false);

        if FindNodeText(XMLRootNode, YodleeAPIStrings.GetErrorOccurredXPath()) = 'true' then begin
            ErrorText := FindNodeText(XMLRootNode, YodleeAPIStrings.GetDetailedMessageXPath());
            if ErrorText = '' then begin
                ErrorText := UnknownErr;
                FeatureTelemetry.LogError('0000GYM', 'Yodlee', 'Getting Response Value', UnknownErr);
            end;

            exit(false);
        end;

        exit(true);
    end;

    [Scope('OnPrem')]
    procedure GetCobrandEnvironmentName(): Text;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        SecretValue: Text;
    begin
        if GetYodleeCobrandEnvironmentNameFromAzureKeyVault(SecretValue) then
            exit(SecretValue);

        MSYodleeBankServiceSetup.GET();
        exit(MSYodleeBankServiceSetup.GetCobrandEnvironmentName(MSYodleeBankServiceSetup."Cobrand Environment Name"));
    end;

    [Scope('OnPrem')]
    procedure GetCobrandName(): Text;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        SecretValue: Text;
    begin
        if ClientCredentialsAuthEnabled() then begin
            GetYodleeAdminLoginName(SecretValue);
            exit(SecretValue);
        end;

        if GetYodleeCobrandNameFromAzureKeyVault(SecretValue) then
            exit(SecretValue);

        MSYodleeBankServiceSetup.GET();
        exit(MSYodleeBankServiceSetup.GetCobrandName(MSYodleeBankServiceSetup."Cobrand Name"));
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    procedure GetCobrandPassword(): Text;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        SecretValue: Text;
    begin
        if ClientCredentialsAuthEnabled() then
            exit('');

        if GetYodleeCobrandPassFromAzureKeyVault(SecretValue) then
            exit(SecretValue);

        MSYodleeBankServiceSetup.GET();
        exit(MSYodleeBankServiceSetup.GetCobrandPassword(MSYodleeBankServiceSetup."Cobrand Password"));
    end;

    [NonDebuggable]
    [Scope('OnPrem')]
    procedure GetConsumerPassword(): Text;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        if ClientCredentialsAuthEnabled() then
            exit('');

        MSYodleeBankServiceSetup.GET();
        exit(MSYodleeBankServiceSetup.GetPassword(MSYodleeBankServiceSetup."Consumer Password"));
    end;

    internal procedure GetConsumerName(): Text;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        MSYodleeBankServiceSetup.Get();
        exit(MSYodleeBankServiceSetup."Consumer Name");
    end;

    [Scope('OnPrem')]
    procedure GetYodleeFastlinkUrl(): Text;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        SecretValue: Text;
    begin
        if GetAzureKeyVaultSecret(SecretValue, YodleeFastlinkUrlTok) then
            exit(SecretValue);

        MSYodleeBankServiceSetup.GET();
        MSYodleeBankServiceSetup.TESTFIELD("Bank Acc. Linking URL");
        exit(MSYodleeBankServiceSetup."Bank Acc. Linking URL");
    end;

    internal procedure UsingFastlink4(): Boolean;
    begin
        exit(GetYodleeFastlinkUrl().Contains('fl4'));
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure HasCustomCredentialsInAzureKeyVault(): Boolean;
    var
        SecretValue: Text;
        YodleeAdminLoginName: Text;
        HasCustomCredentials: Boolean;
    begin
        HasCustomCredentials := GetAzureKeyVaultSecret(SecretValue, YodleeCobrandSecretNameTok);
        HasCustomCredentials := (HasCustomCredentials or (GetAzureKeyVaultSecret(YodleeAdminLoginName, YodleeAdminLoginNameSecretNameTok)));
        exit(HasCustomCredentials);
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
    procedure GetYodleeAdminLoginNameFromAzureKeyVault(var YodleeAdminLoginNameValue: Text): Boolean;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(YodleeAdminLoginNameSecretNameTok, YodleeAdminLoginNameValue) then
            exit(false);

        if YodleeAdminLoginNameValue = '' then
            exit(false);

        exit(true);
    end;

    [Scope('OnPrem')]
    procedure GetYodleeCobrandEnvironmentNameFromAzureKeyVault(var YodleeCobrandEnvironmentNameValue: Text): Boolean;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        if ClientCredentialsAuthEnabled() then
            exit(false);

        if not AzureKeyVault.GetAzureKeyVaultSecret(YodleeCobrandSecretEnvironmentNameTok, YodleeCobrandEnvironmentNameValue) then
            exit(false);

        if YodleeCobrandEnvironmentNameValue = '' then
            exit(false);

        exit(true);
    end;

    [Scope('OnPrem')]
    procedure GetYodleeAdminLoginName(var YodleeAdminLoginNameValue: Text): Boolean;
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        case Environmentinformation.IsSaaS() of
            true:
                exit(GetYodleeAdminLoginNameFromAzureKeyVault(YodleeAdminLoginNameValue));
            false:
                begin
                    MSYodleeBankServiceSetup.Get();
                    YodleeAdminLoginNameValue := MSYodleeBankServiceSetup.GetAdminLoginName(MSYodleeBankServiceSetup."Admin Login Name");
                end;
        end;
        exit(YodleeAdminLoginNameValue <> '')
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
    [NonDebuggable]
    procedure GetYodleeClientIdFromAzureKeyVault(var YodleeClientIdValue: Text): Boolean;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(YodleeClientIdSecretNameTok, YodleeClientIdValue) then
            exit(false);

        if YodleeClientIdValue = '' then
            exit(false);

        exit(true);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetYodleeClientSecretFromAzureKeyVault(var YodleeClientSecretValue: Text): Boolean;
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(YodleeClientSecretSecretNameTok, YodleeClientSecretValue) then
            exit(false);

        if YodleeClientSecretValue = '' then
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
        IgnoreError := GLBDisableRethrowException or (Action = Action::IgnoreError) or IsEmptyMessage;

        if IgnoreError then
            ActivityMessage += '\' + ErrorsIgnoredTxt
        else
            if Action = Action::RethrowErrorWithConfirm then begin
                IgnoreError := CONFIRM(ConfirmMessage);
                if IgnoreError then
                    ActivityMessage += '\' + ErrorsIgnoredByUserTxt;
            end;

        SendTelemetryAfterFailedActivity(VerbosityLevel, TelemetryMsg);

        MSYodleeBankServiceSetup.Get();
        if GLBTraceLogEnabled then
            ActivityLog.LogActivity(MSYodleeBankServiceSetup.RecordId(), ActivityLog.Status::Failed, LoggingConstTxt, ActivityDescription, ActivityMessage);

        if IsEmptyMessage and GLBTraceLogEnabled then
            ActivityLog.SetDetailedInfoFromStream(GLBResponseInStream);

        if GLBDisableRethrowException then
            exit;

        COMMIT(); // do not roll back logging

        if not IgnoreError then
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
    local procedure HandleVANRegisterServiceConnection(var ServiceConnection: Record 1400)
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        RecRef: RecordRef;
    begin
        if not MSYodleeBankServiceSetup.GET() then begin
            MSYodleeBankServiceSetup.INIT();
            SetValuesToDefault(MSYodleeBankServiceSetup);
            MSYodleeBankServiceSetup.INSERT(true);
        end;

        RecRef.GETTABLE(MSYodleeBankServiceSetup);

        if MSYodleeBankServiceSetup.Enabled then
            ServiceConnection.Status := ServiceConnection.Status::Enabled
        else
            ServiceConnection.Status := ServiceConnection.Status::Disabled;

        ServiceConnection.InsertServiceConnection(
          ServiceConnection, RecRef.RECORDID(), YodleeServiceNameTxt,
          MSYodleeBankServiceSetup."Service URL", PAGE::"MS - Yodlee Bank Service Setup");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Process Bank Acc. Rec Lines", 'OnLogTelemetryAfterImportBankStatement', '', false, false)]
    local procedure HandleOnLogTelemetryAfterImportBankStatement(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; NumberOfLinesImported: Integer);
    var
        BankAccount: Record "Bank Account";
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        EnvironmentInformation: Codeunit "Environment Information";
        Dimensions: Dictionary of [Text, Text];
        AccountNode: XmlNode;
        ProviderName: Text;
    begin
        if not MSYodleeBankServiceSetup.Get() then
            exit;

        if not MSYodleeBankServiceSetup.Enabled then
            exit;

        if not EnvironmentInformation.IsSaaS() then
            exit;

        if not BankAccount.Get(BankAccReconciliation."Bank Account No.") then
            exit;

        if not IsLinkedToYodleeService(BankAccount) then
            exit;

        if not MSYodleeBankAccLink.Get(BankAccount."No.") then
            exit;

        GetLinkedBankAccount(MSYodleeBankAccLink."Online Bank Account ID", AccountNode);
        ProviderName := FindNodeText(AccountNode, '/root/root/account/providerName');
        Dimensions.Add('Category', YodleeTelemetryCategoryTok);
        Dimensions.Add('Bank Name', ProviderName);
        Dimensions.Add('ProviderAccountId', MSYodleeBankAccLink."Online Bank Account ID");
        Dimensions.Add('NumberOfTransactionsImported', Format(NumberOfLinesImported));
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
        if not TestRecordRef.GET(BankAccount."Bank Stmt. Service Record ID") then
            exit(false);
        if not DataTypeManagement.GetRecordRef(BankAccount."Bank Stmt. Service Record ID", RecordRef) then
            exit(false);

        exit(RecordRef.NUMBER() = DATABASE::"MS - Yodlee Bank Service Setup");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnGetDataExchangeDefinitionEvent', '', false, false)]
    local procedure OnGetDataExchangeDefinition(Sender: Record "Bank Account"; var DataExchDefCodeResponse: Code[20]; var Handled: Boolean);
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        MSYodleeDataExchangeDef: Record "MS - Yodlee Data Exchange Def";
        DataExchDef: Record "Data Exch. Def";
    begin
        // identify that we are the subscriber supposed to handle the request
        if Handled then
            exit;
        if MSYodleeBankServiceSetup.GET(Sender."Bank Stmt. Service Record ID") then begin
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
            Handled := true;
        end;
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
        if Handled then
            exit;

        if not BankAccount.GET(DataExchIdentifier."Related Record") then
            exit;

        if not IsLinkedToYodleeService(BankAccount) then
            exit;

        FromDate := CALCDATE(STRSUBSTNO(LabelDateExprTok, -BankAccount."Transaction Import Timespan"), TODAY());
        ToDate := TODAY();

        // open filter page
        if GUIALLOWED() then begin
            if FromDate = ToDate then
                FromDate := CALCDATE('<-7D>', ToDate);
            BankStatementFilter.SetDates(FromDate, ToDate);
            BankStatementFilter.LOOKUPMODE := true;
            if not (BankStatementFilter.RUNMODAL() = ACTION::LookupOK) then
                exit;
            BankStatementFilter.GetDates(FromDate, ToDate);
        end;

        // Get data and pass back to caller
        MSYodleeBankAccLink.GET(BankAccount."No.");
        LazyBankDataRefresh(MSYodleeBankAccLink."Online Bank ID", MSYodleeBankAccLink."Online Bank Account ID", ToDate);
        GetTransactions(MSYodleeBankAccLink."Online Bank Account ID", FromDate, ToDate);
        LogActivitySucceed(GetBankTxTxt, STRSUBSTNO(SuccessGetTxForAccTxt, BankAccount."No."), StrSubstNo(TelemetryActivitySuccessTxt, GetBankTxTxt, SuccessGetTxForAccTxt));

        ReturnOnlyPostedTransactions(TempBlobResponse);
        Handled := true;
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
            if not GetJsonStructure.JsonToXMLCreateDefaultRoot(BankFeedJSONInStream, OutStreamWithAllTransactions) then
                Session.LogMessage('0000M0I', InvalidResponseErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
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
        if IsLinked = true then
            exit;

        if not IsLinkedToYodleeService(BankAccount) then
            exit;

        if MSYodleeBankAccLink.GET(BankAccount."No.") then
            if MSYodleeBankAccLink."Online Bank Account ID" <> '' then
                IsLinked := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnCheckAutoLogonPossibleEvent', '', false, false)]
    local procedure OnCheckAutoLogonPossible(var BankAccount: Record "Bank Account"; var AutoLogonPossible: Boolean);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        if AutoLogonPossible = false then
            exit;

        if not IsLinkedToYodleeService(BankAccount) then
            exit;

        if MSYodleeBankAccLink.GET(BankAccount."No.") then
            if not MSYodleeBankAccLink."Automatic Logon Possible" then
                AutoLogonPossible := false;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnUnlinkStatementProviderEvent', '', false, false)]
    local procedure OnUnlinkStatementProvider(var BankAccount: Record "Bank Account"; Handled: Boolean);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        LinkRemovedFromYodlee: Boolean;
    begin
        if Handled then
            exit;

        if not IsLinkedToYodleeService(BankAccount) then
            exit;

        if not ValidateNotDemoCompanyOnSaas() then
            exit;

        LinkRemovedFromYodlee := UnlinkBankAccount(BankAccount);

        if MSYodleeBankAccLink.ISEMPTY() and LinkRemovedFromYodlee then
            UnregisterConsumer();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnLinkStatementProviderEvent', '', false, false)]
    local procedure OnLinkStatementProvider(var BankAccount: Record "Bank Account"; StatementProvider: Text);
    begin
        if StatementProvider <> YodleeServiceIdentifierTxt then
            exit;

        if not ValidateNotDemoCompanyOnSaas() then
            exit;

        LinkBankAccount(BankAccount);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnRefreshStatementProviderEvent', '', false, false)]
    local procedure OnRefreshStatementProvider(var BankAccount: Record "Bank Account"; StatementProvider: Text);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        if StatementProvider <> YodleeServiceIdentifierTxt then
            exit;

        if not ValidateNotDemoCompanyOnSaas() then
            exit;

        if not IsLinkedToYodleeService(BankAccount) then
            exit;

        MSYodleeBankAccLink.GET(BankAccount."No.");
        MFABankDataRefresh(MSYodleeBankAccLink."Online Bank ID", MSYodleeBankAccLink."Online Bank Account ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnRenewAccessConsentStatementProviderEvent', '', false, false)]
    local procedure OnRenewAccessConsentStatementProvider(var BankAccount: Record "Bank Account"; StatementProvider: Text);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        if StatementProvider <> YodleeServiceIdentifierTxt then
            exit;

        if not ValidateNotDemoCompanyOnSaas() then
            exit;

        if not IsLinkedToYodleeService(BankAccount) then
            exit;

        MSYodleeBankAccLink.GET(BankAccount."No.");
        OnlineBankAccountAccessConsent(MSYodleeBankAccLink."Online Bank Account ID");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnEditAccountStatementProviderEvent', '', false, false)]
    local procedure OnEditAccountStatementProvider(var BankAccount: Record "Bank Account"; StatementProvider: Text);
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        if StatementProvider <> YodleeServiceIdentifierTxt then
            exit;

        if not ValidateNotDemoCompanyOnSaas() then
            exit;

        if not IsLinkedToYodleeService(BankAccount) then
            exit;

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
        if StatementProvider <> YodleeServiceIdentifierTxt then
            exit;
        if not ValidateNotDemoCompanyOnSaas() then
            exit;

        // In simple linking scenario, user accept the terms and condition in the wizard.
        SetAcceptTermsOfUse(MSYodleeBankServiceSetup);
        EnableServiceInSaas();

        if not ShowFastLinkPage('') then
            exit;

        SiteListXML := GetLinkedSites();
        MatchBankAccountIDs(SiteListXML, TempMissingMSYodleeBankAccLink);

        if TempMissingMSYodleeBankAccLink.COUNT() = 0 then begin
            UnregisterConsumer();
            MESSAGE(NoAccountLinkedMsg);
        end else begin
            TempMissingMSYodleeBankAccLink.FINDSET();
            repeat
                OnlineBankAccLink.INIT();
                OnlineBankAccLink.TRANSFERFIELDS(TempMissingMSYodleeBankAccLink);
                OnlineBankAccLink.ProviderId := YodleeServiceIdentifierTxt;
                OnlineBankAccLink.INSERT();
            until TempMissingMSYodleeBankAccLink.NEXT() = 0
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnDisableStatementProviderEvent', '', false, false)]
    local procedure OnDisableStatementProvider(ProviderName: Text);
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        if ProviderName <> YodleeServiceIdentifierTxt then
            exit;

        if not MSYodleeBankServiceSetup.GET() then
            exit;

        if MSYodleeBankServiceSetup.Enabled = false then
            exit;

        MSYodleeBankServiceSetup.Validate(Enabled, false);
        MSYodleeBankServiceSetup.Modify(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnUpdateBankAccountLinkingEvent', '', false, false)]
    local procedure OnUpdateBankAccountLinking(var BankAccount: Record "Bank Account"; StatementProvider: Text);
    begin
        if StatementProvider <> YodleeServiceIdentifierTxt then
            exit;

        if not ValidateNotDemoCompanyOnSaas() then
            exit;

        UpdateBankAccountLinking(BankAccount, true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnGetStatementProvidersEvent', '', false, false)]
    local procedure OnGetStatementProviders(var TempNameValueBuffer: Record 823 temporary);
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
    begin
        if HasCustomCredentialsInAzureKeyVault() then begin
            PopulateNameValueBufferWithYodleeInfo(TempNameValueBuffer);
            exit;
        end;

        if MSYodleeBankServiceSetup.GET() then;
        if (not MSYodleeBankServiceSetup.HasCobrandName(MSYodleeBankServiceSetup."Cobrand Name")) and (not MSYodleeBankServiceSetup.HasAdminLoginName(MSYodleeBankServiceSetup."Admin Login Name")) then
            exit;

        PopulateNameValueBufferWithYodleeInfo(TempNameValueBuffer);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnMarkAccountLinkedEvent', '', false, false)]
    local procedure OnMarkAccountLinked(var OnlineBankAccLink: Record "Online Bank Acc. Link"; var BankAccount: Record "Bank Account");
    var
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
    begin
        if OnlineBankAccLink.ProviderId <> YodleeServiceIdentifierTxt then
            exit;

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
        if not MSYodleeBankServiceSetup.GET() then begin
            MSYodleeBankServiceSetup.INIT();
            SetValuesToDefault(MSYodleeBankServiceSetup);
            MSYodleeBankServiceSetup.INSERT(true);
        end;

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
        if Rec.ISTEMPORARY() then
            exit;

        if MSYodleeBankAccLink.GET(Rec."No.") then begin // this was a linked account
            Rec.VALIDATE("Automatic Stmt. Import Enabled", false); // remove job queue entry

            MSYodleeBankAccLink.DELETE(true);

            if MSYodleeBankAccLink.ISEMPTY() then
                if CONFIRM(PromptConsumerRemoveNoLinkingQst, true) then
                    UnregisterConsumer();
        end;
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
        if CompanyInformationMgt.IsDemoCompany() and EnvironmentInformation.IsSaaS() then
            exit;

        if not MyNotifications.IsEnabled(GetYodleeAwarenessNotificationId()) then
            exit;

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
        if CompanyInformationMgt.IsDemoCompany() and EnvironmentInfo.IsSaaS() then
            exit;

        if not MyNotifications.IsEnabled(GetPaymentReconJournalsAwarenessNotificationId()) then
            exit;

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
        if CompanyInformationMgt.IsDemoCompany() and EnvironmentInfo.IsSaaS() then
            exit;

        if not MyNotifications.IsEnabled(GetAutomaticBankStatementImportNotificationId()) then
            exit;

        if not MSYodleeBankServiceSetup.GET() then
            exit;

        if not MSYodleeBankServiceSetup.Enabled then
            exit;

        if (Rec."Bank Stmt. Service Record ID" = MSYodleeBankServiceSetup.RECORDID()) and (Rec."Automatic Stmt. Import Enabled" = false) then begin
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
                exit(YodleeAwarenessNotificationNameTxt);
            GetPaymentReconJournalsAwarenessNotificationId():
                exit(PaymentReconAwarenessNotificationNameTxt);
            GetAutomaticBankStatementImportNotificationId():
                exit(AutoBankStmtImportNotificationNameTxt);
        end;
        exit('');
    end;

    local procedure GetNotificationDescription(NotificationId: Guid): Text;
    begin
        case NotificationId of
            GetYodleeAwarenessNotificationId():
                exit(YodleeAwarenessNotificationDescriptionTxt);
            GetPaymentReconJournalsAwarenessNotificationId():
                exit(PaymentReconAwarenessNotificationDescriptionTxt);
            GetAutomaticBankStatementImportNotificationId():
                exit(AutoBankStmtImportNotificationDescriptionTxt);
        end;
        exit('');
    end;

    local procedure ValidateNotDemoCompanyOnSaas(): Boolean;
    var
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if CompanyInformationMgt.IsDemoCompany() and EnvironmentInformation.IsSaaS() then begin
            MESSAGE(DemoCompanyWithDefaultCredentialMsg);
            exit(false);
        end;
        exit(true);
    end;

    procedure LinkNewBankAccountFromNotification(HostNotification: Notification)
    var
        BankAccount: Record "Bank Account";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if CompanyInformationMgt.IsDemoCompany() and EnvironmentInformation.IsSaaS() then
            exit;

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
        if MyNotifications.Get(UserId(), NotificationId) then
            MyNotifications.Disable(NotificationId)
        else
            MyNotifications.InsertDefault(NotificationId, GetNotificationName(NotificationId), GetNotificationDescription(NotificationId), false);
        Session.LogMessage('000020K', StrSubstNo(UserDisabledNotificationTxt, HostNotification.GetData('NotificationId')), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
    end;


    procedure OpenAutoBankStmtImportSetupFromNotification(HostNotification: Notification)
    var
        BankAccount: Record "Bank Account";
        AutoBankStmtImportSetup: Page "Auto. Bank Stmt. Import Setup";
    begin
        if not BankAccount.Get(HostNotification.GetData('BankAccNo')) then
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
        MSYodleeAccountLinking.LOOKUPMODE := true;
        if MSYodleeAccountLinking.RUNMODAL() = ACTION::LookupOK then
            exit(true);

        exit(false);
    end;

    local procedure SetAcceptTermsOfUse(var MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup");
    begin
        if not MSYodleeBankServiceSetup.GET() then begin
            MSYodleeBankServiceSetup.INIT();
            SetValuesToDefault(MSYodleeBankServiceSetup);
            MSYodleeBankServiceSetup.INSERT(true);
        end;

        MSYodleeBankServiceSetup."Accept Terms of Use" := true;
        MSYodleeBankServiceSetup.MODIFY(true);
        COMMIT();
    end;

    procedure UnlinkAllBankAccounts();
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        BankAccount: Record "Bank Account";
    begin
        if not MSYodleeBankServiceSetup.GET() then
            exit;

        BankAccount.SETRANGE("Bank Stmt. Service Record ID", MSYodleeBankServiceSetup.RECORDID());
        if BankAccount.FINDSET() then
            repeat
                MarkBankAccountAsUnlinked(BankAccount."No.");
            until BankAccount.NEXT() = 0;
    end;

    local procedure GetAdjustedErrorText(ErrorText: Text; AdditionalErrorText: Text): Text;
    var
        AdjustedErrorText: Text;
    begin
        if ErrorText <> '' then
            AdjustedErrorText := ErrorText + '\';

        AdjustedErrorText += AdditionalErrorText;
        exit(AdjustedErrorText);
    end;

    local procedure PopulateNameValueBufferWithYodleeInfo(var TempNameValueBuffer: Record 823 temporary);
    var
        LastId: Integer;
    begin
        LastId := 0;
        if TempNameValueBuffer.FINDLAST() then
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
        if not HasCapability() then
            exit(false);

        ErrorOccured := false;
        OnCleanUpEvent(ErrorOccured);

        exit(not ErrorOccured);
    end;

    local procedure HasCapability(): Boolean;
    var
        CryptographyManagement: Codeunit "Cryptography Management";
    begin
        exit(CryptographyManagement.IsEncryptionEnabled() and CryptographyManagement.IsEncryptionPossible());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCleanUpEvent(var ErrorOccured: Boolean)
    // The subscriber of this event should perform any clean up that is dependant on the Isolated Storage table.
    // If an error occurs it should set ErrorOccured to true.
    begin
    end;

    local procedure IsStaleCredentialsErr(ErrTxt: Text): Boolean;
    begin
        exit(ErrTxt.Contains(BankStmtServiceStaleConversationCredentialsErrTxt) or ErrTxt.Contains(BankStmtServiceStaleConversationCredentialsExceptionTxt) or ErrTxt.Contains(StaleCredentialsErr) or ErrTxt.Contains(UnauthorizedResponseCodeTok));
    end;

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

    [IntegrationEvent(false, false)]
    local procedure OnOnlineAccountEmptyCurrencySendTelemetry(Message: Text);
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure HandleOnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    begin
        CleanupYodleeSetup(CompanyName);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure HandleOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    begin
        CleanupYodleeSetup(NewCompanyName);
    end;

    local procedure CleanupYodleeSetup(SetupCompanyName: Text[30])
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        MSYodleeBankAccLink: Record "MS - Yodlee Bank Acc. Link";
        MSYodleeBankSession: Record "MS - Yodlee Bank Session";
    begin
        if SetupCompanyName <> CompanyName() then begin
            MSYodleeBankServiceSetup.ChangeCompany(SetupCompanyName);
            MSYodleeBankAccLink.ChangeCompany(SetupCompanyName);
            MSYodleeBankSession.ChangeCompany(SetupCompanyName);
        end;

        MSYodleeBankServiceSetup.DeleteAll();
        MSYodleeBankAccLink.DeleteAll();
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
    local procedure SendTelemetryOnOnlineAccountEmptyCurrency(Message: Text);
    begin
        Session.LogMessage('00001QG', Message, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', YodleeTelemetryCategoryTok);
    end;
}




