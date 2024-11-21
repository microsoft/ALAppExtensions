codeunit 5553 "Create Activity Step"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateActivity: Codeunit "Create Activity";
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.InsertActivityStep(CreateActivity.CompanyPresentation(), 10000, Enum::"Task Type"::" ", KeyPersonsPresentationLbl, 2, '');
        ContosoCRM.InsertActivityStep(CreateActivity.CompanyPresentation(), 20000, Enum::"Task Type"::" ", ShowroomAvailabilityLbl, 1, '<+1W>');
        ContosoCRM.InsertActivityStep(CreateActivity.CompanyPresentation(), 30000, Enum::"Task Type"::"Phone Call", CallCustomerLbl, 2, '<+1W>');
        ContosoCRM.InsertActivityStep(CreateActivity.CompanyPresentation(), 40000, Enum::"Task Type"::" ", BookShowroomLbl, 1, '<+1W>');
        ContosoCRM.InsertActivityStep(CreateActivity.CompanyPresentation(), 50000, Enum::"Task Type"::" ", TailorPresentationLbl, 2, '<+2W>');
        ContosoCRM.InsertActivityStep(CreateActivity.Initial(), 5000, Enum::"Task Type"::" ", VerifyQualityLbl, 2, '');
        ContosoCRM.InsertActivityStep(CreateActivity.Initial(), 10000, Enum::"Task Type"::" ", IdentifyKeyPersonsLbl, 1, '<+1W>');
        ContosoCRM.InsertActivityStep(CreateActivity.UnderstandingNeeds(), 10000, Enum::"Task Type"::" ", EstCustomerNeedsLbl, 0, '');
        ContosoCRM.InsertActivityStep(CreateActivity.UnderstandingNeeds(), 20000, Enum::"Task Type"::"Phone Call", SetUpMeetingLbl, 1, '<+3D>');
        ContosoCRM.InsertActivityStep(CreateActivity.UnderstandingNeeds(), 25000, Enum::"Task Type"::Meeting, ExpectationsAndNeedsLbl, 2, '<+2W>');
        ContosoCRM.InsertActivityStep(CreateActivity.UnderstandingNeeds(), 30000, Enum::"Task Type"::" ", VerifyChangeCustomerNeedsLbl, 1, '<+3W>');
        ContosoCRM.InsertActivityStep(CreateActivity.ProductPresentation(), 10000, Enum::"Task Type"::"Phone Call", AppointmentForProdPresentationLbl, 1, '');
        ContosoCRM.InsertActivityStep(CreateActivity.ProductPresentation(), 20000, Enum::"Task Type"::" ", ConfirmProdPresentationWritingLbl, 2, '<+2D>');
        ContosoCRM.InsertActivityStep(CreateActivity.ProductPresentation(), 30000, Enum::"Task Type"::" ", BookNecessaryEquipmentLbl, 1, '<+2D>');
        ContosoCRM.InsertActivityStep(CreateActivity.Proposal(), 10000, Enum::"Task Type"::" ", DraftAProposalLbl, 2, '');
        ContosoCRM.InsertActivityStep(CreateActivity.Proposal(), 20000, Enum::"Task Type"::" ", InternalApprovementOfProposalLbl, 2, '<+3D>');
        ContosoCRM.InsertActivityStep(CreateActivity.Proposal(), 30000, Enum::"Task Type"::"Phone Call", ArrangeDateForThePresentationLbl, 2, '<+1W>');
        ContosoCRM.InsertActivityStep(CreateActivity.Proposal(), 40000, Enum::"Task Type"::Meeting, PresentTheProposalLbl, 2, '<+2W>');
        ContosoCRM.InsertActivityStep(CreateActivity.PresentationWorkshop(), 10000, Enum::"Task Type"::"Phone Call", AppointmentForProductWorkshopLbl, 1, '');
        ContosoCRM.InsertActivityStep(CreateActivity.PresentationWorkshop(), 20000, Enum::"Task Type"::" ", ConfirmProdWorkshopWritingLbl, 0, '<+3D>');
        ContosoCRM.InsertActivityStep(CreateActivity.PresentationWorkshop(), 30000, Enum::"Task Type"::" ", BookNecessaryEquipmentLbl, 0, '<+3D>');
        ContosoCRM.InsertActivityStep(CreateActivity.PresentationWorkshop(), 40000, Enum::"Task Type"::" ", AvailabilityInternalResLbl, 1, '<+3D>');
        ContosoCRM.InsertActivityStep(CreateActivity.Qualification(), 10000, Enum::"Task Type"::" ", EstCustomerNeedsLbl, 1, '');
        ContosoCRM.InsertActivityStep(CreateActivity.Qualification(), 20000, Enum::"Task Type"::" ", SendLetterOfIntroductionLbl, 1, '<+1W>');
        ContosoCRM.InsertActivityStep(CreateActivity.Qualification(), 30000, Enum::"Task Type"::"Phone Call", FollowUpOnIntroductionLetterLbl, 2, '<+2W>');
        ContosoCRM.InsertActivityStep(CreateActivity.Qualification(), 40000, Enum::"Task Type"::" ", VerifyChangeCustomerNeedsLbl, 2, '<+2W+1D>');
        ContosoCRM.InsertActivityStep(CreateActivity.SignContract(), 10000, Enum::"Task Type"::" ", CheckDeliveryStatusOnProductsLbl, 0, '');
        ContosoCRM.InsertActivityStep(CreateActivity.SignContract(), 20000, Enum::"Task Type"::Meeting, SignContractLbl, 2, '<+1W>');
        ContosoCRM.InsertActivityStep(CreateActivity.SignContract(), 30000, Enum::"Task Type"::" ", AdminHandlesContractLbl, 1, '<+2W>');
        ContosoCRM.InsertActivityStep(CreateActivity.SignContract(), 40000, Enum::"Task Type"::" ", FollowUpOnCustomerSatisfactionLbl, 1, '<+6M>');
        ContosoCRM.InsertActivityStep(CreateActivity.Workshop(), 10000, Enum::"Task Type"::"Phone Call", AppointmentForWorkshopLbl, 1, '');
        ContosoCRM.InsertActivityStep(CreateActivity.Workshop(), 20000, Enum::"Task Type"::" ", ConfirmWorkshopInWritingLbl, 2, '<+3D>');
        ContosoCRM.InsertActivityStep(CreateActivity.Workshop(), 30000, Enum::"Task Type"::" ", AvailabilityInternalResLbl, 2, '<+3D>');
    end;

    var
        KeyPersonsPresentationLbl: Label 'Invite key persons to presentation', MaxLength = 100;
        ShowroomAvailabilityLbl: Label 'Check dates for showroom availability', MaxLength = 100;
        CallCustomerLbl: Label 'Call customer to confirm date', MaxLength = 100;
        BookShowroomLbl: Label 'Book showroom ect.', MaxLength = 100;
        TailorPresentationLbl: Label 'Tailor presentation to customer', MaxLength = 100;
        VerifyQualityLbl: Label 'Verify quality of opportunity', MaxLength = 100;
        IdentifyKeyPersonsLbl: Label 'Identify key persons', MaxLength = 100;
        EstCustomerNeedsLbl: Label 'Est. customer needs', MaxLength = 100;
        SetUpMeetingLbl: Label 'Set up meeting', MaxLength = 100;
        ExpectationsAndNeedsLbl: Label 'Go through expectations and needs', MaxLength = 100;
        VerifyChangeCustomerNeedsLbl: Label 'Verify/change customer needs', MaxLength = 100;
        AppointmentForProdPresentationLbl: Label 'Make appointment for product presentation', MaxLength = 100;
        ConfirmProdPresentationWritingLbl: Label 'Confirm product presentation in writing', MaxLength = 100;
        BookNecessaryEquipmentLbl: Label 'Book necessary equipment', MaxLength = 100;
        DraftAProposalLbl: Label 'Draft a proposal', MaxLength = 100;
        InternalApprovementOfProposalLbl: Label 'Internal approvement of proposal', MaxLength = 100;
        ArrangeDateForThePresentationLbl: Label 'Arrange date for the presentation of the proposal', MaxLength = 100;
        PresentTheProposalLbl: Label 'Present the proposal and set date for follow-up', MaxLength = 100;
        AppointmentForProductWorkshopLbl: Label 'Make appointment for product presentation/workshop', MaxLength = 100;
        ConfirmProdWorkshopWritingLbl: Label 'Confirm product presentation/workshop in writing', MaxLength = 100;
        AvailabilityInternalResLbl: Label 'Ensure availability of internal resources', MaxLength = 100;
        SendLetterOfIntroductionLbl: Label 'Send letter of introduction', MaxLength = 100;
        FollowUpOnIntroductionLetterLbl: Label 'Follow-up on introduction letter', MaxLength = 100;
        CheckDeliveryStatusOnProductsLbl: Label 'Check delivery status on products', MaxLength = 100;
        SignContractLbl: Label 'Sign Contract', MaxLength = 100;
        AdminHandlesContractLbl: Label 'Arrange that the admin. handles the contract', MaxLength = 100;
        FollowUpOnCustomerSatisfactionLbl: Label 'Follow-up on customer satisfaction', MaxLength = 100;
        AppointmentForWorkshopLbl: Label 'Make appointment for workshop', MaxLength = 100;
        ConfirmWorkshopInWritingLbl: Label 'Confirm workshop in writing', MaxLength = 100;
}