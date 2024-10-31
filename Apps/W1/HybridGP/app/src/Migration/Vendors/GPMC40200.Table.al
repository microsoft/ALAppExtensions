namespace Microsoft.DataMigration.GP;

table 40110 "GP MC40200"
{
    Description = 'GP Currency Setup';
    DataClassification = CustomerContent;
    DataPerCompany = false;

    fields
    {
        field(1; CURNCYID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(2; CURRNIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(3; NOTEINDX; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(4; CRNCYDSC; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(5; CRNCYSYM; Text[3])
        {
            DataClassification = CustomerContent;
        }
        field(6; CNYSYMAR_1; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(7; CNYSYMAR_2; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(8; CNYSYMAR_3; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(9; CYSYMPLC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(10; INCLSPAC; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(11; NEGSYMBL; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(12; NGSMAMPC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(13; NEGSMPLC; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(14; DECSYMBL; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(15; DECPLCUR; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(16; THOUSSYM; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(17; CURTEXT_1; Text[25])
        {
            DataClassification = CustomerContent;
        }
        field(18; CURTEXT_2; Text[25])
        {
            DataClassification = CustomerContent;
        }
        field(19; CURTEXT_3; Text[25])
        {
            DataClassification = CustomerContent;
        }
        field(20; ISOCURRC; Text[3])
        {
            DataClassification = CustomerContent;
        }
        field(21; CURLNGID; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(22; DEX_ROW_TS; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(23; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; CURNCYID)
        {
            Clustered = true;
        }
    }
}