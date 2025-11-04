/// <summary>
/// Provides utility functions for creating and managing price calculation setup and testing various pricing scenarios.
/// </summary>
codeunit 130510 "Library - Price Calculation"
{

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        LibraryPriceCalculation: Codeunit "Library - Price Calculation";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LastHandlerId: Enum "Price Calculation Handler";
        DefaultPriceListTok: Label 'Default price list.';

    procedure AddSetup(var PriceCalculationSetup: Record "Price Calculation Setup"; NewMethod: Enum "Price Calculation Method"; PriceType: Enum "Price Type"; AssetType: Enum "Price Asset Type"; NewImplementation: Enum "Price Calculation Handler"; NewDefault: Boolean): Code[100];
    begin
        PriceCalculationSetup.Init();
        PriceCalculationSetup.Method := NewMethod;
        PriceCalculationSetup.Type := PriceType;
        PriceCalculationSetup."Asset Type" := AssetType;
        PriceCalculationSetup.Implementation := NewImplementation;
        PriceCalculationSetup.Default := NewDefault;
        PriceCalculationSetup.Enabled := true;
        PriceCalculationSetup.Insert(true);
        exit(PriceCalculationSetup.Code)
    end;

    procedure AddDtldSetup(var DtldPriceCalculationSetup: Record "Dtld. Price Calculation Setup"; PriceType: Enum "Price Type"; AssetType: Enum "Price Asset Type"; AssetNo: code[20]; SourceGroup: Enum "Price Source Group"; SourceNo: Code[20])
    begin
        if DtldPriceCalculationSetup.IsTemporary then
            DtldPriceCalculationSetup."Line No." += 1
        else
            DtldPriceCalculationSetup."Line No." := 0;
        DtldPriceCalculationSetup.Type := PriceType;
        DtldPriceCalculationSetup."Asset Type" := AssetType;
        DtldPriceCalculationSetup."Asset No." := AssetNo;
        DtldPriceCalculationSetup.Validate("Source Group", SourceGroup);
        DtldPriceCalculationSetup."Source No." := SourceNo;
        DtldPriceCalculationSetup.Enabled := true;
        DtldPriceCalculationSetup.Insert(true);
    end;

    procedure AddDtldSetup(var DtldPriceCalculationSetup: Record "Dtld. Price Calculation Setup"; SetupCode: Code[100]; AssetNo: code[20]; SourceGroup: Enum "Price Source Group"; SourceNo: Code[20])
    begin
        if DtldPriceCalculationSetup.IsTemporary then
            DtldPriceCalculationSetup."Line No." += 1
        else
            DtldPriceCalculationSetup."Line No." := 0;
        DtldPriceCalculationSetup.Validate("Setup Code", SetupCode);
        DtldPriceCalculationSetup."Asset No." := AssetNo;
        DtldPriceCalculationSetup.Validate("Source Group", SourceGroup);
        DtldPriceCalculationSetup."Source No." := SourceNo;
        DtldPriceCalculationSetup.Enabled := true;
        DtldPriceCalculationSetup.Insert(true);
    end;

    procedure DisableSetup(var PriceCalculationSetup: Record "Price Calculation Setup")
    begin
        PriceCalculationSetup.Enabled := false;
        PriceCalculationSetup.Modify();
    end;

    procedure DisableDtldSetup(var DtldPriceCalculationSetup: Record "Dtld. Price Calculation Setup")
    begin
        DtldPriceCalculationSetup.Enabled := false;
        DtldPriceCalculationSetup.Modify();
    end;

    procedure DisableExtendedPriceCalculation()
    begin
        // turn off ExtendedPriceCalculationEnabledHandler
        UnbindSubscription(LibraryPriceCalculation);
    end;

    procedure EnableExtendedPriceCalculation()
    begin
        // turn on ExtendedPriceCalculationEnabledHandler
        UnbindSubscription(LibraryPriceCalculation);
        BindSubscription(LibraryPriceCalculation);
    end;

    procedure EnableExtendedPriceCalculation(Enable: Boolean)
    begin
        // turn on/off ExtendedPriceCalculationEnabledHandler
        UnbindSubscription(LibraryPriceCalculation);
        if Enable then
            BindSubscription(LibraryPriceCalculation);
    end;

    procedure SetupDefaultHandler(NewImplementation: Enum "Price Calculation Handler") xImplementation: Enum "Price Calculation Handler";
    var
        PriceCalculationSetup: Record "Price Calculation Setup";
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
    begin
        if LastHandlerId = NewImplementation then
            exit;
        PriceCalculationSetup.SetRange(Default, true);
        if PriceCalculationSetup.FindFirst() then
            xImplementation := PriceCalculationSetup.Implementation
        else
            xImplementation := NewImplementation;

        PriceCalculationSetup.Reset();
        PriceCalculationSetup.DeleteAll();
        PriceCalculationMgt.Run();
        PriceCalculationSetup.Modifyall(Default, false);

        PriceCalculationSetup.SetRange(Implementation, NewImplementation);
        PriceCalculationSetup.Modifyall(Default, true, true);

        LastHandlerId := NewImplementation;
    end;

    procedure AllowEditingActiveSalesPrice()
    begin
        AllowEditingActiveSalesPrice(true);
    end;

    local procedure AllowEditingActiveSalesPrice(AllowEditingActivePrice: Boolean)
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Allow Editing Active Price" := AllowEditingActivePrice;
        SalesReceivablesSetup.Modify();
    end;

    procedure AllowEditingActivePurchPrice()
    begin
        AllowEditingActivePurchPrice(true);
    end;

    local procedure AllowEditingActivePurchPrice(AllowEditingActivePrice: Boolean)
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup."Allow Editing Active Price" := AllowEditingActivePrice;
        PurchasesPayablesSetup.Modify();
    end;

    procedure DisallowEditingActiveSalesPrice()
    begin
        AllowEditingActiveSalesPrice(false);
    end;

    procedure DisallowEditingActivePurchPrice()
    begin
        AllowEditingActivePurchPrice(false);
    end;

    local procedure CreateDefaultPriceList(PriceType: Enum "Price Type"; SourceGroup: Enum "Price Source Group"): Code[20]
    var
        PriceListHeader: Record "Price List Header";
    begin
        PriceListHeader.Validate("Price Type", PriceType);
        PriceListHeader.Validate("Source Group", SourceGroup);
        PriceListHeader.Description := DefaultPriceListTok;
        case SourceGroup of
            SourceGroup::Customer:
                PriceListHeader.Validate("Source Type", PriceListHeader."Source Type"::"All Customers");
            SourceGroup::Vendor:
                PriceListHeader.Validate("Source Type", PriceListHeader."Source Type"::"All Vendors");
            SourceGroup::Job:
                PriceListHeader.Validate("Source Type", PriceListHeader."Source Type"::"All Jobs");
        end;
        PriceListHeader."Allow Updating Defaults" := true;
        PriceListHeader.Status := "Price Status"::Active;
        if PriceListHeader.Insert(true) then
            exit(PriceListHeader.Code);
    end;

    procedure SetDefaultPriceList(PriceType: Enum "Price Type"; SourceGroup: Enum "Price Source Group") DefaultPriceListCode: Code[20];
    begin
        case SourceGroup of
            SourceGroup::Customer:
                DefaultPriceListCode := DefineSalesDefaultPriceList();
            SourceGroup::Vendor:
                DefaultPriceListCode := DefinePurchDefaultPriceList();
            SourceGroup::Job:
                DefaultPriceListCode := DefineJobDefaultPriceList(PriceType);
        end
    end;

    local procedure DefineJobDefaultPriceList(PriceType: Enum "Price Type") DefaultPriceListCode: Code[20];
    var
        JobsSetup: Record "Jobs Setup";
    begin
        JobsSetup.Get();
        DefaultPriceListCode := CreateDefaultPriceList(PriceType, "Price Source Group"::Job);
        case PriceType of
            PriceType::Purchase:
                JobsSetup."Default Purch Price List Code" := DefaultPriceListCode;
            PriceType::Sale:
                JobsSetup."Default Sales Price List Code" := DefaultPriceListCode;
        end;
        JobsSetup.Modify();
    end;

    local procedure DefinePurchDefaultPriceList() DefaultPriceListCode: Code[20];
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        DefaultPriceListCode := CreateDefaultPriceList("Price Type"::Purchase, "Price Source Group"::Vendor);
        PurchasesPayablesSetup."Default Price List Code" := DefaultPriceListCode;
        PurchasesPayablesSetup."Allow Editing Active Price" := true;
        PurchasesPayablesSetup.Modify();
    end;

    local procedure DefineSalesDefaultPriceList() DefaultPriceListCode: Code[20];
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        DefaultPriceListCode := CreateDefaultPriceList("Price Type"::Sale, "Price Source Group"::Customer);
        SalesReceivablesSetup."Default Price List Code" := DefaultPriceListCode;
        SalesReceivablesSetup."Allow Editing Active Price" := true;
        SalesReceivablesSetup.Modify();
        exit(SalesReceivablesSetup."Default Price List Code");
    end;

    procedure ClearDefaultPriceList(PriceType: Enum "Price Type"; SourceGroup: Enum "Price Source Group")
    var
        JobsSetup: Record "Jobs Setup";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        case SourceGroup of
            SourceGroup::Job:
                begin
                    JobsSetup.Get();
                    case PriceType of
                        PriceType::Purchase:
                            JobsSetup."Default Purch Price List Code" := '';
                        PriceType::Sale:
                            JobsSetup."Default Sales Price List Code" := '';
                    end;
                    JobsSetup.Modify();
                end;
            SourceGroup::Vendor:
                begin
                    PurchasesPayablesSetup.Get();
                    PurchasesPayablesSetup."Default Price List Code" := '';
                    PurchasesPayablesSetup.Modify();
                end;
            SourceGroup::Customer:
                begin
                    SalesReceivablesSetup.Get();
                    SalesReceivablesSetup."Default Price List Code" := '';
                    SalesReceivablesSetup.Modify();
                end;
        end;
    end;

    procedure SetUseCustomLookup(NewValue: Boolean) OldValue: Boolean;
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        OldValue := SalesReceivablesSetup."Use Customized Lookup";
        if OldValue = NewValue then
            exit;
        SalesReceivablesSetup."Use Customized Lookup" := NewValue;
        SalesReceivablesSetup.Modify();
    end;

    procedure SetMethodInSalesSetup()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Price Calculation Method" := SalesReceivablesSetup."Price Calculation Method"::"Lowest Price";
        SalesReceivablesSetup.Modify();
    end;

    procedure SetMethodInPurchSetup()
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup."Price Calculation Method" := PurchasesPayablesSetup."Price Calculation Method"::"Lowest Price";
        PurchasesPayablesSetup.Modify();
    end;

    procedure CreatePriceHeader(var PriceListHeader: Record "Price List Header"; PriceType: Enum "Price Type"; SourceType: Enum "Price Source Type"; SourceNo: code[20])
    begin
        PriceListHeader.Init();
        PriceListHeader.Code := LibraryUtility.GenerateGUID();
        PriceListHeader.Description := StrSubstNo('%1%2', PriceListHeader.FieldName(Description), PriceListHeader.Code);
        PriceListHeader."Price Type" := PriceType;
        PriceListHeader.Validate("Source Type", SourceType);
        PriceListHeader.Validate("Source No.", SourceNo);
        PriceListHeader.Insert(true);
    end;

    procedure CreatePriceHeader(var PriceListHeader: Record "Price List Header"; PriceType: Enum "Price Type"; SourceType: Enum "Price Source Type"; ParentSourceNo: code[20]; SourceNo: code[20])
    begin
        PriceListHeader.Init();
        PriceListHeader.Code := LibraryUtility.GenerateGUID();
        PriceListHeader.Description := StrSubstNo('%1%2', PriceListHeader.FieldName(Description), PriceListHeader.Code);
        PriceListHeader."Price Type" := PriceType;
        PriceListHeader.Validate("Source Type", SourceType);
        PriceListHeader.Validate("Parent Source No.", ParentSourceNo);
        PriceListHeader.Validate("Source No.", SourceNo);
        PriceListHeader.Insert(true);
    end;

    procedure CreatePriceListLine(var PriceListLine: Record "Price List Line"; PriceListHeader: Record "Price List Header"; AmountType: Enum "Price Amount Type"; AssetType: enum "Price Asset Type"; AssetNo: Code[20])
    begin
        CreatePriceListLine(
            PriceListLine,
            PriceListHeader.Code, PriceListHeader."Price Type",
            PriceListHeader."Source Type", PriceListHeader."Parent Source No.", PriceListHeader."Source No.",
            AmountType, AssetType, AssetNo);
    end;

    procedure CreatePriceListLine(var PriceListLine: Record "Price List Line"; PriceListCode: Code[20]; PriceType: Enum "Price Type"; SourceType: Enum "Price Source Type"; SourceNo: Code[20]; AmountType: Enum "Price Amount Type"; AssetType: enum "Price Asset Type"; AssetNo: Code[20])
    begin
        // to skip blank "Parent Source No."
        CreatePriceListLine(
            PriceListLine, PriceListCode, PriceType, SourceType, '', SourceNo, AmountType, AssetType, AssetNo);
    end;

    procedure CreatePriceListLine(var PriceListLine: Record "Price List Line"; PriceListCode: Code[20]; PriceType: Enum "Price Type"; SourceType: Enum "Price Source Type"; ParentSourceNo: Code[20]; SourceNo: Code[20]; AmountType: Enum "Price Amount Type"; AssetType: enum "Price Asset Type"; AssetNo: Code[20])
    begin
        PriceListLine.Init();
        PriceListLine."Line No." := 0;
        PriceListLine."Price List Code" := PriceListCode;
        PriceListLine."Price Type" := PriceType;
        PriceListLine.Validate("Source Type", SourceType);
        PriceListLine.Validate("Parent Source No.", ParentSourceNo);
        PriceListLine.Validate("Source No.", SourceNo);
        PriceListLine.Validate("Asset Type", AssetType);
        PriceListLine.Validate("Asset No.", AssetNo);
        PriceListLine.Validate("Amount Type", AmountType);
        if AmountType in [AmountType::Discount, AmountType::Any] then
            PriceListLine.Validate("Line Discount %", LibraryRandom.RandDec(100, 2));
        if AmountType in [AmountType::Price, AmountType::Any] then
            case PriceType of
                PriceType::Sale:
                    PriceListLine.Validate("Unit Price", LibraryRandom.RandDec(1000, 2));
                PriceType::Purchase:
                    PriceListLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(1000, 2));
            end;
        PriceListLine.Insert(true);
    end;

    procedure CreatePurchDiscountLine(var PriceListLine: Record "Price List Line"; PriceListCode: Code[20]; SourceType: Enum "Price Source Type"; SourceNo: code[20];
                                                                                                                            AssetType: enum "Price Asset Type";
                                                                                                                            AssetNo: Code[20])
    begin
        CreatePriceListLine(
            PriceListLine, PriceListCode, PriceListLine."Price Type"::Purchase, SourceType, SourceNo,
            PriceListLine."Amount Type"::Discount, AssetType, AssetNo);
    end;

    procedure CreatePurchPriceLine(var PriceListLine: Record "Price List Line"; PriceListCode: Code[20]; SourceType: Enum "Price Source Type"; SourceNo: code[20];
                                                                                                                         AssetType: enum "Price Asset Type";
                                                                                                                         AssetNo: Code[20])
    begin
        CreatePriceListLine(
            PriceListLine, PriceListCode, PriceListLine."Price Type"::Purchase, SourceType, SourceNo,
            PriceListLine."Amount Type"::Price, AssetType, AssetNo);
    end;

    procedure CreateSalesDiscountLine(var PriceListLine: Record "Price List Line"; PriceListCode: Code[20]; SourceType: Enum "Price Source Type"; SourceNo: code[20];
                                                                                                                            AssetType: enum "Price Asset Type";
                                                                                                                            AssetNo: Code[20])
    begin
        CreatePriceListLine(
            PriceListLine, PriceListCode, PriceListLine."Price Type"::Sale, SourceType, SourceNo,
            PriceListLine."Amount Type"::Discount, AssetType, AssetNo);
    end;

    procedure CreateSalesPriceLine(var PriceListLine: Record "Price List Line"; PriceListCode: Code[20]; SourceType: Enum "Price Source Type"; SourceNo: code[20];
                                                                                                                         AssetType: enum "Price Asset Type";
                                                                                                                         AssetNo: Code[20])
    begin
        CreatePriceListLine(
            PriceListLine, PriceListCode, PriceListLine."Price Type"::Sale, SourceType, SourceNo,
            PriceListLine."Amount Type"::Price, AssetType, AssetNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Price Calculation Mgt.", 'OnIsExtendedPriceCalculationEnabled', '', false, false)]
    procedure ExtendedPriceCalculationEnabledHandler(var Result: Boolean);
    begin
        Result := true;
    end;
}