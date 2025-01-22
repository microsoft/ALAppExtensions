// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Payments;

using System.Utilities;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;

codeunit 6106 "Receive Payments"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        this.EDocumentService.TestField(Code);
        this.IDocumentPaymentHandler.Receive(this.EDocument, this.EDocumentService, this.PaymentsMetadata, this.PaymentContext);
    end;

    /// <summary>
    /// Sets the IDocumentPaymentHandler instance.
    /// </summary>
    /// <param name="PaymentHandler">IDocumentPaymentHandler implementation used for receiving payments.</param>
    procedure SetInstance(PaymentHandler: Interface IDocumentPaymentHandler)
    begin
        this.IDocumentPaymentHandler := PaymentHandler;
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
    /// Sets the received payments to Temp Blob List.
    /// </summary>
    /// <param name="PaymentsMetadata">Temp Blob List to save received payments.</param>
    procedure SetPayments(PaymentsMetadata: Codeunit "Temp Blob List")
    begin
        this.PaymentsMetadata := PaymentsMetadata
    end;

    /// <summary>
    /// Sets the E-Document Service used for receiving payments.
    /// </summary>
    /// <param name="EDocumentService">Service for receiving payments.</param>
    procedure SetService(var EDocumentService: Record "E-Document Service")
    begin
        this.EDocumentService.Copy(EDocumentService);
    end;

    /// <summary>
    /// Sets the E-Document for which payments are received.
    /// </summary>
    /// <param name="EDocument">E-Document for which payments are received.</param>
    procedure SetDocument(var EDocument: Record "E-Document")
    begin
        this.EDocument.Copy(EDocument);
    end;

    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        PaymentsMetadata: Codeunit "Temp Blob List";
        PaymentContext: Codeunit PaymentContext;
        IDocumentPaymentHandler: Interface IDocumentPaymentHandler;
}
