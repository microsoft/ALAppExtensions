#if not CLEAN20
codeunit 139581 "MS - Wallet Inv Mock Events"
{
    // version Test,ERM,W1,CA,GB,US
    ObsoleteState = Pending;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '20.0';
    EventSubscriberInstance = Manual;

    trigger OnRun();
    begin
    end;

    var
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        MockUpPayPal: Boolean;
        MockedPaypalIncludeOnDocuments: Boolean;
        MockedPaypalEnabled: Boolean;

    procedure SetMockUpPaypal(NewMockUpPayPal: Boolean; NewEnabled: Boolean; NewAlwaysInclude: Boolean)
    begin
        MockUpPayPal := NewMockUpPayPal;
        MockedPaypalEnabled := NewEnabled;
        MockedPaypalIncludeOnDocuments := NewAlwaysInclude;
    end;

    procedure CleanUpPayPal()
    begin
        MockUpPayPal := false;
        MockedPaypalEnabled := false;
        MockedPaypalIncludeOnDocuments := false;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Service Setup", 'OnRegisterPaymentServices', '', false, false)]
    local procedure RegisterPayPalStandardAccounts(var PaymentServiceSetup: Record 1060);
    begin
        HandleMockPaypalInvoicing(PaymentServiceSetup);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Service Setup", 'OnRegisterPaymentServiceProviders', '', false, false)]
    local procedure RegisterPayPalStandardTemplate(var PaymentServiceSetup: Record 1060);
    begin
        HandleMockPaypalInvoicing(PaymentServiceSetup);
    end;

    local procedure HandleMockPaypalInvoicing(var PaymentServiceSetup: Record 1060);
    var
        DummyCompanyInformation: Record "Company Information";
    begin
        if not MockUpPayPal then
            exit;

        DummyCompanyInformation.FindFirst();
        Clear(PaymentServiceSetup);
        PaymentServiceSetup.Name := 'MockedPayPal';
        PaymentServiceSetup."Terms of Service" := 'http://localhost/paypal';
        PaymentServiceSetup.Description := 'Mocked PayPal';
        PaymentServiceSetup.Enabled := MockedPayPalEnabled;
        PaymentServiceSetup."Always Include on Documents" := MockedPaypalIncludeOnDocuments;
        PaymentServiceSetup."Setup Record ID" := DummyCompanyInformation.RecordId();
        PaymentServiceSetup.AssignPrimaryKey(PaymentServiceSetup);
        PaymentServiceSetup."Management Codeunit ID" := CODEUNIT::"MS - Wallet Mock Events";
        PaymentServiceSetup.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Paypal Account Proxy", 'GetPaypalAccount', '', false, false)]
    local procedure GetPaypalAccount(var Account: Text[250]);
    begin
        if MockUpPayPal then
            Account := 'mockuppaypal@test.microsoft.com';
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Paypal Account Proxy", 'SetAlwaysIncludePaypalOnDocuments', '', false, false)]
    local procedure HandleSetAlwaysIncludePaypalOnDocuments(NewAlwaysIncludeOnDocuments: Boolean; HideDialogs: Boolean);
    begin
        MockedPaypalIncludeOnDocuments := NewAlwaysIncludeOnDocuments;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Service Setup", 'OnDoNotIncludeAnyPaymentServicesOnAllDocuments', '', false, false)]
    local procedure HandleOnDoNotIncludeAnyPaymentServicesOnAllDocuments();
    begin
        MockedPaypalIncludeOnDocuments := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Paypal Account Proxy", 'GetPaypalSetupOptions', '', false, false)]
    local procedure HandleGetPaypalSetupOptions(var Enabled: Boolean; var IncludeInAllDocuments: Boolean);
    begin
        if not MockUpPayPal then
            exit;

        Enabled := MockedPaypalEnabled;
        IncludeInAllDocuments := MockedPaypalIncludeOnDocuments;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Paypal Account Proxy", 'SetPaypalAccount', '', false, false)]
    local procedure SetPaypalAccount(Account: Text[250]; Silent: Boolean);
    var
        O365SalesInvoicePayment: Codeunit "O365 Sales Invoice Payment";
    begin
        if not MockUpPayPal then
            exit;

        if Account = '' then
            O365SalesInvoicePayment.OnPayPalEmailSetToEmpty();

    end;



    procedure ClearVariableStorage();
    begin
        LibraryVariableStorage.Clear();
    end;

    procedure GetVariableStorageNextText(): Text;
    var
    begin
        exit(LibraryVariableStorage.DequeueText());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Mail Management", 'OnBeforeDoSending', '', false, false)]
    local procedure BlockEmailSendingEventSubscriber(var CancelSending: Boolean);
    begin
        CancelSending := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document-Mailing", 'OnBeforeSendEmail', '', false, false)]
    local procedure SaveEmailContentBeforeSending(var TempEmailItem: Record "Email Item" temporary; IsFromPostedDoc: Boolean; PostedDocNo: Code[20]; HideDialog: Boolean; ReportUsage: Integer);
    begin
        LibraryVariableStorage.Enqueue(TempEmailItem.GetBodyText());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MS - Wallet Merchant Mgt", 'OnBeforeRetrieveMerchantId', '', false, false)]
    local procedure RetrieveMerchantIdInvoicing(var MSWalletMerchantAccount: Record "MS - Wallet Merchant Account"; var Handled: Boolean);
    var
        EnvInfoProxy: Codeunit "Env. Info Proxy";
    begin
        if EnvInfoProxy.IsInvoicing() then begin
            Handled := true;
            MSWalletMerchantAccount.Validate("Merchant ID", CreateGuid());
            MSWalletMerchantAccount.Modify(true);
        end;
    end;
}
#endif