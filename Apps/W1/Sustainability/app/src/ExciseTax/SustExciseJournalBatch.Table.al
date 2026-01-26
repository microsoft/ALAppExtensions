// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.NoSeries;

table 6239 "Sust. Excise Journal Batch"
{
    Caption = 'Excise Journal Batch';
    DataClassification = CustomerContent;
    DataPerCompany = true;
    Extensible = true;
    DataCaptionFields = Name, Description;

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Sust. Excise Journal Template";
            NotBlank = true;
        }
        field(2; Name; Code[10])
        {
            Caption = 'Batch Name';
            NotBlank = true;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(4; "No Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(5; "Type"; Enum "Sust. Excise Jnl. Tax Type")
        {
            Caption = 'Type';
        }
        field(6; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";

            trigger OnValidate()
            var
                SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line";
            begin
                if "Source Code" <> xRec."Source Code" then begin
                    SustainabilityExciseJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                    SustainabilityExciseJnlLine.SetRange("Journal Batch Name", Name);
                    SustainabilityExciseJnlLine.ModifyAll("Source Code", "Source Code");
                end;
            end;
        }
        field(7; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";

            trigger OnValidate()
            var
                SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line";
            begin
                if "Reason Code" <> xRec."Reason Code" then begin
                    SustainabilityExciseJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                    SustainabilityExciseJnlLine.SetRange("Journal Batch Name", Name);
                    SustainabilityExciseJnlLine.ModifyAll("Reason Code", "Reason Code");
                end;
            end;
        }
    }
    keys
    {
        key(PK; "Journal Template Name", Name)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line";
    begin
        SustainabilityExciseJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        SustainabilityExciseJnlLine.SetRange("Journal Batch Name", Name);
        SustainabilityExciseJnlLine.DeleteAll(true);
    end;

    trigger OnInsert()
    var
        SustainabilityExciseJnlTemplate: Record "Sust. Excise Journal Template";
    begin
        SustainabilityExciseJnlTemplate.Get("Journal Template Name");
    end;
}