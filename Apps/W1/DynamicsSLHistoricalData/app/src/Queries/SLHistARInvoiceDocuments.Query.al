// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

using Microsoft.Sales.Customer;

query 42807 "SL Hist. ARInvoiceDocuments"
{
    QueryType = Normal;
    OrderBy = ascending(BatNbr);
    QueryCategory = 'Customer List';
    Caption = 'Dynamics SL AR Invoice Documents';
    elements
    {
        dataitem(SL_ARDocHist; "SL Hist. ARDoc")
        {
            DataItemTableFilter = Crtd_Prog = const('40690');

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
                Caption = 'Invoice Number';
            }
            column(OrdNbr; OrdNbr)
            {
                Caption = 'Sales Order Number';
            }
            column(CustId; CustId)
            {
                Caption = 'Customer Number';
            }
            dataitem(BCCustomer; Customer)
            {
                DataItemLink = "No." = SL_ARDocHist.CustID;
                SqlJoinType = LeftOuterJoin;
                column(CustName; Name)
                {
                    Caption = 'Customer Name';
                }
            }
            column(DocType; DocType)
            {
                Caption = 'Document Type';
                ColumnFilter = DocType = const('IN');
            }
            column(DocDesc; DocDesc)
            {
                Caption = 'Document Description';
            }
            column(OrigDocAmt; OrigDocAmt)
            {
                Caption = 'Original Document Amount';
            }
            column(DocBal; DocBal)
            {
                Caption = 'Document Balance';
            }
            column(DocDate; DocDate)
            {
                Caption = 'Document Date';
            }
            column(DueDate; DueDate)
            {
                Caption = 'Due Date';
            }
            column(SlsperId; SlsperId)
            {
                Caption = 'Salesperson ID';
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