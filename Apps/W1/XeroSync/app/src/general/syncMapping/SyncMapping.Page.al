page 2401 "XS Sync Mapping"
{
    Caption = 'Sync Mapping';
    PageType = List;
    SourceTable = "Sync Mapping";
    Editable = false;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(GroupName)
            {
                field("External Id"; "External Id")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Internal ID"; format("Internal ID"))
                {
                    ApplicationArea = Basic, Suite;
                }
                field("NAV Data"; NAVData)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Xero Json Response"; XeroData)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Handler; Handler)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Last Synced Internal"; "Last Synced Internal")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Last Synced Xero"; "XS Last Synced Xero")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("NAV Entity ID"; "XS NAV Entity ID")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Active; "XS Active")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }

    var
        NAVData: Text;
        XeroData: Text;

    trigger OnAfterGetRecord()
    var
        JsonObjectHelper: Codeunit "XS Json Object Helper";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        NAVData := JsonObjectHelper.GetBLOBDataAsText(RecRef, Rec.FieldNo(Rec."XS NAV Data"));
        XeroData := JsonObjectHelper.GetBLOBDataAsText(RecRef, Rec.FieldNo(Rec."XS Xero Json Response"));
    end;
}