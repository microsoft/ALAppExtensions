namespace Microsoft.API.V2;

using Microsoft.Inventory.Location;

page 30076 "APIV2 - Locations"
{
    DelayedInsert = true;
    APIVersion = 'v2.0';
    EntityCaption = 'Location';
    EntitySetCaption = 'Locations';
    PageType = API;
    ODataKeyFields = SystemId;
    EntityName = 'location';
    EntitySetName = 'locations';
    SourceTable = Location;
    Extensible = false;
    AboutText = 'Exposes warehouse and inventory location master data including codes, addresses, contact details, and operational settings. Supports full CRUD operations to synchronize fulfillment nodes, manage routing rules, and integrate external WMS or e-commerce platforms with Business Central, ensuring all inventory movements and documents reference valid locations.';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(code; Rec.Code)
                {
                    Caption = 'Code';
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'Name';
                }
                field(contact; Rec.Contact)
                {
                    Caption = 'Contact';
                }
                field(addressLine1; Rec.Address)
                {
                    Caption = 'Address Line 1';
                }
                field(addressLine2; Rec."Address 2")
                {
                    Caption = 'Address Line 2';
                }
                field(city; Rec.City)
                {
                    Caption = 'City';
                }
                field(state; Rec.County)
                {
                    Caption = 'State';
                }
                field(country; Rec."Country/Region Code")
                {
                    Caption = 'Country/Region Code';
                }
                field(postalCode; Rec."Post Code")
                {
                    Caption = 'Post Code';
                }
                field(phoneNumber; Rec."Phone No.")
                {
                    Caption = 'Phone No.';
                }
                field(email; Rec."E-Mail")
                {
                    Caption = 'Email';
                }
                field(website; Rec."Home Page")
                {
                    Caption = 'Website';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
            }
        }
    }
}