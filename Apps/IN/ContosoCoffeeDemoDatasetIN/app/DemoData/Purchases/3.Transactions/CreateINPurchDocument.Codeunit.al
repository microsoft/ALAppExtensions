// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Purchases;

using Microsoft.Purchases.Document;
using Microsoft.Inventory.Item;
using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Inventory;
using Microsoft.DemoData.Finance;
using Microsoft.Finance.GST.Base;

codeunit 19067 "Create IN Purch. Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdatePurchaseLineDirectUnitCost();
        CreateINPurchDocument();
    end;

    local procedure UpdatePurchaseLineDirectUnitCost()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Item: Record Item;
    begin
        PurchaseHeader.SetFilter("Currency Code", '<>%1', '');
        if PurchaseHeader.FindSet() then
            repeat
                PurchaseLine.Reset();
                PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
                PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
                PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
                if PurchaseLine.FindSet() then
                    repeat
                        Item.Get(PurchaseLine."No.");
                        PurchaseLine.Validate("Direct Unit Cost", Round((Item."Unit Cost" * PurchaseHeader."Currency Factor"), 0.001, '='));
                        PurchaseLine.Modify(true);
                    until PurchaseLine.Next() = 0;
            until PurchaseHeader.Next() = 0;
    end;

    local procedure CreateINPurchDocument()
    begin
        CreateINPurchOrder();
        CreateINPurchOrderLines();
        CreateINPurchInvoice();
        CreateINPurchInvLines();
        CreateINPurchCrMemo();
        CreateINPurchCrMemoLines();
    end;

    local procedure CreateINPurchOrder()
    var
        CreateVendor: Codeunit "Create Vendor";
        ContosoINPurchDocument: Codeunit "Contoso IN Purch. Document";
    begin
        ContosoINPurchDocument.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.EUGraphicDesign(), 19030126D, 'VI-0001');

        ContosoINPurchDocument.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.ExportFabrikam(), 19020630D, 'PO-1001');
        ContosoINPurchDocument.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.DomesticNodPublisher(), 19020630D, 'PO-1002');
        ContosoINPurchDocument.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.EUGraphicDesign(), 19020630D, 'PO-1003');
        ContosoINPurchDocument.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.EUGraphicDesign(), 19020630D, 'PO-1004');
    end;

    local procedure CreateINPurchInvoice()
    var
        CreateVendor: Codeunit "Create Vendor";
        ContosoINPurchDocument: Codeunit "Contoso IN Purch. Document";
    begin
        ContosoINPurchDocument.InsertPurchaseHeader(Enum::"Purchase Document Type"::Invoice, CreateVendor.DomesticFirstUp(), 19020630D, 'PI-1001');
        ContosoINPurchDocument.InsertPurchaseHeader(Enum::"Purchase Document Type"::Invoice, CreateVendor.DomesticWorldImporter(), 19020630D, 'PI-1002');
    end;

    local procedure CreateINPurchCrMemo()
    var
        CreateVendor: Codeunit "Create Vendor";
        ContosoINPurchDocument: Codeunit "Contoso IN Purch. Document";
    begin
        ContosoINPurchDocument.InsertPurchaseHeaderWithDocNo(Enum::"Purchase Document Type"::"Credit Memo", 'CM-1001', CreateVendor.ExportFabrikam(), 19030112D, 'CM-1001');
        ContosoINPurchDocument.InsertPurchaseHeaderWithDocNo(Enum::"Purchase Document Type"::"Credit Memo", 'CM-1002', CreateVendor.ExportFabrikam(), 19030125D, 'CM-1002');
    end;

    local procedure CreateINPurchOrderLines()
    var
        ContosoINPurchDocument: Codeunit "Contoso IN Purch. Document";
        CreateItem: Codeunit "Create Item";
        CreateINLocation: Codeunit "Create IN Location";
        CreateINTDSSection: Codeunit "Create IN TDS Section";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        ContosoINPurchDocument.InsertPurchaseLine(Enum::"Purchase Document Type"::Order, GetDocumentNo("Purchase Document Type"::Order, 'PO-1001'), Enum::"Purchase Line Type"::Item, CreateItem.BerlingGuestChairYellow(), CreateINLocation.BlueLocation(), 10, 100, '', '', '', Enum::"GST Credit"::Availment);
        ContosoINPurchDocument.InsertPurchaseLine(Enum::"Purchase Document Type"::Order, GetDocumentNo("Purchase Document Type"::Order, 'PO-1001'), Enum::"Purchase Line Type"::Item, CreateItem.MexicoSwivelChairBlack(), CreateINLocation.BlueLocation(), 20, 100, '', '', '', Enum::"GST Credit"::Availment);
        ContosoINPurchDocument.InsertPurchaseLine(Enum::"Purchase Document Type"::Order, GetDocumentNo("Purchase Document Type"::Order, 'PO-1002'), Enum::"Purchase Line Type"::Item, CreateItem.BerlingGuestChairYellow(), CreateINLocation.BlueLocation(), 10, 100, '', '', '', Enum::"GST Credit"::Availment);
        ContosoINPurchDocument.InsertPurchaseLine(Enum::"Purchase Document Type"::Order, GetDocumentNo("Purchase Document Type"::Order, 'PO-1002'), Enum::"Purchase Line Type"::Item, CreateItem.MexicoSwivelChairBlack(), CreateINLocation.BlueLocation(), 20, 100, '', '', '', Enum::"GST Credit"::Availment);
        ContosoINPurchDocument.InsertPurchaseLine(Enum::"Purchase Document Type"::Order, GetDocumentNo("Purchase Document Type"::Order, 'PO-1003'), Enum::"Purchase Line Type"::"G/L Account", CreateGLAccount.Postage(), CreateINLocation.BlueLocation(), 1, 10000, CreateINTDSSection.SectionS(), '', '', Enum::"GST Credit"::Availment);
        ContosoINPurchDocument.InsertPurchaseLine(Enum::"Purchase Document Type"::Order, GetDocumentNo("Purchase Document Type"::Order, 'PO-1004'), Enum::"Purchase Line Type"::"G/L Account", CreateGLAccount.Postage(), CreateINLocation.BlueLocation(), 1, 10000, CreateINTDSSection.SectionS(), '', '', Enum::"GST Credit"::Availment);
        ContosoINPurchDocument.InsertPurchaseLine(Enum::"Purchase Document Type"::Order, GetDocumentNo("Purchase Document Type"::Order, 'PO-1004'), Enum::"Purchase Line Type"::"G/L Account", CreateGLAccount.Travel(), CreateINLocation.BlueLocation(), 1, 6000, CreateINTDSSection.Section194JPF(), '', '', Enum::"GST Credit"::Availment);
    end;

    local procedure CreateINPurchInvLines()
    var
        ContosoINPurchDocument: Codeunit "Contoso IN Purch. Document";
        CreateINLocation: Codeunit "Create IN Location";
        CreateINGLAccounts: Codeunit "Create IN GL Accounts";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateINTDSSection: Codeunit "Create IN TDS Section";
        CreateINTDSNatureofRem: Codeunit "Create IN TDS Nature of Rem.";
        CreateINActApplicable: Codeunit "Create IN Act Applicable";
    begin
        ContosoINPurchDocument.InsertPurchaseLine(Enum::"Purchase Document Type"::Invoice, GetDocumentNo("Purchase Document Type"::Invoice, 'PI-1001'), Enum::"Purchase Line Type"::"G/L Account", CreateINGLAccounts.AuditFee(), CreateINLocation.BlueLocation(), 1, 1000, '', '', '', Enum::"GST Credit"::Availment);
        ContosoINPurchDocument.InsertPurchaseLine(Enum::"Purchase Document Type"::Invoice, GetDocumentNo("Purchase Document Type"::Invoice, 'PI-1002'), Enum::"Purchase Line Type"::"G/L Account", CreateGLAccount.Travel(), CreateINLocation.BlueLocation(), 1, 8000, CreateINTDSSection.Section195(), CreateINTDSNatureofRem.NatureofRemittance16(), CreateINActApplicable.IncomeTaxAct(), Enum::"GST Credit"::Availment);
    end;

    local procedure CreateINPurchCrMemoLines()
    var
        ContosoINPurchDocument: Codeunit "Contoso IN Purch. Document";
        CreateItem: Codeunit "Create Item";
        CreateVendor: Codeunit "Create Vendor";
        CreateINLocation: Codeunit "Create IN Location";
        CreateINGLAccounts: Codeunit "Create IN GL Accounts";
    begin
        ContosoINPurchDocument.InsertPurchaseLine(Enum::"Purchase Document Type"::"Credit Memo", GetDocumentNo("Purchase Document Type"::"Credit Memo", 'CM-1001'), Enum::"Purchase Line Type"::Item, CreateItem.BerlingGuestChairYellow(), CreateINLocation.BlueLocation(), 5, 100, '', '', '', Enum::"GST Credit"::" ");
        ContosoINPurchDocument.InsertPurchaseLine(Enum::"Purchase Document Type"::"Credit Memo", GetDocumentNo("Purchase Document Type"::"Credit Memo", 'CM-1001'), Enum::"Purchase Line Type"::Item, CreateItem.MexicoSwivelChairBlack(), CreateINLocation.BlueLocation(), 2, 100, '', '', '', Enum::"GST Credit"::" ");
        ContosoINPurchDocument.InsertPurchaseLine(Enum::"Purchase Document Type"::"Credit Memo", GetDocumentNo("Purchase Document Type"::"Credit Memo", 'CM-1002'), Enum::"Purchase Line Type"::"G/L Account", CreateINGLAccounts.AuditFee(), CreateINLocation.BlueLocation(), 1, 100, '', '', '', Enum::"GST Credit"::" ");

        ContosoINPurchDocument.InsertRefInvNo(Enum::"Document Type Enum"::"Credit Memo", GetDocumentNo("Purchase Document Type"::"Credit Memo", 'CM-1001'), CreateVendor.ExportFabrikam());
        ContosoINPurchDocument.InsertRefInvNo(Enum::"Document Type Enum"::"Credit Memo", GetDocumentNo("Purchase Document Type"::"Credit Memo", 'CM-1002'), CreateVendor.ExportFabrikam());
    end;

    local procedure GetDocumentNo(PurchDocType: Enum "Purchase Document Type"; InvoiceNo: Code[20]): Code[20]
    var
        PurchHeader: Record "Purchase Header";
    begin
        PurchHeader.SetRange("Document Type", PurchDocType);
        if PurchDocType in [PurchDocType::Order, PurchDocType::Invoice] then
            PurchHeader.SetRange("Vendor Invoice No.", InvoiceNo)
        else
            PurchHeader.SetRange("Vendor Cr. Memo No.", InvoiceNo);
        PurchHeader.FindFirst();
        exit(PurchHeader."No.");
    end;
}
