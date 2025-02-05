// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

using Microsoft.Purchases.Vendor;

query 42803 "SL Hist. APDocuments"
{
    QueryType = Normal;
    OrderBy = ascending(BatNbr);
    QueryCategory = 'Vendor List';
    Caption = 'Dynamics SL Accounts Payable Documents';
    elements
    {
        dataitem(SL_APDocHist; "SL Hist. APDoc")
        {
            column(CpnyID; CpnyID)
            {
                Caption = 'Company ID';
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
                Caption = 'Vendor ID';
            }
            dataitem(BCVendor; Vendor)
            {
                DataItemLink = "No." = SL_APDocHist.VendId;
                SqlJoinType = LeftOuterJoin;
                column(VendName; Name)
                {
                    Caption = 'Vendor Name';
                }
            }
            column(DocType; DocType)
            {
                Caption = 'Document Type';
                ColumnFilter = DocType = filter(<> 'VT');
            }
            column(DocDate; DocDate)
            {
                Caption = 'Document Date';
            }
            column(PONbr; PONbr)
            {
                Caption = 'PO Number';
            }
            column(InvcNbr; InvcNbr)
            {
                Caption = 'Invoice Number';
            }
            column(InvcDate; InvcDate)
            {
                Caption = 'Invoice Date';
            }
            column(DiscDate; DiscDate)
            {
                Caption = 'Discount Date';
            }
            column(DueDate; DueDate)
            {
                Caption = 'Due Date';
            }
            column(PayDate; PayDate)
            {
                Caption = 'Pay Date';
            }
            column(OrigDocAmt; OrigDocAmt)
            {
                Caption = 'Original Document Amount';
            }
            column(DocBal; DocBal)
            {
                Caption = 'Document Balance';
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