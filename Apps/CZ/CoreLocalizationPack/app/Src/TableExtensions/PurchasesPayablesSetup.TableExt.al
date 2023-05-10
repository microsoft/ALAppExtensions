tableextension 11715 "Purchases & Payables Setup CZL" extends "Purchases & Payables Setup"
{
    fields
    {
        field(11780; "Default VAT Date CZL"; Enum "Default VAT Date CZL")
        {
            Caption = 'Default VAT Date';
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Replaced by VAT Reporting Date in General Ledger Setup.';
        }
        field(11781; "Allow Alter Posting Groups CZL"; Boolean)
        {
            Caption = 'Allow Alter Posting Groups';
            DataClassification = CustomerContent;
#if not CLEAN20            
            ObsoleteState = Pending;
            ObsoleteTag = '20.1';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '23.0';
#endif
            ObsoleteReason = 'It will be replaced by "Allow Multiple Posting Groups" field.';
        }
        field(31110; "Def. Orig. Doc. VAT Date CZL"; Option)
        {
            Caption = 'Default Original Document VAT Date';
            OptionCaption = 'Blank,Posting Date,VAT Date,Document Date';
            OptionMembers = Blank,"Posting Date","VAT Date","Document Date";
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Replaced by Def. Orig. Doc. VAT Date CZL in General Ledger Setup.';
        }
    }
}
