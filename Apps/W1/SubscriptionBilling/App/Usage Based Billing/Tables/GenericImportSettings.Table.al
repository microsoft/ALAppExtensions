namespace Microsoft.SubscriptionBilling;

using System.IO;

table 8017 "Generic Import Settings"
{
    Caption = 'Generic Import Settings';
    DataClassification = CustomerContent;
    LookupPageId = "Generic Import Settings Card";
    DrillDownPageId = "Generic Import Settings Card";
    Access = Internal;

    fields
    {
        field(1; "Usage Data Supplier No."; Code[20])
        {
            Caption = 'Usage Data Supplier No.';
            TableRelation = "Usage Data Supplier";
            NotBlank = true;
        }
        field(2; "Data Exchange Definition"; Code[20])
        {
            Caption = 'Data Exchange Definition';
            TableRelation = "Data Exch. Def" where(Type = const("Generic Import"));
        }
        field(3; "Create Customers"; Boolean)
        {
            Caption = 'Create Customers';
            InitValue = true;
        }
        field(4; "Create Subscriptions"; Boolean)
        {
            Caption = 'Create Subscriptions';
            InitValue = true;
        }
        field(5; "Additional Processing"; Enum "Additional Processing Type")
        {
            Caption = 'Additional Processing';
        }
        field(6; "Process without UsageDataBlobs"; Boolean)
        {
            Caption = 'Process without Usage Data Blobs';
        }
    }
    keys
    {
        key(PK; "Usage Data Supplier No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "Usage Data Supplier No." = '' then
            "Usage Data Supplier No." := GetUsageDataSupplierNoFromFilter();
    end;

    internal procedure GetUsageDataSupplierNoFromFilter() UsageDataSupplierNo: Code[20]
    begin
        Rec.FilterGroup(2);
        UsageDataSupplierNo := CopyStr(Rec.GetFilter("Usage Data Supplier No."), 1, MaxStrLen(UsageDataSupplierNo));
        Rec.FilterGroup(0);
    end;
}
