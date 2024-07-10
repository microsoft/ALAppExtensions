// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Agent.SalesOrderTaker.Instructions;

page 4318 "SOA Instruction Prompt Card"
{
    PageType = Card;
    SourceTable = "SOA Instruction Prompt";
    Caption = 'Instruction Prompt';
    SourceTableTemporary = true;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            field(Code; Rec.Code)
            {
                Caption = 'Code';
                ToolTip = 'Specifies the code of the prompt.';
                Visible = not ReadOnly;
            }
            field(Enabled; Rec.Enabled)
            {
                Caption = 'Enabled';
                ToolTip = 'Specifies if the prompt is enabled.';
                ValuesAllowed = No, Yes;
                Visible = not ReadOnly;
            }
            group(PromptText)
            {
                Caption = 'Prompt Text';
                Visible = not ReadOnly;

                field("Prompt Text"; PromptText)
                {
                    ShowCaption = false;
                    ToolTip = 'Specifies the full prompt.';
                    MultiLine = true;

                    trigger OnValidate()
                    begin
                        if not ReadOnly then
                            SaveRec();
                    end;
                }
            }
            group(PromptRichText)
            {
                Caption = 'Prompt Text';
                Visible = ReadOnly;
                Editable = false;

                field("Prompt Rich Text"; PromptText)
                {
                    ExtendedDatatype = RichContent;
                    ShowCaption = false;
                    ToolTip = 'Specifies the full prompt.';
                    MultiLine = true;
                }
            }
        }
    }

    var
        PromptText: Text;
        ReadOnly: Boolean;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if not ReadOnly then
            SaveRec();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if not ReadOnly then
            SaveRec();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        if not ReadOnly then
            DeleteRec();
    end;

    procedure SetRec(PromptCode: Code[20]; NewPromptText: Text; NewReadOnly: Boolean)
    var
        InstructionPrompt: Record "SOA Instruction Prompt";
    begin
        if InstructionPrompt.Get(PromptCode) then
            Rec.Copy(InstructionPrompt)
        else
            Rec.Init();
        Rec.Insert();
        PromptText := NewPromptText;

        ReadOnly := NewReadOnly;
    end;

    local procedure SaveRec()
    var
        InstructionPrompt: Record "SOA Instruction Prompt";
        InstructionsMgt: Codeunit "SOA Instructions Mgt.";
    begin
        if not InstructionPrompt.Get(Rec.Code) then begin
            InstructionPrompt := Rec;
            InstructionPrompt.Insert();
        end else begin
            InstructionPrompt := Rec;
            InstructionPrompt.Modify();
        end;
        InstructionsMgt.SetPrompt(InstructionPrompt, PromptText);
        InstructionPrompt.Modify();
        Commit();

        Rec.Copy(InstructionPrompt);
    end;

    local procedure DeleteRec()
    var
        InstructionPrompt: Record "SOA Instruction Prompt";
    begin
        if InstructionPrompt.Get(Rec.Code) then
            InstructionPrompt.Delete();
    end;

}