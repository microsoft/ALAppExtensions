// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Interfaces;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Integration.Payments;
using System.Utilities;

/// <summary>
/// Interface for sending and receiving payment information for E-Documents using E-Document service
/// </summary>
interface IDocumentPaymentHandler
{
    procedure Send(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; PaymentContext: Codeunit PaymentContext)

    procedure Receive(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var PaymentsMetadata: Codeunit "Temp Blob List"; PaymentContext: Codeunit PaymentContext)

    procedure GetDetails(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; PaymentMetadata: Codeunit "Temp Blob"; PaymentContext: Codeunit PaymentContext)
}
