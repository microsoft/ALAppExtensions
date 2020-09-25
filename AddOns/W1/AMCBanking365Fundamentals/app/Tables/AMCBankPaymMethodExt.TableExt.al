tableextension 20104 "AMC Bank Paym. Method Ext" extends "Payment Method"
{
    fields
    {
        field(20100; "AMC Bank Pmt. Type"; Text[50])
        {
            Caption = 'Bank Pmt. Type';
            TableRelation = "AMC Bank Pmt. Type";
            DataClassification = CustomerContent;
        }
    }

}

