// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

query 47001 "SL AcctHist Acitve Accounts"
{
    Caption = 'AcctHist Acitve Accounts';
    QueryType = Normal;

    elements
    {
        dataitem(SLAcctHist; "SL AcctHist")
        {
            column(Acct; Acct)
            {
            }
            column(FiscYr; FiscYr)
            {
            }
            column(PtdBal00; PtdBal00)
            {
            }
            column(PtdBal01; PtdBal01)
            {
            }
            column(PtdBal02; PtdBal02)
            {
            }
            column(PtdBal03; PtdBal03)
            {
            }
            column(PtdBal04; PtdBal04)
            {
            }
            column(PtdBal05; PtdBal05)
            {
            }
            column(PtdBal06; PtdBal06)
            {
            }
            column(PtdBal07; PtdBal07)
            {
            }
            column(PtdBal08; PtdBal08)
            {
            }
            column(PtdBal09; PtdBal09)
            {
            }
            column(PtdBal10; PtdBal10)
            {
            }
            column(PtdBal11; PtdBal11)
            {
            }
            column(PtdBal12; PtdBal12)
            {
            }
            column(Sub; Sub)
            {
            }
            column(CpnyID; CpnyID)
            {
            }
            column(LedgerID; LedgerID)
            {
            }
            dataitem(SLAccount; "SL Account")
            {
                DataItemLink = Acct = SLAcctHist.Acct;
                SqlJoinType = InnerJoin;
                column(Active; Active)
                {
                }
                column(AcctType; AcctType)
                {
                }
            }
        }
    }

    trigger OnBeforeOpen()
    begin
    end;
}
