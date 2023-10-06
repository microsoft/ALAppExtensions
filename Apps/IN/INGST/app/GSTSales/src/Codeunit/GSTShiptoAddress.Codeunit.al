// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Sales;

using Microsoft.Finance.GST.Base;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;

codeunit 18151 "GST Ship To Address"
{
    var
        GSTRegistrationValidationErr: Label 'You must select the same GST Registration No. / ARN No. for all lines in Document No. = %1, Line No. = %2 Registration No. / ARN No. is  %3  should be %4.', Comment = '%1 = Document No. ; %2 = Line No.; %3 = Registration No. / ARN No.;%4 = Registration No. / ARN No. ';
        DiffJurisdictionTypeErr: Label 'All lines in the document must have same GST Jurisdiction Type.';
        GSTShipToStateCodeErr: Label 'GST Transaction with Ship-to Code is not allowed against Unregistered Customer.';
        GSTPlaceOfSupplyErr: Label 'You must select Ship-to Code or Ship-to Customer in transaction header.';
        ShipToGSTARNErr: Label 'Either Ship-To Address GST Registration No. or ARN No. in Ship-To Address should have a value.';
        CustGSTARNErr: Label 'Either Customer GST Registration No. or ARN No. in Customer should have a value.';

    procedure UpdateBilltiAddressState(var SalesHeader: Record "Sales Header")
    var
        SelltoCustomer: Record Customer;
    begin
        if SelltoCustomer.Get(SalesHeader."Sell-to Customer No.") then
            SalesHeader.State := SelltoCustomer."State Code";
    end;

    procedure UpdateShiptoAddressState(var SalesHeader: Record "Sales Header")
    var
        ShiptoAddress: Record "Ship-to Address";
    begin
        if SalesHeader."GST Customer Type" in [
                "GST Customer Type"::Exempted,
                "GST Customer Type"::"Deemed Export",
                "GST Customer Type"::"SEZ Development",
                "GST Customer Type"::"SEZ Unit",
                "GST Customer Type"::Registered] then
            if ShipToAddress.Get(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code") then
                SalesHeader.State := ShipToAddress.State;
    end;

    procedure UpdateLocationAddressState(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.State := SalesHeader."Location State Code";
    end;

    procedure SalesPostGSTPlaceOfSupply(SalesHeader: Record "Sales Header")
    var
        GSTBaseValidation: Codeunit "GST Base Validation";
        TransactionTypeEnum: Enum "Transaction Type Enum";
    begin
        if SalesHeader."GST Customer Type" = SalesHeader."GST Customer Type"::" " then
            exit;

        if not (SalesHeader."GST Customer Type" In [SalesHeader."GST Customer Type"::Export, SalesHeader."GST Customer Type"::Unregistered]) then begin
            GSTBaseValidation.CheckGSTRegistrationNo(TransactionTypeEnum::Sales, SalesHeader."Document Type", SalesHeader."No.");
            CheckSimilarGSTPlaceOfSupply(SalesHeader);
        end;
    end;

    procedure ValidateGSTRegistration(SalesLine: Record "Sales Line")
    var
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        ShiptoAddress: Record "Ship-to Address";
    begin
        SalesHeader.Get(SalesLine."Document Type", SalesLine."Document No.");
        if SalesHeader."Bill-to Customer No." = '' then
            exit;

        Customer.Get(SalesHeader."Bill-to Customer No.");
        case SalesLine."GST Place of Supply" of
            SalesLine."GST Place of Supply"::"Bill-to Address":
                case SalesHeader."GST Customer Type" of
                    SalesHeader."GST Customer Type"::Registered,
                    SalesHeader."GST Customer Type"::"Deemed Export",
                    SalesHeader."GST Customer Type"::Exempted,
                    SalesHeader."GST Customer Type"::"SEZ Development",
                    SalesHeader."GST Customer Type"::"SEZ Unit":
                        if SalesHeader."Customer GST Reg. No." = '' then
                            if Customer."ARN No." = '' then
                                Error(CustGSTARNErr);

                    SalesHeader."GST Customer Type"::Unregistered:
                        SalesHeader.TestField("GST Bill-to State Code");
                end;
            SalesLine."GST Place of Supply"::"Ship-to Address":
                begin
                    Customer.Get(SalesHeader."Sell-to Customer No.");
                    if (SalesHeader."Ship-to Code" = '') and (SalesHeader."Ship-to Customer" = '') then
                        Error(GSTPlaceOfSupplyErr);

                    if SalesHeader."Ship-to Code" <> '' then begin
                        ShiptoAddress.Get(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code");
                        case SalesHeader."GST Customer Type" of
                            SalesHeader."GST Customer Type"::Registered,
                            SalesHeader."GST Customer Type"::"Deemed Export",
                            SalesHeader."GST Customer Type"::Exempted,
                            SalesHeader."GST Customer Type"::"SEZ Development",
                            SalesHeader."GST Customer Type"::"SEZ Unit":
                                begin
                                    if SalesHeader."Ship-to GST Reg. No." = '' then
                                        if ShiptoAddress."ARN No." = '' then
                                            Error(ShipToGSTARNErr);

                                    if SalesHeader."GST Customer Type" = SalesHeader."GST Customer Type"::Registered then
                                        SalesHeader.TestField("GST Ship-to State Code");
                                end;
                            SalesHeader."GST Customer Type"::Unregistered:
                                begin
                                    SalesHeader.TestField("Ship-to GST Reg. No.", '');
                                    if SalesHeader."GST Ship-to State Code" = '' then
                                        Error(GSTShipToStateCodeErr);
                                end;
                            SalesHeader."GST Customer Type"::Export:
                                SalesHeader.TestField("Ship-to GST Reg. No.", '');
                        end;
                    end;
                end;
        end;
    end;

    local procedure CheckSimilarGSTPlaceOfSupply(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        SalesLine1: Record "Sales Line";
        PresentGSTRegNo: Code[20];
        PreviousGSTRegNo: Code[20];
    begin
        SalesLine.SetCurrentKey("Document Type", "Document No.", Type, "No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Type, '<>%1', Type::" ");
        SalesLine.SetFilter("No.", '<>%1', '');
        if SalesLine.FindSet() then
            repeat
                PresentGSTRegNo := GetGSTRegistrationNum(SalesHeader, SalesLine);
                SalesLine1.SetCurrentKey("Document Type", "Document No.", Type, "No.");
                SalesLine1.SetRange("Document Type", SalesHeader."Document Type");
                SalesLine1.SetRange("Document No.", SalesHeader."No.");
                SalesLine1.SetFilter(Type, '<>%1', SalesLine1.Type::" ");
                SalesLine1.SetFilter("No.", '<>%1', '');
                SalesLine1.SetFilter("Line No.", '<>%1', SalesLine."Line No.");
                SalesLine1.SetFilter("GST Group Code", '<>%1', '');
                SalesLine1.SetFilter("GST Place of Supply", '<>%1', SalesLine."GST Place of Supply");
                SalesLine1.SetRange("Non-GST Line", false);
                if SalesLine1.FindSet() then
                    repeat
                        PreviousGSTRegNo := GetGSTRegistrationNum(SalesHeader, SalesLine1);
                        if (PreviousGSTRegNo <> PresentGSTRegNo) and (PresentGSTRegNo <> '') then
                            Error(GSTRegistrationValidationErr, SalesLine1."Document No.", SalesLine1."Line No.", PreviousGSTRegNo, PresentGSTRegNo);

                        if SalesLine."GST Jurisdiction Type" <> SalesLine1."GST Jurisdiction Type" then
                            Error(DiffJurisdictionTypeErr);
                    until SalesLine1.next() = 0;
            until SalesLine.next() = 0;
    end;

    local procedure GetGSTRegistrationNum(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line"): Code[20]
    var
        Customer: Record Customer;
        ShipToAddress: Record "Ship-to Address";
        PresentRegNo: Code[20];
    begin
        SalesLine.TestField("GST Place of Supply");
        case SalesLine."GST Place of Supply" of
            SalesLine."GST Place of Supply"::"Bill-to Address", SalesLine."GST Place of Supply"::"Location Address":
                if SalesHeader."Customer GST Reg. No." <> '' then
                    PresentRegNo := SalesHeader."Customer GST Reg. No."
                else
                    if Customer.Get(SalesHeader."Sell-to Customer No.") then
                        PresentRegNo := Customer."ARN No.";
            SalesLine."GST Place of Supply"::"Ship-to Address":
                if SalesHeader."Ship-to GST Reg. No." <> '' then
                    PresentRegNo := SalesHeader."Ship-to GST Reg. No."
                else
                    if ShipToAddress.Get(SalesHeader."Sell-to Customer No.", SalesHeader."Ship-to Code") then
                        PresentRegNo := ShipToAddress."ARN No.";
        end;

        Exit(PresentRegNo);
    end;

    procedure CheckUpdatePreviousLineGSTPlaceofSupply(Var SalesLine: Record "Sales Line")
    var
        PreviousSalesLine: Record "Sales Line";
    begin
        PreviousSalesLine.SetCurrentKey("Document Type", "Document No.", Type, "No.");
        PreviousSalesLine.SetRange("Document Type", SalesLine."Document Type");
        PreviousSalesLine.SetRange("Document No.", SalesLine."Document No.");
        PreviousSalesLine.SetFilter(Type, '<>%1', Type::" ");
        PreviousSalesLine.SetFilter("No.", '<>%1', '');
        if PreviousSalesLine.FindFirst() then
            if PreviousSalesLine."GST Place Of Supply" <> SalesLine."GST Place Of Supply" then
                SalesLine."GST Place Of Supply" := PreviousSalesLine."GST Place Of Supply";
    end;
}
