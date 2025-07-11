namespace Microsoft.Intercompany.CrossEnvironment;

using Microsoft.Intercompany.Dimension;

page 30402 "API - IC Dimensions"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'intercompany';
    APIVersion = 'v1.0';
    EntityName = 'intercompanyDimension';
    EntitySetName = 'intercompanyDimensions';
    EntityCaption = 'Intercompany Dimension';
    EntitySetCaption = 'Intercompany Dimensions';
    SourceTable = "IC Dimension";
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ODataKeyFields = SystemId;
    Extensible = false;
    Editable = false;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            field(id; Rec.SystemId)
            {
                Caption = 'Id';
            }
            field(code; Rec.Code)
            {
                Caption = 'Code';
            }
            field(name; Rec.Name)
            {
                Caption = 'Name';
            }
            field(blocked; Rec.Blocked)
            {
                Caption = 'Blocked';
            }
        }
    }
}