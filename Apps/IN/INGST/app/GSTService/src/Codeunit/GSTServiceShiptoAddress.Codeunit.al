// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Services;

using Microsoft.Finance.GST.Base;
using Microsoft.Sales.Customer;
using Microsoft.Service.Document;

codeunit 18156 "GST Service Ship To Address"
{
    var
        GSTRegistrationValidationErr: Label 'You must select the same GST Registration No. / ARN No. for all lines in Document No. = %1, Line No. = %2 Registration No. / ARN No. is  %3  should be %4.', Comment = '%1 = Document No. ; %2 = Line No.; %3 = Registration No. / ARN No.;%4 = Registration No. / ARN No. ';
        DiffJurisdictionTypeErr: Label 'All lines in the document must have same GST Jurisdiction Type.';
        GSTShipToStateCodeErr: Label 'GST Transaction with Ship-to Code is not allowed against Unregistered Customer.';
        GSTPlaceOfSupplyErr: Label 'You must select Ship-to Code or Ship-to Customer in transaction header.';
        ShipToGSTARNErr: Label 'Either Ship-To Address GST Registration No. or ARN No. in Ship-To Address should have a value.';
        CustGSTARNErr: Label 'Either Customer GST Registration No. or ARN No. in Customer should have a value.';

    procedure UpdateBillToAddressState(var ServiceHeader: Record "Service Header")
    var
        SelltoCustomer: Record Customer;
    begin
        if SelltoCustomer.Get(ServiceHeader."Customer No.") then
            ServiceHeader.State := SelltoCustomer."State Code";
    end;

    procedure UpdateShiptoAddressState(var ServiceHeader: Record "Service Header")
    var
        ShiptoAddress: Record "Ship-to Address";
    begin
        if ServiceHeader."GST Customer Type" in [
                "GST Customer Type"::Exempted,
                "GST Customer Type"::"Deemed Export",
                "GST Customer Type"::"SEZ Development",
                "GST Customer Type"::"SEZ Unit",
                "GST Customer Type"::Registered] then
            if ShipToAddress.Get(ServiceHeader."Customer No.", ServiceHeader."Ship-to Code") then
                ServiceHeader.State := ShipToAddress.State;
    end;

    procedure UpdateLocationAddressState(var ServiceHeader: Record "Service Header")
    begin
        ServiceHeader.State := ServiceHeader."Location State Code";
    end;

    procedure ServicePostGSTPlaceOfSupply(ServiceHeader: Record "Service Header")
    var
        GSTBaseValidation: Codeunit "GST Base Validation";
        TransactionTypeEnum: Enum "Transaction Type Enum";
    begin
        if ServiceHeader."GST Customer Type" = ServiceHeader."GST Customer Type"::" " then
            exit;

        if not (ServiceHeader."GST Customer Type" In [ServiceHeader."GST Customer Type"::Export, ServiceHeader."GST Customer Type"::Unregistered]) then begin
            GSTBaseValidation.CheckGSTRegistrationNo(TransactionTypeEnum::Service, ServiceHeader."Document Type", ServiceHeader."No.");
            CheckSimilarGSTPlaceOfSupply(ServiceHeader);
        end;
    end;

    procedure ValidateGSTRegistration(ServiceLine: Record "Service Line")
    var
        ServiceHeader: Record "Service Header";
        Customer: Record Customer;
        ShiptoAddress: Record "Ship-to Address";
    begin
        ServiceHeader.Get(ServiceLine."Document Type", ServiceLine."Document No.");
        Customer.Get(ServiceHeader."Bill-to Customer No.");
        case ServiceLine."GST Place of Supply" of
            ServiceLine."GST Place of Supply"::"Bill-to Address":
                case ServiceHeader."GST Customer Type" of
                    ServiceHeader."GST Customer Type"::Registered,
                    ServiceHeader."GST Customer Type"::"Deemed Export",
                    ServiceHeader."GST Customer Type"::Exempted,
                    ServiceHeader."GST Customer Type"::"SEZ Development",
                    ServiceHeader."GST Customer Type"::"SEZ Unit":
                        if ServiceHeader."Customer GST Reg. No." = '' then
                            if Customer."ARN No." = '' then
                                Error(CustGSTARNErr);

                    ServiceHeader."GST Customer Type"::Unregistered:
                        ServiceHeader.TestField("GST Bill-to State Code");
                end;
            ServiceLine."GST Place of Supply"::"Ship-to Address":
                begin
                    Customer.Get(ServiceHeader."Customer No.");
                    if (ServiceHeader."Ship-to Code" = '') then
                        Error(GSTPlaceOfSupplyErr);

                    if ServiceHeader."Ship-to Code" <> '' then begin
                        ShiptoAddress.Get(ServiceHeader."Customer No.", ServiceHeader."Ship-to Code");
                        case ServiceHeader."GST Customer Type" of
                            ServiceHeader."GST Customer Type"::Registered,
                            ServiceHeader."GST Customer Type"::"Deemed Export",
                            ServiceHeader."GST Customer Type"::Exempted,
                            ServiceHeader."GST Customer Type"::"SEZ Development",
                            ServiceHeader."GST Customer Type"::"SEZ Unit":
                                begin
                                    if ServiceHeader."Ship-to GST Reg. No." = '' then
                                        if ShiptoAddress."ARN No." = '' then
                                            Error(ShipToGSTARNErr);

                                    if ServiceHeader."GST Customer Type" = ServiceHeader."GST Customer Type"::Registered then
                                        ServiceHeader.TestField("GST Ship-to State Code");
                                end;
                            ServiceHeader."GST Customer Type"::Unregistered:
                                begin
                                    ServiceHeader.TestField("Ship-to GST Reg. No.", '');
                                    if ServiceHeader."GST Ship-to State Code" = '' then
                                        Error(GSTShipToStateCodeErr);
                                end;
                            ServiceHeader."GST Customer Type"::Export:
                                ServiceHeader.TestField("Ship-to GST Reg. No.", '');
                        end;
                    end;
                end;
        end;
    end;

    local procedure CheckSimilarGSTPlaceOfSupply(ServiceHeader: Record "Service Header")
    var
        ServiceLine: Record "Service Line";
        ServiceLine1: Record "Service Line";
        PresentGSTRegNo: Code[20];
        PreviousGSTRegNo: Code[20];
    begin
        ServiceLine.SetCurrentKey("Document Type", "Document No.", Type, "No.");
        ServiceLine.SetRange("Document Type", ServiceHeader."Document Type");
        ServiceLine.SetRange("Document No.", ServiceHeader."No.");
        ServiceLine.SetFilter(Type, '<>%1', Type::" ");
        ServiceLine.SetFilter("No.", '<>%1', '');
        if ServiceLine.FindSet() then
            repeat
                PresentGSTRegNo := GetGSTRegistrationNum(ServiceHeader, ServiceLine);
                ServiceLine1.SetCurrentKey("Document Type", "Document No.", Type, "No.");
                ServiceLine1.SetRange("Document Type", ServiceHeader."Document Type");
                ServiceLine1.SetRange("Document No.", ServiceHeader."No.");
                ServiceLine1.SetFilter(Type, '<>%1', ServiceLine1.Type::" ");
                ServiceLine1.SetFilter("No.", '<>%1', '');
                ServiceLine1.SetFilter("Line No.", '<>%1', ServiceLine."Line No.");
                ServiceLine1.SetFilter("GST Group Code", '<>%1', '');
                ServiceLine1.SetFilter("GST Place of Supply", '<>%1', ServiceLine."GST Place of Supply");
                ServiceLine1.SetRange("Non-GST Line", false);
                if ServiceLine1.FindSet() then
                    repeat
                        PreviousGSTRegNo := GetGSTRegistrationNum(ServiceHeader, ServiceLine1);
                        if (PreviousGSTRegNo <> PresentGSTRegNo) and (PresentGSTRegNo <> '') then
                            Error(GSTRegistrationValidationErr, ServiceLine1."Document No.", ServiceLine1."Line No.", PreviousGSTRegNo, PresentGSTRegNo);

                        if ServiceLine."GST Jurisdiction Type" <> ServiceLine1."GST Jurisdiction Type" then
                            Error(DiffJurisdictionTypeErr);
                    until ServiceLine1.next() = 0;
            until ServiceLine1.next() = 0;
    end;

    local procedure GetGSTRegistrationNum(ServiceHeader: Record "Service Header"; ServiceLine: Record "Service Line"): Code[20]
    var
        Customer: Record Customer;
        ShipToAddress: Record "Ship-to Address";
        PresentRegNo: Code[20];
    begin
        ServiceLine.TestField("GST Place of Supply");
        case ServiceLine."GST Place of Supply" of
            ServiceLine."GST Place of Supply"::"Bill-to Address", ServiceLine."GST Place of Supply"::"Location Address":
                if ServiceHeader."Customer GST Reg. No." <> '' then
                    PresentRegNo := ServiceHeader."Customer GST Reg. No."
                else
                    if Customer.Get(ServiceHeader."Customer No.") then
                        PresentRegNo := Customer."ARN No.";
            ServiceLine."GST Place of Supply"::"Ship-to Address":
                if ServiceHeader."Ship-to GST Reg. No." <> '' then
                    PresentRegNo := ServiceHeader."Ship-to GST Reg. No."
                else
                    if ShipToAddress.Get(ServiceHeader."Customer No.", ServiceHeader."Ship-to Code") then
                        PresentRegNo := ShipToAddress."ARN No.";
        end;

        Exit(PresentRegNo);
    end;

    procedure CheckUpdatePreviousLineGSTPlaceofSupply(Var ServiceLine: Record "Service Line")
    var
        PreviousServiceLine: Record "Service Line";
    begin
        PreviousServiceLine.SetCurrentKey("Document Type", "Document No.", Type, "No.");
        PreviousServiceLine.SetRange("Document Type", ServiceLine."Document Type");
        PreviousServiceLine.SetRange("Document No.", ServiceLine."Document No.");
        PreviousServiceLine.SetFilter(Type, '<>%1', Type::" ");
        PreviousServiceLine.SetFilter("No.", '<>%1', '');
        if PreviousServiceLine.FindFirst() then
            if PreviousServiceLine."GST Place Of Supply" <> ServiceLine."GST Place Of Supply" then
                ServiceLine."GST Place Of Supply" := PreviousServiceLine."GST Place Of Supply";
    end;
}
