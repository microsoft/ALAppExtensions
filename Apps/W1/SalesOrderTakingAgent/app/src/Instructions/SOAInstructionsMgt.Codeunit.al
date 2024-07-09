// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Instructions;
using System.Reflection;
using System.Utilities;

codeunit 4305 "SOA Instructions Mgt."
{
    trigger OnRun()
    begin

    end;

    var
        PromptTok: Label 'Prompt';

    procedure SetPrompt(var InstructionPrompt: Record "SOA Instruction Prompt"; PromptTextToBlob: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        PromptStream: OutStream;
    begin
        RecRef.GetTable(InstructionPrompt);
        TempBlob.CreateOutStream(PromptStream, TextEncoding::UTF8);
        PromptStream.Write(PromptTextToBlob);
        TempBlob.ToRecordRef(RecRef, InstructionPrompt.FieldNo(Prompt));
        RecRef.SetTable(InstructionPrompt);
    end;

    procedure GetPromptText(InstructionPrompt: Record "SOA Instruction Prompt") Result: Text
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        TempBlob.FromRecord(InstructionPrompt, InstructionPrompt.FieldNo(Prompt));
        if not TempBlob.HasValue() then
            exit;

        Result := GetPromptTextFromBlob(TempBlob);
    end;

    procedure GetPromptText(InstructionTaskPolicy: Record "SOA Instruction Task/Policy") Result: Text
    var
        InstructionPrompt: Record "SOA Instruction Prompt";
        TempBlob: Codeunit "Temp Blob";
    begin
        Result := '';

        if not InstructionPrompt.Get(InstructionTaskPolicy."Prompt Code") then
            exit;

        TempBlob.FromRecord(InstructionPrompt, InstructionPrompt.FieldNo(Prompt));
        if not TempBlob.HasValue() then
            exit;

        Result := GetPromptTextFromBlob(TempBlob);
    end;

    procedure GetPromptText(InstructionPhase: Record "SOA Instruction Phase") Result: Text
    var
        InstructionPhaseStep: Record "SOA Instruction Phase Step";
        InstructionTaskPolicy: Record "SOA Instruction Task/Policy";
        InstructionPrompt: Record "SOA Instruction Prompt";
        TempBlob: Codeunit "Temp Blob";
        TextBuilder: TextBuilder;
        PromptText: Text;
    begin
        Result := '';

        if InstructionPrompt.Get(InstructionPhase."Prompt Code") then begin
            TempBlob.FromRecord(InstructionPrompt, InstructionPrompt.FieldNo(Prompt));
            if TempBlob.HasValue() then begin
                PromptText := GetPromptTextFromBlob(TempBlob);
                TextBuilder.AppendLine(PromptText);
            end;
        end;

        InstructionPhaseStep.SetRange(Phase, InstructionPhase.Phase);
        InstructionPhaseStep.SetFilter(Enabled, '<>%1', InstructionPhaseStep.Enabled::No);
        if InstructionPhaseStep.FindSet() then
            repeat
                InstructionTaskPolicy.Get(InstructionPhaseStep."Step Type", InstructionPhaseStep."Step Name");
                PromptText := GetPromptText(InstructionTaskPolicy);
                TextBuilder.AppendLine(PromptText);
            until InstructionPhaseStep.Next() = 0;

        Result := TextBuilder.ToText();
    end;

    procedure GetPromptText(InstructionTemplate: Record "SOA Instruction Template") Result: Text
    var
        InstructionPhase: Record "SOA Instruction Phase";
        InstructionPrompt: Record "SOA Instruction Prompt";
        TempBlob: Codeunit "Temp Blob";
        TemplatePromptText: Text;
        PhasePromptText: Text;
        PhasePlaceholderTok: Label '<<PHASE %1>>', Locked = true;
    begin
        Result := '';

        if not InstructionPrompt.Get(InstructionTemplate."Prompt Code") then
            exit;

        TempBlob.FromRecord(InstructionPrompt, InstructionPrompt.FieldNo(Prompt));
        if not TempBlob.HasValue() then
            exit;

        TemplatePromptText := GetPromptTextFromBlob(TempBlob);

        InstructionPhase.SetRange("Template Name", InstructionTemplate.Name);
        if InstructionPhase.FindSet() then
            repeat
                if InstructionPhase.Enabled = InstructionPhase.Enabled::No then
                    PhasePromptText := ''
                else
                    PhasePromptText := GetPromptText(InstructionPhase);
                TemplatePromptText := TemplatePromptText.Replace(StrSubstNo(PhasePlaceholderTok, InstructionPhase."Phase Order No."), PhasePromptText);
            until InstructionPhase.Next() = 0;

        Result := TemplatePromptText;
    end;

    procedure GetMetaPromptText(InstructionTemplate: Record "SOA Instruction Template") Result: Text
    var
        InstructionPrompt: Record "SOA Instruction Prompt";
        TempBlob: Codeunit "Temp Blob";
    begin
        Result := '';

        if not InstructionPrompt.Get(InstructionTemplate."Meta Prompt Code") then
            exit;

        TempBlob.FromRecord(InstructionPrompt, InstructionPrompt.FieldNo(Prompt));
        if not TempBlob.HasValue() then
            exit;

        Result := GetPromptTextFromBlob(TempBlob);
    end;

    local procedure GetPromptTextFromBlob(var TempBlob: Codeunit "Temp Blob"): Text
    var
        TypeHelper: Codeunit "Type Helper";
        PromptStream: InStream;
    begin
        TempBlob.CreateInStream(PromptStream, TextEncoding::UTF8);
        exit(TypeHelper.TryReadAsTextWithSepAndFieldErrMsg(PromptStream, TypeHelper.LFSeparator(), PromptTok));
    end;

    [EventSubscriber(ObjectType::Table, Database::"SOA Instruction Prompt", OnAfterDeleteEvent, '', false, false)]
    local procedure ClearPromptLinks(var Rec: Record "SOA Instruction Prompt")
    var
        InstructionTemplate: Record "SOA Instruction Template";
        InstructionPhase: Record "SOA Instruction Phase";
    begin
        InstructionTemplate.SetRange("Prompt Code", Rec.Code);
        InstructionTemplate.ModifyAll("Prompt Code", '', false);
        InstructionPhase.SetRange("Prompt Code", Rec.Code);
        InstructionPhase.ModifyAll("Prompt Code", '', false);
    end;
}