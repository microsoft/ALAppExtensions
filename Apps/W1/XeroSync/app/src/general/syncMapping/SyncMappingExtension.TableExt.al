tableextension 2404 "XS Sync Mapping Extension" extends "Sync Mapping" //50102
{
    fields
    {
        field(5; "XS Last Synced Xero"; Text[250])
        {
            Caption = 'Last Synched Xero';
            DataClassification = SystemMetadata;
        }
        field(6; "XS Xero Json Response"; Blob)
        {
            Caption = 'Xero Json Response';
            DataClassification = CustomerContent;
        }
        field(7; "XS NAV Data"; Blob)
        {
            Caption = 'NAV Data';
            DataClassification = CustomerContent;
        }
        field(8; "XS NAV Entity ID"; Integer)
        {
            Caption = 'NAV Entity ID';
            DataClassification = SystemMetadata;
        }
        field(9; "XS Do Not Delete"; Boolean)
        {
            Caption = 'Do not delete';
            DataClassification = SystemMetadata;
            Description = 'This field is used in processing deletion from Xero, and is used only in temporary record';
        }
        field(10; "XS Active"; Boolean)
        {
            Caption = 'Active';
            DataClassification = SystemMetadata;
            Description = 'When Entity is delted the mapping becomes inactive (false).';
        }
    }
}