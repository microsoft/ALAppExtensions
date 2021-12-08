query 18051 GSTR2CompTaxValue

{
    QueryType = Normal;

    elements
    {
        dataitem(Detailed_GST_Ledger_Entry; "Detailed GST Ledger Entry")
        {
            column(Document_Type; "Document Type")
            {
            }
            column(Posting_Date; "Posting Date")
            {

            }
            column(Location__Reg__No_; "Location  Reg. No.")
            {
            }
            column(GST_Vendor_Type; "GST Vendor Type")
            {

            }
            column(GST_Jurisdiction_Type; "GST Jurisdiction Type")
            {

            }
            column(GST__; "GST %")
            {
            }
            column(GST_Base_Amount; "GST Base Amount")
            {
                Method = Sum;
            }
        }

    }
}
