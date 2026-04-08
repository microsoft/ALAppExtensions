// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer.CustomAgent;

using System.Agents;
using System.Agents.Designer;
using System.IO;
using System.Utilities;

codeunit 4352 "Custom Agent Instructions"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Custom Agent Setup" = rm;

    procedure DownloadSelectedInstructions(var CustomAgentInstructionsLog: Record "Custom Agent Instructions Log"; AgentUserSecurityId: Guid)
    var
        Agent: Record Agent;
        NumberOfRecordsFound: Integer;
        AgentName: Text;
    begin
        if not CustomAgentInstructionsLog.FindSet() then
            Error(NoRecordsSelectedErr);

        NumberOfRecordsFound := CustomAgentInstructionsLog.Count();
        if NumberOfRecordsFound = 0 then
            Error(NoRecordsSelectedErr);

        Agent.Get(AgentUserSecurityId);
        AgentName := Agent."Display Name";

        if NumberOfRecordsFound = 1 then begin
            DownloadSingleInstruction(CustomAgentInstructionsLog, AgentName);
            exit;
        end;

        DownloadMultipleInstructions(CustomAgentInstructionsLog, AgentName);
    end;

    [Scope('OnPrem')]
    [NonDebuggable]
    procedure GetInstructions(AgentUserSecurityID: Guid): Text
    var
        AgentInstructions: Text;
    begin
        if TryGetInstructions(AgentUserSecurityID, AgentInstructions) then
            exit(AgentInstructions);

        exit(CannotLoadInstructionsTxt);
    end;

    [Scope('OnPrem')]
    procedure TryGetInstructions(AgentUserSecurityID: Guid; var AgentInstructions: Text): Boolean
    var
        CustomAgentSetup: Record "Custom Agent Setup";
        AgentDesignerEnvironment: Codeunit "Agent Designer Environment";
        InstructionsInstream: InStream;
    begin
        AgentDesignerEnvironment.VerifyCanRunOnCurrentEnvironment();
        if IsNullGuid(AgentUserSecurityID) then
            exit(false);

        if CustomAgentSetup.Get(AgentUserSecurityID) then begin
            CustomAgentSetup.CalcFields(Instructions);
            CustomAgentSetup.Instructions.CreateInStream(InstructionsInstream, GetDefaultEncoding());
            InstructionsInstream.Read(AgentInstructions);
            exit(true);
        end;

        exit(false);
    end;

    [Scope('OnPrem')]
    procedure RestoreInstructions(var CustomAgentSetup: Record "Custom Agent Setup"; InstructionsText: Text; InstructionsVersion: Text[100])
    var
        AgentDesignerEnvironment: Codeunit "Agent Designer Environment";
        NewInstructionsVersion: Text[100];
    begin
        AgentDesignerEnvironment.VerifyCanRunOnCurrentEnvironment();

        MarkCurrentInstructionsAsReadOnly(CustomAgentSetup);

        // We do not want to override the restored instructions, we should create new instructions
        NewInstructionsVersion := GetNextVersionNumber(CustomAgentSetup);
        SetInstructions(CustomAgentSetup, InstructionsText, NewInstructionsVersion, true);
    end;

    [Scope('OnPrem')]
    procedure SetInstructions(var CustomAgentSetup: Record "Custom Agent Setup"; NewInstructions: Text; var InstructionsVersion: Text[100]; ForceSave: Boolean)
    var
        CustomAgentInstructionsLog: Record "Custom Agent Instructions Log";
        CurrentAgentInstructionsLog: Record "Custom Agent Instructions Log";
        AgentDesignerEnvironment: Codeunit "Agent Designer Environment";
        NewVersionNeeded: Boolean;
    begin
        AgentDesignerEnvironment.VerifyCanRunOnCurrentEnvironment();

        if CustomAgentSetup.IsTemporary() then
            exit;

        if InstructionsVersion = '' then
            InstructionsVersion := GetNextVersionNumber(CustomAgentSetup);

        NewVersionNeeded := ForceSave;
        if not NewVersionNeeded then
            if GetCurrentInstructions(CustomAgentSetup, CurrentAgentInstructionsLog) then
                NewVersionNeeded := CurrentAgentInstructionsLog."Read-Only Instructions";

        if CustomAgentSetup."Instructions Version" <> '' then
            if NewVersionNeeded then begin
#pragma warning disable AA0139
                if CustomAgentSetup."Instructions Version" = InstructionsVersion then
                    InstructionsVersion := GetNextVersionNumber(CustomAgentSetup);

                CustomAgentSetup."Instructions Version" := InstructionsVersion;
