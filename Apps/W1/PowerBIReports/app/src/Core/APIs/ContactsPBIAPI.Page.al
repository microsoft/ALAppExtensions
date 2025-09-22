// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.PowerBIReports;

using Microsoft.CRM.Contact;

page 36966 "Contacts - PBI API"
{
    PageType = API;
    Caption = 'Power BI Contacts';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
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
