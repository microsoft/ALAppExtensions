// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Payments;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Payments;

codeunit 6116 "Send Payment"
{
    trigger OnRun()
    begin
        this.EDocumentService.TestField(Code);
        this.IPaymentHandler.Send(this.EDocument, this.EDocumentService, this.PaymentContext);
    end;

    procedure SetInstance(PaymentHandler: Interface IDocumentPaymentHandler)
    begin
        this.IPaymentHandler := PaymentHandler;
    end;

    procedure SetContext(PaymentContext: Codeunit PaymentContext)
    begin
        this.PaymentContext := PaymentContext;
    end;

    procedure SetDocumentAndService(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service")
    begin
        this.EDocument.Copy(EDocument);
        this.EDocumentService.Copy(EDocumentService);
    end;

    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        PaymentContext: Codeunit PaymentContext;
        IPaymentHandler: Interface IDocumentPaymentHandler;
}
