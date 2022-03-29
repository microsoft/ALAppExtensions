page 40024 "Cloud Mig Product Type API"
{
    PageType = API;
    SourceTable = "Hybrid Product Type";
    APIGroup = 'cloudMigration';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    EntityCaption = 'Source Product Type';
    EntitySetCaption = 'Source Product Types';
    EntitySetName = 'sourceProductTypes';
    EntityName = 'sourceProductType';
    DelayedInsert = true;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;
    ODataKeyFields = "ID";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec."ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'id';
                }

                field(displayName; Rec."Display Name")
                {
                    ApplicationArea = All;
                    Caption = 'displayName';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        HybridCloudManagement.OnGetHybridProductType(Rec);
    end;
}