namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

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
                field(Id; Rec.Id)
                {
                    ToolTip = 'Specifies the unique identifier for the company location in Shopify.';
                }
                field("Company SystemId"; Rec."Company SystemId")
                {
                    ToolTip = 'Specifies the unique identifier for the company in Shopify.';
                }
                field("Default"; Rec."Default")
                {
                    ToolTip = 'Specifies whether the location is the default location for the company.';
                }
                field(Address; Rec.Address)
                {
                    ToolTip = 'Specifies the address of the company location.';
                }
                field("Address 2"; Rec."Address 2")
                {
                    ToolTip = 'Specifies the second address line of the company location.';
                }
                field(Zip; Rec.Zip)
                {
                    ToolTip = 'Specifies the postal code of the company location.';
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the city of the company location.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ToolTip = 'Specifies the country/region code of the company location.';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ToolTip = 'Specifies the phone number of the company location.';
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the company location.';
                }
                field("Province Code"; Rec."Province Code")
                {
                    ToolTip = 'Specifies the province code of the company location.';
                }
                field("Province Name"; Rec."Province Name")
                {
                    ToolTip = 'Specifies the province name of the company location.';
                }
                field("Tax Registration Id"; Rec."Tax Registration Id")
                {
                    ToolTip = 'Specifies the tax registration identifier of the company location.';
                }
                field("Shpfy Payment Terms Id"; Rec."Shpfy Payment Terms Id")
                {
                    ToolTip = 'Specifies the Shopify Payment Terms Id which is mapped with Customer''s Payment Terms.';
                }
            }
        }
    }

}
