#if not CLEAN21
#pragma warning disable AL0432
#endif
tableextension 31053 "Invt. Posting Buffer CZL" extends "Invt. Posting Buffer"
#if not CLEAN21
#pragma warning restore AL0432
#endif
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