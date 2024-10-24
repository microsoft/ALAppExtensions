#if not CLEANSCHEMA24
table 11700 "Stg VAT Posting Setup"
{
    ReplicateData = false;
    Extensible = false;
    ObsoleteState = Removed;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '24.0';

    fields
    {
        field(1; "VAT Bus. Posting Group"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(2; "VAT Prod. Posting Group"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(31102; "Insolvency Proceedings (p.44)"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(31104; "Corrections for Bad Receivable"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ","Insolvency Proceedings (p.44)","Bad Receivable (p.46 resp. 74a)";
        }
    }

    keys
    {
        key(Key1; "VAT Bus. Posting Group", "VAT Prod. Posting Group")
        {
            Clustered = true;
        }
        key(Key2; "VAT Prod. Posting Group", "VAT Bus. Posting Group")
        {
        }
    }
}
#endif