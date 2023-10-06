#if not CLEAN21
#pragma warning disable AL0432
#endif
tableextension 11784 "Adj. Exchange Rate Buffer CZL" extends "Adjust Exchange Rate Buffer"
#if not CLEAN21
#pragma warning restore AL0432
#endif
{
    fields
    {
        field(11765; "Document Type CZL"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
            DataClassification = SystemMetadata;
        }
        field(11766; "Document No. CZL"; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = SystemMetadata;
        }
    }
}