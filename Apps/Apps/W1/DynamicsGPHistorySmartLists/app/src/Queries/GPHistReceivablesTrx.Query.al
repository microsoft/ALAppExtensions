namespace Microsoft.DataMigration.GP.SmartLists;

using Microsoft.DataMigration.GP;
using Microsoft.Sales.Customer;

query 3005 GPHistReceivablesTrx
{
    QueryType = Normal;
    QueryCategory = 'Customer List';
    Caption = 'Dynamics GP Historical Receivables Transactions';
    elements
    {
        dataitem(GP_RMHist; GPRMHist)
        {
            column(CUSTNMBR; CUSTNMBR)
            {
                Caption = 'Customer Number';
            }
            dataitem(Customer; Customer)
            {
                DataItemLink = "No." = GP_RMHist.CUSTNMBR;
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
            column(CASHAMNT; CASHAMNT)
            {
                Caption = 'Cash Amount';
            }
            column(ORTRXAMT; ORTRXAMT)
            {
                Caption = 'Original Transaction Amount';
            }
            column(COMDLRAM; COMDLRAM)
            {
                Caption = 'Commission Amount';
            }
            column(DINVPDOF; DINVPDOF)
            {
                Caption = 'Date Invoice Paid Off';
            }
            column(DISTKNAM; DISTKNAM)
            {
                Caption = 'Terms Disc Taken';
            }
            column(SLPRSNID; SLPRSNID)
            {
                Caption = 'Salesperson';
            }
            column(SLSTERCD; SLSTERCD)
            {
                Caption = 'Sales Territory';
            }
            column(PYMTRMID; PYMTRMID)
            {
                Caption = 'Payment Terms';
            }
        }
    }
}