#pragma warning disable AA0247
codeunit 5221 "Create Sustainability Journal"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        SustainJnlSetup: Codeunit "Create Sustain. Jnl. Setup";
        ContosoUtility: Codeunit "Contoso Utilities";
    begin
        CreateLinesForDefaultBatch(SustainJnlSetup.GeneralTemplate(), SustainJnlSetup.DefaultBatch(), ContosoUtility.AdjustDate(19030531D));
        CreateLinesForScope1Batch(SustainJnlSetup.GeneralTemplate(), SustainJnlSetup.Scope1Batch(), ContosoUtility.AdjustDate(19030531D));
        CreateLinesForScope2Batch(SustainJnlSetup.GeneralTemplate(), SustainJnlSetup.Scope2Batch(), ContosoUtility.AdjustDate(19030531D));
        CreateLinesForScope3Batch(SustainJnlSetup.GeneralTemplate(), SustainJnlSetup.Scope3Batch(), ContosoUtility.AdjustDate(19030531D));
    end;

    local procedure CreateLinesForDefaultBatch(TemplateName: Code[10]; BatchName: Code[10]; DefaultDate: Date)
    var
        ContosoSustainability: Codeunit "Contoso Sustainability";
        Account: Codeunit "Create Sustainability Account";
        CreateUnitofMeasure: Codeunit "Create Unit of Measure";
    begin
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, DefaultDate, 'SJ00018', Account.CompanyCarLargeSize(), CreateUnitofMeasure.KM(), 0, 385, 0, 1, 0, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, DefaultDate, 'SJ00018', Account.CompanyCarMediumSize(), CreateUnitofMeasure.KM(), 0, 1820, 0, 1, 0, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, DefaultDate, 'SJ00018', Account.CompanyCarPremiumSize(), CreateUnitofMeasure.KM(), 0, 268, 0, 1, 0, '', '');

        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, DefaultDate, 'SJ00018', Account.AirContinentalEconomy(), CreateUnitofMeasure.KM(), 0, 4120, 0, 1, 0, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, DefaultDate, 'SJ00018', Account.AirIntercontinentalBusiness(), CreateUnitofMeasure.KM(), 0, 9860, 0, 1, 0, '', '');

        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, DefaultDate, 'SJ00018', Account.ContosoHotel3Stars(), CreateUnitofMeasure.Day(), 0, 0, 2, 1, 0, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, DefaultDate, 'SJ00018', Account.ContosoHotel4Stars(), CreateUnitofMeasure.Day(), 0, 0, 6, 1, 0, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, DefaultDate, 'SJ00018', Account.ContosoHotel4StarsJuniorSuite(), CreateUnitofMeasure.Day(), 0, 0, 3, 1, 0, '', '');

        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, DefaultDate, 'SJ00018', Account.ContosoRentalCar(), CreateUnitofMeasure.L(), 120, 0, 0, 1, 0, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, DefaultDate, 'SJ00018', Account.Rail(), CreateUnitofMeasure.KM(), 0, 0, 0, 1, 0, '', '');

        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, DefaultDate, 'SJ00018', Account.PurchasedServices(), 0, 0, 0, '', '');
    end;

    local procedure CreateLinesForScope1Batch(TemplateName: Code[10]; BatchName: Code[10]; DefaultDate: Date)
    var
        ContosoSustainability: Codeunit "Contoso Sustainability";
        Account: Codeunit "Create Sustainability Account";
        CreateUnitofMeasure: Codeunit "Create Unit of Measure";
    begin
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, DefaultDate, 'EMIS1-0001', Account.OnRoadVehicleUrbanTrucks(), CreateUnitofMeasure.KM(), 0, 1010, 0, 1, 0, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, DefaultDate, 'EMIS1-0001', Account.NonRoadVehiclesTractors(), CreateUnitofMeasure.L(), 225, 0, 0, 1, 0, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, DefaultDate, 'EMIS1-0001', Account.NonRoadVehiclesBackhoes(), CreateUnitofMeasure.L(), 180, 0, 0, 1, 0, '', '');
    end;

    local procedure CreateLinesForScope2Batch(TemplateName: Code[10]; BatchName: Code[10]; DefaultDate: Date)
    var
        ContosoSustainability: Codeunit "Contoso Sustainability";
        Account: Codeunit "Create Sustainability Account";
    begin
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, DefaultDate, 'EMIS1-0002', Account.SteamFabrikamInc(), '', 0, 0, 0, 1, 0, '', '');
    end;

    local procedure CreateLinesForScope3Batch(TemplateName: Code[10]; BatchName: Code[10]; DefaultDate: Date)
    var
        ContosoSustainability: Codeunit "Contoso Sustainability";
        Account: Codeunit "Create Sustainability Account";
        CreateUnitofMeasure: Codeunit "Create Unit of Measure";
    begin
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, DefaultDate, 'EMIS1-0003', Account.WastePlasticGeneratedInOperation(), CreateUnitofMeasure.Ton(), 0, 0, 0.41, 1, 0, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, DefaultDate, 'EMIS1-0003', Account.WasteOrganicGeneratedInOperation(), CreateUnitofMeasure.Ton(), 0, 0, 0.63, 1, 0, '', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, DefaultDate, 'EMIS1-0003', Account.RecycledWasteGeneratedInOperation(), CreateUnitofMeasure.Ton(), 0, 0, 0.82, 1, 0, '', '');
    end;
}
