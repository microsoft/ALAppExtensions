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
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}