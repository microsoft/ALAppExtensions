// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Payables;

reportextension 31004 "Open Vend. Entries to Date CZZ" extends "Open Vend. Entries to Date CZL"
{
    dataset
    {
        modify("Vendor Ledger Entry")
        {
            trigger OnAfterPreDataItem()
            begin
                case PrintAdvanceEntries of
                    PrintAdvanceEntries::Including:
                        SetRange("Advance Letter No. CZZ");
                    PrintAdvanceEntries::WithoutAdvances:
                        SetRange("Advance Letter No. CZZ", '');
                    PrintAdvanceEntries::OnlyAdvances:
                        SetFilter("Advance Letter No. CZZ", '<>%1', '');
                end;
            end;
        }
    }

    requestpage
    {
        layout
        {
            addafter(SkipBalanceField)
            {
                field(PrintAdvanceEntriesCZZ; PrintAdvanceEntries)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Print Advance Entries';
                    OptionCaption = 'Including,Without Advances,Only Advances';
                    ToolTip = 'Specifies what advance entries will be printed.';
                }
            }
        }
    }

    var
        PrintAdvanceEntries: Option Including,WithoutAdvances,OnlyAdvances;
}
