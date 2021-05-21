tableextension 31012 "Transfer Shipment Header CZL" extends "Transfer Shipment Header"
{
    fields
    {
        field(31069; "Intrastat Exclude CZL"; Boolean)
        {
            Caption = 'Intrastat Exclude';
            DataClassification = CustomerContent;
        }
    }
}