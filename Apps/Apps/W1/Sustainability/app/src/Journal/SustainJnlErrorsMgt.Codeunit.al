namespace Microsoft.Sustainability.Journal;

using Microsoft.Utilities;
using System.Utilities;
using Microsoft.Sustainability.Setup;

codeunit 6220 "Sustain. Jnl. Errors Mgt."
{
    Access = Internal;
    SingleInstance = true;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        TempDeletedSustJnlLine, TempSustJnlLineBeforeModify, TempSustJnlLineAfterModify : Record "Sustainability Jnl. Line" temporary;
        FullBatchCheck, SustainabilitySetupRetrieved : Boolean;

    procedure CollectSustJnlCheckParameters(SustainabilityJnlLine: Record "Sustainability Jnl. Line"; var ErrorHandlingParameters: Record "Error Handling Parameters")
    var
        TempSustJnlLine, TempxSustJnlLine : Record "Sustainability Jnl. Line" temporary;
    begin
        ErrorHandlingParameters."Journal Template Name" := SustainabilityJnlLine."Journal Template Name";
        ErrorHandlingParameters."Journal Batch Name" := SustainabilityJnlLine."Journal Batch Name";
        ErrorHandlingParameters."Full Batch Check" := GetFullBatchCheck();
        ErrorHandlingParameters."Line Modified" := GetRecXRecOnModify(TempxSustJnlLine, TempSustJnlLine);
        ErrorHandlingParameters."Line No." := TempSustJnlLine."Line No.";
    end;

    procedure GetErrorsFromSustJnlCheckResultValues(ResultValues: List of [Text]; var TempErrorMsg: Record "Error Message" temporary; ErrorHandlingParameters: Record "Error Handling Parameters")
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        TempSustainabilityJnlLine: Record "Sustainability Jnl. Line" temporary;
        ErrorMessageMgt: Codeunit "Error Message Management";
    begin
        TempErrorMsg.Reset();
        if ErrorHandlingParameters."Full Batch Check" then
            TempErrorMsg.DeleteAll()
        else begin
            if GetDeletedSustJnlLine(TempSustainabilityJnlLine, true) then
                if TempSustainabilityJnlLine.FindSet() then
                    repeat
                        TempErrorMsg.SetRange("Context Record ID", TempSustainabilityJnlLine.RecordId);
                        TempErrorMsg.DeleteAll();
                    until TempSustainabilityJnlLine.Next() = 0;

            TempErrorMsg.Reset();
            if ErrorHandlingParameters."Line Modified" then
                if SustainabilityJnlLine.Get(ErrorHandlingParameters."Journal Template Name", ErrorHandlingParameters."Journal Batch Name", ErrorHandlingParameters."Line No.") then begin
                    TempErrorMsg.SetRange("Context Record ID", SustainabilityJnlLine.RecordId());
                    TempErrorMsg.DeleteAll();
                end;
        end;

        ErrorMessageMgt.GetErrorsFromResultValues(ResultValues, TempErrorMsg);

        if ErrorHandlingParameters."Full Batch Check" then
            SetFullBatchCheck(false);
    end;

    procedure SetRecXRecOnModify(xRec: Record "Sustainability Jnl. Line"; Rec: Record "Sustainability Jnl. Line")
    begin
        if BackgroundCheckEnabled() then begin
            SaveJournalLineToBuffer(xRec, TempSustJnlLineBeforeModify);
            SaveJournalLineToBuffer(Rec, TempSustJnlLineAfterModify);
        end;
    end;

    local procedure SaveJournalLineToBuffer(SustainabilityJournalLine: Record "Sustainability Jnl. Line"; var BufferLine: Record "Sustainability Jnl. Line" temporary)
    begin
        if BufferLine.Get(SustainabilityJournalLine."Journal Template Name", SustainabilityJournalLine."Journal Batch Name", SustainabilityJournalLine."Line No.") then begin
            BufferLine.TransferFields(SustainabilityJournalLine);
            BufferLine.Modify();
        end else begin
            BufferLine := SustainabilityJournalLine;
            BufferLine.Insert();
        end;
    end;

    procedure GetRecXRecOnModify(var xRec: Record "Sustainability Jnl. Line"; var Rec: Record "Sustainability Jnl. Line"): Boolean
    begin
        if TempSustJnlLineAfterModify.FindFirst() then begin
            xRec := TempSustJnlLineBeforeModify;
            Rec := TempSustJnlLineAfterModify;

            if TempSustJnlLineBeforeModify.Delete() then;
            if TempSustJnlLineAfterModify.Delete() then;
            exit(true);
        end;

        exit(false);
    end;

    procedure SetFullBatchCheck(NewFullBatchCheck: Boolean)
    begin
        FullBatchCheck := NewFullBatchCheck;
    end;

    procedure GetFullBatchCheck(): Boolean
    begin
        exit(FullBatchCheck);
    end;

    procedure GetDeletedSustJnlLine(var TempSustJnlLine: Record "Sustainability Jnl. Line" temporary; ClearBuffer: Boolean): Boolean
    begin
        if TempDeletedSustJnlLine.FindSet() then begin
            repeat
                TempSustJnlLine := TempDeletedSustJnlLine;
                TempSustJnlLine.Insert();
            until TempDeletedSustJnlLine.Next() = 0;

            if ClearBuffer then
                TempDeletedSustJnlLine.DeleteAll();
            exit(true);
        end;

        exit(false);
    end;

    procedure InsertDeletedLine(SustJnlLine: Record "Sustainability Jnl. Line")
    begin
        if BackgroundCheckEnabled() then begin
            TempDeletedSustJnlLine := SustJnlLine;
            if TempDeletedSustJnlLine.Insert() then;
        end;
    end;

    procedure BackgroundCheckEnabled(): Boolean
    begin
        if not SustainabilitySetupRetrieved then begin
            SustainabilitySetup.Get();
            SustainabilitySetupRetrieved := true;
        end;

        exit(SustainabilitySetup."Enable Background Error Check");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sustainability Journal", 'OnDeleteRecordEvent', '', false, false)]
    local procedure OnDeleteRecordEventSustainabilityJournal(var Rec: Record "Sustainability Jnl. Line"; var AllowDelete: Boolean)
    begin
        InsertDeletedLine(Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sustainability Journal", 'OnModifyRecordEvent', '', false, false)]
    local procedure OnModifyRecordEventSustainabilityJournal(var Rec: Record "Sustainability Jnl. Line"; var xRec: Record "Sustainability Jnl. Line"; var AllowModify: Boolean)
    begin
        SetRecXRecOnModify(xRec, Rec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sustainability Journal", 'OnInsertRecordEvent', '', false, false)]
    local procedure OnInsertRecordEventSustainabilityJournal(var Rec: Record "Sustainability Jnl. Line"; var xRec: Record "Sustainability Jnl. Line"; var AllowInsert: Boolean)
    begin
        SetRecXRecOnModify(xRec, Rec);
    end;
}