table 1070 "MS - PayPal Standard Account"
{
    Caption = 'PayPal Payments Standard Account';
    DrillDownPageID = 1070;
    LookupPageID = 1070;
    Permissions = TableData "Webhook Subscription" = rimd;
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
            var
                CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
            begin
                if not xRec."Enabled" and Rec."Enabled" then
                    Rec."Enabled" := CustomerConsentMgt.ConfirmUserConsent();

                if Rec.Enabled then
                    VerifyAccountID();
            end;
        }
        field(5; "Always Include on Documents"; Boolean)
        {

            trigger OnValidate();
            var
                MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
                SalesHeader: Record "Sales Header";
            begin
                IF NOT "Always Include on Documents" THEN
                    EXIT;

                MSPayPalStandardAccount.SETRANGE("Always Include on Documents", TRUE);
                MSPayPalStandardAccount.SETFILTER("Primary Key", '<>%1', "Primary Key");
                MSPayPalStandardAccount.MODIFYALL("Always Include on Documents", FALSE, TRUE);

                IF NOT GUIALLOWED() THEN
                    EXIT;

                SalesHeader.SETFILTER("Document Type", StrSubstNo(SalesHeaderFilterLbl,
                    SalesHeader."Document Type"::Invoice,
                    SalesHeader."Document Type"::Order,
                    SalesHeader."Document Type"::Quote));

                IF not SalesHeader.IsEmpty() AND NOT HideDialogs THEN
                    MESSAGE(UpdateOpenInvoicesManuallyMsg);
            end;
        }
        field(8; "Terms of Service"; Text[250])
        {
            ExtendedDatatype = URL;
        }
        field(10; "Account ID"; Text[250])
        {

            trigger OnValidate();
            begin
                VerifyAccountID();
                "Account ID" := LOWERCASE("Account ID");
            end;
        }
        field(12; "Target URL"; BLOB)
        {
            Caption = 'Service URL';
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
        DeleteWebhookSubscription("Account ID");
    end;

    trigger OnModify();
    begin
        UpdateWebhookOnModify();
    end;

    var
        MSPayPalWebhookManagement: Codeunit "MS - PayPal Webhook Management";
        PayPalTelemetryCategoryTok: Label 'AL Paypal', Locked = true;
        AccountIDCannotBeBlankErr: Label 'You must specify an account ID for this payment service.';
        RefreshWebhooksSubscriptionMsg: Label 'Deleting and recreating Webhook Subscription.', Locked = true;
        AccountIDTooLongForWebhooksErr: Label 'The length of the specified PayPal account ID exceeds the maximum supported length of the webhook subscription ID, which is %1 characters.', Comment = '%1=integer value';
        UpdateOpenInvoicesManuallyMsg: Label 'A link for the PayPal payment service will be included for new sales documents. To add it to existing sales documents, you must manually select it in the Payment Service field on the sales document.';
        WebhooksNotAllowedForCurrentClientTypeTxt: Label 'Webhooks are not allowed for the current client type.', Locked = true;
        PaymentRegistrationSetupAlreadyExistsTxt: Label 'The payment registration setup already exists.', Locked = true;
        PaymentRegistrationSetupCreatedTxt: Label 'A payment registration setup is created.', Locked = true;
        PaymentRegistrationSetupNotCreatedTxt: Label 'A payment registration setup is not created.', Locked = true;
        WebhookSubscriptionNotCreatedTxt: Label 'A webhook subscription is not created.', Locked = true;
        WebhookSubscriptionCreatedTxt: Label 'A webhook subscription is created.', Locked = true;
        WebhookSubscriptionDeletedTxt: Label 'The webhook subscription is deleted.', Locked = true;
        WebhookSubscriptionDoesNotExistTxt: Label 'The webhook subscription does not exist.', Locked = true;
        InvalidTargetURLErr: Label 'The target URL is not valid.';
        HideDialogs: Boolean;
        SalesHeaderFilterLbl: Label '%1|%2|%3', Comment = '%1,%2 and %3 are Document Types.', Locked = true;

    procedure GetTargetURL(): Text;
    var
        InStream: InStream;
        TargetURL: Text;
    begin
        TargetURL := '';
        CALCFIELDS("Target URL");
        IF "Target URL".HASVALUE() THEN BEGIN
            "Target URL".CREATEINSTREAM(InStream);
            InStream.READ(TargetURL);
        END;
        EXIT(TargetURL);
    end;

    procedure SetTargetURL(TargetURL: Text);
    var
        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
        OutStream: OutStream;
    begin
        if not MSPayPalStandardMgt.IsValidAndSecureURL(TargetURL) then
            Error(InvalidTargetURLErr);

        "Target URL".CREATEOUTSTREAM(OutStream);
        OutStream.WRITE(TargetURL);
        MODIFY();
    end;

    local procedure VerifyAccountID();
    begin
        IF Enabled THEN
            IF "Account ID" = '' THEN
                IF HideDialogs THEN
                    "Account ID" := ''
                ELSE
                    ERROR(AccountIDCannotBeBlankErr);
    end;

    procedure HideAllDialogs();
    begin
        HideDialogs := TRUE;
    end;

    local procedure UpdateWebhookOnModify();
    var
        PrevMSPayPalStandardAccount: Record "MS - PayPal Standard Account";
    begin
        PrevMSPayPalStandardAccount.GET("Primary Key");

        IF PrevMSPayPalStandardAccount."Account ID" <> "Account ID" THEN
            DeleteWebhookSubscription(PrevMSPayPalStandardAccount."Account ID");

        IF "Account ID" <> '' THEN
            IF Enabled THEN
                RegisterWebhookListenerForRec()
            ELSE
                DeleteWebhookSubscription("Account ID");

        CreatePaymentRegistrationSetupForCurrentUser();
    end;

    local procedure RegisterWebhookListenerForRec();
    var
        WebhookSubscription: Record "Webhook Subscription";
        MarketingSetup: Record "Marketing Setup";
        WebhookManagement: Codeunit "Webhook Management";
        WebhooksAdapterUri: Text[250];
        SubscriptionId: Text[150];
    begin
        IF NOT WebhookManagement.IsCurrentClientTypeAllowed() THEN BEGIN
            Session.LogMessage('00008H5', WebhooksNotAllowedForCurrentClientTypeTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
            EXIT;
        END;

        if StrLen("Account ID") > MaxStrLen(SubscriptionId) then begin
            Session.LogMessage('00006TI', STRSUBSTNO(AccountIDTooLongForWebhooksErr, MaxStrLen(SubscriptionId)), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
            ERROR(AccountIDTooLongForWebhooksErr, MaxStrLen(SubscriptionId));
        end;

        SubscriptionId := CopyStr(LowerCase("Account ID"), 1, MaxStrLen(SubscriptionId));
        WebhookSubscription.SETRANGE("Subscription ID", SubscriptionId);
        WebhookSubscription.SetFilter("Created By", MSPayPalWebhookManagement.GetCreatedByFilterForWebhooks());
        WebhooksAdapterUri := LOWERCASE(WebhookManagement.GetNotificationUrl());

        if WebhookManagement.FindWebhookSubscriptionMatchingEndPointUri(WebhookSubscription, WebhooksAdapterUri, 0, 0) then begin
            Session.LogMessage('00006TJ', RefreshWebhooksSubscriptionMsg, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
            WebhookSubscription.Delete(true); // Delete and re-insert: do not assume that if the account ID is the same, the webhook is equivalent
            Clear(WebhookSubscription);
        end;

        WebhookSubscription."Subscription ID" := SubscriptionId;
        WebhookSubscription.Endpoint := WebhooksAdapterUri;
        WebhookSubscription."Created By" := GetBaseURL();
        WebhookSubscription."Company Name" := CopyStr(COMPANYNAME(), 1, MaxStrLen(WebhookSubscription."Company Name"));
        WebhookSubscription."Run Notification As" := MarketingSetup.TrySetWebhookSubscriptionUserAsCurrentUser();
        IF NOT WebhookSubscription.INSERT() THEN
            Session.LogMessage('00008H6', WebhookSubscriptionNotCreatedTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok)
        ELSE
            Session.LogMessage('00008H7', WebhookSubscriptionCreatedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
    end;

    local procedure DeleteWebhookSubscription(AccountId: Text[250]);
    var
        WebhookSubscription: Record "Webhook Subscription";
        SubscriptionId: Text[150];
    begin
        SubscriptionId := CopyStr(LowerCase(AccountId), 1, MaxStrLen(SubscriptionId));
        WebhookSubscription.SETRANGE("Subscription ID", SubscriptionId);
        WebhookSubscription.SetFilter("Created By", MSPayPalWebhookManagement.GetCreatedByFilterForWebhooks());
        IF NOT WebhookSubscription.IsEmpty() THEN BEGIN
            WebhookSubscription.DeleteAll(true);
            Session.LogMessage('00008H8', WebhookSubscriptionDeletedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
        END;

        Session.LogMessage('00008H9', WebhookSubscriptionDoesNotExistTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
    end;

    local procedure GetBaseURL(): Text[50];
    var
        PayPalUrl: Text;
    begin
        PayPalUrl := GetTargetURL();
        exit(GetURLWithoutQueryParams(PayPalUrl));
    end;

    local procedure GetURLWithoutQueryParams(URL: Text) BaseURL: Text[50];
    var
        ParametersStartPosition: Integer;
    begin
        ParametersStartPosition := STRPOS(URL, '?');
        IF ParametersStartPosition > 0 THEN
            BaseURL := COPYSTR(DELSTR(URL, ParametersStartPosition), 1, MAXSTRLEN(BaseURL))
        ELSE
            BaseURL := COPYSTR(URL, 1, MAXSTRLEN(BaseURL));
    end;

    LOCAL PROCEDURE CreatePaymentRegistrationSetupForCurrentUser();
    VAR
        PaymentRegistrationSetup: Record "Payment Registration Setup";
    BEGIN
        IF PaymentRegistrationSetup.GET(USERID()) THEN BEGIN
            Session.LogMessage('00008HA', PaymentRegistrationSetupAlreadyExistsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
            EXIT;
        END;
        IF PaymentRegistrationSetup.GET() THEN BEGIN
            PaymentRegistrationSetup."User ID" := CopyStr(USERID(), 1, MaxStrLen(PaymentRegistrationSetup."User ID"));
            IF PaymentRegistrationSetup.INSERT(TRUE) THEN BEGIN
                Session.LogMessage('00008HB', PaymentRegistrationSetupCreatedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
                EXIT;
            END;
        END;
        Session.LogMessage('00008HC', PaymentRegistrationSetupNotCreatedTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
    END;
}
