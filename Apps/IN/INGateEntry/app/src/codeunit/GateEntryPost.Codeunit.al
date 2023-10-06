// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

using Microsoft.Finance.TaxBase;
using Microsoft.Foundation.NoSeries;

codeunit 18602 "Gate Entry Post"
{
    TableNo = "Gate Entry Header";

    trigger OnRun()
    begin
        GateEntryHeader := Rec;
        Rec.TestField("Posting Date");
        Rec.TestField("Document Date");
        GateEntryLine.Reset();
        GateEntryLine.SetRange("Entry Type", Rec."Entry Type");
        GateEntryLine.SetRange("Gate Entry No.", Rec."No.");
        if not GateEntryLine.FindFirst() then
            Error(NothingToPostErr);

        if GateEntryLine.FindSet() then
            repeat
                if GateEntryLine."Source Type" <> GateEntryLine."Source Type"::" " then
                    GateEntryLine.TestField("Source No.");
                if GateEntryLine."Source Type" = GateEntryLine."Source Type"::" " then
                    GateEntryLine.TestField(Description);
            until GateEntryLine.Next() = 0;

        if GuiAllowed then
            Window.Open(
              '#1###########################\\' +
              PostingLinesLbl);
        if GuiAllowed then
            Window.Update(1, StrSubstNo(GateEntryNoLbl, GateEntryLbl, Rec."No."));

        if Rec."Posting No. Series" = '' then begin
            Record := Rec;
            PostingNoSeries.GetPostingNoSeriesCode(Record);
            Rec := Record;
            Rec.Modify();
        end;
        if Rec."Posting No." = '' then begin
            Rec."Posting No." := NoSeriesMgt.GetNextNo(Rec."Posting No. Series", Rec."Posting Date", true);
            ModifyHeader := true;
        end;
        if ModifyHeader then
            Rec.Modify();

        GateEntryLine.LockTable();
        PostedGateEntryHeader.Init();
        PostedGateEntryHeader.TransferFields(GateEntryHeader);
        PostedGateEntryHeader."No." := Rec."Posting No.";
        PostedGateEntryHeader."No. Series" := Rec."Posting No. Series";
        PostedGateEntryHeader."Gate Entry No." := Rec."No.";

        if GuiAllowed then
            Window.Update(1, StrSubstNo(GateEntryUpdateLbl, Rec."No.", PostedGateEntryHeader."No."));
        PostedGateEntryHeader.Insert();
        GateEntryHandler.CopyCommentLines(Rec."Entry Type", Rec."Entry Type", Rec."No.", PostedGateEntryHeader."No.");
        GateEntryLine.Reset();
        GateEntryLine.SetRange("Entry Type", Rec."Entry Type");
        GateEntryLine.SetRange("Gate Entry No.", Rec."No.");
        LineCount := 0;
        if GateEntryLine.FindSet() then
            repeat
                LineCount += 1;
                if GuiAllowed then
                    Window.Update(2, LineCount);
                PostedGateEntryLine.Init();
                PostedGateEntryLine.TransferFields(GateEntryLine);
                PostedGateEntryLine."Entry Type" := PostedGateEntryHeader."Entry Type";
                PostedGateEntryLine."Gate Entry No." := PostedGateEntryHeader."No.";
                PostedGateEntryLine.Insert();
            until GateEntryLine.Next() = 0;

        Rec.Delete();
        GateEntryLine.DeleteAll();
        if GuiAllowed then
            Window.Close();
        Rec := GateEntryHeader;
    end;

    var
        GateEntryHeader: Record "Gate Entry Header";
        GateEntryLine: Record "Gate Entry Line";
        PostedGateEntryHeader: Record "Posted Gate Entry Header";
        PostedGateEntryLine: Record "Posted Gate Entry Line";
        PostingNoSeries: Record "Posting No. Series";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        GateEntryHandler: Codeunit "Gate Entry Handler";
        Record: Variant;
        Window: Dialog;
        ModifyHeader: Boolean;
        LineCount: Integer;
        NothingToPostErr: Label 'There is nothing to post.';
        PostingLinesLbl: Label 'Posting Lines #2######\', Comment = '#2 = Open Dialog Window';
        GateEntryLbl: Label 'Gate Entry.';
        GateEntryNoLbl: Label '%1 %2', Comment = '%1 = Gate Entry Caption,%2 = Gate Entry No.';
        GateEntryUpdateLbl: Label 'Gate Entry %1 -> Posted Gate Entry %2.', Comment = '%1 = No., %2 =  PostedGateEntryHeader.No.';
}
