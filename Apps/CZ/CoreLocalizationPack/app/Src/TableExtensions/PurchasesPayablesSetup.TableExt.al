tableextension 11715 "Purchases & Payables Setup CZL" extends "Purchases & Payables Setup"
{
    fields
    {
        field(11780; "Default VAT Date CZL"; Enum "Default VAT Date CZL")
        {
            Caption = 'Default VAT Date';
            DataClassification = CustomerContent;
        }
        field(11781; "Allow Alter Posting Groups CZL"; Boolean)
        {
            Caption = 'Allow Alter Posting Groups';
            DataClassification = CustomerContent;
        }
        field(31110; "Def. Orig. Doc. VAT Date CZL"; Option)
        {
            Caption = 'Default Original Document VAT Date';
            OptionCaption = 'Blank,Posting Date,VAT Date,Document Date';
            OptionMembers = Blank,"Posting Date","VAT Date","Document Date";
            DataClassification = CustomerContent;
        }
    }
}
