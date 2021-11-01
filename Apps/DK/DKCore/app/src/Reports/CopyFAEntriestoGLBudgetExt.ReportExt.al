reportextension 13603 CopyFAEntriestoGLBudgetExt extends "Copy FA Entries to G/L Budget"
{
    requestpage
    {
        layout
        {
            modify("TransferType[5]")
            {
                Visible = false;
            }

            modify("TransferType[6]")
            {
                Visible = false;
            }
        }
    }
}