codeunit 5442 "Create Campaign"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateNoSeries: Codeunit "Create No. Series";
        ContosoCRM: Codeunit "Contoso CRM";
        ContosoUtilities: Codeunit "Contoso Utilities";
        SalespersonPurchaser: Codeunit "Create Salesperson/Purchaser";
        CreateCampaignStatus: Codeunit "Create Campaign Status";
    begin
        ContosoCRM.InsertCampaign(IncreaseSale(), IncreaseSaleLbl, ContosoUtilities.AdjustDate(19020111D), ContosoUtilities.AdjustDate(19030401D), SalespersonPurchaser.HelenaRay(), CreateNoSeries.Campaign(), CreateCampaignStatus.Started());
        ContosoCRM.InsertCampaign(EventCampaign(), EventLbl, ContosoUtilities.AdjustDate(19030117D), ContosoUtilities.AdjustDate(19030120D), SalespersonPurchaser.BenjaminChiu(), CreateNoSeries.Campaign(), CreateCampaignStatus.Done());
        ContosoCRM.InsertCampaign(WorkingPlaceArrangement(), WorkingPlaceArrangementLbl, ContosoUtilities.AdjustDate(19030107D), ContosoUtilities.AdjustDate(19030401D), SalespersonPurchaser.OtisFalls(), CreateNoSeries.Campaign(), CreateCampaignStatus.Started());
    end;

    procedure IncreaseSale(): Code[20]
    begin
        exit(Campaign1001Tok);
    end;

    procedure EventCampaign(): Code[20]
    begin
        exit(Campaign1002Tok);
    end;

    procedure WorkingPlaceArrangement(): Code[20]
    begin
        exit(Campaign1003Tok);
    end;

    var
        Campaign1001Tok: Label 'CP1001', MaxLength = 20;
        Campaign1002Tok: Label 'CP1002', MaxLength = 20;
        Campaign1003Tok: Label 'CP1003', MaxLength = 20;
        IncreaseSaleLbl: Label 'Increase sale', MaxLength = 100;
        EventLbl: Label 'Event', MaxLength = 100;
        WorkingPlaceArrangementLbl: Label 'Working place arrangement', MaxLength = 100;
}