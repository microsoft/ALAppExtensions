#if not CLEAN23
codeunit 139506 "MS - WorldPay Std Mock Events"
{
    // version Test,ERM,W1,AT,AU,BE,CA,CH,DE,DK,ES,FI,FR,GB,IS,IT,MX,NL,NO,NZ,SE,US

    EventSubscriberInstance = Manual;
    ObsoleteReason = 'WorldPay Payments Standard extension is discontinued';
    ObsoleteState = Pending;
    ObsoleteTag = '23.0';

    var
        LibraryUtility: Codeunit "Library - Utility";

    [EventSubscriber(ObjectType::Table, Database::"Payment Service Setup", 'OnRegisterPaymentServiceProviders', '', false, false)]
    local procedure RegisterDummyPaymentServiceProvider(var PaymentServiceSetup: Record 1060);
    begin
        CLEAR(PaymentServiceSetup);

        PaymentServiceSetup.Name := COPYSTR(LibraryUtility.GenerateRandomAlphabeticText(20, 0),
            1, MAXSTRLEN(PaymentServiceSetup.Name));
        PaymentServiceSetup.AssignPrimaryKey(PaymentServiceSetup);
        PaymentServiceSetup.INSERT(TRUE);
    end;
}
#endif
