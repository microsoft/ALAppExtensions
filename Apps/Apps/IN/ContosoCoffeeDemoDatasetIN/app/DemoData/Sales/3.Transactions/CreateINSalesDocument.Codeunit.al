// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Sales;

using Microsoft.DemoData.Foundation;
using Microsoft.Sales.Document;
using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Inventory;
using Microsoft.DemoData.Finance;
using Microsoft.Finance.GST.Base;

codeunit 19062 "Create IN Sales Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateCustomer: Codeunit "Create Customer";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
    begin
        UpdatePaymentTermsOnSalesHeader(CreateCustomer.ExportSchoolofArt(), CreatePaymentTerms.PaymentTermsM8D());
        UpdateUnitPriceOnSalesLine(CreateCustomer.ExportSchoolofArt(), 647.908);
        CreateINSalesDocument();
    end;

    local procedure UpdatePaymentTermsOnSalesHeader(CustomerNo: Code[20]; PaymentTermsCode: Code[10])
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        if SalesHeader.FindSet() then
            repeat
                SalesHeader.Validate("Payment Terms Code", PaymentTermsCode);
                SalesHeader.Modify(true);
            until SalesHeader.Next() = 0;
    end;

    local procedure UpdateUnitPriceOnSalesLine(CustomerNo: Code[20]; UnitPrice: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Sell-to Customer No.", CustomerNo);
        if SalesLine.FindSet() then
            repeat
                SalesLine.Validate("Unit Price", UnitPrice);
                SalesLine.Modify(true);
            until SalesLine.Next() = 0;
    end;

    local procedure CreateINSalesDocument()
    begin
        CreateINSalesOrders();
        CreateINSalesOrderLines();
        CreateINSalesInvoice();
        CreateSalesInvLines();
        CreateINSalesCrMemo();
        CreateSalesCrMemoLines();
    end;

    local procedure CreateINSalesOrders()
    var
        CreateCustomer: Codeunit "Create Customer";
        CreateINNoSeries: Codeunit "Create IN No. Series";
        ContosoINSalesDocument: Codeunit "Contoso IN Sales Document";
        CreateShippingData: Codeunit "Create Shipping Data";
    begin
        ContosoINSalesDocument.InsertSalesHeader(Enum::"Sales Document Type"::Order, CreateCustomer.DomesticAdatumCorporation(), 19030205D, 'SO-0001', false, CreateINNoSeries.PostedSalesINInvoice(), '', '');
        ContosoINSalesDocument.InsertSalesHeader(Enum::"Sales Document Type"::Order, CreateCustomer.ExportSchoolofArt(), 19030205D, 'SO-0002', false, CreateINNoSeries.PostedSalesINInvoice(), '', CreateShippingData.DHL());
        ContosoINSalesDocument.InsertSalesHeader(Enum::"Sales Document Type"::Order, CreateCustomer.DomesticRelecloud(), 19030205D, 'SO-0003', false, CreateINNoSeries.PostedSalesINInvoice(), '', '');
        ContosoINSalesDocument.InsertSalesHeader(Enum::"Sales Document Type"::Order, CreateCustomer.DomesticRelecloud(), 19030205D, 'SO-0004', false, CreateINNoSeries.PostedSalesINInvoice(), '', CreateShippingData.UPS());
    end;

    local procedure CreateINSalesInvoice()
    var
        CreateCustomer: Codeunit "Create Customer";
        CreateINNoSeries: Codeunit "Create IN No. Series";
        ContosoINSalesDocument: Codeunit "Contoso IN Sales Document";
    begin
        ContosoINSalesDocument.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), 19030205D, 'SI-0001', false, CreateINNoSeries.PostedSalesINInvoice(), '', '');
        ContosoINSalesDocument.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), 19030205D, 'SI-0002', false, CreateINNoSeries.PostedSalesINInvoice(), 'USD', '');
    end;

    local procedure CreateINSalesCrMemo()
    var
        CreateCustomer: Codeunit "Create Customer";
        ContosoINSalesDocument: Codeunit "Contoso IN Sales Document";
        CreateShippingData: Codeunit "Create Shipping Data";
    begin
        ContosoINSalesDocument.InsertSalesHeader(Enum::"Sales Document Type"::"Credit Memo", CreateCustomer.DomesticAdatumCorporation(), 19030120D, 'SCM-1001', false, '', '', '');
        ContosoINSalesDocument.InsertSalesHeader(Enum::"Sales Document Type"::"Credit Memo", CreateCustomer.DomesticAdatumCorporation(), 19030127D, 'SCM-1002', false, '', '', CreateShippingData.UPS());
    end;

    local procedure CreateINSalesOrderLines()
    var
        CreateItem: Codeunit "Create Item";
        CreateINGLAccounts: Codeunit "Create IN GL Accounts";
        ContosoINSalesDocument: Codeunit "Contoso IN Sales Document";
    begin
        ContosoINSalesDocument.InsertSalesLine(Enum::"Sales Document Type"::Order, 'SO-0001', Enum::"Sales Line Type"::Item, CreateItem.BerlingGuestChairYellow(), '', 10, '', 100);
        ContosoINSalesDocument.InsertSalesLine(Enum::"Sales Document Type"::Order, 'SO-0001', Enum::"Sales Line Type"::Item, CreateItem.MexicoSwivelChairBlack(), '', 10, '', 100);
        ContosoINSalesDocument.InsertSalesLine(Enum::"Sales Document Type"::Order, 'SO-0002', Enum::"Sales Line Type"::Item, CreateItem.BerlingGuestChairYellow(), '', 10, '', 100);
        ContosoINSalesDocument.InsertSalesLine(Enum::"Sales Document Type"::Order, 'SO-0002', Enum::"Sales Line Type"::Item, CreateItem.MexicoSwivelChairBlack(), '', 10, '', 100);
        ContosoINSalesDocument.InsertSalesLine(Enum::"Sales Document Type"::Order, 'SO-0003', Enum::"Sales Line Type"::Item, CreateItem.RomeGuestChairGreen(), '', 1, 'A', 10000);
        ContosoINSalesDocument.InsertSalesLine(Enum::"Sales Document Type"::Order, 'SO-0004', Enum::"Sales Line Type"::"G/L Account", CreateINGLAccounts.LiquorFees(), '', 10, 'A', 100);
    end;

    local procedure CreateSalesInvLines()
    var
        CreateINGLAccounts: Codeunit "Create IN GL Accounts";
        ContosoINSalesDocument: Codeunit "Contoso IN Sales Document";
    begin
        ContosoINSalesDocument.InsertSalesLine(Enum::"Sales Document Type"::Invoice, 'SI-0001', Enum::"Sales Line Type"::"G/L Account", CreateINGLAccounts.ServiceContractSale(), '', 1, '', 1000);
        ContosoINSalesDocument.InsertSalesLine(Enum::"Sales Document Type"::Invoice, 'SI-0002', Enum::"Sales Line Type"::"G/L Account", CreateINGLAccounts.LiquorFees(), '', 1, 'A', 6000);
    end;

    local procedure CreateSalesCrMemoLines()
    var
        CreateItem: Codeunit "Create Item";
        CreateINGLAccounts: Codeunit "Create IN GL Accounts";
        CreateINLocation: Codeunit "Create IN Location";
        CreateCustomer: Codeunit "Create Customer";
        ContosoINSalesDocument: Codeunit "Contoso IN Sales Document";
    begin
        ContosoINSalesDocument.InsertSalesLine(Enum::"Sales Document Type"::"Credit Memo", 'SCM-1001', Enum::"Sales Line Type"::Item, CreateItem.BerlingGuestChairYellow(), CreateINLocation.BlueLocation(), 7, '', 100);
        ContosoINSalesDocument.InsertSalesLine(Enum::"Sales Document Type"::"Credit Memo", 'SCM-1001', Enum::"Sales Line Type"::Item, CreateItem.BerlingGuestChairYellow(), CreateINLocation.BlueLocation(), 8, '', 100);
        ContosoINSalesDocument.InsertSalesLine(Enum::"Sales Document Type"::"Credit Memo", 'SCM-1002', Enum::"Sales Line Type"::"G/L Account", CreateINGLAccounts.ServiceContractSale(), CreateINLocation.BlueLocation(), 1, '', 100);

        ContosoINSalesDocument.InsertRefInvNo(Enum::"Document Type Enum"::"Credit Memo", 'SCM-1001', CreateCustomer.DomesticAdatumCorporation());
        ContosoINSalesDocument.InsertRefInvNo(Enum::"Document Type Enum"::"Credit Memo", 'SCM-1002', CreateCustomer.DomesticAdatumCorporation());
    end;
}
