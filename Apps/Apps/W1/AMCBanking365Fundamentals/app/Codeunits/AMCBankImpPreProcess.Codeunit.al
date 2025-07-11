// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.Reconciliation;
using System.IO;

codeunit 20127 "AMC Bank Imp.-Pre-Process"
{
    TableNo = "Bank Acc. Reconciliation Line";

    trigger OnRun()
    var
        DataExch: Record "Data Exch.";
        XMLImportAMCBankPrePostProc: Codeunit "AMC Bank PrePost Proc";
    begin
        DataExch.Get(Rec."Data Exch. Entry No.");
        XMLImportAMCBankPrePostProc.PreProcessFile(DataExch);
        XMLImportAMCBankPrePostProc.PreProcessBankAccount(DataExch, Rec."Bank Account No.");
    end;

    var
}

