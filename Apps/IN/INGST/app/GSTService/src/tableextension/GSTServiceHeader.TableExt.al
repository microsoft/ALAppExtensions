// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Document;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.GST.Sales;
using Microsoft.Finance.GST.Services;
using Microsoft.Finance.TaxBase;
using Microsoft.Service.Setup;

tableextension 18440 "GST Service Header" extends "Service Header"
{
    fields
    {
        field(18440; Trading; Boolean)
        {
            Caption = 'Trading';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                InitRecord();
            end;
        }
        field(18441; "Time of Removal"; Time)
        {
            Caption = 'Time of Removal';
            DataClassification = CustomerContent;
        }
        field(18442; "LR/RR No."; Code[20])
        {
            Caption = 'LR/RR No.';
            DataClassification = CustomerContent;
        }
        field(18443; "LR/RR Date"; Date)
        {
            Caption = 'LR/RR Date';
            DataClassification = CustomerContent;
        }
        field(18444; "Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            DataClassification = CustomerContent;
        }
        field(18445; "Mode of Transport"; Text[20])
        {
            Caption = 'Mode of Transport';
            DataClassification = CustomerContent;
        }
        field(18446; "Nature of Services"; enum "GST Nature of Service")
        {
            Caption = 'Nature of Services';
            DataClassification = CustomerContent;
        }
        field(18447; "Sale Return Type"; enum "Sale Return Type")
        {
            Caption = 'Sale Return Type';
            DataClassification = CustomerContent;
        }
        field(18448; "Nature of Supply"; enum "GST Nature of Supply")
        {
            Caption = 'Nature of Supply';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18449; "GST Customer Type"; enum "GST Customer Type")
        {
            Caption = 'GST Customer Type';
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            begin
                UpdateInvoiceTypeService(Rec);
            end;
        }
        field(18450; "Invoice Type"; enum "Sales Invoice Type")
        {
            Caption = 'Invoice Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateInvoiceType();
            end;
        }
        field(18451; "GST Without Payment of Duty"; Boolean)
        {
            Caption = 'GST Without Payment of Duty';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not ("GST Customer Type" in [
                    "GST Customer Type"::Export,
                    "GST Customer Type"::"Deemed Export",
                    "GST Customer Type"::"SEZ Development",
                    "GST Customer Type"::"SEZ Unit"]) then
                    Error(GSTPaymentDutyErr);
            end;
        }
        field(18452; "Bill Of Export No."; Code[20])
        {
            Caption = 'Bill Of Export No.';
            DataClassification = CustomerContent;
        }
        field(18453; "Bill Of Export Date"; Date)
        {
            Caption = 'Bill Of Export Date';
            DataClassification = CustomerContent;
        }
        field(18454; "GST Bill-to State Code"; Code[10])
        {
            Caption = 'GST Bill-to State Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = State;
        }
        field(18455; "GST Ship-to State Code"; Code[10])
        {
            Caption = 'GST Ship-to State Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = State;
        }
        field(18456; "Location State Code"; Code[10])
        {
            Caption = 'Location State Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = State;
        }
        field(18457; "Location GST Reg. No."; Code[20])
        {
            Caption = 'Location GST Reg. No.';
            DataClassification = CustomerContent;
            TableRelation = "GST Registration Nos.";

            trigger OnValidate()
            begin
                ValidateGSTRegistrationNo();
            end;
        }
        field(18458; "Customer GST Reg. No."; Code[20])
        {
            Caption = 'Customer GST Reg. No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18459; "Ship-to GST Reg. No."; Code[20])
        {
            Caption = 'Ship-to GST Reg. No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18460; "Reference Invoice No."; Code[20])
        {
            Caption = 'Reference Invoice No.';
            DataClassification = CustomerContent;
        }
        field(18461; "GST Reason Type"; enum "GST Reason Type")
        {
            Caption = 'GST Reason Type';
            DataClassification = CustomerContent;
        }
        field(18462; "Supply Finish Date"; enum "GST Rate Change")
        {
            Caption = 'Supply Finish Date';
            DataClassification = CustomerContent;
        }
        field(18463; "Payment Date"; enum "GST Rate Change")
        {
            Caption = 'Payment Date';
            DataClassification = CustomerContent;
        }
        field(18464; "Rate Change Applicable"; Boolean)
        {
            Caption = 'Rate Change Applicable';
            DataClassification = CustomerContent;
        }
        field(18465; "GST Inv. Rounding Precision"; Decimal)
        {
            Caption = 'GST Inv. Rounding Precision';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(18466; "GST Inv. Rounding Type"; enum "GST Inv Rounding Type")
        {
            Caption = 'GST Inv. Rounding Type';
            DataClassification = CustomerContent;
        }
        field(18467; "POS Out Of India"; Boolean)
        {
            Caption = 'POS Out Of India';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidatePOSOutofIndia();
            end;
        }
        field(18468; State; Code[10])
        {
            Caption = 'State';
            TableRelation = State;
            DataClassification = CustomerContent;
        }
    }

    var
        GSTServiceValidations: Codeunit "GST Service Validations";
        InvoiceTypeErr: Label 'You can not select the Invoice Type %1 for GST Customer Type %2.', Comment = '%1 =Invoice Type , %2 = GST Customer Type';
        ReferenceNoErr: Label 'Selected Document No does not exit for Reference Invoice No.';
        GSTPlaceOfSuppErr: Label 'You can not select POS Out Of India field on header if GST Place of Supply is Location Address.';
        InvoiceTypeShippedDocErr: Label 'You can not change the Invoice Type for Shipped Document.';
        GSTPaymentDutyErr: Label 'You can only select GST Without Payment of Duty in Export or Deemed Export Customer.';

    local procedure UpdateInvoiceTypeService(var ServiceHeader: Record "Service Header")
    begin
        case ServiceHeader."GST Customer Type" of
            ServiceHeader."GST Customer Type"::" ", ServiceHeader."GST Customer Type"::Registered, ServiceHeader."GST Customer Type"::Unregistered:
                ServiceHeader."Invoice Type" := ServiceHeader."Invoice Type"::Taxable;
            ServiceHeader."GST Customer Type"::Export, ServiceHeader."GST Customer Type"::"Deemed Export",
                ServiceHeader."GST Customer Type"::"SEZ Development", ServiceHeader."GST Customer Type"::"SEZ Unit":
                ServiceHeader."Invoice Type" := ServiceHeader."Invoice Type"::Export;
            ServiceHeader."GST Customer Type"::Exempted:
                ServiceHeader."Invoice Type" := ServiceHeader."Invoice Type"::"Bill of Supply";
        end;
    end;

    local procedure CheckAllLinesExemptedService(ServiceHeader: Record "Service Header"): Boolean
    var
        ServiceLine: Record "Service Line";
        ServiceLine1: Record "Service Line";
    begin
        ServiceLine.SetRange("Document Type", ServiceHeader."Document Type");
        ServiceLine.SetRange("Document No.", ServiceHeader."No.");
        ServiceLine1.CopyFilters(ServiceLine);
        ServiceLine1.SetRange(Exempted, true);
        if ServiceLine.Count() <> ServiceLine1.Count() then
            exit(true);
    end;

    local procedure CheckInvoiceTypeService(ServiceHeader: Record "Service Header")
    begin
        case ServiceHeader."GST Customer Type" of
            ServiceHeader."GST Customer Type"::" ", ServiceHeader."GST Customer Type"::Registered, ServiceHeader."GST Customer Type"::Unregistered:
                if ServiceHeader."Invoice Type" in [ServiceHeader."Invoice Type"::"Bill of Supply", ServiceHeader."Invoice Type"::Export] then
                    Error(InvoiceTypeErr, ServiceHeader."Invoice Type", ServiceHeader."GST Customer Type");

            ServiceHeader."GST Customer Type"::Export, ServiceHeader."GST Customer Type"::"Deemed Export",
            ServiceHeader."GST Customer Type"::"SEZ Development", ServiceHeader."GST Customer Type"::"SEZ Unit":
                if ServiceHeader."Invoice Type" in [ServiceHeader."Invoice Type"::"Bill of Supply", ServiceHeader."Invoice Type"::Taxable] then
                    Error(InvoiceTypeErr, ServiceHeader."Invoice Type", ServiceHeader."GST Customer Type");

            ServiceHeader."GST Customer Type"::Exempted:
                if ServiceHeader."Invoice Type" in [ServiceHeader."Invoice Type"::"Debit Note", ServiceHeader."Invoice Type"::Export, ServiceHeader."Invoice Type"::Taxable] then
                    Error(InvoiceTypeErr, ServiceHeader."Invoice Type", ServiceHeader."GST Customer Type");
        end;
    end;

    local procedure CheckShippedDocumentServiceLine()
    var
        ServiceLine: Record "Service Line";
    begin
        ServiceLine.SetRange("Document Type", "Document Type");
        ServiceLine.SetRange("Document No.", "No.");
        ServiceLine.SetFilter("Qty. Shipped (Base)", '<>%1', 0);
        if not ServiceLine.IsEmpty() then
            Error(InvoiceTypeShippedDocErr);
    end;

    local procedure ValidateInvoiceType()
    var
        ServiceLine: Record "Service Line";
    begin
        if "GST Customer Type" <> "GST Customer Type"::Exempted then begin
            if CheckAllLinesExemptedService(Rec) then
                CheckInvoiceTypeService(Rec)
            else begin
                ServiceLine.Reset();
                ServiceLine.SetRange("Document Type", "Document Type");
                ServiceLine.SetRange("Document No.", "No.");
                if not ServiceLine.IsEmpty() then
                    TestField("Invoice Type", "Invoice Type"::"Bill of Supply");
            end;
        end else
            CheckInvoiceTypeService(Rec);

        CheckShippedDocumentServiceLine();
        InitRecord();

        if "Reference Invoice No." <> '' then
            if not ("Invoice Type" in ["Invoice Type"::"Debit note", "Invoice Type"::Supplementary]) then
                Error(ReferenceNoErr);

        if "Document Type" in ["Document Type"::Order, "Document Type"::Invoice] then
            GSTServiceValidations.ReferenceInvoiceNoValidation("Document Type", "No.", "Customer No.");
    end;

    local procedure ValidatePOSOutofIndia()
    var
        ServiceLine: Record "Service Line";
        GSTBaseValidation: Codeunit "GST Base Validation";
        ConfigType: Enum "Party Type";
        GSTVendorType: Enum "GST Vendor Type";
    begin
        TestField("Release Status", "Release Status"::Open);
        GSTServiceValidations.ReferenceInvoiceNoValidation("Document Type", "No.", "Customer No.");

        ServiceLine.SetRange("Document Type", "Document Type");
        ServiceLine.SetRange("Document No.", "No.");
        if ServiceLine.FindSet() then
            repeat
                if ServiceLine."GST Place Of Supply" = ServiceLine."GST Place Of Supply"::"Location Address" then
                    Error(GSTPlaceOfSuppErr);

                GSTBaseValidation.VerifyPOSOutOfIndia(
                    ConfigType::Customer,
                    "Location State Code",
                    GetPlaceOfSupplyStateCode(ServiceLine),
                    GSTVendorType::" ",
                    "GST Customer Type");
                ServiceLine.UpdateAmounts();
            until ServiceLine.Next() = 0
        else
            GSTBaseValidation.VerifyPOSOutOfIndia(ConfigType::Customer, "Location State Code", "GST Bill-to State Code", GSTVendorType::" ", "GST Customer Type");
    end;

    local procedure ValidateGSTRegistrationNo()

    var
        GSTRegistrationNos: Record "GST Registration Nos.";
    begin
        TestField("Release Status", "Release Status"::Open);
        if GSTRegistrationNos.Get("Location GST Reg. No.") then
            "Location State Code" := GSTRegistrationNos."State Code"
        else
            "Location State Code" := '';

        GSTServiceValidations.ReferenceInvoiceNoValidation("Document Type", "No.", "Customer No.");
        "POS Out Of India" := false;
    end;

    local procedure GetPlaceOfSupplyStateCode(ServiceLine: Record "Service Line"): Code[10]
    var
        ServiceHeader: Record "Service Header";
        ServiceMgtSetup: Record "Service Mgt. Setup";
        PlaceofSupplyStateCode: Code[10];
    begin
        ServiceMgtSetup.Get();
        ServiceHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.");
        case ServiceLine."GST Place Of Supply" of
            ServiceLine."GST Place Of Supply"::"Bill-to Address":
                PlaceofSupplyStateCode := ServiceHeader."GST Bill-to State Code";
            ServiceLine."GST Place Of Supply"::"Ship-to Address":
                PlaceofSupplyStateCode := ServiceHeader."GST Ship-to State Code";
            ServiceLine."GST Place Of Supply"::"Location Address":
                PlaceofSupplyStateCode := ServiceHeader."Location State Code";
            ServiceLine."GST Place Of Supply"::" ":
                if ServiceMgtSetup."GST Dependency Type" = ServiceMgtSetup."GST Dependency Type"::"Bill-to Address" then
                    PlaceofSupplyStateCode := ServiceHeader."GST Bill-to State Code"
                else
                    if ServiceMgtSetup."GST Dependency Type" = ServiceMgtSetup."GST Dependency Type"::"Ship-to Address" then
                        PlaceofSupplyStateCode := ServiceHeader."GST Ship-to State Code";
        end;

        exit(PlaceofSupplyStateCode);
    end;
}
