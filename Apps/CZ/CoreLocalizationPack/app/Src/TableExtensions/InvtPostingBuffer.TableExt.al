tableextension 31053 "Invt. Posting Buffer CZL" extends "Invt. Posting Buffer"
{
    fields
    {
        field(11764; "G/L Correction CZL"; Boolean)
        {
            Caption = 'G/L Correction';
            Editable = false;
            DataClassification = SystemMetadata;
        }
    }
}