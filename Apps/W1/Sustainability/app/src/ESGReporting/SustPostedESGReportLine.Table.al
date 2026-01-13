// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using Microsoft.Finance.Analysis.StatisticalAccount;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.HumanResources.Employee;
using Microsoft.Integration.Dataverse;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Scorecard;
using System.Reflection;

table 6232 "Sust. Posted ESG Report Line"
{
    Caption = 'Posted ESG Report Line';
    DataClassification = CustomerContent;
    LookupPageId = "Sust. Posted ESG Report Lines";
    DrillDownPageId = "Sust. Posted ESG Report Lines";

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
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; "Grouping"; Text[100])
        {
            Caption = 'Grouping';
        }
        field(6; "Row No."; Code[10])
        {
            Caption = 'Row No.';
        }
        field(7; Description; Text[500])
        {
            Caption = 'Description';
        }
#pragma warning disable AS0086
#pragma warning disable AS0004
        field(8; "Reporting Code"; Text[100])
        {
            Caption = 'Reporting Code';
        }
#pragma warning restore AS0004
#pragma warning restore AS0086
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
                    Validate("Field No.", 0);
                    Rec.Validate(Source, '');
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
            TableRelation = "Sust. ESG Reporting Unit".Code;
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
        field(36; "Concept Link"; Text[840])
        {
            Caption = 'Concept Link';
        }
        field(37; "Concept"; Text[400])
        {
            Caption = 'Concept';
        }
        field(40; "Posted Amount"; Decimal)
        {
            Caption = 'Posted Amount';
        }
        field(50; "Coupled to Dataverse"; Boolean)
        {
            FieldClass = FlowField;
            Caption = 'Coupled to Dataverse';
            Editable = false;
            CalcFormula = exist("CRM Integration Record" where("Integration ID" = field(SystemId), "Table ID" = const(Database::"Sust. Posted ESG Report Line")));
            ToolTip = 'Specifies that the posted reporting line is coupled to an esg fact in Dataverse.';
        }
        field(55; "Derived From SystemId"; Guid)
        {
            Caption = 'Derived From SystemId';
            TableRelation = "Sust. ESG Reporting Line".SystemId;
        }
        field(60; "Assessment ID"; Guid)
        {
            Caption = 'Assessment ID';
        }
        field(61; "Standard Requirement ID"; Guid)
        {
            Caption = 'Standard Requirement ID';
        }
        field(62; "Parent Standard Requirement ID"; Guid)
        {
            Caption = 'Parent Standard Requirement ID';
        }
        field(63; "Requirement Concept ID"; Guid)
        {
            Caption = 'Requirement Concept ID';
        }
        field(64; "Concept ID"; Guid)
        {
            Caption = 'Concept ID';
        }
        field(65; "Assessment Requirement ID"; Guid)
        {
            Caption = 'Assessment Requirement ID';
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    procedure LookupTotaling()
    var
        GLAccList: Page "G/L Account List";
        SustAccountList: Page "Sustainability Account List";
        StatisticalAccountList: Page "Statistical Account List";
        EmployeeList: Page "Employee List";
    begin
        case Rec."Table No." of
            Database::"Sustainability Goal",
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

    internal procedure CopyFromESGReportingLine(ESGReportingLine: Record "Sust. ESG Reporting Line");
    begin
        Rec."ESG Reporting Template Name" := ESGReportingLine."ESG Reporting Template Name";
        Rec."ESG Reporting Name" := ESGReportingLine."ESG Reporting Name";
        Rec."Line No." := ESGReportingLine."Line No.";
        Rec.Grouping := ESGReportingLine.Grouping;
        Rec."Row No." := ESGReportingLine."Row No.";
        Rec.Description := ESGReportingLine.Description;
        Rec."Reporting Code" := ESGReportingLine."Reporting Code";
        Rec."Field Type" := ESGReportingLine."Field Type";
        Rec."Table No." := ESGReportingLine."Table No.";
        Rec."Field No." := ESGReportingLine."Field No.";
        Rec.Source := ESGReportingLine.Source;
        Rec."Field Caption" := ESGReportingLine."Field Caption";
        Rec."Value Settings" := ESGReportingLine."Value Settings";
        Rec."Account Filter" := ESGReportingLine."Account Filter";
        Rec."Date Filter" := ESGReportingLine."Date Filter";
        Rec."Reporting Unit" := ESGReportingLine."Reporting Unit";
        Rec."Row Type" := ESGReportingLine."Row Type";
        Rec."Row Totaling" := ESGReportingLine."Row Totaling";
        Rec."Calculate With" := ESGReportingLine."Calculate With";
        Rec.Show := ESGReportingLine.Show;
        Rec."Show With" := ESGReportingLine."Show With";
        Rec."Rounding" := ESGReportingLine."Rounding";
        Rec."Goal SystemID" := ESGReportingLine."Goal SystemID";
        Rec."Concept Link" := ESGReportingLine."Concept Link";
        Rec."Concept" := ESGReportingLine."Concept";
        Rec."Derived From SystemId" := ESGReportingLine."Derived From SystemId";
        Rec."Assessment ID" := ESGReportingLine."Assessment ID";
        Rec."Standard Requirement ID" := ESGReportingLine."Standard Requirement ID";
        Rec."Parent Standard Requirement ID" := ESGReportingLine."Parent Standard Requirement ID";
        Rec."Requirement Concept ID" := ESGReportingLine."Requirement Concept ID";
        Rec."Concept ID" := ESGReportingLine."Concept ID";
        Rec."Assessment Requirement ID" := ESGReportingLine."Assessment Requirement ID";
    end;
}