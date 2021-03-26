table 20256 "Tax Acc. Period Setup"
{
    Caption = 'Tax Type Accounting Setup';
    LookupPageId = "Tax Acc. Period Setup";
    DrillDownPageId = "Tax Acc. Period Setup";
    DataClassification = EndUserIdentifiableInformation;
    Access = Public;
    Extensible = false;
    fields
    {
        field(1; Code; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

}