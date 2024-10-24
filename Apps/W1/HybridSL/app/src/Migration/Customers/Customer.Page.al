// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

page 42022 "SL Customer"
{
    ApplicationArea = All;
    Caption = 'Customer Table';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    PromotedActionCategories = 'Related Entities';
    SourceTable = "SL Customer";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(CustId; 'Customer Id') { Caption = 'Customer Number'; ToolTip = 'Customer Number'; }
                field(Name; Rec.Name) { ToolTip = 'Customer Name'; }
                field(BillName; Rec.BillName) { ToolTip = 'Bill Name'; }
                field(Addr1; Rec.Addr1) { ToolTip = 'Address1'; }
                field(Addr2; Rec.Addr2) { ToolTip = 'Address2'; }
                field(City; Rec.City) { ToolTip = 'City'; }
                field(Attn; Rec.Attn) { ToolTip = 'Contact Person'; }
                field(Phone; Rec.Phone) { ToolTip = 'Phone'; }
                field(Territory; Rec.Territory) { ToolTip = 'Sales Territory'; }
                field(CrLmt; Rec.CrLmt) { ToolTip = 'Credit Limit Amount'; }
                field(Terms; Rec.Terms) { ToolTip = 'Payment Terms'; }
                field(SlsperId; Rec.SlsperId) { ToolTip = 'Salesperson Id'; }
                field(Country; Rec.Country) { ToolTip = 'Country'; }
                field(Zip; Rec.Zip) { ToolTip = 'Zip'; }
                field(State; Rec.State) { ToolTip = 'State'; }
                field(TaxRegNbr; Rec.TaxRegNbr) { ToolTip = 'Tax Registration Number'; }
            }
        }
    }
}