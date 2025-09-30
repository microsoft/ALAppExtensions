namespace Microsoft.DataMigration.GP;

table 4090 "GP Account"
{
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; AcctNum; Text[75]) // ACTNUMST - Main segment
        {
            Caption = 'Account Number';
            DataClassification = CustomerContent;
        }
        field(2; AcctIndex; Integer)
        {
            Caption = 'Account Index';
            DataClassification = CustomerContent;
        }
        field(3; Name; Text[100]) // ACTDESCR
        {
            Caption = 'Account Name';
            DataClassification = CustomerContent;
        }
        field(4; SearchName; Text[100]) // SEARCHNAME
        {
            Caption = 'Search Name';
            DataClassification = CustomerContent;
        }
        field(5; AccountCategory; Integer) // ACCATNUM
        {
            Caption = 'Account Category';
            DataClassification = CustomerContent;
        }
        field(6; IncomeBalance; Boolean) // PSTNGTYP
        {
            Caption = 'Income/Balance';
            DataClassification = CustomerContent;
        }
        field(7; DebitCredit; Integer) // TPCLBLNC
        {
            Caption = 'Debit/Credit';
            DataClassification = CustomerContent;
        }
        field(8; Active; Boolean) // ACTIVE
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(9; DirectPosting; Boolean) // ACCTENTR
        {
            Caption = 'Direct Posting';
            DataClassification = CustomerContent;
        }
        field(10; AccountSubcategoryEntryNo; Integer) // ACCOUNTSUBCATEGORYENTRYNO
        {
            Caption = 'Account Subcategory Entry Number';
            DataClassification = CustomerContent;
        }
        field(12; AccountType; Integer) // ACCTTYPE
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
        }
        field(13; ACTNUMBR_1; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(14; ACTNUMBR_2; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(15; ACTNUMBR_3; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(16; ACTNUMBR_4; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(17; ACTNUMBR_5; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(18; ACTNUMBR_6; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(19; ACTNUMBR_7; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(20; ACTNUMBR_8; Text[20])
        {
            DataClassification = CustomerContent;
        }
        field(100; "Standard Sales Code"; Code[10])
        {
            DataClassification = SystemMetadata;
        }
        field(101; "Standard Purchase Code"; Code[10])
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; AcctIndex)
        {
            Clustered = true;
        }
        key(AcctNum; AcctNum)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; AcctNum, Name)
        {
        }
    }
}

