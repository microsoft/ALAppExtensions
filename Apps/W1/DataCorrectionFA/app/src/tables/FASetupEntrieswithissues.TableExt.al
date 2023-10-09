namespace Microsoft.FixedAssets.Repair;

using Microsoft.FixedAssets.Setup;

tableextension 6091 "FA Setup Entries with issues" extends "FA setup"
{
    fields
    {
        field(6090; LastEntryNo; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Entry No. Checked';
        }
        field(6091; "Last time scanned"; DateTime)
        {
            Caption = 'Last time scanned';
            DataClassification = CustomerContent;
        }
    }
}


