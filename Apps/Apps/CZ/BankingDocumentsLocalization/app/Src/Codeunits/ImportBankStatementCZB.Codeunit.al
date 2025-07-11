// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.Reconciliation;

codeunit 31399 "Import Bank Statement CZB"
{
    TableNo = "Bank Acc. Reconciliation";

    trigger OnRun()
    begin
        Rec.ImportBankStatement();
    end;
}
