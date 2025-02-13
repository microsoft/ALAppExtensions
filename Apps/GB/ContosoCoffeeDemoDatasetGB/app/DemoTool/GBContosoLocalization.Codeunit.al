codeunit 11487 "GB Contoso Localization"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure LocalizationContosoDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                FoundationModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Finance:
                FinanceModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Purchase:
                PurchaseModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::Sales:
                SalesModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                HumanResourcesModule(ContosoDemoDataLevel);
            Enum::"Contoso Demo Data Module"::EService:
                EServiceModule(ContosoDemoDataLevel);
        end;
    end;

    local procedure EServiceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create GB Incoming Document");
        end;
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create GB Company Information");
        end;
    end;

    local procedure PurchaseModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create GB Purch Payable Setup");
        end;
    end;

    local procedure SalesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create GB Sales Recv Setup");
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create GB Customer");
                    Codeunit.Run(Codeunit::"Create GB Sales DimensionValue");
                end;
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create GB Sales Document");
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateGBVATPostingGroup: Codeunit "Create GB VAT Posting Group";
        CreateGBGenPostingSetup: Codeunit "Create GB Gen Posting Setup";
        CreateGBGLAccounts: Codeunit "Create GB GL Accounts";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create GB General Ledger Setup");
                    CreateGBGLAccounts.AddCategoriesToGLAccounts();
                    CreateGBGenPostingSetup.UpdateGenPostingSetup();
                    CreateGBVATPostingGroup.UpdateVATPostingSetup();
                    Codeunit.Run(Codeunit::"Create GB Column Layout Name");
                    Codeunit.Run(Codeunit::"Create GB VAT Report Setup")
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create GB Column Layout");
                    Codeunit.Run(Codeunit::"Create GB VAT Statement");
                    Codeunit.Run(Codeunit::"Create GB Gen. Journal Batch");
                end;
        end;
    end;

    local procedure HumanResourcesModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create GB Employee");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(ContosoDemoDataLevel: Enum "Contoso Demo Data Level"; Module: Enum "Contoso Demo Data Module")
    var
        CreateGBInvPostingSetup: Codeunit "Create GB Inv Posting Setup";
        CreateGBBankAccPostingGrp: Codeunit "Create GB Bank Acc Posting Grp";
        CreateGBPaymentMethod: Codeunit "Create GB Payment Method";
        CreateGBBankAccRec: Codeunit "Create GB Bank Acc. Rec.";
        CreateGBVendor: Codeunit "Create GB Vendor";
        CreateGBVATStatement: Codeunit "Create GB VAT Statement";
        CreateGBVATSetupPostGrp: Codeunit "Create GB VAT Setup Post. Grp.";
        CreateGBVendorPostingGroup: Codeunit "Create GB Vendor Posting Group";
        CreateGBCustPostingGroup: Codeunit "Create GB Cust Posting Group";
        CreateGBCustomer: Codeunit "Create GB Customer";
        CreateGBVATReportSetup: Codeunit "Create GB VAT Report Setup";
        CreateGBSalesDimensionValue: Codeunit "Create GB Sales DimensionValue";
        CreateGBFAPostingGroup: Codeunit "Create GB FA Posting Group";
        CreateGBResource: Codeunit "Create GB Resource";
        CreateGBAnalysisViews: Codeunit "Create GB Analysis View";
        CreateGBVATPostingGroup: Codeunit "Create GB VAT Posting Group";
        CreateGBAccScheduleLine: Codeunit "Create GB Acc Schedule Line";
        CreateGBCurrency: Codeunit "Create GB Currency";
        CreateGBFADepreciationBook: Codeunit "Create GB FA Depreciation Book";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Inventory:
                BindSubscription(CreateGBInvPostingSetup);
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    BindSubscription(CreateGBBankAccPostingGrp);
                    BindSubscription(CreateGBPaymentMethod);
                    BindSubscription(CreateGBBankAccRec);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreateGBVendor);
                    BindSubscription(CreateGBVendorPostingGroup);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateGBCustPostingGroup);
                    BindSubscription(CreateGBCustomer);
                    BindSubscription(CreateGBSalesDimensionValue);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                begin
                    BindSubscription(CreateGBFAPostingGroup);
                    BindSubscription(CreateGBFADepreciationBook);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    BindSubscription(CreateGBResource);
                    BindSubscription(CreateGBVATReportSetup);
                    BindSubscription(CreateGBAnalysisViews);
                    BindSubscription(CreateGBVATPostingGroup);
                    BindSubscription(CreateGBAccScheduleLine);
                    BindSubscription(CreateGBVATSetupPostGrp);
                    BindSubscription(CreateGBVATStatement);
                    BindSubscription(CreateGBCurrency);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(ContosoDemoDataLevel: Enum "Contoso Demo Data Level"; Module: Enum "Contoso Demo Data Module")
    var
        CreateGBInvPostingSetup: Codeunit "Create GB Inv Posting Setup";
        CreateGBBankAccPostingGrp: Codeunit "Create GB Bank Acc Posting Grp";
        CreateGBPaymentMethod: Codeunit "Create GB Payment Method";
        CreateGBBankAccRec: Codeunit "Create GB Bank Acc. Rec.";
        CreateGBVendor: Codeunit "Create GB Vendor";
        CreateGBVATSetupPostGrp: Codeunit "Create GB VAT Setup Post. Grp.";
        CreateGBVATStatement: Codeunit "Create GB VAT Statement";
        CreateGBVendorPostingGroup: Codeunit "Create GB Vendor Posting Group";
        CreateGBCustPostingGroup: Codeunit "Create GB Cust Posting Group";
        CreateGBCustomer: Codeunit "Create GB Customer";
        CreateGBVATReportSetup: Codeunit "Create GB VAT Report Setup";
        CreateGBSalesDimensionValue: Codeunit "Create GB Sales DimensionValue";
        CreateGBFAPostingGroup: Codeunit "Create GB FA Posting Group";
        CreateGBResource: Codeunit "Create GB Resource";
        CreateGBAnalysisViews: Codeunit "Create GB Analysis View";
        CreateGBVATPostingGroup: Codeunit "Create GB VAT Posting Group";
        CreateGBAccScheduleLine: Codeunit "Create GB Acc Schedule Line";
        CreateGBCurrency: Codeunit "Create GB Currency";
        CreateGBFADepreciationBook: Codeunit "Create GB FA Depreciation Book";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    UnbindSubscription(CreateGBBankAccPostingGrp);
                    UnbindSubscription(CreateGBPaymentMethod);
                    UnbindSubscription(CreateGBBankAccRec);
                end;
            Enum::"Contoso Demo Data Module"::Inventory:
                UnbindSubscription(CreateGBInvPostingSetup);
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnbindSubscription(CreateGBVendor);
                    UnbindSubscription(CreateGBVendorPostingGroup);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnbindSubscription(CreateGBCustPostingGroup);
                    UnbindSubscription(CreateGBCustomer);
                    UnbindSubscription(CreateGBSalesDimensionValue);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                begin
                    UnbindSubscription(CreateGBFAPostingGroup);
                    UnbindSubscription(CreateGBFADepreciationBook);
                end;
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnbindSubscription(CreateGBResource);
                    UnbindSubscription(CreateGBAnalysisViews);
                    UnbindSubscription(CreateGBVATReportSetup);
                    UnbindSubscription(CreateGBVATPostingGroup);
                    UnbindSubscription(CreateGBVATSetupPostGrp);
                    UnbindSubscription(CreateGBVATStatement);
                    UnbindSubscription(CreateGBAccScheduleLine);
                    UnbindSubscription(CreateGBCurrency);
                end;
        end;
    end;
}