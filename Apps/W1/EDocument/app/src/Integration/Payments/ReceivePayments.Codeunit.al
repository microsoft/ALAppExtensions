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
        EDocumentService.TestField(Code);
        IDocumentPaymentHandler.Receive(this.EDocument, this.EDocumentService, this.PaymentsMetadata, this.PaymentContext);
    end;

    /// <summary>
    /// Sets the IPaymentHandler instance.
    ///</summary>
    procedure SetInstance(PaymentHandler: Interface IDocumentPaymentHandler)
    begin
        this.IDocumentPaymentHandler := PaymentHandler;
    end;

    /// <summary>
    /// Sets the global variable PaymentContext.
    ///</summary>
    procedure SetContext(PaymentContext: Codeunit PaymentContext)
    begin
        this.PaymentContext := PaymentContext;
    end;

    /// <summary>
    /// Sets the received payments to Temp Blob List.
    ///</summary>
    procedure SetPayments(PaymentsMetadata: Codeunit "Temp Blob List")
    begin
        this.PaymentsMetadata := PaymentsMetadata
    end;

    /// <summary>
    /// Sets the E-Document Service used for receiving payments.
    ///</summary>
    procedure SetService(var EDocumentService: Record "E-Document Service")
    begin
        this.EDocumentService.Copy(EDocumentService);
    end;

    /// <summary>
    /// Sets the E-Document for which payments are received.
    ///</summary>
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
