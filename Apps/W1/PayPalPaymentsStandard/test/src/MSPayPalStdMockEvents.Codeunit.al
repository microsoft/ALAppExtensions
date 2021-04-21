codeunit 139503 "MS - PayPal Std Mock Events"
{
    // version Test,ERM,W1,AT,AU,BE,CA,CH,DE,DK,ES,FI,FR,GB,IS,IT,MX,NL,NO,NZ,SE,US

    EventSubscriberInstance = Manual;

    var
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryUtility: Codeunit "Library - Utility";
        PaymentTok: Label 'payment', Locked = true;
        OverpaymentTok: Label 'overpayment', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MS - PayPal Webhook Management", 'OnAfterPostPayPalPayment', '', false, false)]
    local procedure HandleOnAfterPostPayPalPayment(var TempPaymentRegistrationBuffer: Record 981 temporary; AmountReceived: Decimal);
    begin
        LibraryVariableStorage.Enqueue(PaymentTok);
        LibraryVariableStorage.Enqueue(TempPaymentRegistrationBuffer."Document No.");
        LibraryVariableStorage.Enqueue(AmountReceived);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MS - PayPal Webhook Management", 'OnAfterReceivePayPalOverpayment', '', false, false)]
    local procedure HandleOnAfterReceivePayPalOverpayment(var TempPaymentRegistrationBuffer: Record 981 temporary; AmountReceived: Decimal);
    begin
        LibraryVariableStorage.Enqueue(OverpaymentTok);
        LibraryVariableStorage.Enqueue(TempPaymentRegistrationBuffer."Document No.");
        LibraryVariableStorage.Enqueue(AmountReceived);
    end;

    procedure DequeueEvent(var EventType: Code[20]; var InvoiceNo: Code[20]; var AmountReceived: Decimal);
    begin
        EventType := COPYSTR(LibraryVariableStorage.DequeueText(), 1, 20);
        InvoiceNo := COPYSTR(LibraryVariableStorage.DequeueText(), 1, 20);
        AmountReceived := LibraryVariableStorage.DequeueDecimal();
    end;

    procedure AssertEmpty();
    begin
        LibraryVariableStorage.AssertEmpty();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Service Setup", 'OnRegisterPaymentServiceProviders', '', false, false)]
    local procedure RegisteDummyPaymentServiceProvider(var PaymentServiceSetup: Record 1060);
    begin
        CLEAR(PaymentServiceSetup);

        PaymentServiceSetup.Name := COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(20, 0),
            1, MAXSTRLEN(PaymentServiceSetup.Name));
        PaymentServiceSetup.AssignPrimaryKey(PaymentServiceSetup);
        PaymentServiceSetup.INSERT(TRUE);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MS - PayPal Webhook Management", 'OnBeforeRunPayPalNotificationBackgroundSession', '', false, false)]
    local procedure DisableRunInBackgroundOnBeforeRunPayPalNotificationBackgroundSession(var AllowBackgroundSessions: Boolean);
    begin
        // AL Test Framework does not allow starting background sessions.
        AllowBackgroundSessions := FALSE;
    end;

    [EventSubscriber(ObjectType::Page, Page::"MS - PayPal Standard Setup", 'OnBeforeShowPayPalNotification', '', false, false)]
    local procedure DisableShowPayPalNotification(var NotificationAllowed: Boolean);
    begin
        NotificationAllowed := FALSE;
    end;
}

