table 51753 "Bus Queue Detailed"
{
    Access = Internal;
    Caption = 'Bus Queue Detailed';
    DrillDownPageId = "Bus Queues Detailed";
    LookupPageId = "Bus Queues Detailed";
    Extensible = false;
    InherentEntitlements = RIMD;
    InherentPermissions = RIMD;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(2; "Parent Entry No."; Integer)
        {
            Caption = 'Parent Entry No.';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(4; Status; Enum "Bus Queue Status")
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
        }
        field(5; "No. Of Try"; Integer)
        {
            Caption = 'No. Of Try';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        BusQueueDetailed: Record "Bus Queue Detailed";
    begin
        BusQueueDetailed.ReadIsolation := IsolationLevel::UpdLock;
        BusQueueDetailed.SetLoadFields("Entry No.");
        if BusQueueDetailed.FindLast() then
            "Entry No." := BusQueueDetailed."Entry No." + 1
        else
            "Entry No." := 1;
    end;
}