// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Payments;

using System.Utilities;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Payments;
using Microsoft.eServices.EDocument.Integration.Interfaces;

codeunit 6122 "Payment Integration Management"
{
    internal procedure ReceivePayments(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; PaymentContext: Codeunit PaymentContext)
    var
        PaymentMetadata: Codeunit "Temp Blob";
        PaymentsMetadata: Codeunit "Temp Blob List";
        IDocumentPaymentHandler: Interface IDocumentPaymentHandler;
        Index: Integer;
    begin
        IDocumentPaymentHandler := EDocumentService."Payment Integration";
        this.RunReceivePayments(EDocument, EDocumentService, PaymentsMetadata, IDocumentPaymentHandler, PaymentContext);

        if PaymentsMetadata.IsEmpty() then
            exit;

        for Index := 1 to PaymentsMetadata.Count() do begin
            PaymentsMetadata.Get(Index, PaymentMetadata);
            this.ReceivePaymentDetails(EDocument, EDocumentService, PaymentMetadata, IDocumentPaymentHandler);
        end;
    end;

    internal procedure SendPayments(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; PaymentContext: Codeunit PaymentContext)
    var
        Payment: Record "E-Document Payment";
    begin
        Payment.SetRange("E-Document Entry No.", EDocument."Entry No");
        Payment.SetFilter(Status, '%1|%2', Payment.Status::Created, Payment.Status::"Sending Error");

        if not Payment.FindSet() then
            exit;

        repeat
            this.SendPayment(EDocument, EDocumentService, Payment);
        until Payment.Next() = 0;
    end;

    local procedure RunReceivePayments(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; Payments: Codeunit "Temp Blob List"; IDocumentPaymentHandler: Interface IDocumentPaymentHandler; PaymentContext: Codeunit PaymentContext)
    var
        ReceivePayments: Codeunit "Receive Payments";
    begin
        // Commit needed for "if codeunit run" pattern when catching errors.
        Commit();

        ReceivePayments.SetInstance(IDocumentPaymentHandler);
        ReceivePayments.SetService(EDocumentService);
        ReceivePayments.SetDocument(EDocument);
        ReceivePayments.SetContext(PaymentContext);
        ReceivePayments.SetPayments(Payments);
        if not ReceivePayments.Run() then
            this.EDocumentErrorHelper.LogErrorMessage(EDocument, Database::"E-Document Payment", EDocument.FieldNo("Paid Amount"), StrSubstNo(this.PaymentReceiveErr, GetLastErrorText()));
    end;

    local procedure ReceivePaymentDetails(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; PaymentMetadata: Codeunit "Temp Blob"; IDocumentPaymentHandler: Interface IDocumentPaymentHandler)
    var
        Payment: Record "E-Document Payment";
        PaymentContext: Codeunit PaymentContext;
    begin
        PaymentContext.SetPaymentStatus("Payment Status"::Received);

        this.RunGetPaymentDetails(EDocument, EDocumentService, PaymentMetadata, IDocumentPaymentHandler, PaymentContext);

        if (PaymentContext.GetAmount() = 0) or (PaymentContext.GetDate() = 0D) then
            exit;

        Payment.Init();
        Payment.Validate("E-Document Entry No.", EDocument."Entry No");
        Payment.Date := PaymentContext.GetDate();
        Payment.Validate(Amount, PaymentContext.GetAmount());
        Payment.Status := PaymentContext.GetPaymentStatus();
        Payment.Insert(true);
    end;

    local procedure RunGetPaymentDetails(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; PaymentMetadata: Codeunit "Temp Blob"; IDocumentPaymentHandler: Interface IDocumentPaymentHandler; PaymentContext: Codeunit PaymentContext): Boolean
    var
        GetPaymentDetails: Codeunit "Get Payment Details";
    begin
        // Commit needed for "if codeunit run" pattern when catching errors.
        Commit();

        GetPaymentDetails.SetInstance(IDocumentPaymentHandler);
        GetPaymentDetails.SetContext(PaymentContext);
        GetPaymentDetails.SetParameters(EDocument, EDocumentService, PaymentMetadata);
        if not GetPaymentDetails.Run() then
            this.EDocumentErrorHelper.LogErrorMessage(EDocument, Database::"E-Document Payment", EDocument.FieldNo("Paid Amount"), StrSubstNo(this.PaymentReceiveErr, GetLastErrorText()));
    end;

    local procedure SendPayment(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; Payment: Record "E-Document Payment")
    var
        PaymentContext: Codeunit PaymentContext;
    begin
        PaymentContext.SetPaymentStatus("Payment Status"::Sent);

        this.RunSendPayment(EDocument, EDocumentService, Payment, EDocumentService."Payment Integration", PaymentContext);

        Payment.Status := PaymentContext.GetPaymentStatus();
        Payment.Modify(false);
    end;

    local procedure RunSendPayment(EDocument: Record "E-Document"; EDocumentService: Record "E-Document Service"; Payment: Record "E-Document Payment"; IDocumentPaymentHandler: Interface IDocumentPaymentHandler; PaymentContext: Codeunit PaymentContext): Boolean
    var
        SendPayment: Codeunit "Send Payment";
    begin
        // Commit needed for "if codeunit run" pattern when catching errors.
        Commit();

        SendPayment.SetInstance(IDocumentPaymentHandler);
        SendPayment.SetDocumentAndService(EDocument, EDocumentService);
        SendPayment.SetContext(PaymentContext);

        if not SendPayment.Run() then
            this.EDocumentErrorHelper.LogErrorMessage(EDocument, Payment, EDocument.FieldNo("Paid Amount"), StrSubstNo(this.PaymentSendErr, GetLastErrorText()));
    end;

    var
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        PaymentSendErr: Label 'Sending payments for this document failed with error: %1', Comment = '%1 - error message';
        PaymentReceiveErr: Label 'Receiving payments for this document failed with error: %1', Comment = '%1 - error message';
}
