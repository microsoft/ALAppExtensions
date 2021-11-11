tableextension 20108 "AMC Bank Paym. Exp. Data Ext" extends "Payment Export Data"
{
    fields
    {
        field(20100; "AMC Recip. Bank Acc. Currency"; Code[10])
        {
            Caption = 'Recipient Bank Account Currency';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
    }

}

