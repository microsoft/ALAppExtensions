// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ESGReporting;

using Microsoft.Foundation.NoSeries;
using Microsoft.Integration.Dataverse;
using Microsoft.Sustainability.Setup;

table 6253 "Sust. ESG Standard"
{
    Caption = 'ESG Standard';
    DataCaptionFields = "No.", Description;
    LookupPageID = "Sust. ESG Standards";
    DrillDownPageId = "Sust. ESG Standards";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                TestNoSeries();
            end;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(10; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
        }
        field(20; "Coupled to Dataverse"; Boolean)
        {
            FieldClass = FlowField;
            Caption = 'Coupled to Dataverse';
            Editable = false;
            CalcFormula = exist("CRM Integration Record" where("Integration ID" = field(SystemId), "Table ID" = const(Database::"Sust. ESG Standard")));
            ToolTip = 'Specifies that the standard is coupled to an standard in Dataverse.';
        }
        field(30; "Standard ID"; Guid)
        {
            Caption = 'Standard ID';
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        ESGStandard: Record "Sust. ESG Standard";
    begin
        if "No." = '' then begin
            SustainabilitySetup.GetRecordOnce();
            SustainabilitySetup.TestField("ESG Standard Reporting Nos.");
            "No. Series" := SustainabilitySetup."ESG Standard Reporting Nos.";
            if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                "No. Series" := xRec."No. Series";

            "No." := NoSeries.GetNextNo("No. Series");
            ESGStandard.ReadIsolation(IsolationLevel::ReadUncommitted);
            ESGStandard.SetLoadFields("No.");
            while ESGStandard.Get("No.") do
                "No." := NoSeries.GetNextNo("No. Series");
        end;
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        NoSeries: Codeunit "No. Series";

    procedure AssistEdit(OldESGStandard: Record "Sust. ESG Standard"): Boolean
    var
        ESGStandard: Record "Sust. ESG Standard";
    begin
        ESGStandard := Rec;
        SustainabilitySetup.Get();
        SustainabilitySetup.TestField("ESG Standard Reporting Nos.");
        if NoSeries.LookupRelatedNoSeries(SustainabilitySetup."ESG Standard Reporting Nos.", OldESGStandard."No. Series", ESGStandard."No. Series") then begin
            ESGStandard."No." := NoSeries.GetNextNo(ESGStandard."No. Series");
            Rec := ESGStandard;

            exit(true);
        end;
    end;

    local procedure TestNoSeries()
    var
        ESGStandard: Record "Sust. ESG Standard";
    begin
        if "No." <> xRec."No." then
            if not ESGStandard.Get(Rec."No.") then begin
                SustainabilitySetup.Get();
                NoSeries.TestManual(SustainabilitySetup."ESG Standard Reporting Nos.");
                "No. Series" := '';
            end;
    end;
}