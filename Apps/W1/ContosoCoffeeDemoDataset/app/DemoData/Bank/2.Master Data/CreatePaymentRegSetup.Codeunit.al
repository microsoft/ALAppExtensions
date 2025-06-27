// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Finance;

codeunit 5422 "Create Payment Reg. Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoBank: Codeunit "Contoso Bank";
        CreateGenJournalTemplate: Codeunit "Create Gen. Journal Template";
        CreateBankJnlBatch: Codeunit "Create Bank Jnl. Batches";
        CreateBankAccount: Codeunit "Create Bank Account";
    begin
        ContosoBank.InsertPaymentRegistrationSetup('', CreateGenJournalTemplate.PaymentJournal(), CreateBankJnlBatch.PaymentReconciliation(), 2, CreateBankAccount.Checking(), true, true);
    end;
}
