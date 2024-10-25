namespace Microsoft.DataMigration.SL.HistoricalData;

using Microsoft.Sales.Customer;

query 42802 "SL Hist. OpenARDocuments"
{
    QueryType = Normal;
    OrderBy = ascending(BatNbr);
    QueryCategory = 'Customer List';
    Caption = 'Dynamics SL Open Accounts Receivable Documents';
    elements
    {
        dataitem(SL_ARDocHist; "SL Hist. ARDoc")
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
            column(CustId; CustId)
            {
                Caption = 'Customer Number';
            }
            dataitem(BCCustomer; Customer)
            {
                DataItemLink = "No." = SL_ARDocHist.CustId;
                SqlJoinType = LeftOuterJoin;
                column(Name; Name)
                {
                    Caption = 'Customer Name';
                }
            }
            column(OrigDocAmt; OrigDocAmt)
            {
                Caption = 'Original Document Amount';
            }
            column(DocBal; DocBal)
            {
                Caption = 'Document Balance';
                ColumnFilter = DocBal = filter(<> 0);
            }
            column(DocType; DocType)
            {
                Caption = 'Document Type';
            }
            column(DocDesc; DocDesc)
            {
                Caption = 'Document Description';
            }
            column(DocDate; DocDate)
            {
                Caption = 'Document Date';
            }
        }
    }

    trigger OnBeforeOpen()
    begin
        CpnyName := CompanyName();
        SetFilter(CpnyID, CpnyName);
    end;

    var
        CpnyName: Text[10];
}