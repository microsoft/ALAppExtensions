#if not CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.GeneralLedger.Reports;

#pragma warning disable AL0432
reportextension 10859 "GL/Cust. Ledger Reconciliation" extends "GL/Cust. Ledger Reconciliation"
#pragma warning restore AL0432
{
    trigger OnPreReport()
    var
        PaymentFeature: Codeunit "Payment Management Feature FR";
    begin
        if PaymentFeature.IsEnabled() then
            Error(UseGLCustLedgerReconciliationFRReportErr);
    end;

    var
        UseGLCustLedgerReconciliationFRReportErr: Label 'Use Payment Management FR app instead';
}
#endif