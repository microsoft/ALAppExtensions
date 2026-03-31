namespace Microsoft.DataMigration.GP;

table 40198 "GP GL00103"
{
    DataClassification = CustomerContent;
    fields
    {
        field(1; ACTINDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; PRCNTAGE; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(3; DSTINDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(4; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(100; "Dist. Is Posting Account"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("GP GL00100" where(ACTINDX = field(DSTINDX), ACCTTYPE = const(1)));
            Editable = false;
        }
    }
    keys
    {
        key(Key1; ACTINDX, DSTINDX)
        {
            Clustered = true;
        }
    }
}

