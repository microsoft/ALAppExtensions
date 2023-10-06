﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Reflection;

page 6124 "E-Doc. Mapping Part"
{
    ApplicationArea = Basic, Suite;
    Caption = 'E-Document Mapping';
    PageType = ListPart;
    SourceTable = "E-Doc. Mapping";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater("E-Doc Mapping Lines")
            {
                field("Table ID"; Rec."Table ID")
                {
                    Caption = 'Table ID';
                    ToolTip = 'Specifies the table of the mapping value.';

                    trigger OnValidate()
                    begin
                        Clear(Rec."Field ID");
                        Clear(Rec."Field ID Caption");
                        Rec.CalcFields("Table ID Caption");
                    end;
                }
                field("Table ID Caption"; Rec."Table ID Caption")
                {
                    Caption = 'Table';
                    ToolTip = 'Specifies the table caption of the mapping value.';
                }
                field("Field ID"; Rec."Field ID")
                {
                    Caption = 'Field ID';
                    ToolTip = 'Specifies the field of the mapping value.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        FieldTable: Record Field;
                    begin
                        if Rec."Table ID" <> 0 then
                            FieldTable.SetRange(TableNo, Rec."Table ID");

                        if Page.RunModal(Page::"Fields Lookup", FieldTable) = Action::LookupOK then begin
                            Rec."Field ID" := FieldTable."No.";
                            Rec.CalcFields("Field ID Caption");
                        end;
                    end;
                }
                field("Field ID Caption"; Rec."Field ID Caption")
                {
                    Caption = 'Field';
                    ToolTip = 'Specifies the field caption of the mapping value.';
                }
                field("Transformation Rule"; Rec."Transformation Rule")
                {
                    Caption = 'Transformation';
                    ToolTip = 'Specifies the transformation rule applied to map the field.';
                }
                field("Find Value"; Rec."Find Value")
                {
                    Caption = 'Find Value';
                    ToolTip = 'Specifies the original field value of the mapping.';
                }
                field("Replace Value"; Rec."Replace Value")
                {
                    Caption = 'Replace Value';
                    ToolTip = 'Specifies the replaced field value of the mapping.';
                }
            }
        }
    }

    var
        ForImport: Boolean;


    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec."For Import" := ForImport;
    end;

    internal procedure SaveAsImport(Value: Boolean)
    begin
        ForImport := Value;
    end;
}
