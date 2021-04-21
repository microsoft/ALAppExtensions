query 3004 GPHistSalesReturns
{
    QueryType = Normal;
    QueryCategory = 'Customer List';
    Caption = 'Dynamics GP Sales Returns';
    elements
    {
        dataitem(GP_SOPTrxHist; GPSOPTrxHist)
        {
            DataItemTableFilter = SOPTYPE = const(Return);

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
            column(DUEDATE; DUEDATE)
            {
                Caption = 'Due Date';
            }
            column(ACTLSHIP; ACTLSHIP)
            {
                Caption = 'Actual Ship Date';
            }
            column(CUSTNMBR; CUSTNMBR)
            {
                Caption = 'Customer Number';
            }
            column(CUSTNAME; CUSTNAME)
            {
                Caption = 'Customer Name';
            }
            column(CNTCPRSN; CNTCPRSN)
            {
                Caption = 'Contact Person';
            }
            column(SLPRSNID; SLPRSNID)
            {
                Caption = 'Salesperson ID';
            }
            column(SALSTERR; SALSTERR)
            {
                Caption = 'Sales Territory';
            }
            column(CSTPONBR; CSTPONBR)
            {
                Caption = 'Customer PO Number';
            }
            column(SHIPMTHD; SHIPMTHD)
            {
                Caption = 'Shipping Method';
            }
            column(PRSTADCD; PRSTADCD)
            {
                Caption = 'Ship-to Address Code';
            }
            column(CITY; CITY)
            {
                Caption = 'City';
            }
            column(SOPSTATUS; SOPSTATUS)
            {
                Caption = 'Sales Document Status';
            }
            column(DOCAMNT; DOCAMNT)
            {
                Caption = 'Document Amount';
            }
            column(ORIGNUMB; ORIGNUMB)
            {
                Caption = 'Original Number';
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}