codeunit 5383 "Create Activity"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.InsertActivity(CompanyPresentation(), CompanyPresentationTasksLbl);
        ContosoCRM.InsertActivity(Initial(), InitialTasksLbl);
        ContosoCRM.InsertActivity(UnderstandingNeeds(), UnderstandingNeedsTasksLbl);
        ContosoCRM.InsertActivity(ProductPresentation(), ProductPresentationLbl);
        ContosoCRM.InsertActivity(Proposal(), ProposalTasksLbl);
        ContosoCRM.InsertActivity(PresentationWorkshop(), PresentationWorkshopLbl);
        ContosoCRM.InsertActivity(Qualification(), QualificationTasksLbl);
        ContosoCRM.InsertActivity(SignContract(), SignContractTasksLbl);
        ContosoCRM.InsertActivity(Workshop(), WorkshopTasksLbl);
    end;

    procedure CompanyPresentation(): Code[10]
    begin
        exit(CompanyPresentationTemplateTok);
    end;

    procedure Initial(): Code[10]
    begin
        exit(InitTemplateTok);
    end;

    procedure UnderstandingNeeds(): Code[10]
    begin
        exit(NeedsTemplateTok);
    end;

    procedure ProductPresentation(): Code[10]
    begin
        exit(PPresTemplateTok);
    end;

    procedure Proposal(): Code[10]
    begin
        exit(ProposalTemplateTok);
    end;

    procedure PresentationWorkshop(): Code[10]
    begin
        exit(PWorkTemplateTok);
    end;

    procedure Qualification(): Code[10]
    begin
        exit(QualTok);
    end;

    procedure SignContract(): Code[10]
    begin
        exit(SignTemplateTok);
    end;

    procedure Workshop(): Code[10]
    begin
        exit(WorkshopTemplateTok);
    end;

    var
        CompanyPresentationTemplateTok: Label 'C-PRES', MaxLength = 10;
        InitTemplateTok: Label 'INIT', MaxLength = 10;
        NeedsTemplateTok: Label 'NEEDS', MaxLength = 10;
        PPresTemplateTok: Label 'P-PRES', MaxLength = 10;
        ProposalTemplateTok: Label 'PROPOSAL', MaxLength = 10;
        PWorkTemplateTok: Label 'P-WORK', MaxLength = 10;
        QualTok: Label 'QUAL', MaxLength = 10;
        SignTemplateTok: Label 'SIGN', MaxLength = 10;
        WorkshopTemplateTok: Label 'WORKSHOP', MaxLength = 10;
        CompanyPresentationTasksLbl: Label 'Company Presentation tasks', MaxLength = 100;
        InitialTasksLbl: Label 'Initial tasks', MaxLength = 100;
        UnderstandingNeedsTasksLbl: Label 'Understanding needs tasks', MaxLength = 100;
        ProductPresentationLbl: Label 'Product Presentation', MaxLength = 100;
        ProposalTasksLbl: Label 'Proposal tasks', MaxLength = 100;
        PresentationWorkshopLbl: Label 'Presentation/Workshop', MaxLength = 100;
        QualificationTasksLbl: Label 'Qualification tasks', MaxLength = 100;
        SignContractTasksLbl: Label 'Sign Contract tasks', MaxLength = 100;
        WorkshopTasksLbl: Label 'Workshop tasks', MaxLength = 100;
}