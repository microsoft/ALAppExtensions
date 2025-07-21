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
                field("Company SystemId"; Rec."Company SystemId")
                {
                    Visible = false;
                }
                field(Name; Rec.Name) { }
                field("Company Name"; Rec."Company Name") { }
                field("Default"; Rec."Default") { }
                field(Address; Rec.Address) { }
                field("Address 2"; Rec."Address 2") { }
                field(Zip; Rec.Zip) { }
                field(City; Rec.City) { }
                field("Country/Region Code"; Rec."Country/Region Code") { }
                field("Phone No."; Rec."Phone No.") { }
                field("Province Code"; Rec."Province Code") { }
                field("Province Name"; Rec."Province Name") { }
                field(Recipient; Rec.Recipient) { }
                field("Tax Registration Id"; Rec."Tax Registration Id") { }
                field("Shpfy Payment Terms Id"; Rec."Shpfy Payment Terms Id")
                {
                    Visible = false;
                }
                field("Shpfy Payment Term"; Rec."Shpfy Payment Term") { }
            }
        }
    }
}