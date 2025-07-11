table 139615 "E-Doc. Mapping Test Rec"
{
    Access = Internal;
    DataClassification = SystemMetadata;
    
    fields
    {
        field(1; "Key Field"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Text Value"; Text[250])
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Code Value"; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Decimal Value"; Decimal)
        {
            DataClassification = SystemMetadata;    
        }
    }
    
    keys
    {
        key(Key1; "Key Field")
        {
            Clustered = true;
        }
    }
    
}