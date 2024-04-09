namespace Microsoft.Sustainability.Journal;

using System.Utilities;
using Microsoft.Utilities;
using Microsoft.Sustainability.Posting;

page 6226 "Sustain. Jnl. Errors Factbox"
{
    PageType = ListPart;
    Caption = 'Journal Check';
    Editable = false;
    LinksAllowed = false;
    SourceTable = "Sustainability Jnl. Line";

    layout
    {
        area(content)
        {
            cuegroup(Control1)
            {
                ShowCaption = false;
                field(NumberOfLinesChecked; NumberOfLines)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Lines checked';
                    ToolTip = 'Specifies the number of journal lines that have been checked for potential issues.';
                }
                field(NumberOfLinesWithErrors; NumberOfLinesWithErrors)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Lines with issues';
                    ToolTip = 'Specifies the number of journal lines that have issues.';
                }
                field(NumberOfBatchErrors; NumberOfBatchErrors)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Issues Total';
                    ToolTip = 'Specifies the number of issues that have been found in the journal.';
                    StyleExpr = TotalErrorsStyleTxt;

                    trigger OnDrillDown()
                    begin
                        TempErrorMessage.Reset();
                        TempErrorMessage.SetRange(Duplicate, false);
                        Page.Run(Page::"Error Messages", TempErrorMessage);
                    end;
                }
            }
            field(Refresh; RefreshTxt)
            {
                ApplicationArea = Basic, Suite;
                ShowCaption = false;
                trigger OnDrillDown()
                begin
                    if SustainJnlErrorsMgt.BackgroundCheckEnabled() then begin
                        SustainJnlErrorsMgt.SetFullBatchCheck(true);
                        CheckErrorsInBackground();
                    end;
                end;
            }
            group(Control2)
            {
                Caption = 'Current line';
                field(Error1; ErrText[1])
                {
                    ShowCaption = false;
                    ApplicationArea = Basic, Suite;
                    StyleExpr = CurrentLineStyleTxt;
                }
                field(Error2; ErrText[2])
                {
                    ShowCaption = false;
                    ApplicationArea = Basic, Suite;
                    StyleExpr = CurrentLineStyleTxt;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if SustainJnlErrorsMgt.BackgroundCheckEnabled() then begin
            SustainJnlErrorsMgt.SetFullBatchCheck(true);
            CheckErrorsInBackground();
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if SustainJnlErrorsMgt.BackgroundCheckEnabled() then
            CheckErrorsInBackground();
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    begin
        if TaskId = TaskIdCountErrors then begin
            SustainJnlErrorsMgt.GetErrorsFromSustJnlCheckResultValues(Results.Values, TempErrorMessage, ErrorHandlingParameters);
            CalcErrors();
            NumberOfLines := GetNumberOfLines();
        end;
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    begin
        if TaskId = TaskIdCountErrors then
            IsHandled := true;
    end;

    var
        TempErrorMessage: Record "Error Message" temporary;
        ErrorHandlingParameters: Record "Error Handling Parameters";
        SustainJnlErrorsMgt: Codeunit "Sustain. Jnl. Errors Mgt.";
        TaskIdCountErrors, NumberOfBatchErrors, NumberOfLineErrors, NumberOfLines, NumberOfLinesWithErrors : Integer;
        TotalErrorsStyleTxt, CurrentLineStyleTxt : Text;
        ErrText: array[2] of Text;
        OtherIssuesTxt: Label '(+%1 other issues)', comment = '%1 - number of issues';
        NoIssuesFoundTxt: Label 'No issues found.';
        RefreshTxt: Label 'Refresh';

    local procedure GetTotalErrorsStyle(): Text
    begin
        if NumberOfBatchErrors = 0 then
            exit('Favorable')
        else
            exit('Unfavorable');
    end;

    local procedure GetCurrentLineStyle(): Text
    begin
        if NumberOfLineErrors = 0 then
            exit('Standard')
        else
            exit('Attention');
    end;

    local procedure GetNumberOfLines(): Integer
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
    begin
        SustainabilityJnlLine.SetRange("Journal Template Name", Rec."Journal Template Name");
        SustainabilityJnlLine.SetRange("Journal Batch Name", Rec."Journal Batch Name");
        exit(SustainabilityJnlLine.Count());
    end;

    local procedure CheckErrorsInBackground()
    var
        TempSustainabilityJnlLine: Record "Sustainability Jnl. Line" temporary;
        Args: Dictionary of [Text, Text];
    begin
        if TaskIdCountErrors <> 0 then
            CurrPage.CancelBackgroundTask(TaskIdCountErrors);

        SustainJnlErrorsMgt.CollectSustJnlCheckParameters(Rec, ErrorHandlingParameters);
        ErrorHandlingParameters.ToArgs(Args);

        if SustainJnlErrorsMgt.GetDeletedSustJnlLine(TempSustainabilityJnlLine, false) then begin
            TempSustainabilityJnlLine.FindSet();
            repeat
                Args.Add(Format(TempSustainabilityJnlLine."Line No."), DeletedDocumentToJson(TempSustainabilityJnlLine));
            until TempSustainabilityJnlLine.Next() = 0;
        end;

        CurrPage.EnqueueBackgroundTask(TaskIdCountErrors, Codeunit::"Check Sust. Jnl. Line. Backgr.", Args);
    end;

    local procedure CalcErrors()
    var
        NumberOfErrors: Integer;
    begin
        TempErrorMessage.Reset();
        TempErrorMessage.SetRange(Duplicate, false);
        NumberOfBatchErrors := TempErrorMessage.Count();
        TempErrorMessage.SetRange(Duplicate);
        TempErrorMessage.SetRange("Context Record ID", Rec.RecordId);
        NumberOfLineErrors := TempErrorMessage.Count();

        Clear(ErrText);
        NumberOfErrors := TempErrorMessage.Count();
        if TempErrorMessage.FindFirst() then
            ErrText[1] := TempErrorMessage."Message"
        else
            ErrText[1] := NoIssuesFoundTxt;

        if NumberOfErrors > 2 then
            ErrText[2] := StrSubstNo(OtherIssuesTxt, NumberOfErrors - 1)
        else
            if TempErrorMessage.Next() <> 0 then
                ErrText[2] := TempErrorMessage."Message";

        TotalErrorsStyleTxt := GetTotalErrorsStyle();
        CurrentLineStyleTxt := GetCurrentLineStyle();
        NumberOfLinesWithErrors := GetNumberOfLinesWithErrors();
    end;

    local procedure GetNumberOfLinesWithErrors(): Integer
    var
        TempLineErrorMessage: Record "Error Message" temporary;
    begin
        TempErrorMessage.Reset();
        if TempErrorMessage.FindSet() then
            repeat
                TempLineErrorMessage.SetRange("Context Record ID", TempErrorMessage."Context Record ID");
                if TempLineErrorMessage.IsEmpty() then begin
                    TempLineErrorMessage := TempErrorMessage;
                    TempLineErrorMessage.Insert();
                end;
            until TempErrorMessage.Next() = 0;

        TempLineErrorMessage.Reset();
        exit(TempLineErrorMessage.Count());
    end;

    local procedure DeletedDocumentToJson(TempSustainabilityJnlLine: Record "Sustainability Jnl. Line" temporary) JSON: Text
    var
        JObject: JsonObject;
    begin
        JObject.Add(TempSustainabilityJnlLine.FieldName("Line No."), TempSustainabilityJnlLine."Line No.");
        JObject.WriteTo(JSON);
    end;
}