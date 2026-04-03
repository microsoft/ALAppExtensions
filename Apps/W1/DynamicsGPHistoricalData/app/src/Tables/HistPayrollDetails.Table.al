namespace Microsoft.DataMigration.GP.HistoricalData;

table 40917 "Hist. Payroll Details"
{
    Caption = 'Hist. Payroll Details';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Hist. Gen. Journal Line Key"; Integer)
        {
            Caption = 'Hist. Gen. Journal Line Key';
        }
        field(2; "Orig. Document No."; Text[35])
        {
            Caption = 'Orig. Document No.';
        }
        field(3; "Source No."; Text[35])
        {
            Caption = 'Source No.';
        }
        field(4; "Source Name"; Text[50])
        {
            Caption = 'Source Name';
        }
    }
    keys
    {
        key(PK; "Hist. Gen. Journal Line Key")
        {
            Clustered = true;
        }
    }
}