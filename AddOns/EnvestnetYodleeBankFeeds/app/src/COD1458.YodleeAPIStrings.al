codeunit 1458 "Yodlee API Strings"
{
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        TypeHelper: Codeunit "Type Helper";

    [Scope('OnPrem')]
    procedure GetCobrandTokenURL(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit(GetFullURL('/cobrand/login'));

        exit(GetFullURL('/authenticate/coblogin'));
    end;

    [Scope('OnPrem')]
    procedure GetCobrandTokenBody(CobrandLogin: Text; CobrandPassword: Text): Text;
    var
        GetCobrandTokenRequestBodyJsonObject: JsonObject;
        GetCobrandTokenRequestBodyText: Text;
        CobrandCredentialsJsonObject: JsonObject;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then begin
            CobrandCredentialsJsonObject.Add('cobrandLogin', CobrandLogin);
            CobrandCredentialsJsonObject.Add('cobrandPassword', CobrandPassword);
            GetCobrandTokenRequestBodyJsonObject.Add('cobrand', CobrandCredentialsJsonObject);
            GetCobrandTokenRequestBodyJsonObject.WriteTo(GetCobrandTokenRequestBodyText);
            exit(GetCobrandTokenRequestBodyText);
        end;

        exit(StrSubstNo('cobrandLogin=%1&cobrandPassword=%2', TypeHelper.UrlEncode(CobrandLogin), TypeHelper.UrlEncode(CobrandPassword)));
    end;

    [Scope('OnPrem')]
    procedure GetAuthorizationHeaderValue(CobrandSessionToken: Text; UserSessionToken: Text): Text;
    begin
        // in the legacy API there is no authorization header. instead, the tokens are specified in the request body.
        if not MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('');

        if CobrandSessionToken = '' then
            exit('');

        if UserSessionToken = '' then
            exit(StrSubstno('{cobSession=%1}', CobrandSessionToken));

        exit(StrSubstno('{cobSession=%1,userSession=%2}', CobrandSessionToken, UserSessionToken))
    end;

    [Scope('OnPrem')]
    procedure GetConsumerTokenBody(UserLogin: Text; UserPassword: Text; CobrandSessionToken: Text): Text;
    var
        GetConsumerTokenRequestBodyJsonObject: JsonObject;
        GetConsumerTokenRequestBodyText: Text;
        UserCredentialsJsonObject: JsonObject;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then begin
            UserCredentialsJsonObject.Add('loginName', UserLogin);
            UserCredentialsJsonObject.Add('password', UserPassword);
            GetConsumerTokenRequestBodyJsonObject.Add('user', UserCredentialsJsonObject);
            GetConsumerTokenRequestBodyJsonObject.WriteTo(GetConsumerTokenRequestBodyText);
            exit(GetConsumerTokenRequestBodyText);
        end;

        exit(StrSubstNo('cobSessionToken=%1&login=%2&password=%3', TypeHelper.UrlEncode(CobrandSessionToken), TypeHelper.UrlEncode(UserLogin), TypeHelper.UrlEncode(UserPassword)));
    end;

    [Scope('OnPrem')]
    procedure GetConsumerTokenURL(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit(GetFullURL('/user/login'));

        exit(GetFullURL('/authenticate/login'));
    end;

    [Scope('OnPrem')]
    procedure GetRegisterConsumerURL(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit(GetFullURL('/user/register'));

        exit(GetFullURL('/jsonsdk/UserRegistration/register3'));
    end;

    [Scope('OnPrem')]
    procedure GetRegisterConsumerBody(CobrandToken: Text; UserName: Text; UserPassword: Text; UserEmail: Text; UserCurrency: Text): Text;
    var
        GetRegisterConsumerRequestBodyJsonObject: JsonObject;
        GetRegisterConsumerRequestBodyText: Text;
        UserJsonObject: JsonObject;
        UserPreferencesJsonObject: JsonObject;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then begin
            UserJsonObject.Add('loginName', UserName);
            UserJsonObject.Add('password', UserPassword);
            UserJsonObject.Add('email', UserEmail);
            UserPreferencesJsonObject.Add('currency', UserCurrency);
            UserJsonObject.Add('preferences', UserPreferencesJsonObject);
            GetRegisterConsumerRequestBodyJsonObject.Add('user', UserJsonObject);
            GetRegisterConsumerRequestBodyJsonObject.WriteTo(GetRegisterConsumerRequestBodyText);
            exit(GetRegisterConsumerRequestBodyText);
        end;

        exit(STRSUBSTNO('cobSessionToken=%1&' +
            'userCredentials.loginName=%2&' +
            'userCredentials.password=%3&' +
            'userCredentials.objectInstanceType=%4&' +
            'userProfile.emailAddress=%5&' +
            'userPreferences[0]=PREFERRED_CURRENCY~%6&' +
            'userProfile.objectInstanceType=%7&',
            TypeHelper.UrlEncode(CobrandToken),
            TypeHelper.UrlEncode(Username),
            TypeHelper.UrlEncode(UserPassword),
            'com.yodlee.ext.login.PasswordCredentials',
            TypeHelper.UrlEncode(UserEmail),
            TypeHelper.UrlEncode(UserCurrency),
            'com.yodlee.core.usermanagement.UserProfile'));
    end;

    [Scope('OnPrem')]
    procedure GetRemoveConsumerURL(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit(GetFullURL('/user/unregister'));

        exit(GetFullURL('/jsonsdk/UserRegistration/unregister'));
    end;

    [Scope('OnPrem')]
    procedure GetRemoveConsumerRequestMethod(): Text[6];
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('DELETE');

        exit('POST');
    end;

    [Scope('OnPrem')]
    procedure GetRemoveConsumerRequestBody(CobrandToken: Text; ConsumerToken: Text): Text;
    begin
        // in YSL 1.1 this is a DELETE request - no body
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('');

        exit(StrSubstNo('cobSessionToken=%1&userSessionToken=%2',
            TypeHelper.UrlEncode(CobrandToken),
            TypeHelper.UrlEncode(ConsumerToken)));
    end;

    [Scope('OnPrem')]
    procedure GetApiVersion(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('1.1');

        exit('');
    end;

    [Scope('OnPrem')]
    procedure GetWebRequestContentType(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('application/json');

        exit('application/x-www-form-urlencoded');
    end;

    [Scope('OnPrem')]
    procedure GetFastLinkTokenURL(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit(GetFullURL('/user/accessTokens?appIds=10003600'));

        exit(GetFullURL('/authenticator/token'));
    end;

    [Scope('OnPrem')]
    procedure GetFastLinkTokenRequestMethod(): Text[6];
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('GET');

        exit('POST');
    end;

    [Scope('OnPrem')]
    procedure GetFastLinkTokenBody(CobrandToken: Text; ConsumerToken: Text): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('');

        exit(STRSUBSTNO(
            'finAppId=%1&rsession=%2&cobSessionToken=%3', '10003600', TypeHelper.UrlEncode(ConsumerToken),
            TypeHelper.UrlEncode(CobrandToken)));
    end;

    [Scope('OnPrem')]
    procedure StartSiteRefreshURL(): Text;
    begin
        EXIT(GetFullURL('/jsonsdk/Refresh/startSiteRefresh'));
    end;

    [Scope('OnPrem')]
    procedure GetSiteRefreshURL(): Text;
    begin
        EXIT(GetFullURL('/jsonsdk/Refresh/getSiteRefreshInfo'));
    end;

    [Scope('OnPrem')]
    procedure GetTransactionSearchURL(OnlineBankAccountId: Text; FromDate: Date; ToDate: Date): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit(GetFullURL(StrSubstNo('/transactions?accountId=%1&fromDate=%2&toDate=%3&skip=0&top=500', OnlineBankAccountId, FORMAT(FromDate, 0, 9), FORMAT(ToDate, 0, 9))));

        EXIT(GetFullURL('/jsonsdk/TransactionSearchService/executeUserSearchRequest'));
    end;

    local procedure FormatDateToYodlee11Date(BCDate: Date): Text;
    begin

    end;

    [Scope('OnPrem')]
    procedure GetTransactionSearchBody(CobrandToken: Text; ConsumerToken: Text; OnlineBankAccountId: Text; FromDate: Date; ToDate: Date): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('');

        EXIT(StrSubstNo(
                'cobSessionToken=%1&' +
                'userSessionToken=%2&' +
                'transactionSearchRequest.containerType=%3&' +
                'transactionSearchRequest.higherFetchLimit=%4&' +
                'transactionSearchRequest.lowerFetchLimit=%5&' +
                'transactionSearchRequest.resultRange.endNumber=%6&' +
                'transactionSearchRequest.resultRange.startNumber=%7&' +
                'transactionSearchRequest.searchClients.clientId=%8&' +
                'transactionSearchRequest.searchClients.clientName=%9&' +
                'transactionSearchRequest.ignoreUserInput=%10&' +
                'transactionSearchRequest.searchFilter.postDateRange.fromDate=%11&' +
                'transactionSearchRequest.searchFilter.postDateRange.toDate=%12&' +
                'transactionSearchRequest.searchFilter.transactionSplitType=%13&' +
                'transactionSearchRequest.searchFilter.itemAccountId.identifier=%14&' +
                'transactionSearchRequest.searchFilter.transactionStatus.statusId=%15',
                TypeHelper.UrlEncode(CobrandToken),
                TypeHelper.UrlEncode(ConsumerToken),
                'all',
                5000,
                1,
                5000,
                1,
                1,
                'DataSearchService',
                'true',
                FORMAT(FromDate, 0, '<Month>-<Day>-<Year4>'),
                FORMAT(ToDate, 0, '<Month>-<Day>-<Year4>'),
                'ALL_TRANSACTION',
                TypeHelper.UrlEncode(OnlineBankAccountId),
                1));
    end;

    [Scope('OnPrem')]
    procedure GetTransactionSearchRequestMethod(): Text[6];
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('GET');

        exit('POST');
    end;

    [Scope('OnPrem')]
    procedure GetLinkedSiteListURL(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit(GetFullURL('/providerAccounts'));

        exit(GetFullURL('/jsonsdk/SiteAccountManagement/getAllSiteAccounts'));
    end;

    [Scope('OnPrem')]
    procedure GetLinkedSiteListRequestMethod(): Text[6];
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('GET');

        exit('POST');
    end;

    [Scope('OnPrem')]
    procedure GetLinkedSiteListBody(CobrandToken: Text; ConsumerToken: Text): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('');

        exit(StrSubstNo('cobSessionToken=%1&userSessionToken=%2', TypeHelper.UrlEncode(CobrandToken), TypeHelper.UrlEncode(ConsumerToken)));
    end;

    [Scope('OnPrem')]
    procedure GetLinkedBankAccountsURL(ProviderAccountId: Text): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit(GetFullURL(StrSubstNo('/accounts?status=ACTIVE&providerAccountId=%1&include=holder,autoRefresh', ProviderAccountId)));

        exit(GetFullURL('/jsonsdk/DataService/getItemSummariesForSite'));
    end;

    [Scope('OnPrem')]
    procedure GetLinkedBankAccountURL(AccountId: Text): Text;
    begin
        exit(GetFullURL(StrSubstNo('/accounts?accountId=%1&include=holder,autoRefresh', AccountId)));
    end;

    [Scope('OnPrem')]
    procedure GetLinkedBankAccountsRequestMethod(): Text[6];
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('GET');

        exit('POST');
    end;

    [Scope('OnPrem')]
    procedure GetLinkedBankAccountsBody(CobrandToken: Text; ConsumerToken: Text; SiteAccountId: Text): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('');

        exit(StrSubstNo('cobSessionToken=%1&userSessionToken=%2&memSiteAccId=%3', TypeHelper.UrlEncode(CobrandToken), TypeHelper.UrlEncode(ConsumerToken), TypeHelper.UrlEncode(SiteAccountId)));
    end;

    [Scope('OnPrem')]
    procedure GetUnlinkBankAccountURL(AccountId: Text): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit(GetFullUrl(StrSubstNo('/accounts/%1', AccountId)));

        EXIT(GetFullURL('/jsonsdk/ItemAccountManagement/removeItemAccount'));
    end;

    [Scope('OnPrem')]
    procedure GetUnlinkBankAccountRequestMethod(): Text[6];
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('DELETE');

        EXIT('POST');
    end;

    [Scope('OnPrem')]
    procedure GetUnlinkBankAccountBody(CobrandToken: Text; ConsumerToken: Text; AccountId: Text): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('');

        EXIT(StrSubstNo('cobSessionToken=%1&userSessionToken=%2&itemAccountId=%3',
            TypeHelper.UrlEncode(CobrandToken),
            TypeHelper.UrlEncode(ConsumerToken),
            TypeHelper.UrlEncode(AccountId)));
    end;

    [Scope('OnPrem')]
    procedure GetCobrandTokenXPath(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('//session/cobSession');

        exit('//sessionToken');
    end;

    [Scope('OnPrem')]
    procedure GetConsumerTokenXPath(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('//session/userSession');

        exit('//conversationCredentials/sessionToken');
    end;

    procedure GetFastLinkTokenXPath(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('//accessTokens/value');

        exit('//finappAuthenticationInfos/token');
    end;

    procedure GetBankAccountsListXPath(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('//account');

        EXIT('//itemData/accounts');
    end;

    procedure GetRootXPath(): Text;
    begin
        EXIT('/');
    end;

    [Scope('OnPrem')]
    procedure GetProviderAccountIdXPath(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('./id');

        exit('./siteAccountId');
    end;

    [Scope('OnPrem')]
    procedure GetProviderAccountXPath(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('/root/root/providerAccount');

        exit('');
    end;

    [Scope('OnPrem')]
    procedure GetBankAccountIdXPath(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('./id');

        exit('./itemAccountId');
    end;

    [Scope('OnPrem')]
    procedure GetBankAccountNameXPath(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('./accountName');

        exit('./accountDisplayName/defaultNormalAccountName');
    end;

    [Scope('OnPrem')]
    procedure GetProviderNameXPath(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('./providerName');

        exit('./siteName');
    end;

    procedure GetProviderIdXPath(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('./providerId');

        exit('./siteId');
    end;

    [Scope('OnPrem')]
    procedure GetBankAccountHolderNameXPath(): Text;
    begin
        exit('./accountHolder');
    end;

    [Scope('OnPrem')]
    procedure GetBankAccountCurrentBalanceXPath(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('./currentBalance/currency');

        exit('./currentBalance/currencyCode');
    end;

    [Scope('OnPrem')]
    procedure GetBankAccountRunningBalanceXPath(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('./runningBalance/currency');

        exit('./runningBalance/currencyCode');
    end;

    [Scope('OnPrem')]
    procedure GetBankAccountAvailableBalanceXPath(): Text;
    begin
        if MSYodleeBankServiceSetup.IsSetUpForYSL11() then
            exit('./availableBalance/currency');

        exit('./availableBalance/currencyCode');
    end;

    procedure GetErrorDetailXPath(): Text;
    begin
        EXIT('//errorDetail');
    end;

    procedure GetExceptionXPath(): Text;
    begin
        EXIT('//exceptionType');
    end;

    procedure GetErrorOccurredXPath(): Text;
    begin
        EXIT('//errorOccurred');
    end;

    procedure GetErrorCodeXPath(): Text;
    begin
        EXIT('//errorCode');
    end;

    procedure GetDetailedMessageXPath(): Text;
    begin
        EXIT('//detailedMessage');
    end;

    local procedure GetFullURL(PartialURL: Text): Text;
    begin
        MSYodleeBankServiceSetup.Get();
        exit(MSYodleeBankServiceSetup.GetServiceURL() + PartialURL);
    end;
}