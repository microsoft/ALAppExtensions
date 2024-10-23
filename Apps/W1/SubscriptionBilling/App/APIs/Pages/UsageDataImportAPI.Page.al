namespace Microsoft.SubscriptionBilling;

page 8040 "Usage Data Import API"
{
    APIGroup = 'subsBilling';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    ModifyAllowed = false;
    InsertAllowed = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityName = 'usageDataImport';
    EntitySetName = 'usageDataImports';
    PageType = API;
    SourceTable = "Usage Data Import";
    ODataKeyFields = SystemId;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(systemId; Rec.SystemId) { }
                field(systemModifiedAt; Rec.SystemModifiedAt) { }
                field(supplierNo; Rec."Supplier No.") { }
                part(UsageDataGenericImportAPI; "Usage Data Generic Import API")
                {
                    Caption = 'usageDataGenericImport', Locked = true;
                    EntityName = 'usageDataGenericImport';
                    EntitySetName = 'usageDataGenericImports';
                    SubPageLink = "Usage Data Import Entry No." = field("Entry No.");
                }
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Insert(true);
    end;
}
