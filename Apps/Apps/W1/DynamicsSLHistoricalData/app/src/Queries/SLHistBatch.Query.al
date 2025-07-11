// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

query 42816 "SL Hist. Batch"
{
    QueryType = Normal;
    OrderBy = ascending(BatNbr);
    QueryCategory = 'Chart of Accounts';
    Caption = 'Dynamics SL Batches';
    elements
    {
        dataitem(SLBatchHist; "SL Hist. Batch")
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
            column(JrnlType; JrnlType)
            {
                Caption = 'Journal Type';
            }
            column(LedgerID; LedgerID)
            {
                Caption = 'Ledger ID';
            }
            column(Descr; Descr)
            {
                Caption = 'Description';
            }
            column(BalanceType; BalanceType)
            {
                Caption = 'BalanceType';
            }
            column(Module; Module)
            {
                Caption = 'Module';
            }
            column(PerEnt; PerEnt)
            {
                Caption = 'Period Entered';
            }
            column(PerPost; PerPost)
            {
                Caption = 'Period Post';
            }
            column(Status; Status)
            {
                Caption = 'Status';
            }
            column(CrTot; CrTot)
            {
                Caption = 'Credit Total';
            }
            column(DrTot; DrTot)
            {
                Caption = 'Debit Total';
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