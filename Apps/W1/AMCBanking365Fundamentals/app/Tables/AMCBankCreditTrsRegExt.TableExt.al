tableextension 20107 "AMC Bank Credit Trs. Reg. Ext" extends "Credit Transfer Register"
{
    fields
    {
        field(20100; "Data Exch. Entry No."; Integer)
        {
            Caption = 'Data Exch. Entry No.';
            Editable = false;
            TableRelation = "Data Exch.";
            DataClassification = CustomerContent;
        }
        field(20101; "AMC Bank XTL Journal"; Text[250])
        {
            Caption = 'XTL Journal';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(AMCKey1; "Data Exch. Entry No.")
        {
        }
    }


}

