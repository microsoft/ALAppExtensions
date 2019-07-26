table 135039 "Cues And KPIs Test 1 Cue"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
        }
        field(10; NormalInteger; Integer)
        {
        }
        field(15; NormalDecimal; Decimal)
        {
        }
        field(20; FlowfieldInteger; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = sum ("Cues And KPIs Test 1 Cue".NormalInteger);
        }
        field(25; FlowfieldDecimal; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum ("Cues And KPIs Test 1 Cue".NormalDecimal);
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}