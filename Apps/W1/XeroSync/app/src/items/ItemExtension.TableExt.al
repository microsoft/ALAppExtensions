tableextension 2408 "Item Extension" extends Item
{
    fields
    {
        field(2400; "XS Tax Type"; Text[50])
        {
            DataClassification = SystemMetadata;
        }

        field(2401; "XS Account Code"; Code[10])
        {
            DataClassification = SystemMetadata;
        }
    }
}