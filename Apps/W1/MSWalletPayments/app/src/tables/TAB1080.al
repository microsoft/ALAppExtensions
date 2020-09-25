table 1080 "MS - Wallet Merchant Account"
{
    Caption = 'Microsoft Pay Payments Account';
    DrillDownPageID = 1080;
    LookupPageID = 1080;
    Permissions = TableData 2000000199 = rimd;
    ReplicateData = false;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            AutoIncrement = true;
        }
        field(2; Name; Text[250])
        {
            NotBlank = true;
        }
        field(3; Description; Text[250])
        {
            NotBlank = true;
        }
        field(4; Enabled; Boolean)
        {

            trigger OnValidate();
            begin
                VerifyAccountID();
            end;
        }
        field(5; "Always Include on Documents"; Boolean)
        {

            trigger OnValidate();
            var
                MSWalletMerchantAccount: Record 1080;
                SalesHeader: Record 36;
            begin
                IF NOT "Always Include on Documents" THEN
                    EXIT;

                MSWalletMerchantAccount.SETRANGE("Always Include on Documents", TRUE);
                MSWalletMerchantAccount.SETFILTER("Primary Key", '<>%1', "Primary Key");
                MSWalletMerchantAccount.MODIFYALL("Always Include on Documents", FALSE, TRUE);

                IF NOT GUIALLOWED() THEN
                    EXIT;

                SalesHeader.SETFILTER("Document Type", STRSUBSTNO('%1|%2|%3',
                    SalesHeader."Document Type"::Invoice,
                    SalesHeader."Document Type"::Order,
                    SalesHeader."Document Type"::Quote));

                IF SalesHeader.FINDFIRST() AND NOT HideDialogs THEN
                    MESSAGE(UpdateOpenInvoicesManuallyMsg);
            end;
        }
        field(8; "Terms of Service"; Text[250])
        {
            ExtendedDatatype = URL;
        }
        field(10; "Merchant ID"; Text[250])
        {

            trigger OnValidate();
            begin
                VerifyAccountID();
                "Merchant ID" := LOWERCASE("Merchant ID");
            end;
        }
        field(12; "Payment Request URL"; BLOB)
        {
            Caption = 'Service URL';
        }
        field(16; "Test Mode"; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete();
    begin
        DeleteWebhookSubscription("Merchant ID");
    end;

    trigger OnInsert();
    var
        CompanyInformationMgt: Codeunit 1306;
    begin
        IF NOT ISTEMPORARY() THEN
            IF FINDFIRST() THEN
                ERROR(MSWalletSingeltonErr);
        "Test Mode" := CompanyInformationMgt.IsDemoCompany();
    end;

    trigger OnModify();
    begin
        UpdateWebhookOnModify();
    end;

    var
        merchantIDCannotBeBlankErr: Label 'You must set up your merchant account before enabling this payment service.';
        UpdateOpenInvoicesManuallyMsg: Label 'A link for the Microsoft Pay Payments payment service will be included on new sales documents. To add it to existing sales documents, you must manually select it in the Payment Service field on the sales document.';
        HideDialogs: Boolean;
        MSWalletSingeltonErr: Label 'You can only have one Microsoft Pay Payments setup. To add more payment accounts to your merchant profile, edit the existing Microsoft Pay Payments setup.';
        MSWalletTelemetryCategoryTok: Label 'AL MSPAY', Locked = true;
        InvalidPaymentRequestURLErr: Label 'The payment request URL is not valid.';
        WebhooksNotAllowedForCurrentClientTypeTxt: Label 'Webhooks are not allowed for the current client type.', Locked = true;
        WebhookSubscriptionAlreadyExistsTxt: Label 'A webhook subscription already exists.', Locked = true;
        WebhookSubscriptionNotCreatedTxt: Label 'A webhook subscription is not created.', Locked = true;
        WebhookSubscriptionCreatedTxt: Label 'A webhook subscription is created.', Locked = true;
        WebhookSubscriptionDeletedTxt: Label 'The webhook subscription is deleted.', Locked = true;
        WebhookSubscriptionDoesNotExistTxt: Label 'The webhook subscription does not exist.', Locked = true;
        PaymentRegistrationSetupAlreadyExistsTxt: Label 'The payment registration setup already exists.', Locked = true;
        PaymentRegistrationSetupCreatedTxt: Label 'A payment registration setup is created.', Locked = true;
        PaymentRegistrationSetupNotCreatedTxt: Label 'A payment registration setup is not created.', Locked = true;

    procedure GetPaymentRequestURL(): Text;
    var
        InStream: InStream;
        PaymentRequestURL: Text;
    begin
        PaymentRequestURL := '';
        CALCFIELDS("Payment Request URL");
        IF "Payment Request URL".HASVALUE() THEN BEGIN
            "Payment Request URL".CREATEINSTREAM(InStream);
            InStream.READ(PaymentRequestURL);
        END;
        EXIT(PaymentRequestURL);
    end;

    procedure SetPaymentRequestURL(PaymentRequestURL: Text);
    var
        OutStream: OutStream;
    begin
        if not IsValidURL(PaymentRequestURL) then
            Error(InvalidPaymentRequestURLErr);

        "Payment Request URL".CREATEOUTSTREAM(OutStream);
        OutStream.WRITE(PaymentRequestURL);
        MODIFY();
    end;

    local procedure IsValidURL(URL: Text): Boolean;
    var
        WebRequestHelper: Codeunit 1299;
    begin
        if WebRequestHelper.IsValidUri(URL) then
            if WebRequestHelper.IsHttpUrl(URL) then
                if WebRequestHelper.IsSecureHttpUrl(URL) then
                    exit(true);
        exit(false);
    end;

    local procedure VerifyAccountID();
    begin
        IF Enabled THEN
            IF "Merchant ID" = '' THEN
                IF HideDialogs THEN
                    "Merchant ID" := ''
                ELSE
                    ERROR(merchantIDCannotBeBlankErr);
    end;

    procedure HideAllDialogs();
    begin
        HideDialogs := TRUE;
    end;

    local procedure UpdateWebhookOnModify();
    var
        PrevMSWalletMerchantAccount: Record 1080;
    begin
        PrevMSWalletMerchantAccount.GET("Primary Key");

        IF PrevMSWalletMerchantAccount."Merchant ID" <> "Merchant ID" THEN
            DeleteWebhookSubscription(PrevMSWalletMerchantAccount."Merchant ID");

        IF "Merchant ID" <> '' THEN
            IF Enabled THEN
                RegisterWebhookListener("Merchant ID")
            ELSE
                DeleteWebhookSubscription("Merchant ID");

        CreatePaymentRegistrationSetupForCurrentUser();
    end;

    local procedure RegisterWebhookListener(AccountID: Text[250]);
    var
        WebhookSubscription: Record 2000000199;
        MarketingSetup: Record 5079;
        WebhookManagement: Codeunit 5377;
        MSWalletWebhookManagement: Codeunit 1083;
        WebHooksAdapterUri: Text[250];
        SubscriptionID: Text[150];
    begin
        IF NOT WebhookManagement.IsCurrentClientTypeAllowed() THEN BEGIN
            Session.LogMessage('00008I4', WebhooksNotAllowedForCurrentClientTypeTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            EXIT;
        END;

        SubscriptionID := CopyStr(MSWalletWebhookManagement.GetWebhookSubscriptionID(LOWERCASE(AccountID)), 1, MaxStrLen(SubscriptionID));
        WebhookSubscription.SETRANGE("Subscription ID", SubscriptionID);
        WebhookSubscription.SetFilter("Created By", MSWalletWebhookManagement.GetCreatedByFilterForWebhooks());
        WebHooksAdapterUri := MSWalletWebhookManagement.GetNotificationUrl();

        IF WebhookManagement.FindWebhookSubscriptionMatchingEndPointUri(WebhookSubscription, WebHooksAdapterUri, 0, 0) THEN BEGIN
            Session.LogMessage('00008I5', WebhookSubscriptionAlreadyExistsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            EXIT; // subscription already exists
        END;

        WebhookSubscription."Subscription ID" := SubscriptionID;
        WebhookSubscription.Endpoint := WebHooksAdapterUri;
        WebhookSubscription."Created By" := COPYSTR(GetBaseURL(), 1, MAXSTRLEN(WebhookSubscription."Created By"));
        WebhookSubscription."Company Name" := CopyStr(COMPANYNAME(), 1, MaxStrLen(WebhookSubscription."Company Name"));
        WebhookSubscription."Run Notification As" := MarketingSetup.TrySetWebhookSubscriptionUserAsCurrentUser();
        IF NOT WebhookSubscription.INSERT() THEN
            Session.LogMessage('00008I6', WebhookSubscriptionNotCreatedTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok)
        ELSE
            Session.LogMessage('00008I7', WebhookSubscriptionCreatedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
    end;

    local procedure DeleteWebhookSubscription(AccountID: Text[250]);
    var
        WebhookSubscription: Record 2000000199;
        MSWalletWebhookManagement: Codeunit 1083;
    begin
        WebhookSubscription.SETRANGE("Subscription ID", MSWalletWebhookManagement.GetWebhookSubscriptionID(LOWERCASE(AccountID)));
        WebhookSubscription.SetFilter("Created By", MSWalletWebhookManagement.GetCreatedByFilterForWebhooks());
        IF NOT WebhookSubscription.IsEmpty() THEN BEGIN
            WebhookSubscription.DeleteAll(true);
            Session.LogMessage('00008I8', WebhookSubscriptionDeletedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
        END;

        Session.LogMessage('00008I9', WebhookSubscriptionDoesNotExistTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
    end;

    procedure GetBaseURL(): Text;
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        EXIT(TypeHelper.UriGetAuthority(GetPaymentRequestURL()));
    end;

    local procedure CreatePaymentRegistrationSetupForCurrentUser();
    var
        PaymentRegistrationSetup: Record 980;
    begin
        IF PaymentRegistrationSetup.GET(USERID()) THEN BEGIN
            Session.LogMessage('00008IA', PaymentRegistrationSetupAlreadyExistsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            exit;
        END;
        IF PaymentRegistrationSetup.GET() THEN BEGIN
            PaymentRegistrationSetup."User ID" := CopyStr(USERID(), 1, MaxStrLen(PaymentRegistrationSetup."User ID"));
            IF PaymentRegistrationSetup.INSERT(TRUE) THEN BEGIN
                Session.LogMessage('00008IB', PaymentRegistrationSetupCreatedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
                exit;
            END;
            Session.LogMessage('00008IC', PaymentRegistrationSetupNotCreatedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok)
        END;
    end;
}

