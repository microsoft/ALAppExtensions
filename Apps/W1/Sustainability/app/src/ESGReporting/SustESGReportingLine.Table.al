// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using Microsoft.Finance.Analysis.StatisticalAccount;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.HumanResources.Employee;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Scorecard;
using System.Reflection;

table 6230 "Sust. ESG Reporting Line"
{
    Caption = 'ESG Reporting Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "ESG Reporting Template Name"; Code[10])
        {
            Caption = 'ESG Reporting Template Name';
            TableRelation = "Sust. ESG Reporting Template";
        }
        field(2; "ESG Reporting Name"; Code[10])
        {
            Caption = 'ESG Reporting Name';
            TableRelation = "Sust. ESG Reporting Name".Name where("ESG Reporting Template Name" = field("ESG Reporting Template Name"));
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; "Grouping"; Code[10])
        {
            Caption = 'Grouping';
        }
        field(6; "Row No."; Code[10])
        {
            Caption = 'Row No.';
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; "Reporting Code"; Code[20])
        {
            Caption = 'Reporting Code';
        }
        field(9; "Field Type"; Enum "Sust. ESG Reporting Field Type")
        {
            Caption = 'Field Type';

            trigger OnValidate()
            begin
                if (Rec."Field Type" <> Rec."Field Type"::"Table Field") and (xRec."Field Type" = Rec."Field Type"::"Table Field") then
                    Rec.Validate("Table No.", 0);
            end;
        }
        field(10; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = if ("Field Type" = const("Table Field")) AllObj."Object Id" where("Object Type" = const(Table));

            trigger OnValidate()
            var
                AllObj: Record AllObj;
            begin
                if Rec."Table No." <> 0 then begin
                    AllObj.Get(AllObj."Object Type"::Table, Rec."Table No.");

                    Rec.Validate(Source, AllObj."Object Name");
                end else begin
                    Rec.Validate("Field No.", 0);
                    Rec.Validate(Source, '');
                    Rec.Validate("Account Filter", '');
                end;
            end;
        }
        field(11; "Field No."; Integer)
        {
            Caption = 'Field No.';

            trigger OnValidate()
            var
                Field: Record "Field";
                TypeHelper: Codeunit "Type Helper";
            begin
                if "Field No." <> 0 then begin
                    Field.Get("Table No.", "Field No.");

                    TypeHelper.TestFieldIsNotObsolete(Field);
                    Rec.Validate("Field Caption", Field."Field Caption");
                end else
                    Rec.Validate("Field Caption", '');
            end;

            trigger OnLookup()
            var
                Field: Record Field;
                FieldSelection: Codeunit "Field Selection";
            begin
                Field.Reset();
                Field.SetRange(TableNo, "Table No.");
                if FieldSelection.Open(Field) then
                    Validate("Field No.", Field."No.");
            end;
        }
        field(15; Source; Text[250])
        {
            Caption = 'Source';
        }
        field(16; "Field Caption"; Text[250])
        {
            Caption = 'Value';
        }
        field(20; "Value Settings"; Enum "Sust. ESG Value Settings")
        {
            Caption = 'Value Settings';
        }
        field(21; "Account Filter"; Text[250])
        {
            Caption = 'Account Filter';

            trigger OnValidate()
            begin
                if Rec."Account Filter" = '' then
                    Rec.Validate("Goal SystemID", EmptyGuid);
            end;

            trigger OnLookup()
            begin
                LookupTotaling();
            end;
        }
        field(22; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            Editable = false;
            FieldClass = FlowFilter;
        }
        field(25; "Reporting Unit"; Code[20])
        {
            Caption = 'Reporting Unit';
        }
        field(27; "Row Type"; Option)
        {
            Caption = 'Row Type';
            OptionCaption = 'Net Change,Balance at Date,Year to Date,Beginning Balance';
            OptionMembers = "Net Change","Balance at Date","Year to Date","Beginning Balance";
        }
        field(28; "Row Totaling"; Text[50])
        {
            Caption = 'Row Totaling';
        }
        field(30; "Calculate With"; Option)
        {
            Caption = 'Calculate With';
            OptionCaption = 'Sign,Opposite Sign';
            OptionMembers = Sign,"Opposite Sign";
        }
        field(31; Show; Boolean)
        {
            Caption = 'Show';
        }
        field(32; "Show With"; Option)
        {
            Caption = 'Show With';
            OptionCaption = 'Sign,Opposite Sign';
            OptionMembers = Sign,"Opposite Sign";
        }
        field(33; "Rounding"; Enum "Sust. ESG Rounding Factor")
        {
            Caption = 'Rounding';
        }
        field(35; "Goal SystemID"; Guid)
        {
            Caption = 'Goal SystemID';
        }
    }

    keys
    {
        key(Key1; "ESG Reporting Template Name", "ESG Reporting Name", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        EmptyGuid: Guid;

    procedure LookupTotaling()
    var
        SustainabilityGoal: Record "Sustainability Goal";
        GLAccList: Page "G/L Account List";
        SustAccountList: Page "Sustainability Account List";
        StatisticalAccountList: Page "Statistical Account List";
        EmployeeList: Page "Employee List";
        SustainabilityGoals: Page "Sustainability Goals";
    begin
        case Rec."Table No." of
            Database::"Sustainability Goal":
                begin
                    SustainabilityGoals.LookupMode(true);
                    if SustainabilityGoals.RunModal() = Action::LookupOK then begin
                        SustainabilityGoals.GetRecord(SustainabilityGoal);
                        Validate("Account Filter", Format(SustainabilityGoal.RecordId()));
                        Validate("Goal SystemID", SustainabilityGoal.SystemId);
                    end;
                end;
            Database::"Sustainability Ledger Entry":
                begin
                    SustAccountList.LookupMode(true);
                    if SustAccountList.RunModal() = Action::LookupOK then
                        Validate("Account Filter", SustAccountList.GetSelectionFilter());
                end;
            Database::"Statistical Ledger Entry":
                begin
                    StatisticalAccountList.LookupMode(true);
                    if StatisticalAccountList.RunModal() = Action::LookupOK then
                        Validate("Account Filter", StatisticalAccountList.GetSelectionFilter());
                end;
            Database::"G/L Entry":
                begin
                    GLAccList.LookupMode(true);
                    if GLAccList.RunModal() = Action::LookupOK then
                        Validate("Account Filter", GLAccList.GetSelectionFilter());
                end;
            Database::Employee:
                begin
                    EmployeeList.LookupMode(true);
                    if EmployeeList.RunModal() = Action::LookupOK then
                        Validate("Account Filter", EmployeeList.GetSelectionFilter());
                end;
        end;
    end;
}