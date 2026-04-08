namespace Microsoft.DataMigration.GP;

table 40199 "GP GL00104"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; ACTINDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; SEPRATR1; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(3; DSTINDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(4; SEPRATR2; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(5; BDNINDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(6; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(100; "Dist. Is Posting Account"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("GP GL00100" where(ACTINDX = field(DSTINDX), ACCTTYPE = const(1)));
            Editable = false;
        }
        field(101; "Brkdn. Is Posting Account"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("GP GL00100" where(ACTINDX = field(BDNINDX), ACCTTYPE = const(1)));
            Editable = false;
        }
    }
    keys
    {
        key(Key1; ACTINDX, DSTINDX, BDNINDX)
        {
            Clustered = true;
        }
    }
}

