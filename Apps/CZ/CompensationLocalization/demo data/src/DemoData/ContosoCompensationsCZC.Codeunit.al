// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Localization;

using Microsoft.Finance.Compensations;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.DemoData.Purchase;
using Microsoft.DemoData.Sales;
using Microsoft.DemoTool;
using Microsoft.Purchases.Document;

codeunit 31465 "Contoso Compensations CZC"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Compensations Setup CZC" = rim,
        tabledata "Compensation Header CZC" = rim,
        tabledata "Compensation Line CZC" = rim,
        tabledata "Purchase Header" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertCompensationsSetup(CompensationBalAccountNo: Code[20]; CompensationNos: Code[20])
    var
        CompensationsSetupCZC: Record "Compensations Setup CZC";
    begin
        if not CompensationsSetupCZC.Get() then
            CompensationsSetupCZC.Insert();

        CompensationsSetupCZC.Validate("Compensation Bal. Account No.", CompensationBalAccountNo);
        CompensationsSetupCZC.Validate("Compensation Nos.", CompensationNos);
        CompensationsSetupCZC.Modify(true);
    end;

    procedure InsertCompensationHeader(CompanyType: Enum "Compensation Company Type CZC"; CompanyNo: Code[20]; DocumentDate: Date; PostingDate: Date): Record "Compensation Header CZC"
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
    begin
        CompensationHeaderCZC.Init();
        CompensationHeaderCZC."No." := '';
        CompensationHeaderCZC."Company Type" := CompanyType;
        CompensationHeaderCZC.Insert(true);

        CompensationHeaderCZC.Validate("Company No.", CompanyNo);
        CompensationHeaderCZC.Validate("Document Date", DocumentDate);
        CompensationHeaderCZC.Validate("Posting Date", PostingDate);
        CompensationHeaderCZC.Modify(true);

        exit(CompensationHeaderCZC);
    end;

    procedure InsertCompensationLine(CompensationHeaderCZC: Record "Compensation Header CZC"; SourceType: Enum "Compensation Source Type CZC"; SourceNo: Code[20]; DocumentType: Enum "Gen. Journal Document Type")
    var
        CompensationLineCZC: Record "Compensation Line CZC";
    begin
        CompensationLineCZC.Init();
        CompensationLineCZC."Compensation No." := CompensationHeaderCZC."No.";
        CompensationLineCZC.Validate("Line No.", GetNextCompensationLineNo(CompensationHeaderCZC));
        CompensationLineCZC.Validate("Source Type", SourceType);
        CompensationLineCZC."Source No." := SourceNo;
        CompensationLineCZC."Document Type" := DocumentType;
        CompensationLineCZC.Insert();
    end;

    procedure InsertPurchaseHeader(DocumentType: Enum "Purchase Document Type"; BuyfromVendorNo: Code[20]; YourReference: Code[35]; OrderDate: Date; PostingDate: Date; ExpectedReceiptDate: Date; PaymentTermsCode: Code[10]; LocationCode: Code[10]; VendorOrderNo: Code[20]; VendorCrMemoNo: Code[35]; DocumentDate: Date; PaymentMethodCode: Code[10]): Record "Purchase Header";
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Validate("Document Type", DocumentType);
        PurchaseHeader.Validate("Buy-from Vendor No.", BuyfromVendorNo);
        if PurchaseHeader.Insert(true) then;

        PurchaseHeader.Validate("Your Reference", YourReference);
        PurchaseHeader.Validate("Order Date", OrderDate);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Validate("Expected Receipt Date", ExpectedReceiptDate);
        PurchaseHeader.Validate("Payment Terms Code", PaymentTermsCode);

        if LocationCode <> '' then
            PurchaseHeader.Validate("Location Code", LocationCode);

        PurchaseHeader.Validate("Vendor Order No.", VendorOrderNo);

        if VendorCrMemoNo <> '' then
            PurchaseHeader.Validate("Vendor Cr. Memo No.", VendorCrMemoNo)
        else
            PurchaseHeader.Validate("Vendor Cr. Memo No.", PurchaseHeader."No.");

        PurchaseHeader.Validate("Document Date", DocumentDate);
        PurchaseHeader.Validate("Payment Method Code", PaymentMethodCode);
        PurchaseHeader.Modify(true);

        exit(PurchaseHeader);
    end;

    local procedure GetNextCompensationLineNo(CompensationHeaderCZC: Record "Compensation Header CZC"): Integer
    var
        CompensationLineCZC: Record "Compensation Line CZC";
    begin
        CompensationLineCZC.SetRange("Compensation No.", CompensationHeaderCZC."No.");
        CompensationLineCZC.SetCurrentKey("Line No.");
        if CompensationLineCZC.FindLast() then
            exit(CompensationLineCZC."Line No." + 10000)
        else
            exit(10000);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure GenerateDemoDataCZOnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Sales:
                SalesModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Finance:
                PurchaseModule(ContosoDemoDataLevel);
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateSalesDocumentCZC: Codeunit "Create Sales Document CZC";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                CreateSalesDocumentCZC.Run();
            Enum::"Contoso Demo Data Level"::"Historical Data":
                CreateSalesDocumentCZC.PostSalesCreditMemos();
        end;
    end;

    local procedure PurchaseModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreatePurchaseDocumentCZC: Codeunit "Create Purchase Document CZC";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                CreatePurchaseDocumentCZC.Run();
            Enum::"Contoso Demo Data Level"::"Historical Data":
                CreatePurchaseDocumentCZC.PostPurchaseCreditMemos();
        end;
    end;
}
