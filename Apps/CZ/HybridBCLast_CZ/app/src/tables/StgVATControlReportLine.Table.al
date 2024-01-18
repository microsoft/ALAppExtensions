table 11717 "Stg VAT Control Report Line"
{
    ReplicateData = false;
    Extensible = false;
    ObsoleteState = Removed;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '24.0';

    fields
    {
        field(1; "Control Report No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(43; "Corrections for Bad Receivable"; Option)
        {
            DataClassification = CustomerContent;
            OptionCaption = ' ,Insolvency Proceedings (p.44),Bad Receivable (p.46 resp. 74a)';
            OptionMembers = " ","Insolvency Proceedings (p.44)","Bad Receivable (p.46 resp. 74a)";
        }
        field(44; "Insolvency Proceedings (p.44)"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Insolvency Proceedings (p.44)';
        }
    }

    keys
    {
        key(Key1; "Control Report No.", "Line No.")
        {
            Clustered = true;
        }
    }
}

