// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents.Designer;

page 4361 "Agent Task Templates"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Agent Task Template Buffer";
    Caption = 'Agent Task Templates';
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            repeater(Main)
            {
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the type of the agent task template.';
                }
                field(Name; Rec.Name)
                {
                }
                field(Description; Rec.Description)
                {
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(NewTaskTemplate)
            {
                ApplicationArea = All;
                Caption = 'New Task Template';
                Image = New;
                ToolTip = 'Create a new agent task template.';

                trigger OnAction()
                var
                    TempAgentTaskTemplateBuffer: Record "Agent Task Template Buffer" temporary;
                begin
                    TempAgentTaskTemplateBuffer.Type := Enum::"Agent Template Type"::"Agent Task Template";
                    TempAgentTaskTemplateBuffer.Insert();
                    if (Page.RunModal(Page::"Agent Task Template Card", TempAgentTaskTemplateBuffer) in [Action::OK, Action::LookupOK]) then
                        RefreshPage();
                end;
            }
            action(NewMessageTemplate)
            {
                ApplicationArea = All;
                Caption = 'New Message Template';
                Image = NewInvoice;
                ToolTip = 'Create a new agent message template.';

                trigger OnAction()
                var
                    TempAgentTaskTemplateBuffer: Record "Agent Task Template Buffer" temporary;
                begin
                    TempAgentTaskTemplateBuffer.Type := Enum::"Agent Template Type"::"Agent Message Template";
                    TempAgentTaskTemplateBuffer.Insert();
                    if (Page.RunModal(Page::"Agent Task Template Card", TempAgentTaskTemplateBuffer) in [Action::OK, Action::LookupOK]) then
                        RefreshPage();
                end;
            }
            action(Edit)
            {
                ApplicationArea = All;
                Caption = 'Edit';
                Image = Edit;
                ToolTip = 'Edit the selected agent task template.';

                trigger OnAction()
                begin
                    if (Page.RunModal(Page::"Agent Task Template Card", Rec) in [Action::OK, Action::LookupOK]) then
                        CurrPage.Update(false);
                end;
            }
            action(Delete)
            {
                ApplicationArea = All;
                Caption = 'Delete';
                Image = Delete;
                ToolTip = 'Delete the selected agent task template.';

                trigger OnAction()
                begin
                    if not Confirm(AreYouSureYouWantToDeleteQst) then
                        exit;

                    Rec.Delete(true);
                    CurrPage.Update(false);
                end;
            }
            action(DeleteAll)
            {
                ApplicationArea = All;
                Caption = 'Delete All';
                Image = Delete;
                ToolTip = 'Delete all agent task templates.';

                trigger OnAction()
                begin
                    if not Confirm(AreYouSureYouWantToDeleteAllQst) then
                        exit;

                    Rec.Reset();
                    Rec.DeleteAll(true);
                    CurrPage.Update(false);
                end;
            }
            action(Import)
            {
                ApplicationArea = All;
                Caption = 'Import';
                Image = Import;
                ToolTip = 'Import agent task templates from a file.';

                trigger OnAction()
                var
                    AgentTaskTemplate: Codeunit "Agent Task Template";
                begin
                    AgentTaskTemplate.ImportFromFile();
                    RefreshPage();
                    CurrPage.Update(false);
                end;
            }
            action(Export)
            {
                ApplicationArea = All;
                Caption = 'Export';
                Image = Export;
                ToolTip = 'Export agent task templates to a file.';

                trigger OnAction()
                var
                    AgentTaskTemplate: Codeunit "Agent Task Template";
                begin
                    AgentTaskTemplate.ExportToFile();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                group(AgentTemplates)
                {
                    ShowAs = SplitButton;
                    actionref(NewTaskTemplate_Promoted; NewTaskTemplate)
                    {
                    }
                    actionref(NewMessageTemplate_Promoted; NewMessageTemplate)
                    {
                    }
                }
                actionref(Edit_Promoted; Edit)
                {
                }
                group(DeleteGroup)
                {
                    ShowAs = SplitButton;
                    actionref(Delete_Promoted; Delete)
                    {
                    }
                    actionref(DeleteAll_Promoted; DeleteAll)
                    {
                    }
                }
                group(ImportExport)
                {
                    ShowAs = SplitButton;
                    actionref(Import_Promoted; Import)
                    {
                    }
                    actionref(Export_Promoted; Export)
                    {
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if GlobalAgentTaskType <> Enum::"Agent Template Type"::All then begin
            Rec.FilterGroup(4);
            Rec.SetRange(Type, GlobalAgentTaskType);
            Rec.FilterGroup(0);
        end;

        Rec.LoadRecords(GlobalAgentTaskType, GlobalTaskTemplateCode);
    end;

    internal procedure SetType(NewType: Enum "Agent Template Type")
    begin
        GlobalAgentTaskType := NewType;
    end;

    internal procedure SetTaskTemplateCode(NewCode: Code[20])
    begin
        GlobalTaskTemplateCode := NewCode;
    end;

    internal procedure GetSelectedSourceID(): Integer
    begin
        exit(Rec."Source Record ID");
    end;

    internal procedure GetSelectedRecords(var AgentTaskTemplateBuffer: Record "Agent Task Template Buffer")
    begin
        AgentTaskTemplateBuffer.Copy(Rec, true);
        CurrPage.SetSelectionFilter(AgentTaskTemplateBuffer);
    end;

    local procedure RefreshPage()
    begin
        Rec.Reset();
        Rec.DeleteAll(false);
        Rec.LoadRecords(GlobalAgentTaskType, GlobalTaskTemplateCode);
        CurrPage.Update(false);
    end;

    var
        GlobalAgentTaskType: Enum "Agent Template Type";
        GlobalTaskTemplateCode: Code[20];
        AreYouSureYouWantToDeleteQst: Label 'Are you sure you want to delete this template?';
        AreYouSureYouWantToDeleteAllQst: Label 'Are you sure you want to delete all templates?';
}