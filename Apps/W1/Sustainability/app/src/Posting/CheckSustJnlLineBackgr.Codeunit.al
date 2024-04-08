namespace Microsoft.Sustainability.Posting;

using Microsoft.Utilities;
using System.Utilities;
using Microsoft.Sustainability.Journal;

codeunit 6221 "Check Sust. Jnl. Line. Backgr."
{
    Access = Internal;
    trigger OnRun()
    var
        TempErrorMessage: Record "Error Message" temporary;
    begin
        RunCheck(Page.GetBackgroundParameters(), TempErrorMessage);
        Page.SetBackgroundTaskResult(PackErrorMessagesToResults(TempErrorMessage));
    end;

    local procedure RunCheck(Args: Dictionary of [Text, Text]; var TempErrorMessage: Record "Error Message" temporary)
    var
        ErrorHandlingParameters: Record "Error Handling Parameters";
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainabilityJnlCheck: Codeunit "Sustainability Jnl.-Check";
    begin
        ErrorHandlingParameters.FromArgs(Args);

        SustainabilityJnlLine.SetRange("Journal Template Name", ErrorHandlingParameters."Journal Template Name");
        SustainabilityJnlLine.SetRange("Journal Batch Name", ErrorHandlingParameters."Journal Batch Name");
        if ErrorHandlingParameters."Full Batch Check" then
            SustainabilityJnlCheck.CheckAllJournalLinesWithErrorCollect(SustainabilityJnlLine, TempErrorMessage)
        else
            if ErrorHandlingParameters."Line Modified" then begin
                SustainabilityJnlLine.SetRange("Line No.", ErrorHandlingParameters."Line No.");
                if SustainabilityJnlLine.FindFirst() then
                    SustainabilityJnlCheck.CheckSustainabilityJournalLineWithErrorCollect(SustainabilityJnlLine, TempErrorMessage);
            end;
    end;

    local procedure PackErrorMessagesToResults(var TempErrorMessage: Record "Error Message" temporary) Results: Dictionary of [Text, Text]
    var
        ErrorMessageMgt: Codeunit "Error Message Management";
    begin
        if TempErrorMessage.FindSet() then
            repeat
                Results.Add(Format(TempErrorMessage.ID), ErrorMessageMgt.ErrorMessage2JSON(TempErrorMessage));
            until TempErrorMessage.Next() = 0;
    end;
}