codeunit 1075 "MS - PayPal Transactions Mgt."
{

    trigger OnRun();
    begin
    end;

    var
        CompletedTok: Label 'COMPLETED', Locked = true;
        PaymentDateFormat1Txt: Label '"HH:mm:ss MMM dd yyyy zzz"', Locked = true;
        PaymentDateFormat2Txt: Label '"HH:mm:ss dd MMM yyyy zzz"', Locked = true;
        CommaTxt: Label ',', Locked = true;
        PdtTimeZoneNameTxt: Label 'PDT', Locked = true;
        PstTimeZoneNameTxt: Label 'PST', Locked = true;
        PdtTimeZoneValueTxt: Label '-07:00', Locked = true;
        PstTimeZoneValueTxt: Label '-08:00', Locked = true;
        UnexpectedAccountErr: Label 'PayPal account %1 in transaction %2 is unexpected.', Comment = '%1=PayPal account ID, %2=transaction ID';
        TelemetryUnexpectedAccountErr: Label 'Detected usage of unexpected PayPal account.', Locked = true;
        UnexpectedInvoiceNumberErr: Label 'Invoice number %1 in transaction %2 is unexpected.', Comment = '%1=invoice number, %2=transaction ID';
        TelemetryUnexpectedInvoiceNumberErr: Label 'Detected an invoice with unexpected number.', Locked = true;
        UnexpectedCurrencyCodeErr: Label 'Currency code %1 in transaction %2 is unexpected.', Comment = '%1=currency code, %2=transaction ID';
        TelemetryUnexpectedCurrencyCodeErr: Label 'Currency code %1 is unexpected in this transaction.', Locked = true;
        UnexpectedAmountErr: Label 'Gross amount %1 in transaction %2 is unexpected.', Comment = '%1=decimal value, %2=transaction ID';
        AlreadyProcessedErr: Label 'Transaction %2 with status %1 has already been processed.', Comment = '%1=status code (arbitrary text), %2=transaction ID';
        TelemetryAlreadyProcessedErr: Label 'Transaction (with status %1) has already been processed.', Locked = true;
        EmptyNotificationErr: Label 'Webhook notification is empty.';
        TelemetryEmptyNotificationErr: Label 'Webhook notification is empty.', Locked = true;
        IgnoreNotificationTxt: Label 'Ignore notification.', Locked = true;
        VerifyNotificationContentTxt: Label 'Verify notification content.', Locked = true;
        NotificationContentVerifiedTxt: Label 'Notification content is successfully verified.', Locked = true;
        VerifyTransactionDetailsTxt: Label 'Verify transaction details.', Locked = true;
        TransactionDetailsVerifiedTxt: Label 'Transaction details are successfully verified.', Locked = true;
        TransactionNotCompletedTxt: Label 'Transaction is not completed.', Locked = true;
        GetTransactionDetailsTxt: Label 'Get transaction details.', Locked = true;
        InsertTransactionDetailsTxt: Label 'Insert transaction details.', Locked = true;
        UpdateTransactionDetailsTxt: Label 'Update transaction details.', Locked = true;
        CannotParseGrossAmountTxt: Label 'Cannot parse gross amount.', Locked = true;
        GrossAmountLessOrEqualToZeroTxt: Label 'Gross amount is less or equal to zero.', Locked = true;
        CannotParseFeeAmountTxt: Label 'Cannot parse fee amount.', Locked = true;
        CannotParsePaymentDateTxt: Label 'Cannot parse payment date. UTC now is used instead.', Locked = true;
        PayPalTelemetryCategoryTok: Label 'AL Paypal', Locked = true;

    procedure ValidateNotification(var WebhookNotification: Record 2000000194; var InvoiceNo: Text; var GrossAmount: Decimal): Boolean;
    var
        JsonString: Text;
        AccountID: Text;
        TransactionID: Text;
        PayPalTransactionType: Text;
        TransactionDate: DateTime;
        TransactionStatus: Text;
        CurrencyCode: Text;
        PayerEmail: Text;
        PayerName: Text;
        PayerAddress: Text;
        Custom: Text;
        FeeAmount: Decimal;
    begin
        SendTraceTag('00008GR', PayPalTelemetryCategoryTok, VERBOSITY::Normal, VerifyNotificationContentTxt, DataClassification::SystemMetadata);

        JsonString := GetNotificationJsonString(WebhookNotification);
        IF JsonString = '' THEN BEGIN
            SendTraceTag('00008GS', PayPalTelemetryCategoryTok, VERBOSITY::Error, TelemetryEmptyNotificationErr, DataClassification::SystemMetadata);
            ERROR(EmptyNotificationErr);
        END;

        GetTransactionDetailsFromNotification(
          JsonString, AccountID, TransactionID, PayPalTransactionType, TransactionDate, TransactionStatus,
          InvoiceNo, CurrencyCode, GrossAmount, FeeAmount, PayerEmail, PayerName, PayerAddress, Custom);

        IF NOT ValidateTransactionDetails(
             AccountID, TransactionID, TransactionStatus, InvoiceNo, CurrencyCode, GrossAmount)
        THEN BEGIN
            SendTraceTag('00008GT', PayPalTelemetryCategoryTok, VERBOSITY::Normal, IgnoreNotificationTxt, DataClassification::SystemMetadata);
            EXIT(FALSE);
        END;

        SendTraceTag('00008GU', PayPalTelemetryCategoryTok, VERBOSITY::Normal, NotificationContentVerifiedTxt, DataClassification::SystemMetadata);

        SaveTransactionDetails(
          AccountID, TransactionID, PayPalTransactionType, TransactionDate, TransactionStatus, InvoiceNo, CurrencyCode,
          GrossAmount, GrossAmount - FeeAmount, FeeAmount, PayerEmail, PayerName, PayerAddress, Custom, '', JsonString);

        EXIT(TRUE);
    end;

    local procedure ValidateTransactionDetails(AccountID: Text; TransactionID: Text; TransactionStatus: Text; InvoiceNo: Text; CurrencyCode: Text; GrossAmount: Decimal): Boolean;
    var
        MSPayPalTransaction: Record 1077;
        MSPayPalStandardAccount: Record 1070;
        SalesInvoiceHeader: Record 112;
        InvoiceCurrencyCode: Code[10];
    begin
        SendTraceTag('00008GV', PayPalTelemetryCategoryTok, VERBOSITY::Normal, VerifyTransactionDetailsTxt, DataClassification::SystemMetadata);

        IF UPPERCASE(TransactionStatus) <> CompletedTok THEN BEGIN
            SendTraceTag('00008GW', PayPalTelemetryCategoryTok, VERBOSITY::Normal, TransactionNotCompletedTxt, DataClassification::SystemMetadata);
            EXIT(FALSE);
        END;

        MSPayPalStandardAccount.SETRANGE("Account ID", AccountID);
        IF MSPayPalStandardAccount.IsEmpty() THEN BEGIN
            SENDTRACETAG('0000166', PayPalTelemetryCategoryTok, VERBOSITY::Normal, TelemetryUnexpectedAccountErr, DataClassification::SystemMetadata);
            ERROR(UnexpectedAccountErr, AccountID, TransactionID);
        END;

        IF NOT SalesInvoiceHeader.GET(InvoiceNo) THEN BEGIN
            SENDTRACETAG('0000167', PayPalTelemetryCategoryTok, VERBOSITY::Normal, TelemetryUnexpectedInvoiceNumberErr, DataClassification::SystemMetadata);
            ERROR(UnexpectedInvoiceNumberErr, InvoiceNo, TransactionID);
        END;

        InvoiceCurrencyCode := SalesInvoiceHeader."Currency Code";
        IF InvoiceCurrencyCode = '' THEN
            InvoiceCurrencyCode := GetDefaultCurrencyCode();
        IF InvoiceCurrencyCode <> UPPERCASE(CurrencyCode) THEN BEGIN
            SENDTRACETAG('0000168', PayPalTelemetryCategoryTok, VERBOSITY::Normal, STRSUBSTNO(TelemetryUnexpectedCurrencyCodeErr, CurrencyCode), DataClassification::SystemMetadata);
            ERROR(UnexpectedCurrencyCodeErr, CurrencyCode, TransactionID);
        END;

        IF GrossAmount <= 0 THEN BEGIN
            SendTraceTag('00008GX', PayPalTelemetryCategoryTok, VERBOSITY::Normal, GrossAmountLessOrEqualToZeroTxt, DataClassification::SystemMetadata);
            ERROR(UnexpectedAmountErr, GrossAmount, TransactionID);
        END;

        MSPayPalTransaction.SETFILTER("Account ID", AccountID);
        MSPayPalTransaction.SETFILTER("Transaction ID", TransactionID);
        MSPayPalTransaction.SETFILTER("Transaction Status", TransactionStatus);
        IF NOT MSPayPalTransaction.IsEmpty() THEN BEGIN
            SENDTRACETAG('0000169', PayPalTelemetryCategoryTok, VERBOSITY::Warning, STRSUBSTNO(TelemetryAlreadyProcessedErr, TransactionStatus), DataClassification::SystemMetadata);
            ERROR(AlreadyProcessedErr, TransactionID, TransactionStatus);
        END;

        SendTraceTag('00008GY', PayPalTelemetryCategoryTok, VERBOSITY::Normal, TransactionDetailsVerifiedTxt, DataClassification::SystemMetadata);
        EXIT(TRUE);
    end;

    local procedure SaveTransactionDetails(AccountID: Text; TransactionID: Text; PayPalTransactionType: Text; TransactionDate: DateTime; TransactionStatus: Text; InvoiceNo: Text; CurrencyCode: Text; GrossAmount: Decimal; NetAmount: Decimal; FeeAmount: Decimal; PayerEmail: Text; PayerName: Text; PayerAddress: Text; Custom: Text; Note: Text; Details: Text);
    var
        MSPayPalTransaction: Record 1077;
    begin
        MSPayPalTransaction.SETRANGE("Account ID", AccountID);
        MSPayPalTransaction.SETRANGE("Transaction ID", TransactionID);
        IF NOT MSPayPalTransaction.FINDFIRST() THEN BEGIN
            SendTraceTag('00008GZ', PayPalTelemetryCategoryTok, VERBOSITY::Normal, InsertTransactionDetailsTxt, DataClassification::SystemMetadata);
            MSPayPalTransaction.INIT();
            MSPayPalTransaction."Account ID" := COPYSTR(AccountID, 1, MAXSTRLEN(MSPayPalTransaction."Account ID"));
            MSPayPalTransaction."Transaction ID" := COPYSTR(TransactionID, 1, MAXSTRLEN(MSPayPalTransaction."Transaction ID"));
            MSPayPalTransaction.INSERT();
        END ELSE
            SendTraceTag('00008H0', PayPalTelemetryCategoryTok, VERBOSITY::Normal, UpdateTransactionDetailsTxt, DataClassification::SystemMetadata);
        MSPayPalTransaction."Transaction Type" := COPYSTR(PayPalTransactionType, 1, MAXSTRLEN(MSPayPalTransaction."Transaction Type"));
        MSPayPalTransaction."Transaction Status" := COPYSTR(TransactionStatus, 1, MAXSTRLEN(MSPayPalTransaction."Transaction Status"));
        MSPayPalTransaction."Transaction Date" := TransactionDate;
        MSPayPalTransaction."Invoice No." := COPYSTR(InvoiceNo, 1, MAXSTRLEN(MSPayPalTransaction."Invoice No."));
        MSPayPalTransaction."Currency Code" := COPYSTR(CurrencyCode, 1, MAXSTRLEN(MSPayPalTransaction."Currency Code"));
        MSPayPalTransaction."Gross Amount" := GrossAmount;
        MSPayPalTransaction."Net Amount" := NetAmount;
        MSPayPalTransaction."Fee Amount" := FeeAmount;
        MSPayPalTransaction."Payer E-mail" := COPYSTR(PayerEmail, 1, MAXSTRLEN(MSPayPalTransaction."Payer E-mail"));
        MSPayPalTransaction."Payer Name" := COPYSTR(PayerName, 1, MAXSTRLEN(MSPayPalTransaction."Payer Name"));
        MSPayPalTransaction."Payer Address" := COPYSTR(PayerAddress, 1, MAXSTRLEN(MSPayPalTransaction."Payer Address"));
        MSPayPalTransaction.Note := COPYSTR(Note, 1, MAXSTRLEN(MSPayPalTransaction.Note));
        MSPayPalTransaction.Custom := COPYSTR(Custom, 1, MAXSTRLEN(MSPayPalTransaction.Custom));
        MSPayPalTransaction."Response Date" := GetUtcNow();
        MSPayPalTransaction.SetDetails(Details);
        MSPayPalTransaction.MODIFY();
    end;

    local procedure GetTransactionDetailsFromNotification(JsonString: Text; var AccountID: Text; var TransactionID: Text; var PayPalTransactiontype: Text; var TransactionDate: DateTime; var TransactionStatus: Text; var InvoiceNo: Text; var CurrencyCode: Text; var GrossAmount: Decimal; var FeeAmount: Decimal; var PayerEmail: Text; var PayerName: Text; var PayerAddress: Text; var Custom: Text);
    var
        JObject: JsonObject;
        TransactionDateStr: Text;
        PayerStreet: Text;
        PayerCity: Text;
        PayerZip: Text;
        PayerState: Text;
        PayerCountry: Text;
        GrossAmountStr: Text;
        FeeAmountStr: Text;
    begin
        SendTraceTag('00008H1', PayPalTelemetryCategoryTok, VERBOSITY::Normal, GetTransactionDetailsTxt, DataClassification::SystemMetadata);
        JObject.ReadFrom(JsonString);
        GetPropertyValueFromJObject(JObject, 'receiver_email', AccountID);
        AccountID := LOWERCASE(AccountID);
        GetPropertyValueFromJObject(JObject, 'txn_id', TransactionID);
        GetPropertyValueFromJObject(JObject, 'txn_type', PayPalTransactiontype);
        GetPropertyValueFromJObject(JObject, 'payment_date', TransactionDateStr);
        GetPropertyValueFromJObject(JObject, 'payment_status', TransactionStatus);
        GetPropertyValueFromJObject(JObject, 'invoice', InvoiceNo);
        GetPropertyValueFromJObject(JObject, 'mc_currency', CurrencyCode);
        GetPropertyValueFromJObject(JObject, 'mc_gross', GrossAmountStr);
        GetPropertyValueFromJObject(JObject, 'mc_fee', FeeAmountStr);
        GetPropertyValueFromJObject(JObject, 'custom', Custom);
        GetPropertyValueFromJObject(JObject, 'payer_email', PayerEmail);
        GetPropertyValueFromJObject(JObject, 'payer_business_name', PayerName);
        GetPropertyValueFromJObject(JObject, 'address_street', PayerStreet);
        GetPropertyValueFromJObject(JObject, 'address_city', PayerCity);
        GetPropertyValueFromJObject(JObject, 'address_zip', PayerZip);
        GetPropertyValueFromJObject(JObject, 'address_state', PayerState);
        GetPropertyValueFromJObject(JObject, 'address_country', PayerCountry);
        TransactionDate := GetPaymentDate(TransactionDateStr);
        IF NOT EVALUATE(GrossAmount, GrossAmountStr, 9) THEN
            SendTraceTag('00008H2', PayPalTelemetryCategoryTok, VERBOSITY::Warning, CannotParseGrossAmountTxt, DataClassification::SystemMetadata);
        IF NOT EVALUATE(FeeAmount, FeeAmountStr, 9) THEN
            SendTraceTag('00008H3', PayPalTelemetryCategoryTok, VERBOSITY::Warning, CannotParseFeeAmountTxt, DataClassification::SystemMetadata);
        PayerAddress := STRSUBSTNO('%1, %2 %3, %4, %5', PayerStreet, PayerCity, PayerZip, PayerState, PayerCountry);
    end;

    local procedure GetPropertyValueFromJObject(JObject: JsonObject; PropertyKey: Text; var PropertyValue: Text);
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
        PropertyValue := JValue.AsText();
    end;

    local procedure GetPaymentDate(DateTimeText: Text): DateTime;
    var
        TypeHelper: Codeunit "Type Helper";
        DateTimeVariant: Variant;
        AdjustedDateTimeText: Text;
    begin
        AdjustedDateTimeText := GetAdjustPaymentDateString(DateTimeText);
        DateTimeVariant := CurrentDateTime();
        if TypeHelper.Evaluate(DateTimeVariant, AdjustedDateTimeText, PaymentDateFormat1Txt, '') then
            exit(DateTimeVariant);

        if TypeHelper.Evaluate(DateTimeVariant, AdjustedDateTimeText, PaymentDateFormat2Txt, '') then
            exit(DateTimeVariant);

        if TypeHelper.Evaluate(DateTimeVariant, AdjustedDateTimeText, '', '') then
            exit(DateTimeVariant);

        SendTraceTag('00008H4', PayPalTelemetryCategoryTok, VERBOSITY::Warning, CannotParsePaymentDateTxt, DataClassification::SystemMetadata);
        exit(GetUtcNow());
    end;

    local procedure GetAdjustPaymentDateString(DateTimeText: Text): Text;
    var
        PreparedDateTimeText: Text;
    begin
        // PayPal sends payment date in one of 8 possible formats:
        // 'HH:mm:ss MMM dd yyyy PDT', 'HH:mm:ss MMM dd yyyy PST', 'HH:mm:ss MMM dd, yyyy PDT', 'HH:mm:ss MMM dd, yyyy PST',
        // 'HH:mm:ss dd MMM yyyy PDT', 'HH:mm:ss dd MMM yyyy PST', 'HH:mm:ss dd MMM, yyyy PDT', 'HH:mm:ss dd MMM, yyyy PST'.
        // The function returns date string in one of 2 formats: 'HH:mm:ss MMM dd yyyy zzz', 'HH:mm:ss dd MMM yyyy zzz'.
        PreparedDateTimeText := DateTimeText.Replace(PdtTimeZoneNameTxt, PdtTimeZoneValueTxt); // PDT -> -07:00
        PreparedDateTimeText := PreparedDateTimeText.Replace(PstTimeZoneNameTxt, PstTimeZoneValueTxt); // PST -> -08:00
        PreparedDateTimeText := PreparedDateTimeText.Replace(CommaTxt, '');
        EXIT(PreparedDateTimeText);
    end;

    procedure GetNotificationJsonString(var WebhookNotification: Record 2000000194): Text;
    var
        NotificationStream: InStream;
        NotificationString: Text;
    begin
        NotificationString := '';
        WebhookNotification.CALCFIELDS(Notification);
        IF WebhookNotification.Notification.HASVALUE() THEN BEGIN
            WebhookNotification.Notification.CREATEINSTREAM(NotificationStream);
            NotificationStream.READ(NotificationString);
        END;
        EXIT(NotificationString);
    end;

    local procedure GetUtcNow(): DateTime;
    var
        DateFilterCalc: Codeunit 358;
    begin
        EXIT(DateFilterCalc.ConvertToUtcDateTime(CURRENTDATETIME()));
    end;

    local procedure GetDefaultCurrencyCode(): Code[10];
    var
        GeneralLedgerSetup: Record 98;
        CurrencyCode: Code[10];
    begin
        GeneralLedgerSetup.GET();
        CurrencyCode := GeneralLedgerSetup.GetCurrencyCode(CurrencyCode);
        EXIT(CurrencyCode);
    end;

}

