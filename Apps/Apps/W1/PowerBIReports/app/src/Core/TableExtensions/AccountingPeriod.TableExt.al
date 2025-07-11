namespace Microsoft.PowerBIReports;

using Microsoft.Foundation.Period;

tableextension 36950 "Accounting Period" extends "Accounting Period"
{
    fields
    {
        modify("Starting Date")
        {
            trigger OnAfterValidate()
            var
                PBISetup: Record "PowerBI Reports Setup";
            begin
                if PBISetup.Get() then begin
                    if "Starting Date" < PBISetup."Date Table Starting Date" then
                        PBISetup."Date Table Starting Date" := "Starting Date";
                    if "Starting Date" > PBISetup."Date Table Ending Date" then
                        PBISetup."Date Table Ending Date" := "Starting Date";
                    if PBISetup.WritePermission() then
                        PBISetup.Modify();
                end;
            end;
        }
    }
}