codeunit 5222 "Create Sustainability Entry"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Sustainability Jnl. Line" = r;

    trigger OnRun()
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainJnlSetup: Codeunit "Create Sustain. Jnl. Setup";
        LastLineNo: Integer;
    begin
        SustainabilityJnlLine.SetRange("Journal Template Name", SustainJnlSetup.GeneralTemplate());
        SustainabilityJnlLine.SetRange("Journal Batch Name", SustainJnlSetup.DefaultBatch());
        SustainabilityJnlLine.FindLast();
        LastLineNo := SustainabilityJnlLine."Line No.";

        CreateLinesToPost(SustainJnlSetup.GeneralTemplate(), SustainJnlSetup.DefaultBatch());

        PostCreatedEntries(LastLineNo, SustainJnlSetup.GeneralTemplate(), SustainJnlSetup.DefaultBatch());
    end;

    local procedure CreateLinesToPost(TemplateName: Code[10]; BatchName: Code[10])
    var
        ContosoUtility: Codeunit "Contoso Utilities";
        ContosoSustainability: Codeunit "Contoso Sustainability";
        Account: Codeunit "Create Sustainability Account";
        CreateUnitOfMeasure: Codeunit "Create Unit Of Measure";
    begin
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030131D), 'SJ00001', Account.Refrigerators(), CreateUnitOfMeasure.Piece(), 0, 0, 15, 3, 0.8, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030131D), 'SJ00001', Account.PurchasedElectricityContosoPowerPlant(), CreateUnitOfMeasure.KWH(), 4682, 0, 0, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030131D), 'SJ00003', Account.CompanyCarLargeSize(), CreateUnitOfMeasure.KM(), 0, 860, 0, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030131D), 'SJ00003', Account.ContosoHotel3Stars(), CreateUnitOfMeasure.Day(), 0, 0, 4, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030131D), 'SJ00003', Account.ContosoRentalCar(), CreateUnitOfMeasure.L(), 16, 0, 0, 1, 0, 'US', '');

        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030228D), 'SJ00004', Account.Refrigerators(), CreateUnitOfMeasure.Piece(), 0, 0, 15, 3, 0.8, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030228D), 'SJ00004', Account.PurchasedElectricityContosoPowerPlant(), CreateUnitOfMeasure.KWH(), 5011, 0, 0, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030228D), 'SJ00006', Account.CompanyCarLargeSize(), CreateUnitOfMeasure.KM(), 0, 652, 0, 1, 0, 'US', '');

        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030331D), 'SJ00007', Account.Refrigerators(), CreateUnitOfMeasure.Piece(), 0, 0, 15, 3, 0.8, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030331D), 'SJ00007', Account.PurchasedElectricityContosoPowerPlant(), CreateUnitOfMeasure.KWH(), 4998, 0, 0, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030331D), 'SJ00009', Account.CompanyCarLargeSize(), CreateUnitOfMeasure.KM(), 0, 860, 0, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030331D), 'SJ00009', Account.ContosoHotel4StarsJuniorSuite(), CreateUnitOfMeasure.Day(), 0, 0, 6, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030331D), 'SJ00009', Account.ContosoRentalCar(), CreateUnitOfMeasure.L(), 16, 0, 0, 1, 0, 'US', '');

        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030430D), 'SJ00012', Account.Refrigerators(), CreateUnitOfMeasure.Piece(), 0, 0, 15, 3, 0.8, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030430D), 'SJ00012', Account.PurchasedElectricityContosoPowerPlant(), CreateUnitOfMeasure.KWH(), 4456, 0, 0, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030430D), 'SJ00014', Account.CompanyCarLargeSize(), CreateUnitOfMeasure.KM(), 0, 564, 0, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030430D), 'SJ00014', Account.CompanyCarPremiumSize(), CreateUnitOfMeasure.KM(), 0, 226, 0, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030430D), 'SJ00014', Account.ContosoHotel4StarsJuniorSuite(), CreateUnitOfMeasure.Day(), 0, 0, 5, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030430D), 'SJ00014', Account.ContosoHotel3Stars(), CreateUnitOfMeasure.Day(), 0, 0, 4, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030430D), 'SJ00014', Account.ContosoRentalCar(), CreateUnitOfMeasure.L(), 16, 0, 0, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030430D), 'SJ00016', Account.AirConditionEquipments24kW(), CreateUnitOfMeasure.Piece(), 0, 0, 5, 44, 0.25, 'US', '');

        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030531D), 'SJ00017', Account.AirConditionEquipments24kW(), CreateUnitOfMeasure.Piece(), 0, 0, 5, 56, 0.4, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030531D), 'SJ00017', Account.Refrigerators(), CreateUnitOfMeasure.Piece(), 0, 0, 18, 3, 0.85, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030531D), 'SJ00017', Account.PurchasedElectricityContosoPowerPlant(), CreateUnitOfMeasure.KWH(), 5827, 0, 0, 1, 0, 'US', '');

        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030409D), 'SJ00027', Account.OnRoadVehiclesLongHaulTrucks(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 2.42, 0.15125, 0.01222, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030409D), 'SJ00027', Account.AirIntercontinentalBusiness(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 2.165, 1.35313, 0.01093, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030409D), 'SJ00027', Account.PurchasedGoodsPlastic(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 14.11, 0.64136, 0.04064, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030409D), 'SJ00027', Account.PurchasedGoodsAluminum(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 3.98, 0.16583, 0.01567, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030409D), 'SJ00027', Account.PurchasedGoodsSteel(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 3.285, 0.11328, 0.01846, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030410D), 'SJ00027', Account.OnRoadVehiclesLongHaulTrucks(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 2, 0.0625, 0.00671, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030410D), 'SJ00027', Account.AirIntercontinentalBusiness(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 1.5, 0.04688, 0.00758, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030410D), 'SJ00027', Account.PurchasedGoodsPlastic(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 9.65, 0.30156, 0.03238, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030410D), 'SJ00027', Account.PurchasedGoodsAluminum(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 2.85, 0.08906, 0.00956, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030410D), 'SJ00027', Account.PurchasedGoodsSteel(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 2.15, 0.06719, 0.00721, '', '');
    end;

    local procedure PostCreatedEntries(LastLineNo: Integer; TemplateName: Code[10]; BatchName: Code[10])
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
    begin
        SustainabilityJnlLine.SetRange("Journal Template Name", TemplateName);
        SustainabilityJnlLine.SetRange("Journal Batch Name", BatchName);
        SustainabilityJnlLine.SetFilter("Line No.", '>%1', LastLineNo);
        SustainabilityJnlLine.FindSet();

        Codeunit.Run(Codeunit::"Sustainability Jnl.-Post", SustainabilityJnlLine);
    end;
}