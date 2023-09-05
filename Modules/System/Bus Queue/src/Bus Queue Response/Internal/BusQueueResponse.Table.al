table 51751 "Bus Queue Response"
{
    Access = Internal;
    Caption = 'Bus Queue Response';
    DrillDownPageId = "Bus Queue Responses";
    LookupPageId = "Bus Queue Responses";
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
        field(2; "Bus Queue Detailed Entry No."; Integer)
        {
            Caption = 'Bus Queue Detailed Entry No.';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(3; "Bus Queue Entry No."; Integer)
        {
            Caption = 'Bus Queue Entry No.';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(4; Headers; Blob)
        {
            Caption = 'Headers';
            DataClassification = SystemMetadata;
        }
        field(6; Body; Blob)
        {
            Caption = 'Body';
            DataClassification = SystemMetadata;
        }
        field(7; "HTTP Code"; Integer)
        {
            Caption = 'HTTP Code';
            DataClassification = SystemMetadata;
        }
        field(8; "Reason Phrase"; Text[40])
        {
            Caption = 'Reason Phrase';
            DataClassification = SystemMetadata;
        }
        field(9; "RecordId"; RecordId)
        {
            Caption = 'RecordId';
            DataClassification = CustomerContent;
        }
        field(10; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(11; "System Id"; Guid)
        {
            Caption = 'System Id';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Bus Queue Detailed Entry No.")
        {
        }
    }

    trigger OnInsert()
    var
        BusQueueResponse: Record "Bus Queue Response";
    begin
        BusQueueResponse.ReadIsolation := IsolationLevel::UpdLock;
        BusQueueResponse.SetLoadFields("Entry No.");
        if BusQueueResponse.FindLast() then
            "Entry No." := BusQueueResponse."Entry No." + 1
        else
            "Entry No." := 1;
    end;
}