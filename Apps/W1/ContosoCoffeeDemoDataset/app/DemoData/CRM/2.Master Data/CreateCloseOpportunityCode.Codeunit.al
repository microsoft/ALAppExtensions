codeunit 5485 "Create Close Opportunity Code"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CloseOpportunityCode: Record "Close Opportunity Code";
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.InsertCloseOpportunityCode(BusinessL(), InadequateKnowledgeOfCustLbl, CloseOpportunityCode.Type::Lost);
        ContosoCRM.InsertCloseOpportunityCode(BusinessW(), KnowledgeOfCustBusinessLbl, CloseOpportunityCode.Type::Won);
        ContosoCRM.InsertCloseOpportunityCode(ConsultL(), IneffectiveConsultantLbl, CloseOpportunityCode.Type::Lost);
        ContosoCRM.InsertCloseOpportunityCode(ConsultW(), CompetentConsultantLbl, CloseOpportunityCode.Type::Won);
        ContosoCRM.InsertCloseOpportunityCode(CP(), ClosedFromCommercePortalLbl, CloseOpportunityCode.Type::Won);
        ContosoCRM.InsertCloseOpportunityCode(PostpndL(), DealPostponedIndefinitelyLbl, CloseOpportunityCode.Type::Lost);
        ContosoCRM.InsertCloseOpportunityCode(PresL(), IneffectivePresaleWorkLbl, CloseOpportunityCode.Type::Lost);
        ContosoCRM.InsertCloseOpportunityCode(PresW(), StrongPresaleWorkLbl, CloseOpportunityCode.Type::Won);
        ContosoCRM.InsertCloseOpportunityCode(PriceL(), OurProductWasTooExpensiveLbl, CloseOpportunityCode.Type::Lost);
        ContosoCRM.InsertCloseOpportunityCode(PriceW(), BestPriceLbl, CloseOpportunityCode.Type::Won);
        ContosoCRM.InsertCloseOpportunityCode(ProductL(), CustomerChoseAnotherProductLbl, CloseOpportunityCode.Type::Lost);
        ContosoCRM.InsertCloseOpportunityCode(ProductW(), BestProductLbl, CloseOpportunityCode.Type::Won);
        ContosoCRM.InsertCloseOpportunityCode(RelationL(), PoorCustomerRelationsLbl, CloseOpportunityCode.Type::Lost);
        ContosoCRM.InsertCloseOpportunityCode(RelationW(), GoodCustomerRelationsLbl, CloseOpportunityCode.Type::Won);
        ContosoCRM.InsertCloseOpportunityCode(SalesrepL(), AttitudeOfSalespersonLbl, CloseOpportunityCode.Type::Lost);
        ContosoCRM.InsertCloseOpportunityCode(SalesrepW(), CompetentSalespersonLbl, CloseOpportunityCode.Type::Won);
        ContosoCRM.InsertCloseOpportunityCode(TimewstL(), CustNotCommittedToDealLbl, CloseOpportunityCode.Type::Lost);
        ContosoCRM.InsertCloseOpportunityCode(WalkedL(), WeWalkedLbl, CloseOpportunityCode.Type::Lost);
    end;

    procedure BusinessL(): Code[10]
    begin
        exit(BusinessLTok);
    end;

    procedure BusinessW(): Code[10]
    begin
        exit(BusinessWTok);
    end;

    procedure ConsultL(): Code[10]
    begin
        exit(ConsultLTok);
    end;

    procedure ConsultW(): Code[10]
    begin
        exit(ConsultWTok);
    end;

    procedure CP(): Code[10]
    begin
        exit(CPTok);
    end;

    procedure PostpndL(): Code[10]
    begin
        exit(PostpndLTok);
    end;

    procedure PresL(): Code[10]
    begin
        exit(PresLTok);
    end;

    procedure PresW(): Code[10]
    begin
        exit(PresWTok);
    end;

    procedure PriceL(): Code[10]
    begin
        exit(PriceLTok);
    end;

    procedure PriceW(): Code[10]
    begin
        exit(PriceWTok);
    end;

    procedure ProductL(): Code[10]
    begin
        exit(ProductLTok);
    end;

    procedure ProductW(): Code[10]
    begin
        exit(ProductWTok);
    end;

    procedure RelationL(): Code[10]
    begin
        exit(RelationLTok);
    end;

    procedure RelationW(): Code[10]
    begin
        exit(RelationWTok);
    end;

    procedure SalesrepL(): Code[10]
    begin
        exit(SalesrepLTok);
    end;

    procedure SalesrepW(): Code[10]
    begin
        exit(SalesrepWTok);
    end;

    procedure TimewstL(): Code[10]
    begin
        exit(TimewstLTok);
    end;

    procedure WalkedL(): Code[10]
    begin
        exit(WalkedLTok);
    end;

    var
        BusinessLTok: Label 'BUSINESS_L', MaxLength = 10;
        BusinessWTok: Label 'BUSINESS_W', MaxLength = 10;
        ConsultLTok: Label 'CONSULT_L', MaxLength = 10;
        ConsultWTok: Label 'CONSULT_W', MaxLength = 10;
        CpTok: Label 'CP', MaxLength = 10;
        PostpndLTok: Label 'POSTPND_L', MaxLength = 10;
        PresLTok: Label 'PRES_L', MaxLength = 10;
        PresWTok: Label 'PRES_W', MaxLength = 10;
        PriceLTok: Label 'PRICE_L', MaxLength = 10;
        PriceWTok: Label 'PRICE_W', MaxLength = 10;
        ProductLTok: Label 'PRODUCT_L', MaxLength = 10;
        ProductWTok: Label 'PRODUCT_W', MaxLength = 10;
        RelationLTok: Label 'RELATION_L', MaxLength = 10;
        RelationWTok: Label 'RELATION_W', MaxLength = 10;
        SalesrepLTok: Label 'SALESREP_L', MaxLength = 10;
        SalesrepWTok: Label 'SALESREP_W', MaxLength = 10;
        TimewstLTok: Label 'TIMEWST_L', MaxLength = 10;
        WalkedLTok: Label 'WALKED_L', MaxLength = 10;
        InadequateKnowledgeOfCustLbl: Label 'Inadequate knowledge of cust', MaxLength = 100;
        KnowledgeOfCustBusinessLbl: Label 'Knowledge of cust. business', MaxLength = 100;
        IneffectiveConsultantLbl: Label 'Ineffective consultant', MaxLength = 100;
        CompetentConsultantLbl: Label 'Competent consultant', MaxLength = 100;
        ClosedFromCommercePortalLbl: Label 'Closed from Commerce Portal', MaxLength = 100;
        DealPostponedIndefinitelyLbl: Label 'Deal postponed indefinitely', MaxLength = 100;
        IneffectivePresaleWorkLbl: Label 'Ineffective presale work', MaxLength = 100;
        StrongPresaleWorkLbl: Label 'Strong presale work', MaxLength = 100;
        OurProductWasTooExpensiveLbl: Label 'Our product was too expensive', MaxLength = 100;
        BestPriceLbl: Label 'Best price', MaxLength = 100;
        CustomerChoseAnotherProductLbl: Label 'Customer chose another product', MaxLength = 100;
        BestProductLbl: Label 'Best product', MaxLength = 100;
        PoorCustomerRelationsLbl: Label 'Poor customer relations', MaxLength = 100;
        GoodCustomerRelationsLbl: Label 'Good customer relations', MaxLength = 100;
        AttitudeOfSalespersonLbl: Label 'Attitude of salesperson', MaxLength = 100;
        CompetentSalespersonLbl: Label 'Competent salesperson', MaxLength = 100;
        CustNotCommittedToDealLbl: Label 'Cust. not committed to deal', MaxLength = 100;
        WeWalkedLbl: Label 'We walked', MaxLength = 100;
}