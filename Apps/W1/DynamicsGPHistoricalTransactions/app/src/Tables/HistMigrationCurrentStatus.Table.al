table 40912 "Hist. Migration Current Status"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; Dummy; Code[10])
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Current Step"; enum "Hist. Migration Step Type")
        {
            Caption = 'Current Step';
            DataClassification = SystemMetadata;
        }
        field(3; "Error Count"; Integer)
        {
            CalcFormula = Count("Hist. Migration Step Error");
            Editable = false;
            FieldClass = FlowField;
        }
        field(4; "Log Count"; Integer)
        {
            CalcFormula = Count("Hist. Migration Step Status");
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; Dummy)
        {
            Clustered = true;
        }
    }
}