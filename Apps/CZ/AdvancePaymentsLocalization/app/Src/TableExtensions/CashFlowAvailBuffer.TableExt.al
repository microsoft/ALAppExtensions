tableextension 31043 "Cash Flow Avail. Buffer CZZ" extends "Cash Flow Availability Buffer"
{
    fields
    {
        field(11702; "Sales Advances CZZ"; Decimal)
        {
            Caption = 'Sales Advances';
            DataClassification = SystemMetadata;
        }
        field(11703; "Purchase Advances CZZ"; Decimal)
        {
            Caption = 'Purchase Advances';
            DataClassification = SystemMetadata;
        }
    }
}