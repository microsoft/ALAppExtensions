codeunit 1073 "MS - PayPal Webhook Management"
{
    Permissions = TableData "Webhook Subscription" = rimd;
    TableNo = "Webhook Notification";

    trigger OnRun();
    var
        MSPayPalTransactionsMgt: Codeunit "MS - PayPal Transactions Mgt.";
        InvoiceNo: Text;
        InvoiceNoCode: Code[20];
        TotalAmount: Decimal;
    begin
        IF MSPayPalTransactionsMgt.ValidateNotification(Rec, InvoiceNo, TotalAmount) THEN BEGIN
            InvoiceNoCode := COPYSTR(InvoiceNo, 1, MAXSTRLEN(InvoiceNoCode));
            if not PostPaymentForInvoice(InvoiceNoCode, TotalAmount) then begin
                Session.LogMessage('00008IH', PaymentRegistrationFailedTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
                exit;
            end;
            Session.LogMessage('00001V8', MerchantsCustomerPaidTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
        END;
    end;

    var
        PayPalCreatedByTok: Label 'PAYPAL.COM', Locked = true;
        PayPalTelemetryCategoryTok: Label 'AL Paypal', Locked = true;
        MerchantsCustomerPaidTxt: Label 'The payment of the merchant''s customer was successfully processed.', Locked = true;
        ProcessingPaymentInBackgroundSessionTxt: Label 'Processing payment in a background session.', Locked = true;
        ProcessingPaymentInCurrentSessionTxt: Label 'Processing payment in the current session.', Locked = true;
        WebhookSubscriptionNotFoundTxt: Label 'Webhook subscription is not found.', Locked = true;
        NoRemainingPaymentsTxt: Label 'The payment is ignored because no payment remains.', Locked = true;
        OverpaymentTxt: Label 'The payment is ignored because of overpayment.', Locked = true;
        ProcessingWebhookNotificationTxt: Label 'Processing webhook notification.', Locked = true;
        RegisteringPaymentTxt: Label 'Registering the payment.', Locked = true;
        PaymentRegistrationFailedTxt: Label 'Payment registration failed.', Locked = true;
        PaymentRegistrationSucceedTxt: Label 'Payment registration succeed.', Locked = true;

    [EventSubscriber(ObjectType::Table, Database::"Webhook Notification", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncToNavOnWebhookNotificationInsert(var Rec: Record "Webhook Notification"; RunTrigger: Boolean);
    var
        WebhookSubscription: Record "Webhook Subscription";
        AccountID: Text[250];
        BackgroundSessionAllowed: Boolean;
    begin
        if Rec.IsTemporary() then
            exit;

        Session.LogMessage('00008IP', ProcessingWebhookNotificationTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);

        AccountID := LOWERCASE(Rec."Subscription ID");
        WebhookSubscription.SetRange("Subscription ID", AccountID);
        WebhookSubscription.SetFilter("Created By", GetCreatedByFilterForWebhooks());
        IF WebhookSubscription.IsEmpty() THEN BEGIN
            Session.LogMessage('00008GK', WebhookSubscriptionNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
            EXIT;
        END;

        BackgroundSessionAllowed := TRUE;
        OnBeforeRunPayPalNotificationBackgroundSession(BackgroundSessionAllowed);

        IF BackgroundSessionAllowed THEN BEGIN
            Session.LogMessage('00008GM', ProcessingPaymentInBackgroundSessionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
            TASKSCHEDULER.CREATETASK(CODEUNIT::"MS - PayPal Webhook Management", 0, TRUE, COMPANYNAME(), CURRENTDATETIME() + 200, Rec.RECORDID())
        END ELSE BEGIN
            Session.LogMessage('00008GN', ProcessingPaymentInCurrentSessionTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
            CODEUNIT.RUN(CODEUNIT::"MS - PayPal Webhook Management", Rec);
        END;

        COMMIT();
    end;

    procedure GetCreatedByFilterForWebhooks(): Text;
    begin
        exit('@*' + PayPalCreatedByTok + '*');
    end;

    local procedure PostPaymentForInvoice(InvoiceNo: Code[20]; AmountReceived: Decimal): Boolean;
    var
        TempPaymentRegistrationBuffer: Record 981 temporary;
        PaymentMethod: Record "Payment Method";
        PaymentRegistrationMgt: Codeunit "Payment Registration Mgt.";
        O365SalesInvoicePayment: Codeunit "O365 Sales Invoice Payment";
        MSPayPalStandardMgt: Codeunit "MS - PayPal Standard Mgt.";
    begin
        IF NOT O365SalesInvoicePayment.CollectRemainingPayments(InvoiceNo, TempPaymentRegistrationBuffer) THEN BEGIN
            Session.LogMessage('00008GO', NoRemainingPaymentsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
            EXIT(FALSE);
        END;

        IF TempPaymentRegistrationBuffer."Remaining Amount" >= AmountReceived THEN BEGIN
            Session.LogMessage('00008GP', RegisteringPaymentTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
            TempPaymentRegistrationBuffer.VALIDATE("Amount Received", AmountReceived);
            TempPaymentRegistrationBuffer.VALIDATE("Date Received", WORKDATE());
            MSPayPalStandardMgt.GetPayPalPaymentMethod(PaymentMethod);
            TempPaymentRegistrationBuffer.VALIDATE("Payment Method Code", PaymentMethod.Code);
            TempPaymentRegistrationBuffer.MODIFY(TRUE);
            PaymentRegistrationMgt.Post(TempPaymentRegistrationBuffer, FALSE);
            OnAfterPostPayPalPayment(TempPaymentRegistrationBuffer, AmountReceived);
            Session.LogMessage('00008IG', PaymentRegistrationSucceedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
            EXIT(TRUE);
        END;

        Session.LogMessage('00008GQ', OverpaymentTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PayPalTelemetryCategoryTok);
        OnAfterReceivePayPalOverpayment(TempPaymentRegistrationBuffer, AmountReceived);

        EXIT(FALSE);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPayPalPayment(var TempPaymentRegistrationBuffer: Record 981 temporary; AmountReceived: Decimal);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReceivePayPalOverpayment(var TempPaymentRegistrationBuffer: Record 981 temporary; AmountReceived: Decimal);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRunPayPalNotificationBackgroundSession(var AllowBackgroundSessions: Boolean);
    begin
    end;

}


