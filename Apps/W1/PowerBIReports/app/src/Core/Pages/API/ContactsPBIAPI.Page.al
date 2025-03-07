namespace Microsoft.PowerBIReports;

using Microsoft.CRM.Contact;

page 36966 "Contacts - PBI API"
{
    PageType = API;
    Caption = 'Power BI Contacts';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'contact';
    EntitySetName = 'contacts';
    SourceTable = Contact;
    DataAccessIntent = ReadOnly;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(contactNo; Rec."No.") { }
                field(contactType; Rec.Type) { }
                field(contactName; Rec.Name) { }
                field(companyNo; Rec."Company No.") { }
                field(companyName; Rec."Company Name") { }
                field(address; Rec.Address) { }
                field(address2; Rec."Address 2") { }
                field(city; Rec.City) { }
                field(postCode; Rec."Post Code") { }
                field(county; Rec.County) { }
                field(countryRegionCode; Rec."Country/Region Code") { }
            }
        }
    }
}
