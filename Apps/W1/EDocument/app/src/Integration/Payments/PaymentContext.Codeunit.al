// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Integration.Payments;

using Microsoft.eServices.EDocument.Integration;
using Microsoft.eServices.EDocument.Payments;

codeunit 6104 PaymentContext
{
    /// <summary>
    /// Get the Http Message State codeunit.
    /// </summary>
    procedure Http(): Codeunit "Http Message State"
    begin
        exit(this.HttpMessageState);
    end;

    /// <summary>
    /// Retrieves the payment date.
    /// </summary>
    procedure GetDate(): Date
    begin
        exit(this.Date);
    end;

    /// <summary>
    /// Retrieves the payment amount.
    /// </summary>
    procedure GetAmount(): Decimal
    begin
        exit(this.Amount);
    end;

    /// <summary>
    /// Sets the payment date and amount.
    /// </summary>
    procedure SetPaymentInformation(Date: Date; Amount: Decimal)
    begin
        this.Date := Date;
        this.Amount := Amount;
    end;

    /// <summary>
    /// Retrieves the payment status.
    /// </summary>
    procedure GetPaymentStatus(): Enum "Payment Status"
    begin
        exit(this.PaymentStatus);
    end;

    /// <summary>
    /// Sets the payment status.
    /// </summary>
    procedure SetPaymentStatus(NewPaymentStatus: Enum "Payment Status")
    begin
        this.PaymentStatus := NewPaymentStatus;
    end;

    var
        HttpMessageState: Codeunit "Http Message State";
        PaymentStatus: Enum "Payment Status";
        Date: Date;
        Amount: Decimal;

}