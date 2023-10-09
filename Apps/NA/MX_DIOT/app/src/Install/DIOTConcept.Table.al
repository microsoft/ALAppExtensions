// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Utilities;

table 27030 "DIOT Concept"
{
    Caption = 'DIOT Concept';

    fields
    {
        field(1; "Concept No."; Integer)
        {
            Caption = 'Concept No.';
            MinValue = 1;
            MaxValue = 17;
        }
        field(2; "Column No."; Integer)
        {
            Caption = 'Column No.';
            MinValue = 8;
            MaxValue = 24;
        }

        field(3; "Description"; Text[250])
        {
            Caption = 'Description';
        }

        field(4; "Column Type"; Option)
        {
            OptionMembers = None,"VAT Base","Vat Amount";
            OptionCaption = 'None,VAT Base,VAT Amount';
            Caption = 'Column Type';

            trigger OnValidate()
            var
                DIOTConceptLink: Record "DIOT Concept Link";
                ConfirmManagement: Codeunit "Confirm Management";
            begin
                if "Column Type" = "Column Type"::None then begin
                    DIOTConceptLink.SetRange("DIOT Concept No.", "Concept No.");
                    if DIOTConceptLink.IsEmpty() then
                        exit;
                    if ConfirmManagement.GetResponseOrDefault(ConceptLinksWillBeDeletedMsg, true) then
                        DIOTConceptLink.DeleteAll()
                    else
                        "Column Type" := xRec."Column Type";
                end;
            end;
        }

        field(5; "Non-Deductible"; Boolean)
        {
            Caption = 'Non-Deductible';

            trigger OnValidate()
            begin
                if xRec."Non-Deductible" <> "Non-Deductible" then
                    if not "Non-Deductible" then
                        "Non-Deductible Pct" := 0;
            end;
        }

        field(6; "Non-Deductible Pct"; Decimal)
        {
            Caption = 'Non-Deductible percent';
            MinValue = 0;

            trigger OnValidate()
            begin
                if xRec."Non-Deductible Pct" <> "Non-Deductible Pct" then
                    "Non-Deductible" := "Non-Deductible Pct" > 0;
            end;
        }
        field(7; "VAT Links Count"; Integer)
        {
            Caption = 'VAT Links Count';
            FieldClass = FlowField;
            CalcFormula = Count("DIOT Concept Link" WHERE("DIOT Concept No." = FIELD("Concept No.")));
        }
    }

    keys
    {
        key(PK; "Concept No.")
        {
            Clustered = true;
        }
    }

    var
        ConceptLinksWillBeDeletedMsg: Label 'Selecting None as column type will delete all existing links to this concept. Continue?';

    procedure GetColumnNo(ConceptNo: Integer): Integer
    begin
        if get(ConceptNo) then;
        exit("Column No.");
    end;

    procedure CheckLinksForConceptWithTypeNotNone(): Boolean
    var
        DIOTConcept: Record "DIOT Concept";
        DIOTConceptLink: Record "DIOT Concept Link";
    begin
        DIOTConcept.SetFilter("Column Type", '<>%1', DIOTConcept."Column Type"::None);
        if DIOTConcept.FindSet() then
            repeat
                DIOTConceptLink.SetRange("DIOT Concept No.", DIOTConcept."Concept No.");
                if DIOTConceptLink.IsEmpty() then
                    exit(true);
            until DIOTConcept.Next() = 0;
    end;
}
