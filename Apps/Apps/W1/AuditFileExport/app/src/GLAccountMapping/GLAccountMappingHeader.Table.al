// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Foundation.Period;
using System.Utilities;

table 5260 "G/L Account Mapping Header"
{
    DataClassification = CustomerContent;
    Caption = 'G/L Account Mapping';
    LookupPageId = "G/L Account Mapping";
    DrillDownPageId = "G/L Account Mapping";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; "Standard Account Type"; enum "Standard Account Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Standard Account Type';

            trigger OnValidate()
            var
                GLAccountMappingLine: Record "G/L Account Mapping Line";
                AuditMappingHelper: Codeunit "Audit Mapping Helper";
                IAuditFileExportDataHandling: Interface "Audit File Export Data Handling";
            begin
                if "Standard Account Type" <> xRec."Standard Account Type" then begin
                    AuditMappingHelper.VerifyNoMappingDone(xRec);

                    if not AuditMappingHelper.AreStandardAccountsLoaded("Standard Account Type") then begin
                        IAuditFileExportDataHandling := "Audit File Export Format";
                        IAuditFileExportDataHandling.LoadStandardAccounts("Standard Account Type");
                    end;

                    GLAccountMappingLine.SetRange("G/L Account Mapping Code", Code);
                    GLAccountMappingLine.ModifyAll("Standard Account Type", "Standard Account Type");
                end;
            end;
        }
        field(3; "Audit File Export Format"; enum "Audit File Export Format")
        {
            DataClassification = CustomerContent;
            Caption = 'Audit File Export Format';
            Editable = false;
        }
        field(10; "Starting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                CheckDateConsistency();
                if "Starting Date" = 0D then
                    "Period Type" := "G/L Acc. Mapping Period Type"::None
                else begin
                    "Accounting Period" := 0D;
                    "Period Type" := "G/L Acc. Mapping Period Type"::"Date Range";
                end;
            end;
        }
        field(11; "Ending Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Ending Date';

            trigger OnValidate()
            begin
                CheckDateConsistency();
                if "Ending Date" = 0D then
                    "Period Type" := "G/L Acc. Mapping Period Type"::None
                else begin
                    "Accounting Period" := 0D;
                    "Period Type" := "G/L Acc. Mapping Period Type"::"Date Range";
                end;
            end;
        }
        field(12; "Period Type"; enum "G/L Acc. Mapping Period Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Period Type';
            Editable = false;
        }
        field(13; "Accounting Period"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Accounting Period';
            TableRelation = "Accounting Period" where("New Fiscal Year" = const(true));

            trigger OnValidate()
            var
                AccountingPeriod: Record "Accounting Period";
            begin
                if "Accounting Period" = 0D then
                    "Period Type" := "G/L Acc. Mapping Period Type"::None
                else
                    if AccountingPeriod.Get("Accounting Period") then begin
                        "Period Type" := "G/L Acc. Mapping Period Type"::"Accounting Period";
                        "Starting Date" := AccountingPeriod."Starting Date";
                        "Ending Date" := AccountingPeriod.GetFiscalYearEndDate("Starting Date");
                        if "Ending Date" = 0D then
                            Error(CannotSelectAccPeriodWithoutEndingDateErr);
                    end;
            end;
        }
        field(14; "Include Incoming Balance"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Include Incoming Balance';
        }
        field(15; "Standard Account Category No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Standard Account Category No.';
            TableRelation = "Standard Account Category"."No." where("Standard Account Type" = field("Standard Account Type"));

            trigger OnValidate()
            begin
                "Standard Account No." := '';
                UpdateGLAccountMapping(FieldNo("Standard Account Category No."));
            end;
        }
        field(16; "Standard Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Standard Account No.';
            TableRelation = "Standard Account"."No." where(Type = field("Standard Account Type"), "Category No." = field("Standard Account Category No."));

            trigger OnValidate()
            begin
                UpdateGLAccountMapping(FieldNo("Standard Account No."));
            end;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Code, "Period Type", "Starting Date", "Ending Date")
        {

        }
    }

    var
        DatesAreNotCorrectErr: label 'The starting date is later than the ending date.';
        MappingExistQst: label 'One or more G/L Account are already mapped. Do you want to remove the mapping?';
        AuditFileExportDocExistsErr: label 'One or more audit file export documents exist for the mapping. Do you want to remove the mapping?';
        CannotSelectAccPeriodWithoutEndingDateErr: label 'You cannot select the accounting period that does not have the ending date.';
        OverwriteMappingQst: label 'Do you want to change the already defined G/L account mapping to a new mapping?';

    trigger OnInsert()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
    begin
        AuditFileExportSetup.Get();
        Validate("Audit File Export Format", AuditFileExportSetup."Audit File Export Format");
        Validate("Standard Account Type", AuditFileExportSetup."Standard Account Type");
    end;

    trigger OnDelete()
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        AuditFileExportHeader: Record "Audit File Export Header";
        ConfirmMgt: Codeunit "Confirm Management";
    begin
        AuditFileExportHeader.SetRange("G/L Account Mapping Code", Code);
        if not AuditFileExportHeader.IsEmpty() then
            if ConfirmMgt.GetResponseOrDefault(AuditFileExportDocExistsErr, false) then
                AuditFileExportHeader.DeleteAll(true)
            else
                Error('');
        GLAccountMappingLine.SetRange("G/L Account Mapping Code", Code);
        GLAccountMappingLine.SetFilter("Standard Account No.", '<>%1', '');
        if not GLAccountMappingLine.IsEmpty() then
            if ConfirmMgt.GetResponseOrDefault(MappingExistQst, false) then
                GLAccountMappingLine.DeleteAll(true)
            else
                Error('');

    end;

    local procedure CheckDateConsistency()
    begin
        if ("Starting Date" <> 0D) and ("Ending Date" <> 0D) and ("Starting Date" > "Ending Date") then
            Error(DatesAreNotCorrectErr);
    end;

    local procedure UpdateGLAccountMapping(UpdateFieldNo: Integer)
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        ConfirmMgt: Codeunit "Confirm Management";
    begin
        if UpdateFieldNo = 0 then
            exit;

        if not ConfirmMgt.GetResponseOrDefault(OverwriteMappingQst, false) then
            exit;

        GLAccountMappingLine.SetRange("G/L Account Mapping Code", Code);
        case UpdateFieldNo of
            FieldNo("Standard Account Category No."):
                begin
                    GLAccountMappingLine.ModifyAll("Standard Account Category No.", "Standard Account Category No.");
                    GLAccountMappingLine.ModifyAll("Standard Account No.", '');
                end;
            FieldNo("Standard Account No."):
                GLAccountMappingLine.ModifyAll("Standard Account No.", "Standard Account No.");
        end;
    end;
}
