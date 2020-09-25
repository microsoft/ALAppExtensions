tableextension 20106 "AMC Bank Activity Log ext." extends "Activity Log"
{
    fields
    {
        field(20100; "AMC Bank WebLog Status"; Enum AMCBankWebLogStatus)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
    }

}