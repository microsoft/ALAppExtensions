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
        GetStartingDate();
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
        FirstDayOfTheMonth: Date;
        LastDayOfTheMonth: Date;
    begin
        // Starting Date minus 5 months
        CalculateDatesForThisMonth('<-5M>', FirstDayOfTheMonth, LastDayOfTheMonth);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), FirstDayOfTheMonth, CreatePaymentTerms.PaymentTermsCM(), '', FirstDayOfTheMonth, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 3);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+8D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+8D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 2);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+12D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+12D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.ParisGuestChairBlack(), 8);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<-4D>', LastDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<-4D>', LastDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SydneySwivelChairGreen(), 8);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<-2D>', LastDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<-2D>', LastDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SeoulGuestChairRed(), 10);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), LastDayOfTheMonth, CreatePaymentTerms.PaymentTermsCM(), '', LastDayOfTheMonth, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.RomeGuestChairGreen(), 6);

        // Starting Date minus 4 months
        CalculateDatesForThisMonth('<-4M>', FirstDayOfTheMonth, LastDayOfTheMonth);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), FirstDayOfTheMonth, CreatePaymentTerms.PaymentTermsCM(), '', FirstDayOfTheMonth, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 5);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+2D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+2D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.BerlingGuestChairYellow(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+3D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+3D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 8);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+3D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+3D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 5);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+5D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+5D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 6);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+6D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+6D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 6);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+6D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+6D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SeoulGuestChairRed(), 2);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+9D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+9D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+10D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+10D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 10);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+10D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+10D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 2);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+12D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+12D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 9);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+13D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+13D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+15D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+15D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 6);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+18D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+18D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 9);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+19D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+19D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 2);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+20D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+20D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SydneySwivelChairGreen(), 9);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+20D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+20D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MoscowSwivelChairRed(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+21D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+21D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SeoulGuestChairRed(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+21D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+21D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+23D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+23D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AmsterdamLamp(), 9);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+24D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+24D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 5);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+25D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+25D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 8);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+26D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+26D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MoscowSwivelChairRed(), 5);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<-2D>', LastDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<-2D>', LastDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SeoulGuestChairRed(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), LastDayOfTheMonth, CreatePaymentTerms.PaymentTermsCM(), '', LastDayOfTheMonth, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 6);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MoscowSwivelChairRed(), 10);

        // Starting Date minus 3 months
        CalculateDatesForThisMonth('<-3M>', FirstDayOfTheMonth, LastDayOfTheMonth);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), FirstDayOfTheMonth, CreatePaymentTerms.PaymentTermsCM(), '', FirstDayOfTheMonth, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 7);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.RomeGuestChairGreen(), 9);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+1D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+1D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.ParisGuestChairBlack(), 6);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+3D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+3D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+4D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+4D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+6D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+6D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 6);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+9D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+9D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 9);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+14D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+14D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SydneySwivelChairGreen(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+15D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+15D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+18D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+18D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MoscowSwivelChairRed(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+19D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+19D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.BerlingGuestChairYellow(), 5);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+20D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+20D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SeoulGuestChairRed(), 10);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+22D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+22D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 10);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+22D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+22D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+24D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+24D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 6);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<-3D>', LastDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<-3D>', LastDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AmsterdamLamp(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<-2D>', LastDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<-2D>', LastDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MoscowSwivelChairRed(), 5);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), LastDayOfTheMonth, CreatePaymentTerms.PaymentTermsCM(), '', LastDayOfTheMonth, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 2);

        // Starting Date minus 2 months
        CalculateDatesForThisMonth('<-2M>', FirstDayOfTheMonth, LastDayOfTheMonth);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), FirstDayOfTheMonth, CreatePaymentTerms.PaymentTermsCM(), '', FirstDayOfTheMonth, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SeoulGuestChairRed(), 10);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+1D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+1D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 7);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+5D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+5D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AmsterdamLamp(), 5);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+7D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+7D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 5);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+8D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+8D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 2);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+11D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+11D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 8);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+13D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+13D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MoscowSwivelChairRed(), 7);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+14D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+14D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+17D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+17D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.RomeGuestChairGreen(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+19D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+19D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SydneySwivelChairGreen(), 3);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+20D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+20D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 7);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+21D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+21D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.GuestSection1(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticRelecloud(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+21D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+21D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.ParisGuestChairBlack(), 12);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<-4D>', LastDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<-4D>', LastDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 3);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<-1D>', LastDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<-1D>', LastDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), LastDayOfTheMonth, CreatePaymentTerms.PaymentTermsCM(), '', LastDayOfTheMonth, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.ParisGuestChairBlack(), 4);

        // Previous Month
        CalculateDatesForThisMonth('<-1M>', FirstDayOfTheMonth, LastDayOfTheMonth);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), FirstDayOfTheMonth, CreatePaymentTerms.PaymentTermsCM(), '', FirstDayOfTheMonth, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 6);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), FirstDayOfTheMonth, CreatePaymentTerms.PaymentTermsCM(), '', FirstDayOfTheMonth, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 7);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MoscowSwivelChairRed(), 3);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+1D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+1D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+2D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+2D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MoscowSwivelChairRed(), 6);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 8);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+5D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+5D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AmsterdamLamp(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+5D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+5D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+10D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+10D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 2);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+11D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+11D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.GuestSection1(), 8);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+15D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+15D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 1);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+16D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+16D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 6);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+20D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+20D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 4);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+22D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+22D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 5);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+23D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+23D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 6);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<+25D>', FirstDayOfTheMonth), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<+25D>', FirstDayOfTheMonth), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.RomeGuestChairGreen(), 5);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticAdatumCorporation(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), LastDayOfTheMonth, CreatePaymentTerms.PaymentTermsCM(), '', LastDayOfTheMonth, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 8);
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.DomesticTreyResearch(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), LastDayOfTheMonth, CreatePaymentTerms.PaymentTermsCM(), '', LastDayOfTheMonth, '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 8);

        // Current month
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.ExportSchoolofArt(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<-CM>', StartingDate), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<-CM>', StartingDate), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 5);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Invoice, CreateCustomer.EUAlpineSkiHouse(), AnalyticsReference(), ContosoUtilities.AdjustDate(19020101D), CalcDate('<-CM>', StartingDate), CreatePaymentTerms.PaymentTermsCM(), '', CalcDate('<-CM>', StartingDate), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.BerlingGuestChairYellow(), 10);
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
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticAdatumCorporation(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-15W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-15W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 24);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.EUAlpineSkiHouse(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-19W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-19W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.BerlingGuestChairYellow(), 28);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.ParisGuestChairBlack(), 20);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AmsterdamLamp(), 10);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticRelecloud(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-10W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-10W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.RomeGuestChairGreen(), 16);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticTreyResearch(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-9W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-9W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 10);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticTreyResearch(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-8W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-8W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 6);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticRelecloud(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-3W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-3W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 8);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.RomeGuestChairGreen(), 8);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticTreyResearch(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-7W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-7W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 6);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.ExportSchoolofArt(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-26W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-26W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AmsterdamLamp(), 16);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.BerlingGuestChairYellow(), 20);


        // Return Orders
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Return Order", CreateCustomer.DomesticRelecloud(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-9W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-9W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 2);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Return Order", CreateCustomer.DomesticRelecloud(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-17W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-17W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 4);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Return Order", CreateCustomer.EUAlpineSkiHouse(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-15W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-15W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 1);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Return Order", CreateCustomer.DomesticAdatumCorporation(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-6W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-6W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 4);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Return Order", CreateCustomer.DomesticTreyResearch(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-3W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-3W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 3);


        // Blanket Orders
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Blanket Order", CreateCustomer.ExportSchoolofArt(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-5W>'), CreatePaymentTerms.PaymentTermsDAYS60(), '', CalculateDate('<-5W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.BerlingGuestChairYellow(), 80);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SeoulGuestChairRed(), 40);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Blanket Order", CreateCustomer.DomesticTreyResearch(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-7W>'), CreatePaymentTerms.PaymentTermsDAYS21(), '', CalculateDate('<-7W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SeoulGuestChairRed(), 40);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 20);

        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 3);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Return Order", CreateCustomer.DomesticAdatumCorporation(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-6W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-6W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 4);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Return Order", CreateCustomer.DomesticRelecloud(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-9W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-9W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 2);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Return Order", CreateCustomer.DomesticRelecloud(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-18W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-18W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 4);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Return Order", CreateCustomer.EUAlpineSkiHouse(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-15W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-15W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 1);


        // Quotes
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticAdatumCorporation(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-15W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-15W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 24);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.EUAlpineSkiHouse(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-17W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-17W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.BerlingGuestChairYellow(), 28);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.ParisGuestChairBlack(), 20);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AmsterdamLamp(), 10);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticRelecloud(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-12W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-12W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MexicoSwivelChairBlack(), 16);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticTreyResearch(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-9W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-9W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AntwerpConferenceTable(), 10);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticTreyResearch(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-7W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-7W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 6);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticRelecloud(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-3W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-3W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 8);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.RomeGuestChairGreen(), 8);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.DomesticTreyResearch(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-7W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-7W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AtlantaWhiteboardBase(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 6);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::Quote, CreateCustomer.ExportSchoolofArt(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-23W>'), CreatePaymentTerms.PaymentTermsCM(), '', CalculateDate('<-23W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensDesk(), 10);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.TokyoGuestChairBlue(), 8);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.MunichSwivelChairYellow(), 20);


        // Blanket Orders
        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Blanket Order", CreateCustomer.ExportSchoolofArt(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-5W>'), CreatePaymentTerms.PaymentTermsDAYS60(), '', CalculateDate('<-5W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.BerlingGuestChairYellow(), 80);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.LondonSwivelChairBlue(), 40);

        SalesHeader := ContosoSales.InsertSalesHeader(Enum::"Sales Document Type"::"Blanket Order", CreateCustomer.DomesticTreyResearch(), CreateSalesDocument.OpenYourReference(), ContosoUtilities.AdjustDate(19020101D), CalculateDate('<-7W>'), CreatePaymentTerms.PaymentTermsDAYS21(), '', CalculateDate('<-7W>'), '', '', ContosoUtilities.AdjustDate(0D), '', '');
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.SeoulGuestChairRed(), 40);
        ContosoSales.InsertSalesLineWithItem(SalesHeader, CreateItem.AthensMobilePedestal(), 20);
    end;

    procedure AnalyticsReference(): Text
    begin
        exit(AnalyticsReferenceTok);
    end;

    local procedure GetStartingDate()
    var
        AnalyticsModuleSetup: Record "Analytics Module Setup";
    begin
        AnalyticsModuleSetup.Get();
        StartingDate := AnalyticsModuleSetup."Starting Date";
    end;

    local procedure CalculateDatesForThisMonth(DateFormulaText: Text; var FirstDayOfTheMonth: Date; var LastDayOfTheMonth: Date)
    begin
        FirstDayOfTheMonth := CalcDate(DateFormulaText, CalcDate('<-CM>', StartingDate));
        LastDayOfTheMonth := CalcDate(DateFormulaText, CalcDate('<CM>', StartingDate));
    end;

    local procedure CalculateDate(DateFormulaText: Text): Date
    begin
        exit(CalcDate(DateFormulaText, StartingDate));
    end;

    var
        AnalyticsReferenceTok: Label 'ANALYTICS', Locked = true;
        StartingDate: Date;
}