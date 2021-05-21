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

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(code; Code)
                {
                    Caption = 'Code';
                }
                field(displayName; Name)
                {
                    Caption = 'Name';
                }
                field(contact; Contact)
                {
                    Caption = 'Contact';
                }
                field(addressLine1; Address)
                {
                    Caption = 'Address Line 1';
                }
                field(addressLine2; "Address 2")
                {
                    Caption = 'Address Line 2';
                }
                field(city; City)
                {
                    Caption = 'City';
                }
                field(state; County)
                {
                    Caption = 'State';
                }
                field(country; "Country/Region Code")
                {
                    Caption = 'Country/Region Code';
                }
                field(postalCode; "Post Code")
                {
                    Caption = 'Post Code';
                }
                field(phoneNumber; "Phone No.")
                {
                    Caption = 'Phone No.';
                }
                field(email; "E-Mail")
                {
                    Caption = 'Email';
                }
                field(website; "Home Page")
                {
                    Caption = 'Website';
                }
            }
        }
    }
}