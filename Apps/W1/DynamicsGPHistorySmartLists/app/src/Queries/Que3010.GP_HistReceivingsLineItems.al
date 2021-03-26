query 3010 GPHistReceivingsLineItems
{
    QueryType = Normal;
    QueryCategory = 'Vendor List';
    Caption = 'Dynamics GP Receivings Line Items';
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
            column(VENDORID; VENDORID)
            {
                Caption = 'Vendor ID';
            }
            column(VENDNAME; VENDNAME)
            {
                Caption = 'Vendor Name';
            }
            dataitem(GP_POPReceiptLineHist; GPPOPReceiptLineHist)
            {
                DataItemLink = POPRCTNM = GP_POPReceiptHist.POPRCTNM;
                SqlJoinType = InnerJoin;
                column(ITEMNMBR; ITEMNMBR)
                {
                    Caption = 'Item Number';
                }
                column(ITEMDESC; ITEMDESC)
                {
                    Caption = 'Item Description';
                }
                column(UNITCOST; UNITCOST)
                {
                    Caption = 'Unit Cost';
                }
                column(EXTDCOST; EXTDCOST)
                {
                    Caption = 'Extended Cost';
                }
                dataitem(GP_POPReceiptApply; GPPOPReceiptApply)
                {
                    DataItemLink = POPRCTNM = GP_POPReceiptLineHist.POPRCTNM,
                                RCPTLNNM = GP_POPReceiptLineHist.RCPTLNNM;
                    SqlJoinType = InnerJoin;
                    column(QTYSHPPD; QTYSHPPD)
                    {
                        Caption = 'Quantity Shipped';
                    }

                    column(QTYINVCD; QTYINVCD)
                    {
                        Caption = 'Quantity Invoiced';
                    }
                }

            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}