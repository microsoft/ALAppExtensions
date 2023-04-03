reportextension 31003 "Open Cust. Entries to Date CZZ" extends "Open Cust. Entries to Date CZL"
{
    dataset
    {
        modify("Cust. Ledger Entry")
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