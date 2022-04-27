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
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}