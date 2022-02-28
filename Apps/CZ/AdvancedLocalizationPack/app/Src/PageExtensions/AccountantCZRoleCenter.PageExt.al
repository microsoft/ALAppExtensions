pageextension 31201 "Accountant CZ Role Center CZA" extends "Accountant CZ Role Center CZL"
{
    actions
    {
        addbefore("Create Reminders")
        {
            action("Apply G/L Entries CZA")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Apply G/L Entries';
                Ellipsis = true;
                Image = ApplicationWorksheet;
                RunObject = Page "Apply G/L Entries CZA";
                ToolTip = 'Handle application of G/L entries.';
            }
        }
        addlast("General Ledger Reports")
        {
            action("Inventory Account to Date CZA")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Inventory Account to Date';
                Ellipsis = true;
                Image = Report;
                RunObject = Report "Inventory Account to Date CZA";
                ToolTip = 'View, print, or send the inventory account to date report.';
            }
            action("Open G/L Entries to Date CZA")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open G/L Entries to Date';
                Ellipsis = true;
                Image = Report;
                RunObject = Report "Open G/L Entries to Date CZA";
                ToolTip = 'View, print, or send the open G/L entries to date report.';
            }
        }
    }
}
