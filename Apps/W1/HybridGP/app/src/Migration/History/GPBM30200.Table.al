namespace Microsoft.DataMigration.GP;

table 41003 "GP BM30200"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; TRX_ID; Text[19])
        {
            DataClassification = CustomerContent;
        }
        field(2; BM_Trx_Status; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(3; BCHSOURC; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(4; BACHNUMB; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(5; Batch_ID_Note_Index; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(6; Completion_Date; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(7; BM_Start_Date; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(8; TRXDATE; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(9; PSTGDATE; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(10; REFRENCE; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(13; NOTEINDX; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(14; MODIFDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(15; USER2ENT; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(16; CREATDDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(17; PTDUSRID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(18; POSTEDDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(19; TRXSORCE; Text[13])
        {
            DataClassification = CustomerContent;
        }
        field(20; USERDEF1; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(21; USERDEF2; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(22; USRDEF03; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(23; USRDEF04; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(24; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; TRX_ID)
        {
            Clustered = true;
        }
    }
}