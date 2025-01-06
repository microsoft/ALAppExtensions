// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Payments;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Interfaces;
using Microsoft.eServices.EDocument.Payments;
using System.Utilities;

/// <summary>
/// This codeunit is used to implement the "Document Payment Handler" interface. It is used to provide a default implementation for the "Action Invoker" interface.
/// </summary>
codeunit 6105 "Empty Payment Handler" implements IDocumentPaymentHandler
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; PaymentContext: Codeunit PaymentContext)
    begin
    end;

    procedure Receive(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var PaymentsMetadata: Codeunit "Temp Blob List"; PaymentContext: Codeunit PaymentContext)
    begin
    end;

    procedure GetDetails(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; PaymentMetadata: Codeunit "Temp Blob"; PaymentContext: Codeunit PaymentContext)
    begin
    end;

}