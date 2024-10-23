namespace Microsoft.Bank.PayPal;

using System.Integration;
using System.Privacy;
using Microsoft.Sales.Document;
using Microsoft.CRM.Setup;
using Microsoft.Bank.Payment;
using System.Telemetry;

table 1070 "MS - PayPal Standard Account"
{
    Caption = 'PayPal Payments Standard Account';
    DrillDownPageID = 1070;
    LookupPageID = 1070;
    Permissions = TableData "Webhook Subscription" = rimd;
    ReplicateData = false;
    DataClassification = CustomerContent;

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
                MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
                FeatureTelemetry: Codeunit "Feature Telemetry";
                MSPayPalConsentProvidedLbl: Label 'MS Pay Pal - consent provided by UserSecurityId %1.', Locked = true;
            begin
                if not xRec."Enabled" and Rec."Enabled" then
                    Rec."Enabled" := CustomerConsentMgt.ConfirmUserConsent();

                if Rec.Enabled then begin
                    VerifyAccountID();
                    FeatureTelemetry.LogUptake('0000LHR', MSPayPalStandardMgt.GetFeatureTelemetryName(), Enum::"Feature Uptake Status"::"Set up");
                    Session.LogAuditMessage(StrSubstNo(MSPayPalConsentProvidedLbl, UserSecurityId()), SecurityOperationResult::Success, AuditCategory::ApplicationManagement, 4, 0);
                end;
            end;
        }
        field(5; "Always Include on Documents"; Boolean)
        {

            trigger OnValidate();
            var
                MSPayPalStandardAccount: Record "MS - PayPal Standard Account";
                SalesHeader: Record "Sales Header";
            begin
                if not "Always Include on Documents" then
                    exit;

                MSPayPalStandardAccount.SETRANGE("Always Include on Documents", true);
                MSPayPalStandardAccount.SETFILTER("Primary Key", '<>%1', "Primary Key");
                MSPayPalStandardAccount.MODIFYALL("Always Include on Documents", false, true);

                if not GUIALLOWED() then
                    exit;

                SalesHeader.SETFILTER("Document Type", StrSubstNo(SalesHeaderFilterLbl,
                    SalesHeader."Document Type"::Invoice,
                    SalesHeader."Document Type"::Order,
                    SalesHeader."Document Type"::Quote));

                if not SalesHeader.IsEmpty() and not HideDialogs then
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
        field(20; "Disable Webhook Notifications"; Boolean)
        {
            InitValue = true;

            Caption = 'Disable Webhook Notifications';
            trigger OnValidate()
            var
                MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
            begin
                if "Disable Webhook Notifications" then
                    exit;

                if GuiAllowed() then
                    if not Confirm(EnablePayPalWebhookPaymentRegistrationQst) then
                        Error('');

                if Confirm(UpdatePaymentRegistrationSetupQst) then
                    MSPayPalStandardMgt.RunPaymentRegistrationSetupForce();
            end;
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
        EnablePayPalWebhookPaymentRegistrationQst: Label 'To enable PayPal payment notifications you must have a Business PayPal account.\\Do you want to enable the webhooks for automatic payment registrations from PayPal?';
        UpdatePaymentRegistrationSetupQst: Label 'Would you like to update the Payment Registration setup that will be used to automatically register payments from PayPal?';
        HideDialogs: Boolean;
        SalesHeaderFilterLbl: Label '%1|%2|%3', Comment = '%1,%2 and %3 are Document Types.', Locked = true;

    procedure GetTargetURL(): Text;
    var
        InStream: InStream;
        TargetURL: Text;
    begin
        TargetURL := '';
        CALCFIELDS("Target URL");
        if "Target URL".HASVALUE() then begin
            "Target URL".CREATEINSTREAM(InStream);
            InStream.READ(TargetURL);
        end;
        exit(TargetURL);
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
        if Enabled then
            if "Account ID" = '' then
                if HideDialogs then
                    "Account ID" := ''
                else
                    ERROR(AccountIDCannotBeBlankErr);
    end;

    procedure HideAllDialogs();
    begin
        HideDialogs := true;
    end;

    local procedure UpdateWebhookOnModify();
    var
        PrevMSPayPalStandardAccount: Record "MS - PayPal Standard Account";
    begin
        PrevMSPayPalStandardAccount.GET("Primary Key");

        if PrevMSPayPalStandardAccount."Account ID" <> "Account ID" then
            DeleteWebhookSubscription(PrevMSPayPalStandardAccount."Account ID");

        if "Account ID" <> '' then
            if Enabled then
                RegisterWebhookListenerForRec()
            else
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
        if not WebhookManagement.IsCurrentClientTypeAllowed() then begin
            Session.LogMessage('00008H5', WebhooksNotAllowedForCurrentClientTypeTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
            exit;
        end;

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
        if not WebhookSubscription.INSERT() then
            Session.LogMessage('00008H6', WebhookSubscriptionNotCreatedTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok)
        else
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
        if not WebhookSubscription.IsEmpty() then begin
            WebhookSubscription.DeleteAll(true);
            Session.LogMessage('00008H8', WebhookSubscriptionDeletedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
        end;

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
        if ParametersStartPosition > 0 then
            BaseURL := COPYSTR(DELSTR(URL, ParametersStartPosition), 1, MAXSTRLEN(BaseURL))
        else
            BaseURL := COPYSTR(URL, 1, MAXSTRLEN(BaseURL));
    end;

    local procedure CreatePaymentRegistrationSetupForCurrentUser();
    var
        PaymentRegistrationSetup: Record "Payment Registration Setup";
    begin
        if PaymentRegistrationSetup.Get(UserId()) then begin
            Session.LogMessage('00008HA', PaymentRegistrationSetupAlreadyExistsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
            exit;
        end;
        if PaymentRegistrationSetup.Get() then begin
            PaymentRegistrationSetup."User ID" := CopyStr(USERID(), 1, MaxStrLen(PaymentRegistrationSetup."User ID"));
            if PaymentRegistrationSetup.Insert(true) then begin
                Session.LogMessage('00008HB', PaymentRegistrationSetupCreatedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
                exit;
            end;
        end;
        Session.LogMessage('00008HC', PaymentRegistrationSetupNotCreatedTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
    end;
}
