tableextension 11751 "Acc. Schedule Line CZL" extends "Acc. Schedule Line"
{
    fields
    {
        field(31070; "Calc CZL"; Enum "Accounting Schedule Calc CZL")
        {
            Caption = 'Calc';
            DataClassification = CustomerContent;
        }
        field(31071; "Row Correction CZL"; Code[10])
        {
            Caption = 'Row Correction';
            DataClassification = CustomerContent;
        }
        field(31072; "Assets/Liabilities Type CZL"; Enum "Assets Liabilities Type CZL")
        {
            Caption = 'Assets/Liabilities Type';
            DataClassification = CustomerContent;
        }
        field(31085; "Source Table CZL"; Enum "Acc. Schedule Source Table CZL")
        {
            Caption = 'Source Table';
            DataClassification = CustomerContent;
        }
    }
}
