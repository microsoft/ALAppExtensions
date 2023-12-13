namespace Microsoft.DataMigration.GP.SmartLists;

using Microsoft.DataMigration.GP;
using Microsoft.Sales.Customer;

query 3006 GPOpenReceivablesTrx
{
    QueryType = Normal;
    QueryCategory = 'Customer List';
    Caption = 'Dynamics GP Open Receivables Transactions';
    elements
    {
        dataitem(GP_RMOpen; GPRMOpen)
        {
            column(CUSTNMBR; CUSTNMBR)
            {
                Caption = 'Customer Number';
            }
            dataitem(Customer; Customer)
            {
                DataItemLink = "No." = GP_RMOpen.CUSTNMBR;
                SqlJoinType = InnerJoin;
                column(Name; Name)
                {
                    Caption = 'Customer Name';
                }
            }
            column(DOCNUMBR; DOCNUMBR)
            {
                Caption = 'Document Number';
            }
            column(RMDTYPAL; RMDTYPAL)
            {
                Caption = 'Document Type';
            }
            column(DOCDATE; DOCDATE)
            {
                Caption = 'Document Date';
            }
            column(SLSAMNT; SLSAMNT)
            {
                Caption = 'Sales Amount';
            }
            column(TRXDSCRN; TRXDSCRN)
            {
                Caption = 'Description';
            }
            column(CHEKNMBR; CHEKNMBR)
            {
                Caption = 'Check Number';
            }
            column(DUEDATE; DUEDATE)
            {
                Caption = 'Due Date';
            }
            column(ORTRXAMT; ORTRXAMT)
            {
                Caption = 'Original Transaction Amount';
            }
            column(CURTRXAM; CURTRXAM)
            {
                Caption = 'Current Transaction Amount';
            }
            column(FRTAMNT; FRTAMNT)
            {
                Caption = 'Freight Amount';
            }
            column(MISCAMNT; MISCAMNT)
            {
                Caption = 'Misc Amount';
            }
            column(TAXAMNT; TAXAMNT)
            {
                Caption = 'Tax Amount';
            }
            column(COMDLRAM; COMDLRAM)
            {
                Caption = 'Commission Amount';
            }
            column(CASHAMNT; CASHAMNT)
            {
                Caption = 'Cash Amount';
            }
            column(DISTKNAM; DISTKNAM)
            {
                Caption = 'Terms Disc Taken';
            }
            column(DISCDATE; DISCDATE)
            {
                Caption = 'Discount Date';
            }
            column(SLPRSNID; SLPRSNID)
            {
                Caption = 'Salesperson';
            }
            column(SLSTERCD; SLSTERCD)
            {
                Caption = 'Sales Territory';
            }
            column(DINVPDOF; DINVPDOF)
            {
                Caption = 'Date Invoice Paid Off';
            }
            column(PYMTRMID; PYMTRMID)
            {
                Caption = 'Payment Terms';
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}