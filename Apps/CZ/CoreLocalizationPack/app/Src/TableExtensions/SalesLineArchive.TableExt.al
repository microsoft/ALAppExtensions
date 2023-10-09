tableextension 31016 "Sales Line Archive CZL" extends "Sales Line Archive"
{
    fields
    {
        field(31064; "Physical Transfer CZL"; Boolean)
        {
            Caption = 'Physical Transfer';
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
    }
}