table 40116 "GP IV00101"
{
    Description = 'Item Master';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ITEMNMBR; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(2; ITEMDESC; Text[101])
        {
            DataClassification = CustomerContent;
        }
        field(5; ITEMTYPE; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(7; STNDCOST; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(8; CURRCOST; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(9; ITEMSHWT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(14; IVIVINDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(29; ITMCLSCD; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(30; ITMTRKOP; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(37; VCTNMTHD; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(38; UOMSCHDL; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(63; PRCHSUOM; Text[9])
        {
            DataClassification = CustomerContent;
        }
        field(64; SELNGUOM; Text[9])
        {
            DataClassification = CustomerContent;
        }
        field(75; INACTIVE; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; ITEMNMBR)
        {
            Clustered = true;
        }
    }

    procedure DiscontinuedItemTypeId(): Integer
    begin
        exit(2);
    end;

    procedure KitItemTypeId(): Integer
    begin
        exit(3);
    end;

    procedure IsDiscontinued(): Boolean
    begin
        exit(Rec.ITEMTYPE = DiscontinuedItemTypeId());
    end;
}