query 3007 GPHistSalesLineItems
{
    QueryType = Normal;
    QueryCategory = 'Customer List';
    Caption = 'Dynamics GP Sales Line Items';
    elements
    {
        dataitem(GP_SOPTrxHist; GPSOPTrxHist)
        {
            column(SOPTYPE; SOPTYPE)
            {
                Caption = 'Document Type';
            }
            column(SOPNUMBE; SOPNUMBE)
            {
                Caption = 'Document Number';
            }
            column(DOCDATE; DOCDATE)
            {
                Caption = 'Document Date';
            }
            column(CUSTNMBR; CUSTNMBR)
            {
                Caption = 'Customer Number';
            }
            dataitem(GP_SOPTrxAmountsHist; GPSOPTrxAmountsHist)
            {
                DataItemLink = SOPTYPE = GP_SOPTrxHist.SOPTYPE,
                                SOPNUMBE = GP_SOPTrxHist.SOPNUMBE;
                SqlJoinType = InnerJoin;

                column(ITEMNMBR; ITEMNMBR)
                {
                    Caption = 'Item Number';
                }
                column(ITEMDESC; ITEMDESC)
                {
                    Caption = 'Item Description';
                }
                column(QUANTITY; QUANTITY)
                {
                    Caption = 'Quantity';
                }
                column(EXTDCOST; EXTDCOST)
                {
                    Caption = 'Extended Cost';
                }
                column(XTNDPRCE; XTNDPRCE)
                {
                    Caption = 'Extended Price';
                }
                column(UNITCOST; UNITCOST)
                {
                    Caption = 'Unit Cost';
                }
                column(UNITPRCE; UNITPRCE)
                {
                    Caption = 'Unit Price';
                }
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}