namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Company Locations (ID 30165).
/// </summary>
page 30165 "Shpfy Comp. Locations"
{
    ApplicationArea = All;
    Caption = 'Shopify Company Locations';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Shpfy Company Location";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Id; Rec.Id) { }
                field("Company SystemId"; Rec."Company SystemId") { }
                field("Default"; Rec."Default") { }
                field(Address; Rec.Address) { }
                field("Address 2"; Rec."Address 2") { }
                field(Zip; Rec.Zip) { }
                field(City; Rec.City) { }
                field("Country/Region Code"; Rec."Country/Region Code") { }
                field("Phone No."; Rec."Phone No.") { }
                field(Name; Rec.Name) { }
                field("Province Code"; Rec."Province Code") { }
                field("Province Name"; Rec."Province Name") { }
                field("Tax Registration Id"; Rec."Tax Registration Id") { }
                field("Shpfy Payment Terms Id"; Rec."Shpfy Payment Terms Id") { }
            }
        }
    }
}