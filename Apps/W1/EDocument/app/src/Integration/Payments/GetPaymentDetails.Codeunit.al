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

    procedure SetContext(PaymentContext: Codeunit PaymentContext)
    begin
        this.PaymentContext := PaymentContext;
    end;

    procedure SetInstance(PaymentHandler: Interface IDocumentPaymentHandler)
    begin
        this.IDocumentPaymentHandler := PaymentHandler;
    end;

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
