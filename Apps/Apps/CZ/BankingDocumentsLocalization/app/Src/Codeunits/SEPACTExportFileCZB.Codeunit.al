// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.DirectDebit;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Journal;
using System.IO;

codeunit 31232 "SEPA CT-Export File CZB"
{
    TableNo = "Gen. Journal Line";

    trigger OnRun()
    var
        BankAccount: Record "Bank Account";
        ExpUserFeedbackGenJnl: Codeunit "Exp. User Feedback Gen. Jnl.";
        SEPACTExportFile: Codeunit "SEPA CT-Export File";
    begin
        Rec.LockTable();
        BankAccount.Get(Rec."Bal. Account No.");
        if SEPACTExportFile.Export(Rec, XMLPortID) then
            ExpUserFeedbackGenJnl.SetExportFlagOnGenJnlLine(Rec);
    end;

    var
        XMLPortID: Integer;

    procedure SetXMLPortID(NewXMLPortID: Integer)
    begin
        XMLPortID := NewXMLPortID;
    end;
}