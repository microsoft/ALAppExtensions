namespace Microsoft.Sustainability.Journal;

using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Sustainability.Account;

table 6213 "Sustainability Jnl. Batch"
{
    Access = Public;
    Caption = 'Sustainability Journal Batch';
    DataClassification = CustomerContent;
    DataPerCompany = true;
    Extensible = true;
    DataCaptionFields = Name, Description;

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Sustainability Jnl. Template";
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
        field(5; "Emission Scope"; Enum "Emission Scope")
        {
            Caption = 'Emission Scope';
        }
        field(6; "Source Code"; Code[10])
        {
            Caption = 'Source Code';
            TableRelation = "Source Code";

            trigger OnValidate()
            var
                SustainabilityJnlLine: Record "Sustainability Jnl. Line";
            begin
                if "Source Code" <> xRec."Source Code" then begin
                    SustainabilityJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                    SustainabilityJnlLine.SetRange("Journal Batch Name", Name);
                    SustainabilityJnlLine.ModifyAll("Source Code", "Source Code");
                end;
            end;
        }
        field(7; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";

            trigger OnValidate()
            var
                SustainabilityJnlLine: Record "Sustainability Jnl. Line";
            begin
                if "Reason Code" <> xRec."Reason Code" then begin
                    SustainabilityJnlLine.SetRange("Journal Template Name", "Journal Template Name");
                    SustainabilityJnlLine.SetRange("Journal Batch Name", Name);
                    SustainabilityJnlLine.ModifyAll("Reason Code", "Reason Code");
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
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
    begin
        SustainabilityJnlLine.SetRange("Journal Template Name", "Journal Template Name");
        SustainabilityJnlLine.SetRange("Journal Batch Name", Name);
        SustainabilityJnlLine.DeleteAll(true);
    end;

    trigger OnInsert()
    var
        SustainabilityJnlTemplate: Record "Sustainability Jnl. Template";
    begin
        SustainabilityJnlTemplate.Get("Journal Template Name");
    end;
}