// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

page 42000 "SL Account StagingTable"
{
    ApplicationArea = All;
    Caption = 'Account Table';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    PromotedActionCategories = 'Related Entities';
    SourceTable = "SL Account Staging";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(AcctNum; Rec.AcctNum) { ToolTip = 'Account Number'; }
                field(Name; Rec.Name) { ToolTip = 'Name'; }
                field(SearchName; Rec.SearchName) { ToolTip = 'Search Name'; }
                field(AccountCategory; Rec.AccountCategory) { ToolTip = 'Account Category'; }
                field(IncomeBalance; Rec.IncomeBalance) { ToolTip = 'IncomeBalance'; }
                field(DebitCredit; Rec.DebitCredit) { ToolTip = 'DebitCredit'; }
                field(Active; Rec.Active) { ToolTip = 'Active'; }
            }
        }
    }
}