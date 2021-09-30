reportextension 13601 CancelFALedgerEntriesExt extends "Cancel FA Ledger Entries"
{
    requestpage
    {
        layout
        {
            modify("CancelChoices[5]")
            {
                Visible = false;
            }

            modify("CancelChoices[6]")
            {
                Visible = false;
            }
        }
    }
}