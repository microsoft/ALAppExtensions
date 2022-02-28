#if not CLEAN20
codeunit 139583 "MS - Wallet Mock Events"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'MS Wallet have been deprecated';
    ObsoleteTag = '20.0';
    // version Test,ERM,W1,AT,AU,BE,CA,CH,DE,DK,ES,FI,FR,GB,IS,IT,MX,NL,NO,NZ,SE,US

    EventSubscriberInstance = Manual;

    trigger OnRun();
    begin
    end;

    var
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryUtility: Codeunit "Library - Utility";
        PaymentTok: Label 'payment', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MS - Wallet Webhook Management", 'OnAfterPostWalletPayment', '', false, false)]
    procedure HandleOnAfterPostWalletPayment(var TempPaymentRegistrationBuffer: Record 981 temporary; AmountReceived: Decimal);
    begin
        LibraryVariableStorage.Enqueue(PaymentTok);
        LibraryVariableStorage.Enqueue(TempPaymentRegistrationBuffer."Document No.");
        LibraryVariableStorage.Enqueue(AmountReceived);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Payment Service Setup", 'OnRegisterPaymentServiceProviders', '', false, false)]
    procedure RegisteDummyPaymentServiceProvider(var PaymentServiceSetup: Record 1060);
    begin
        CLEAR(PaymentServiceSetup);

        PaymentServiceSetup.Name := COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(20, 0),
            1, MAXSTRLEN(PaymentServiceSetup.Name));
        PaymentServiceSetup.AssignPrimaryKey(PaymentServiceSetup);
        PaymentServiceSetup.INSERT(TRUE);
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
}
#endif