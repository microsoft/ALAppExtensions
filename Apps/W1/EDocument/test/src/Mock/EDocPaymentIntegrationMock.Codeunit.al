codeunit 139506 "E-Doc Payment Integration Mock" implements IDocumentPaymentHandler
{
    Access = Internal;

    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; PaymentContext: Codeunit PaymentContext)
    begin
        OnSendPayment(EDocument, EDocumentService, PaymentContext);
    end;

    procedure Receive(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var PaymentsMetadata: Codeunit "Temp Blob List"; PaymentContext: Codeunit PaymentContext)
    begin
        OnReceivePayment(EDocument, EDocumentService, PaymentsMetadata, PaymentContext);
    end;

    procedure GetDetails(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; PaymentMetadata: Codeunit "Temp Blob"; PaymentContext: Codeunit PaymentContext)
    begin
        OnGetPaymentDetails(EDocument, EDocumentService, PaymentMetadata, PaymentContext);
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendPayment(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; PaymentContext: Codeunit PaymentContext)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnReceivePayment(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var PaymentsMetadata: Codeunit "Temp Blob List"; PaymentContext: Codeunit PaymentContext)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetPaymentDetails(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; PaymentMetadata: Codeunit "Temp Blob"; PaymentContext: Codeunit PaymentContext)
    begin
    end;
}
