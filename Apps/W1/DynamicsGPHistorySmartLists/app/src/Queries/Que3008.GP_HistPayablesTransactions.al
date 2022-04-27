query 3008 GPHistPayablesTrx
{
    QueryType = Normal;
    QueryCategory = 'Vendor List';
    Caption = 'Dynamics GP Payables Transactions';
    elements
    {
        dataitem(GP_PMHist; GPPMHist)
        {
            column(VCHRNMBR; VCHRNMBR)
            {
                Caption = 'Voucher Number';
            }
            column(VENDORID; VENDORID)
            {
                Caption = 'Vendor ID';
            }
            column(DOCTYPE; DOCTYPE)
            {
                Caption = 'Document Type';
            }
            column(DOCDATE; DOCDATE)
            {
                Caption = 'Document Date';
            }
            column(DOCNUMBR; DOCNUMBR)
            {
                Caption = 'Document Number';
            }
            column(DOCAMNT; DOCAMNT)
            {
                Caption = 'Document Amount';
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}