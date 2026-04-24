#if not CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

#pragma warning disable AL0432
reportextension 10858 "Archive Payment Slips" extends "Archive Payment Slips"
#pragma warning restore AL0432
{
    trigger OnPreReport()
    var
        PaymentFeature: Codeunit "Payment Management Feature FR";
    begin
        if PaymentFeature.IsEnabled() then
            Error(UseArchivePaymentJournalsFRReportErr);
    end;

    var
        UseArchivePaymentJournalsFRReportErr: Label 'Use Payment Management FR app instead';
}
#endif