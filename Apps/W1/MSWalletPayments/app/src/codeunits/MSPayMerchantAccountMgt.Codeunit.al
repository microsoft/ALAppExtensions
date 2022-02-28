#if not CLEAN20
codeunit 1085 "MS - Pay Merchant Account Mgt."
{
    ObsoleteState = Pending;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '20.0';
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Paypal Account Proxy", 'SetAlwaysIncludeMsPayOnDocuments', '', true, true)]
    procedure HandleSetAlwaysIncludeMsPayOnDocuments(NewAlwaysIncludeOnDocuments: Boolean; HideDialogs: Boolean);
    begin
        SetAlwaysIncludeOnDocuments(NewAlwaysIncludeOnDocuments, HideDialogs);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Paypal Account Proxy", 'GetMsPayIsEnabled', '', true, true)]
    procedure HandleGetMsPayIsEnabled(var Enabled: Boolean);
    var
        MSWalletMerchantAccount: Record "MS - Wallet Merchant Account";
    begin
        if not MSWalletMerchantAccount.FindFirst() then
            exit;

        Enabled := MSWalletMerchantAccount.Enabled;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Service Setup", 'OnDoNotIncludeAnyPaymentServicesOnAllDocuments', '', true, true)]
    procedure HandleOnDoNotIncludeAnyPaymentServicesOnAllDocuments();
    begin
        SetAlwaysIncludeOnDocuments(false, true);
    end;

    local procedure SetAlwaysIncludeOnDocuments(AlwaysInclude: Boolean; HideDialogs: Boolean);
    var
        MSWalletMerchantAccount: Record "MS - Wallet Merchant Account";
    begin
        if not MSWalletMerchantAccount.FindFirst() then
            exit;

        if HideDialogs then
            MSWalletMerchantAccount.HideAllDialogs();
        if MSWalletMerchantAccount."Always Include on Documents" <> AlwaysInclude then begin
            MSWalletMerchantAccount.Validate("Always Include on Documents", AlwaysInclude);
            MSWalletMerchantAccount.Modify(true);
        end;
    end;
}
#endif
