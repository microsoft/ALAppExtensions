tableextension 31032 "Gen. Journal Template CZL" extends "Gen. Journal Template"
{
    fields
    {
        field(11770; "Not Check Doc. Type CZL"; Boolean)
        {
            Caption = 'Not Check Doc. Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Force Doc. Balance");
            end;
        }
    }
}