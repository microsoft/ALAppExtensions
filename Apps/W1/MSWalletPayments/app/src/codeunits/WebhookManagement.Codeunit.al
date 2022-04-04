#if not CLEAN20
codeunit 1083 "MS - Wallet Webhook Management"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '20.0';
    Permissions = TableData "MS - Wallet Charge" = rimd, TableData "Webhook Subscription" = rimd;

    var
        WalletCreatedByTok: Label 'PAY.MICROSOFT', Locked = true;
        InvoiceTxtTok: Label 'Invoice ', Locked = true;
        ChargeDescriptionTok: Label 'Payment for %1';
        ChargeAPIURLFormatTok: Label '%1/v1.0/merchants/%2/charges', Locked = true;
        UnexpectedAccountErr: Label 'Merchant ID %1 is unexpected.';
        TelemetryUnexpectedAccountErr: Label 'Unexpected Merchant ID detected.', Locked = true;
        UnexpectedInvoiceNumberErr: Label 'Invoice number ''%1'' is unexpected.';
        TelemetryUnexpectedInvoiceNumberErr: Label 'Invoice with unexpected number detected.', Locked = true;
        UnexpectedInvoiceClosedErr: Label 'Invoice number ''%1'' is already paid.', Locked = true;
        TelemetryUnexpectedInvoiceClosedErr: Label 'Attempted to pay an invoice that is already paid.', Locked = true;
        UnexpectedCurrencyCodeErr: Label 'Currency code %2 is unexpected. Currency Code ''%2'' does not match ''%3''.';
        UnexpectedAmountErr: Label 'Amount ''%1'' is unexpected.';
        TelemetryUnexpectedAmountErr: Label 'Unexpected amount detected.', Locked = true;
        UnexpectedCreateTimeErr: Label 'Create time ''%1'' is unexpected.';
        MSWalletTelemetryCategoryTok: Label 'AL MSPAY', Locked = true;
        MSWalletChargeTelemetryErr: Label 'Error while charging payment token. Response status code %1, Error: %2.', Locked = true;
        MSWalletChargeErr: Label 'Merchant %1: Error while charging payment token. Response status code %2, Error: %3.', Locked = true;
        ChargeJsonTelemetryTxt: Label 'Error, could not construct Json object for charge call.', Locked = true;

        CancellingPaymentTxt: Label 'Error happened while charging the customer; reversing the last payment.', Locked = true;
        CancellingPaymentDoneTxt: Label 'Error happened while charging the customer; reversing the last payment was done successfully.', Locked = true;
        PostingPaymentErr: Label 'Error happened while posting payment against the invoice.';
        ChargeCallErr: Label 'Error happened while charging customer.';
        CancellingPaymentErrorTxt: Label 'Error happened: charge call failed, then could not revert the posted payment.', Locked = true;
        ActivityCancellingPaymentErrTxt: Label 'Error happened: charge call failed, then could not revert the posted payment for invoice %1.', Locked = true;
        MerchantsCustomerPaidTxt: Label 'The payment of the merchant''s customer was successfully processed.', Locked = true;
        NoWebhookSubscriptionTxt: Label 'Webhook subscription could not be found.';
        SetupUserIsDisabledOrDeletedTxt: Label 'The user that was used to set up Microsoft Pay Payments has been deleted or disabled.';
        NoPaymentRegistrationSetupErrTxt: Label 'The Payment Registration Setup window is not filled in correctly for user %1.';
        PaymentRegistrationSetupFieldErrTxt: Label 'The Payment Registration Setup window is not filled in for user %1.';
        CannotMakePaymentWarningTxt: Label 'You may not be able to accept payments throught Microsoft Pay Payments. %1', Comment = '%1 is an error message.';
        SetupDeleteOrDisableWithOpenInvoiceQst: Label 'You have unpaid invoices with a Microsoft Pay Payments link. Deleting or disabling the Microsoft Pay Payments account setup will make you unable to accept payments through Microsoft Pay Payments.\\ Do you want to continue?';
        ChargeRequestFailedResponseTxt: Label 'Error while charging payment token. Response status code %1.', Locked = true;
        ChargeCannotReadResponseTxt: Label 'Cannot read response on charge call.', Locked = true;
        ChargeEmptyResponseTxt: Label 'Empty reponse on charge call.', Locked = true;
        ChargeIncorrectResponseTxt: Label 'Incorrect reponse on charge call.', Locked = true;
        WebhookSubscriptionNotFoundTxt: Label 'Webhook subscription is not found.', Locked = true;
        NoRemainingPaymentsTxt: Label 'The payment is ignored because no payment remains.', Locked = true;
        OverpaymentTxt: Label 'The payment is ignored because of overpayment.', Locked = true;
        ProcessingWebhookNotificationTxt: Label 'Processing webhook notification.', Locked = true;
        RegisteringPaymentTxt: Label 'Registering the payment.', Locked = true;
        PaymentRegistrationSucceedTxt: Label 'Payment registration succeed.', Locked = true;
        EmptyNotificationTxt: Label 'Webhook notification is empty.', Locked = true;
        IncorrectNotificationTxt: Label 'Webhook notification is incorrect.', Locked = true;
        IgnoreNotificationTxt: Label 'Ignore notification.', Locked = true;
        VerifyNotificationContentTxt: Label 'Verify notification content.', Locked = true;
        NotificationContentVerifiedTxt: Label 'Notification content is successfully verified.', Locked = true;
        VerifyTransactionDetailsTxt: Label 'Verify transaction details.', Locked = true;
        TransactionDetailsVerifiedTxt: Label 'Transaction details are successfully verified.', Locked = true;
        SaveChargeResourceTxt: Label 'Save charge resource.', Locked = true;
        CannotParseAmountTxt: Label 'Cannot parse amount.', Locked = true;
        CannotParseCreateTimeTxt: Label 'Cannot parse create time.', Locked = true;
        UnexpectedCurrencyCodeTelemetryTxt: Label 'Unexpected currency code.', Locked = true;
        MSPayContextTxt: Label 'MSPay', Locked = true;

    [EventSubscriber(ObjectType::Table, Database::"Webhook Notification", 'OnAfterInsertEvent', '', false, false)]
    local procedure SyncToNavOnWebhookNotificationInsert(var Rec: Record "Webhook Notification"; RunTrigger: Boolean);
    var
        WebhookSubscription: Record "Webhook Subscription";
        MSWalletMerchantAccount: Record "MS - Wallet Merchant Account";
        JObject: JsonObject;
        SubscriptionID: Text[250];
        PaymentToken: Text;
        MerchantID: Text[150];
        InvoiceNoTxt: Text;
        CurrencyCode: Code[10];
        InvoiceNoCode: Code[20];
        TotalAmount: Decimal;
        PayerEmail: Text;
    begin
        if Rec.IsTemporary() then
            exit;

        Session.LogMessage('00008IE', ProcessingWebhookNotificationTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);

        SubscriptionID := LOWERCASE(Rec."Subscription ID");
        WebhookSubscription.SetRange("Subscription ID", SubscriptionID);
        WebhookSubscription.SetFilter("Created By", GetCreatedByFilterForWebhooks());
        IF WebhookSubscription.IsEmpty() THEN BEGIN
            Session.LogMessage('00008HI', WebhookSubscriptionNotFoundTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            EXIT;
        END;

        IF NOT GetNotificationJson(Rec, JObject) THEN BEGIN
            Session.LogMessage('00008HK', IgnoreNotificationTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            EXIT;
        END;

        MerchantID := GetMerchantIDFromSubscriptionID(Rec."Subscription ID");

        MSWalletMerchantAccount.SETRANGE("Merchant ID", MerchantID);
        IF NOT MSWalletMerchantAccount.FINDFIRST() THEN BEGIN
            Session.LogMessage('00001CP', TelemetryUnexpectedAccountErr, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            LogActivity(StrSubstNo(UnexpectedAccountErr, MerchantID), '');
            ERROR(UnexpectedAccountErr, MerchantID);
        END;

        GetDetailsFromNotification(JObject, InvoiceNoTxt, PaymentToken, CurrencyCode, TotalAmount, PayerEmail);

        IF STRPOS(InvoiceNoTxt, InvoiceTxtTok) = 1 THEN
            InvoiceNoCode := CopyStr(DELSTR(InvoiceNoTxt, 1, STRLEN(InvoiceTxtTok)), 1, MaxStrLen(InvoiceNoCode))
        ELSE
            InvoiceNoCode := COPYSTR(InvoiceNoTxt, 1, MAXSTRLEN(InvoiceNoCode));

        ValidateInvoiceDetails(InvoiceNoCode, TotalAmount, CurrencyCode);

        IF not PostPaymentForInvoice(InvoiceNoCode, TotalAmount) THEN
            Error(PostingPaymentErr);

        IF NOT ChargePaymentNotification(MSWalletMerchantAccount, InvoiceNoTxt, TotalAmount, PaymentToken, CurrencyCode, PayerEmail) THEN begin
            // An error happened while charging the user: reverse the payment posted against the invoice
            if not CancelInvoiceLastPayment(InvoiceNoCode) then begin
                Session.LogMessage('00001TZ', CancellingPaymentErrorTxt, Verbosity::Critical, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok); // payment has been posted and could not revert it, but user was not charged
                LogActivity(StrSubstNo(ActivityCancellingPaymentErrTxt, InvoiceNoCode), '');
            end;
            Error(ChargeCallErr);
        end;

        Session.LogMessage('00001V7', MerchantsCustomerPaidTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
    end;

    procedure GetCreatedByFilterForWebhooks(): Text;
    begin
        exit('@*' + WalletCreatedByTok + '*');
    end;

    procedure GetNotificationUrl(): Text[250];
    var
        WebhookManagement: Codeunit "Webhook Management";
    begin
        exit(LOWERCASE(WebhookManagement.GetNotificationUrl()));
    end;

    procedure GetWebhookSubscriptionID(AccountID: Text[250]): Text[250];
    begin
        EXIT(CopyStr(LowerCase(StrSubstNo('%1_%2', AccountID, CompanyProperty.UrlName())), 1, 250));
    end;

    procedure GetMerchantIDFromSubscriptionID(SubscriptionID: Text[250]): Text[150];
    var
        SplitIndex: Integer;
    begin
        SplitIndex := SubscriptionID.IndexOf('_');
        if SplitIndex = 0 then
            exit(CopyStr(SubscriptionID, 1, 150));
        exit(CopyStr(SubscriptionID.Substring(1, SplitIndex - 1), 1, 150));
    end;

    procedure PostPaymentForInvoice(InvoiceNo: Code[20]; AmountReceived: Decimal): Boolean;
    var
        TempPaymentRegistrationBuffer: Record "Payment Registration Buffer" temporary;
        PaymentMethod: Record "Payment Method";
        PaymentRegistrationMgt: Codeunit "Payment Registration Mgt.";
        O365SalesInvoicePayment: Codeunit "O365 Sales Invoice Payment";
        MSWalletMgt: Codeunit "MS - Wallet Mgt.";
    begin
        IF NOT O365SalesInvoicePayment.CollectRemainingPayments(InvoiceNo, TempPaymentRegistrationBuffer) THEN BEGIN
            Session.LogMessage('00008HL', NoRemainingPaymentsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            EXIT(FALSE);
        END;

        IF TempPaymentRegistrationBuffer."Remaining Amount" >= AmountReceived THEN BEGIN
            Session.LogMessage('00008HM', RegisteringPaymentTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            TempPaymentRegistrationBuffer.VALIDATE("Amount Received", AmountReceived);
            TempPaymentRegistrationBuffer.VALIDATE("Date Received", WORKDATE());
            MSWalletMgt.GetWalletPaymentMethod(PaymentMethod);
            TempPaymentRegistrationBuffer.VALIDATE("Payment Method Code", PaymentMethod.Code);
            TempPaymentRegistrationBuffer.MODIFY(TRUE);
            PaymentRegistrationMgt.Post(TempPaymentRegistrationBuffer, FALSE);
            OnAfterPostWalletPayment(TempPaymentRegistrationBuffer, AmountReceived);
            Session.LogMessage('00008ID', PaymentRegistrationSucceedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            EXIT(TRUE);
        END;

        Session.LogMessage('00008HN', OverpaymentTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
        OnAfterReceiveWalletOverpayment(TempPaymentRegistrationBuffer, AmountReceived);

        EXIT(FALSE);
    end;

    local procedure ChargePaymentNotification(MSWalletMerchantAccount: Record "MS - Wallet Merchant Account"; InvoiceNoTxt: Text; GrossAmount: Decimal; PaymentToken: Text; CurrencyCode: Code[10]; receiptEmail: Text): Boolean;
    var
        MSWalletMgt: Codeunit "MS - Wallet Mgt.";
        RequestHttpClient: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestContent: HttpContent;
        RequestHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        JObject: JsonObject;
        AuthHeader: Text;
        RequestPayload: Text;
        JPayload: JsonObject;
        ChargeAPIURL: Text;
    begin
        AuthHeader := MSWalletMgt.GetAADAuthHeader(MSWalletMerchantAccount.GetBaseURL());

        ChargeAPIURL := STRSUBSTNO(ChargeAPIURLFormatTok, MSWalletMerchantAccount.GetBaseURL(), MSWalletMerchantAccount."Merchant ID");

        JPayload.Add('idempotencyKey', CreateGuid());
        JPayload.Add('referenceId', InvoiceNoTxt);
        JPayload.Add('amount', GrossAmount);
        JPayload.Add('currency', CurrencyCode);
        JPayload.Add('paymentToken', PaymentToken);
        JPayload.Add('description', STRSUBSTNO(ChargeDescriptionTok, InvoiceNoTxt));
        JPayload.Add('receiptEmail', receiptEmail);

        if not JPayload.WriteTo(RequestPayload) then begin
            Session.LogMessage('00001YC', ChargeJsonTelemetryTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            LogActivity(ChargeJsonTelemetryTxt, '');
        end;

        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('Authorization', AuthHeader);
        RequestHeaders.Add('MS-AccountMode', GetMSAccountMode(MSWalletMerchantAccount));
        RequestMessage.SetRequestUri(ChargeAPIURL);
        RequestMessage.Method('POST');
        RequestContent.GetHeaders(ContentHeaders);
        RequestContent.WriteFrom(RequestPayload);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json; charset=utf-8');
        RequestMessage.Content(RequestContent);

        if not RequestHttpClient.Send(RequestMessage, ResponseMessage) then begin
            Session.LogMessage('00008HO', StrSubstNo(ChargeRequestFailedResponseTxt, ResponseMessage.HttpStatusCode()), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            Session.LogMessage('00001P6', STRSUBSTNO(MSWalletChargeTelemetryErr, ResponseMessage.HttpStatusCode(), GETLASTERRORTEXT()), Verbosity::Error, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            LogActivity(STRSUBSTNO(MSWalletChargeErr, MSWalletMerchantAccount."Merchant ID", ResponseMessage.HttpStatusCode(), GETLASTERRORTEXT()), RequestPayload);
            EXIT(FALSE);
        END;

        if GetChargeResource(ResponseMessage, JObject) then
            exit(SaveChargeResource(JObject));

        Session.LogMessage('00001P7', STRSUBSTNO(MSWalletChargeTelemetryErr, ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase()), Verbosity::Error, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
        LogActivity(STRSUBSTNO(MSWalletChargeErr, MSWalletMerchantAccount."Merchant ID", ResponseMessage.HttpStatusCode(), ResponseMessage.ReasonPhrase()), RequestPayload);
        EXIT(FALSE);
    end;

    local procedure GetChargeResource(var ResponseMessage: HttpResponseMessage; var JObject: JsonObject): Boolean;
    var
        ResponseText: Text;
    begin
        if not ResponseMessage.IsSuccessStatusCode() then begin
            Session.LogMessage('00008HP', StrSubstNo(ChargeRequestFailedResponseTxt, ResponseMessage.HttpStatusCode()), Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            exit(false);
        end;
        if not ResponseMessage.Content().ReadAs(ResponseText) then begin
            Session.LogMessage('00008HQ', ChargeCannotReadResponseTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            exit(false);
        end;
        if ResponseText = '' then begin
            Session.LogMessage('00008HR', ChargeEmptyResponseTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            exit(false);
        end;
        if not JObject.ReadFrom(ResponseText) then begin
            Session.LogMessage('00008HS', ChargeIncorrectResponseTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            exit(false);
        end;
        exit(true);
    end;

    local procedure GetNotificationJson(var WebhookNotification: Record "Webhook Notification"; var JObject: JsonObject): Boolean;
    var
        NotificationStream: InStream;
        NotificationString: Text;
    begin
        Session.LogMessage('00008HT', VerifyNotificationContentTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);

        NotificationString := '';
        WebhookNotification.CALCFIELDS(Notification);
        IF NOT WebhookNotification.Notification.HASVALUE() THEN BEGIN
            Session.LogMessage('00008HU', EmptyNotificationTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            EXIT(FALSE);
        END;

        WebhookNotification.Notification.CREATEINSTREAM(NotificationStream);
        NotificationStream.READ(NotificationString);

        IF NOT JObject.ReadFrom(NotificationString) THEN BEGIN
            Session.LogMessage('00008HV', IncorrectNotificationTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            EXIT(FALSE);
        END;

        Session.LogMessage('00008HW', NotificationContentVerifiedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
        EXIT(TRUE);
    end;

    local procedure GetDetailsFromNotification(var JObject: JsonObject; var InvoiceNo: Text; var PaymentToken: Text; var CurrencyCode: Code[10]; var GrossAmount: Decimal; var PayerEmail: Text);
    var
        CurrencyCodeTxt: Text;
        GrossAmountTxt: Text;
    begin
        GetJsonPropertyValueByPath(JObject, 'paymentResponse.details.paymentToken', PaymentToken);
        GetJsonPropertyValueByPath(JObject, 'paymentRequest.details.total.label', InvoiceNo);
        GetJsonPropertyValueByPath(JObject, 'paymentRequest.details.total.amount.value', GrossAmountTxt);
        GetJsonPropertyValueByPath(JObject, 'paymentRequest.details.total.amount.currency', CurrencyCodeTxt);
        GetJsonPropertyValueByPath(JObject, 'paymentResponse.payerEmail', PayerEmail);

        IF NOT EVALUATE(GrossAmount, GrossAmountTxt, 9) THEN
            Session.LogMessage('00008HX', CannotParseAmountTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
        CurrencyCode := COPYSTR(CurrencyCodeTxt, 1, MAXSTRLEN(CurrencyCode));
    end;

    local procedure ValidateInvoiceDetails(InvoiceNoCode: Code[20]; GrossAmount: Decimal; CurrencyCode: Code[10]);
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        InvoiceCurrencyCode: Code[10];
    begin
        Session.LogMessage('00008HY', VerifyTransactionDetailsTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);

        IF NOT SalesInvoiceHeader.GET(InvoiceNoCode) THEN BEGIN
            Session.LogMessage('00001P8', TelemetryUnexpectedInvoiceNumberErr, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            LogActivity(StrSubstNo(UnexpectedInvoiceNumberErr, InvoiceNoCode), '');
            ERROR(UnexpectedInvoiceNumberErr, InvoiceNoCode);
        END;

        SalesInvoiceHeader.CALCFIELDS(Closed);
        IF SalesInvoiceHeader.Closed THEN BEGIN
            Session.LogMessage('00001P9', TelemetryUnexpectedInvoiceClosedErr, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            LogActivity(StrSubstNo(UnexpectedInvoiceClosedErr, InvoiceNoCode), '');
            ERROR(UnexpectedInvoiceClosedErr, InvoiceNoCode);
        END;

        InvoiceCurrencyCode := SalesInvoiceHeader."Currency Code";
        IF InvoiceCurrencyCode = '' THEN
            InvoiceCurrencyCode := GetDefaultCurrencyCode();
        IF InvoiceCurrencyCode <> UPPERCASE(CurrencyCode) THEN BEGIN
            Session.LogMessage('00001PA', UnexpectedCurrencyCodeTelemetryTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            LogActivity(StrSubstNo(UnexpectedCurrencyCodeErr, CurrencyCode, InvoiceCurrencyCode), '');
            ERROR(UnexpectedCurrencyCodeErr, CurrencyCode, InvoiceCurrencyCode);
        END;

        IF GrossAmount <= 0 THEN BEGIN
            Session.LogMessage('00001PB', TelemetryUnexpectedAmountErr, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            LogActivity(StrSubstNo(UnexpectedAmountErr, GrossAmount), '');
            ERROR(UnexpectedAmountErr, GrossAmount);
        END;

        Session.LogMessage('00008HZ', TransactionDetailsVerifiedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
    end;

    local procedure SaveChargeResource(JObject: JsonObject): Boolean;
    var
        MSWalletCharge: Record "MS - Wallet Charge";
        CreateTime: DateTime;
        ChargeAmount: Decimal;
        chargeIdTxt: Text;
        merchantIdTxt: Text;
        createTimeTxt: Text;
        statusTxt: Text;
        currencyTxt: Text;
        descriptionTxt: Text;
        amountTxt: Text;
        referenceIdTxt: Text;
        paymentMethodDescriptionTxt: Text;
    begin
        Session.LogMessage('00008I0', SaveChargeResourceTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);

        GetJsonPropertyValue(JObject, 'chargeId', chargeIdTxt);
        MSWalletCharge.VALIDATE("Charge ID", chargeIdTxt);

        GetJsonPropertyValue(JObject, 'merchantId', merchantIdTxt);
        MSWalletCharge.VALIDATE("Merchant ID", merchantIdTxt);

        GetJsonPropertyValue(JObject, 'createTime', createTimeTxt);

        IF NOT TryParseDateTime(createTimeTxt, CreateTime) THEN BEGIN
            Session.LogMessage('00001PC', CannotParseCreateTimeTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            LogActivity(STRSUBSTNO(UnexpectedCreateTimeErr, createTimeTxt), '');
            EXIT(FALSE);
        END;

        MSWalletCharge.VALIDATE("Create Time", CreateTime);

        GetJsonPropertyValue(JObject, 'status', statusTxt);
        MSWalletCharge.VALIDATE(Status, COPYSTR(statusTxt, 1, MAXSTRLEN(MSWalletCharge.Status)));

        GetJsonPropertyValue(JObject, 'description', descriptionTxt);
        MSWalletCharge.VALIDATE(Description, descriptionTxt);

        GetJsonPropertyValue(JObject, 'currency', currencyTxt);
        MSWalletCharge.VALIDATE(Currency, COPYSTR(currencyTxt, 1, MAXSTRLEN(MSWalletCharge.Currency)));

        GetJsonPropertyValue(JObject, 'amount', amountTxt);
        IF NOT EVALUATE(ChargeAmount, amountTxt, 9) THEN BEGIN
            Session.LogMessage('00001PD', CannotParseAmountTxt, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
            LogActivity(STRSUBSTNO(UnexpectedAmountErr, amountTxt), '');
            EXIT(FALSE);
        END;

        MSWalletCharge.VALIDATE(Amount, ChargeAmount);

        GetJsonPropertyValue(JObject, 'referenceId', referenceIdTxt);
        MSWalletCharge.VALIDATE("Reference ID", referenceIdTxt);

        GetJsonPropertyValue(JObject, 'paymentMethodDescription', paymentMethodDescriptionTxt);
        MSWalletCharge.VALIDATE("Payment Method Description", paymentMethodDescriptionTxt);

        MSWalletCharge.INSERT(TRUE);
        EXIT(TRUE);
    end;

    local procedure GetMSAccountMode(MSWalletMerchantAccount: Record "MS - Wallet Merchant Account"): Text;
    begin
        IF MSWalletMerchantAccount."Test Mode" OR (STRPOS(LOWERCASE(MSWalletMerchantAccount.GetBaseURL()), 'ppe') <> 0) THEN
            EXIT('TEST');

        EXIT('LIVE');
    end;

    local procedure GetDefaultCurrencyCode(): Code[10];
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CurrencyCode: Code[10];
    begin
        GeneralLedgerSetup.GET();
        CurrencyCode := GeneralLedgerSetup.GetCurrencyCode(CurrencyCode);
        EXIT(CurrencyCode);
    end;

    local procedure TryParseDateTime(DateTimeText: Text; var ResultDateTime: DateTime): Boolean;
    var
        TypeHelper: Codeunit "Type Helper";
        DateTimeVariant: Variant;
    begin
        DateTimeVariant := 0DT;
        if not TypeHelper.Evaluate(DateTimeVariant, DateTimeText, '', '') then
            exit(false);

        ResultDateTime := DateTimeVariant;
        exit(true);
    end;

    [BusinessEvent(false)]
    local procedure OnAfterPostWalletPayment(var TempPaymentRegistrationBuffer: Record "Payment Registration Buffer" temporary; AmountReceived: Decimal);
    begin
    end;

    [BusinessEvent(false)]
    local procedure OnAfterReceiveWalletOverpayment(var TempPaymentRegistrationBuffer: Record "Payment Registration Buffer" temporary; AmountReceived: Decimal);
    begin
    end;

    [Scope('OnPrem')]
    procedure CancelInvoiceLastPayment(SalesInvoiceDocumentNo: Code[20]): Boolean;
    var
        InvoiceCustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentCustLedgerEntry: Record "Cust. Ledger Entry";
        ReversalEntry: Record "Reversal Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
    begin
        Session.LogMessage('00001PE', CancellingPaymentTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
        LogActivity(CancellingPaymentTxt, SalesInvoiceDocumentNo);

        // Find the customer ledger entry related to the invoice
        InvoiceCustLedgerEntry.SETRANGE("Document Type", InvoiceCustLedgerEntry."Document Type"::Invoice);
        InvoiceCustLedgerEntry.SETRANGE("Document No.", SalesInvoiceDocumentNo);
        IF NOT InvoiceCustLedgerEntry.FINDFIRST() THEN
            EXIT(FALSE); // The invoice does not exist

        // Find the customer ledger entry related to the payment of the invoice
        PaymentCustLedgerEntry.Get(InvoiceCustLedgerEntry."Closed by Entry No.");

        IF NOT PaymentCustLedgerEntry.FINDLAST() THEN
            EXIT(FALSE);

        // Get detailed ledger entry for the payment, making sure it's a payment
        DetailedCustLedgEntry.SETRANGE("Document Type", DetailedCustLedgEntry."Document Type"::Payment);
        DetailedCustLedgEntry.SETRANGE("Document No.", PaymentCustLedgerEntry."Document No.");
        DetailedCustLedgEntry.SETRANGE("Cust. Ledger Entry No.", PaymentCustLedgerEntry."Entry No.");
        DetailedCustLedgEntry.SETRANGE(Unapplied, FALSE);
        IF NOT DetailedCustLedgEntry.FINDLAST() THEN
            EXIT(FALSE);

        ApplyUnapplyParameters."Document No." := DetailedCustLedgEntry."Document No.";
        ApplyUnapplyParameters."Posting Date" := DetailedCustLedgEntry."Posting Date";
        CustEntryApplyPostedEntries.PostUnApplyCustomerCommit(
          DetailedCustLedgEntry, ApplyUnapplyParameters, true);

        ReversalEntry.SetHideWarningDialogs();
        ReversalEntry.ReverseTransaction(PaymentCustLedgerEntry."Transaction No.");
        Commit();

        Session.LogMessage('00001PF', CancellingPaymentDoneTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', MSWalletTelemetryCategoryTok);
        LogActivity(CancellingPaymentDoneTxt, SalesInvoiceDocumentNo);
        EXIT(TRUE);
    end;

    local procedure GetJsonPropertyValueByPath(JObject: JsonObject; PropertyPath: Text; var PropertyValue: Text);
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        PropertyValue := '';
        if not JObject.SelectToken(PropertyPath, JToken) then
            exit;
        if not JToken.IsValue() then
            exit;
        JValue := JToken.AsValue();
        if JValue.IsNull() then
            exit;
        PropertyValue := JValue.AsText();
    end;

    local procedure GetJsonPropertyValue(JObject: JsonObject; PropertyKey: Text; var PropertyValue: Text);
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        PropertyValue := '';
        if not JObject.Get(PropertyKey, JToken) then
            exit;
        if not JToken.IsValue() then
            exit;
        JValue := JToken.AsValue();
        if JValue.IsNull() then
            exit;
        PropertyValue := JValue.AsText();
    end;

    local procedure LogActivity(ErrorDescription: Text; ErrorMsg: Text)
    var
        ActivityLog: Record "Activity Log";
        MSWalletMerchantAccount: Record "MS - Wallet Merchant Account";
    begin
        if MSWalletMerchantAccount.FindFirst() then;
        ActivityLog.LogActivity(MSWalletMerchantAccount.RecordId(), ActivityLog.Status::Failed, MSPayContextTxt, ErrorDescription, ErrorMsg);
    end;

    procedure ShowWarningIfCannotMakePayment(MSWalletMerchantAccount: Record "MS - Wallet Merchant Account")
    var
        ErrorMsg: Text;
    begin
        if not GuiAllowed() then
            exit;
        if not CanAcceptWebhookPayment(MSWalletMerchantAccount, ErrorMsg) then
            Message(StrSubstNo(CannotMakePaymentWarningTxt, ErrorMsg));
    end;

    procedure CanAcceptWebhookPayment(MSWalletMerchantAccount: Record "MS - Wallet Merchant Account"; var ErrorMsg: Text): Boolean;
    var
        WebhookSubscription: Record "Webhook Subscription";
        User: Record "User";
        PaymentRegistrationSetup: Record "Payment Registration Setup";
    begin
        WebhookSubscription.SetRange("Subscription ID", GetWebhookSubscriptionID(MSWalletMerchantAccount."Merchant ID"));
        WebhookSubscription.SetFilter("Created By", GetCreatedByFilterForWebhooks());
        if not WebhookSubscription.FindFirst() then begin
            ErrorMsg := NoWebhookSubscriptionTxt;
            exit(false);
        end;

        if not IsEnabledUser(WebhookSubscription."Run Notification As", User) then begin
            ErrorMsg := SetupUserIsDisabledOrDeletedTxt;
            exit(false);
        end;

        if not PaymentRegistrationSetup.GET(User."User Name") then begin
            ErrorMsg := StrSubstNo(NoPaymentRegistrationSetupErrTxt, User."User Name");
            exit(false);
        end;
        if not PaymentRegistrationSetup.ValidateMandatoryFields(false) then begin
            ErrorMsg := StrSubstNo(PaymentRegistrationSetupFieldErrTxt, WebhookSubscription."Run Notification As");
            exit(false);
        end;
        exit(true);
    end;

    local PROCEDURE IsEnabledUser(UserSID: GUID; var User: Record "User"): Boolean;
    BEGIN
        IF User.GET(UserSID) THEN
            EXIT(User.State = User.State::Enabled);

        EXIT(FALSE);
    END;

    [EventSubscriber(ObjectType::Table, Database::"MS - Wallet Merchant Account", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteMSWalletAccount(var Rec: Record "MS - Wallet Merchant Account"; RunTrigger: Boolean);
    begin
        if Rec.IsTemporary() then
            exit;

        CheckMSWalletAccountWithOpenInvoices();
    end;

    [EventSubscriber(ObjectType::Table, Database::"MS - Wallet Merchant Account", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure OnBeforeDisableMSWalletAccount(VAR Rec: Record "MS - Wallet Merchant Account"; VAR xRec: Record "MS - Wallet Merchant Account"; CurrFieldNo: Integer)
    begin
        if not Rec.Enabled and xRec.Enabled then
            CheckMSWalletAccountWithOpenInvoices();
    end;

    local procedure CheckMSWalletAccountWithOpenInvoices();
    var
        MSWalletPayment: Record "MS - Wallet Payment";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        EnvInfoProxy: Codeunit "Env. Info Proxy";
    begin
        if not GuiAllowed() then
            exit;

        if EnvInfoProxy.IsInvoicing() then
            exit;

        if not MSWalletPayment.FindSet() then
            exit;
        repeat
            IF SalesInvoiceHeader.GET(MSWalletPayment."Invoice No") THEN BEGIN
                SalesInvoiceHeader.CALCFIELDS(Closed);
                IF not SalesInvoiceHeader.Closed THEN begin
                    if Confirm(SetupDeleteOrDisableWithOpenInvoiceQst) then
                        exit;
                    Error('');
                end;
            end;
        until MSWalletPayment.Next() = 0;
    end;
}
#endif