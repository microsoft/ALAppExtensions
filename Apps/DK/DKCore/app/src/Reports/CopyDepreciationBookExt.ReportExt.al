reportextension 13602 CopyDepreciationBookExt extends "Copy Depreciation Book"
{
    requestpage
    {
        layout
        {
            modify("CopyChoices[5]")
            {
                Visible = false;
            }

            modify("CopyChoices[6]")
            {
                Visible = false;
            }
        }
    }

    var
        CancelFALedgEntries: Codeunit "Cancel FA Ledger Entries";
}