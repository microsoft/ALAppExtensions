// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Analytics;

using Microsoft.Sales.Document;
using Microsoft.DemoTool.Helpers;
using Microsoft.DemoData.Foundation;
using Microsoft.DemoData.Inventory;
using Microsoft.DemoData.Bank;
using Microsoft.DemoData.Sales;

codeunit 5692 "Create Extended Sales Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateSalesInvoicesToPost();
        CreateOpenSalesDocuments();
    end;

    local procedure CreateSalesInvoicesToPost()
    var
        SalesHeader: Record "Sales Header";
        ContosoSales: Codeunit "Contoso Sales";
        CreateCustomer: Codeunit "Create Customer";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        CreateItem: Codeunit "Create Item";
        CreatePaymentMethod: Codeunit "Create Payment Method";
    begin
        // 2025 February
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250223D, CreatePaymentTerms.PaymentTermsCM(), '', 20250223D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 3);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250223D, CreatePaymentTerms.PaymentTermsCM(), '', 20250223D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 2);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250223D, CreatePaymentTerms.PaymentTermsCM(), '', 20250223D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.ParisGuestChairBlack(), 8);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250223D, CreatePaymentTerms.PaymentTermsCM(), '', 20250223D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SydneySwivelChairGreen(), 8);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250223D, CreatePaymentTerms.PaymentTermsCM(), '', 20250223D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SeoulGuestChairRed(), 10);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250223D, CreatePaymentTerms.PaymentTermsCM(), '', 20250223D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.RomeGuestChairGreen(), 6);

        // 2025 March
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250302D, CreatePaymentTerms.PaymentTermsCM(), '', 20250302D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 5);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250302D, CreatePaymentTerms.PaymentTermsCM(), '', 20250302D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.BerlingGuestChairYellow(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250302D, CreatePaymentTerms.PaymentTermsCM(), '', 20250302D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 8);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250302D, CreatePaymentTerms.PaymentTermsCM(), '', 20250302D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 5);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250309D, CreatePaymentTerms.PaymentTermsCM(), '', 20250309D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 6);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250309D, CreatePaymentTerms.PaymentTermsCM(), '', 20250309D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 6);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250309D, CreatePaymentTerms.PaymentTermsCM(), '', 20250309D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SeoulGuestChairRed(), 2);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250309D, CreatePaymentTerms.PaymentTermsCM(), '', 20250309D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250309D, CreatePaymentTerms.PaymentTermsCM(), '', 20250309D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 10);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250309D, CreatePaymentTerms.PaymentTermsCM(), '', 20250309D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 2);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250309D, CreatePaymentTerms.PaymentTermsCM(), '', 20250309D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 9);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250316D, CreatePaymentTerms.PaymentTermsCM(), '', 20250316D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250316D, CreatePaymentTerms.PaymentTermsCM(), '', 20250316D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 6);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250316D, CreatePaymentTerms.PaymentTermsCM(), '', 20250316D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 9);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250316D, CreatePaymentTerms.PaymentTermsCM(), '', 20250316D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 2);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250316D, CreatePaymentTerms.PaymentTermsCM(), '', 20250316D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SydneySwivelChairGreen(), 9);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250316D, CreatePaymentTerms.PaymentTermsCM(), '', 20250316D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MoscowSwivelChairRed(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250316D, CreatePaymentTerms.PaymentTermsCM(), '', 20250316D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SeoulGuestChairRed(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250323D, CreatePaymentTerms.PaymentTermsCM(), '', 20250323D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250323D, CreatePaymentTerms.PaymentTermsCM(), '', 20250323D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AmsterdamLamp(), 9);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250323D, CreatePaymentTerms.PaymentTermsCM(), '', 20250323D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 5);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250330D, CreatePaymentTerms.PaymentTermsCM(), '', 20250330D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 8);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250330D, CreatePaymentTerms.PaymentTermsCM(), '', 20250330D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MoscowSwivelChairRed(), 5);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250330D, CreatePaymentTerms.PaymentTermsCM(), '', 20250330D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SeoulGuestChairRed(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250330D, CreatePaymentTerms.PaymentTermsCM(), '', 20250330D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 6);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MoscowSwivelChairRed(), 10);

        // 2025 April
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250406D, CreatePaymentTerms.PaymentTermsCM(), '', 20250406D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 7);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.RomeGuestChairGreen(), 9);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250406D, CreatePaymentTerms.PaymentTermsCM(), '', 20250406D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.ParisGuestChairBlack(), 6);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250406D, CreatePaymentTerms.PaymentTermsCM(), '', 20250406D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250406D, CreatePaymentTerms.PaymentTermsCM(), '', 20250406D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250413D, CreatePaymentTerms.PaymentTermsCM(), '', 20250413D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 6);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250413D, CreatePaymentTerms.PaymentTermsCM(), '', 20250413D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 9);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250413D, CreatePaymentTerms.PaymentTermsCM(), '', 20250413D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SydneySwivelChairGreen(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250413D, CreatePaymentTerms.PaymentTermsCM(), '', 20250413D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250413D, CreatePaymentTerms.PaymentTermsCM(), '', 20250413D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MoscowSwivelChairRed(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250413D, CreatePaymentTerms.PaymentTermsCM(), '', 20250413D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.BerlingGuestChairYellow(), 5);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250420D, CreatePaymentTerms.PaymentTermsCM(), '', 20250420D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SeoulGuestChairRed(), 10);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250420D, CreatePaymentTerms.PaymentTermsCM(), '', 20250420D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 10);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250420D, CreatePaymentTerms.PaymentTermsCM(), '', 20250420D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250420D, CreatePaymentTerms.PaymentTermsCM(), '', 20250420D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 6);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250427D, CreatePaymentTerms.PaymentTermsCM(), '', 20250427D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AmsterdamLamp(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250427D, CreatePaymentTerms.PaymentTermsCM(), '', 20250427D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MoscowSwivelChairRed(), 5);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250427D, CreatePaymentTerms.PaymentTermsCM(), '', 20250427D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 2);

        // 2025 May
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250504D, CreatePaymentTerms.PaymentTermsCM(), '', 20250504D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SeoulGuestChairRed(), 10);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250504D, CreatePaymentTerms.PaymentTermsCM(), '', 20250504D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 7);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250504D, CreatePaymentTerms.PaymentTermsCM(), '', 20250504D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AmsterdamLamp(), 5);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250511D, CreatePaymentTerms.PaymentTermsCM(), '', 20250511D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 5);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250511D, CreatePaymentTerms.PaymentTermsCM(), '', 20250511D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 2);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250511D, CreatePaymentTerms.PaymentTermsCM(), '', 20250511D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 8);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250511D, CreatePaymentTerms.PaymentTermsCM(), '', 20250511D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MoscowSwivelChairRed(), 7);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250511D, CreatePaymentTerms.PaymentTermsCM(), '', 20250511D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250511D, CreatePaymentTerms.PaymentTermsCM(), '', 20250511D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.RomeGuestChairGreen(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250518D, CreatePaymentTerms.PaymentTermsCM(), '', 20250518D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SydneySwivelChairGreen(), 3);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250518D, CreatePaymentTerms.PaymentTermsCM(), '', 20250518D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 7);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250518D, CreatePaymentTerms.PaymentTermsCM(), '', 20250518D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.GuestSection1(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250525D, CreatePaymentTerms.PaymentTermsCM(), '', 20250525D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.ParisGuestChairBlack(), 12);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250525D, CreatePaymentTerms.PaymentTermsCM(), '', 20250525D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 3);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250525D, CreatePaymentTerms.PaymentTermsCM(), '', 20250525D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250525D, CreatePaymentTerms.PaymentTermsCM(), '', 20250525D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.ParisGuestChairBlack(), 4);

        // 2025 June
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250601D, CreatePaymentTerms.PaymentTermsCM(), '', 20250601D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 6);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250601D, CreatePaymentTerms.PaymentTermsCM(), '', 20250601D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 7);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MoscowSwivelChairRed(), 3);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250601D, CreatePaymentTerms.PaymentTermsCM(), '', 20250601D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250601D, CreatePaymentTerms.PaymentTermsCM(), '', 20250601D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MoscowSwivelChairRed(), 6);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 8);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250601D, CreatePaymentTerms.PaymentTermsCM(), '', 20250601D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AmsterdamLamp(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250601D, CreatePaymentTerms.PaymentTermsCM(), '', 20250601D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250601D, CreatePaymentTerms.PaymentTermsCM(), '', 20250601D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 2);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250608D, CreatePaymentTerms.PaymentTermsCM(), '', 20250608D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.GuestSection1(), 8);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250608D, CreatePaymentTerms.PaymentTermsCM(), '', 20250608D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250608D, CreatePaymentTerms.PaymentTermsCM(), '', 20250608D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 6);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250608D, CreatePaymentTerms.PaymentTermsCM(), '', 20250608D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250615D, CreatePaymentTerms.PaymentTermsCM(), '', 20250615D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 5);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250615D, CreatePaymentTerms.PaymentTermsCM(), '', 20250615D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 6);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250615D, CreatePaymentTerms.PaymentTermsCM(), '', 20250615D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.RomeGuestChairGreen(), 5);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250615D, CreatePaymentTerms.PaymentTermsCM(), '', 20250615D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 8);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), 20250615D, CreatePaymentTerms.PaymentTermsCM(), '', 20250615D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 8);
    end;

    local procedure CreateOpenSalesDocuments()
    var
        SalesHeader: Record "Sales Header";
        ContosoSales: Codeunit "Contoso Sales";
        CreateCustomer: Codeunit "Create Customer";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreatePaymentTerms: Codeunit "Create Payment Terms";
        CreateItem: Codeunit "Create Item";
        CreatePaymentMethod: Codeunit "Create Payment Method";
        CreateSalesDocument: Codeunit "Create Sales Document";
    begin

        // Quotes
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticAdatumCorporation(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250312D, CreatePaymentTerms.PaymentTermsCM(), '', 20250312D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 24);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.EUAlpineSkiHouse(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250220D, CreatePaymentTerms.PaymentTermsCM(), '', 20250220D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.BerlingGuestChairYellow(), 28);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.ParisGuestChairBlack(), 20);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AmsterdamLamp(), 10);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticRelecloud(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250402D, CreatePaymentTerms.PaymentTermsCM(), '', 20250402D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.RomeGuestChairGreen(), 16);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticTreyResearch(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250428D, CreatePaymentTerms.PaymentTermsCM(), '', 20250428D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 10);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticTreyResearch(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250505D, CreatePaymentTerms.PaymentTermsCM(), '', 20250505D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 6);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticRelecloud(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250602D, CreatePaymentTerms.PaymentTermsCM(), '', 20250602D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 8);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.RomeGuestChairGreen(), 8);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticTreyResearch(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250505D, CreatePaymentTerms.PaymentTermsCM(), '', 20250505D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 6);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.ExportSchoolofArt(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250117D, CreatePaymentTerms.PaymentTermsCM(), '', 20250117D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AmsterdamLamp(), 16);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.BerlingGuestChairYellow(), 20);


        // Return Orders
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Return Order", CreateCustomer.DomesticRelecloud(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250423D, CreatePaymentTerms.PaymentTermsCM(), '', 20250423D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 2);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Return Order", CreateCustomer.DomesticRelecloud(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250226D, CreatePaymentTerms.PaymentTermsCM(), '', 20250226D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 4);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Return Order", CreateCustomer.EUAlpineSkiHouse(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250311D, CreatePaymentTerms.PaymentTermsCM(), '', 20250311D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 1);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Return Order", CreateCustomer.DomesticAdatumCorporation(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250513D, CreatePaymentTerms.PaymentTermsCM(), '', 20250513D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 4);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Return Order", CreateCustomer.DomesticTreyResearch(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250609D, CreatePaymentTerms.PaymentTermsCM(), '', 20250609D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 3);


        // Blanket Orders
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Blanket Order", CreateCustomer.ExportSchoolofArt(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250522D, CreatePaymentTerms.PaymentTermsDAYS60(), '', 20250522D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.BerlingGuestChairYellow(), 80);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SeoulGuestChairRed(), 40);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Blanket Order", CreateCustomer.DomesticTreyResearch(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250505D, CreatePaymentTerms.PaymentTermsDAYS21(), '', 20250505D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SeoulGuestChairRed(), 40);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 20);

        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 3);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Return Order", CreateCustomer.DomesticAdatumCorporation(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250513D, CreatePaymentTerms.PaymentTermsCM(), '', 20250513D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 4);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Return Order", CreateCustomer.DomesticRelecloud(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250423D, CreatePaymentTerms.PaymentTermsCM(), '', 20250423D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 2);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Return Order", CreateCustomer.DomesticRelecloud(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250226D, CreatePaymentTerms.PaymentTermsCM(), '', 20250226D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 4);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Return Order", CreateCustomer.EUAlpineSkiHouse(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250311D, CreatePaymentTerms.PaymentTermsCM(), '', 20250311D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 1);


        // Quotes
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticAdatumCorporation(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250312D, CreatePaymentTerms.PaymentTermsCM(), '', 20250312D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 24);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.EUAlpineSkiHouse(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250220D, CreatePaymentTerms.PaymentTermsCM(), '', 20250220D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.BerlingGuestChairYellow(), 28);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.ParisGuestChairBlack(), 20);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AmsterdamLamp(), 10);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticRelecloud(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250402D, CreatePaymentTerms.PaymentTermsCM(), '', 20250402D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 16);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticTreyResearch(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250428D, CreatePaymentTerms.PaymentTermsCM(), '', 20250428D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 10);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticTreyResearch(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250505D, CreatePaymentTerms.PaymentTermsCM(), '', 20250505D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 6);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticRelecloud(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250602D, CreatePaymentTerms.PaymentTermsCM(), '', 20250602D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 8);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.RomeGuestChairGreen(), 8);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticTreyResearch(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250505D, CreatePaymentTerms.PaymentTermsCM(), '', 20250505D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 6);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.ExportSchoolofArt(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250117D, CreatePaymentTerms.PaymentTermsCM(), '', 20250117D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 8);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 20);


        // Blanket Orders
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Blanket Order", CreateCustomer.ExportSchoolofArt(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250522D, CreatePaymentTerms.PaymentTermsDAYS60(), '', 20250522D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.BerlingGuestChairYellow(), 80);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 40);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Blanket Order", CreateCustomer.DomesticTreyResearch(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), 20250505D, CreatePaymentTerms.PaymentTermsDAYS21(), '', 20250505D, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SeoulGuestChairRed(), 40);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 20);
    end;

    procedure AnalyticsReference(): Text
    begin
        exit(AnalyticsReferenceTok);
    end;

    var
        AnalyticsReferenceTok: Label 'ANALYTICS', Locked = true;
}