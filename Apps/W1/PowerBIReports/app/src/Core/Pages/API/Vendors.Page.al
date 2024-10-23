namespace Microsoft.PowerBIReports;

using Microsoft.Purchases.Vendor;

page 36959 Vendors
{
    PageType = API;
    // IMPORTANT: do not change the caption - see slice 546954
    Caption = 'Vendors', Comment = 'Only for RU: Use the same translation as the "Vendors" page in BaseApp.';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'vendor';
    EntitySetName = 'vendors';
    SourceTable = Vendor;
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
                field(vendorNo; Rec."No.")
                {
                }
                field(vendorName; Rec.Name)
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
                field(vendorPostingGroup; Rec."Vendor Posting Group")
                {
                }
            }
        }
    }
}