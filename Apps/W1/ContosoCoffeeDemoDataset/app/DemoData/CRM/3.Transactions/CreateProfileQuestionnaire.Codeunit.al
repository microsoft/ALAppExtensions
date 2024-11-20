codeunit 5681 "Create Profile Questionnaire"
{
    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
        CreateBusinessRelation: Codeunit "Create Business Relation";
    begin
        ContosoCRM.InsertProfileQuestionnaireHeader(Company(), GeneralCompanyInformationLbl, Enum::"Profile Questionnaire Contact Type"::Companies, '');
        ContosoCRM.InsertProfileQuestionnaireHeader(Customer(), CustomerInformationLbl, Enum::"Profile Questionnaire Contact Type"::Companies, CreateBusinessRelation.CustBusinessRelation());
        ContosoCRM.InsertProfileQuestionnaireHeader(Person(), GeneralPersonalInformationLbl, Enum::"Profile Questionnaire Contact Type"::People, '');

        ContosoCRM.InsertProfileQuestionnaireLine(Company(), 10000, Enum::"Profile Questionnaire Line Type"::Question, NoOfEmployeesLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Company(), 20000, Enum::"Profile Questionnaire Line Type"::Answer, '1..99', false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Company(), 30000, Enum::"Profile Questionnaire Line Type"::Answer, '100..499', false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Company(), 40000, Enum::"Profile Questionnaire Line Type"::Answer, '500..999', false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Company(), 50000, Enum::"Profile Questionnaire Line Type"::Answer, '1000+', false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Company(), 60000, Enum::"Profile Questionnaire Line Type"::Question, CompanyOwnershipLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Company(), 70000, Enum::"Profile Questionnaire Line Type"::Answer, StockExchangeLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Company(), 80000, Enum::"Profile Questionnaire Line Type"::Answer, FamilyLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Company(), 90000, Enum::"Profile Questionnaire Line Type"::Answer, FoundationLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Company(), 100000, Enum::"Profile Questionnaire Line Type"::Answer, GovernmentLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Company(), 110000, Enum::"Profile Questionnaire Line Type"::Answer, InstitutionLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Company(), 120000, Enum::"Profile Questionnaire Line Type"::Question, AdditionalBusinessRelationsLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Company(), 130000, Enum::"Profile Questionnaire Line Type"::Answer, PartnerLbl, false, Enum::"Profile Answer Priority"::High, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Company(), 140000, Enum::"Profile Questionnaire Line Type"::Answer, CompetitorLbl, false, Enum::"Profile Answer Priority"::"Very High", false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 10000, Enum::"Profile Questionnaire Line Type"::Question, ProfitLCYlastyearLbl, false, Enum::"Profile Answer Priority"::Normal, true, Enum::"Profile Quest. Cust. Class. Field"::"Profit (LCY)", '<CY-2Y+1D>', '<CY-1Y>', 3, 1, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 20000, Enum::"Profile Questionnaire Line Type"::Answer, TopOfCustomersLbl, false, Enum::"Profile Answer Priority"::"Very Low (Hidden)", false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 25);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 25000, Enum::"Profile Questionnaire Line Type"::Answer, MiddleOfCustomersLbl, false, Enum::"Profile Answer Priority"::"Very Low (Hidden)", false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 26, 75);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 30000, Enum::"Profile Questionnaire Line Type"::Answer, BottomCustomersLbl, false, Enum::"Profile Answer Priority"::"Very Low (Hidden)", false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 76, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 40000, Enum::"Profile Questionnaire Line Type"::Question, ProfitLCYCurrentYearLbl, false, Enum::"Profile Answer Priority"::Normal, true, Enum::"Profile Quest. Cust. Class. Field"::"Profit (LCY)", '<CY-1Y+1D>', '<CD>', 3, 1, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 50000, Enum::"Profile Questionnaire Line Type"::Answer, TopOfCustomersLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 25);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 55000, Enum::"Profile Questionnaire Line Type"::Answer, MiddleOfCustomersLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 26, 75);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 60000, Enum::"Profile Questionnaire Line Type"::Answer, BottomCustomersLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 76, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 70000, Enum::"Profile Questionnaire Line Type"::Question, DiscountLastYearLbl, false, Enum::"Profile Answer Priority"::Normal, true, Enum::"Profile Quest. Cust. Class. Field"::"Discount (%)", '<CY-2Y+1D>', '<CY-1Y>', 1, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 80000, Enum::"Profile Questionnaire Line Type"::Answer, HighDiscountUsageLbl, false, Enum::"Profile Answer Priority"::High, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 5, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 85000, Enum::"Profile Questionnaire Line Type"::Answer, MediumDiscountUsageLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 2, 4);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 90000, Enum::"Profile Questionnaire Line Type"::Answer, LowDiscountUsageLbl, false, Enum::"Profile Answer Priority"::"Very High", false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 1);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 100000, Enum::"Profile Questionnaire Line Type"::Question, DiscountCurrentYearLbl, false, Enum::"Profile Answer Priority"::Normal, true, Enum::"Profile Quest. Cust. Class. Field"::"Discount (%)", '<CY-1Y+1D>', '<CD>', 1, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 110000, Enum::"Profile Questionnaire Line Type"::Answer, HighDiscountUsageLbl, false, Enum::"Profile Answer Priority"::High, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 5, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 115000, Enum::"Profile Questionnaire Line Type"::Answer, MediumDiscountUsageLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 2, 4);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 120000, Enum::"Profile Questionnaire Line Type"::Answer, LowDiscountUsageLbl, false, Enum::"Profile Answer Priority"::"Very High", false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 1);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 130000, Enum::"Profile Questionnaire Line Type"::Question, TurnoverLCYCurrentYearLbl, false, Enum::"Profile Answer Priority"::Normal, true, Enum::"Profile Quest. Cust. Class. Field"::"Sales (LCY)", '<CY-1Y+1D>', '<CD>', 1, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 140000, Enum::"Profile Questionnaire Line Type"::Answer, HighOverLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 4001, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 150000, Enum::"Profile Questionnaire Line Type"::Answer, MediumLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 1000, 4000);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 160000, Enum::"Profile Questionnaire Line Type"::Answer, LowBelowLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 999);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 170000, Enum::"Profile Questionnaire Line Type"::Question, TurnoverLCYLastYearLbl, false, Enum::"Profile Answer Priority"::Normal, true, Enum::"Profile Quest. Cust. Class. Field"::"Sales (LCY)", '<CY-2Y+1D>', '<CY-1Y>', 1, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 180000, Enum::"Profile Questionnaire Line Type"::Answer, HighOverLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 4001, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 190000, Enum::"Profile Questionnaire Line Type"::Answer, MediumLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 1000, 4000);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 200000, Enum::"Profile Questionnaire Line Type"::Answer, LowBelowLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 999);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 210000, Enum::"Profile Questionnaire Line Type"::Question, CustomerPurchaseFrequencyCurrentYearLbl, false, Enum::"Profile Answer Priority"::Normal, true, Enum::"Profile Quest. Cust. Class. Field"::"Sales Frequency (Invoices/Year)", '<CY-1Y+1D>', '<CD>', 1, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 220000, Enum::"Profile Questionnaire Line Type"::Answer, GreaterThanTimesAYearLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 6, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 230000, Enum::"Profile Questionnaire Line Type"::Answer, BetweenTimesAYearLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 3, 5);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 240000, Enum::"Profile Questionnaire Line Type"::Answer, LessThanTimesAYearLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 2);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 250000, Enum::"Profile Questionnaire Line Type"::Question, CustomerPurchaseFrequencyLastYearLbl, false, Enum::"Profile Answer Priority"::Normal, true, Enum::"Profile Quest. Cust. Class. Field"::"Sales Frequency (Invoices/Year)", '<CY-2Y+1D>', '<CY-1Y>', 1, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 260000, Enum::"Profile Questionnaire Line Type"::Answer, GreaterThanTimesAYearLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 6, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 270000, Enum::"Profile Questionnaire Line Type"::Answer, BetweenTimesAYearLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 3, 5);
        ContosoCRM.InsertProfileQuestionnaireLine(Customer(), 280000, Enum::"Profile Questionnaire Line Type"::Answer, LessThanTimesAYearLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 2);

        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 10000, Enum::"Profile Questionnaire Line Type"::Question, SexLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 20000, Enum::"Profile Questionnaire Line Type"::Answer, MaleLbl, false, Enum::"Profile Answer Priority"::Low, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 30000, Enum::"Profile Questionnaire Line Type"::Answer, FemaleLbl, false, Enum::"Profile Answer Priority"::Low, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 40000, Enum::"Profile Questionnaire Line Type"::Question, HobbiesLbl, true, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 50000, Enum::"Profile Questionnaire Line Type"::Answer, FootballLbl, false, Enum::"Profile Answer Priority"::Low, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 60000, Enum::"Profile Questionnaire Line Type"::Answer, GolfLbl, false, Enum::"Profile Answer Priority"::Low, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 70000, Enum::"Profile Questionnaire Line Type"::Answer, TennisLbl, false, Enum::"Profile Answer Priority"::Low, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 80000, Enum::"Profile Questionnaire Line Type"::Answer, HuntingLbl, false, Enum::"Profile Answer Priority"::Low, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 90000, Enum::"Profile Questionnaire Line Type"::Answer, OtherOutdoorLbl, false, Enum::"Profile Answer Priority"::Low, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 100000, Enum::"Profile Questionnaire Line Type"::Answer, TheaterLbl, false, Enum::"Profile Answer Priority"::Low, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 110000, Enum::"Profile Questionnaire Line Type"::Answer, LiteratureLbl, false, Enum::"Profile Answer Priority"::Low, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 120000, Enum::"Profile Questionnaire Line Type"::Answer, DesignLbl, false, Enum::"Profile Answer Priority"::Low, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 130000, Enum::"Profile Questionnaire Line Type"::Question, MaritalStatusLbl, true, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 140000, Enum::"Profile Questionnaire Line Type"::Answer, MarriedLbl, false, Enum::"Profile Answer Priority"::Low, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 150000, Enum::"Profile Questionnaire Line Type"::Answer, ChildrenLbl, false, Enum::"Profile Answer Priority"::Low, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 160000, Enum::"Profile Questionnaire Line Type"::Question, EducationalLevelLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 170000, Enum::"Profile Questionnaire Line Type"::Answer, MasterPhdLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 180000, Enum::"Profile Questionnaire Line Type"::Answer, BachelorLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 190000, Enum::"Profile Questionnaire Line Type"::Answer, SkilledLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 200000, Enum::"Profile Questionnaire Line Type"::Question, PersonalityLbl, true, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 210000, Enum::"Profile Questionnaire Line Type"::Answer, ExtrovertLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
        ContosoCRM.InsertProfileQuestionnaireLine(Person(), 220000, Enum::"Profile Questionnaire Line Type"::Answer, AnalyticalLbl, false, Enum::"Profile Answer Priority"::Normal, false, Enum::"Profile Quest. Cust. Class. Field"::" ", '', '', 0, 0, 0, 0);
    end;

    procedure Company(): Code[20]
    begin
        exit(CompanyTok);
    end;

    procedure Customer(): Code[20]
    begin
        exit(CustomerTok);
    end;

    procedure Person(): Code[20]
    begin
        exit(PersonTok);
    end;


    var
        CompanyTok: Label 'COMPANY', MaxLength = 20;
        GeneralCompanyInformationLbl: Label 'General company information', MaxLength = 250;
        CustomerTok: Label 'CUSTOMER', MaxLength = 20;
        CustomerInformationLbl: Label 'Customer information', MaxLength = 250;
        PersonTok: Label 'PERSON', MaxLength = 20;
        GeneralPersonalInformationLbl: Label 'General personal information', MaxLength = 250;
        NoOfEmployeesLbl: Label 'No. of employees', MaxLength = 250;
        CompanyOwnershipLbl: Label 'Company Ownership', MaxLength = 250;
        StockExchangeLbl: Label 'Stock Exchange', MaxLength = 250;
        FamilyLbl: Label 'Family', MaxLength = 250;
        FoundationLbl: Label 'Foundation', MaxLength = 250;
        GovernmentLbl: Label 'Government', MaxLength = 250;
        InstitutionLbl: Label 'Institution', MaxLength = 250;
        AdditionalBusinessRelationsLbl: Label 'Additional Business Relations', MaxLength = 250;
        PartnerLbl: Label 'Partner', MaxLength = 250;
        CompetitorLbl: Label 'Competitor', MaxLength = 250;
        ProfitLCYlastyearLbl: Label 'Profit (LCY) last year', MaxLength = 250;
        TopOfCustomersLbl: Label 'Top 25 % of Customers', MaxLength = 250;
        MiddleOfCustomersLbl: Label 'Middle 50 % of Customers', MaxLength = 250;
        BottomCustomersLbl: Label 'Bottom 25 % Customers', MaxLength = 250;
        ProfitLCYCurrentYearLbl: Label 'Profit (LCY) Current Year', MaxLength = 250;
        DiscountLastYearLbl: Label 'Discount (%) Last Year', MaxLength = 250;
        HighDiscountUsageLbl: Label 'High discount usage', MaxLength = 250;
        MediumDiscountUsageLbl: Label 'Medium discount usage', MaxLength = 250;
        LowDiscountUsageLbl: Label 'Low discount usage', MaxLength = 250;
        DiscountCurrentYearLbl: Label 'Discount (%) Current Year', MaxLength = 250;
        TurnoverLCYCurrentYearLbl: Label 'Turnover (LCY), Current Year', MaxLength = 250;
        HighOverLbl: Label 'High (over 4,000)', MaxLength = 250;
        MediumLbl: Label 'Medium (1,000 - 4,000)', MaxLength = 250;
        LowBelowLbl: Label 'low (below 1,000)', MaxLength = 250;
        TurnoverLCYLastYearLbl: Label 'Turnover (LCY), Last Year', MaxLength = 250;
        CustomerPurchaseFrequencyCurrentYearLbl: Label 'Customer Purchase Frequency, Current Year', MaxLength = 250;
        GreaterThanTimesAYearLbl: Label '> 5 times a year', MaxLength = 250;
        BetweenTimesAYearLbl: Label '3-5 times a year', MaxLength = 250;
        LessThanTimesAYearLbl: Label '< 3 times a year', MaxLength = 250;
        CustomerPurchaseFrequencyLastYearLbl: Label 'Customer Purchase Frequency, Last Year', MaxLength = 250;
        SexLbl: Label 'Sex', MaxLength = 250;
        MaleLbl: Label 'Male', MaxLength = 250;
        FemaleLbl: Label 'Female', MaxLength = 250;
        HobbiesLbl: Label 'Hobbies', MaxLength = 250;
        FootballLbl: Label 'Football', MaxLength = 250;
        GolfLbl: Label 'Golf', MaxLength = 250;
        TennisLbl: Label 'Tennis', MaxLength = 250;
        HuntingLbl: Label 'Hunting', MaxLength = 250;
        OtherOutdoorLbl: Label 'Other outdoor', MaxLength = 250;
        TheaterLbl: Label 'Theater', MaxLength = 250;
        LiteratureLbl: Label 'Literature', MaxLength = 250;
        DesignLbl: Label 'Design', MaxLength = 250;
        MaritalStatusLbl: Label 'Marital Status', MaxLength = 250;
        MarriedLbl: Label 'Married', MaxLength = 250;
        ChildrenLbl: Label 'Children', MaxLength = 250;
        EducationalLevelLbl: Label 'Educational level', MaxLength = 250;
        MasterPhdLbl: Label 'Master/ Ph.d', MaxLength = 250;
        BachelorLbl: Label 'Bachelor', MaxLength = 250;
        SkilledLbl: Label 'Skilled', MaxLength = 250;
        PersonalityLbl: Label 'Personality', MaxLength = 250;
        ExtrovertLbl: Label 'Extrovert', MaxLength = 250;
        AnalyticalLbl: Label 'Analytical', MaxLength = 250;
}