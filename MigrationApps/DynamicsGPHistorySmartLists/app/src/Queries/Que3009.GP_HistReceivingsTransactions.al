query 3009 GPHistReceivingsTrx
{
    QueryType = Normal;
    QueryCategory = 'Vendor List';
    Caption = 'Dynamics GP Receivings Transactions';
    elements
    {
        dataitem(GP_POPReceiptHist; GPPOPReceiptHist)
        {
            column(POPRCTNM; POPRCTNM)
            {
                Caption = 'Receipt Number';
            }
            column(POPTYPE; POPTYPE)
            {
                Caption = 'Document Type';
            }
            column(receiptdate; receiptdate)
            {
                Caption = 'Receipt Date';
            }
            column(VENDORID; VENDORID)
            {
                Caption = 'Vendor ID';
            }
            column(VENDNAME; VENDNAME)
            {
                Caption = 'Vendor Name';
            }
            column(SUBTOTAL; SUBTOTAL)
            {
                Caption = 'Subtotal';
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}