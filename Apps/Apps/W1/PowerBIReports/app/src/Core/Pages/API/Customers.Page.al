namespace Microsoft.PowerBIReports;

using Microsoft.Sales.Customer;

page 36954 Customers
{
    PageType = API;
    Caption = 'Power BI Customers';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'customer';
    EntitySetName = 'customers';
    SourceTable = Customer;
    DelayedInsert = true;
    DataAccessIntent = ReadOnly;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(customerNo; Rec."No.")
                {
                }
                field(customerName; Rec.Name)
                {
                }
                field(address; Rec.Address)
                {
                }
                field(address2; Rec."Address 2")
                {
                }
                field(city; Rec.City)
                {
                }
                field(postCode; Rec."Post Code")
                {
                }
                field(county; Rec.County)
                {
                }
                field(countryRegionCode; Rec."Country/Region Code")
                {
                }
                field(customerPostingGroup; Rec."Customer Posting Group")
                {
                }
                field(customerPriceGroup; Rec."Customer Price Group")
                {
                }
                field(customerDiscGroup; Rec."Customer Disc. Group")
                {
                }
            }
        }
    }
}
