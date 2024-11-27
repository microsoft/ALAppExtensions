codeunit 5180 "Contoso CRM"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Duplicate Search String Setup" = rim,
                  tabledata "Interaction Group" = rim,
                  tabledata "Interaction Template" = rim,
                  tabledata "Interaction Template Setup" = rim,
                  tabledata "Interaction Tmpl. Language" = rim,
                  tabledata "Marketing Setup" = rim,
                  tabledata Activity = rim,
                  tabledata "Activity Step" = rim,
                  tabledata "Business Relation" = rim,
                  tabledata Salutation = rim,
                  tabledata "Salutation Formula" = rim,
                  tabledata "Sales Cycle" = rim,
                  tabledata Campaign = rim,
                  tabledata "Campaign Status" = rim,
                  tabledata "Close Opportunity Code" = rim,
                  tabledata "Industry Group" = rim,
                  tabledata "Job Responsibility" = rim,
                  tabledata "Mailing Group" = rim,
                  tabledata "Territory" = rim,
                  tabledata "Salesperson/Purchaser" = rim,
                  tabledata "Word Template" = rim,
                  tabledata "Web Source" = rim,
                  tabledata "Organizational Level" = rim,
                  tabledata Team = rim,
                  tabledata "Sales Cycle Stage" = rim,
                  tabledata "Segment Header" = rim,
                  tabledata "Segment Line" = rim,
                  tabledata Opportunity = rim,
                  tabledata "Opportunity Entry" = rim,
                  tabledata "Contact Job Responsibility" = rim,
                  tabledata "Profile Questionnaire Header" = rim,
                  tabledata "Profile Questionnaire Line" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertDuplicateSearchStringSetup(FieldNo: Integer; PartOfField: Option; Length: Integer)
    var
        DuplicateSearchStringSetup: Record "Duplicate Search String Setup";
        Exists: Boolean;
    begin
        if DuplicateSearchStringSetup.Get(FieldNo, PartOfField) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        DuplicateSearchStringSetup.Validate("Field No.", FieldNo);
        DuplicateSearchStringSetup.Validate("Part of Field", PartOfField);
        DuplicateSearchStringSetup.Validate(Length, Length);

        if Exists then
            DuplicateSearchStringSetup.Modify(true)
        else
            DuplicateSearchStringSetup.Insert(true);
    end;

    procedure InsertInteractionGroup(Code: Code[10]; Description: Text[100])
    var
        InteractionGroup: Record "Interaction Group";
        Exists: Boolean;
    begin
        if InteractionGroup.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        InteractionGroup.Validate(Code, Code);
        InteractionGroup.Validate(Description, Description);

        if Exists then
            InteractionGroup.Modify(true)
        else
            InteractionGroup.Insert(true);
    end;

    procedure InsertInteractionTemplate(Code: Code[10]; InteractionGroupCode: Code[10]; Description: Text[100]; UnitCostLCY: Decimal; UnitDurationMin: Decimal; InformationFlow: Integer; InitiatedBy: Integer; CorrespondenceTypeDefault: Enum "Correspondence Type"; WizardAction: Enum "Interaction Template Wizard Action"; IgnoreContactCorresType: Boolean)
    var
        InteractionTemplate: Record "Interaction Template";
        Exists: Boolean;
    begin
        if InteractionTemplate.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        InteractionTemplate.Validate(Code, Code);
        InteractionTemplate.Validate("Interaction Group Code", InteractionGroupCode);
        InteractionTemplate.Validate(Description, Description);
        InteractionTemplate.Validate("Unit Cost (LCY)", UnitCostLCY);
        InteractionTemplate.Validate("Unit Duration (Min.)", UnitDurationMin);
        InteractionTemplate.Validate("Information Flow", InformationFlow);
        InteractionTemplate.Validate("Initiated By", InitiatedBy);
        InteractionTemplate.Validate("Correspondence Type (Default)", CorrespondenceTypeDefault);
        InteractionTemplate.Validate("Wizard Action", WizardAction);
        InteractionTemplate.Validate("Ignore Contact Corres. Type", IgnoreContactCorresType);

        if Exists then
            InteractionTemplate.Modify(true)
        else
            InteractionTemplate.Insert(true);
    end;

    procedure InsertInteractionTemplateSetup(SalesInvoices: Code[10]; SalesCrMemo: Code[10]; SalesOrdCnfrmn: Code[10]; SalesQuotes: Code[10]; PurchInvoices: Code[10]; PurchCrMemos: Code[10]; PurchOrders: Code[10]; PurchQuotes: Code[10]; EMails: Code[10]; CoverSheets: Code[10]; OutgCalls: Code[10]; SalesBlnktOrd: Code[10]; ServOrdPost: Code[10]; SalesShptNote: Code[10]; SalesStatement: Code[10]; SalesRmdr: Code[10]; ServOrdCreate: Code[10]; PurchBlnktOrd: Code[10]; PurchRcpt: Code[10]; SalesReturnOrder: Code[10]; SalesReturnReceipt: Code[10]; SalesFinanceChargeMemo: Code[10]; PurchReturnShipment: Code[10]; PurchReturnOrdCnfrmn: Code[10]; MeetingInvitation: Code[10]; EMailDraft: Code[10]; SalesDraftInvoices: Code[10])
    var
        InteractionTemplateSetup: Record "Interaction Template Setup";
    begin
        if not InteractionTemplateSetup.Get() then
            InteractionTemplateSetup.Insert();

        InteractionTemplateSetup.Validate("Sales Invoices", SalesInvoices);
        InteractionTemplateSetup.Validate("Sales Cr. Memo", SalesCrMemo);
        InteractionTemplateSetup.Validate("Sales Ord. Cnfrmn.", SalesOrdCnfrmn);
        InteractionTemplateSetup.Validate("Sales Quotes", SalesQuotes);
        InteractionTemplateSetup.Validate("Purch Invoices", PurchInvoices);
        InteractionTemplateSetup.Validate("Purch Cr Memos", PurchCrMemos);
        InteractionTemplateSetup.Validate("Purch. Orders", PurchOrders);
        InteractionTemplateSetup.Validate("Purch. Quotes", PurchQuotes);
        InteractionTemplateSetup.Validate("E-Mails", EMails);
        InteractionTemplateSetup.Validate("Cover Sheets", CoverSheets);
        InteractionTemplateSetup.Validate("Outg. Calls", OutgCalls);
        InteractionTemplateSetup.Validate("Sales Blnkt. Ord", SalesBlnktOrd);
        InteractionTemplateSetup.Validate("Serv Ord Post", ServOrdPost);
        InteractionTemplateSetup.Validate("Sales Shpt. Note", SalesShptNote);
        InteractionTemplateSetup.Validate("Sales Statement", SalesStatement);
        InteractionTemplateSetup.Validate("Sales Rmdr.", SalesRmdr);
        InteractionTemplateSetup.Validate("Serv Ord Create", ServOrdCreate);
        InteractionTemplateSetup.Validate("Purch Blnkt Ord", PurchBlnktOrd);
        InteractionTemplateSetup.Validate("Purch. Rcpt.", PurchRcpt);
        InteractionTemplateSetup.Validate("Sales Return Order", SalesReturnOrder);
        InteractionTemplateSetup.Validate("Sales Return Receipt", SalesReturnReceipt);
        InteractionTemplateSetup.Validate("Sales Finance Charge Memo", SalesFinanceChargeMemo);
        InteractionTemplateSetup.Validate("Purch. Return Shipment", PurchReturnShipment);
        InteractionTemplateSetup.Validate("Purch. Return Ord. Cnfrmn.", PurchReturnOrdCnfrmn);
        InteractionTemplateSetup.Validate("Meeting Invitation", MeetingInvitation);
        InteractionTemplateSetup.Validate("E-Mail Draft", EMailDraft);
        InteractionTemplateSetup.Validate("Sales Draft Invoices", SalesDraftInvoices);
        InteractionTemplateSetup.Modify(true);
    end;

    procedure InsertInteractionTmplLanguage(InteractionTemplateCode: Code[10]; LanguageCode: Code[10])
    var
        InteractionTmplLanguage: Record "Interaction Tmpl. Language";
        Exists: Boolean;
    begin
        if InteractionTmplLanguage.Get(InteractionTemplateCode, LanguageCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        InteractionTmplLanguage.Validate("Interaction Template Code", InteractionTemplateCode);
        InteractionTmplLanguage.Validate("Language Code", LanguageCode);

        if Exists then
            InteractionTmplLanguage.Modify(true)
        else
            InteractionTmplLanguage.Insert(true);
    end;

    procedure InsertSalesCycle(SalesCycleCode: Code[10]; Description: Text[100]; ProbabilityCalculation: Integer)
    var
        SalesCycle: Record "Sales Cycle";
        Exists: Boolean;
    begin
        if SalesCycle.Get(SalesCycleCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        SalesCycle.Validate(Code, SalesCycleCode);
        SalesCycle.Validate(Description, Description);
        SalesCycle.Validate("Probability Calculation", ProbabilityCalculation);

        if Exists then
            SalesCycle.Modify(true)
        else
            SalesCycle.Insert(true);
    end;

    procedure InsertMarketingSetup(CountryOrRegionCode: Code[10]; ContactNos: Code[20]; CampaignNos: Code[20]; SegmentNos: Code[20]; ToDoNos: Code[20]; OpportunityNos: Code[20]; BusRelCodeForCustomers: Code[10]; BusRelCodeForVendors: Code[10]; BusRelCodeForBankAccs: Code[10]; BusRelCodeForEmployees: Code[10]; InheritSalespersonCode: Boolean; InheritTerritoryCode: Boolean; InheritCountryRegionCode: Boolean; InheritLanguageCode: Boolean; InheritAddressDetails: Boolean; InheritCommunicationDetails: Boolean; DefaultLanguageCode: Code[10]; DefaultSalesCycleCode: Code[10]; AttachmentStorageType: Enum "Setup Attachment Storage Type"; AutosearchForDuplicates: Boolean; SearchHitPercentage: Integer; MaintainDuplSearchStrings: Boolean; MergefieldLanguageID: Integer; DefCompanySalutationCode: Code[10]; DefaultPersonSalutationCode: Code[10]; DefaultCorrespondenceType: Enum "Correspondence Type"; InheritFormatRegion: Boolean)
    var
        MarketingSetup: Record "Marketing Setup";
    begin
        if not MarketingSetup.Get() then
            MarketingSetup.Insert();

        MarketingSetup.Validate("Default Country/Region Code", CountryOrRegionCode);
        MarketingSetup.Validate("Contact Nos.", ContactNos);
        MarketingSetup.Validate("Campaign Nos.", CampaignNos);
        MarketingSetup.Validate("Segment Nos.", SegmentNos);
        MarketingSetup.Validate("To-do Nos.", ToDoNos);
        MarketingSetup.Validate("Opportunity Nos.", OpportunityNos);
        MarketingSetup.Validate("Bus. Rel. Code for Customers", BusRelCodeForCustomers);
        MarketingSetup.Validate("Bus. Rel. Code for Vendors", BusRelCodeForVendors);
        MarketingSetup.Validate("Bus. Rel. Code for Bank Accs.", BusRelCodeForBankAccs);
        MarketingSetup.Validate("Bus. Rel. Code for Employees", BusRelCodeForEmployees);
        MarketingSetup.Validate("Inherit Salesperson Code", InheritSalespersonCode);
        MarketingSetup.Validate("Inherit Territory Code", InheritTerritoryCode);
        MarketingSetup.Validate("Inherit Country/Region Code", InheritCountryRegionCode);
        MarketingSetup.Validate("Inherit Language Code", InheritLanguageCode);
        MarketingSetup.Validate("Inherit Address Details", InheritAddressDetails);
        MarketingSetup.Validate("Inherit Communication Details", InheritCommunicationDetails);
        MarketingSetup.Validate("Default Language Code", DefaultLanguageCode);
        MarketingSetup.Validate("Default Sales Cycle Code", DefaultSalesCycleCode);
        MarketingSetup.Validate("Attachment Storage Type", AttachmentStorageType);
        MarketingSetup.Validate("Autosearch for Duplicates", AutosearchForDuplicates);
        MarketingSetup.Validate("Search Hit %", SearchHitPercentage);
        MarketingSetup.Validate("Maintain Dupl. Search Strings", MaintainDuplSearchStrings);
        MarketingSetup.Validate("Mergefield Language ID", MergefieldLanguageID);
        MarketingSetup.Validate("Def. Company Salutation Code", DefCompanySalutationCode);
        MarketingSetup.Validate("Default Person Salutation Code", DefaultPersonSalutationCode);
        MarketingSetup.Validate("Default Correspondence Type", DefaultCorrespondenceType);
        MarketingSetup.Validate("Inherit Format Region", InheritFormatRegion);
        MarketingSetup.Modify(true);
    end;

    procedure InsertActivity(Code: Code[10]; Description: Text[100])
    var
        Activity: Record "Activity";
        Exists: Boolean;
    begin
        if Activity.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Activity.Validate(Code, Code);
        Activity.Validate(Description, Description);

        if Exists then
            Activity.Modify(true)
        else
            Activity.Insert(true);
    end;

    procedure InsertActivityStep(ActivityCode: Code[10]; StepNo: Integer; Type: Enum "Task Type"; Description: Text[100]; Priority: Integer; DateFormula: Text)
    var
        ActivityStep: Record "Activity Step";
        Exists: Boolean;
    begin
        if ActivityStep.Get(ActivityCode, StepNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ActivityStep.Validate("Activity Code", ActivityCode);
        ActivityStep.Validate("Step No.", StepNo);
        ActivityStep.Validate(Type, Type);
        ActivityStep.Validate(Description, Description);
        ActivityStep.Validate(Priority, Priority);
        Evaluate(ActivityStep."Date Formula", DateFormula);

        if Exists then
            ActivityStep.Modify(true)
        else
            ActivityStep.Insert(true);
    end;

    procedure InsertBusinessRelation(Code: Code[10]; Description: Text[100])
    var
        BusinessRelation: Record "Business Relation";
        Exists: Boolean;
    begin
        if BusinessRelation.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        BusinessRelation.Validate(Code, Code);
        BusinessRelation.Validate(Description, Description);

        if Exists then
            BusinessRelation.Modify(true)
        else
            BusinessRelation.Insert(true);
    end;

    procedure InsertSalutations(Code: Code[10]; Description: Text[100])
    var
        Salutation: Record Salutation;
        Exists: Boolean;
    begin
        if Salutation.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Salutation.Validate(Code, Code);
        Salutation.Validate(Description, Description);

        if Exists then
            Salutation.Modify(true)
        else
            Salutation.Insert(true);
    end;

    procedure InsertCampaign(No: Code[20]; Description: Text[100]; StartingDate: Date; EndingDate: Date; SalespersonCode: Code[20]; NoSeries: Code[20]; StatusCode: Code[10])
    var
        Campaign: Record "Campaign";
        Exists: Boolean;
    begin
        if Campaign.Get(No) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Campaign.Validate("No.", No);
        Campaign.Validate(Description, Description);
        Campaign.Validate("Starting Date", StartingDate);
        Campaign.Validate("Ending Date", EndingDate);
        Campaign.Validate("Salesperson Code", SalespersonCode);
        Campaign.Validate("No. Series", NoSeries);
        Campaign.Validate("Status Code", StatusCode);

        if Exists then
            Campaign.Modify(true)
        else
            Campaign.Insert(true);
    end;

    procedure InsertCampaignStatus(Code: Code[10]; Description: Text[100])
    var
        CampaignStatus: Record "Campaign Status";
        Exists: Boolean;
    begin
        if CampaignStatus.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CampaignStatus.Code := Code;
        CampaignStatus.Description := Description;

        if Exists then
            CampaignStatus.Modify(true)
        else
            CampaignStatus.Insert(true);
    end;

    procedure InsertCloseOpportunityCode(Code: Code[10]; Description: Text[100]; Type: Option)
    var
        CloseOpportunityCode: Record "Close Opportunity Code";
        Exists: Boolean;
    begin
        if CloseOpportunityCode.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CloseOpportunityCode.Validate(Code, Code);
        CloseOpportunityCode.Validate(Description, Description);
        CloseOpportunityCode.Validate(Type, Type);

        if Exists then
            CloseOpportunityCode.Modify(true)
        else
            CloseOpportunityCode.Insert(true);
    end;

    procedure InsertIndustryGroup(Code: Code[10]; Description: Text[100])
    var
        IndustryGroup: Record "Industry Group";
        Exists: Boolean;
    begin
        if IndustryGroup.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        IndustryGroup.Validate(Code, Code);
        IndustryGroup.Validate(Description, Description);

        if Exists then
            IndustryGroup.Modify(true)
        else
            IndustryGroup.Insert(true);
    end;

    procedure InsertJobResponsibility(Code: Code[10]; Description: Text[100])
    var
        JobResponsibility: Record "Job Responsibility";
        Exists: Boolean;
    begin
        if JobResponsibility.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        JobResponsibility.Validate(Code, Code);
        JobResponsibility.Validate(Description, Description);

        if Exists then
            JobResponsibility.Modify(true)
        else
            JobResponsibility.Insert(true);
    end;

    procedure InsertMailingGroup(Code: Code[10]; Description: Text[100])
    var
        MailingGroup: Record "Mailing Group";
        Exists: Boolean;
    begin
        if MailingGroup.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        MailingGroup.Validate(Code, Code);
        MailingGroup.Validate(Description, Description);

        if Exists then
            MailingGroup.Modify(true)
        else
            MailingGroup.Insert(true);
    end;

    procedure InsertTerritory(Code: Code[10]; Name: Text[50])
    var
        Territory: Record "Territory";
        Exists: Boolean;
    begin
        if Territory.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Territory.Validate(Code, Code);
        Territory.Validate(Name, Name);

        if Exists then
            Territory.Modify(true)
        else
            Territory.Insert(true);
    end;

    procedure InsertSalespersonPurchaser(Code: Code[20]; Name: Text[50]; CommissionPercentage: Decimal; Picture: Codeunit "Temp Blob"; EMail: Text[80])
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Exists: Boolean;
    begin
        if SalespersonPurchaser.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        SalespersonPurchaser.Validate(Code, Code);
        SalespersonPurchaser.Validate(Name, Name);
        SalespersonPurchaser.Validate("Commission %", CommissionPercentage);
        SalespersonPurchaser.Validate("E-Mail", EMail);

        if Exists then
            SalespersonPurchaser.Modify(true)
        else
            SalespersonPurchaser.Insert(true);
    end;

    procedure InsertWordTemplate(Code: Code[30]; Name: Text[250]; TableID: Integer; FileName: Text; LanguageCode: Code[10])
    var
        WordTemplate: Record "Word Template";
        Exists: Boolean;
        InStream: InStream;
    begin
        if WordTemplate.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        WordTemplate.Validate(Code, Code);
        WordTemplate.Validate(Name, Name);
        WordTemplate.Validate("Table ID", TableID);
        WordTemplate.Validate("Language Code", LanguageCode);

        NavApp.GetResource(FileName, InStream);
        WordTemplate.Template.ImportStream(InStream, 'Template');

        if Exists then
            WordTemplate.Modify(true)
        else
            WordTemplate.Insert(true);
    end;

    procedure InsertWebSource(Code: Code[10]; Description: Text[100]; URL: Text[250])
    var
        WebSource: Record "Web Source";
        Exists: Boolean;
    begin
        if WebSource.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        WebSource.Validate(Code, Code);
        WebSource.Validate(Description, Description);
        WebSource.Validate(URL, URL);

        if Exists then
            WebSource.Modify(true)
        else
            WebSource.Insert(true);
    end;

    procedure InsertOrganizationalLevel(Code: Code[10]; Description: Text[100])
    var
        OrganizationalLevel: Record "Organizational Level";
        Exists: Boolean;
    begin
        if OrganizationalLevel.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        OrganizationalLevel.Validate(Code, Code);
        OrganizationalLevel.Validate(Description, Description);

        if Exists then
            OrganizationalLevel.Modify(true)
        else
            OrganizationalLevel.Insert(true);
    end;

    procedure InsertTeam(Code: Code[10]; Name: Text[50])
    var
        Team: Record Team;
        Exists: Boolean;
    begin
        if Team.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Team.Validate(Code, Code);
        Team.Validate(Name, Name);

        if Exists then
            Team.Modify(true)
        else
            Team.Insert(true);
    end;

    procedure InsertSalesCycleStage(SalesCycleCode: Code[10]; Stage: Integer; Description: Text[100]; CompletedPercent: Decimal; ActivityCode: Code[10]; QuoteRequired: Boolean; AllowSkip: Boolean; ChancesofSuccessPercent: Decimal)
    var
        SalesCycleStage: Record "Sales Cycle Stage";
        Exists: Boolean;
    begin
        if SalesCycleStage.Get(SalesCycleCode, Stage) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        SalesCycleStage.Validate("Sales Cycle Code", SalesCycleCode);
        SalesCycleStage.Validate(Stage, Stage);
        SalesCycleStage.Validate(Description, Description);
        SalesCycleStage.Validate("Completed %", CompletedPercent);
        SalesCycleStage.Validate("Activity Code", ActivityCode);
        SalesCycleStage.Validate("Quote Required", QuoteRequired);
        SalesCycleStage.Validate("Allow Skip", AllowSkip);
        SalesCycleStage.Validate("Chances of Success %", ChancesofSuccessPercent);

        if Exists then
            SalesCycleStage.Modify(true)
        else
            SalesCycleStage.Insert(true);
    end;

    procedure InsertSegmentHeader(No: Code[20]; Description: Text[100]; SalespersonCode: Code[20]; CorrespondenceType: Enum "Correspondence Type"; InteractionTemplateCode: Code[10]; UnitCost: Decimal; UnitDuration: Decimal; InteractionGroupCode: Code[10]; InformationFlow: Integer; InitiatedBy: Integer; IgnoreContactCorresType: Boolean)
    var
        SegmentHeader: Record "Segment Header";
        Exists: Boolean;
    begin
        if SegmentHeader.Get(No) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        SegmentHeader.Validate("No.", No);
        SegmentHeader.Validate(Description, Description);
        SegmentHeader.Validate("Salesperson Code", SalespersonCode);
        SegmentHeader.Validate("Correspondence Type (Default)", CorrespondenceType);
        SegmentHeader.Validate("Unit Cost (LCY)", UnitCost);
        SegmentHeader.Validate("Unit Duration (Min.)", UnitDuration);
        SegmentHeader.Validate("Interaction Group Code", InteractionGroupCode);
        SegmentHeader.Validate("Information Flow", InformationFlow);
        SegmentHeader.Validate("Initiated By", InitiatedBy);
        SegmentHeader.Validate("Ignore Contact Corres. Type", IgnoreContactCorresType);

        if Exists then
            SegmentHeader.Modify(true)
        else
            SegmentHeader.Insert(true);

        SegmentHeader.Validate("Interaction Template Code", InteractionTemplateCode);
        SegmentHeader.Modify(true);
    end;

    procedure InsertSegmentLine(SegmentNo: Code[20]; LineNo: Integer; ContactNo: Code[20])
    var
        SegmentLine: Record "Segment Line";
        Exists: Boolean;
    begin
        if SegmentLine.Get(SegmentNo, LineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        SegmentLine.Validate("Segment No.", SegmentNo);
        SegmentLine.Validate("Line No.", LineNo);
        SegmentLine.Validate("Contact No.", ContactNo);

        if Exists then
            SegmentLine.Modify(true)
        else
            SegmentLine.Insert(true);
    end;

    procedure InsertOpportunity(No: Code[10]; Description: Text[100]; SalespersonCode: Code[20]; ContactNo: Code[20]; ContactCompanyNo: Code[20]; SalesCycleCode: Code[10]; CreationDate: Date; Status: Enum "Opportunity Status"; Priority: Enum "Opportunity Priority"; Closed: Boolean; DateClosed: Date; NoSeries: Code[20])
    var
        Opportunity: Record Opportunity;
        Exists: Boolean;
    begin
        if Opportunity.Get(No) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Opportunity.Validate("No.", No);
        Opportunity.Validate(Description, Description);
        Opportunity.Validate("Salesperson Code", SalespersonCode);
        Opportunity.Validate("Contact No.", ContactNo);
        Opportunity.Validate("Contact Company No.", ContactCompanyNo);
        Opportunity.Validate("Sales Cycle Code", SalesCycleCode);
        Opportunity.Validate("Creation Date", CreationDate);
        Opportunity.Validate(Status, Status);
        Opportunity.Validate(Priority, Priority);
        Opportunity.Validate(Closed, Closed);
        Opportunity.Validate("Date Closed", DateClosed);
        Opportunity.Validate("No. Series", NoSeries);

        if Exists then
            Opportunity.Modify(true)
        else
            Opportunity.Insert(true);
    end;

    procedure InsertOpportunityEntry(EntryNo: Integer; OpportunityNo: Code[10]; SalesCycleStage: Integer; EstimatedCloseDate: Date; DateofChange: Date; Active: Boolean; DateClosed: Date; ActionTaken: Integer; EstimatedValueLCY: Decimal; CompletedPercent: Decimal; ChancesofSuccessPercent: Decimal; CloseOpportunityCode: Code[10]; PreviousSalesCycleStage: Integer)
    var
        Opportunity: Record Opportunity;
        OpportunityEntry: Record "Opportunity Entry";
    begin
        OpportunityEntry.Validate("Entry No.", EntryNo);
        OpportunityEntry.Validate("Opportunity No.", OpportunityNo);

        Opportunity.Get(OpportunityNo);
        OpportunityEntry.Validate("Sales Cycle Code", Opportunity."Sales Cycle Code");
        OpportunityEntry.Validate("Contact No.", Opportunity."Contact No.");
        OpportunityEntry.Validate("Contact Company No.", Opportunity."Contact Company No.");
        OpportunityEntry.Validate("Salesperson Code", Opportunity."Salesperson Code");
        OpportunityEntry.Validate("Campaign No.", Opportunity."Campaign No.");

        OpportunityEntry.Validate("Sales Cycle Stage", SalesCycleStage);
        OpportunityEntry.Validate("Estimated Close Date", EstimatedCloseDate);
        OpportunityEntry.Validate("Date of Change", DateofChange);
        OpportunityEntry.Validate(Active, Active);
        OpportunityEntry.Validate("Date Closed", DateClosed);
        OpportunityEntry.Validate("Action Taken", ActionTaken);
        OpportunityEntry.Validate("Estimated Value (LCY)", EstimatedValueLCY);
        OpportunityEntry.Validate("Completed %", CompletedPercent);
        OpportunityEntry.Validate("Chances of Success %", ChancesofSuccessPercent);
        OpportunityEntry.Validate("Close Opportunity Code", CloseOpportunityCode);
        OpportunityEntry.Validate("Previous Sales Cycle Stage", PreviousSalesCycleStage);
        OpportunityEntry.Insert();

        OpportunityEntry.UpdateEstimates();

        if OpportunityEntry."Action Taken" = OpportunityEntry."Action Taken"::Won then begin
            OpportunityEntry."Calcd. Current Value (LCY)" := EstimatedValueLCY;
            OpportunityEntry.Modify();
        end;
    end;

    procedure InsertProfileQuestionnaireHeader(Code: Code[20]; Description: Text[250]; ContactType: Enum "Profile Questionnaire Contact Type"; BusinessRelationCode: Code[10])
    var
        ProfileQuestionnaireHeader: Record "Profile Questionnaire Header";
        Exists: Boolean;
    begin
        if ProfileQuestionnaireHeader.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ProfileQuestionnaireHeader.Validate(Code, Code);
        ProfileQuestionnaireHeader.Validate(Description, Description);
        ProfileQuestionnaireHeader.Validate("Contact Type", ContactType);
        ProfileQuestionnaireHeader.Validate("Business Relation Code", BusinessRelationCode);

        if Exists then
            ProfileQuestionnaireHeader.Modify(true)
        else
            ProfileQuestionnaireHeader.Insert(true);
    end;

    procedure InsertProfileQuestionnaireLine(ProfileQuestionnaireCode: Code[20]; LineNo: Integer; Type: Enum "Profile Questionnaire Line Type"; Description: Text[250]; MultipleAnswers: Boolean; Priority: Enum "Profile Answer Priority"; AutoContactClassification: Boolean; ClassificationFieldsCust: Enum "Profile Quest. Cust. Class. Field"; StartingDateFormula: Text[30]; EndingDateFormula: Text[30]; ClassificationMethod: Integer; SortingMethod: Integer; FromValue: Decimal; ToValue: Decimal)
    var
        ProfileQuestionnaireLine: Record "Profile Questionnaire Line";
        Exists: Boolean;
    begin
        if ProfileQuestionnaireLine.Get(ProfileQuestionnaireCode, LineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ProfileQuestionnaireLine.Validate("Profile Questionnaire Code", ProfileQuestionnaireCode);
        ProfileQuestionnaireLine.Validate("Line No.", LineNo);
        ProfileQuestionnaireLine.Validate(Type, Type);
        ProfileQuestionnaireLine.Validate(Description, Description);
        ProfileQuestionnaireLine.Validate("Multiple Answers", MultipleAnswers);
        ProfileQuestionnaireLine.Priority := Priority;
        ProfileQuestionnaireLine.Validate("Auto Contact Classification", AutoContactClassification);
        ProfileQuestionnaireLine.Validate("Customer Class. Field", ClassificationFieldsCust);
        Evaluate(ProfileQuestionnaireLine."Starting Date Formula", StartingDateFormula);
        ProfileQuestionnaireLine.Validate("Starting Date Formula");
        Evaluate(ProfileQuestionnaireLine."Ending Date Formula", EndingDateFormula);
        ProfileQuestionnaireLine.Validate("Ending Date Formula");
        ProfileQuestionnaireLine.Validate("Classification Method", ClassificationMethod);
        ProfileQuestionnaireLine.Validate("Sorting Method", SortingMethod);
        ProfileQuestionnaireLine.Validate("From Value", FromValue);
        ProfileQuestionnaireLine.Validate("To Value", ToValue);

        if Exists then
            ProfileQuestionnaireLine.Modify(true)
        else
            ProfileQuestionnaireLine.Insert(true);
    end;

    procedure InsertSalutationFormula(SalutationCode: Code[10]; LanguageCode: Code[10]; SalutationType: Enum "Salutation Formula Salutation Type"; Salutation: Text[50]; Name1: Enum "Salutation Formula Name"; Name2: Enum "Salutation Formula Name"; Name3: Enum "Salutation Formula Name")
    var
        SalutationFormula: Record "Salutation Formula";
        Exists: Boolean;
    begin
        if SalutationFormula.Get(SalutationCode, LanguageCode, SalutationType) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        SalutationFormula.Validate("Salutation Code", SalutationCode);
        SalutationFormula.Validate("Language Code", LanguageCode);
        SalutationFormula.Validate("Salutation Type", SalutationType);
        SalutationFormula.Validate(Salutation, Salutation);
        SalutationFormula.Validate("Name 1", Name1);
        SalutationFormula.Validate("Name 2", Name2);
        SalutationFormula.Validate("Name 3", Name3);

        if Exists then
            SalutationFormula.Modify(true)
        else
            SalutationFormula.Insert(true);
    end;

    procedure InsertContactJobResponsibility(ContactNo: Code[20]; JobResponsibilityCode: Code[10])
    var
        ContactJobResponsibility: Record "Contact Job Responsibility";
        Exists: Boolean;
    begin
        if ContactJobResponsibility.Get(ContactNo, JobResponsibilityCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ContactJobResponsibility.Validate("Contact No.", ContactNo);
        ContactJobResponsibility.Validate("Job Responsibility Code", JobResponsibilityCode);

        if Exists then
            ContactJobResponsibility.Modify(true)
        else
            ContactJobResponsibility.Insert(true);
    end;

    procedure FindContactNo(LinkToTable: Enum "Contact Business Relation Link To Table"; ContactBusinessRelationNo: Code[20]; ContactType: Integer): Code[20]
    var
        ContactBusinessRelation: Record "Contact Business Relation";
        Contact: Record Contact;
    begin
        if ContactType = 0 then begin
            ContactBusinessRelation.SetRange("Link to Table", LinkToTable);
            ContactBusinessRelation.SetRange("No.", ContactBusinessRelationNo);
            if ContactBusinessRelation.FindFirst() then
                exit(ContactBusinessRelation."Contact No.")
        end else begin
            ContactBusinessRelation.SetRange("Link to Table", LinkToTable);
            ContactBusinessRelation.SetRange("No.", ContactBusinessRelationNo);
            if ContactBusinessRelation.FindFirst() then begin
                Contact.SetRange("Company No.", ContactBusinessRelation."Contact No.");
                Contact.SetRange(Type, ContactType);
                if Contact.FindFirst() then
                    exit(Contact."No.");
            end;
        end;
    end;
}