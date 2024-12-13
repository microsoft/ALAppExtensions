namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.MachineCenter;

pageextension 6257 "Sust. Machine Center List" extends "Machine Center List"
{
    actions
    {
        addafter("Capacity Ledger E&ntries")
        {
            action("Calculate CO2e")
            {
                Caption = 'Calculate CO2e';
                ApplicationArea = Basic, Suite;
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Executes the Calculate CO2e action.';

                trigger OnAction()
                var
                    CalculateCO2e: Report "Sust. Calculate CO2e";
                begin
                    CalculateCO2e.Initialize(1, true);
                    CalculateCO2e.Run();
                end;
            }
        }
    }
}