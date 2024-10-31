namespace Microsoft.DataMigration.GP;

query 40100 "GP Populate Item Transactions"
{
    QueryType = Normal;
    OrderBy = ascending(ITEMNMBR, TRXLOCTN, DATERECD);

    elements
    {
        dataitem(GPIV10200; "GP IV10200")
        {
            column(ITEMNMBR; ITEMNMBR)
            {
            }

            column(TRXLOCTN; TRXLOCTN)
            {
            }

            column(UNITCOST; UNITCOST)
            {
            }

            column(RCTSEQNM; RCTSEQNM)
            {
            }

            column(RCPTNMBR; RCPTNMBR)
            {
            }

            column(DATERECD; DATERECD)
            {
            }

            filter(RCPTSOLD; RCPTSOLD)
            {
            }

            column(QTYRECVD; QTYRECVD)
            {
            }

            column(QTYSOLD; QTYSOLD)
            {
            }

            column(QTYTYPE; QTYTYPE)
            {
            }

            dataitem(GPIV00101; "GP IV00101")
            {
                SqlJoinType = InnerJoin;
                DataItemLink = ITEMNMBR = GPIV10200.ITEMNMBR;

                column(ITMTRKOP; ITMTRKOP)
                {
                }

                column(CURRCOST; CURRCOST)
                {
                }

                column(STNDCOST; STNDCOST)
                {
                }

                dataitem(GPIV00300; "GP IV00300")
                {
                    SqlJoinType = LeftOuterJoin;
                    DataItemLink = LOCNCODE = GPIV10200.TRXLOCTN, DATERECD = GPIV10200.DATERECD, ITEMNMBR = GPIV10200.ITEMNMBR, RCTSEQNM = GPIV10200.RCTSEQNM;

                    column(LOTNUMBR; LOTNUMBR)
                    {
                    }

                    column(EXPNDATE; EXPNDATE)
                    {
                    }

                    column(QTYRECVDGPIV00300; QTYRECVD)
                    {
                    }

                    column(QTYSOLDGPIV00300; QTYSOLD)
                    {
                    }

                    dataitem(GPIV00200; "GP IV00200")
                    {
                        SqlJoinType = LeftOuterJoin;
                        DataItemLink = LOCNCODE = GPIV10200.TRXLOCTN, DATERECD = GPIV10200.DATERECD, ITEMNMBR = GPIV10200.ITEMNMBR, RCTSEQNM = GPIV10200.RCTSEQNM;

                        column(SERLNMBR; SERLNMBR)
                        {
                        }
                    }
                }
            }
        }
    }
}