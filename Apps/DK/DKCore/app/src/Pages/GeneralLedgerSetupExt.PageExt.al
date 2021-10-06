pageextension 13602 GeneralLedgerSetupExt extends "General Ledger Setup"
{
    layout
    {

        modify("Tax Invoice Renaming Threshold")
        {
            Visible = false;
        }

        modify("Payroll Transaction Import")
        {
            Visible = true;
        }

        modify("Payroll Trans. Import Format")
        {
            Visible = true;
        }
    }
}