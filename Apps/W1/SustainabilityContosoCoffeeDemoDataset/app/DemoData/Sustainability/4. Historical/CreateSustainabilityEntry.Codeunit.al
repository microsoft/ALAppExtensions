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
        CommonUoM: Codeunit "Create Common Unit Of Measure";
    begin
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030131D), 'SJ00001', Account.Refrigerators(), CommonUoM.Piece(), 0, 0, 15, 3, 0.8, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030131D), 'SJ00001', Account.PurchasedElectricityContosoPowerPlant(), CommonUoM.KWH(), 4682, 0, 0, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030131D), 'SJ00003', Account.CompanyCarLargeSize(), CommonUoM.KM(), 0, 860, 0, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030131D), 'SJ00003', Account.ContosoHotel3Stars(), CommonUoM.Day(), 0, 0, 4, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030131D), 'SJ00003', Account.ContosoRentalCar(), CommonUoM.L(), 16, 0, 0, 1, 0, 'US', '');

        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030228D), 'SJ00004', Account.Refrigerators(), CommonUoM.Piece(), 0, 0, 15, 3, 0.8, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030228D), 'SJ00004', Account.PurchasedElectricityContosoPowerPlant(), CommonUoM.KWH(), 5011, 0, 0, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030228D), 'SJ00006', Account.CompanyCarLargeSize(), CommonUoM.KM(), 0, 652, 0, 1, 0, 'US', '');

        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030331D), 'SJ00007', Account.Refrigerators(), CommonUoM.Piece(), 0, 0, 15, 3, 0.8, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030331D), 'SJ00007', Account.PurchasedElectricityContosoPowerPlant(), CommonUoM.KWH(), 4998, 0, 0, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030331D), 'SJ00009', Account.CompanyCarLargeSize(), CommonUoM.KM(), 0, 860, 0, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030331D), 'SJ00009', Account.ContosoHotel4StarsJuniorSuite(), CommonUoM.Day(), 0, 0, 6, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030331D), 'SJ00009', Account.ContosoRentalCar(), CommonUoM.L(), 16, 0, 0, 1, 0, 'US', '');

        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030430D), 'SJ00012', Account.Refrigerators(), CommonUoM.Piece(), 0, 0, 15, 3, 0.8, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030430D), 'SJ00012', Account.PurchasedElectricityContosoPowerPlant(), CommonUoM.KWH(), 4456, 0, 0, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030430D), 'SJ00014', Account.CompanyCarLargeSize(), CommonUoM.KM(), 0, 564, 0, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030430D), 'SJ00014', Account.CompanyCarPremiumSize(), CommonUoM.KM(), 0, 226, 0, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030430D), 'SJ00014', Account.ContosoHotel4StarsJuniorSuite(), CommonUoM.Day(), 0, 0, 5, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030430D), 'SJ00014', Account.ContosoHotel3Stars(), CommonUoM.Day(), 0, 0, 4, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030430D), 'SJ00014', Account.ContosoRentalCar(), CommonUoM.L(), 16, 0, 0, 1, 0, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030430D), 'SJ00016', Account.AirConditionEquipments24kW(), CommonUoM.Piece(), 0, 0, 5, 44, 0.25, 'US', '');

        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030531D), 'SJ00017', Account.AirConditionEquipments24kW(), CommonUoM.Piece(), 0, 0, 5, 56, 0.4, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030531D), 'SJ00017', Account.Refrigerators(), CommonUoM.Piece(), 0, 0, 18, 3, 0.85, 'US', '');
        ContosoSustainability.InsertSustainabilityJournalLine(TemplateName, BatchName, ContosoUtility.AdjustDate(19030531D), 'SJ00017', Account.PurchasedElectricityContosoPowerPlant(), CommonUoM.KWH(), 5827, 0, 0, 1, 0, 'US', '');
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