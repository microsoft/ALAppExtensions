// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Compensations;

using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Localization;
using Microsoft.DemoData.Purchases;
using Microsoft.DemoData.Sales;
using Microsoft.Finance.Compensations;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Receivables;
using Microsoft.Purchases.Payables;

codeunit 31482 "Create Compensation Doc. CZC"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateCompensations();
    end;

    local procedure CreateCompensations()
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        ContosoCompensationsCZC: Codeunit "Contoso Compensations CZC";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreateCustomer: Codeunit "Create Customer";
        CreateVendor: Codeunit "Create Vendor";
    begin
        CompensationHeaderCZC := ContosoCompensationsCZC.InsertCompensationHeader(Enum::"Compensation Company Type CZC"::Customer, CreateCustomer.DomesticAdatumCorporation(), ContosoUtilities.AdjustDate(19030115D), ContosoUtilities.AdjustDate(19030115D));
        ContosoCompensationsCZC.InsertCompensationLine(CompensationHeaderCZC, Enum::"Compensation Source Type CZC"::Customer, CreateCustomer.DomesticAdatumCorporation(), Enum::"Gen. Journal Document Type"::Invoice);
        ContosoCompensationsCZC.InsertCompensationLine(CompensationHeaderCZC, Enum::"Compensation Source Type CZC"::Customer, CreateCustomer.DomesticAdatumCorporation(), Enum::"Gen. Journal Document Type"::"Credit Memo");

        CompensationHeaderCZC := ContosoCompensationsCZC.InsertCompensationHeader(Enum::"Compensation Company Type CZC"::Vendor, CreateVendor.EUGraphicDesign(), ContosoUtilities.AdjustDate(19030115D), ContosoUtilities.AdjustDate(19030115D));
        ContosoCompensationsCZC.InsertCompensationLine(CompensationHeaderCZC, Enum::"Compensation Source Type CZC"::Vendor, CreateVendor.EUGraphicDesign(), Enum::"Gen. Journal Document Type"::"Credit Memo");
        ContosoCompensationsCZC.InsertCompensationLine(CompensationHeaderCZC, Enum::"Compensation Source Type CZC"::Vendor, CreateVendor.EUGraphicDesign(), Enum::"Gen. Journal Document Type"::Invoice);
    end;

    procedure UpdateCompensationLines()
    var
        CompensationLineCZC: Record "Compensation Line CZC";
    begin
        if CompensationLineCZC.FindSet() then
            repeat
                CompensationLineCZC.Validate("Source Entry No.", GetSourceEntryNo(CompensationLineCZC));
                CompensationLineCZC.Modify(true);
            until CompensationLineCZC.Next() = 0;
    end;

    procedure ApplyBalanceCompensations()
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        CompensationManagementCZC: Codeunit "Compensation Management CZC";
    begin
        if CompensationHeaderCZC.FindSet() then
            repeat
                CompensationManagementCZC.BalanceCompensations(CompensationHeaderCZC);
            until CompensationHeaderCZC.Next() = 0;
    end;

    procedure ReleaseCompensations()
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
    begin
        if CompensationHeaderCZC.FindSet() then
            repeat
                Codeunit.Run(Codeunit::"Release Compens. Document CZC", CompensationHeaderCZC);
            until CompensationHeaderCZC.Next() = 0;
    end;

    procedure PostCompensations()
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
    begin
        if CompensationHeaderCZC.FindFirst() then
            Codeunit.Run(Codeunit::"Compensation - Post CZC", CompensationHeaderCZC);
    end;

    local procedure GetSourceEntryNo(CompensationLineCZC: Record "Compensation Line CZC"): Integer
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        case CompensationLineCZC."Source Type" of
            CompensationLineCZC."Source Type"::Customer:
                begin
                    CustLedgerEntry.SetRange("Customer No.", CompensationLineCZC."Source No.");
                    CustLedgerEntry.SetRange("Document Type", CompensationLineCZC."Document Type");
                    CustLedgerEntry.SetRange(Open, true);
                    if CustLedgerEntry.FindFirst() then
                        exit(CustLedgerEntry."Entry No.");
                end;
            CompensationLineCZC."Source Type"::Vendor:
                begin
                    VendorLedgerEntry.SetRange("Vendor No.", CompensationLineCZC."Source No.");
                    VendorLedgerEntry.SetRange("Document Type", CompensationLineCZC."Document Type");
                    VendorLedgerEntry.SetRange(Open, true);
                    if VendorLedgerEntry.FindFirst() then
                        exit(VendorLedgerEntry."Entry No.");
                end;
        end;
    end;
}