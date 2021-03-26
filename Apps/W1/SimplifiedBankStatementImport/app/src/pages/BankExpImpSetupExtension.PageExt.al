pageextension 8851 "Bank Exp. Imp. Setup Extension" extends "Bank Export/Import Setup"
{
    actions
    {
        addfirst(Processing)
        {
            action("Bank Statement File Format Wizard")
            {
                ApplicationArea = All;
                ToolTip = 'Start the Bank Statement File Setup wizard to set up a bank statement file import format.';
                Image = Setup;

                trigger OnAction()
                begin
                    Page.Run(Page::"Bank Statement File Wizard");
                end;
            }
        }
    }
}