// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Analytics;

using Microsoft.Purchases.Document;
using Microsoft.DemoData.CRM;
using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Foundation;
using Microsoft.DemoTool;
using Microsoft.DemoData.Inventory;
using Microsoft.DemoData.Bank;
using Microsoft.DemoData.Purchases;

codeunit 5688 "Create Extended Purch Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        PurchaseHeader: Record "Purchase Header";
        ContosoPurchase: Codeunit "Contoso Purchase";
        CreateVendor: Codeunit "Create Vendor";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        CreateItem: Codeunit "Create Item";
        CreatePaymentMethod: Codeunit "Create Payment Method";
        CreatePurchaser: Codeunit "Create Salesperson/Purchaser";
        CreateReturnReason: Codeunit "Create Return Reason";
        DocumentDate: Date;
        StartingDate: Date;
    begin
        ContosoCoffeeDemoDataSetup.Get();
        StartingDate := ContosoCoffeeDemoDataSetup."Starting Date";

        DocumentDate := CalcDate('<-6M>', StartingDate);

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.EUGraphicDesign(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCM(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.OtisFalls());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.AthensDesk(), 60, '', 219.5);

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.DomesticNodPublisher(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.JimOlive());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.ParisGuestChairBlack(), 30, '', 97.5);

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.EUGraphicDesign(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.LinaTownsend());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.AthensMobilePedestal(), 25, '', 219.5);

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.DomesticFirstUp(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.OtisFalls());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.LondonSwivelChairBlue(), 23, '', 96.1);

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.DomesticWorldImporter(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.LinaTownsend());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.AntwerpConferenceTable(), 50, '', 328);

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.EUGraphicDesign(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.BenjaminChiu());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.AmsterdamLamp(), 15, '', 27.8);

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.EUGraphicDesign(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.OtisFalls());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.BerlingGuestChairYellow(), 5, '', 27.8);

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.DomesticFirstUp(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCM(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.RobinBettencourt());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.RomeGuestChairGreen(), 39, '', 97.5);

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.DomesticWorldImporter(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.LinaTownsend());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.TokyoGuestChairBlue(), 40, '', 97.5);

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.DomesticFirstUp(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.BenjaminChiu());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.MexicoSwivelChairBlack(), 30, '', 96.1);

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.EUGraphicDesign(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.OtisFalls());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.MunichSwivelChairYellow(), 30, '', 96.1);

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.DomesticNodPublisher(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.JimOlive());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.MoscowSwivelChairRed(), 40, '', 96.1);

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.DomesticFirstUp(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.LinaTownsend());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.SeoulGuestChairRed(), 40, '', 97.5);

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.EUGraphicDesign(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.OtisFalls());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.AtlantAWhiteboardBase(), 20, '', 707.2);

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::Order, CreateVendor.EUGraphicDesign(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.LinaTownsend());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.SydneySwivelChairGreen(), 10, '', 96.1);

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Credit Memo", CreateVendor.EUGraphicDesign(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.OtisFalls());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.AthensDesk(), 60, '', 219.5, CreateReturnReason.Damaged());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Credit Memo", CreateVendor.DomesticNodPublisher(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.JimOlive());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.ParisGuestChairBlack(), 30, '', 97.5, CreateReturnReason.Damaged());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Credit Memo", CreateVendor.EUGraphicDesign(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.LinaTownsend());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.ParisGuestChairBlack(), 25, '', 219.5, CreateReturnReason.Damaged());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Credit Memo", CreateVendor.DomesticFirstUp(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.BenjaminChiu());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.AthensDesk(), 23, '', 96.1, CreateReturnReason.WrongItem());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Credit Memo", CreateVendor.DomesticWorldImporter(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.LinaTownsend());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.ParisGuestChairBlack(), 50, '', 328, CreateReturnReason.Damaged());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Credit Memo", CreateVendor.ExportFabrikam(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.OtisFalls());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.ParisGuestChairBlack(), 15, '', 96.5, CreateReturnReason.WrongSize());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Credit Memo", CreateVendor.EUGraphicDesign(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.LinaTownsend());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.AthensDesk(), 15, '', 27.8, CreateReturnReason.WrongColor());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Credit Memo", CreateVendor.EUGraphicDesign(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.BenjaminChiu());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.ParisGuestChairBlack(), 5, '', 27.8, CreateReturnReason.WrongSize());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Credit Memo", CreateVendor.DomesticFirstUp(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.RobinBettencourt());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.ParisGuestChairBlack(), 39, '', 97.5, CreateReturnReason.Damaged());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Credit Memo", CreateVendor.DomesticWorldImporter(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.JimOlive());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.ParisGuestChairBlack(), 40, '', 97.5, CreateReturnReason.Damaged());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Return Order", CreateVendor.EUGraphicDesign(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.BenjaminChiu());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.AthensDesk(), 60, '', 219.5, CreateReturnReason.Damaged());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Return Order", CreateVendor.DomesticNodPublisher(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.RobinBettencourt());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.ParisGuestChairBlack(), 30, '', 97.5, CreateReturnReason.Damaged());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Return Order", CreateVendor.EUGraphicDesign(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.LinaTownsend());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.ParisGuestChairBlack(), 25, '', 219.5, CreateReturnReason.Damaged());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Return Order", CreateVendor.DomesticFirstUp(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.JimOlive());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.AthensDesk(), 23, '', 96.1, CreateReturnReason.WrongItem());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Return Order", CreateVendor.DomesticWorldImporter(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.OtisFalls());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.ParisGuestChairBlack(), 50, '', 328, CreateReturnReason.Damaged());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Return Order", CreateVendor.ExportFabrikam(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.JimOlive());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.ParisGuestChairBlack(), 15, '', 96.5, CreateReturnReason.WrongSize());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Return Order", CreateVendor.EUGraphicDesign(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.LinaTownsend());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.AthensDesk(), 15, '', 27.8, CreateReturnReason.WrongColor());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Return Order", CreateVendor.EUGraphicDesign(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.LinaTownsend());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.ParisGuestChairBlack(), 5, '', 27.8, CreateReturnReason.WrongSize());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Return Order", CreateVendor.DomesticFirstUp(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.OtisFalls());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.ParisGuestChairBlack(), 39, '', 97.5, CreateReturnReason.Damaged());

        PurchaseHeader := ContosoPurchase.InsertPurchaseHeader(Enum::"Purchase Document Type"::"Return Order", CreateVendor.DomesticWorldImporter(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), DocumentDate, ContosoUtilities.AdjustDate(19020101D), CreatePaymentTerms.PaymentTermsCOD(), '', '', '', DocumentDate, CreatePaymentMethod.Cash(), CreatePurchaser.RobinBettencourt());
        ContosoPurchase.InsertPurchaseLineWithItem(PurchaseHeader, CreateItem.ParisGuestChairBlack(), 40, '', 97.5, CreateReturnReason.Damaged());
    end;

    procedure AnalyticsReference(): Code[35]
    begin
        exit(AnalyticsReferenceTok);
    end;

    var
        AnalyticsReferenceTok: Label 'ANALYTICS', MaxLength = 35;
}