#pragma warning restore AA0139
                CustomAgentSetup.Modify(true);
                UpdateInstructionsOnSetupRecord(CustomAgentSetup, NewInstructions);
                SaveCurrentInstructionsToLog(CustomAgentSetup, ForceSave);
            end else begin
                UpdateInstructionsOnSetupRecord(CustomAgentSetup, NewInstructions);
                if CustomAgentSetup."Instructions Version" <> InstructionsVersion then begin
#pragma warning disable AA0139
                    CustomAgentSetup."Instructions Version" := InstructionsVersion;
#pragma warning restore AA0139
                    CustomAgentSetup.Modify(true);
                end;

                CustomAgentInstructionsLog.SetRange("User Security ID", CustomAgentSetup."User Security ID");
                CustomAgentInstructionsLog.SetRange("Instruction Version", InstructionsVersion);
                if CustomAgentInstructionsLog.FindFirst() then begin
                    CustomAgentInstructionsLog.SetInstructions(NewInstructions);
#pragma warning disable AA0214
                    CustomAgentInstructionsLog.Modify(true);
#pragma warning restore AA0214
                end else
                    SaveCurrentInstructionsToLog(CustomAgentSetup, ForceSave);
            end;
    end;

    procedure UpdateCustomAgentSetupVersionName(AgentUserSecurityID: Guid; NewVersionName: Text[100])
    var
        CustomAgentSetup: Record "Custom Agent Setup";
    begin
        if not CustomAgentSetup.Get(AgentUserSecurityID) then
            exit;

        if CustomAgentSetup."Instructions Version" <> NewVersionName then begin
            CustomAgentSetup."Instructions Version" := NewVersionName;
            CustomAgentSetup.Modify(true);
        end;
    end;

    local procedure DownloadSingleInstruction(var CustomAgentInstructionsLog: Record "Custom Agent Instructions Log"; AgentName: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        FileInStream: InStream;
        FileName: Text;
        Instructions: Text;
    begin
        Instructions := CustomAgentInstructionsLog.GetInstructions();
        if Instructions = '' then
            Error(NoRecordsSelectedErr);

        CreateTextBlobStream(TempBlob, Instructions, FileInStream);
        FileName := StrSubstNo(SingleFileNameLbl, AgentName, CustomAgentInstructionsLog."Instruction Version");
        DownloadFromStream(FileInStream, DownloadSingleFileLbl, '', '*.txt', FileName);
    end;

    local procedure DownloadMultipleInstructions(var CustomAgentInstructionsLog: Record "Custom Agent Instructions Log"; AgentName: Text)
    var
        DataCompression: Codeunit "Data Compression";
        TempBlob: Codeunit "Temp Blob";
        ZipTempBlob: Codeunit "Temp Blob";
        FileInStream: InStream;
        FileOutStream: OutStream;
        FileName: Text;
        EntryFileName: Text;
        Instructions: Text;
    begin
        DataCompression.CreateZipArchive();

        repeat
            Instructions := CustomAgentInstructionsLog.GetInstructions();
            if Instructions <> '' then begin
                CreateTextBlobStream(TempBlob, Instructions, FileInStream);
                EntryFileName := StrSubstNo(SingleFileNameLbl, AgentName, CustomAgentInstructionsLog."Instruction Version");
                DataCompression.AddEntry(FileInStream, EntryFileName);
            end;
        until CustomAgentInstructionsLog.Next() = 0;

        Clear(ZipTempBlob);
        ZipTempBlob.CreateOutStream(FileOutStream);
        DataCompression.SaveZipArchive(FileOutStream);
        DataCompression.CloseZipArchive();

        ZipTempBlob.CreateInStream(FileInStream);
        FileName := StrSubstNo(ZipFileNameLbl, AgentName);
        DownloadFromStream(FileInStream, DownloadZipLbl, '', '*.zip', FileName);
    end;

    local procedure UpdateInstructionsOnSetupRecord(var CustomAgentSetup: Record "Custom Agent Setup"; NewInstructions: Text)
    var
        Agent: Codeunit Agent;
        InstructionsOutstream: OutStream;
    begin
        Clear(CustomAgentSetup.Instructions);
        CustomAgentSetup.Instructions.CreateOutStream(InstructionsOutstream, GetDefaultEncoding());

        InstructionsOutstream.WriteText(NewInstructions);
        CustomAgentSetup.Modify(true);
        Agent.SetInstructions(CustomAgentSetup."User Security ID", NewInstructions);
    end;

    local procedure SaveCurrentInstructionsToLog(var CustomAgentSetup: Record "Custom Agent Setup"; Force: Boolean)
    var
        CustomAgentInstructionsLog: Record "Custom Agent Instructions Log";
        ExistingCustomAgentInstructionsLog: Record "Custom Agent Instructions Log";
        CurrentInstructions: Text;
        InstructionVersionName: Text[100];
    begin
        if CustomAgentSetup.IsTemporary() then
            exit;

        if IsNullGuid(CustomAgentSetup."User Security ID") then
            exit;

        CurrentInstructions := GetInstructions(CustomAgentSetup."User Security ID");

        if not Force then
            if not ShouldSaveInstructionsToLog(CustomAgentSetup."User Security ID", CurrentInstructions) then
                exit;

        InstructionVersionName := CustomAgentSetup."Instructions Version";
        ExistingCustomAgentInstructionsLog.SetRange("User Security ID", CustomAgentSetup."User Security ID");
        ExistingCustomAgentInstructionsLog.SetRange("Instruction Version", InstructionVersionName);
        if not ExistingCustomAgentInstructionsLog.IsEmpty() then begin
            ExistingCustomAgentInstructionsLog.SetFilter("Instruction Version", InstructionVersionName + ' - *');
#pragma warning disable AA0139
            InstructionVersionName := InstructionVersionName + ' - ' + Format(ExistingCustomAgentInstructionsLog.Count() + 1);
#pragma warning restore AA0139
        end;
        CustomAgentInstructionsLog."User Security ID" := CustomAgentSetup."User Security ID";
        CustomAgentInstructionsLog.SetInstructions(CurrentInstructions);
        CustomAgentInstructionsLog."Instruction Version" := InstructionVersionName;
        CustomAgentInstructionsLog.Insert(true);
    end;

    local procedure ShouldSaveInstructionsToLog(AgentUserSecurityId: Guid; CurrentInstructions: Text): Boolean
    var
        CustomAgentInstructionsLog: Record "Custom Agent Instructions Log";
        LastInstructions: Text;
        NewLineChars: Text;
    begin
        CustomAgentInstructionsLog.SetRange("User Security ID", AgentUserSecurityId);
        CustomAgentInstructionsLog.SetCurrentKey("User Security ID", SystemCreatedAt);
        CustomAgentInstructionsLog.Ascending(false);

        if not CustomAgentInstructionsLog.FindFirst() then begin
            if CurrentInstructions = '' then
                exit(false);
            exit(true);
        end;

        LastInstructions := CustomAgentInstructionsLog.GetInstructions();

        NewLineChars := GetNewLineChars();
        CurrentInstructions := DelChr(CurrentInstructions, '=', NewLineChars).Trim();
        LastInstructions := DelChr(LastInstructions, '=', NewLineChars).Trim();

        if CurrentInstructions = LastInstructions then
            exit(false);

        exit(true);
    end;

    local procedure GetNewLineChars(): Text
    var
        LF: Char;
        CR: Char;
    begin
        LF := 10;
        CR := 13;
        exit(Format(LF) + Format(CR));
    end;

    procedure GetNextVersionNumber(var CustomAgentSetup: Record "Custom Agent Setup") NewInstructionsName: Text[100]
    var
        ExistingCustomAgentInstructionsLog: Record "Custom Agent Instructions Log";
        Prefixes: List of [Text];
        InstructionsPrefix: Text;
    begin
        if CustomAgentSetup."Instructions Version" = '' then
            CustomAgentSetup."Instructions Version" := InstructionsLbl;

        ExistingCustomAgentInstructionsLog.SetRange("User Security ID", CustomAgentSetup."User Security ID");
        Prefixes := CustomAgentSetup."Instructions Version".Split(' - ');
        if Prefixes.Count() > 0 then
            InstructionsPrefix := Prefixes.Get(1);

        if InstructionsPrefix = '' then
            InstructionsPrefix := CustomAgentSetup."Instructions Version";

        ExistingCustomAgentInstructionsLog.SetFilter("Instruction Version", InstructionsPrefix + '*');

        NewInstructionsName := InstructionsPrefix + ' - ' + Format(ExistingCustomAgentInstructionsLog.Count() + 1);
        exit(NewInstructionsName);
    end;

    procedure DownloadCurrentInstructions(InstructionsTxt: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        FileInStream: InStream;
        FileName: Text;
    begin
        if InstructionsTxt = '' then
            Error(NoInstructionsToDownloadErr);

        FileName := AgentInstructionsFileNameLbl;
        CreateTextBlobStream(TempBlob, InstructionsTxt, FileInStream);
        DownloadFromStream(FileInStream, DownloadCurrentInstructionsLbl, '', '*.txt', FileName);
    end;

    procedure ApplyInstructionsToAgent(var CustomAgentInstructionsLog: Record "Custom Agent Instructions Log"; AgentUserSecurityId: Guid)
    var
        CustomAgentSetup: Record "Custom Agent Setup";
    begin
        if not Confirm(ApplyInstructionsConfirmQst, false, CustomAgentInstructionsLog."Instruction Version") then
            exit;

        if not CustomAgentSetup.Get(AgentUserSecurityId) then
            Error(AgentSetupNotFoundErr);

        RestoreInstructions(CustomAgentSetup, CustomAgentInstructionsLog.GetInstructions(), CustomAgentInstructionsLog."Instruction Version");
        if GuiAllowed then
            Message(InstructionsAppliedSuccessMsg);
    end;

    procedure SaveInstructionsAsNewVersion(InstructionsTxt: Text; AgentUserSecurityId: Guid): Boolean
    var
        CustomAgentSetup: Record "Custom Agent Setup";
        CustAgentSaveVersionDlg: Page "Cust. Agent Save Version Dlg";
        NewVersionName: Text[100];
    begin
        if not CustomAgentSetup.Get(AgentUserSecurityId) then
            Error(AgentSetupNotFoundErr);

        NewVersionName := GetNextVersionNumber(CustomAgentSetup);

        CustAgentSaveVersionDlg.SetVersionName(NewVersionName);
        if CustAgentSaveVersionDlg.RunModal() <> Action::Yes then
            exit(false);

        NewVersionName := CustAgentSaveVersionDlg.GetVersionName();
        if NewVersionName = '' then
            Error(VersionNameRequiredErr);

        SetInstructions(CustomAgentSetup, InstructionsTxt, NewVersionName, true);
        MarkCurrentInstructionsAsReadOnly(CustomAgentSetup);
        exit(true);
    end;

    procedure MarkCurrentInstructionsAsReadOnly(var CustomAgentSetup: Record "Custom Agent Setup")
    var
        CustomAgentInstructionsLog: Record "Custom Agent Instructions Log";
    begin
        if not GetCurrentInstructions(CustomAgentSetup, CustomAgentInstructionsLog) then
            exit;

        CustomAgentInstructionsLog."Read-Only Instructions" := true;
        CustomAgentInstructionsLog.Modify(false);
    end;

    local procedure GetCurrentInstructions(var CustomAgentSetup: Record "Custom Agent Setup"; var CurrentAgentInstructionsLog: Record "Custom Agent Instructions Log"): Boolean
    begin
        if CustomAgentSetup."Instructions Version" = '' then
            exit(false);

        CurrentAgentInstructionsLog.SetRange("User Security ID", CustomAgentSetup."User Security ID");
        CurrentAgentInstructionsLog.SetRange("Instruction Version", CustomAgentSetup."Instructions Version");
        exit(CurrentAgentInstructionsLog.FindFirst());
    end;

    local procedure CreateTextBlobStream(var TempBlob: Codeunit "Temp Blob"; TextContent: Text; var FileInStream: InStream)
    var
        FileOutStream: OutStream;
    begin
        Clear(TempBlob);
        TempBlob.CreateOutStream(FileOutStream, GetDefaultEncoding());
        FileOutStream.WriteText(TextContent);
        TempBlob.CreateInStream(FileInStream, GetDefaultEncoding());
    end;

    internal procedure GetDefaultEncoding(): TextEncoding
    begin
        exit(TextEncoding::UTF8);
    end;

    internal procedure GetHowToWriteInstructionsUrl(): Text
    begin
        exit(HowToWriteInstructionsUrlTxt);
    end;

    var
        CannotLoadInstructionsTxt: Label 'For this agent, it is not possible to load the instructions.';
        InstructionsLbl: Label 'Instructions';
        NoRecordsSelectedErr: Label 'No records have been selected. Please select one or more instructions to download.';
        SingleFileNameLbl: Label '%1-%2.txt', Comment = '%1 = Agent name, %2 = Version', Locked = true;
        ZipFileNameLbl: Label 'Instructions-%1.zip', Comment = '%1 = Agent name', Locked = true;
        DownloadSingleFileLbl: Label 'Download Instructions';
        DownloadZipLbl: Label 'Download Instructions Archive';
        AgentInstructionsFileNameLbl: Label 'AgentInstructions.txt', Locked = true;
        DownloadCurrentInstructionsLbl: Label 'Download instructions';
        NoInstructionsToDownloadErr: Label 'There are no instructions to download.';
        ApplyInstructionsConfirmQst: Label 'Do you want to apply instructions version %1 to the agent? This will replace the current instructions.', Comment = '%1 = Instructions version';
        AgentSetupNotFoundErr: Label 'The agent setup could not be found.';
        InstructionsAppliedSuccessMsg: Label 'The instructions have been successfully applied to the agent.';
        VersionNameRequiredErr: Label 'Version name cannot be empty.';
        HowToWriteInstructionsUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2344704', Locked = true;
}
