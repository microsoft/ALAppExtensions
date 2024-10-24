// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

page 42025 "SL Vendor"
{
    ApplicationArea = All;
    Caption = 'Vendor Table';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    PromotedActionCategories = 'Related Entities';
    SourceTable = "SL Vendor";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(VendId; Rec.VendId) { ToolTip = 'Vendor Number'; }
                field(Name; Rec.Name) { ToolTip = 'Vendor Name'; }
                field(RemitName; Rec.RemitName) { ToolTip = 'Remittance Name'; }
                field(Addr1; Rec.Addr1) { ToolTip = 'Address 1'; }
                field(Addr2; Rec.Addr2) { ToolTip = 'Address 2'; }
                field(City; Rec.City) { ToolTip = 'City'; }
                field(Country; Rec.Country) { ToolTip = 'Country'; }
                field(Zip; Rec.Zip) { ToolTip = 'Zip'; }
                field(Phone; Rec.Phone) { ToolTip = 'Phone'; }
                field(Fax; Rec.Fax) { ToolTip = 'Fax'; }
            }
        }
    }
}