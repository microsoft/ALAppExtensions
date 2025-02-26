codeunit 139519 "E-Doc. Payment Impl. State"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc Payment Integration Mock", 'OnSendPayment', '', false, false)]
    local procedure OnSendPayment(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; PaymentContext: Codeunit PaymentContext)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc Payment Integration Mock", 'OnReceivePayment', '', false, false)]
    local procedure OnReceivePayment(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var PaymentsMetadata: Codeunit "Temp Blob List"; PaymentContext: Codeunit PaymentContext)
    var
        TempBlob: Codeunit "Temp Blob";
        PaymentText: Text;
        OutStream: OutStream;
    begin
        PaymentText := '{"PaymentId": "123456"}';
        TempBlob.CreateOutStream(OutStream);
        OutStream.Write(PaymentText);
        PaymentsMetadata.Add(TempBlob);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc Payment Integration Mock", 'OnGetPaymentDetails', '', false, false)]
    local procedure OnGetPaymentDetails(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; PaymentMetadata: Codeunit "Temp Blob"; PaymentContext: Codeunit PaymentContext)
    begin
        PaymentContext.SetPaymentInformation(Today(), 1);
    end;
}
