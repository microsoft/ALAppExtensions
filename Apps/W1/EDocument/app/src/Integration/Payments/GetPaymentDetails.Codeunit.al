// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Payments;

using System.Utilities;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;

codeunit 6107 "Get Payment Details"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        this.EDocumentService.TestField(Code);
        this.IDocumentPaymentHandler.GetDetails(this.EDocument, this.EDocumentService, this.PaymentMetadata, this.PaymentContext);
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
    /// Sets the IDocumentPaymentHandler instance.
    /// </summary>
    /// <param name="PaymentHandler">IDocumentPaymentHandler implementation used for receiving payment details.</param>
    procedure SetInstance(PaymentHandler: Interface IDocumentPaymentHandler)
    begin
        this.IDocumentPaymentHandler := PaymentHandler;
    end;

    /// <summary>
    /// Sets the parameters for the payment information receiving.
    /// </summary>
    /// <param name="EDocument">Electronic document for which payment is received.</param>
    /// <param name="EDocumentService">Service for receiving payments.</param>
    /// <param name="PaymentMetadata">TempBlob which contains received payment information.</param>
    procedure SetParameters(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; PaymentMetadata: Codeunit "Temp Blob")
    begin
        this.EDocument.Copy(EDocument);
        this.EDocumentService.Copy(EDocumentService);
        this.PaymentMetadata := PaymentMetadata;
    end;

    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        PaymentMetadata: Codeunit "Temp Blob";
        PaymentContext: Codeunit PaymentContext;
        IDocumentPaymentHandler: Interface IDocumentPaymentHandler;
}
