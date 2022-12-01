tableextension 31052 "CV Ledger Entry Buffer CZL" extends "CV Ledger Entry Buffer"
{
    fields
    {
        field(11730; "Orig. Pmt. Disc. CZL"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Pmt. Disc.';
            DataClassification = SystemMetadata;
        }
        field(11731; "Orig. Pmt. Disc. (LCY) CZL"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Pmt. Disc. (LCY)';
            DataClassification = SystemMetadata;
        }
        field(11732; "Corr. Pmt. Disc. (LCY) CZL"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Corr. Pmt. Disc. (LCY)';
            DataClassification = SystemMetadata;
        }
    }
}