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
    }

    keys
    {
        key(Key1; AcctIndex)
        {
            Clustered = true;
        }
        Key(AcctNum; AcctNum)
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

