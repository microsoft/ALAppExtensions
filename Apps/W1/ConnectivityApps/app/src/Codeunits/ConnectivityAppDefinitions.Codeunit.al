// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 20352 "Connectivity App Definitions"
{
    Access = Internal;
    SingleInstance = true;

    var
        TempConnectivityApp: Record "Connectivity App" temporary;
        TempApprovedConnectivityAppCountryOrRegion: Record "Conn. App Country/Region" temporary;
        TempWorksOnConnectivityAppLocalization: Record "Conn. App Country/Region" temporary;
        TempConnectivityAppDescription: Record "Connectivity App Description" temporary;
        UserPersonalization: Record "User Personalization";

    local procedure LoadBankingAppsData()
    begin
        RegisterAppBankingNL();
        RegisterAppSwissSalaryBanking();
        RegisterContiniaPaymentManagementNL();
        RegisterContiniaPaymentManagementDK();
        RegisterContiniaPaymentManagementNO();
        RegisterIQBanking();
        RegisterWiseBanking();
        RegisterIdynDirectBanking();
        RegisterSofteraBankfeed();
        RegisterSUManGOAutoBank();
        RegisterYavrioOpenBanking();
    end;

    local procedure RegisterAppBankingNL()
    var
        AppId: Text[250];
        AppName: Text[1024];
        AppPublisher: Text[250];
        AppDescription: Text[2048];
        AppProviderSupportURL: Text[250];
        AppSourceURL: Text[250];
        AppWorksOn: Text;
        AppApprovedFor: Text;
    begin
        /***************************************************
            Add app 'Banking NL' to NL
        ***************************************************/

        AppId := '62bbfa1b-2fec-4a2b-beaf-be2c79b47000';
        AppName := 'Banking NL';
        AppPublisher := 'Micro Apps';
        AppDescription := 'Fully integrate your Bank with Business Central: automatically import and process your bank transactions.';
        AppProviderSupportURL := 'https://micro-apps.com/banking-nl/';
        AppSourceUrl := 'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.microapps%7CAID.banking-nl%7CPAPPID.62bbfa1b-2fec-4a2b-beaf-be2c79b47000';
        AppApprovedFor := 'NL';
        AppWorksOn := 'NL';

        AddDescriptionTranslation(AppId, 'Integreer je Bank volledig met Business Central: importeer en verwerk automatisch al je banktransacties', 1043);
        RegisterApp(AppId, AppName, AppPublisher, AppDescription, AppProviderSupportURL, AppSourceURL, AppApprovedFor, AppWorksOn, "Connectivity Apps Category"::Banking);
    end;

    local procedure RegisterAppSwissSalaryBanking()
    var
        AppId: Text[250];
        AppName: Text[1024];
        AppPublisher: Text[250];
        AppDescription: Text[2048];
        AppProviderSupportURL: Text[250];
        AppSourceURL: Text[250];
        AppWorksOn: Text;
        AppApprovedFor: Text;
    begin
        /***************************************************
            Add app 'SwissSalary Banking' to CH
        ***************************************************/

        AppId := '15b7c820-da20-4340-a051-099c5a96b437';
        AppName := 'SwissSalary Banking';
        AppPublisher := 'SwissSalary Ltd.';
        AppDescription := 'This app allows you to create payments for a processed payroll without opening your e-banking. Grant the app access to one or several of your bank accounts of a supported financial institution and pay the payroll with just a few clicks.';
        AppProviderSupportURL := 'https://swisssalary.ch/en/products/swisssalary-apps/banking-apps';
        AppSourceUrl := 'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.swisssalary%7CAID.swisssalary-banking%7CPAPPID.15b7c820-da20-4340-a051-099c5a96b437';
        AppApprovedFor := 'CH';
        AppWorksOn := 'CH';

        AddDescriptionTranslation(AppId, 'Mit dieser App können Sie Zahlungen für eine verarbeitete Lohnabrechnung erstellen, ohne Ihr E-Banking zu öffnen. Gewähren Sie der App Zugang zu einem oder mehreren Ihrer Bankkonten eines unterstützten Finanzinstituts und bezahlen Sie die Lohnabrechnung mit wenigen Klicks.', 1031);
        AddDescriptionTranslation(AppId, 'Cette application vous permet d''effectuer des paiements pour une fiche de salaire traitée sans avoir à ouvrir votre e-banking. Donnez à l''app l''accès à un ou plusieurs de vos comptes bancaires d''un établissement financier supporté et payez la fiche de salaire en quelques clics.', 1036);
        AddDescriptionTranslation(AppId, 'Con quest’app potrete creare i pagamenti per un conteggio di salario rielaborato senza dover aprire il vostro E-Banking. Concedete all’app di accedere a uno o più conti bancari di un istituto finanziario supportato e pagherete il conteggio di salario con meno clic.', 1040);
        RegisterApp(AppId, AppName, AppPublisher, AppDescription, AppProviderSupportURL, AppSourceURL, AppApprovedFor, AppWorksOn, "Connectivity Apps Category"::Banking);
    end;

    local procedure RegisterContiniaPaymentManagementNL()
    var
        AppId: Text[250];
        AppName: Text[1024];
        AppPublisher: Text[250];
        AppDescription: Text[2048];
        AppProviderSupportURL: Text[250];
        AppSourceURL: Text[250];
        AppWorksOn: Text;
        AppApprovedFor: Text;
    begin
        /***************************************************
            Add app 'Continia Payment Management (NL)' to NL
        ***************************************************/

        AppId := 'ec587884-e9e3-48ac-97ca-3f2bdd40bb2e';
        AppName := 'Continia Payment Management (NL)';
        AppPublisher := 'Continia Software';
        AppDescription := 'Connect your online bank to Business Central. With Continia Payment Management, you can pay your vendors, match customer payments, and reconcile statements directly from Business Central - fully integrated and secure without having to log into your online bank. Payment Management offers direct integration to most banks in the Netherlands, such as: ABN-Amro, ING, Rabobank, ASN Bank, Bunq, Knab, RegioBank, SNS, Triodos Bank. Start a free trial by downloading the app, or visit the Continia website for more information.';
        AppProviderSupportURL := 'https://www.continia.com/inspiration/solution-usage/connect-your-banks-to-business-central/';
        AppSourceUrl := 'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.continia365%7CAID.continia-payment-management-365-nl%7CPAPPID.ec587884-e9e3-48ac-97ca-3f2bdd40bb2e';
        AppApprovedFor := 'NL';
        AppWorksOn := 'NL';

        AddDescriptionTranslation(AppId, 'Verbind uw online bank met Business Central. Met Continia Payment Management kunt u uw leveranciers betalen, betalingen van klanten matchen en afschriften direct vanuit Business Central reconciliëren - volledig geïntegreerd en veilig, zonder dat u hoeft in te loggen bij uw online bank. Payment Management biedt directe integratie met de meeste banken in Nederland, zoals: ABN-Amro, ING, Rabobank, ASN Bank, Bunq, Knab, RegioBank, SNS, Triodos Bank. Begin uw gratis proefperiode door de app te downloaden, of bezoek de Continia-website voor meer informatie.', 1043);
        RegisterApp(AppId, AppName, AppPublisher, AppDescription, AppProviderSupportURL, AppSourceURL, AppApprovedFor, AppWorksOn, "Connectivity Apps Category"::Banking);
    end;

    local procedure RegisterContiniaPaymentManagementDK()
    var
        AppId: Text[250];
        AppName: Text[1024];
        AppPublisher: Text[250];
        AppDescription: Text[2048];
        AppProviderSupportURL: Text[250];
        AppSourceURL: Text[250];
        AppWorksOn: Text;
        AppApprovedFor: Text;
    begin
        /***************************************************
            Add app 'Continia Payment Management (DK)' to DK
        ***************************************************/

        AppId := '1dafd1ac-6218-4a6e-9bd7-3dec0f14a072';
        AppName := 'Continia Payment Management (DK)';
        AppPublisher := 'Continia Software';
        AppDescription := 'Connect your online bank to Business Central. With Continia Payment Management, you can pay your vendors, match customer payments, and reconcile statements directly from Business Central - fully integrated and secure without having to log into your online bank. Payment Management offers direct integration to most banks in Denmark, such as: Danske Bank, Nordea, Sydbank, Handelsbanken, SparNord, Jyske Bank, SEB, Arbejdernes Landsbank, All Savings banks. Start a free trial by downloading the app, or visit the Continia website for more information.';
        AppProviderSupportURL := 'https://www.continia.com/inspiration/solution-usage/connect-your-banks-to-business-central/';
        AppSourceUrl := 'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.continia365%7CAID.c7577a9d-eec1-44cd-85f9-800529a2f90d%7CPAPPID.1dafd1ac-6218-4a6e-9bd7-3dec0f14a072';
        AppApprovedFor := 'DK';
        AppWorksOn := 'DK';

        AddDescriptionTranslation(AppId, 'Tilslut din netbank til Business Central. Med Continia Payment Management kan du betale dine leverandører, matche kundebetalinger og afstemme kontoudtog direkte fra Business Central - fuldt integreret og sikkert uden at skulle logge ind på din netbank. Payment Management tilbyder direkte integration til alle banker i Danmark, såsom: Danske Bank, Nordea, Sydbank, Handelsbanken, SparNord, Jyske Bank, SEB, Arbejdernes Landsbank, Alle sparekasser. Start din gratis prøveperiode ved at downloade appen, eller besøg Continias hjemmeside for mere information.', 1030);
        RegisterApp(AppId, AppName, AppPublisher, AppDescription, AppProviderSupportURL, AppSourceURL, AppApprovedFor, AppWorksOn, "Connectivity Apps Category"::Banking);
    end;

    local procedure RegisterContiniaPaymentManagementNO()
    var
        AppId: Text[250];
        AppName: Text[1024];
        AppPublisher: Text[250];
        AppDescription: Text[2048];
        AppProviderSupportURL: Text[250];
        AppSourceURL: Text[250];
        AppWorksOn: Text;
        AppApprovedFor: Text;
    begin
        /***************************************************
            Add app 'Continia Payment Management (NO)' to NO
        ***************************************************/

        AppId := '9f6c9dd2-64ac-488c-85bc-9bd05a0b42a3';
        AppName := 'Continia Payment Management (NO)';
        AppPublisher := 'Continia Software';
        AppDescription := 'Connect your online bank to Business Central. With Continia Payment Management, you can pay your vendors, match customer payments, and reconcile statements directly from Business Central - fully integrated and secure without having to log into your online bank. Payment Management offers direct integration to most banks in Norway, such as: DNB, Handelsbanken, Nordea, SpareBank 1, Sparebanken Vest, Danske Bank. Start a free trial by downloading the app, or visit the Continia website for more information.';
        AppProviderSupportURL := 'https://www.continia.com/inspiration/solution-usage/connect-your-banks-to-business-central/';
        AppSourceUrl := 'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.continia365%7CAID.continia-payment-management-365-no%7CPAPPID.9f6c9dd2-64ac-488c-85bc-9bd05a0b42a3';
        AppApprovedFor := 'NO';
        AppWorksOn := 'NO';

        AddDescriptionTranslation(AppId, 'Nettbanken din kan kobles til Business Central. Med Continia Payment Management kan du betale dine leverandører, matche kundebetalinger og avstemme kontoutskrifter direkte fra Business Central – fullt integrert og sikkert uten å måtte logge på nettbanken din. Payment Management har integrasjon til følgende banker i Norge: DNB, Handelsbanken, Nordea, SpareBank 1, Sparebanken Vest, Danske Bank. Last ned appen og start din gratis prøveversjon, eller besøk nettsiden vår for mer informasjon.', 1044);
        RegisterApp(AppId, AppName, AppPublisher, AppDescription, AppProviderSupportURL, AppSourceURL, AppApprovedFor, AppWorksOn, "Connectivity Apps Category"::Banking);
    end;

    local procedure RegisterIQBanking()
    var
        AppId: Text[250];
        AppName: Text[1024];
        AppPublisher: Text[250];
        AppDescription: Text[2048];
        AppProviderSupportURL: Text[250];
        AppSourceURL: Text[250];
        AppWorksOn: Text;
        AppApprovedFor: Text;
    begin
        /***************************************************
            Add app 'IQ Banking' to ES
        ***************************************************/

        AppId := '80d82476-426c-4812-be05-bfcbaf777868';
        AppName := 'IQ Banking';
        AppPublisher := 'InnoQubit Software';
        AppDescription := 'Manage your banks directly from Business Central. In order to make financial management easier, this app allows you import bank transactions and execute payments in an easy and secure way, without leaving your Business Central environment.';
        AppProviderSupportURL := 'https://innovaonline.es/banking/bank';
        AppSourceUrl := 'https://appsource.microsoft.com/es-es/product/dynamics-365-business-central/PUBID.innoqubitsoftwaresl1638027829374%7CAID.iq-banking%7CPAPPID.80d82476-426c-4812-be05-bfcbaf777868';
        AppApprovedFor := 'ES';
        AppWorksOn := 'ES';

        AddDescriptionTranslation(AppId, 'Gestiona tus bancos directamente desde Business Central. Con la finalidad de facilitar la gestión financiera, esta app te permite importar transacciones bancarias y ejecutar pagos de una forma sencilla y segura, sin salir de tu entorno de Business Central.', 1034);
        RegisterApp(AppId, AppName, AppPublisher, AppDescription, AppProviderSupportURL, AppSourceURL, AppApprovedFor, AppWorksOn, "Connectivity Apps Category"::Banking);
    end;

    local procedure RegisterWiseBanking()
    var
        AppId: Text[250];
        AppName: Text[1024];
        AppPublisher: Text[250];
        AppDescription: Text[2048];
        AppProviderSupportURL: Text[250];
        AppSourceURL: Text[250];
        AppWorksOn: Text;
        AppApprovedFor: Text;
    begin
        /***************************************************
            Add app 'Wise Banking' to IS
        ***************************************************/

        AppId := '6a580fed-3f05-40d3-bd61-652c7af0622f';
        AppName := 'Wise Banking';
        AppPublisher := 'Wise';
        AppDescription := 'Wise Banking provides the user with secure communication with all commercial banks of Iceland. It does this by using the banking standards of the Icelandic banks (IOBS). With Wise Banking the user can therefore safely manage bank accounts, automatic bank reconciliation, outgoing payments and currency and exchange rates directly from Business Central.';
        AppProviderSupportURL := 'https://wise.is/en/solutions/wisebusiness/wise-banking/';
        AppSourceUrl := 'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.wiselausnirehf1587117975659%7CAID.wisebanking%7CPAPPID.6a580fed-3f05-40d3-bd61-652c7af0622f?tab=Overview';
        AppApprovedFor := 'IS';
        AppWorksOn := 'IS';

        AddDescriptionTranslation(AppId, 'Með Bankasamskiptakerfi Wise  eru fyrirtæki í öruggum samskiptum við sína viðskiptabanka. Bankasamskiptakerfi Wise fylgir samræmdum bankastaðli íslensku bankanna (IOBS) og uppfyllir ströngustu öryggisstaðla. Með kerfinu getur notandinn haldið utan um bankareikninga, sjálfvirkar afstemmingar, útgreiðslur og gengi gjaldmiðla beint úr Business Central á öruggan hátt.', 1039);
        RegisterApp(AppId, AppName, AppPublisher, AppDescription, AppProviderSupportURL, AppSourceURL, AppApprovedFor, AppWorksOn, "Connectivity Apps Category"::Banking);
    end;

    local procedure RegisterIdynDirectBanking()
    var
        AppId: Text[250];
        AppName: Text[1024];
        AppPublisher: Text[250];
        AppDescription: Text[2048];
        AppProviderSupportURL: Text[250];
        AppSourceURL: Text[250];
        AppWorksOn: Text;
        AppApprovedFor: Text;
    begin
        /***************************************************
            Add app 'Direct Banking' for NL, BE, DE
        ***************************************************/

        AppId := '1b3790da-e8ba-4a11-92a9-c70e37b4f831';
        AppName := 'Direct Banking';
        AppPublisher := 'IDYN B.V.';
        AppDescription := 'Automate your banking process in Business Central, no file exchange needed. Streamline bank transactions including matching for your bank accounts, and initiate payment from Business Central.';
        AppProviderSupportURL := 'https://help.idyn.nl/directbanking/bc/en/topic/about-directbanking';
        AppSourceUrl := 'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.idynbv%7CAID.bcbanking%7CPAPPID.1b3790da-e8ba-4a11-92a9-c70e37b4f831';
        AppApprovedFor := 'NL,BE,DE';
        AppWorksOn := 'W1,NL,BE,DE';

        AddDescriptionTranslation(AppId, 'Automatiseer uw bankprocessen in Business Central, zonder uitwisseling van bestanden. Stroomlijn uw banktransacties inclusief matching voor uw bankrekeningen en initieer betalingen vanuit Business Central.', 1043);
        AddDescriptionTranslation(AppId, 'Automatiseer uw bankprocessen in Business Central, zonder uitwisseling van bestanden. Stroomlijn uw banktransacties inclusief matching voor uw bankrekeningen en initieer betalingen vanuit Business Central.', 2067);
        AddDescriptionTranslation(AppId, 'Automatisez votre processus bancaire dans Business Central, sans échange de fichiers. Rationalisez les transactions bancaires, y compris l''appariement de vos comptes bancaires, et initiez des paiements à partir de Business Central.', 2060);
        AddDescriptionTranslation(AppId, 'Automatisez votre processus bancaire dans Business Central, sans échange de fichiers. Rationalisez les transactions bancaires, y compris l''appariement de vos comptes bancaires, et initiez des paiements à partir de Business Central.', 1036);
        AddDescriptionTranslation(AppId, 'Automatisieren Sie Ihre Bankprozesse in Business Central, ohne Dateien auszutauschen. Optimieren Sie Ihre Banktransaktionen, einschließlich des Abgleichs mit Ihren Bankkonten, und veranlassen Sie Zahlungen über Business Central.', 1031);
        AddDescriptionTranslation(AppId, 'Automatisieren Sie Ihre Bankprozesse in Business Central, ohne Dateien auszutauschen. Optimieren Sie Ihre Banktransaktionen, einschließlich des Abgleichs mit Ihren Bankkonten, und veranlassen Sie Zahlungen über Business Central.', 2055);
        AddDescriptionTranslation(AppId, 'Automatisieren Sie Ihre Bankprozesse in Business Central, ohne Dateien auszutauschen. Optimieren Sie Ihre Banktransaktionen, einschließlich des Abgleichs mit Ihren Bankkonten, und veranlassen Sie Zahlungen über Business Central.', 3079);
        RegisterApp(AppId, AppName, AppPublisher, AppDescription, AppProviderSupportURL, AppSourceURL, AppApprovedFor, AppWorksOn, "Connectivity Apps Category"::Banking);
    end;

    local procedure RegisterSofteraBankfeed()
    var
        AppId: Text[250];
        AppName: Text[1024];
        AppPublisher: Text[250];
        AppDescription: Text[2048];
        AppProviderSupportURL: Text[250];
        AppSourceURL: Text[250];
        AppWorksOn: Text;
        AppApprovedFor: Text;
    begin
        /***************************************************
            Add app 'Bankfeed - Bank Statement Import & Reconciliation' to LT, DK, HU, GB
        ***************************************************/

        AppId := '74689c09-2ed3-4e69-a2e8-c9310a271b9a';
        AppName := 'Bankfeed - Bank Statement Import & Reconciliation';
        AppPublisher := 'Softera Baltic';
        AppDescription := 'Bank statement import & reconciliation.';
        AppProviderSupportURL := 'https://bankfeed.com/banks/';
        AppSourceUrl := 'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.softera_baltic%7CAID.softeradokubank%7CPAPPID.74689c09-2ed3-4e69-a2e8-c9310a271b9a';
        AppApprovedFor := 'LT,DK,HU,GB';
        AppWorksOn := 'W1,DK,GB';

        AddDescriptionTranslation(AppId, 'Banko išrašo importas ir suderinimas.', 1063);
        AddDescriptionTranslation(AppId, 'Kontoudtog import & afstemning.', 1030);
        AddDescriptionTranslation(AppId, 'Banki kivonat importálása és egyeztetése.', 1038);
        RegisterApp(AppId, AppName, AppPublisher, AppDescription, AppProviderSupportURL, AppSourceURL, AppApprovedFor, AppWorksOn, "Connectivity Apps Category"::Banking);
    end;

    local procedure RegisterSUManGOAutoBank()
    var
        AppId: Text[250];
        AppName: Text[1024];
        AppPublisher: Text[250];
        AppDescription: Text[2048];
        AppProviderSupportURL: Text[250];
        AppSourceURL: Text[250];
        AppWorksOn: Text;
        AppApprovedFor: Text;
    begin
        /***************************************************
            Add app 'Sumango AutoBank' to NO, SE
        ***************************************************/

        AppId := '52508c8d-fb2b-49da-9657-f49859fd43cc';
        AppName := 'Sumango AutoBank';
        AppPublisher := 'Sumango AS';
        AppDescription := 'AutoBank manage payments, recivables, refunds and reconciliation in all currencies directly from Business Central. Streamlines, simplifies and expands bank functionality without leaving your Business Central environment. Sumango AutoBank support banks in Norway, Sweden, Denmark, Finland, Germany, Portugal, United Kingdom and United States. Visit www.sumango.no for more information.';
        AppProviderSupportURL := 'https://oseberg.atlassian.net/wiki/spaces/Autobank/pages/2342191252/Integrated+banks';
        AppSourceUrl := 'https://appsource.microsoft.com/nb-NO/product/dynamics-365-business-central/PUBID.sumango_as%7CAID.sumango_autobank%7CPAPPID.52508c8d-fb2b-49da-9657-f49859fd43cc';
        AppApprovedFor := 'NO,SE';
        AppWorksOn := 'NO,SE';

        AddDescriptionTranslation(AppId, 'AutoBank har som hovedfokus å effektivisere, forenkle og utvide funksjonalitet rundt betaling, innbetalinger, refusjoner og avstemming av banktransaksjoner i alle valutaer. Du kan nå trygt integrere banken din direkte i Business Central uten filhåndtering. AutoBank støtter alle banker i Norge, samt utvalgte banker i Sverige, Danmark, Finland, Tyskland, Portugal, England og USA. (www.sumango.no)', 1044);
        AddDescriptionTranslation(AppId, 'AutoBanks huvudfokus är att effektivisera, förenkla och utöka funktionaliteten kring leverantör betalningar, kund betalningar, återbetalning och avstämning av banktransaktioner i alla valutor. Du kan nu säkert integrera din bank direkt i Business Central utan filhantering. AutoBank stödjer följande bankar Handelsbanken, SEB, Nordea, Danske Bank, och DNB.', 1053);
        RegisterApp(AppId, AppName, AppPublisher, AppDescription, AppProviderSupportURL, AppSourceURL, AppApprovedFor, AppWorksOn, "Connectivity Apps Category"::Banking);
    end;

    local procedure RegisterYavrioOpenBanking()
    var
        AppId: Text[250];
        AppName: Text[1024];
        AppPublisher: Text[250];
        AppDescription: Text[2048];
        AppProviderSupportURL: Text[250];
        AppSourceURL: Text[250];
        AppWorksOn: Text;
        AppApprovedFor: Text;
    begin
        /***************************************************
            Add app 'Yavrio Open Banking' to GB
        ***************************************************/

        AppId := '3d686c04-e1b1-435e-bea4-862c2c203ca7';
        AppName := 'Yavrio Open Banking';
        AppPublisher := 'Yavrio';
        AppDescription := 'Yavrio Open Banking uses industry-standard Open Banking technology to connect directly with your Bank Accounts. Using bank-grade security, you can draw down live feeds directly into Business Central, with no files required, and push payments directly from BC onto the Bank.';
        AppProviderSupportURL := 'https://yavr.io/bank-coverage/';
        AppSourceUrl := 'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.yavrioltd1647526263468%7CAID.yavrio_open_banking%7CPAPPID.3d686c04-e1b1-435e-bea4-862c2c203ca7';
        AppApprovedFor := 'GB';
        AppWorksOn := 'GB';

        RegisterApp(AppId, AppName, AppPublisher, AppDescription, AppProviderSupportURL, AppSourceURL, AppApprovedFor, AppWorksOn, "Connectivity Apps Category"::Banking);
    end;

    internal procedure GetConnectivityAppDefinitions(var ConnectivityApps: Record "Connectivity App"; var ApprovedConnectivityAppCountry: Record "Conn. App Country/Region"; var WorksOnConnectivityAppCountry: Record "Conn. App Country/Region")
    begin
        LoadData();
        ConnectivityApps.Copy(TempConnectivityApp, true);
        ApprovedConnectivityAppCountry.Copy(TempApprovedConnectivityAppCountryOrRegion, true);
        WorksOnConnectivityAppCountry.Copy(TempWorksOnConnectivityAppLocalization, true);
    end;

    internal procedure ApprovedConnectivityAppsForCurrentCountryExists(CurrentCountryOrRegion: Enum "Conn. Apps Country/Region"; CurrentLocalization: Enum "Connectivity Apps Localization") Exists: Boolean
    var
        IdFilter: Text;
    begin
        LoadData();
        TempWorksOnConnectivityAppLocalization.SetRange(Localization, CurrentLocalization);
        if TempWorksOnConnectivityAppLocalization.FindSet() then
            repeat
                IdFilter += TempWorksOnConnectivityAppLocalization."App Id" + '|';
            until TempWorksOnConnectivityAppLocalization.Next() = 0;
        IdFilter := IdFilter.TrimEnd('|');

        TempApprovedConnectivityAppCountryOrRegion.SetRange("Country/Region", CurrentCountryOrRegion);
        TempApprovedConnectivityAppCountryOrRegion.SetFilter("App Id", IdFilter);
        Exists := not TempApprovedConnectivityAppCountryOrRegion.IsEmpty();
        TempApprovedConnectivityAppCountryOrRegion.Reset();
    end;

    internal procedure ApprovedConnectivityAppsForCurrentCountryExists(CurrentCountryOrRegion: Enum "Conn. Apps Country/Region"; CurrentLocalization: Enum "Connectivity Apps Localization"; ConnectivityAppCategory: Enum "Connectivity Apps Category") Exists: Boolean
    var
        IdFilter: Text;
    begin
        LoadData();
        TempWorksOnConnectivityAppLocalization.SetRange(Localization, CurrentLocalization);
        TempWorksOnConnectivityAppLocalization.SetRange(Category, ConnectivityAppCategory);
        if TempWorksOnConnectivityAppLocalization.FindSet() then
            repeat
                IdFilter += TempWorksOnConnectivityAppLocalization."App Id" + '|';
            until TempWorksOnConnectivityAppLocalization.Next() = 0;
        IdFilter := IdFilter.TrimEnd('|');

        TempApprovedConnectivityAppCountryOrRegion.SetRange("Country/Region", CurrentCountryOrRegion);
        TempApprovedConnectivityAppCountryOrRegion.SetRange(Category, ConnectivityAppCategory);
        TempApprovedConnectivityAppCountryOrRegion.SetFilter("App Id", IdFilter);
        Exists := not TempApprovedConnectivityAppCountryOrRegion.IsEmpty();
        TempApprovedConnectivityAppCountryOrRegion.Reset();
    end;

    internal procedure WorksOnConnectivityAppForCurrentLocalizationExists(ConnectivityAppLocalization: Enum "Connectivity Apps Localization") Exists: Boolean
    begin
        LoadData();
        TempWorksOnConnectivityAppLocalization.SetRange(Localization, ConnectivityAppLocalization);
        Exists := not TempWorksOnConnectivityAppLocalization.IsEmpty();
        TempWorksOnConnectivityAppLocalization.Reset();
    end;

    internal procedure WorksOnConnectivityAppForCurrentLocalizationExists(ConnectivityAppLocalization: Enum "Connectivity Apps Localization"; ConnectivityAppCategory: Enum "Connectivity Apps Category") Exists: Boolean
    begin
        LoadData();
        TempWorksOnConnectivityAppLocalization.SetRange(Localization, ConnectivityAppLocalization);
        TempWorksOnConnectivityAppLocalization.SetRange(Category, ConnectivityAppCategory);
        Exists := not TempWorksOnConnectivityAppLocalization.IsEmpty();
        TempWorksOnConnectivityAppLocalization.Reset();
    end;

    local procedure AddDescriptionTranslation(AppIdText: Text[250]; AppDescription: Text[2048]; LanguageId: Integer)
    var
        WindowsLanguage: Record "Windows Language";
        AppId: Guid;
    begin
        Evaluate(AppId, AppIdText);
        WindowsLanguage.SetRange("Primary Language ID", LanguageId);
        if WindowsLanguage.FindSet() then
            repeat
                TempConnectivityAppDescription.Init();
                TempConnectivityAppDescription."App Id" := AppId;
                TempConnectivityAppDescription."Language Id" := WindowsLanguage."Language ID";
                TempConnectivityAppDescription.Description := AppDescription;
                TempConnectivityAppDescription.Insert();
            until WindowsLanguage.Next() = 0;
    end;

    local procedure LoadData()
    begin
        if TempConnectivityApp.Count() > 0 then
            exit;

        LoadBankingAppsData();
    end;

    local procedure RegisterApp(AppIdText: Text[250]; AppName: Text[1024]; AppPublisher: Text[250]; AppDescription: Text[2048]; AppProviderSupportURL: Text[250]; AppSourceUrl: Text[250]; AppApprovedForCountriesOrRegions: Text; AppWorksOnCountriesOrRegions: Text; AppCategory: Enum "Connectivity Apps Category")
    var
        AppId: Guid;
        CountryOrRegionList, LocalizationList : List of [Text];
        CountryOrRegion, Localization : Text;
    begin
        Evaluate(AppId, AppIdText);
        TempConnectivityApp.Init();
        TempConnectivityApp."App Id" := AppId;
        TempConnectivityApp.Name := AppName;
        TempConnectivityApp.Publisher := AppPublisher;
        TempConnectivityApp.Description := GetAppDescription(AppId, AppDescription);
        TempConnectivityApp."Provider Support URL" := AppProviderSupportURL;
        TempConnectivityApp."AppSource URL" := AppSourceUrl;
        TempConnectivityApp.Category := AppCategory;

        TempConnectivityApp.Insert();

        CountryOrRegionList := AppApprovedForCountriesOrRegions.Split(',');
        foreach CountryOrRegion in CountryOrRegionList do begin
            TempApprovedConnectivityAppCountryOrRegion.Init();
            TempApprovedConnectivityAppCountryOrRegion."App Id" := AppId;
            Evaluate(TempApprovedConnectivityAppCountryOrRegion."Country/Region", CountryOrRegion);
            TempApprovedConnectivityAppCountryOrRegion.Category := AppCategory;
            TempApprovedConnectivityAppCountryOrRegion.Insert();
        end;

        LocalizationList := AppWorksOnCountriesOrRegions.Split(',');
        foreach Localization in LocalizationList do begin
            TempWorksOnConnectivityAppLocalization.Init();
            TempWorksOnConnectivityAppLocalization."App Id" := AppId;
            Evaluate(TempWorksOnConnectivityAppLocalization.Localization, Localization);
            TempWorksOnConnectivityAppLocalization.Category := AppCategory;
            if TempWorksOnConnectivityAppLocalization.Insert() then; // this is needed because of the default value of the enum
        end;
    end;

    local procedure GetAppDescription(AppId: Guid; AppDescription: Text[2048]): Text[2048]
    begin
        if UserPersonalization."Language ID" = 0 then
            if not UserPersonalization.Get(UserSecurityId()) then
                exit(AppDescription);

        if TempConnectivityAppDescription.Get(AppId, UserPersonalization."Language ID") then
            exit(TempConnectivityAppDescription.Description);

        exit(AppDescription);
    end;

    // Methods to help override the default definitions during tests
    internal procedure SetConnectivityAppDefinitions(var ConnectivityApps: Record "Connectivity App"; var ApprovedConnectivityAppCountryOrRegion: Record "Conn. App Country/Region"; var WorksOnConnectivityAppCountryOrRegion: Record "Conn. App Country/Region")
    begin
        TempConnectivityApp.Copy(ConnectivityApps, true);
        TempApprovedConnectivityAppCountryOrRegion.Copy(ApprovedConnectivityAppCountryOrRegion, true);
        TempWorksOnConnectivityAppLocalization.Copy(WorksOnConnectivityAppCountryOrRegion, true);
    end;

    internal procedure ClearConnectivityAppDefinitions()
    begin
        TempConnectivityApp.DeleteAll();
        TempConnectivityAppDescription.DeleteAll();
        TempApprovedConnectivityAppCountryOrRegion.DeleteAll();
        TempWorksOnConnectivityAppLocalization.DeleteAll();
    end;
}