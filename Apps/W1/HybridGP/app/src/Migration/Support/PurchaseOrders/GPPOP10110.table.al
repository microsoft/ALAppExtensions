namespace Microsoft.DataMigration.GP;

table 40138 "GP POP10110"
{
    DataClassification = CustomerContent;
    Extensible = false;

    fields
    {
        field(1; PONUMBER; Text[18])
        {
            Caption = 'PONUMBER';
            DataClassification = CustomerContent;
        }
        field(2; ORD; Integer)
        {
            Caption = 'ORD';
            DataClassification = CustomerContent;
        }
        field(3; POLNESTA; Option)
        {
            Caption = 'POLNESTA';
            OptionMembers = ,"New","Released","Change Order","Received","Closed","Canceled";
            DataClassification = CustomerContent;
        }
        field(4; POTYPE; Option)
        {
            Caption = 'POTYPE';
            OptionMembers = ,"Standard","Drop-Ship","Blanket","Drop-Ship Blanket";
            DataClassification = CustomerContent;
        }
        field(5; ITEMNMBR; Text[32])
        {
            Caption = 'ITEMNMBR';
            DataClassification = CustomerContent;
        }
        field(6; ITEMDESC; Text[102])
        {
            Caption = 'ITEMDESC';
            DataClassification = CustomerContent;
        }
        field(7; VENDORID; Text[16])
        {
            Caption = 'VENDORID';
            DataClassification = CustomerContent;
        }
        field(10; NONINVEN; Integer)
        {
            Caption = 'NONINVEN';
            DataClassification = CustomerContent;
        }
        field(11; LOCNCODE; Text[12])
        {
            Caption = 'LOCNCODE';
            DataClassification = CustomerContent;
        }
        field(12; UOFM; Text[10])
        {
            Caption = 'UOFM';
            DataClassification = CustomerContent;
        }
        field(14; QTYORDER; Decimal)
        {
            Caption = 'QTYORDER';
            DataClassification = CustomerContent;
        }
        field(15; QTYCANCE; Decimal)
        {
            Caption = 'QTYCANCE';
            DataClassification = CustomerContent;
        }
        field(18; UNITCOST; Decimal)
        {
            Caption = 'UNITCOST';
            DataClassification = CustomerContent;
        }
        field(19; EXTDCOST; Decimal)
        {
            Caption = 'EXTDCOST';
            DataClassification = CustomerContent;
        }
        field(20; INVINDX; Integer)
        {
            Caption = 'INVINDX';
            DataClassification = CustomerContent;
        }
        field(21; REQDATE; Date)
        {
            Caption = 'REQDATE';
            DataClassification = CustomerContent;
        }
        field(22; PRMDATE; Date)
        {
            Caption = 'PRMDATE';
            DataClassification = CustomerContent;
        }
        field(40; BRKFLD1; Integer)
        {
            Caption = 'BRKFLD1';
            DataClassification = CustomerContent;
        }
        field(47; CURNCYID; Text[16])
        {
            Caption = 'CURNCYID';
            DataClassification = CustomerContent;
        }
        field(48; CURRNIDX; Integer)
        {
            Caption = 'CURRNIDX';
            DataClassification = CustomerContent;
        }
        field(49; XCHGRATE; Decimal)
        {
            Caption = 'XCHGRATE';
            DataClassification = CustomerContent;
        }
        field(50; RATECALC; Integer)
        {
            Caption = 'RATECALC';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; PONUMBER, ORD, BRKFLD1)
        {
            Clustered = true;
        }
    }
}