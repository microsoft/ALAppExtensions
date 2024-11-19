codeunit 5677 "Create Sales Cycle Stage"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
        CreateSalesCycle: Codeunit "Create Sales Cycle";
        CreateActivity: Codeunit "Create Activity";
    begin
        ContosoCRM.InsertSalesCycleStage(CreateSalesCycle.ExistingSalesCycle(), 1, InitialLbl, 2, CreateActivity.Initial(), false, true, 10);
        ContosoCRM.InsertSalesCycleStage(CreateSalesCycle.ExistingSalesCycle(), 2, PresentationLbl, 50, CreateActivity.PresentationWorkshop(), false, true, 40);
        ContosoCRM.InsertSalesCycleStage(CreateSalesCycle.ExistingSalesCycle(), 3, ProposalLbl, 80, CreateActivity.Proposal(), true, false, 80);
        ContosoCRM.InsertSalesCycleStage(CreateSalesCycle.ExistingSalesCycle(), 4, SignContractLbl, 95, CreateActivity.SignContract(), true, false, 100);

        ContosoCRM.InsertSalesCycleStage(CreateSalesCycle.NewSalesCycle(), 1, InitialLbl, 2, CreateActivity.Initial(), false, false, 10);
        ContosoCRM.InsertSalesCycleStage(CreateSalesCycle.NewSalesCycle(), 2, QualificationLbl, 5, CreateActivity.Qualification(), false, false, 20);
        ContosoCRM.InsertSalesCycleStage(CreateSalesCycle.NewSalesCycle(), 3, PresentationLbl, 40, CreateActivity.PresentationWorkshop(), true, true, 50);
        ContosoCRM.InsertSalesCycleStage(CreateSalesCycle.NewSalesCycle(), 4, ProposalLbl, 60, CreateActivity.Proposal(), true, false, 75);
        ContosoCRM.InsertSalesCycleStage(CreateSalesCycle.NewSalesCycle(), 5, SignContractLbl, 95, CreateActivity.SignContract(), true, false, 100);
    end;

    var
        InitialLbl: Label 'Initial', MaxLength = 100;
        PresentationLbl: Label 'Presentation', MaxLength = 100;
        ProposalLbl: Label 'Proposal', MaxLength = 100;
        SignContractLbl: Label 'Sign Contract', MaxLength = 100;
        QualificationLbl: Label 'Qualification', MaxLength = 100;

}