// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Payments;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;
using System.Utilities;

/// <summary>
/// This codeunit is used to provide a default implementation for the "Document Payment Handler" interface.
/// </summary>
codeunit 6121 "Empty Payment Handler" implements IDocumentPaymentHandler
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; PaymentContext: Codeunit PaymentContext)
    begin
        // This method serves as a placeholder implementation for the IDocumentPaymentHandler interface.
    end;

    procedure Receive(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var PaymentsMetadata: Codeunit "Temp Blob List"; PaymentContext: Codeunit PaymentContext)
    begin
        // This method serves as a placeholder implementation for the IDocumentPaymentHandler interface.
    end;

    procedure GetDetails(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; PaymentMetadata: Codeunit "Temp Blob"; PaymentContext: Codeunit PaymentContext)
    begin
        // This method serves as a placeholder implementation for the IDocumentPaymentHandler interface.
    end;
}