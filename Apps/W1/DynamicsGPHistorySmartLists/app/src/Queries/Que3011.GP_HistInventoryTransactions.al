query 3011 GPHistInventoryTrx
{
    QueryType = Normal;
    QueryCategory = 'Item List';
    Caption = 'Dynamics GP Inventory Transactions';

    elements
    {
        dataitem(GP_IVTrxAmountsHist; GPIVTrxAmountsHist)
        {
            column(DOCNUMBR; DOCNUMBR)
            {
                Caption = 'Document Number';
            }
            column(DOCTYPE; DOCTYPE)
            {
                Caption = 'Document Type';
            }
            column(ITEMNMBR; ITEMNMBR)
            {
                Caption = 'Item Number';
            }
            column(UOFM; UOFM)
            {
                Caption = 'Unit of Measure';
            }
            column(TRXQTY; TRXQTY)
            {
                Caption = 'Quantity';
            }
            column(UNITCOST; UNITCOST)
            {
                Caption = 'Unit Cost';
            }
            column(EXTDCOST; EXTDCOST)
            {
                Caption = 'Extended Cost';
            }
            column(TRXLOCTN; TRXLOCTN)
            {
                Caption = 'Location';
            }
            column(DOCDATE; DOCDATE)
            {
                Caption = 'Document Date';
            }
            dataitem(GP_IVTrxHist; "GPIVTrxHist")
            {
                DataItemLink = DOCNUMBR = GP_IVTrxAmountsHist.DOCNUMBR,
                            IVDOCTYP = GP_IVTrxAmountsHist.DOCTYPE;
                SqlJoinType = LeftOuterJoin;
            }
        }
    }
}