codeunit 1085 "MS - Pay Merchant Account Mgt."
{

    [EventSubscriber(ObjectType::Codeunit, 1060, 'SetAlwaysIncludeMsPayOnDocuments', '', true, true)]
    procedure HandleSetAlwaysIncludeMsPayOnDocuments(NewAlwaysIncludeOnDocuments: Boolean; HideDialogs: Boolean);
    begin
        SetAlwaysIncludeOnDocuments(NewAlwaysIncludeOnDocuments, HideDialogs);
    end;

    [EventSubscriber(ObjectType::Codeunit, 1060, 'GetMsPayIsEnabled', '', true, true)]
    procedure HandleGetMsPayIsEnabled(var Enabled: Boolean);
    var
        MSWalletMerchantAccount: Record 1080;
    begin
        if not MSWalletMerchantAccount.FindFirst() then
            exit;

        Enabled := MSWalletMerchantAccount.Enabled;
    end;

    [EventSubscriber(ObjectType::Table, 1060, 'OnDoNotIncludeAnyPaymentServicesOnAllDocuments', '', true, true)]
    procedure HandleOnDoNotIncludeAnyPaymentServicesOnAllDocuments();
    begin
        SetAlwaysIncludeOnDocuments(false, true);
    end;

    local procedure SetAlwaysIncludeOnDocuments(AlwaysInclude: Boolean; HideDialogs: Boolean);
    var
        MSWalletMerchantAccount: Record 1080;
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

