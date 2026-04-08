// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer;

table 4358 "Agent Task Template Buffer"
{
    ReplicateData = false;
    InherentPermissions = RIMDX;
    InherentEntitlements = RIMDX;
    TableType = Temporary;
    Access = Internal;
    Extensible = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'ID';
            ToolTip = 'Specifies the unique identifier of the agent task template.';
        }
        field(2; Name; Text[150])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name of the agent task template.';
        }
        field(3; Description; Text[250])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the agent task template.';
        }
        field(10; Type; Enum "Agent Template Type")
        {
            DataClassification = SystemMetadata;
            Caption = 'Type';
            ToolTip = 'Specifies the type of the agent template.';
        }
        field(100; "Source Record ID"; Integer)
        {
            Caption = 'Source Record ID';
            ToolTip = 'Specifies the ID of the template record from which this buffer record was created.';
        }
    }
    keys
    {
        key(Key1; ID)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        AgentTaskTemplate: Record "Agent Task Template";
        AgentMessageTemplate: Record "Agent Message Template";
    begin
        if Rec.Type = Rec.Type::"Agent Task Template" then begin
            if AgentTaskTemplate.Get(Rec."Source Record ID") then
                AgentTaskTemplate.Delete(true);
            exit;
        end;

        if Rec.Type = Rec.Type::"Agent Message Template" then begin
            if AgentMessageTemplate.Get(Rec."Source Record ID") then
                AgentMessageTemplate.Delete(true);
            exit;
        end;
    end;

    internal procedure GetAgentTaskTemplate(var AgentTaskTemplate: Record "Agent Task Template"; var AgentMessageTemplate: Record "Agent Message Template"): Boolean
    begin
        if Rec.Type <> Rec.Type::"Agent Task Template" then
            exit(false);

        if not (AgentTaskTemplate.Get(Rec."Source Record ID")) then
            exit(false);

        if not AgentTaskTemplate."Include Message" then
            exit(true);

        exit(AgentMessageTemplate.Get(AgentTaskTemplate."Message Template ID"));
    end;

    internal procedure GetAgentMessageTemplate(var AgentMessageTemplate: Record "Agent Message Template"): Boolean
    begin
        if Rec.Type <> Rec.Type::"Agent Message Template" then
            exit(false);

        exit(AgentMessageTemplate.Get(Rec."Source Record ID"));
    end;

    internal procedure LoadRecords(AgentTemplateType: Enum "Agent Template Type")
    begin
        LoadRecords(AgentTemplateType, '');
    end;

    internal procedure LoadRecords(AgentTemplateType: Enum "Agent Template Type"; SampleAgentTaskTemplateCode: Code[20])
    var
        CurrentKey: Integer;
    begin
        CurrentKey := 1;
        if AgentTemplateType in [AgentTemplateType::"Agent Task Template", AgentTemplateType::All] then
            LoadAgentTaskTemplates(CurrentKey, SampleAgentTaskTemplateCode);

        if AgentTemplateType in [AgentTemplateType::"Agent Message Template", AgentTemplateType::All] then
            LoadAgentMessageTemplates(CurrentKey);
    end;

    local procedure LoadAgentTaskTemplates(var CurrentKey: Integer; SampleAgentTaskTemplateCode: Code[20])
    var
        AgentTaskTemplate: Record "Agent Task Template";
    begin
        if SampleAgentTaskTemplateCode <> '' then
            AgentTaskTemplate.SetRange("Sample Agent Code", SampleAgentTaskTemplateCode);

        if not AgentTaskTemplate.FindSet() then
            exit;
        repeat
            Clear(Rec);
            Rec.ID := CurrentKey;
            Rec.Name := AgentTaskTemplate.Name;
            Rec.Description := AgentTaskTemplate."Description";
            Rec.Type := Rec.Type::"Agent Task Template";
            Rec."Source Record ID" := AgentTaskTemplate.ID;
            CurrentKey += 1;
            Rec.Insert();
        until AgentTaskTemplate.Next() = 0;
    end;

    local procedure LoadAgentMessageTemplates(var CurrentKey: Integer)
    var
        AgentMessageTemplate: Record "Agent Message Template";
    begin
        AgentMessageTemplate.SetRange("Created with task", false);
        if not AgentMessageTemplate.FindSet() then
            exit;
        repeat
            Clear(Rec);
            Rec.ID := CurrentKey;
            Rec.Name := AgentMessageTemplate.Name;
            Rec.Type := Rec.Type::"Agent Message Template";
            Rec."Source Record ID" := AgentMessageTemplate.ID;
            CurrentKey += 1;
            Rec.Insert();
        until AgentMessageTemplate.Next() = 0;
    end;
}