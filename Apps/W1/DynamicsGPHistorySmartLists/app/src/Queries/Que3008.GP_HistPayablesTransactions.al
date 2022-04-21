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
            column(TRXDSCRN; TRXDSCRN)
            {
                Caption = 'Description';
            }
            column(TRDISAMT; TRDISAMT)
            {
                Caption = 'Trade Discount';
            }
            column(MSCCHAMT; MSCCHAMT)
            {
                Caption = 'Misc Amount';
            }
            column(FRTAMNT; FRTAMNT)
            {
                Caption = 'Freight Amount';
            }
            column(TAXAMNT; TAXAMNT)
            {
                Caption = 'Tax Amount';
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