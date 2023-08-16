codeunit 692 "Paym. Prac. Cust. Generator" implements PaymentPracticeDataGenerator
{
    Access = Internal;

    procedure GenerateData(var PaymentPracticeData: Record "Payment Practice Data"; PaymentPracticeHeader: Record "Payment Practice Header")
    var
        PaymentPracticeBuilders: Codeunit "Payment Practice Builders";
    begin
        PaymentPracticeBuilders.BuildPaymentPracticeDataForCustomer(PaymentPracticeData, PaymentPracticeHeader);
    end;
}