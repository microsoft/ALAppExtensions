#if not CLEAN22
table 4857 "Auto. Acc. Page Setup"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; Id; Enum "AAC Page Setup Key")
        {
            DataClassification = SystemMetadata;
        }
        field(2; ObjectId; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Id)
        {
            Clustered = true;
        }
    }
}
#endif