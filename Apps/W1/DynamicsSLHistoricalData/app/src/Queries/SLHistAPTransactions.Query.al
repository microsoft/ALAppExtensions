// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

using Microsoft.Purchases.Vendor;

query 42814 "SL Hist. APTransactions"
{
    QueryType = Normal;
    OrderBy = ascending(BatNbr);
    QueryCategory = 'Vendor List';
    Caption = 'Dynamics SL Accounts Payable Transactions';
    elements
    {
        dataitem(SLAPTranHist; "SL Hist. APTran")
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
            column(RefNbr; RefNbr)
            {
                Caption = 'Reference Number';
            }
            column(VendId; VendId)
            {
                Caption = 'Vendor Number';
            }
            dataitem(BCVendor; Vendor)
            {
                DataItemLink = "No." = SLAPTranHist.VendId;
                SqlJoinType = LeftOuterJoin;
                column(Name; Name)
                {
                    Caption = 'Vendor Name';
                }
            }
            column(TranAmt; TranAmt)
            {
                Caption = 'Transaction Amount';
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
            column(DrCr; DrCr)
            {
                Caption = 'Debit/Credit';
            }
            column(Qty; Qty)
            {
                Caption = 'Qty';
            }
            column(UnitPrice; UnitPrice)
            {
                Caption = 'Unit Price';
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
