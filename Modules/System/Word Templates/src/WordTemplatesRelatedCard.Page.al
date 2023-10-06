// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Word;

using System.Reflection;

/// <summary>
/// A list part factbox to view related entities for Word templates.
/// </summary>
page 9986 "Word Templates Related Card"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'Related Entity';
    DataCaptionExpression = Rec."Related Table Caption";
    UsageCategory = Administration;
    SourceTable = "Word Templates Related Table";
    SourceTableTemporary = true;
    Extensible = false;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            group(Group)
            {
                Caption = 'Related Entity';
                ShowCaption = false;

                field("Table ID"; Rec."Related Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the id of the related entity.';
                    Visible = false;
                }
                field("Table Caption"; Rec."Related Table Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the related entity.';
                    Editable = false;
                    Enabled = not IsEditOnly;

                    trigger OnAssistEdit()
                    var
                        AllObjWithCaption: Record AllObjWithCaption;
                        WordTemplateImpl: Codeunit "Word Template Impl.";
                    begin
                        if not WordTemplateImpl.GetTable(SelectRelatedTableCaptionLbl, AllObjWithCaption, FilterExpression) then
                            exit;

                        Rec."Related Table ID" := AllObjWithCaption."Object ID";

                        if Rec."Related Table ID" <> 0 then begin
                            Rec."Related Table Code" := WordTemplateImpl.GenerateCode(AllObjWithCaption."Object Caption", WordTemplateImpl.GetExistingCodes(Rec));
                            Rec."Field No." := WordTemplateImpl.GetFieldNo(FieldFilterExpression, Rec."Table ID", Rec."Related Table ID");
                            Rec.CalcFields("Related Table Caption");
                            Rec.CalcFields("Field Caption");
                        end;

                        CurrPage.Update();
                    end;
                }
                group(FieldSelection)
                {
                    ShowCaption = false;
                    Caption = ' ';

                    field("Field No."; Rec."Field No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the field no. from the source entity that creates the relationship to the related entity.';
                        Editable = false;
                        Visible = false;
                    }
                    field("Field Caption"; Rec."Field Caption")
                    {
                        ApplicationArea = All;
                        Caption = 'Source Entity Relation';
                        ToolTip = 'Specifies the field from the source entity that creates the relationship to the related entity. If there are more than one related entities, specify the one to use for your template.​';
                        Editable = false;

                        trigger OnAssistEdit()
                        var
                            WordTemplateImpl: Codeunit "Word Template Impl.";
                            FieldNo: Integer;
                        begin
                            if Rec."Related Table ID" = 0 then
                                Error(SelectRelatedTableErr);

                            if TableId <> 0 then begin
                                FieldNo := WordTemplateImpl.GetField(SelectTableFieldLbl, TableId, FieldFilterExpression);
                                if FieldNo <> 0 then begin
                                    Rec."Field No." := FieldNo;
                                    Rec.CalcFields("Field Caption");
                                    CurrPage.Update();
                                end;
                            end;
                        end;
                    }
                }
                field("Related Table Code"; Rec."Related Table Code")
                {
                    ApplicationArea = All;
                    Caption = 'Field Prefix';
                    ToolTip = 'Specifies a prefix that will indicate that the field is from the related entity when you are setting up the template. For example, if you enter Sales, the field names are prefixed with Sales_. The prefix must be unique.';
                    Editable = not IsEditOnly;
                }
                label(RelatedEntityOptions)
                {
                    ApplicationArea = All;
                    Caption = 'Related entities share a field, typically an identifier such as its name, code, or ID, with the source entity. When choosing a related entity the view is filtered to known predefined relations. To define your own custom relation, you can remove the filtering.​';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Table ID" := TableId;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction <> Action::LookupOK then
            exit(true);

        if Rec."Field No." = 0 then
            Error(EmptyParentFieldErr);

        exit(true);
    end;

    internal procedure SetFilterExpression(Expression: Text)
    begin
        FilterExpression := Expression;
    end;

    internal procedure SetTableNo(TableNo: Integer)
    begin
        TableId := TableNo;
    end;

    internal procedure SetEditOnly(EditOnly: Boolean)
    begin
        IsEditOnly := EditOnly;
    end;

    internal procedure SetRelatedTable(var WordTemplatesRelatedTable: Record "Word Templates Related Table" temporary)
    var
        WordTemplateImpl: Codeunit "Word Template Impl.";
    begin
        if IsEditOnly then begin
            Rec.Copy(WordTemplatesRelatedTable);
            Rec.Insert();
            WordTemplateImpl.GetFieldNo(FieldFilterExpression, Rec."Table ID", Rec."Related Table ID");
        end else
            Rec.Copy(WordTemplatesRelatedTable, true);
    end;

    internal procedure GetRelatedTable(var WordTemplatesRelatedTable: Record "Word Templates Related Table" temporary)
    begin
        WordTemplatesRelatedTable.TransferFields(Rec);
    end;

    var
        IsEditOnly: Boolean;
        TableId: Integer;
        FilterExpression: Text;
        FieldFilterExpression: Text;
        SelectRelatedTableCaptionLbl: Label 'Select related entity for the Word template.';
        SelectRelatedTableErr: Label 'Select a related entity before specifying the relation.';
        SelectTableFieldLbl: Label 'Select the source entity relation.';
        EmptyParentFieldErr: Label 'No source entity relation was specified.';
}