table 132549 "Page Provider Summary Test2"
{
    fields
    {
        field(1; TestInteger; Integer)
        {
        }
        field(2; TestBigInteger; BigInteger)
        {
        }
        field(3; TestBlob; Blob)
        {
        }
        field(4; TestBoolean; Boolean)
        {
        }
        field(5; TestCode; Code[20])
        {
        }
        field(6; TestDate; Date)
        {
        }
        field(7; TestDateFormula; DateFormula)
        {
        }
        field(8; TestDateTime; DateTime)
        {
        }
        field(9; TestDecimal; Decimal)
        {
        }
        field(10; TestDuration; Duration)
        {
        }
        field(11; TestEnum; Enum "Page Provider Summary Test")
        {
        }
        field(12; TestGuid; Guid)
        {
        }
        field(13; TestMedia; Media)
        {
        }
        field(14; TestMediaSet; MediaSet)
        {
        }
        field(15; TestOption; Option)
        {
            OptionMembers = Option1,Option2,Option3;
        }
        field(16; TestRecordId; RecordId)
        {
        }
        field(17; TestTableFilter; TableFilter)
        {
        }
        field(18; TestText; Text[20])
        {
        }
        field(19; TestTime; Time)
        {
        }
    }

    keys
    {
        key(PK; TestInteger)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(Brick; TestInteger, TestText, TestCode, TestDateTime)
        {

        }
    }
}