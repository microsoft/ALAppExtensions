// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Reconcilation;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;

table 18280 "GST Reconcilation"
{
    Caption = 'GST Reconcilation';

    fields
    {
        field(1; "GSTIN No."; Code[20])
        {
            Caption = 'GSTIN No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "GST Registration Nos.";

            trigger OnValidate()
            var
                GSTRegistrationNos: Record "GST Registration Nos.";
            begin
                "Input Service Distributor" := false;
                if GSTRegistrationNos.Get("GSTIN No.") then
                    "Input Service Distributor" := GSTRegistrationNos."Input Service Distributor";
                if CheckReconciliationLine(xRec."GSTIN No.", Month, Year) then
                    Error(GSTRegNoErr, "GSTIN No.");
            end;
        }
        field(2; Month; Integer)
        {
            Caption = 'Month';
            DataClassification = CustomerContent;
            MaxValue = 12;
            MinValue = 1;
            NotBlank = true;

            trigger OnValidate()
            begin
                if CheckReconciliationLine("GSTIN No.", xRec.Month, Year) then
                    Error(MonthModifyErr, Month, "GSTIN No.");
            end;
        }
        field(3; Year; Integer)
        {
            Caption = 'Year';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnValidate()
            var
                GeneralLedgerSetup: Record "General Ledger Setup";
            begin
                GeneralLedgerSetup.Get();
                "GST Recon. Tolerance" := GeneralLedgerSetup."GST Recon. Tolerance";
                if StrLen(Format(Year)) <= 3 then
                    Error(YearFormatErr);
                if CheckReconciliationLine("GSTIN No.", Month, xRec.Year) then
                    Error(ModifyYearErr, Year, "GSTIN No.");

            end;
        }
        field(4; "Document No"; Code[20])
        {
            Caption = 'Document No';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(6; "GST Recon. Tolerance"; Decimal)
        {
            Caption = 'GST Recon. Tolerance';
            DataClassification = CustomerContent;
        }
        field(7; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = SystemMetadata;
        }
        field(8; "Input Service Distributor"; Boolean)
        {
            Caption = 'Input Service Distributor';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "GSTIN No.", Month, Year)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        GSTReconcilationLines: Record "GST Reconcilation Line";
        PeriodicGSTR2AData: Record "Periodic GSTR-2A Data";
    begin
        GSTReconcilationLines.SetRange("GSTIN No.", "GSTIN No.");
        GSTReconcilationLines.SetRange(Month, Month);
        GSTReconcilationLines.SetRange(Year, Year);
        GSTReconcilationLines.DeleteAll(true);

        PeriodicGSTR2AData.SetRange("GSTIN No.", "GSTIN No.");
        PeriodicGSTR2AData.SetRange(Month, Month);
        PeriodicGSTR2AData.SetRange(Year, Year);
        PeriodicGSTR2AData.DeleteAll(true);
    end;

    var
        DimensionManagement: Codeunit DimensionManagement;
        YearFormatErr: Label 'Year Format must be YYYY.';
        MonthModifyErr: Label 'You can not modify the Month,since GST Reconciliation Lines already has records for %1 Month and for GST Registion No. %2.', Comment = '%1 = Month ,%2 = GSTIN No';
        ModifyYearErr: Label 'You can not modify the Year,since GST Reconciliation Lines already has records for %1 Year and for GST Registion No. %2.', Comment = '%1= Year, %2 = GSTIN No.';
        GSTRegNoErr: Label 'You can not modify the GSTIN No.,since GST Reconciliation Lines already has records for GST Registion No. %1.', Comment = '%1 = GSTIN No.';
        GstinNoMsg: Label '%1', Comment = '%1= GSTIN No.';

    procedure ShowDimensions()
    begin
        "Dimension Set ID" :=
            DimensionManagement.EditDimensionSet(
                "Dimension Set ID",
                StrSubstNo(GstinNoMsg, "GSTIN No."));
    end;

    local procedure CheckReconciliationLine(GSTINNo: Code[20]; InputMonth: Integer; InputYear: Integer): Boolean
    var
        GSTReconcilationLines2: Record "GST Reconcilation Line";
    begin
        GSTReconcilationLines2.SetRange("GSTIN No.", GSTINNo);
        GSTReconcilationLines2.SetRange(Month, InputMonth);
        GSTReconcilationLines2.SetRange(Year, InputYear);
        if not GSTReconcilationLines2.IsEmpty() then
            exit(true);
    end;
}
