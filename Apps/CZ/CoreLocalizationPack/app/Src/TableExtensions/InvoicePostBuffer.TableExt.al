tableextension 11722 "Invoice Post. Buffer CZL" extends "Invoice Post. Buffer"
{
    fields
    {
        field(11780; "VAT Date CZL"; Date)
        {
            Caption = 'VAT Date';
            DataClassification = SystemMetadata;
        }
        field(31112; "Original Doc. VAT Date CZL"; Date)
        {
            Caption = 'Original Document VAT Date';
            DataClassification = SystemMetadata;
        }
    }
}
