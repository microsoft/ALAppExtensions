/// <summary>
/// Provides utility functions for creating and managing marketing-related entities in test scenarios, including contacts, campaigns, and segments.
/// </summary>
codeunit 131900 "Library - Marketing"
{

    trigger OnRun()
    begin
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";

    procedure CreateActivity(var Activity: Record Activity)
    begin
        Activity.Init();
        Activity.Validate(Code, LibraryUtility.GenerateRandomCode(Activity.FieldNo(Code), DATABASE::Activity));
        Activity.Validate(Description, Activity.Code);  // Validating Code as Description because value is not important.
        Activity.Insert(true);
    end;

    procedure CreateActivityStep(var ActivityStep: Record "Activity Step"; ActivityCode: Code[10])
    var
        RecRef: RecordRef;
    begin
        ActivityStep.Init();
        ActivityStep.Validate("Activity Code", ActivityCode);
        RecRef.GetTable(ActivityStep);
        ActivityStep.Validate("Step No.", LibraryUtility.GetNewLineNo(RecRef, ActivityStep.FieldNo("Step No.")));
        ActivityStep.Insert(true);
    end;

    procedure CreateAttachment(var Attachment: Record Attachment)
    var
        No: Integer;
    begin
        Clear(Attachment);

        if Attachment.FindLast() then
            No := Attachment."No." + 1;

        Attachment.Init();
        Attachment."No." := No;
        Attachment.Insert(true);
    end;

    procedure CreateBusinessRelation(var BusinessRelation: Record "Business Relation")
    begin
        BusinessRelation.Init();
        BusinessRelation.Validate(Code, LibraryUtility.GenerateRandomCode(BusinessRelation.FieldNo(Code), DATABASE::"Business Relation"));
        BusinessRelation.Validate(Description, BusinessRelation.Code);  // Validating Code as Description because value is not important.
        BusinessRelation.Insert(true);
    end;

    procedure CreateCampaign(var Campaign: Record Campaign)
    var
        MarketingSetup: Record "Marketing Setup";
    begin
        MarketingSetup.Get();
        if MarketingSetup."Campaign Nos." = '' then begin
            MarketingSetup.Validate("Campaign Nos.", LibraryUtility.GetGlobalNoSeriesCode());
            MarketingSetup.Modify(true);
        end;

        Clear(Campaign);
        Campaign.Init();
        Campaign.Insert(true);
        Campaign.Validate(Description, Campaign."No.");  // Validating No. as Description because value is not important.
        Campaign.Modify(true);
    end;

    procedure CreateCampaignStatus(var CampaignStatus: Record "Campaign Status")
    begin
        CampaignStatus.Init();
        CampaignStatus.Validate(Code, LibraryUtility.GenerateRandomCode(CampaignStatus.FieldNo(Code), DATABASE::"Campaign Status"));
        CampaignStatus.Validate(Description, CampaignStatus.Code);  // Validating Code as Description because value is not important.
        CampaignStatus.Insert(true);
    end;

    procedure CreateCloseOpportunityCode(var CloseOpportunityCode: Record "Close Opportunity Code")
    begin
        CloseOpportunityCode.Init();
        CloseOpportunityCode.Validate(
          Code, LibraryUtility.GenerateRandomCode(CloseOpportunityCode.FieldNo(Code), DATABASE::"Close Opportunity Code"));
        // Validating Code as Description because value is not important.
        CloseOpportunityCode.Validate(Description, CloseOpportunityCode.Code);
        CloseOpportunityCode.Insert(true);
    end;

    procedure CreateCompanyContact(var Contact: Record Contact)
    begin
        CreateContact(Contact, Contact.Type::Company);
    end;

    procedure CreateCompanyContactNo(): Code[20]
    var
        Contact: Record Contact;
    begin
        CreateCompanyContact(Contact);
        exit(Contact."No.");
    end;

    procedure CreateCompanyContactTask(var Task: Record "To-do"; TaskType: Option)
    var
        Salesperson: Record "Salesperson/Purchaser";
    begin
        LibrarySales.CreateSalesperson(Salesperson);
        Task.Init();
        Task.Validate(Description, Salesperson.Code);
        Task.Validate(Type, TaskType);
        Task.Validate("Contact No.", CreateCompanyContactNo());
        Task.Validate("Salesperson Code", Salesperson.Code);
        Task.Validate(Date, WorkDate());
        Task.Validate("Start Time", Time);
        Task.Validate(Duration, LibraryRandom.RandIntInRange(60000, 60000000));
        Task.Insert(true);
    end;

    procedure CreatePersonContact(var Contact: Record Contact)
    begin
        CreateContact(Contact, Contact.Type::Person);
    end;

    procedure CreatePersonContactNo(): Code[20]
    var
        Contact: Record Contact;
    begin
        CreatePersonContact(Contact);
        exit(Contact."No.");
    end;

    [Scope('OnPrem')]
    procedure CreatePersonContactWithCompanyNo(var Contact: Record Contact)
    begin
        CreatePersonContact(Contact);
        Contact.Validate("Company No.", CreateCompanyContactNo());
        Contact.Modify(true);
    end;

    local procedure CreateContact(var Contact: Record Contact; Type: Enum "Contact Type")
    var
        MarketingSetup: Record "Marketing Setup";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        MarketingSetup.Get();
        if MarketingSetup."Contact Nos." = '' then begin
            MarketingSetup.Validate("Contact Nos.", LibraryUtility.GetGlobalNoSeriesCode());
            MarketingSetup.Modify(true);
        end;

        SalespersonPurchaser.FindFirst();
        Contact.Init();
        Contact.Insert(true);
        Contact.Validate(Name, Contact."No.");  // Validating Name as No. because value is not important.
        Contact.Validate("Salesperson Code", SalespersonPurchaser.Code);
        Contact.Validate(Type, Type);
        Contact.TypeChange();
        Contact.Modify(true);
    end;

    procedure CreateContactAltAddress(var ContactAltAddress: Record "Contact Alt. Address"; ContactNo: Code[20])
    begin
        ContactAltAddress.Init();
        ContactAltAddress.Validate("Contact No.", ContactNo);
        ContactAltAddress.Validate(
          Code, LibraryUtility.GenerateRandomCode(ContactAltAddress.FieldNo(Code), DATABASE::"Contact Alt. Address"));
        ContactAltAddress.Insert(true);
    end;

    procedure CreateContactAltAddrDateRange(var ContactAltAddrDateRange: Record "Contact Alt. Addr. Date Range"; ContactNo: Code[20]; StartingDate: Date)
    begin
        ContactAltAddrDateRange.Init();
        ContactAltAddrDateRange.Validate("Contact No.", ContactNo);
        ContactAltAddrDateRange.Validate("Starting Date", StartingDate);
        ContactAltAddrDateRange.Insert(true);
    end;

    procedure CreateContactBusinessRelation(var ContactBusinessRelation: Record "Contact Business Relation"; ContactNo: Code[20]; BusinessRelationCode: Code[10])
    begin
        ContactBusinessRelation.Init();
        ContactBusinessRelation.Validate("Contact No.", ContactNo);
        ContactBusinessRelation.Validate("Business Relation Code", BusinessRelationCode);
        ContactBusinessRelation.Insert(true);
    end;

    procedure CreateContactIndustryGroup(var ContactIndustryGroup: Record "Contact Industry Group"; ContactNo: Code[20]; IndustryGroupCode: Code[10])
    begin
        ContactIndustryGroup.Init();
        ContactIndustryGroup.Validate("Contact No.", ContactNo);
        ContactIndustryGroup.Validate("Industry Group Code", IndustryGroupCode);
        ContactIndustryGroup.Insert(true);
    end;

    procedure CreateContactJobResponsibility(var ContactJobResponsibility: Record "Contact Job Responsibility"; ContactNo: Code[20]; JobResponsibilityCode: Code[10])
    begin
        ContactJobResponsibility.Init();
        ContactJobResponsibility.Validate("Contact No.", ContactNo);
        ContactJobResponsibility.Validate("Job Responsibility Code", JobResponsibilityCode);
        ContactJobResponsibility.Insert(true);
    end;

    procedure CreateContactMailingGroup(var ContactMailingGroup: Record "Contact Mailing Group"; ContactNo: Code[20]; MailingGroupCode: Code[10])
    begin
        ContactMailingGroup.Init();
        ContactMailingGroup.Validate("Contact No.", ContactNo);
        ContactMailingGroup.Validate("Mailing Group Code", MailingGroupCode);
        ContactMailingGroup.Insert(true);
    end;

    procedure CreateContactWebSource(var ContactWebSource: Record "Contact Web Source"; ContactNo: Code[20]; WebSourceCode: Code[10])
    begin
        ContactWebSource.Init();
        ContactWebSource.Validate("Contact No.", ContactNo);
        ContactWebSource.Validate("Web Source Code", WebSourceCode);
        ContactWebSource.Insert(true);
    end;

    procedure CreateBusinessRelationWithContact(var ContactBusinessRelation: Record "Contact Business Relation"; ContactNo: Code[20])
    var
        BusinessRelation: Record "Business Relation";
    begin
        CreateBusinessRelation(BusinessRelation);
        CreateContactBusinessRelation(ContactBusinessRelation, ContactNo, BusinessRelation.Code);
        ContactBusinessRelation."Link to Table" := ContactBusinessRelation."Link to Table"::Customer;
        ContactBusinessRelation."No." := LibrarySales.CreateCustomerNo();
        ContactBusinessRelation.Modify(true);
    end;

    procedure CreateBusinessRelationBetweenContactAndCustomer(var ContactBusinessRelation: Record "Contact Business Relation"; ContactNo: Code[20]; CustomerNo: Code[20])
    var
        BusinessRelation: Record "Business Relation";
    begin
        CreateBusinessRelation(BusinessRelation);
        CreateContactBusinessRelation(ContactBusinessRelation, ContactNo, BusinessRelation.Code);
        ContactBusinessRelation."Link to Table" := ContactBusinessRelation."Link to Table"::Customer;
        ContactBusinessRelation."No." := CustomerNo;
        ContactBusinessRelation.Modify(true);
    end;

    procedure CreateBusinessRelationBetweenContactAndVendor(var ContactBusinessRelation: Record "Contact Business Relation"; ContactNo: Code[20]; VendorNo: Code[20])
    var
        BusinessRelation: Record "Business Relation";
    begin
        CreateBusinessRelation(BusinessRelation);
        CreateContactBusinessRelation(ContactBusinessRelation, ContactNo, BusinessRelation.Code);
        ContactBusinessRelation."Link to Table" := ContactBusinessRelation."Link to Table"::Vendor;
        ContactBusinessRelation."No." := VendorNo;
        ContactBusinessRelation.Modify(true);
    end;

    procedure CreateContactWithCustomer(var Contact: Record Contact; var Customer: Record Customer)
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        CreateCompanyContact(Contact);
        LibrarySales.CreateCustomer(Customer);
        CreateBusinessRelationBetweenContactAndCustomer(ContactBusinessRelation, Contact."No.", Customer."No.");
    end;

    procedure CreateContactWithVendor(var Contact: Record Contact; var Vendor: Record Vendor)
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        CreateCompanyContact(Contact);
        LibraryPurchase.CreateVendor(Vendor);
        CreateBusinessRelationBetweenContactAndVendor(ContactBusinessRelation, Contact."No.", Vendor."No.");
    end;

    procedure CreateInteractionGroup(var InteractionGroup: Record "Interaction Group")
    begin
        InteractionGroup.Init();
        InteractionGroup.Validate(Code, LibraryUtility.GenerateRandomCode(InteractionGroup.FieldNo(Code), DATABASE::"Interaction Group"));
        InteractionGroup.Validate(Description, InteractionGroup.Code);  // Validating Code as Description because value is not important.
        InteractionGroup.Insert(true);
    end;

    procedure CreateInteractionLogEntry(var InteractionLogEntry: Record "Interaction Log Entry"; DocumentType: Enum "Interaction Log Entry Document Type"; DocumentNo: Code[20])
    var
        NextInteractLogEntryNo: Integer;
    begin
        NextInteractLogEntryNo := 1;
        if InteractionLogEntry.FindLast() then
            NextInteractLogEntryNo := InteractionLogEntry."Entry No." + 1;

        InteractionLogEntry.Init();
        InteractionLogEntry."Entry No." := NextInteractLogEntryNo;
        InteractionLogEntry.Insert();
        InteractionLogEntry."Document Type" := DocumentType;
        InteractionLogEntry."Document No." := DocumentNo;
        InteractionLogEntry."Version No." := 1;
        InteractionLogEntry.Canceled := true;
        InteractionLogEntry.Modify();
    end;

    procedure CreateInteractionTemplate(var InteractionTemplate: Record "Interaction Template")
    var
        InteractionGroup: Record "Interaction Group";
    begin
        InteractionGroup.FindFirst();
        InteractionTemplate.Init();
        InteractionTemplate.Validate(
          Code, LibraryUtility.GenerateRandomCode(InteractionTemplate.FieldNo(Code), DATABASE::"Interaction Template"));
        InteractionTemplate.Validate("Interaction Group Code", InteractionGroup.Code);
        // Validating Code as Description because value is not important.
        InteractionTemplate.Validate(Description, InteractionTemplate.Code + InteractionTemplate."Interaction Group Code");
        InteractionTemplate.Validate("Correspondence Type (Default)", "Correspondence Type"::" ");
        InteractionTemplate.Insert(true);
    end;

    procedure CreateJobResponsibility(var JobResponsibility: Record "Job Responsibility")
    begin
        JobResponsibility.Init();
        JobResponsibility.Validate(
          Code, LibraryUtility.GenerateRandomCode(JobResponsibility.FieldNo(Code), DATABASE::"Job Responsibility"));
        JobResponsibility.Validate(Description, JobResponsibility.Code);  // Validating Code as Description because value is not important.
        JobResponsibility.Insert(true);
    end;

    procedure CreateMailingGroup(var MailingGroup: Record "Mailing Group")
    begin
        MailingGroup.Init();
        MailingGroup.Validate(Code, LibraryUtility.GenerateRandomCode(MailingGroup.FieldNo(Code), DATABASE::"Mailing Group"));
        MailingGroup.Validate(Description, MailingGroup.Code);  // Validating Code as Description because value is not important.
        MailingGroup.Insert(true);
    end;

    procedure CreateOpportunity(var Opportunity: Record Opportunity; ContactNo: Code[20])
    var
        Contact: Record Contact;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SalesCycle: Record "Sales Cycle";
    begin
        Opportunity.Init();
        Opportunity."No." := LibraryUtility.GenerateGUID();
        Opportunity.Validate("Contact No.", ContactNo);
        Contact.Get(ContactNo);
        if Contact."Salesperson Code" <> '' then
            SalespersonPurchaser.Code := Contact."Salesperson Code"
        else
            SalespersonPurchaser.FindFirst();
        Opportunity.Validate("Salesperson Code", SalespersonPurchaser.Code);
        Opportunity.Validate(Description, Opportunity."No." + Opportunity."Contact No.");
        // Validating No. as Description because value is not important.
        SalesCycle.FindFirst();
        Opportunity.Validate("Sales Cycle Code", SalesCycle.Code);
        Opportunity.Insert(true);
    end;

    procedure CreateQuestionnaireHeader(var ProfileQuestionnaireHeader: Record "Profile Questionnaire Header")
    begin
        ProfileQuestionnaireHeader.Init();
        ProfileQuestionnaireHeader.Validate(
          Code, LibraryUtility.GenerateRandomCode(ProfileQuestionnaireHeader.FieldNo(Code), DATABASE::"Profile Questionnaire Header"));

        // Validating Code as Description because value is not important.
        ProfileQuestionnaireHeader.Validate(Description, ProfileQuestionnaireHeader.Code);
        ProfileQuestionnaireHeader.Insert(true);
    end;

    procedure CreateProfileQuestionnaireLine(var ProfileQuestionnaireLine: Record "Profile Questionnaire Line"; ProfileQuestionnaireCode: Code[20])
    var
        RecRef: RecordRef;
    begin
        ProfileQuestionnaireLine.Init();
        ProfileQuestionnaireLine.Validate("Profile Questionnaire Code", ProfileQuestionnaireCode);
        RecRef.GetTable(ProfileQuestionnaireLine);
        // Use the function GetLastLineNo to get the value of the Line No. field.
        ProfileQuestionnaireLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, ProfileQuestionnaireLine.FieldNo("Line No.")));
        ProfileQuestionnaireLine.Insert(true);
    end;

    procedure CreateContactProfileAnswer(ContactNo: Code[20]; ProfileQuestionnaireCode: Code[20]; LineNo: Integer; NewProfileQuestionnaireValue: Text)
    var
        ContactProfileAnswer: Record "Contact Profile Answer";
    begin
        ContactProfileAnswer.Init();
        ContactProfileAnswer.Validate("Contact No.", ContactNo);
        ContactProfileAnswer.Validate("Profile Questionnaire Code", ProfileQuestionnaireCode);
        ContactProfileAnswer.Validate("Line No.", LineNo);
        ContactProfileAnswer.Validate("Profile Questionnaire Value", CopyStr(NewProfileQuestionnaireValue, 1, MaxStrLen(ContactProfileAnswer."Profile Questionnaire Value")));
        ContactProfileAnswer.Insert(true);
    end;

    procedure CreateRlshpMgtCommentLine(var RlshpMgtCommentLine: Record "Rlshp. Mgt. Comment Line"; TableName: Enum "Rlshp. Mgt. Comment Line Table Name"; No: Code[20]; SubNo: Integer)
    var
        RecRef: RecordRef;
    begin
        RlshpMgtCommentLine.Init();
        RlshpMgtCommentLine.Validate("Table Name", TableName);
        RlshpMgtCommentLine.Validate("No.", No);
        RlshpMgtCommentLine.Validate("Sub No.", SubNo);
        RecRef.GetTable(RlshpMgtCommentLine);
        RlshpMgtCommentLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, RlshpMgtCommentLine.FieldNo("Line No.")));
        RlshpMgtCommentLine.Insert(true);
    end;

    procedure CreateRlshpMgtCommentContact(var RlshpMgtCommentLine: Record "Rlshp. Mgt. Comment Line"; ContactNo: Code[20])
    begin
        CreateRlshpMgtCommentLine(RlshpMgtCommentLine, RlshpMgtCommentLine."Table Name"::Contact, ContactNo, 0);
        // Sub No. is 0 for Contact.
    end;

    procedure CreateRlshpMgtCommentSales(var RlshpMgtCommentLine: Record "Rlshp. Mgt. Comment Line"; SalesCycleCode: Code[10])
    begin
        CreateRlshpMgtCommentLine(RlshpMgtCommentLine, RlshpMgtCommentLine."Table Name"::"Sales Cycle", SalesCycleCode, 0);
        // Sub No. is 0 for Sales Cycle.
    end;

    procedure CreateSalutation(var Salutation: Record Salutation)
    begin
        Salutation.Init();
        Salutation.Validate(Code, LibraryUtility.GenerateRandomCode(Salutation.FieldNo(Code), DATABASE::Salutation));
        Salutation.Validate(Description, Salutation.Code);  // Validating Code as Description because value is not important.
        Salutation.Insert(true);
    end;

    procedure CreateSalutationFormula(var SalutationFormula: Record "Salutation Formula"; SalutationCode: Code[10]; LanguageCode: Code[10]; SalutationType: Enum "Salutation Formula Salutation Type")
    begin
        SalutationFormula.Init();
        SalutationFormula.Validate("Salutation Code", SalutationCode);
        SalutationFormula.Validate("Language Code", LanguageCode);
        SalutationFormula.Validate("Salutation Type", SalutationType);
        SalutationFormula.Insert(true);
    end;

    procedure CreateSalesCycle(var SalesCycle: Record "Sales Cycle")
    begin
        SalesCycle.Init();
        SalesCycle.Validate(Code, LibraryUtility.GenerateRandomCode(SalesCycle.FieldNo(Code), DATABASE::"Sales Cycle"));
        SalesCycle.Validate(Description, SalesCycle.Code);
        SalesCycle.Insert(true);
    end;

    procedure CreateSalesCycleStage(var SalesCycleStage: Record "Sales Cycle Stage"; SalesCycleCode: Code[10])
    var
        Stage: Integer;
    begin
        SalesCycleStage.SetRange("Sales Cycle Code", SalesCycleCode);
        // Use 1 to Increase Stage.
        if SalesCycleStage.FindLast() then
            Stage := SalesCycleStage.Stage + 1
        else
            Stage := 1;
        SalesCycleStage.Init();
        SalesCycleStage.Validate("Sales Cycle Code", SalesCycleCode);
        SalesCycleStage.Validate(Stage, Stage);
        SalesCycleStage.Insert(true);
    end;

    procedure CreateSalesHeaderWithContact(var SalesHeader: Record "Sales Header"; SellToContactNo: Code[20]; SellToCustomerTemplateCode: Code[10])
    begin
        SalesHeader.Init();
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Contact No.", SellToContactNo);
        SalesHeader.Modify(true);
    end;

    procedure CreateSalesQuoteWithContact(var SalesHeader: Record "Sales Header"; SellToContactNo: Code[20]; SellToCustomerTemplateCode: Code[10])
    begin
        SalesHeader.Init();
        SalesHeader.Insert(true);
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.Validate("Sell-to Contact No.", SellToContactNo);
        SalesHeader.Modify(true);
    end;

    procedure CreateSalesLineDiscount(var SalesLineDiscount: Record "Sales Line Discount"; CampaignNo: Code[20]; ItemNo: Code[20])
    begin
        SalesLineDiscount.Init();
        SalesLineDiscount.Validate(Type, SalesLineDiscount.Type::Item);
        SalesLineDiscount.Validate(Code, ItemNo);
        SalesLineDiscount.Validate("Sales Type", SalesLineDiscount."Sales Type"::Campaign);
        SalesLineDiscount.Validate("Sales Code", CampaignNo);
        SalesLineDiscount.Insert(true);
    end;

    procedure CreateSalesPriceForCampaign(var SalesPrice: Record "Sales Price"; ItemNo: Code[20]; CampaignNo: Code[20])
    begin
        SalesPrice.Init();
        SalesPrice.Validate("Item No.", ItemNo);
        SalesPrice.Validate("Sales Type", SalesPrice."Sales Type"::Campaign);
        SalesPrice.Validate("Sales Code", CampaignNo);
        SalesPrice.Insert(true);
    end;

    procedure CreateSegmentHeader(var SegmentHeader: Record "Segment Header")
    var
        MarketingSetup: Record "Marketing Setup";
    begin
        MarketingSetup.Get();
        if MarketingSetup."Segment Nos." = '' then begin
            MarketingSetup.Validate("Segment Nos.", LibraryUtility.GetGlobalNoSeriesCode());
            MarketingSetup.Modify(true);
        end;

        SegmentHeader.Init();
        SegmentHeader.Insert(true);
        SegmentHeader.Validate(Description, SegmentHeader."No.");  // Validating No. as Description because value is not important.
        SegmentHeader.Modify(true);
    end;

    procedure CreateSegmentLine(var SegmentLine: Record "Segment Line"; SegmentHeaderNo: Code[20])
    var
        RecRef: RecordRef;
    begin
        SegmentLine.Init();
        SegmentLine.Validate("Segment No.", SegmentHeaderNo);
        RecRef.GetTable(SegmentLine);
        SegmentLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecRef, SegmentLine.FieldNo("Line No.")));
        SegmentLine.Insert(true);
    end;

    procedure CreateTeam(var Team: Record Team)
    begin
        Team.Init();
        Team.Validate(Code, LibraryUtility.GenerateRandomCode(Team.FieldNo(Code), DATABASE::Team));
        Team.Insert(true);
    end;

    procedure CreateTeamSalesperson(var TeamSalesperson: Record "Team Salesperson"; TeamCode: Code[10]; SalespersonCode: Code[20])
    begin
        TeamSalesperson.Init();
        TeamSalesperson.Validate("Team Code", TeamCode);
        TeamSalesperson.Validate("Salesperson Code", SalespersonCode);
        TeamSalesperson.Insert(true);
    end;

    procedure CreateTask(var Task: Record "To-do")
    begin
        Task.Init();
        Task.Insert(true);
        Task.Validate(Description, Task."No.");
        Task.Modify(true);
    end;

    procedure CreateWebSource(var WebSource: Record "Web Source")
    begin
        WebSource.Init();
        WebSource.Validate(Code, LibraryUtility.GenerateRandomCode(WebSource.FieldNo(Code), DATABASE::"Web Source"));
        WebSource.Validate(Description, WebSource.Code);  // Validating Code as Description because value is not important.
        WebSource.Insert(true);
    end;

    procedure CreateEmailMergeCustomLayoutNo(): Code[20]
    var
        CustomReportLayout: Record "Custom Report Layout";
    begin
        CustomReportLayout.Init();
        CustomReportLayout."Report ID" := REPORT::"Email Merge";
        CustomReportLayout.Type := CustomReportLayout.Type::Word;
        CustomReportLayout.Description := StrSubstNo('%1-%2', Format(REPORT::"Email Merge"), CustomReportLayout.Code);
        CustomReportLayout.Insert(true);
        exit(CustomReportLayout.Code);
    end;

    procedure CreateEmailMergeAttachment(var Attachment: Record Attachment) ContentBodyText: Text
    begin
        Attachment.Init();
        Attachment."No." := LibraryUtility.GetNewRecNo(Attachment, Attachment.FieldNo("No."));
        Attachment."Storage Type" := Attachment."Storage Type"::Embedded;
        Attachment."File Extension" := 'HTML';
        Attachment.Insert(true);

        ContentBodyText := LibraryUtility.GenerateRandomAlphabeticText(LibraryRandom.RandIntInRange(2000, 3000), 0);
        Attachment.WriteHTMLCustomLayoutAttachment(ContentBodyText, FindEmailMergeCustomLayoutName());
    end;

    procedure CreateIntrastatContact(CountryRegionCode: Code[10]): Code[20]
    var
        Contact: Record Contact;
    begin
        CreateCompanyContact(Contact);
        Contact.Validate(Address, LibraryUtility.GenerateGUID());
        Contact.Validate("Country/Region Code", CountryRegionCode);
        Contact.Validate("Post Code", LibraryUtility.GenerateGUID());
        Contact.Validate(City, LibraryUtility.GenerateGUID());
        Contact.Validate("Phone No.", LibraryUtility.GenerateRandomPhoneNo());
        Contact.Validate("Fax No.", LibraryUtility.GenerateGUID());
        Contact.Validate("E-Mail", LibraryUtility.GenerateGUID() + '@' + LibraryUtility.GenerateGUID());
        Contact.Modify(true);
        exit(Contact."No.");
    end;

    procedure FindContact(var Contact: Record Contact)
    begin
        Contact.FindSet();
    end;

    procedure FindEmailMergeCustomLayoutNo(): Code[20]
    var
        CustomReportLayout: Record "Custom Report Layout";
    begin
        CustomReportLayout.SetRange("Report ID", REPORT::"Email Merge");
        CustomReportLayout.SetFilter(Code, 'MS-*');
        CustomReportLayout.FindFirst();
        exit(CustomReportLayout.Code);
    end;

    procedure FindEmailMergeCustomLayoutName(): Text[250]
    var
        ReportLayoutList: Record "Report Layout List";
    begin
        ReportLayoutList.SetRange("Report ID", REPORT::"Email Merge");
        ReportLayoutList.SetRange(Name, 'DefaultEmailMergeDoc.docx');
        if ReportLayoutList.FindFirst() then
            exit(ReportLayoutList.Name);
        ReportLayoutList.SetRange(Name);
        if ReportLayoutList.FindFirst() then
            exit(ReportLayoutList.Name);
        exit('');
    end;

    procedure RunAddContactsReport(LibraryVariableStorage: Codeunit "Library - Variable Storage"; UseRequestPage: Boolean)
    var
        AddContacts: Report "Add Contacts";
        RecVar: Variant;
    begin
        while LibraryVariableStorage.Length() > 0 do begin
            LibraryVariableStorage.Dequeue(RecVar);
            AddContacts.SetTableView(RecVar);
        end;
        AddContacts.UseRequestPage(UseRequestPage);
        AddContacts.RunModal();
    end;

    procedure UpdateContactAddress(var Contact: Record Contact)
    var
        CountryRegion: Record "Country/Region";
    begin
        Contact.Name := CopyStr(LibraryUtility.GenerateRandomText(10), 1, MaxStrLen(Contact.Name));
        Contact.Address := CopyStr(LibraryUtility.GenerateRandomText(10), 1, MaxStrLen(Contact.Address));
        Contact."Address 2" := CopyStr(LibraryUtility.GenerateRandomText(10), 1, MaxStrLen(Contact."Address 2"));
        Contact."Post Code" := CopyStr(LibraryUtility.GenerateRandomText(10), 1, MaxStrLen(Contact."Post Code"));
        Contact.City := CopyStr(LibraryUtility.GenerateRandomText(10), 1, MaxStrLen(Contact.City));
        Contact.County := CopyStr(LibraryUtility.GenerateRandomText(10), 1, MaxStrLen(Contact.County));
        LibraryERM.CreateCountryRegion(CountryRegion);
        CountryRegion.Name := CopyStr(LibraryUtility.GenerateRandomText(10), 1, MaxStrLen(CountryRegion.Name));
        CountryRegion.Modify();
        Contact."Country/Region Code" := CountryRegion.Code;
        Contact.Modify();
    end;
}

