codeunit 18077 "Library GST"
{
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryERM: Codeunit "Library - ERM";
        LibraryResource: Codeunit "Library - Resource";
        FinancialYear: Code[10];
        CGSTLbl: Label 'CGST';
        SGSTLbl: Label 'SGST';
        IGSTLbl: Label 'IGST';
        AmountLEVerifyErr: Label '%1 is incorrect in %2.', Comment = '%1 and %2 = Field Caption and Table Caption';

    procedure CreateInitialSetup(): Code[10]
    var
        StateCode: Code[10];
    begin
        if IsTaxAccountingPeriodEmpty() then
            CreateGSTAccountingPeriod();
        StateCode := CreateGSTStateCode();
        exit(StateCode);
    end;

    procedure CreateGSTStateCode(): Code[10]
    var
        State: Record State;
        GSTState: Record State;
        StateGSTRegNo: Code[10];
        GSTRegNo: Integer;
    begin
        GSTRegNo := LibraryRandom.RandIntInRange(10, 90);
        StateGSTRegNo := Format(GSTRegNo);
        GSTState.Reset();
        GSTState.SetCurrentKey("State Code (GST Reg. No.)");
        GSTState.SetFilter("State Code (GST Reg. No.)", '%1', StateGSTRegNo);
        if not GSTState.FindFirst() then begin
            CreateState(State);
            State.Validate(Description, State.Code);
            State.Validate("State Code (GST Reg. No.)", StateGSTRegNo);
            State.Modify(true);
            exit(State.Code);
        end else
            exit(GSTState.Code)
    end;

    procedure CreateCustomerGSTStateCode(LocationState: Code[10]): Code[10]
    var
        State: Record State;
        GSTState: Record State;
        StateGSTRegNo: Code[10];
    begin
        GSTState.Reset();
        GSTState.SetCurrentKey("State Code (GST Reg. No.)");
        GSTState.SetFilter(Code, '<>%1', LocationState);
        GSTState.SetFilter("State Code (GST Reg. No.)", '%1..%2', '10', '99');
        if GSTState.FindSet() then
            GSTState.DeleteAll(true);

        StateGSTRegNo := Format(LibraryRandom.RandIntInRange(10, 80));

        GSTState.Reset();
        GSTState.SetCurrentKey("State Code (GST Reg. No.)");
        GSTState.SetFilter(Code, '<>%1', LocationState);
        GSTState.FindFirst();
        if GSTState."State Code (GST Reg. No.)" = StateGSTRegNo then
            StateGSTRegNo := IncStr(StateGSTRegNo);

        State.Reset();
        CreateState(State);
        State.Validate(Description, State.Code);
        State.Validate("State Code (GST Reg. No.)", StateGSTRegNo);
        State.Modify(true);
        exit(State.Code);
    end;

    procedure CreateState(var State: Record State)
    begin
        State.Init();
        State.Validate(Code,
            CopyStr(LibraryUtility.GenerateRandomCode(State.FieldNo(Code), Database::State),
            1, LibraryUtility.GetFieldLength(Database::State, State.FieldNo(Code))));
        State.Insert(true);
    end;

    procedure CreateGSTRegistrationNos(StateCode: Code[10]; PANNo: Code[20]): Code[15]
    var
        GSTRegistrationNos: Record "GST Registration Nos.";
        State: Record State;
        GSTRegistrationNo: Code[15];
    begin
        State.Get(StateCode);
        GSTRegistrationNo := GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", PANNo);
        GSTRegistrationNos.Reset();
        GSTRegistrationNos.SetRange(Code, GSTRegistrationNo);
        if GSTRegistrationNos.IsEmpty() then begin
            GSTRegistrationNos.Init();
            GSTRegistrationNos.Validate("State Code", StateCode);
            GSTRegistrationNos.Validate(Code, GSTRegistrationNo);
            GSTRegistrationNos.Insert();
            exit(CopyStr(GSTRegistrationNos.Code, 1, 15));
        end else
            exit(GSTRegistrationNo);
    end;

    procedure CreateGSTRegistrationNoForISD(StateCode: Code[10]; PANNo: Code[20]; InputServiceDistributor: Boolean): Code[20]
    var
        GSTRegistrationNos: Record "GST Registration Nos.";
        State: Record State;
    begin
        GSTRegistrationNos.Init();
        GSTRegistrationNos.Validate("State Code", StateCode);
        State.Get(StateCode);
        GSTRegistrationNos.Validate(Code, GenerateGSTRegistrationNo(State."State Code (GST Reg. No.)", PANNo));
        if InputServiceDistributor then
            GSTRegistrationNos.Validate("Input Service Distributor", true)
        else
            GSTRegistrationNos.Validate("Input Service Distributor", false);
        GSTRegistrationNos.Insert();

        exit(GSTRegistrationNos.Code);
    end;

    procedure GenerateGSTRegistrationNo(StateCodeGSTReg: Code[10]; PANNo: Code[20]): Code[15]
    var
        GSTRegistrationNo: Code[15];
        GSTRegNo: Code[15];
    begin
        Evaluate(GSTRegistrationNo, (StateCodeGSTReg + PANNo));
        GSTRegistrationNo := GSTRegistrationNo + Format(LibraryRandom.RandIntInRange(0, 9));
        GSTRegistrationNo := CopyStr(GSTRegistrationNo + 'Z', 1, 15);
        GSTRegistrationNo := CopyStr(GSTRegistrationNo + CopyStr(LibraryUtility.GenerateRandomAlphabeticText(1, 0), 1, 1), 1, 15);
        GSTRegNo := CopyStr(GSTRegistrationNo, 1, 15);

        exit(GSTRegNo);
    end;

    procedure CreateLocationSetup(StateCode: Code[10]; GSTRegNo: Code[15]; GSTInputServiceDistribution: Boolean): Code[10]
    var
        Location: Record Location;
        LibraryWarehouse: Codeunit "Library - Warehouse";
    begin
        Location.Validate(Code, LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location));
        Location.Validate("State Code", StateCode);
        Location."GST Registration No." := GSTRegNo;
        Location."GST Input Service Distributor" := GSTInputServiceDistribution;
        Location.Modify(true);

        exit(location.Code);
    end;

    procedure UpdateLocationWithISD(LocationCode: Code[10]; GSTInputServiceDistribution: Boolean)
    var
        GSTRegistrationNos: Record "GST Registration Nos.";
        Location: Record Location;
    begin
        Location.Get(LocationCode);

        GSTRegistrationNos.Get(Location."GST Registration No.");
        GSTRegistrationNos.Validate("Input Service Distributor", GSTInputServiceDistribution);
        GSTRegistrationNos.Modify();

        Location.Get(LocationCode);
        Location.Validate("GST Registration No.");
        Location.Validate("Input Service Distributor", GSTInputServiceDistribution);
        Location.Modify();
    end;

    procedure CreateVendorSetup(): Code[20]
    var
        Vendor: Record Vendor;
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryPurchase: Codeunit "Library - Purchase";
        VendorNo: Code[20];
    begin
        CreateZeroVATPostingSetup(VATPostingSetup);
        LibraryERM.CreateGenBusPostingGroup(GenBusinessPostingGroup);
        LibraryERM.CreateGenProdPostingGroup(GenProductPostingGroup);
        CreateGeneralPostingSetup(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code);

        VendorNo := LibraryPurchase.CreateVendorNo();
        Vendor.Get(VendorNo);
        Vendor.Validate("Gen. Bus. Posting Group", GenBusinessPostingGroup.Code);
        Vendor.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Vendor.Modify(true);

        exit(Vendor."No.");
    end;

    procedure CreateCustomerSetup(): Code[20]
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
        LibrarySales: Codeunit "Library - Sales";
        CustomerNo: Code[20];
    begin
        LibraryERM.FindZeroVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        LibraryERM.CreateGenBusPostingGroup(GenBusinessPostingGroup);
        LibraryERM.CreateGenProdPostingGroup(GenProductPostingGroup);
        CreateGeneralPostingSetup(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code);

        CustomerNo := LibrarySales.CreateCustomerNo();

        Customer.Get(CustomerNo);
        Customer.Validate(Address, CopyStr(LibraryUtility.GenerateGUID(), 1, MaxStrLen(Customer.Address)));
        Customer.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Customer.Validate("Gen. Bus. Posting Group", GenBusinessPostingGroup.Code);
        Customer.Modify(true);

        exit(Customer."No.");
    end;

    procedure CreateCustomerSetupWithPaymentMethodBank(): Code[20]
    var
        Customer: Record Customer;
        PaymentMethod: Record "Payment Method";
        VATPostingSetup: Record "VAT Posting Setup";
        LibrarySales: Codeunit "Library - Sales";
        CustomerNo: Code[20];
    begin
        LibraryERM.FindZeroVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        LibraryERM.CreateGenBusPostingGroup(GenBusinessPostingGroup);
        LibraryERM.CreateGenProdPostingGroup(GenProductPostingGroup);
        CreateGeneralPostingSetup(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code);
        CreatePaymentMethodWithBalAccount(PaymentMethod);

        CustomerNo := LibrarySales.CreateCustomerNo();

        Customer.Get(CustomerNo);
        Customer.Validate(Address, CopyStr(LibraryUtility.GenerateGUID(), 1, MaxStrLen(Customer.Address)));
        Customer.Validate("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Customer.Validate("Gen. Bus. Posting Group", GenBusinessPostingGroup.Code);
        Customer.Validate("Payment Method Code", PaymentMethod.Code);
        Customer.Modify(true);

        exit(Customer."No.");
    end;

    procedure CreatePaymentMethodWithBalAccount(var PaymentMethod: Record "Payment Method")
    var
        BankAccount: Record "Bank Account";
        LibraryERM: Codeunit "Library - ERM";
    begin
        LibraryERM.FindBankAccount(BankAccount);
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        PaymentMethod.Validate("Bal. Account Type", PaymentMethod."Bal. Account Type"::"Bank Account");
        PaymentMethod.Validate("Bal. Account No.", BankAccount."No.");
        PaymentMethod.Modify(true);
    end;

    procedure CreatePANNos(): Code[20]
    var
        PANNo: Code[20];
    begin
        PANNo := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(5, 0), 1, 5);
        PANNo := PANNo + Format(LibraryRandom.RandIntInRange(1000, 9999));
        Evaluate(PANNo, (PANNo + CopyStr(LibraryUtility.GenerateRandomAlphabeticText(1, 0), 1, 1)));

        exit(PANNo);
    end;

    procedure CreateGovtPANNos(): Code[20]
    var
        PANNo: Code[20];
    begin
        PANNo := CopyStr(LibraryUtility.GenerateRandomAlphabeticText(4, 0), 1, 5);
        PANNo := PANNo + Format(LibraryRandom.RandIntInRange(10000, 99999));
        Evaluate(PANNo, (PANNo + CopyStr(LibraryUtility.GenerateRandomAlphabeticText(1, 0), 1, 1)));

        exit(PANNo);
    end;

    procedure CreateGeneralPostingSetup(GenBusinessPostingGroup: Code[20]; GenProductPostingGroup: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        GeneralPostingSetup.SetRange("Gen. Bus. Posting Group", GenBusinessPostingGroup);
        GeneralPostingSetup.SetRange("Gen. Prod. Posting Group", GenProductPostingGroup);
        if not GeneralPostingSetup.FindFirst() then begin
            GeneralPostingSetup.Init();
            GeneralPostingSetup.Validate("Gen. Bus. Posting Group", GenBusinessPostingGroup);
            GeneralPostingSetup.Validate("Gen. Prod. Posting Group", GenProductPostingGroup);
            GeneralPostingSetup.Insert(true);
            GeneralPostingSetup.Validate("Sales Account", CreateGLAccountNo(GenBusinessPostingGroup, GenProductPostingGroup));
            GeneralPostingSetup.Validate("Purch. Account", CreateGLAccountNo(GenBusinessPostingGroup, GenProductPostingGroup));
            GeneralPostingSetup.Validate("COGS Account", CreateGLAccountNo(GenBusinessPostingGroup, GenProductPostingGroup));
            GeneralPostingSetup.Validate("Inventory Adjmt. Account", CreateGLAccountNo(GenBusinessPostingGroup, GenProductPostingGroup));
            GeneralPostingSetup.Validate("Direct Cost Applied Account", CreateGLAccountNo(GenBusinessPostingGroup, GenProductPostingGroup));
            GeneralPostingSetup.Validate("Purch. Line Disc. Account", CreateGLAccountNo(GenBusinessPostingGroup, GenProductPostingGroup));
            GeneralPostingSetup.Validate("Purch. Credit Memo Account", CreateGLAccountNo(GenBusinessPostingGroup, GenProductPostingGroup));
            GeneralPostingSetup.Validate("Sales Credit Memo Account", CreateGLAccountNo(GenBusinessPostingGroup, GenProductPostingGroup));
            GeneralPostingSetup.Modify(true);
        end;
    end;

    procedure CreateGLAccountNo(GenBusinessPostingGroup: Code[20]; GenProductPostingGroup: Code[20]): Code[20]
    var
        GLAccount: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        CreateZeroVATPostingSetup(VATPostingSetup);
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Gen. Bus. Posting Group", GenBusinessPostingGroup);
        GLAccount.Validate("Gen. Prod. Posting Group", GenProductPostingGroup);
        GLAccount.Validate("Gen. Posting Type", GLAccount."Gen. Posting Type"::Purchase);
        GLAccount.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        GLAccount.Modify(true);

        exit(GLAccount."No.");
    end;

    local procedure CreateChargeItem(GenProductPostingGroup: Code[20]): Code[20]
    var
        ItemCharge: Record "Item Charge";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        CreateZeroVATPostingSetup(VATPostingSetup);
        LibraryInventory.CreateItemCharge(ItemCharge);
        ItemCharge.Validate("Gen. Prod. Posting Group", GenProductPostingGroup);
        ItemCharge.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        ItemCharge.Modify(true);

        exit(ItemCharge."No.");
    end;

    procedure CreateGSTGroup(
        var GSTGroup: Record "GST Group";
        GSTGroupType: Enum "GST Group Type";
        GSTDependencyType: Enum "GST Dependency Type";
        ReverseCharge: Boolean): Code[20]
    begin
        GSTGroup.Init();
        GSTGroup.Validate(Code, LibraryUtility.GenerateRandomCode(GSTGroup.FieldNo(Code), Database::"GST Group"));
        GSTGroup.Validate("GST Group Type", GSTGroupType);
        GSTGroup.Validate("GST Place Of Supply", GSTDependencyType);
        GSTGroup.Validate(Description, GSTGroup.Code);
        if ReverseCharge then
            GSTGroup.Validate("Reverse Charge", ReverseCharge);
        GSTGroup.Insert(true);

        exit(GSTGroup.Code);
    end;

    procedure CreateCessGSTGroup(
        var GSTGroup: Record "GST Group";
        GSTGroupType: Enum "GST Group Type";
        GSTDependencyType: Enum "GST Dependency Type";
        CompCalcType: Enum "Component Calc Type";
        ReverseCharge: Boolean): Code[20]
    begin
        GSTGroup.Init();
        GSTGroup.Validate(Code, LibraryUtility.GenerateRandomCode(GSTGroup.FieldNo(Code), Database::"GST Group"));
        GSTGroup.Validate("GST Group Type", GSTGroupType);
        GSTGroup.Validate("GST Place Of Supply", GSTDependencyType);
        GSTGroup.Validate("Component Calc. Type", CompCalcType);
        GSTGroup.Validate(Description, GSTGroup.Code);
        if ReverseCharge then
            GSTGroup.Validate("Reverse Charge", ReverseCharge);
        GSTGroup.Insert(true);

        exit(GSTGroup.Code);
    end;

    procedure UpdateGSTGroupCodeWithReversCharge(GSTGroupCode: Code[10]; ReverseCharge: Boolean)
    var
        GSTGroup: Record "GST Group";
    begin
        if GSTGroup.Get(GSTGroupCode) then begin
            GSTGroup.Validate("Reverse Charge", ReverseCharge);
            GSTGroup.Modify();
        end;
    end;

    procedure CreateHSNSACCode(
        var HSNSAC: Record "HSN/SAC";
        GSTGroupCode: Code[20];
        HSNSACType: Enum "GST Goods And Services Type"): Code[10]
    begin
        HSNSAC.Init();
        HSNSAC.Validate("GST Group Code", GSTGroupCode);
        HSNSAC.Validate(Code, LibraryUtility.GenerateRandomCode(HSNSAC.FieldNo(Code), Database::"HSN/SAC"));
        HSNSAC.Validate(Description, HSNSAC.Code);
        HSNSAC.Validate(Type, HSNSACType);
        HSNSAC.Insert(true);

        exit(HSNSAC.Code);
    end;

    procedure CreateGSTComponent(var TaxComponent: Record "Tax Component"; GSTComponentCode: Text[30])
    var
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;

        TaxComponent.Reset();
        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetRange(Name, GSTComponentCode);
        if not TaxComponent.FindFirst() then begin
            TaxComponent.Init();
            TaxComponent."Tax Type" := GSTSetup."GST Tax Type";
            TaxComponent.Name := GSTComponentCode;
            TaxComponent.Type := TaxComponent.Type::Decimal;
            TaxComponent."Rounding Precision" := 0.01;
            TaxComponent.Direction := TaxComponent.Direction::Nearest;
            TaxComponent.Insert(true);
        end;
    end;

    procedure CreateGSTPostingSetup(var TaxComponent: Record "Tax Component"; StateCode: Code[10])
    var
        GSTPostingSetup: Record "GST Posting Setup";
    begin
        if not GSTPostingSetup.Get(StateCode, TaxComponent.Id) then begin
            GSTPostingSetup.Init();
            GSTPostingSetup.Validate("State Code", StateCode);
            GSTPostingSetup.Validate("Component ID", TaxComponent.Id);
            GSTPostingSetup.Validate("Receivable Account", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Validate("Payable Account", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Validate("Receivable Account (Interim)", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Validate("Payables Account (Interim)", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Validate("Expense Account", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Validate("Refund Account", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Validate("Receivable Acc. Interim (Dist)", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Validate("Receivable Acc. (Dist)", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Validate("IGST Payable A/c (Import)", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Validate("GST Credit Mismatch Account", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Insert();
        end;
    end;

    procedure CreateGSTCessPostingSetup(GSTComponentCode: Text[30]; StateCode: Code[10])
    var
        GSTPostingSetup: Record "GST Posting Setup";
        TaxComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;

        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetRange(Name, GSTComponentCode);
        TaxComponent.FindFirst();

        if not GSTPostingSetup.Get(StateCode, TaxComponent.Id) then begin
            GSTPostingSetup.Init();
            GSTPostingSetup.Validate("State Code", StateCode);
            GSTPostingSetup.Validate("Component ID", TaxComponent.Id);
            GSTPostingSetup.Validate("Receivable Account", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Validate("Payable Account", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Validate("Receivable Account (Interim)", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Validate("Payables Account (Interim)", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Validate("Expense Account", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Validate("Refund Account", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Validate("Receivable Acc. Interim (Dist)", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Validate("Receivable Acc. (Dist)", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Validate("IGST Payable A/c (Import)", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
            GSTPostingSetup.Insert();
        end;
    end;

    procedure UpdateLineDiscAccInGeneralPostingSetup(GenBusinessPostingGroup: Code[20]; GenProductPostingGroup: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        GeneralPostingSetup.SetRange("Gen. Bus. Posting Group", GenBusinessPostingGroup);
        GeneralPostingSetup.SetRange("Gen. Prod. Posting Group", GenProductPostingGroup);
        if GeneralPostingSetup.FindFirst() then begin
            GeneralPostingSetup.Validate("Purch. Line Disc. Account", CreateGLAccountNo(GenBusinessPostingGroup, GenProductPostingGroup));
            GeneralPostingSetup.Validate("Sales Line Disc. Account", CreateGLAccountNo(GenBusinessPostingGroup, GenProductPostingGroup));
            GeneralPostingSetup.Modify(true);
        end;
    end;

    procedure CreateItemWithGSTDetails(
        var VATPostingSetup: Record "VAT Posting Setup";
        GSTGroupCode: Code[20];
        HSNSACCode: Code[10];
        Availment: Boolean;
        ChargeItemExempted: Boolean): Code[20]
    var
        Item: Record Item;
    begin
        CreateZeroVATPostingSetup(VATPostingSetup);
        LibraryInventory.CreateItem(Item);
        Item.Validate("GST Group Code", GSTGroupCode);
        Item.Validate("HSN/SAC Code", HSNSACCode);
        if Availment then
            Item.Validate("GST Credit", Item."GST Credit"::Availment)
        else
            Item.Validate("GST Credit", Item."GST Credit"::"Non-Availment");
        Item.Validate(Exempted, ChargeItemExempted);
        Item.Validate("Gen. Prod. Posting Group", GenProductPostingGroup.Code);
        Item.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Item.Modify(true);

        exit(Item."No.");
    end;

    procedure CreateServiceCostWithGSTDetails(
        var VATPostingSetup: Record "VAT Posting Setup";
        GSTGroupCode: Code[20];
        HSNSACCode: Code[10]): Code[10]
    var
        ServiceCost: Record "Service Cost";
        GLAccount: Record "G/L Account";
        LibraryService: Codeunit "Library - Service";
        GLAccNo: Code[20];
    begin
        CreateZeroVATPostingSetup(VATPostingSetup);
        LibraryService.CreateServiceCost(ServiceCost);

        GLAccNo := LibraryERM.CreateGLAccountWithSalesSetup();
        GLAccount.Get(GLAccNo);
        GLAccount.Validate("Gen. Prod. Posting Group", GenProductPostingGroup.Code);
        GLAccount.Modify(true);

        ServiceCost.Validate("Account No.", GLAccNo);
        ServiceCost.Validate("GST Group Code", GSTGroupCode);
        ServiceCost.Validate("HSN/SAC Code", HSNSACCode);
        ServiceCost.Modify(true);

        exit(ServiceCost.Code);
    end;

    procedure CreateResourceWithGSTDetails(
         var VATPostingSetup: Record "VAT Posting Setup";
         GSTGroupCode: Code[20];
         HSNSACCode: Code[10];
         Availment: Boolean): Code[20]
    var
        Resource: Record Resource;
    begin
        CreateZeroVATPostingSetup(VATPostingSetup);
        LibraryResource.CreateResource(Resource, VATPostingSetup."VAT Bus. Posting Group");
        Resource.Validate("GST Group Code", GSTGroupCode);
        Resource.Validate("HSN/SAC Code", HSNSACCode);
        if Availment then
            Resource.Validate("GST Credit", Resource."GST Credit"::Availment)
        else
            Resource.Validate("GST Credit", Resource."GST Credit"::"Non-Availment");
        Resource.Validate("Gen. Prod. Posting Group", GenProductPostingGroup.Code);
        Resource.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Resource.Modify(true);

        exit(Resource."No.");
    end;

    procedure CreateGLAccWithGSTDetails(
        var VATPostingSetup: Record "VAT Posting Setup";
        GSTGroupCode: Code[20];
        HSNSACCode: Code[10];
        Availment: Boolean;
        GLExempted: Boolean): Code[20]
    var
        GLAccount: Record "G/L Account";
        GLAccNo: Code[20];
    begin
        CreateZeroVATPostingSetup(VATPostingSetup);
        GLAccNo := CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code);
        GLAccount.Get(GLAccNo);
        GLAccount.Validate("GST Group Code", GSTGroupCode);
        GLAccount.Validate("HSN/SAC Code", HSNSACCode);
        if Availment then
            GLAccount.Validate("GST Credit", GLAccount."GST Credit"::Availment)
        else
            GLAccount.Validate("GST Credit", GLAccount."GST Credit"::"Non-Availment");
        GLAccount.Validate(Exempted, GLExempted);
        GLAccount.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        GLAccount.Modify(true);

        exit(GLAccNo);
    end;

    procedure CreateGLAccWithGSTDetail(
        var VATPostingSetup: Record "VAT Posting Setup";
        GSTGroupCode: Code[20];
        HSNSACCode: Code[10]): Code[20]
    var
        GLAccount: Record "G/L Account";
        GLAccNo: Code[20];
    begin
        CreateZeroVATPostingSetup(VATPostingSetup);
        GLAccNo := CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code);
        GLAccount.Get(GLAccNo);
        GLAccount.Validate("GST Group Code", GSTGroupCode);
        GLAccount.Validate("HSN/SAC Code", HSNSACCode);
        GLAccount.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        GLAccount.Modify(true);

        exit(GLAccNo);
    end;

    procedure CreateChargeItemWithGSTDetails(
            var VATPostingSetup: Record "VAT Posting Setup";
            GSTGroupCode: Code[20];
            HSNSACCode: Code[10];
            Availment: Boolean;
            Exempted: Boolean): Code[20]
    var
        ItemCharge: Record "Item Charge";
        ItemChargeNo: Code[20];
    begin
        CreateZeroVATPostingSetup(VATPostingSetup);
        ItemChargeNo := CreateChargeItem(GenProductPostingGroup.Code);
        ItemCharge.Get(ItemChargeNo);
        ItemCharge.Validate("GST Group Code", GSTGroupCode);
        ItemCharge.Validate("HSN/SAC Code", HSNSACCode);
        ItemCharge.Validate("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        if Availment then
            ItemCharge."GST Credit" := ItemCharge."GST Credit"::Availment
        else
            ItemCharge."GST Credit" := ItemCharge."GST Credit"::"Non-Availment";
        ItemCharge.Exempted := Exempted;
        ItemCharge.Modify(true);
        exit(ItemChargeNo);
    end;

    procedure CreateFixedAssetWithGSTDetails(
        var VATPostingSetup: Record "VAT Posting Setup";
        GSTGroupCode: Code[20];
        HSNSACCode: Code[10];
        Availment: Boolean;
        FAExempted: Boolean): Code[20]
    var
        FixedAsset: Record "Fixed Asset";
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        FAJournalSetup: Record "FA Journal Setup";
        FASetup: Record "FA Setup";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
    begin
        CreateZeroVATPostingSetup(VATPostingSetup);
        LibraryFixedAsset.CreateFAWithPostingGroup(FixedAsset);
        CreateDepreciationBook(DepreciationBook);
        CreateFADepreciationBook(FADepreciationBook, FixedAsset, DepreciationBook.Code);
        CreateAndUpdateFAClassSubclass(FixedAsset);

        FASetup.Get();
        FASetup.Validate("Default Depr. Book", DepreciationBook.Code);
        FASetup.Modify(true);

        LibraryFixedAsset.CreateFAJournalSetup(FAJournalSetup, DepreciationBook.Code, CopyStr(UserId, 1, 50));
        UpdateFAPostingGroupGLAccounts(FixedAsset."FA Posting Group");
        FixedAsset.Validate("GST Group Code", GSTGroupCode);
        FixedAsset.Validate("HSN/SAC Code", HSNSACCode);
        if Availment then
            FixedAsset.Validate("GST Credit", FixedAsset."GST Credit"::Availment)
        else
            FixedAsset.Validate("GST Credit", FixedAsset."GST Credit"::"Non-Availment");
        FixedAsset.Validate(Exempted, FAExempted);
        FixedAsset.Modify(true);

        CreateAndPostFAGLJnlforAquisition(FixedAsset."No.", WorkDate());
        CreateAndPostFAGLJnlforDepreciation(FixedAsset."No.", WorkDate());

        exit(FixedAsset."No.");
    end;

    procedure UpdateFAPostingGroupGLAccounts(FAPostingGroupCode: Code[20])
    var
        FAPostingGroup: Record "FA Posting Group";
    begin
        if not FAPostingGroup.Get(FAPostingGroupCode) then
            exit;

        FAPostingGroup.Validate("Acquisition Cost Account", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
        FAPostingGroup.Validate("Acq. Cost Acc. on Disposal", FAPostingGroup."Acquisition Cost Account");
        FAPostingGroup.Validate("Accum. Depreciation Account", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Accum. Depr. Acc. on Disposal", FAPostingGroup."Accum. Depreciation Account");
        FAPostingGroup.Validate("Depreciation Expense Acc.", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Gains Acc. on Disposal", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Losses Acc. on Disposal", LibraryERM.CreateGLAccountNo());
        FAPostingGroup.Validate("Sales Bal. Acc.", CreateGLAccountNo(GenBusinessPostingGroup.Code, GenProductPostingGroup.Code));
        FAPostingGroup.Modify(true);
    end;

    procedure CreateZeroVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup")
    begin
        LibraryERM.FindZeroVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
    end;

    procedure VerifyGLEntries(
        GLDocType: Enum "Gen. Journal Document Type";
        PostedDocumentNo: Code[20];
        GLCount: Integer)
    begin
        VerifyGLEntryforGST(GLDocType, PostedDocumentNo, GLCount);
    end;

    procedure CreateCurrencyCode(): Code[10]
    var
        Currency: Record Currency;
    begin
        LibraryERM.CreateCurrency(Currency);
        LibraryERM.CreateExchangeRate(Currency.Code, WorkDate(), 100, LibraryRandom.RandDecInDecimalRange(70, 80, 2));

        exit(Currency.Code);
    end;

    procedure GSTLedgerEntryCount(DocumentNo: Code[20]; ExpectedCount: Integer)
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        Assert: Codeunit Assert;
    begin
        GSTLedgerEntry.SetRange("Document No.", DocumentNo);
        Assert.RecordCount(GSTLedgerEntry, ExpectedCount);
    end;

    procedure VerifyGLEntry(JnlBatchName: Code[10]): Code[20]
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Journal Batch Name", JnlBatchName);
        GLEntry.FindFirst();

        exit(GLEntry."Document No.");
    end;

    procedure VerifyTaxTransactionForPurchase(PONo: Code[20]; DocType: Enum "Purchase Document Type")
    var
        PurchaseLine: Record "Purchase Line";
        TaxTransactionValue: Record "Tax Transaction Value";
        Assert: Codeunit Assert;
    begin
        PurchaseLine.SetRange("Document Type", DocType);
        PurchaseLine.SetRange("Document No.", PONo);
        PurchaseLine.FindFirst();

        TaxTransactionValue.Reset();
        TaxTransactionValue.SetRange("Tax Record ID", PurchaseLine.RecordId);
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        TaxTransactionValue.SetFilter(Amount, '<>%1', 0);
        TaxTransactionValue.FindFirst();

        Assert.RecordIsNotEmpty(TaxTransactionValue);
    end;

    procedure VerifyTaxTransactionForSales(SONo: Code[20]; DocType: Enum "Sales Document Type")
    var
        SalesLine: Record "Sales Line";
        TaxTransactionValue: Record "Tax Transaction Value";
        Assert: Codeunit Assert;
    begin
        SalesLine.SetRange("Document Type", DocType);
        SalesLine.SetRange("Document No.", SONo);
        SalesLine.FindFirst();

        TaxTransactionValue.Reset();
        TaxTransactionValue.SetRange("Tax Record ID", SalesLine.RecordId);
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        TaxTransactionValue.SetFilter(Amount, '<>%1', 0);
        TaxTransactionValue.FindFirst();

        Assert.RecordIsNotEmpty(TaxTransactionValue);
    end;

    procedure GetGSTRoundingPrecision(ComponentName: Code[30]): Decimal
    var
        TaxComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
        GSTRoundingPrecision: Decimal;
    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");
        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetRange(Name, ComponentName);
        TaxComponent.FindFirst();
        if TaxComponent."Rounding Precision" <> 0 then
            GSTRoundingPrecision := TaxComponent."Rounding Precision"
        else
            GSTRoundingPrecision := 1;

        exit(GSTRoundingPrecision);
    end;

    procedure GetComponentID(ComponentName: Code[30]): Decimal
    var
        GSTSetup: Record "GST Setup";
        TaxComponent: Record "Tax Component";
    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");

        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetRange(Name, ComponentName);
        if TaxComponent.FindFirst() then
            exit(TaxComponent.Id);
    end;

    procedure GetGSTAccountNo(
        GSTStateCode: Code[10];
        GSTComponentCode: Code[30];
        TransactionType: Enum "Detail Ledger Transaction Type";
        Type: Enum Type;
        GSTCredit: Enum "GST Credit";
        ISD: Boolean;
        ReceivableApplicable: Boolean;
        GSTGroupCode: Code[20]): Code[20]
    var
        GSTPostingSetup: Record "GST Posting Setup";
        TaxComponent: Record "Tax Component";
        GSTGroup: Record "GST Group";
        GSTSetup: Record "GST Setup";
        GLAcc: Code[20];
    begin
        GSTGroup.Get(GSTGroupCode);
        GSTSetup.Get();

        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetRange(Name, GSTComponentCode);
        if not TaxComponent.FindFirst() then
            exit;

        GSTPostingSetup.Get(GSTStateCode, TaxComponent.ID);
        if TransactionType = TransactionType::Sales then begin
            GSTPostingSetup.TestField("Payable Account");
            GLAcc := GSTPostingSetup."Payable Account";
        end else
            if TransactionType = TransactionType::Purchase then
                if (Type = Type::"G/L Account") and (GSTCredit = GSTCredit::"Non-Availment") then begin
                    GSTPostingSetup.TestField("Expense Account");
                    GLAcc := GSTPostingSetup."Expense Account";
                end else
                    if ReceivableApplicable then
                        if ISD then begin
                            GSTPostingSetup.TestField("Receivable Acc. (Dist)");
                            GLAcc := GSTPostingSetup."Receivable Acc. (Dist)";
                        end else begin
                            GSTPostingSetup.TestField("Receivable Account");
                            GLAcc := GSTPostingSetup."Receivable Account";
                        end
                    else
                        if not ISD then begin
                            GSTPostingSetup.TestField("Receivable Account (Interim)");
                            GLAcc := GSTPostingSetup."Receivable Account (Interim)";
                        end else
                            if GSTCredit = GSTCredit::"Non-Availment" then begin
                                GSTPostingSetup.TestField("Expense Account");
                                GLAcc := GSTPostingSetup."Expense Account";
                            end else begin
                                GSTPostingSetup.TestField("Receivable Acc. Interim (Dist)");
                                GLAcc := GSTPostingSetup."Receivable Acc. Interim (Dist)";
                            end;
        exit(GLAcc);
    end;

    procedure GetReceivableApplicable(
        GSTVendorType: Enum "GST Vendor Type";
        GSTGroupType: Enum "GST Group Type";
        GSTCredit: Enum "GST Credit";
        AssociatedEnterprises: Boolean;
        ReverseCharge: Boolean): Boolean
    begin
        if GSTCredit <> GSTCredit::Availment then
            exit;

        case GSTVendorType of
            GSTVendorType::Registered:
                begin
                    if ReverseCharge then
                        exit(false);
                    exit(true);
                end;

            GSTVendorType::Unregistered:
                if GSTGroupType = GSTGroupType::Goods then
                    exit(true);

            GSTVendorType::Import, GSTVendorType::SEZ:
                begin
                    if (GSTGroupType = GSTGroupType::Service) and not ReverseCharge then
                        exit(true);
                    if GSTGroupType = GSTGroupType::Goods then
                        exit(true);
                    exit(AssociatedEnterprises = true);
                end;
        end;
    end;

    local procedure CreateGSTAccountingPeriod()
    var
        TaxAccPeriodSetup: Record "Tax Acc. Period Setup";
        TaxAccountingPeriod: Record "Tax Accounting Period";
        GSTSetup: Record "GST Setup";
        AccPeriodStartDate: Date;
        AccPeriodEndDate: Date;
        Count: Integer;
    begin
        if not GSTSetup.Get() then
            exit;

        if not TaxAccPeriodSetup.Get(GSTSetup."GST Tax Type") then begin
            TaxAccPeriodSetup.Init();
            TaxAccPeriodSetup.Code := GSTSetup."GST Tax Type";
            TaxAccPeriodSetup.Description := 'GST Accounting Periods';
            TaxAccPeriodSetup.Insert(true);
        end;

        GetTaxAccountingDate(AccPeriodStartDate, AccPeriodEndDate);

        TaxAccountingPeriod.Reset();
        TaxAccountingPeriod.SetRange("Tax Type Code", GSTSetup."GST Tax Type");
        TaxAccountingPeriod.SetRange("Starting Date", AccPeriodStartDate);
        if not TaxAccountingPeriod.FindFirst() then
            for Count := 1 to 12 do begin
                TaxAccountingPeriod.Init();
                TaxAccountingPeriod."Tax Type Code" := GSTSetup."GST Tax Type";
                TaxAccountingPeriod.Validate("Starting Date", AccPeriodStartDate);
                TaxAccountingPeriod.Validate("Ending Date", CalcDate('<CM>', TaxAccountingPeriod."Starting Date"));
                TaxAccountingPeriod.Validate("Credit Memo Locking Date", CalcDate('<6M>', AccPeriodEndDate));
                TaxAccountingPeriod.Validate("Annual Return Filed Date", CalcDate('<6M>', AccPeriodEndDate));
                TaxAccountingPeriod."Financial Year" := FinancialYear;
                if Count = 1 then begin
                    TaxAccountingPeriod.Validate("New Fiscal Year", true);
                    TaxAccountingPeriod."Date Locked" := true;
                end;
                TaxAccountingPeriod.Quarter := GetTaxAccPeriodQuarter(Count);
                TaxAccountingPeriod.Insert();
                AccPeriodStartDate := CalcDate('<1M>', AccPeriodStartDate);
            end else begin
            TaxAccountingPeriod.Validate("Credit Memo Locking Date", CalcDate('<6M>', AccPeriodEndDate));
            TaxAccountingPeriod.Validate("Annual Return Filed Date", CalcDate('<6M>', AccPeriodEndDate));
            TaxAccountingPeriod.Modify();
            for Count := 1 to 12 do begin
                TaxAccountingPeriod.Init();
                TaxAccountingPeriod."Tax Type Code" := GSTSetup."GST Tax Type";
                TaxAccountingPeriod.Validate("Starting Date", CalcDate('<CM+1D>', AccPeriodStartDate));
                TaxAccountingPeriod.Validate("Ending Date", CalcDate('<CM>', TaxAccountingPeriod."Starting Date"));
                TaxAccountingPeriod.Validate("Credit Memo Locking Date", CalcDate('<6M>', AccPeriodEndDate));
                TaxAccountingPeriod.Validate("Annual Return Filed Date", CalcDate('<6M>', AccPeriodEndDate));
                TaxAccountingPeriod."Financial Year" := FinancialYear;
                if Count = 1 then begin
                    TaxAccountingPeriod.Validate("New Fiscal Year", true);
                    TaxAccountingPeriod."Date Locked" := true;
                end;
                TaxAccountingPeriod.Quarter := GetTaxAccPeriodQuarter(Count);
                TaxAccountingPeriod.Insert();
                AccPeriodStartDate := TaxAccountingPeriod."Starting Date";
            end;
        end;
    end;

    local procedure IsTaxAccountingPeriodEmpty(): Boolean
    var
        GSTSetup: Record "GST Setup";
        TaxType: Record "Tax Type";
        TaxAccountingPeriod: Record "Tax Accounting Period";
        AccPeriodEndDate: Date;
        AccPeriodStartDate: Date;
    begin
        if GSTSetup.Get() then
            GSTSetup.TestField(GSTSetup."GST Tax Type");

        TaxType.Get(GSTSetup."GST Tax Type");

        TaxAccountingPeriod.Reset();
        TaxAccountingPeriod.SetRange("Tax Type Code", TaxType."Accounting Period");
        TaxAccountingPeriod.SetFilter("Starting Date", '<=%1', WorkDate());
        TaxAccountingPeriod.SetFilter("Ending Date", '>=%1', WorkDate());
        if TaxAccountingPeriod.FindSet() then begin
            GetTaxAccountingDate(AccPeriodStartDate, AccPeriodEndDate);
            repeat
                TaxAccountingPeriod.Validate("Credit Memo Locking Date", CalcDate('<6M>', AccPeriodEndDate));
                TaxAccountingPeriod.Validate("Annual Return Filed Date", CalcDate('<6M>', AccPeriodEndDate));
                TaxAccountingPeriod.Modify(true);
            until TaxAccountingPeriod.Next() = 0;
        end else
            exit(true);
    end;

    local procedure GetTaxAccPeriodQuarter(Count: Integer): Code[2]
    var
        Quarter: Code[2];
    begin
        case Count of
            1 .. 3:
                Quarter := 'Q1';
            4 .. 6:
                Quarter := 'Q2';
            7 .. 9:
                Quarter := 'Q3';
            10 .. 12:
                Quarter := 'Q4';
        end;
        exit(Quarter);
    end;

    local procedure CreateDepreciationBook(var DepreciationBook: Record "Depreciation Book")
    var
        FASetup: Record "FA Setup";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
    begin
        LibraryFixedAsset.CreateDepreciationBook(DepreciationBook);
        DepreciationBook.Validate("G/L Integration - Acq. Cost", true);
        DepreciationBook.Validate("G/L Integration - Depreciation", true);
        DepreciationBook.Validate("G/L Integration - Write-Down", true);
        DepreciationBook.Validate("G/L Integration - Appreciation", true);
        DepreciationBook.Validate("G/L Integration - Custom 1", true);
        DepreciationBook.Validate("G/L Integration - Custom 2", true);
        DepreciationBook.Validate("G/L Integration - Disposal", true);
        DepreciationBook.Validate("G/L Integration - Maintenance", true);
        DepreciationBook.Modify(true);

        FASetup.Get();
        FASetup.Validate("Default Depr. Book", DepreciationBook.Code);
        FASetup.Modify(true);
    end;

    local procedure CreateFADepreciationBook(
        var FADepreciationBook: Record "FA Depreciation Book";
        var FixedAsset: Record "Fixed Asset";
        DepreciationBookCode: Code[10])
    var
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
    begin
        LibraryFixedAsset.CreateFADepreciationBook(FADepreciationBook, FixedAsset."No.", DepreciationBookCode);
        FADepreciationBook.Validate("Depreciation Starting Date", WorkDate());
        FADepreciationBook.Validate("No. of Depreciation Months", 12);
        FADepreciationBook.Validate("Acquisition Date", WorkDate());
        FADepreciationBook.Validate("G/L Acquisition Date", WorkDate());
        FADepreciationBook.Validate("FA Posting Group", FixedAsset."FA Posting Group");
        FADepreciationBook.Modify(true);
    end;

    local procedure CreateAndUpdateFAClassSubclass(var FixedAsset: Record "Fixed Asset")
    var
        FAClass: Record "FA Class";
        FASubclass: Record "FA Subclass";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
    begin
        LibraryFixedAsset.CreateFAClass(FAClass);
        LibraryFixedAsset.CreateFASubclassDetailed(FASubclass, FAClass.Code, FixedAsset."FA Posting Group");
        FixedAsset.Validate("FA Class Code", FAClass.Code);
        FixedAsset.Validate("FA Subclass Code", FASubclass.Code);
        FixedAsset.Validate("FA Location Code", CreateFALocation());
        FixedAsset.Modify(true);
    end;

    local procedure CreateFALocation(): Code[10]
    var
        FALocation: Record "FA Location";
    begin
        FALocation.Validate(Code, LibraryUtility.GenerateRandomCode(FALocation.FieldNo(Code), Database::"FA Location"));
        FALocation.Validate(Name, FALocation.Code);
        FALocation.Insert(true);
        exit(FALocation.Code);
    end;

    local procedure CreateAndPostFAGLJnlforAquisition(FixedAssetNo: Code[20]; PostingDate: Date)
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalTemplate: Record "Gen. Journal Template";
        LibraryJournals: Codeunit "Library - Journals";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryJournals.CreateGenJournalLine(GenJournalLine,
            GenJournalTemplate.Name,
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::"Fixed Asset",
            FixedAssetNo,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            CreateGLAccountWithDirectPostingNoVAT(),
            LibraryRandom.RandDecInRange(10000, 20000, 2));
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::Sale);
        GenJournalLine.Validate("FA Posting Type", GenJournalLine."FA Posting Type"::"Acquisition Cost");
        GenJournalLine.Modify(true);

        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateAndPostFAGLJnlforDepreciation(FixedAssetNo: Code[20]; PostingDate: Date)
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalTemplate: Record "Gen. Journal Template";
        LibraryJournals: Codeunit "Library - Journals";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryJournals.CreateGenJournalLine(GenJournalLine,
            GenJournalTemplate.Name,
            GenJournalBatch.Name,
            GenJournalLine."Document Type"::Payment,
            GenJournalLine."Account Type"::"Fixed Asset",
            FixedAssetNo,
            GenJournalLine."Bal. Account Type"::"G/L Account",
            CreateGLAccountWithDirectPostingNoVAT(),
            -LibraryRandom.RandDecInRange(1000, 2000, 2));
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::Sale);
        GenJournalLine.Validate("FA Posting Type", GenJournalLine."FA Posting Type"::Depreciation);
        GenJournalLine.Modify(true);

        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateGLAccountWithDirectPostingNoVAT(): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Get(LibraryERM.CreateGLAccountNoWithDirectPosting());
        GLAccount.Validate("Gen. Prod. Posting Group", GetGenProdPostingGroup());
        GLAccount.Validate("VAT Prod. Posting Group", GetNOVATProdPostingGroup());
        GLAccount.Modify();

        exit(GLAccount."No.");
    end;

    local procedure GetGenProdPostingGroup(): Code[20]
    var
        GenProdPostingGroup: Record "Gen. Product Posting Group";
    begin
        GenProdPostingGroup.FindFirst();

        exit(GenProdPostingGroup.Code);
    end;

    local procedure GetNOVATProdPostingGroup(): Code[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetRange("VAT %", 0);
        if VATPostingSetup.FindFirst() then
            exit(VATPostingSetup."VAT Prod. Posting Group");
    end;

    local procedure VerifyGLEntryforGST(
        DocumentType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
        ExpectedCount: Integer)
    var
        DummyGLEntry: Record "G/L Entry";
        LibraryAssert: Codeunit "Library Assert";
    begin
        DummyGLEntry.SetRange("Document Type", DocumentType);
        DummyGLEntry.SetRange("Document No.", DocumentNo);
        DummyGLEntry.FindFirst();
        LibraryAssert.RecordCount(DummyGLEntry, ExpectedCount);
    end;

    local procedure GetTaxAccountingDate(var AccPeriodStartDate: Date; var AccPeriodEndDate: Date)
    var
        WorkdateMonth: Integer;
        WorkDateYear: Integer;
    begin
        WorkdateMonth := Date2DMY(WorkDate(), 2);
        WorkDateYear := Date2DMY(WorkDate(), 3);
        case WorkdateMonth of
            1 .. 3:
                begin
                    AccPeriodStartDate := DMY2Date(1, 4, (WorkDateYear - 1));
                    AccPeriodEndDate := DMY2Date(31, 3, WorkDateYear);
                    FinancialYear := Format((WorkDateYear - 1)) + '-' + Format(WorkDateYear);
                end;
            4 .. 12:
                begin
                    AccPeriodStartDate := DMY2Date(1, 4, WorkDateYear);
                    AccPeriodEndDate := DMY2Date(31, 3, (WorkDateYear + 1));
                    FinancialYear := Format(WorkDateYear) + '-' + Format(WorkDateYear + 1);
                end;
        end;
    end;

    procedure CreateNoVatSetup()
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.Reset();
        VATPostingSetup.SetRange("VAT Bus. Posting Group", '');
        VATPostingSetup.SetRange("VAT Prod. Posting Group", '');
        if VATPostingSetup.IsEmpty() then begin
            VATPostingSetup.Init();
            VATPostingSetup.Validate("VAT Bus. Posting Group", '');
            VATPostingSetup.Validate("VAT Prod. Posting Group", '');
            VATPostingSetup.Validate("VAT Identifier", LibraryRandom.RandText(10));
            VATPostingSetup.Validate("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
            VATPostingSetup.Insert(true);
        end;
    end;

    procedure GetGSTPayableAccountNo(LocationCode: Code[10]; GSTComponentCode: Code[30]): Code[20]
    var
        GSTPostingSetup: Record "GST Posting Setup";
    begin
        GSTPostingSetup.Reset();
        GSTPostingSetup.SetRange("State Code", LocationCode);
        GSTPostingSetup.SetRange("Component ID", GetComponentID(GSTComponentCode));
        GSTPostingSetup.FindFirst();
        exit(GSTPostingSetup."Payable Account")
    end;

    procedure CreateCustomerParties(GSTCustomerType: enum "GST Customer Type"): Code[20]
    var
        Party: Record Party;
        CompanyInformation: Record "Company Information";
        LocationStateCode: Code[10];
        LocPANNo: Code[20];
        LocationGSTRegNo: Code[15];
    begin
        CompanyInformation.Get();
        if CompanyInformation."P.A.N. No." = '' then begin
            CompanyInformation."P.A.N. No." := CreatePANNos();
            CompanyInformation.Modify();
        end;

        LocPANNo := CompanyInformation."P.A.N. No.";
        LocationStateCode := CreateInitialSetup();
        LocationGSTRegNo := CreateGSTRegistrationNos(LocationStateCode, LocPANNo);
        CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);

        Party.Init();
        Party.Validate(Code, LibraryUtility.GenerateRandomCode(Party.FieldNo("Code"), Database::Party));
        Party.Validate(Address, CopyStr(LibraryUtility.GenerateGUID(), 1, MaxStrLen(Party.Address)));
        Party.Validate("GST Party Type", Party."GST Party Type"::Customer);
        Party.Validate("ARN No.", LibraryUtility.GenerateRandomCode(Party.FieldNo("ARN No."), Database::Party));
        Party.Validate(State, LocationStateCode);
        Party.Validate("P.A.N. No.", LocPANNo);
        Party.Validate("GST Registration No.", LocationGSTRegNo);
        Party.Validate("GST Customer Type", GSTCustomerType);
        Party.Insert(true);
        exit(Party.Code);
    end;

    procedure CreateVendorParties(GSTVendorType: enum "GST Vendor Type"): Code[20]
    var
        Party: Record Party;
        CompanyInformation: Record "Company Information";
        LocationStateCode: Code[10];
        LocPANNo: Code[20];
        LocationGSTRegNo: Code[15];
    begin
        CompanyInformation.Get();
        if CompanyInformation."P.A.N. No." = '' then begin
            CompanyInformation."P.A.N. No." := CreatePANNos();
            CompanyInformation.Modify();
        end;

        LocPANNo := CompanyInformation."P.A.N. No.";
        LocationStateCode := CreateInitialSetup();
        LocationGSTRegNo := CreateGSTRegistrationNos(LocationStateCode, LocPANNo);
        CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);

        Party.Init();
        Party.Validate(Code, LibraryUtility.GenerateRandomCode(Party.FieldNo("Code"), Database::Party));
        Party.Validate(Address, CopyStr(LibraryUtility.GenerateGUID(), 1, MaxStrLen(Party.Address)));
        Party.Validate("GST Party Type", Party."GST Party Type"::Vendor);
        Party.Validate("ARN No.", LibraryUtility.GenerateRandomCode(Party.FieldNo("ARN No."), Database::Party));
        Party.Validate(State, LocationStateCode);
        Party.Validate("P.A.N. No.", LocPANNo);
        Party.Validate("GST Registration No.", LocationGSTRegNo);
        Party.Validate("GST Vendor Type", GSTVendorType);
        Party.Insert(true);
        exit(Party.Code);
    end;

    procedure CreateGSTComponentAndPostingSetup(
        IntraState: Boolean;
        LocationStateCode: Code[10];
        TaxComponent: Record "Tax Component";
        GSTComponentCode: Text[30]);
    begin
        if not IntraState then begin
            GSTComponentCode := IGSTLbl;
            CreateGSTComponent(TaxComponent, GSTComponentCode);
            CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end else begin
            GSTComponentCode := CGSTLbl;
            CreateGSTComponent(TaxComponent, GSTComponentCode);
            CreateGSTPostingSetup(TaxComponent, LocationStateCode);

            GSTComponentCode := SGSTLbl;
            CreateGSTComponent(TaxComponent, GSTComponentCode);
            CreateGSTPostingSetup(TaxComponent, LocationStateCode);
        end;
    end;

    procedure CreateOrderAddress(var OrderAddress: Record "Order Address"; VendorNo: Code[20]): Code[10]
    var
        PostCode: Record "Post Code";
    begin
        LibraryERM.CreatePostCode(PostCode);
        OrderAddress.Init();
        OrderAddress.Validate("Vendor No.", VendorNo);
        OrderAddress.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(OrderAddress.FieldNo(Code), DATABASE::"Order Address"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Order Address", OrderAddress.FieldNo(Code))));
        OrderAddress.Validate(Name, LibraryUtility.GenerateRandomText(MaxStrLen(OrderAddress.Name)));
        OrderAddress.Validate(Address, LibraryUtility.GenerateRandomText(MaxStrLen(OrderAddress.Address)));
        OrderAddress.Validate("Post Code", PostCode.Code);
        OrderAddress.Insert(true);
        exit(OrderAddress.Code);
    end;

    procedure VerifyGLEntryAmount(
        GLDocType: Enum "Gen. Journal Document Type";
        PostedDocumentNo: Code[20];
        GLAccountNo: Code[20];
        Amount: Decimal)
    var
        GLEntry: Record "G/L Entry";
        GeneralLedgerSetup: Record "General Ledger Setup";
        Assert: Codeunit Assert;
    begin
        GLEntry.SetRange("Document Type", GLDocType);
        GLEntry.SetRange("Document No.", PostedDocumentNo);
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        GLEntry.FindFirst();

        Assert.AreNearlyEqual(Amount, GLEntry.Amount, GeneralLedgerSetup."Inv. Rounding Precision (LCY)",
        StrSubstNo(AmountLEVerifyErr, GLEntry.FieldCaption("Amount"), GLEntry.TableCaption));
    end;
}