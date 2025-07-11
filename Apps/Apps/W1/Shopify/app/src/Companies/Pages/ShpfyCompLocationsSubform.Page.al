namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Comp. Locations Subform (ID 30170).
/// </summary>
page 30170 "Shpfy Comp. Locations Subform"
{
    ApplicationArea = All;
    Caption = 'Locations';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Shpfy Company Location";
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name) { }
                field("Default"; Rec."Default") { }
                field("Tax Registration Id"; Rec."Tax Registration Id") { }
            }
        }
    }
}