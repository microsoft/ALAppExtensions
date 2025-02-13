codeunit 13750 "DK Contoso Localization"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        if Module = Enum::"Contoso Demo Data Module"::Foundation then
            FoundationModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::Finance then
            FinanceModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::Bank then
            BankModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::"Fixed Asset Module" then
            FixedAssetModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::Purchase then
            PurchaseModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::Sales then
            SalesModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::"Human Resources Module" then
            HumanResource(ContosoDemoDataLevel);
        if Module = Enum::"Contoso Demo Data Module"::CRM then
            CRMModule(ContosoDemoDataLevel);

        UnBindSubscriptionDemoData(Module);
    end;

    local procedure HumanResource(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Empl. Posting Group NL");
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Employee DK");
        end;
    end;

    local procedure CRMModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Marketing Setup DK");
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create VAT Statement Line DK");
        end;
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreatePostingGroupsDK: Codeunit "Create Posting Groups DK";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create Company Information DK");
                    Codeunit.Run(Codeunit::"Create Post Code DK");
                    Codeunit.Run(Codeunit::"Create VAT Posting Groups DK");
                    CreatePostingGroupsDK.InsertGenPostingGroup();
                end;
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateVatPostingGroupDK: Codeunit "Create VAT Posting Groups DK";
        CreatePostingGroupsDK: Codeunit "Create Posting Groups DK";
        CreateGenJournalBatchDK: Codeunit "Create Gen. Journal Batch DK";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create VAT Posting Groups DK");
                    Codeunit.Run(Codeunit::"Create Posting Groups DK");
                    CreateVatPostingGroupDK.UpdateVATPostingSetup();
                    CreatePostingGroupsDK.UpdateGenPostingSetup();
                    CreateGenJournalBatchDK.UpdateGenJournalBatch();
                    Codeunit.Run(Codeunit::"Create General Ledger Setup DK");

                    //  CreateGLAccDK.AddCategoriesToGLAccounts()
                end;

            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Currency Ex. Rate DK");
                    Codeunit.Run(Codeunit::"Create VAT Setup Post.Grp. DK");
                end;
        end;
    end;

    local procedure BankModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Bank Account DK");

            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Bank Acc Posting Grp DK");

            Enum::"Contoso Demo Data Level"::"Historical Data":
                Codeunit.Run(Codeunit::"Create Bank Acc. Reco. DK");
        end;
    end;

    local procedure FixedAssetModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create FA Posting Grp. DK");
                    Codeunit.Run(Codeunit::"Create FA SubClass DK");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create FA No. Series DK");
                    Codeunit.Run(Codeunit::"Create FA Ins Jnl. Template DK");
                end;
        end;
    end;

    local procedure PurchaseModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Purch. Payable Setup DK");
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create Purchase Document DK");
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Sales Recv. Setup DK");
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreatePostingGroupsDK: Codeunit "Create Posting Groups DK";
        CreateAnalysisViewDK: Codeunit "Create Analysis View DK";
        CreateAccScheduleLineDK: Codeunit "Create Acc. Schedule Line DK";
        CreateCurrencyDK: Codeunit "Create Currency DK";
        CreateCurrencyExchRateDK: Codeunit "Create Currency Ex. Rate DK";
        CreateLocationDK: Codeunit "Create Location DK";
        CreateInvPostingSetupDK: Codeunit "Create Inv. Posting Setup DK";
        CreateItemDK: Codeunit "Create Item DK";
        CreateBankAccountDK: Codeunit "Create Bank Account DK";
        CreatePaymentMethodDK: Codeunit "Create Payment Method DK";
        CreateBankAccPostingGrpDK: Codeunit "Create Bank Acc Posting Grp DK";
        CreateFAPostingGrpDK: Codeunit "Create FA Posting Grp. DK";
        JobPostingGroupDK: Codeunit "Job Posting Group DK";
        CreateJobDK: Codeunit "Create Job DK";
        CreateVendorPostingGroupDK: Codeunit "Create Vendor Posting Group DK";
        CreateVendorDK: Codeunit "Create Vendor DK";
        CreateCustPostingGroupDK: Codeunit "Create Cust. Posting Group DK";
        CreateReminderLevelDK: Codeunit "Create Reminder Level DK";
        CreateCustomerDK: codeunit "Create Customer DK";
        CreateCustomerTemplateDK: Codeunit "Create Customer Template DK";
        CreatePurchDimValueDK: CodeUnit "Create Purch. Dim. Value DK";
        CreateSalesDimValueDK: CodeUnit "Create Sales Dim Value DK";
        CreateEmployeeDK: Codeunit "Create Employee DK";
        CreateResourceDK: Codeunit "Create Resource DK";
        CreateShipToAddressDK: Codeunit "Create Ship-to Address DK";
        CreateVATPostingGrpDK: Codeunit "Create Vat Posting Groups DK";
        CreateFADeprBookDK: Codeunit "Create FA Depreciation Book DK";
        CreateBankAccRecoDK: Codeunit "Create Bank Acc. Reco. DK";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreatePostingGroupsDK);
                    BindSubscription(CreateAnalysisViewDK);
                    BindSubscription(CreateAccScheduleLineDK);
                    BindSubscription(CreateCurrencyDK);
                    BindSubscription(CreateCurrencyExchRateDK);
                    BindSubscription(CreateResourceDK);
                    BindSubscription(CreateVATPostingGrpDK);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    BindSubscription(CreatePaymentMethodDK);
                    BindSubscription(CreateBankAccountDK);
                    BindSubscription(CreateBankAccPostingGrpDK);
                    BindSubscription(CreateBankAccRecoDK);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                begin
                    BindSubscription(CreateFAPostingGrpDK);
                    BindSubscription(CreateFADeprBookDK);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateInvPostingSetupDK);
                    BindSubscription(CreateItemDK);
                    BindSubscription(CreateLocationDK);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreateVendorPostingGroupDK);
                    BindSubscription(CreateVendorDK);
                    BindSubscription(CreatePurchDimValueDK);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateCustPostingGroupDK);
                    BindSubscription(CreateReminderLevelDK);
                    BindSubscription(CreateCustomerDK);
                    BindSubscription(CreateCustomerTemplateDK);
                    BindSubscription(CreateSalesDimValueDK);
                    BindSubscription(CreateShipToAddressDK);
                end;
            Enum::"Contoso Demo Data Module"::"Job Module":
                begin
                    BindSubscription(JobPostingGroupDK);
                    BindSubscription(CreateJobDK);
                end;
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                BindSubscription(CreateEmployeeDK);
        end;
    end;


    local procedure UnBindSubscriptionDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreatePostingGroupsDK: Codeunit "Create Posting Groups DK";
        CreateAnalysisViewDK: Codeunit "Create Analysis View DK";
        CreateAccScheduleLineDK: Codeunit "Create Acc. Schedule Line DK";
        CreateCurrencyDK: Codeunit "Create Currency DK";
        CreateCurrencyExchRateDK: Codeunit "Create Currency Ex. Rate DK";
        CreateLocationDK: Codeunit "Create Location DK";
        CreateInvPostingSetupDK: Codeunit "Create Inv. Posting Setup DK";
        CreateItemDK: Codeunit "Create Item DK";
        CreateBankAccountDK: Codeunit "Create Bank Account DK";
        CreatePaymentMethodDK: Codeunit "Create Payment Method DK";
        CreateBankAccPostingGrpDK: Codeunit "Create Bank Acc Posting Grp DK";
        CreateFAPostingGrpDK: Codeunit "Create FA Posting Grp. DK";
        JobPostingGroupDK: Codeunit "Job Posting Group DK";
        CreateJobDK: Codeunit "Create Job DK";
        CreateVendorPostingGroupDK: Codeunit "Create Vendor Posting Group DK";
        CreateVendorDK: Codeunit "Create Vendor DK";
        CreateCustPostingGroupDK: Codeunit "Create Cust. Posting Group DK";
        CreateReminderLevelDK: Codeunit "Create Reminder Level DK";
        CreateCustomerDK: codeunit "Create Customer DK";
        CreateCustomerTemplateDK: Codeunit "Create Customer Template DK";
        CreatePurchDimValueDK: Codeunit "Create Purch. Dim. Value DK";
        CreateSalesDimValueDK: CodeUnit "Create Sales Dim Value DK";
        CreateEmployeeDK: Codeunit "Create Employee DK";
        CreateResourceDK: Codeunit "Create Resource DK";
        ShipToAddressDK: Codeunit "Create Ship-to Address DK";
        CreateVATPostingGrpDK: Codeunit "Create Vat Posting Groups DK";
        CreateFADeprBookDK: Codeunit "Create FA Depreciation Book DK";
        CreateBankAccRecoDK: Codeunit "Create Bank Acc. Reco. DK";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnBindSubscription(CreatePostingGroupsDK);
                    UnBindSubscription(CreateAnalysisViewDK);
                    UnBindSubscription(CreateAccScheduleLineDK);
                    UnBindSubscription(CreateCurrencyDK);
                    UnbindSubscription(CreateCurrencyExchRateDK);
                    UnbindSubscription(CreateResourceDK);
                    UnbindSubscription(CreateVATPostingGrpDK);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    UnBindSubscription(CreatePaymentMethodDK);
                    UnBindSubscription(CreateBankAccountDK);
                    UnBindSubscription(CreateBankAccPostingGrpDK);
                    UnbindSubscription(CreateBankAccRecoDK);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                begin
                    UnbindSubscription(CreateFADeprBookDK);
                    UnBindSubscription(CreateFAPostingGrpDK);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnBindSubscription(CreateInvPostingSetupDK);
                    UnBindSubscription(CreateItemDK);
                    UnBindSubscription(CreateLocationDK);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnBindSubscription(CreateVendorPostingGroupDK);
                    UnBindSubscription(CreateVendorDK);
                    UnbindSubscription(CreatePurchDimValueDK);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnBindSubscription(CreateReminderLevelDK);
                    UnBindSubscription(CreateCustomerDK);
                    UnBindSubscription(CreateCustomerTemplateDK);
                    UnBindSubscription(CreateCustPostingGroupDK);
                    UnbindSubscription(CreateSalesDimValueDK);
                    UnBindSubscription(ShipToAddressDK)
                end;
            Enum::"Contoso Demo Data Module"::"Job Module":
                begin
                    UnBindSubscription(JobPostingGroupDK);
                    UnBindSubscription(CreateJobDK);
                end;
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                UnbindSubscription(CreateEmployeeDK);
        end;
    end;
}
