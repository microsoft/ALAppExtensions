// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 11718 "VAT Stmt. Report Line Data CZL"
{
    Caption = 'VAT Statement Report Line Data CZL';
    DrillDownPageId = "VAT Stmt. Report Line Data CZL";
    LookupPageId = "VAT Stmt. Report Line Data CZL";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "VAT Report No."; Code[20])
        {
            Caption = 'VAT Report No.';
            Editable = false;
            TableRelation = "VAT Report Header"."No.";
        }
        field(2; "VAT Report Config. Code"; Enum "VAT Report Configuration")
        {
            Caption = 'VAT Report Config. Code';
            Editable = false;
            TableRelation = "VAT Reports Configuration"."VAT Report Type";
        }
        field(3; "VAT Report Line No."; Integer)
        {
            Caption = 'VAT Report Line No.';
            Editable = false;
        }
        field(4; "Statement Template Name"; Code[10])
        {
            Caption = 'Statement Template Name';
            TableRelation = "VAT Statement Template";
            Editable = false;
        }
        field(5; "Statement Name"; Code[10])
        {
            Caption = 'Statement Name';
            TableRelation = "VAT Statement Name".Name where("Statement Template Name" = field("Statement Template Name"));
            Editable = false;
        }
        field(6; "Statement Line No."; Integer)
        {
            Caption = 'Statement Line No.';
            Editable = false;
        }
        field(10; "Row No."; Code[10])
        {
            Caption = 'Row No.';
            Editable = false;
        }
        field(11; Description; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(15; "XML Code"; Code[20])
        {
            Caption = 'XML Code';
            Editable = false;
        }
        field(16; "VAT Report Amount Type"; Enum "VAT Report Amount Type CZL")
        {
            Caption = 'VAT Return Amount Type';
            Editable = false;
        }
        field(20; "Amount"; Decimal)
        {
            Caption = 'Amount';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "VAT Report No.", "VAT Report Config. Code", "VAT Report Line No.", "Statement Template Name", "Statement Name", "Statement Line No.")
        {
            Clustered = true;
        }
    }

    procedure SetFilterTo(VATStatementReportLine: Record "VAT Statement Report Line")
    begin
        SetRange("VAT Report No.", VATStatementReportLine."VAT Report No.");
        SetRange("VAT Report Config. Code", VATStatementReportLine."VAT Report Config. Code");
        SetRange("VAT Report Line No.", VATStatementReportLine."Line No.");
    end;

    procedure SetFilterTo(VATReportHeader: Record "VAT Report Header")
    begin
        SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        SetRange("VAT Report No.", VATReportHeader."No.");
    end;

    procedure CopyFrom(VATStatementLine: Record "VAT Statement Line")
    begin
        "Statement Template Name" := VATStatementLine."Statement Template Name";
        "Statement Name" := VATStatementLine."Statement Name";
        "Statement Line No." := VATStatementLine."Line No.";
        "Row No." := VATStatementLine."Row No.";
        Description := VATStatementLine.Description;
    end;

    procedure CopyFrom(VATStatementReportLine: Record "VAT Statement Report Line")
    begin
        "VAT Report No." := VATStatementReportLine."VAT Report No.";
        "VAT Report Config. Code" := VATStatementReportLine."VAT Report Config. Code";
        "VAT Report Line No." := VATStatementReportLine."Line No.";
    end;

    procedure CopyFrom(VATAttributeCodeCZL: Record "VAT Attribute Code CZL")
    begin
        "XML Code" := VATAttributeCodeCZL."XML Code";
        "VAT Report Amount Type" := VATAttributeCodeCZL."VAT Report Amount Type";
    end;
}