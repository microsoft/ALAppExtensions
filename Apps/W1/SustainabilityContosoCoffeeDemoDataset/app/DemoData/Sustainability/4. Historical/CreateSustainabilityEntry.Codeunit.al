#pragma warning disable AA0247
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

        CreateAndPostLinesForWaterWasteBatch();
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

        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030407D), 'SJ00029', Account.OnRoadVehiclesLongHaulTrucks(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 3428, 93.75, 10.06711, 'CA', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030407D), 'SJ00029', Account.HeatersSmall(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 64.2314, 2, 0.21477, 'CA', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030118D), 'SJ00030', Account.OnRoadVehiclesLongHaulTrucks(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 400, 112.5, 11.38408, 'CA', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030207D), 'SJ00030', Account.NonRoadVehiclesForklifts(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 421, 13, 1.5, 'CA', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030314D), 'SJ00030', Account.AirContinentalBusiness(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 399, 12.4, 1.36, 'CA', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030207D), 'SJ00030', Account.Refrigerators(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 117, 3.65625, 0.40484, 'CA', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030505D), 'SJ00029', Account.AirContinentalBusiness(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 573.2, 17.90625, 1.9827, 'CA', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030118D), 'SJ00030', Account.PurchasedElectricityContosoPowerPlant(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 1511, 100, 12.5, 'GB', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030207D), 'SJ00030', Account.SteamFabrikamInc(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 473, 35, 4.5, 'GB', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030323D), 'SJ00030', Account.HeatingFabrikamInc(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 628, 44, 5.5, 'GB', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030522D), 'SJ00029', Account.PurchasedElectricityContosoPowerPlant(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 128, 143.456, 19.56108, 'GB', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030119D), 'SJ00030', Account.PurchasedGoodsPlastic(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 1000, 30, 0, 'DE', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030125D), 'SJ00030', Account.PurchasedGoodsAluminum(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 1420, 35, 3.6077, 'DE', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030205D), 'SJ00030', Account.PurchasedGoodsSteel(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 1000, 30, 3, 'DE', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030221D), 'SJ00030', Account.PurchasedGoodsGlass(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 1000, 30, 3.0504, 'DE', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030302D), 'SJ00030', Account.TransportationWithOwnTrucks(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 2100, 71.4371, 6.99802, 'DK', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030308D), 'SJ00030', Account.UseOfSoldProducts(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 1150, 32, 3.1009, 'DK', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030309D), 'SJ00030', Account.WasteOrganicGeneratedInOperation(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 1000, 30, 3, 'DK', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030313D), 'SJ00030', Account.ContosoHotel4Stars(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 1250, 33, 3.111, 'DK', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030322D), 'SJ00030', Account.WasteOrganicGeneratedInOperation(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 1000, 30.8, 3, 'DK', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030405D), 'SJ00029', Account.PurchasedGoodsPlastic(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 218, 10.0402, 1.0022, 'DE', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030411D), 'SJ00029', Account.PurchasedGoodsAluminum(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 232, 11, 1.10406, 'DE', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030419D), 'SJ00029', Account.PurchasedGoodsSteel(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 554.1708, 25, 2.3, 'DE', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030424D), 'SJ00029', Account.PurchasedGoodsGlass(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 325, 16, 1.5, 'DE', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030503D), 'SJ00029', Account.TransportationWithOwnTrucks(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 475, 22.00776, 2.00662, 'DK', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030503D), 'SJ00029', Account.UseOfSoldProducts(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 262, 12, 1.1, 'DK', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030508D), 'SJ00029', Account.WasteOrganicGeneratedInOperation(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 438, 21, 1.99562, 'DK', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030512D), 'SJ00029', Account.ContosoHotel4Stars(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 374, 17, 1.6, 'DK', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030515D), 'SJ00029', Account.WasteOrganicGeneratedInOperation(), true, CreateUnitOfMeasure.Piece(), 0, 0, 0, 0, 0, 632.09, 19.448, 2, 'DK', '');
    end;

    local procedure CreateAndPostLinesForWaterWasteBatch()
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
        SustainJnlSetup: Codeunit "Create Sustain. Jnl. Setup";
        LastLineNo: Integer;
    begin
        SustainabilityJnlLine.SetRange("Journal Template Name", SustainJnlSetup.GeneralTemplate());
        SustainabilityJnlLine.SetRange("Journal Batch Name", SustainJnlSetup.WaterWasteBatch());
        if SustainabilityJnlLine.FindLast() then
            LastLineNo := SustainabilityJnlLine."Line No.";

        CreateLinesForWaterWasteBatch(SustainJnlSetup.GeneralTemplate(), SustainJnlSetup.WaterWasteBatch());
        PostCreatedEntries(LastLineNo, SustainJnlSetup.GeneralTemplate(), SustainJnlSetup.WaterWasteBatch());
    end;

    local procedure CreateLinesForWaterWasteBatch(TemplateName: Code[10]; BatchName: Code[10])
    var
        ContosoUtility: Codeunit "Contoso Utilities";
        ContosoSustainability: Codeunit "Contoso Sustainability";
        Account: Codeunit "Create Sustainability Account";
        CreateUnitOfMeasure: Codeunit "Create Unit Of Measure";
        CreateSustResponsibility: Codeunit "Create Sust. Responsibility";
    begin
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030607D), 'SJ00020', Account.GreenWater(), true, CreateUnitOfMeasure.M3(), 0, 0, 0, 0, 0, 0, 0, 0, 2685, 0, 0, "Water/Waste Intensity Type"::Consumed, "Water Type"::"Surface water", 'DK', CreateSustResponsibility.Production());
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030607D), 'SJ00020', Account.BlueWater(), true, CreateUnitOfMeasure.M3(), 0, 0, 0, 0, 0, 0, 0, 0, 1042, 0, 0, "Water/Waste Intensity Type"::Withdrawn, "Water Type"::"Ground water", 'US', CreateSustResponsibility.Production());
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030607D), 'SJ00020', Account.BlueWater(), true, CreateUnitOfMeasure.M3(), 0, 0, 0, 0, 0, 0, 0, 0, 611, 0, 0, "Water/Waste Intensity Type"::Withdrawn, "Water Type"::"Ground water", 'DE', CreateSustResponsibility.Production());
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030607D), 'SJ00020', Account.GreyWater(), true, CreateUnitOfMeasure.M3(), 0, 0, 0, 0, 0, 0, 0, 0, 1142, 0, 0, "Water/Waste Intensity Type"::Recycled, "Water Type"::"Third party water", 'CA', CreateSustResponsibility.Production());
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030607D), 'SJ00020', Account.DischargedWater1(), true, CreateUnitOfMeasure.M3(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3228, "Water/Waste Intensity Type"::Discharged, "Water Type"::"Produced water", 'US', CreateSustResponsibility.Production());

        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030407D), 'SJ00020', Account.BlueWater(), true, CreateUnitOfMeasure.M3(), 0, 0, 0, 0, 0, 0, 0, 0, 1429, 0, 0, "Water/Waste Intensity Type"::Withdrawn, "Water Type"::"Ground water", 'US', CreateSustResponsibility.Warehouse());
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030407D), 'SJ00020', Account.BlueWater(), true, CreateUnitOfMeasure.M3(), 0, 0, 0, 0, 0, 0, 0, 0, 433, 0, 0, "Water/Waste Intensity Type"::Withdrawn, "Water Type"::"Ground water", 'GB', CreateSustResponsibility.Warehouse());

        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030205D), 'SJ00020', Account.BlueWater(), true, CreateUnitOfMeasure.M3(), 0, 0, 0, 0, 0, 0, 0, 0, 2938, 0, 0, "Water/Waste Intensity Type"::Withdrawn, "Water Type"::"Ground water", 'CA', CreateSustResponsibility.Warehouse());
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030205D), 'SJ00020', Account.GreyWater(), true, CreateUnitOfMeasure.M3(), 0, 0, 0, 0, 0, 0, 0, 0, 5011, 0, 0, "Water/Waste Intensity Type"::Recycled, "Water Type"::"Third party water", 'US', CreateSustResponsibility.Production());
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030205D), 'SJ00020', Account.DischargedWater1(), true, CreateUnitOfMeasure.M3(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4722, "Water/Waste Intensity Type"::Discharged, "Water Type"::"Produced water", 'AU', CreateSustResponsibility.Production());

        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030607D), 'SJ00020', Account.PlasticWaste(), true, CreateUnitOfMeasure.KG(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 458, 0, "Water/Waste Intensity Type"::Generated, "Water Type"::" ", '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030608D), 'SJ00021', Account.SteelWaste(), true, CreateUnitOfMeasure.KG(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 3860, 0, "Water/Waste Intensity Type"::Generated, "Water Type"::" ", '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030609D), 'SJ00022', Account.WoodWaste(), true, CreateUnitOfMeasure.KG(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 2420, 0, "Water/Waste Intensity Type"::Disposed, "Water Type"::" ", '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030610D), 'SJ00023', Account.RecyclableWaste(), true, CreateUnitOfMeasure.KG(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 620, 0, "Water/Waste Intensity Type"::Recovered, "Water Type"::" ", '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030611D), 'SJ00024', Account.FoodWaste(), true, CreateUnitOfMeasure.KG(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 183, 0, "Water/Waste Intensity Type"::Disposed, "Water Type"::" ", '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030205D), 'SJ00028', Account.PlasticWaste(), true, CreateUnitOfMeasure.KG(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 596, 0, "Water/Waste Intensity Type"::Generated, "Water Type"::" ", '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030205D), 'SJ00028', Account.SteelWaste(), true, CreateUnitOfMeasure.KG(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 4022, 0, "Water/Waste Intensity Type"::Generated, "Water Type"::" ", '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030205D), 'SJ00028', Account.FoodWaste(), true, CreateUnitOfMeasure.KG(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 206, 0, "Water/Waste Intensity Type"::Disposed, "Water Type"::" ", '', '');
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
