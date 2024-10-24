// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

page 42007 "SL Inventory"
{
    ApplicationArea = All;
    Caption = 'Item Table';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    PromotedActionCategories = 'Related Entities';
    SourceTable = "SL Inventory";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(InvtID; Rec.InvtID) { ToolTip = 'Inventory ID'; }
                field(Descr; Rec.Descr) { ToolTip = 'Description'; }
                field(StkUnit; Rec.StkUnit) { ToolTip = 'Base Unit of Measure'; }
                field(ValMthd; Rec.ValMthd) { ToolTip = 'Valuation Method'; }
                field(LastCost; Rec.LastCost) { ToolTip = 'Last Cost'; }
                field(StdCost; Rec.StdCost) { ToolTip = 'Standard Cost'; }
                field(StkBasePrc; Rec.StkBasePrc) { ToolTip = 'Stock Base Price'; }
                field(TranStatusCode; Rec.TranStatusCode) { ToolTip = 'Transaction Status Code'; }
                field(DfltSOUnit; Rec.DfltSOUnit) { ToolTip = 'Default Sales Unit of Measure'; }
                field(DfltPOUnit; Rec.DfltPOUnit) { ToolTip = 'Default Purchase Unit of Measure'; }
                field(LotSerTrack; Rec.LotSerTrack) { ToolTip = 'Lot/Serial Tracked'; }
                field(SerAssign; Rec.SerAssign) { ToolTip = 'Lot/Serial Assignment'; }
                field(LotSerIssMthd; Rec.LotSerIssMthd) { ToolTip = 'Lot/Serial Issue Method'; }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            group(SupportingPages)
            {
                Caption = 'Supporting Pages';

                action(AccountSetup)
                {
                    Caption = 'Posting Accounts';
                    Image = EntriesList;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    RunObject = page "SL Posting Accounts";
                    RunPageMode = Edit;
                    ToolTip = 'SL Posting Accounts';
                }
            }
        }
    }
}