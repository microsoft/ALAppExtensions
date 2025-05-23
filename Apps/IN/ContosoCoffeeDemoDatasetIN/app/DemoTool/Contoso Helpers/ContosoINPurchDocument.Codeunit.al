// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.Purchases.Document;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;

codeunit 19068 "Contoso IN Purch. Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Purchase Header" = rim,
                tabledata "Purchase Line" = rim;


    procedure InsertPurchaseHeader(DocumentType: Enum "Purchase Document Type"; BuyFromVendorNo: Code[20]; PostingDate: Date; VendorInvoiceNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        PurchaseHeader.Validate("Document Type", DocumentType);
        PurchaseHeader.Validate("No.", '');
        PurchaseHeader."Posting Date" := ContosoUtilities.AdjustDate(PostingDate);
        PurchaseHeader.Insert(true);

        PurchaseHeader.Validate("Buy-from Vendor No.", BuyFromVendorNo);
        PurchaseHeader.Validate("Posting Date");
        PurchaseHeader.Validate("Order Date", ContosoUtilities.AdjustDate(PostingDate));
        PurchaseHeader.Validate("Expected Receipt Date", ContosoUtilities.AdjustDate(PostingDate));
        PurchaseHeader.Validate("Document Date", ContosoUtilities.AdjustDate(PostingDate));

        case DocumentType of
            DocumentType::Order:
                begin
                    PurchaseHeader.Validate("Vendor Invoice No.", VendorInvoiceNo);
                    PurchaseHeader.Validate("Promised Receipt Date", PurchaseHeader."Expected Receipt Date");
                end;
            DocumentType::Invoice:
                PurchaseHeader.Validate("Vendor Invoice No.", VendorInvoiceNo);
            DocumentType::"Credit Memo",
            DocumentType::"Return Order":
                PurchaseHeader.Validate("Vendor Cr. Memo No.", VendorInvoiceNo);
        end;

        PurchaseHeader.Modify();
    end;

    procedure InsertPurchaseHeaderWithDocNo(DocumentType: Enum "Purchase Document Type"; DocumentNo: Code[20]; BuyfromVendorNo: Code[20]; PostingDate: Date; VendorInvoiceNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        ContosoUtilities: Codeunit "Contoso Utilities";
    begin
        PurchaseHeader.Validate("Document Type", DocumentType);
        PurchaseHeader."No." := DocumentNo;
        PurchaseHeader."Posting Date" := ContosoUtilities.AdjustDate(PostingDate);
        PurchaseHeader.Insert(true);

        PurchaseHeader.Validate("Buy-from Vendor No.", BuyfromVendorNo);
        PurchaseHeader.Validate("Posting Date");
        PurchaseHeader.Validate("Order Date", ContosoUtilities.AdjustDate(PostingDate));
        PurchaseHeader.Validate("Expected Receipt Date", ContosoUtilities.AdjustDate(PostingDate));
        PurchaseHeader.Validate("Document Date", ContosoUtilities.AdjustDate(PostingDate));
        PurchaseHeader.Validate("Vendor Cr. Memo No.", VendorInvoiceNo);
        PurchaseHeader.Modify();
    end;

    procedure InsertPurchaseLine(DocumentType: Enum "Purchase Document Type"; DocumentNo: Code[20]; Type: Enum "Purchase Line Type"; No: Code[20]; LocationCode: Code[10]; Quantity: Decimal; DirectUnitCost: Decimal; TDSSectionCode: Code[10]; NatureofRemittance: Code[10]; ActApplicable: Code[10]; GSTCredit: Enum "GST Credit")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        CalculateTax: Codeunit "Calculate Tax";
    begin
        PurchaseHeader.Get(DocumentType, DocumentNo);

        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", DocumentType);
        PurchaseLine.Validate("Document No.", DocumentNo);
        PurchaseLine.Validate("Line No.", GetNextPurchaseLineNo(PurchaseHeader));

        PurchaseLine.Validate(Type, Type);
        PurchaseLine.Validate("No.", No);
        if PurchaseHeader."Location Code" <> '' then
            PurchaseLine.Validate("Location Code", PurchaseHeader."Location Code");
        PurchaseLine.Validate(Quantity, Quantity);

        if PurchaseLine.Type = PurchaseLine.Type::"G/L Account" then
            PurchaseLine.Validate("Direct Unit Cost", DirectUnitCost);

        PurchaseLine."TDS Section Code" := TDSSectionCode;
        PurchaseLine."Nature of Remittance" := NatureofRemittance;
        PurchaseLine."Act Applicable" := ActApplicable;
        PurchaseLine.Validate("GST Credit", GSTCredit);
        PurchaseLine.Insert(true);

        CalculateTax.CallTaxEngineOnPurchaseLine(PurchaseLine, PurchaseLine);
    end;

    procedure InsertRefInvNo(DocumentType: Enum "Document Type Enum"; DocumentNo: Code[20]; SourceNo: Code[20])
    var
        ReferenceInvNo: Record "Reference Invoice No.";
    begin
        ReferenceInvNo.Init();
        ReferenceInvNo."Document Type" := DocumentType;
        ReferenceInvNo."Document No." := DocumentNo;
        ReferenceInvNo."Source Type" := ReferenceInvNo."Source Type"::Vendor;
        ReferenceInvNo."Source No." := SourceNo;
        ReferenceInvNo.Insert();
    end;

    local procedure GetNextPurchaseLineNo(PurchaseHeader: Record "Purchase Header"): Integer
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetCurrentKey("Line No.");

        if PurchaseLine.FindLast() then
            exit(PurchaseLine."Line No." + 10000)
        else
            exit(10000);
    end;
}
