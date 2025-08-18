// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Company Locations (ID 30165).
/// </summary>
page 30165 "Shpfy Comp. Locations"
{
    ApplicationArea = All;
    Caption = 'Shopify Company Locations';
    InsertAllowed = false;
    DeleteAllowed = false;
    PageType = List;
    SourceTable = "Shpfy Company Location";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Id; Rec.Id) { Editable = false; }
                field("Company SystemId"; Rec."Company SystemId")
                {
                    Editable = false;
                    Visible = false;
                }
                field(Name; Rec.Name) { Editable = false; }
                field("Company Name"; Rec."Company Name") { Editable = false; }
                field("Default"; Rec."Default") { Editable = false; }
                field(Address; Rec.Address) { Editable = false; }
                field("Address 2"; Rec."Address 2") { Editable = false; }
                field(Zip; Rec.Zip) { Editable = false; }
                field(City; Rec.City) { Editable = false; }
                field("Country/Region Code"; Rec."Country/Region Code") { Editable = false; }
                field("Phone No."; Rec."Phone No.") { Editable = false; }
                field("Province Code"; Rec."Province Code") { Editable = false; }
                field("Province Name"; Rec."Province Name") { Editable = false; }
                field(Recipient; Rec.Recipient) { Editable = false; }
                field("Tax Registration Id"; Rec."Tax Registration Id") { Editable = false; }
                field("Shpfy Payment Terms Id"; Rec."Shpfy Payment Terms Id")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Shpfy Payment Term"; Rec."Shpfy Payment Term") { Editable = false; }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.") { }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.") { }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(AddCustomersAsLocations)
            {
                ApplicationArea = All;
                Caption = 'Add Customers as Shopify Locations';
                ToolTip = 'Add existing customers as new Shopify locations for the selected parent company.';
                Image = NewCustomer;

                trigger OnAction()
                var
                    AddCustomerAsLocation: Report "Shpfy Add Cust. As Locations";
                    ParentCompanySystemId: Guid;
                begin
                    Evaluate(ParentCompanySystemId, Rec.GetFilter("Company SystemId"));

                    AddCustomerAsLocation.SetParentCompany(ParentCompanySystemId);
                    AddCustomerAsLocation.Run();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(AddCustomersAsLocations_Promoted; AddCustomersAsLocations) { }
            }
        }
    }
}