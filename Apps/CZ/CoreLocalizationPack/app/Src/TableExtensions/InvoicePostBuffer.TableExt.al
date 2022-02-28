#pragma warning disable AL0432
tableextension 11722 "Invoice Post. Buffer CZL" extends "Invoice Post. Buffer"
#pragma warning restore AL0432
{
    fields
    {
        field(11773; "Ext. Amount CZL"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Ext. Amount';
            DataClassification = SystemMetadata;
        }
        field(11774; "Ext. Amount Incl. VAT CZL"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Ext. Amount Including VAT';
            DataClassification = SystemMetadata;
        }
        field(11780; "VAT Date CZL"; Date)
        {
            Caption = 'VAT Date';
            DataClassification = SystemMetadata;
        }
        field(11783; "Correction CZL"; Boolean)
        {
            Caption = 'Correction';
            DataClassification = SystemMetadata;
        }
        field(31112; "Original Doc. VAT Date CZL"; Date)
        {
            Caption = 'Original Document VAT Date';
            DataClassification = SystemMetadata;
        }
    }
}
