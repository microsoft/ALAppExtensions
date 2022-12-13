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
        TempApprovedConnectivityAppCountry: Record "Connectivity App Country" temporary;
        TempWorksOnConnectivityAppCountry: Record "Connectivity App Country" temporary;
        TempConnectivityAppDescription: Record "Connectivity App Description" temporary;
        UserPersonalization: Record "User Personalization";

    local procedure LoadBankingAppsData()
    begin
        RegisterAppBankingNL();
        RegisterAppSwissSalaryBanking();
        RegisterContiniaPaymentManagement365NL();
        RegisterContiniaPaymentManagement365DK();
        RegisterContiniaPaymentManagement365NO();
        RegisterDirectBankingNL();
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

    local procedure RegisterContiniaPaymentManagement365NL()
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
            Add app 'Continia Payment Management 365 (NL)' to NL
        ***************************************************/

        AppId := 'ec587884-e9e3-48ac-97ca-3f2bdd40bb2e';
        AppName := 'Continia Payment Management 365 (NL)';
        AppPublisher := 'Continia Software';
        AppDescription := 'Connect your online bank to Business Central. With Continia Payment Management, you can pay your vendors, match customer payments, and reconcile statements directly from Business Central - fully integrated and secure without having to log into your online bank. Payment Management offers direct integration to most banks in the Netherlands, such as: ABN-Amro, ING, Rabobank, ASN Bank, Bunq, Knab, RegioBank, SNS, Triodos Bank. Start a free trial by downloading the app, or visit the Continia website for more information.';
        AppProviderSupportURL := 'https://www.continia.com/inspiration/solution-usage/connect-your-banks-to-business-central/';
        AppSourceUrl := 'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.continia365%7CAID.continia-payment-management-365-nl%7CPAPPID.ec587884-e9e3-48ac-97ca-3f2bdd40bb2e';
        AppApprovedFor := 'NL';
        AppWorksOn := 'NL';

        AddDescriptionTranslation(AppId, 'Verbind uw online bank met Business Central. Met Continia Payment Management kunt u uw leveranciers betalen, betalingen van klanten matchen en afschriften direct vanuit Business Central reconciliëren - volledig geïntegreerd en veilig, zonder dat u hoeft in te loggen bij uw online bank. Payment Management biedt directe integratie met de meeste banken in Nederland, zoals: ABN-Amro, ING, Rabobank, ASN Bank, Bunq, Knab, RegioBank, SNS, Triodos Bank. Begin uw gratis proefperiode door de app te downloaden, of bezoek de Continia-website voor meer informatie.', 1043);
        RegisterApp(AppId, AppName, AppPublisher, AppDescription, AppProviderSupportURL, AppSourceURL, AppApprovedFor, AppWorksOn, "Connectivity Apps Category"::Banking);
    end;

    local procedure RegisterContiniaPaymentManagement365DK()
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
            Add app 'Continia Payment Management 365 (DK)' to DK
        ***************************************************/

        AppId := '1dafd1ac-6218-4a6e-9bd7-3dec0f14a072';
        AppName := 'Continia Payment Management 365 (DK)';
        AppPublisher := 'Continia Software';
        AppDescription := 'Connect your online bank to Business Central. With Continia Payment Management, you can pay your vendors, match customer payments, and reconcile statements directly from Business Central - fully integrated and secure without having to log into your online bank. Payment Management offers direct integration to most banks in Denmark, such as: Danske Bank, Nordea, Sydbank, Handelsbanken, SparNord, Jyske Bank, SEB, Arbejdernes Landsbank, All Savings banks. Start a free trial by downloading the app, or visit the Continia website for more information.';
        AppProviderSupportURL := 'https://www.continia.com/inspiration/solution-usage/connect-your-banks-to-business-central/';
        AppSourceUrl := 'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.continia365%7CAID.c7577a9d-eec1-44cd-85f9-800529a2f90d%7CPAPPID.1dafd1ac-6218-4a6e-9bd7-3dec0f14a072';
        AppApprovedFor := 'DK';
        AppWorksOn := 'DK';

        AddDescriptionTranslation(AppId, 'Tilslut din netbank til Business Central. Med Continia Payment Management kan du betale dine leverandører, matche kundebetalinger og afstemme kontoudtog direkte fra Business Central - fuldt integreret og sikkert uden at skulle logge ind på din netbank. Payment Management tilbyder direkte integration til alle banker i Danmark, såsom: Danske Bank, Nordea, Sydbank, Handelsbanken, SparNord, Jyske Bank, SEB, Arbejdernes Landsbank, Alle sparekasser. Start din gratis prøveperiode ved at downloade appen, eller besøg Continias hjemmeside for mere information.', 1030);
        RegisterApp(AppId, AppName, AppPublisher, AppDescription, AppProviderSupportURL, AppSourceURL, AppApprovedFor, AppWorksOn, "Connectivity Apps Category"::Banking);
    end;

    local procedure RegisterContiniaPaymentManagement365NO()
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
            Add app 'Continia Payment Management 365 (NO)' to NO
        ***************************************************/

        AppId := '9f6c9dd2-64ac-488c-85bc-9bd05a0b42a3';
        AppName := 'Continia Payment Management 365 (NO)';
        AppPublisher := 'Continia Software';
        AppDescription := 'Connect your online bank to Business Central. With Continia Payment Management, you can pay your vendors, match customer payments, and reconcile statements directly from Business Central - fully integrated and secure without having to log into your online bank. Payment Management offers direct integration to most banks in Norway, such as: DNB, Handelsbanken, Nordea, SpareBank 1, Sparebanken Vest, Danske Bank. Start a free trial by downloading the app, or visit the Continia website for more information.';
        AppProviderSupportURL := 'https://www.continia.com/inspiration/solution-usage/connect-your-banks-to-business-central/';
        AppSourceUrl := 'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.continia365%7CAID.continia-payment-management-365-no%7CPAPPID.9f6c9dd2-64ac-488c-85bc-9bd05a0b42a3';
        AppApprovedFor := 'NO';
        AppWorksOn := 'NO';

        AddDescriptionTranslation(AppId, 'Nettbanken din kan kobles til Business Central. Med Continia Payment Management kan du betale dine leverandører, matche kundebetalinger og avstemme kontoutskrifter direkte fra Business Central – fullt integrert og sikkert uten å måtte logge på nettbanken din. Payment Management har integrasjon til følgende banker i Norge: DNB, Handelsbanken, Nordea, SpareBank 1, Sparebanken Vest, Danske Bank. Last ned appen og start din gratis prøveversjon, eller besøk nettsiden vår for mer informasjon.', 1044);
        RegisterApp(AppId, AppName, AppPublisher, AppDescription, AppProviderSupportURL, AppSourceURL, AppApprovedFor, AppWorksOn, "Connectivity Apps Category"::Banking);
    end;
    
    local procedure RegisterDirectBankingNL()
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
            Add app 'Direct Banking' to NL
        ***************************************************/

        AppId := '7d5b57c9-71d8-47f0-85b8-7a08066f7d2b';
        AppName := 'Direct Banking NL';
        AppPublisher := 'IDYN B.V.';
        AppDescription := 'Integrate ABN, Rabo, ING, Triodos, Knab, ASN, SNS, etc. with Microsoft Dynamics 365 Business Central.';
        AppProviderSupportURL := 'https://help.idyn.nl/directbanking';
        AppSourceUrl := 'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.idynbv%7CAID.bcbanking_nl%7CPAPPID.7d5b57c9-71d8-47f0-85b8-7a08066f7d2b';
        AppApprovedFor := 'NL';
        AppWorksOn := 'NL';

        AddDescriptionTranslation(AppId, 'Integreer ABN, Rabo, ING, Triodos, Knab, ASN, SNS etc. met Microsoft Dynamics 365 Business Central.', 1043);
        RegisterApp(AppId, AppName, AppPublisher, AppDescription, AppProviderSupportURL, AppSourceURL, AppApprovedFor, AppWorksOn, "Connectivity Apps Category"::Banking);
    end;

    internal procedure GetConnectivityAppDefinitions(var ConnectivityApps: Record "Connectivity App"; var ApprovedConnectivityAppCountry: Record "Connectivity App Country"; var WorksOnConnectivityAppCountry: Record "Connectivity App Country")
    begin
        LoadData();
        ConnectivityApps.Copy(TempConnectivityApp, true);
        ApprovedConnectivityAppCountry.Copy(TempApprovedConnectivityAppCountry, true);
        WorksOnConnectivityAppCountry.Copy(TempWorksOnConnectivityAppCountry, true);
    end;

    internal procedure ApprovedConnectivityAppsForCurrentCountryExists(ConnectivityAppCountry: Enum "Conn. Apps Supported Country") Exists: Boolean
    begin
        LoadData();
        TempApprovedConnectivityAppCountry.SetRange(Country, ConnectivityAppCountry);
        Exists := not TempApprovedConnectivityAppCountry.IsEmpty();
        TempApprovedConnectivityAppCountry.Reset();
    end;

    internal procedure ApprovedConnectivityAppsForCurrentCountryExists(ConnectivityAppCountry: Enum "Conn. Apps Supported Country"; ConnectivityAppCategory: Enum "Connectivity Apps Category") Exists: Boolean
    begin
        LoadData();
        TempApprovedConnectivityAppCountry.SetRange(Country, ConnectivityAppCountry);
        TempApprovedConnectivityAppCountry.SetRange(Category, ConnectivityAppCategory);
        Exists := not TempApprovedConnectivityAppCountry.IsEmpty();
        TempApprovedConnectivityAppCountry.Reset();
    end;

    internal procedure WorksOnConnectivityAppForCurrentCountryExists(ConnectivityAppCountry: Enum "Conn. Apps Supported Country") Exists: Boolean
    begin
        LoadData();
        TempWorksOnConnectivityAppCountry.SetRange(Country, ConnectivityAppCountry);
        Exists := not TempWorksOnConnectivityAppCountry.IsEmpty();
        TempWorksOnConnectivityAppCountry.Reset();
    end;

    internal procedure WorksOnConnectivityAppForCurrentCountryExists(ConnectivityAppCountry: Enum "Conn. Apps Supported Country"; ConnectivityAppCategory: Enum "Connectivity Apps Category") Exists: Boolean
    begin
        LoadData();
        TempWorksOnConnectivityAppCountry.SetRange(Country, ConnectivityAppCountry);
        TempWorksOnConnectivityAppCountry.SetRange(Category, ConnectivityAppCategory);
        Exists := not TempWorksOnConnectivityAppCountry.IsEmpty();
        TempWorksOnConnectivityAppCountry.Reset();
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

    local procedure RegisterApp(AppIdText: Text[250]; AppName: Text[1024]; AppPublisher: Text[250]; AppDescription: Text[2048]; AppProviderSupportURL: Text[250]; AppSourceUrl: Text[250]; AppApprovedForCountries: Text; AppWorksOnCountries: Text; AppCategory: Enum "Connectivity Apps Category")
    var
        AppId: Guid;
        CountryList: List of [Text];
        Country: Text;
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

        if TempConnectivityApp.Insert() then;

        CountryList := AppApprovedForCountries.Split(',');
        foreach Country in CountryList do begin
            TempApprovedConnectivityAppCountry.Init();
            TempApprovedConnectivityAppCountry."App Id" := AppId;
            Evaluate(TempApprovedConnectivityAppCountry.Country, Country);
            TempApprovedConnectivityAppCountry.Category := AppCategory;
            if TempApprovedConnectivityAppCountry.Insert() then;
        end;
        CountryList := AppWorksOnCountries.Split(',');
        foreach Country in CountryList do begin
            TempWorksOnConnectivityAppCountry.Init();
            TempWorksOnConnectivityAppCountry."App Id" := AppId;
            Evaluate(TempWorksOnConnectivityAppCountry.Country, Country);
            TempWorksOnConnectivityAppCountry.Category := AppCategory;
            if TempWorksOnConnectivityAppCountry.Insert() then;
        end;
    end;

    local procedure GetAppDescription(AppId: Guid; AppDescription: Text[2048]): Text[2048]
    begin
        if UserPersonalization."Language ID" = 0 then
            UserPersonalization.Get(UserSecurityId());

        if TempConnectivityAppDescription.Get(AppId, UserPersonalization."Language ID") then
            exit(TempConnectivityAppDescription.Description);

        exit(AppDescription);
    end;

    // Methods to help override the default definitions during tests
    internal procedure SetConnectivityAppDefinitions(var ConnectivityApps: Record "Connectivity App"; var ApprovedConnectivityAppCountry: Record "Connectivity App Country"; var WorksOnConnectivityAppCountry: Record "Connectivity App Country")
    begin
        TempConnectivityApp.Copy(ConnectivityApps, true);
        TempApprovedConnectivityAppCountry.Copy(ApprovedConnectivityAppCountry, true);
        TempWorksOnConnectivityAppCountry.Copy(WorksOnConnectivityAppCountry, true);
    end;

    internal procedure ClearConnectivityAppDefinitions()
    begin
        TempConnectivityApp.DeleteAll();
        TempConnectivityAppDescription.DeleteAll();
        TempApprovedConnectivityAppCountry.DeleteAll();
        TempWorksOnConnectivityAppCountry.DeleteAll();
    end;
}
