namespace Microsoft.Finance.PowerBIReports;

using Microsoft.Finance.GeneralLedger.Account;

table 36953 "Account Category"
{
    Access = Internal;
    Caption = 'Power BI Account Category';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Account Category Type"; Enum "Account Category Type")
        {
            Caption = 'Power BI Account Category';
        }
        field(2; "G/L Acc. Category Entry No."; Integer)
        {
            Caption = 'G/L Acc. Category Entry No.';
            TableRelation = "G/L Account Category";
        }
        field(3; "Parent Acc. Category Entry No."; Integer)
        {
            Caption = 'Parent Acc. Category Entry No.';
            TableRelation = "G/L Account Category";
        }
    }

    keys
    {
        key(PK; "Account Category Type")
        {
            Clustered = true;
        }
    }
}