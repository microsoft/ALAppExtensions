tableextension 4853 "AutoAcc. Invoice Post. Buffer" extends "Invoice Post. Buffer"
{
    fields
    {
        field(4850; "Automatic Account Group"; Code[10])
        {
            Caption = 'Automatic Account Group';
            DataClassification = SystemMetadata;
            TableRelation = "Automatic Account Header";
            ObsoleteReason = 'This table will be replaced by table Invoice Posting Buffer in new Invoice Posting implementation.';
#if CLEAN20
            ObsoleteState = Removed;
            ObsoleteTag = '23.0';
#else
            ObsoleteState = Pending;
            ObsoleteTag = '20.0';
#endif
        }
    }
}
