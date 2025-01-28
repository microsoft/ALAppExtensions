#pragma warning disable AS0072
#if not CLEANSCHEMA25
namespace Microsoft.PowerBIReports;

#pragma warning disable AS0130
#pragma warning disable PTE0025
table 36950 "Dimension Set Entry"
#pragma warning restore AS0130
#pragma warning restore PTE0025
{
    Access = Internal;
    ReplicateData = false;
    // IMPORTANT: do not change the caption - see slice 546954
    Caption = 'Dimension Set Entry', Comment = 'IMPORTANT: Use the same translation as in BaseApp''s table "Dimension Set Entry" id: "Table 3998843106 - Property 2879900210" ';
    ObsoleteReason = 'Replaced by table 36954 "PowerBI Flat Dim. Set. Entry"';
#pragma warning disable AS0115
    ObsoleteState = Removed;
#pragma warning restore AS0115
    ObsoleteTag = '25.0';

    fields
    {
        field(1; "Dimension Set ID"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Value Count"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(3; "Dimension 1 Value Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Dimension 1 Value Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(5; "Dimension 2 Value Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(6; "Dimension 2 Value Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(7; "Dimension 3 Value Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(8; "Dimension 3 Value Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(9; "Dimension 4 Value Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(10; "Dimension 4 Value Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(11; "Dimension 5 Value Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(12; "Dimension 5 Value Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(13; "Dimension 6 Value Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(14; "Dimension 6 Value Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(15; "Dimension 7 Value Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(16; "Dimension 7 Value Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(17; "Dimension 8 Value Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(18; "Dimension 8 Value Name"; Text[50])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Dimension Set ID")
        {
        }
        key(SystemModifiedAtKey; SystemModifiedAt)
        {
        }
    }
}
#endif
#pragma warning restore AS0072