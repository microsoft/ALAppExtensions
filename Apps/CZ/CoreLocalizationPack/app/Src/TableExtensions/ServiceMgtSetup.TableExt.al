tableextension 11716 "Service Mgt. Setup CZL" extends "Service Mgt. Setup"
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
#if not CLEAN20            
            ObsoleteState = Pending;
            ObsoleteTag = '20.1';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '23.0';
#endif
            ObsoleteReason = 'It will be replaced by "Allow Multiple Posting Groups" field.';

        }
    }
}
