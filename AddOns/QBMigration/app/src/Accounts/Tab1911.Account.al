table 1911 "MigrationQB Account"
{
    ReplicateData = false;

    fields
    {
        field(1; AcctNum; Text[15])
        {
            DataClassification = CustomerContent;
            Caption = 'Account Number';
        }
        field(2; Name; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(3; SubAccount; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(4; FullyQualifiedName; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(5; Active; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(6; Classification; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(7; AccountType; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Account Type';
        }
        field(8; AccountSubType; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(9; CurrentBalance; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(10; CurrentBalanceWithSubAccounts; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(11; Id; Text[15])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; AcctNum)
        {
            Clustered = true;
        }
        key(Key2; Id)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; AcctNum, Name, AccountType)
        {
        }
    }
}

