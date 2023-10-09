namespace Microsoft.Bank.StatementImport.Yodlee;

codeunit 1458 "Yodlee API Strings"
{
    var
        MSYodleeBankServiceSetup: Record "MS - Yodlee Bank Service Setup";
        AuthHeaderCobSessionTok: Label '{cobSession=%1}', Locked = true;
        AuthHeaderUserSessionTok: Label '{cobSession=%1,userSession=%2}', Locked = true;
        TransactionSearchURLTok: Label '/transactions?accountId=%1&fromDate=%2&toDate=%3&skip=0&top=500', Locked = true;
        LinkedBankAccountsURLTok: Label '/accounts?status=ACTIVE&providerAccountId=%1&include=holder,autoRefresh', Locked = true;
        LinkedBankAccountURLTok: Label '/accounts?accountId=%1&include=holder,autoRefresh', Locked = true;
        UnlinkBankAccountURLTok: Label '/accounts/%1', Locked = true;

    [Scope('OnPrem')]
    procedure GetCobrandTokenURL(): Text;
    begin
        exit(GetFullURL('/cobrand/login'));
    end;

    [Scope('OnPrem')]
    procedure GetCobrandTokenBody(CobrandLogin: Text; CobrandPassword: Text): Text;
    var
        GetCobrandTokenRequestBodyJsonObject: JsonObject;
        GetCobrandTokenRequestBodyText: Text;
        CobrandCredentialsJsonObject: JsonObject;
    begin
        CobrandCredentialsJsonObject.Add('cobrandLogin', CobrandLogin);
        CobrandCredentialsJsonObject.Add('cobrandPassword', CobrandPassword);
        GetCobrandTokenRequestBodyJsonObject.Add('cobrand', CobrandCredentialsJsonObject);
        GetCobrandTokenRequestBodyJsonObject.WriteTo(GetCobrandTokenRequestBodyText);
        exit(GetCobrandTokenRequestBodyText);
    end;

    [Scope('OnPrem')]
    procedure GetAuthorizationHeaderValue(CobrandSessionToken: Text; UserSessionToken: Text): Text;
    begin
        if CobrandSessionToken = '' then
            exit('');

        if UserSessionToken = '' then
            exit(StrSubstno(AuthHeaderCobSessionTok, CobrandSessionToken));

        exit(StrSubstno(AuthHeaderUserSessionTok, CobrandSessionToken, UserSessionToken))
    end;

    [Scope('OnPrem')]
    procedure GetConsumerTokenBody(UserLogin: Text; UserPassword: Text; CobrandSessionToken: Text): Text;
    var
        GetConsumerTokenRequestBodyJsonObject: JsonObject;
        GetConsumerTokenRequestBodyText: Text;
        UserCredentialsJsonObject: JsonObject;
    begin
        UserCredentialsJsonObject.Add('loginName', UserLogin);
        UserCredentialsJsonObject.Add('password', UserPassword);
        GetConsumerTokenRequestBodyJsonObject.Add('user', UserCredentialsJsonObject);
        GetConsumerTokenRequestBodyJsonObject.WriteTo(GetConsumerTokenRequestBodyText);
        exit(GetConsumerTokenRequestBodyText);
    end;

    [Scope('OnPrem')]
    procedure GetConsumerTokenURL(): Text;
    begin
        exit(GetFullURL('/user/login'));
    end;

    [Scope('OnPrem')]
    procedure GetRegisterConsumerURL(): Text;
    begin
        exit(GetFullURL('/user/register'));
    end;

    [Scope('OnPrem')]
    procedure GetRegisterConsumerBody(CobrandToken: Text; UserName: Text; UserPassword: Text; UserEmail: Text; UserCurrency: Text): Text;
    var
        GetRegisterConsumerRequestBodyJsonObject: JsonObject;
        GetRegisterConsumerRequestBodyText: Text;
        UserJsonObject: JsonObject;
        UserPreferencesJsonObject: JsonObject;
    begin
        UserJsonObject.Add('loginName', UserName);
        UserJsonObject.Add('password', UserPassword);
        UserJsonObject.Add('email', UserEmail);
        UserPreferencesJsonObject.Add('currency', UserCurrency);
        UserJsonObject.Add('preferences', UserPreferencesJsonObject);
        GetRegisterConsumerRequestBodyJsonObject.Add('user', UserJsonObject);
        GetRegisterConsumerRequestBodyJsonObject.WriteTo(GetRegisterConsumerRequestBodyText);
        exit(GetRegisterConsumerRequestBodyText);
    end;

    [Scope('OnPrem')]
    procedure GetRemoveConsumerURL(): Text;
    begin
        exit(GetFullURL('/user/unregister'));
    end;

    [Scope('OnPrem')]
    procedure GetRemoveConsumerRequestMethod(): Text[6];
    begin
        exit('DELETE');
    end;

    [Scope('OnPrem')]
    procedure GetRemoveConsumerRequestBody(CobrandToken: Text; ConsumerToken: Text): Text;
    begin
        exit('');
    end;

    [Scope('OnPrem')]
    procedure GetApiVersion(): Text;
    begin
        exit('1.1');
    end;

    [Scope('OnPrem')]
    procedure GetWebRequestContentType(): Text;
    begin
        exit('application/json');
    end;

    [Scope('OnPrem')]
    procedure GetFastLinkTokenURL(): Text;
    begin
        exit(GetFullURL('/user/accessTokens?appIds=10003600'));
    end;

    [Scope('OnPrem')]
    procedure GetFastLinkTokenRequestMethod(): Text[6];
    begin
        exit('GET');
    end;

    [Scope('OnPrem')]
    procedure GetFastLinkTokenBody(CobrandToken: Text; ConsumerToken: Text): Text;
    begin
        exit('');
    end;

    [Scope('OnPrem')]
    procedure StartSiteRefreshURL(): Text;
    begin
        exit(GetFullURL('/jsonsdk/Refresh/startSiteRefresh'));
    end;

    [Scope('OnPrem')]
    procedure GetSiteRefreshURL(): Text;
    begin
        exit(GetFullURL('/jsonsdk/Refresh/getSiteRefreshInfo'));
    end;

    [Scope('OnPrem')]
    procedure GetTransactionSearchURL(OnlineBankAccountId: Text; FromDate: Date; ToDate: Date): Text;
    begin
        exit(GetFullURL(StrSubstNo(TransactionSearchURLTok, OnlineBankAccountId, FORMAT(FromDate, 0, 9), FORMAT(ToDate, 0, 9))));
    end;

    [Scope('OnPrem')]
    procedure GetTransactionSearchBody(CobrandToken: Text; ConsumerToken: Text; OnlineBankAccountId: Text; FromDate: Date; ToDate: Date): Text;
    begin
        exit('');
    end;

    [Scope('OnPrem')]
    procedure GetTransactionSearchRequestMethod(): Text[6];
    begin
        exit('GET');
    end;

    [Scope('OnPrem')]
    procedure GetLinkedSiteListURL(): Text;
    begin
        exit(GetFullURL('/providerAccounts'));
    end;

    [Scope('OnPrem')]
    procedure GetLinkedSiteListRequestMethod(): Text[6];
    begin
        exit('GET');
    end;

    [Scope('OnPrem')]
    procedure GetLinkedSiteListBody(CobrandToken: Text; ConsumerToken: Text): Text;
    begin
        exit('');
    end;

    [Scope('OnPrem')]
    procedure GetLinkedBankAccountsURL(ProviderAccountId: Text): Text;
    begin
        exit(GetFullURL(StrSubstNo(LinkedBankAccountsURLTok, ProviderAccountId)));
    end;

    [Scope('OnPrem')]
    procedure GetLinkedBankAccountURL(AccountId: Text): Text;
    begin
        exit(GetFullURL(StrSubstNo(LinkedBankAccountURLTok, AccountId)));
    end;

    [Scope('OnPrem')]
    procedure GetLinkedBankAccountsRequestMethod(): Text[6];
    begin
        exit('GET');
    end;

    [Scope('OnPrem')]
    procedure GetLinkedBankAccountsBody(CobrandToken: Text; ConsumerToken: Text; SiteAccountId: Text): Text;
    begin
        exit('');
    end;

    [Scope('OnPrem')]
    procedure GetUnlinkBankAccountURL(AccountId: Text): Text;
    begin
        exit(GetFullUrl(StrSubstNo(UnlinkBankAccountURLTok, AccountId)));
    end;

    [Scope('OnPrem')]
    procedure GetUnlinkBankAccountRequestMethod(): Text[6];
    begin
        exit('DELETE');
    end;

    [Scope('OnPrem')]
    procedure GetUnlinkBankAccountBody(CobrandToken: Text; ConsumerToken: Text; AccountId: Text): Text;
    begin
        exit('');
    end;

    [Scope('OnPrem')]
    procedure GetCobrandTokenXPath(): Text;
    begin
        exit('//session/cobSession');
    end;

    [Scope('OnPrem')]
    procedure GetConsumerTokenXPath(): Text;
    begin
        exit('//session/userSession');
    end;

    procedure GetFastLinkTokenXPath(): Text;
    begin
        exit('//accessTokens/value');
    end;

    procedure GetBankAccountsListXPath(): Text;
    begin
        exit('//account');
    end;

    procedure GetRootXPath(): Text;
    begin
        exit('/');
    end;

    [Scope('OnPrem')]
    procedure GetProviderAccountIdXPath(): Text;
    begin
        exit('./id');
    end;

    [Scope('OnPrem')]
    procedure GetProviderAccountXPath(): Text;
    begin
        exit('/root/root/providerAccount');
    end;

    [Scope('OnPrem')]
    procedure GetBankAccountIdXPath(): Text;
    begin
        exit('./id');
    end;

    [Scope('OnPrem')]
    procedure GetBankAccountNameXPath(): Text;
    begin
        exit('./accountName');
    end;

    [Scope('OnPrem')]
    procedure GetProviderNameXPath(): Text;
    begin
        exit('./providerName');
    end;

    procedure GetProviderIdXPath(): Text;
    begin
        exit('./providerId');
    end;

    [Scope('OnPrem')]
    procedure GetBankAccountHolderNameXPath(): Text;
    begin
        exit('./accountHolder');
    end;

    [Scope('OnPrem')]
    procedure GetBankAccountCurrentBalanceXPath(): Text;
    begin
        exit('./currentBalance/currency');
    end;

    [Scope('OnPrem')]
    procedure GetBankAccountRunningBalanceXPath(): Text;
    begin
        exit('./runningBalance/currency');
    end;

    [Scope('OnPrem')]
    procedure GetBankAccountAvailableBalanceXPath(): Text;
    begin
        exit('./availableBalance/currency');
    end;

    procedure GetErrorDetailXPath(): Text;
    begin
        exit('//errorDetail');
    end;

    procedure GetExceptionXPath(): Text;
    begin
        exit('//exceptionType');
    end;

    procedure GetErrorOccurredXPath(): Text;
    begin
        exit('//errorOccurred');
    end;

    procedure GetErrorCodeXPath(): Text;
    begin
        exit('//errorCode');
    end;

    procedure GetDetailedMessageXPath(): Text;
    begin
        exit('//detailedMessage');
    end;

    [Scope('OnPrem')]
    procedure GetFullURL(PartialURL: Text): Text;
    begin
        MSYodleeBankServiceSetup.Get();
        exit(MSYodleeBankServiceSetup.GetServiceURL() + PartialURL);
    end;
}