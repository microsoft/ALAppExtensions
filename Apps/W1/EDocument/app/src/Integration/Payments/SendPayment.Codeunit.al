// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Payments;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;

codeunit 6123 "Send Payment"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        this.EDocumentService.TestField(Code);
        this.IPaymentHandler.Send(this.EDocument, this.EDocumentService, this.PaymentContext);
    end;

    /// <summary>
    /// Sets the IDocumentPaymentHandler instance.
    /// </summary>
    /// <param name="PaymentHandler">IDocumentPaymentHandler implementation used for sending payments.</param>
    procedure SetInstance(PaymentHandler: Interface IDocumentPaymentHandler)
    begin
        this.IPaymentHandler := PaymentHandler;
    end;

    /// <summary>
    /// Sets the global variable PaymentContext.
    /// </summary>
    /// <param name="PaymentContext">Payment context codeunit.</param>
    procedure SetContext(PaymentContext: Codeunit PaymentContext)
    begin
        this.PaymentContext := PaymentContext;
    end;

    /// <summary>
    /// Sets the parameters for the payment handler.
    /// </summary>
    /// <param name="EDocument">Electronic document for which payments are sent.</param>
    /// <param name="EDocumentService">Service for sending payments.</param>
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
