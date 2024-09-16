page 8050 "Sales Person API"
{
    APIGroup = 'subsBilling';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    EntityName = 'salesperson';
    EntitySetName = 'salesperson';
    PageType = API;
    SourceTable = "Salesperson/Purchaser";
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(systemId; Rec.SystemId)
                {
                }
                field(code; Rec."Code")
                {
                }
                field(name; Rec.Name)
                {
                }
            }
        }
    }
}
