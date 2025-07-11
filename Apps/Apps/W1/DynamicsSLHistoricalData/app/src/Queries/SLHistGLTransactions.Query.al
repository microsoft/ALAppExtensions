// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

query 42815 "SL Hist. GLTransactions"
{
    QueryType = Normal;
    OrderBy = ascending(BatNbr);
    QueryCategory = 'Chart of Accounts';
    Caption = 'Dynamics SL General Ledger Transactions';
    elements
    {
        dataitem(SLGLTranHist; "SL Hist. GLTran")
        {
            column(CpnyID; CpnyID)
            {
                Caption = 'Company ID';
            }
            column(Acct; Acct)
            {
                Caption = 'Account';
            }
            column(Sub; Sub)
            {
                Caption = 'Sub Account';
            }
            column(BatNbr; BatNbr)
            {
                Caption = 'Batch Number';
            }
            column(FiscYr; FiscYr)
            {
                Caption = 'Fiscal Year';
            }
            column(RefNbr; RefNbr)
            {
                Caption = 'Reference Number';
            }
            column(JrnlType; JrnlType)
            {
                Caption = 'Journal Type';
            }
            column(LedgerID; LedgerID)
            {
                Caption = 'Ledger ID';
            }
            column(PerEnt; PerEnt)
            {
                Caption = 'Period Entered';
            }
            column(PerPost; PerPost)
            {
                Caption = 'Period Post';
            }
            column(CrAmt; CrAmt)
            {
                Caption = 'Credit Amount';
            }
            column(DrAmt; DrAmt)
            {
                Caption = 'Debit Amount';
            }
            column(BalanceType; BalanceType)
            {
                Caption = 'BalanceType';
            }
            column(Module; Module)
            {
                Caption = 'Module';
            }
            column(TranDesc; TranDesc)
            {
                Caption = 'Transaction Description';
            }
            column(TranDate; TranDate)
            {
                Caption = 'Transaction Date';
            }
            column(TranType; TranType)
            {
                Caption = 'Transaction Type';
            }
            column(Qty; Qty)
            {
                Caption = 'Qty';
            }
            column(ProjectID; ProjectID)
            {
                Caption = 'Project';
            }
            column(TaskID; TaskID)
            {
                Caption = 'Task';
            }
        }
    }

    trigger OnBeforeOpen()
    begin
        GlobalCompanyName := CopyStr(CompanyName(), 1, MaxStrLen(GlobalCompanyName));
        SetFilter(CpnyID, GlobalCompanyName);
    end;

    var
        GlobalCompanyName: Text[10];
}