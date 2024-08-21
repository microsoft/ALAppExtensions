namespace Microsoft.Sustainability.Emission;

using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Posting;

report 6213 "Batch Update Carbon Emission"
{
    Caption = 'Batch Update Carbon Emission';
    UsageCategory = Tasks;
    ApplicationArea = Basic, Suite;
    ProcessingOnly = true;
    Permissions = tabledata "Sustainability Ledger Entry" = ri;

    dataset
    {
        dataitem("Sustainability Ledger Entry"; "Sustainability Ledger Entry")
        {
            RequestFilterFields = "Posting Date", "Account No.", "Account Category";

            trigger OnAfterGetRecord()
            var
                SustLedgEntry: Record "Sustainability Ledger Entry";
                Counter: Integer;
                CommitCounter: Integer;
            begin
                SustLedgEntry.CopyFilters("Sustainability Ledger Entry");
                SustLedgEntry.SetFilter("Carbon Fee", '%1', 0);
                if SustLedgEntry.FindSet() then begin
                    OpenDialog(SustLedgEntry, RecordCount);

                    repeat
                        UpdateCarbonEmission(SustLedgEntry);
                        UpdateDialog(CommitCounter, Counter);

                        TryCommitRecord(CommitCounter);
                    until SustLedgEntry.Next() = 0;

                    CloseDialog();
                end;

                ShowCompletionMsg(RecordCount, Counter);
                CurrReport.Break();
            end;
        }
    }

    local procedure TryCommitRecord(var CommitCounter: Integer)
    begin
        if CommitCounter = 1000 then begin
            Commit();
            CommitCounter := 0;
        end;
    end;

    local procedure UpdateDialog(var CommitCounter: Integer; var Counter: Integer)
    begin
        CommitCounter += 1;

        if not GuiAllowed then
            exit;

        Counter += 1;
        Window.Update(1, Round(Counter / RecordCount * 10000, 1));
    end;

    local procedure OpenDialog(var SustLedgEntry: Record "Sustainability Ledger Entry"; var RecordCount: Integer)
    begin
        if not GuiAllowed() then
            exit;

        RecordCount := SustLedgEntry.Count();
        Window.Open(ProcessBarMsg);
    end;

    local procedure CloseDialog()
    begin
        if not GuiAllowed() then
            exit;

        Window.Close();
    end;

    local procedure ShowCompletionMsg(RecordCount: Integer; Counter: Integer)
    begin
        if not GuiAllowed() then
            exit;

        Message(StrSubstNo(UpdateCompleteMsg, Counter, RecordCount));
    end;

    local procedure UpdateCarbonEmission(var NewSustLedgEntry: Record "Sustainability Ledger Entry")
    var
        SustainabilityPostMgmt: Codeunit "Sustainability Post Mgt";
    begin
        SustainabilityPostMgmt.UpdateCarbonFeeEmission(NewSustLedgEntry);
        NewSustLedgEntry.Modify(true);
    end;

    var
        Window: Dialog;
        ProcessBarMsg: Label 'Processing: @1@@@@@@@', Comment = '1 - overall progress';
        UpdateCompleteMsg: Label 'Carbon Fee Emission updated on %1 out of %2 entries.', Comment = '%1 - Records Updated, %2 - Total Record Count';
        RecordCount: Integer;
}