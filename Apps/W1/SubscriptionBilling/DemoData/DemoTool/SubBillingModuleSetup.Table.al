namespace Microsoft.SubscriptionBilling;

table 8101 "Sub. Billing Module Setup"
{
    DataClassification = CustomerContent;
    InherentEntitlements = RMX;
    InherentPermissions = RMX;
    Extensible = false;
    DataPerCompany = true;
    ReplicateData = false;
    Caption = 'Sub. Billing Module Setup';

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Primary Key';
        }
        field(2; "Create entries in Job Queue"; Boolean)
        {
            Caption = 'Create entries in Job Queue';
            ToolTip = 'Specifies whether Subscription Billing related tasks are created in the Job Queue.';
            InitValue = true;
        }
        field(3; "Import Data Exch. Definition"; Boolean)
        {
            Caption = 'Import Data Exchange Definition';
            ToolTip = 'Specifies whether a Data Exchange Definition is imported to be used for usage data.';
            InitValue = true;
        }
        field(4; "Import reconciliation file"; Boolean)
        {
            Caption = 'Import reconciliation file';
            ToolTip = 'Specifies whether a reconciliation file is imported to be used for usage data.';
            InitValue = true;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    [InherentPermissions(PermissionObjectType::TableData, Database::"Sub. Billing Module Setup", 'I')]
    internal procedure InitRecord()
    begin
        if Rec.Get() then
            exit;

        Rec.Init();
        Rec.Insert();
    end;
}