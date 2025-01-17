﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using Microsoft.Finance.VAT.Reporting;
using Microsoft.Foundation.NoSeries;

table 5023 "Service Declaration Header"
{
    LookupPageId = "Service Declarations";
    DrillDownPageId = "Service Declarations";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            var
                NoSeries: Codeunit "No. Series";
            begin
                if "No." <> xRec."No." then begin
                    TestNoSeries();
                    NoSeries.TestManual(ServiceDeclarationSetup."Declaration No. Series");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Config. Code"; Code[20])
        {
            Caption = 'Config. Code';
            TableRelation = "VAT Reports Configuration"."VAT Report Version" WHERE("VAT Report Type" = CONST("Service Declaration"));
        }
        field(50; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
        }
        field(51; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
        }
        field(100; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(101; "Created Date-Time"; DateTime)
        {
            Caption = 'Created Date-Time';
            Editable = false;
        }
        field(102; Reported; Boolean)
        {
            Caption = 'Reported';
            Editable = false;
        }
        field(103; Status; Enum "Serv. Decl. Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(104; "Export Date"; Date)
        {
            Caption = 'Export Date';
            Editable = false;
        }
        field(105; "Export Time"; Time)
        {
            Caption = 'Export Time';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        ServiceDeclarationSetup: Record "Service Declaration Setup";
#if not CLEAN24
        NoSeriesManagement: Codeunit NoSeriesManagement;
#endif
        ServDeclAlreadyExistErr: Label 'The service declaration %1 already exists.', Comment = '%1 = service declaration number.';

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
#if not CLEAN24
        IsHandled: Boolean;
#endif
    begin
        if "No." = '' then begin
            TestNoSeries();
#if not CLEAN24
            IsHandled := false;
            NoSeriesManagement.RaiseObsoleteOnBeforeInitSeries(ServiceDeclarationSetup."Declaration No. Series", xRec."No. Series", 0D, "No.", "No. Series", IsHandled);
            if not IsHandled then begin
#endif
                "No. Series" := ServiceDeclarationSetup."Declaration No. Series";
                if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                    "No. Series" := xRec."No. Series";
                "No." := NoSeries.GetNextNo("No. Series");
#if not CLEAN24
                NoSeriesManagement.RaiseObsoleteOnAfterInitSeries("No. Series", ServiceDeclarationSetup."Declaration No. Series", 0D, "No.");
            end;
#endif
        end;
    end;

    trigger OnModify()
    begin
        CheckStatusOpen();
    end;

    trigger OnRename()
    begin
        CheckStatusOpen();
    end;

    procedure SuggestLines()
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        TestField("Starting Date");
        TestField("Ending Date");
        GetServDeclarationConfig(VATReportsConfiguration);
        VATReportsConfiguration.TestField("Suggest Lines Codeunit ID");
        Codeunit.Run(VATReportsConfiguration."Suggest Lines Codeunit ID", Rec);
    end;

    procedure CreateFile()
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        GetServDeclarationConfig(VATReportsConfiguration);
        if VATReportsConfiguration."Content Codeunit ID" <> 0 then
            Codeunit.Run(VATReportsConfiguration."Content Codeunit ID", Rec);
        if VATReportsConfiguration."Submission Codeunit ID" <> 0 then
            Codeunit.Run(VATReportsConfiguration."Submission Codeunit ID", Rec);
    end;

    procedure AssistEdit(OldServDeclHeader: Record "Service Declaration Header") Result: Boolean
    var
        ServDeclHeader: Record "Service Declaration Header";
        NoSeries: Codeunit "No. Series";
    begin
        ServDeclHeader.Copy(Rec);
        TestNoSeries();
        if NoSeries.LookupRelatedNoSeries(ServiceDeclarationSetup."Declaration No. Series", OldServDeclHeader."No. Series", ServDeclHeader."No. Series") then begin
            ServDeclHeader."No." := NoSeries.GetNextNo(ServDeclHeader."No. Series");
            if ServDeclHeader.Get(ServDeclHeader."No.") then
                Error(ServDeclAlreadyExistErr, ServDeclHeader."No.");
            Rec := ServDeclHeader;
            exit(true);
        end;
    end;

    procedure TestNoSeries()
    begin
        ServiceDeclarationSetup.Get();
        ServiceDeclarationSetup.TestField("Declaration No. Series");
    end;

    local procedure GetServDeclarationConfig(var VATReportsConfiguration: Record "VAT Reports Configuration")
    begin
        TestField("Config. Code");
        VATReportsConfiguration.Get(VATReportsConfiguration."VAT Report Type"::"Service Declaration", "Config. Code");
    end;

    procedure CheckStatusOpen()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckStatusOpen(xRec, Rec, IsHandled);
        if IsHandled then
            exit;

        TestField(Status, Status::Open);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCheckStatusOpen(xServiceDeclHeader: Record "Service Declaration Header"; ServiceDeclHeader: Record "Service Declaration Header"; var IsHandled: Boolean)
    begin
    end;
}
