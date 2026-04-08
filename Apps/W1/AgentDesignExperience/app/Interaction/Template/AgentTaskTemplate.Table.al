// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer;

table 4357 "Agent Task Template"
{
    Access = Internal;
    Caption = 'Agent Task Template';
    ReplicateData = false;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    DataClassification = CustomerContent;
    DataPerCompany = false;
    Extensible = false;
    LookupPageId = "Agent Task Templates";

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
        field(3; "Task Title"; Text[150])
        {
            Caption = 'Task title';
            ToolTip = 'Specifies the title of the agent task.';
        }
        field(4; "Task External Id"; Text[2048])
        {
            Caption = 'Task external ID';
            ToolTip = 'Specifies the external ID of the agent task.';
        }
        field(5; "Include Message"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Include Message';
            ToolTip = 'Specifies whether to include a message in the agent task.';
        }
        field(6; "Message Template ID"; Integer)
        {
            DataClassification = SystemMetadata;
            Caption = 'Message Template ID';
            ToolTip = 'Specifies the ID of the message template to be used in the agent task.';
        }
        field(7; "Sample Agent Code"; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Sample Agent Code';
            ToolTip = 'Specifies the code used for indentifying templates which were not created by users, for example, templates provided by extensions.';
        }
        field(8; "Description"; Text[250])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the agent task template.';
        }
        field(100; "Message Template Name"; Text[150])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("Agent Message Template".Name where(ID = field("Message Template ID")));
            Caption = 'Message Template Name';
            ToolTip = 'Specifies the name of the message template to be used in the agent task.';
        }
    }

    keys
    {
        key(Key1; ID)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        ValidatePermissions();

        Rec.TestField(Name);
        Rec.TestField("Task Title");
        if ID = 0 then
            ID := GetNextTemplateId();
    end;

    trigger OnModify()
    begin
        ValidatePermissions()
    end;

    trigger OnRename()
    begin
        ValidatePermissions()
    end;

    trigger OnDelete()
    var
        AgentMessageTemplate: Record "Agent Message Template";
    begin
        ValidatePermissions();

        if "Message Template ID" <> 0 then
            if AgentMessageTemplate.Get("Message Template ID") then
                AgentMessageTemplate.Delete(true);
    end;

    local procedure GetNextTemplateId(): Integer
    var
        AgentTaskTemplate: Record "Agent Task Template";
    begin
        if AgentTaskTemplate.FindLast() then;
        exit(AgentTaskTemplate.ID + 1);
    end;

    local procedure ValidatePermissions()
    var
        AgentDesignerPermissions: Codeunit "Agent Designer Permissions";
    begin
        AgentDesignerPermissions.VerifyCurrentUserCanManageTemplates();
    end;
}