codeunit 4776 "Contoso Fixed Asset"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Depreciation Book" = rim,
        tabledata "FA Class" = rim,
        tabledata "FA Subclass" = rim,
        tabledata "FA Location" = rim,
        tabledata "FA Posting Group" = rim,
        tabledata "Fixed Asset" = rim,
        tabledata "Main Asset Component" = rim,
        tabledata Maintenance = rim,
        tabledata "Maintenance Registration" = rim,
        tabledata "FA Journal Setup" = rim,
        tabledata "FA Journal Template" = rim,
        tabledata "FA Journal Batch" = rim,
        tabledata "Insurance Journal Template" = rim,
        tabledata "Insurance Journal Batch" = rim,
        tabledata Insurance = rim,
        tabledata "Insurance Type" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertDepreciationBook(BookCode: Code[10]; Description: Text[100]; AcqCost: Boolean; Depreciation: Boolean; WriteDown: Boolean; Appreciation: Boolean; Custom1: Boolean; Custom2: Boolean; Disposal: Boolean; Maintenance: Boolean; UseRoundingInPeriodicDepr: Boolean; DefaultFinalRoundingAmount: Decimal)
    var
        DepreciationBook: Record "Depreciation Book";
        Exists: Boolean;
    begin
        if DepreciationBook.Get(BookCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        DepreciationBook.Validate(Code, BookCode);
        DepreciationBook.Validate(Description, Description);
        DepreciationBook.Validate("G/L Integration - Acq. Cost", AcqCost);
        DepreciationBook.Validate("G/L Integration - Depreciation", Depreciation);
        DepreciationBook.Validate("G/L Integration - Write-Down", WriteDown);
        DepreciationBook.Validate("G/L Integration - Appreciation", Appreciation);
        DepreciationBook.Validate("G/L Integration - Custom 1", Custom1);
        DepreciationBook.Validate("G/L Integration - Custom 2", Custom2);
        DepreciationBook.Validate("G/L Integration - Disposal", Disposal);
        DepreciationBook.Validate("G/L Integration - Maintenance", Maintenance);
        DepreciationBook.Validate("Use Rounding in Periodic Depr.", UseRoundingInPeriodicDepr);
        DepreciationBook.Validate("Default Final Rounding Amount", DefaultFinalRoundingAmount);

        if Exists then
            DepreciationBook.Modify(true)
        else
            DepreciationBook.Insert(true);
    end;

    procedure InsertFAClass(ClassCode: Code[10]; Name: Text[50])
    var
        FAClass: Record "FA Class";
        Exists: Boolean;
    begin
        if FAClass.Get(ClassCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        FAClass.Validate(Code, ClassCode);
        FAClass.Validate(Name, Name);

        if Exists then
            FAClass.Modify(true)
        else
            FAClass.Insert(true);
    end;

    procedure InsertFASubClass(SubClassCode: Code[10]; Name: Text[50]; ClassCode: Code[10]; PostingGroup: Code[20])
    var
        FASubClass: Record "FA Subclass";
        Exists: Boolean;
    begin
        if FASubClass.Get(SubClassCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        FASubClass.Validate(Code, SubClassCode);
        FASubClass.Validate(Name, Name);
        FASubClass.Validate("FA Class Code", ClassCode);
        FASubClass.Validate("Default FA Posting Group", PostingGroup);

        if Exists then
            FASubClass.Modify(true)
        else
            FASubClass.Insert(true);
    end;

    procedure InsertFALocation(LocationCode: Code[10]; Name: Text[50])
    var
        FALocation: Record "FA Location";
        Exists: Boolean;
    begin
        if FALocation.Get(LocationCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        FALocation.Validate(Code, LocationCode);
        FALocation.Validate(Name, Name);

        if Exists then
            FALocation.Modify(true)
        else
            FALocation.Insert(true);
    end;

    procedure InsertFAPostingGroup(GroupCode: Code[20]; AcquisitionCostAccount: Code[20]; AccumDepreciationAccount: Code[20]; AcqCostAccOnDisposal: Code[20]; AccumDeprAccOnDisposal: Code[20]; GainsAccOnDisposal: Code[20]; LossesAccOnDisposal: Code[20]; MaintenanceExpenseAccount: Code[20]; DepreciationExpenseAcc: Code[20]; AcquisitionCostBalAcc: Code[20])
    var
        FAPostingGroup: Record "FA Posting Group";
        Exists: Boolean;
    begin
        if FAPostingGroup.Get(GroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        FAPostingGroup.Validate(Code, GroupCode);
        FAPostingGroup.Validate("Acquisition Cost Account", AcquisitionCostAccount);
        FAPostingGroup.Validate("Accum. Depreciation Account", AccumDepreciationAccount);
        FAPostingGroup.Validate("Acq. Cost Acc. on Disposal", AcqCostAccOnDisposal);
        FAPostingGroup.Validate("Accum. Depr. Acc. on Disposal", AccumDeprAccOnDisposal);
        FAPostingGroup.Validate("Gains Acc. on Disposal", GainsAccOnDisposal);
        FAPostingGroup.Validate("Losses Acc. on Disposal", LossesAccOnDisposal);
        FAPostingGroup.Validate("Maintenance Expense Account", MaintenanceExpenseAccount);
        FAPostingGroup.Validate("Depreciation Expense Acc.", DepreciationExpenseAcc);
        FAPostingGroup.Validate("Acquisition Cost Bal. Acc.", AcquisitionCostBalAcc);

        if Exists then
            FAPostingGroup.Modify(true)
        else
            FAPostingGroup.Insert(true);
    end;

    procedure InsertFixedAsset(FANo: Code[20]; Description: Text[100]; FAClassCode: Code[10]; FASubclassCode: Code[20]; FALocationCode: Code[10]; MainAssetComponent: Enum "FA Component Type"; SerialNo: Text[30]; NextServiceDate: Date; VendorNo: Code[20]; MaintenanceVendorNo: Code[20])
    var
        FixedAsset: Record "Fixed Asset";
        Exists: Boolean;
    begin
        if FixedAsset.Get(FANo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        FixedAsset.Validate("No.", FANo);
        FixedAsset.Validate(Description, Description);
        FixedAsset.Validate("FA Class Code", FAClassCode);
        FixedAsset.Validate("FA Subclass Code", FASubclassCode);
        FixedAsset.Validate("FA Location Code", FALocationCode);
        FixedAsset.Validate("Main Asset/Component", MainAssetComponent);
        FixedAsset.Validate("Serial No.", SerialNo);
        if NextServiceDate <> 0D then
            FixedAsset.Validate("Next Service Date", NextServiceDate);
        FixedAsset.Validate("Vendor No.", VendorNo);
        FixedAsset.Validate("Maintenance Vendor No.", MaintenanceVendorNo);

        if Exists then
            FixedAsset.Modify(true)
        else
            FixedAsset.Insert(true);
    end;

    procedure InsertMainAssetComponent(MainAssetNo: Code[20]; FANo: Code[20])
    var
        MainAssetComponent: Record "Main Asset Component";
        FixedAsset: Record "Fixed Asset";
        Exists: Boolean;
    begin
        if MainAssetComponent.Get(MainAssetNo, FANo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        MainAssetComponent.Validate("Main Asset No.", MainAssetNo);
        MainAssetComponent.Validate("FA No.", FANo);

        FixedAsset.Get(FANo);
        MainAssetComponent.Validate(Description, FixedAsset.Description);

        if Exists then
            MainAssetComponent.Modify(true)
        else
            MainAssetComponent.Insert(true);
    end;

    procedure InsertMaintenance(MaintenanceCode: Code[10]; Description: Text[100])
    var
        Maintenance: Record Maintenance;
        Exists: Boolean;
    begin
        if Maintenance.Get(MaintenanceCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Maintenance.Validate(Code, MaintenanceCode);
        Maintenance.Validate(Description, Description);

        if Exists then
            Maintenance.Modify(true)
        else
            Maintenance.Insert(true);
    end;

    procedure InsertFAMaintenanceRegistration(FANo: Code[20]; ServiceDate: Date; Comment: Text[50]; ServiceAgentName: Text[30])
    var
        FixedAsset: Record "Fixed Asset";
        MaintenanceRegistration: Record "Maintenance Registration";
    begin
        FixedAsset.Get(FANo);

        MaintenanceRegistration.Init();
        MaintenanceRegistration.Validate("FA No.", FANo);
        MaintenanceRegistration."Line No." := GetNextMaintenanceRegistrationLineNo(FANo);
        MaintenanceRegistration.Validate("Service Date", ServiceDate);
        MaintenanceRegistration.Validate("Maintenance Vendor No.", FixedAsset."Maintenance Vendor No.");
        MaintenanceRegistration.Validate(Comment, Comment);
        MaintenanceRegistration.Validate("Service Agent Name", ServiceAgentName);
        MaintenanceRegistration.Insert(true);
    end;

    procedure InsertFAJournalSetup(CreateByUserId: Code[20]; DepreciationBookCode: Code[10]; FAJnlTemplateName: Code[10]; FAJnlBatchName: Code[10]; GenJnlTemplateName: Code[10]; GenJnlBatchName: Code[10]; InsuranceJnlTemplateName: Code[10]; InsuranceJnlBatchName: Code[10])
    var
        FAJournalSetup: Record "FA Journal Setup";
        Exists: Boolean;
    begin
        if FAJournalSetup.Get(DepreciationBookCode, CreateByUserId) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        FAJournalSetup.Validate("User ID", CreateByUserId);
        FAJournalSetup.Validate("Depreciation Book Code", DepreciationBookCode);
        FAJournalSetup.Validate("FA Jnl. Template Name", FAJnlTemplateName);
        FAJournalSetup.Validate("FA Jnl. Batch Name", FAJnlBatchName);
        FAJournalSetup.Validate("Gen. Jnl. Template Name", GenJnlTemplateName);
        FAJournalSetup.Validate("Gen. Jnl. Batch Name", GenJnlBatchName);
        FAJournalSetup.Validate("Insurance Jnl. Template Name", InsuranceJnlTemplateName);
        FAJournalSetup.Validate("Insurance Jnl. Batch Name", InsuranceJnlBatchName);

        if Exists then
            FAJournalSetup.Modify(true)
        else
            FAJournalSetup.Insert(true);
    end;

    procedure InsertFAJournalTemplate(Name: Code[10]; Description: Text[80]; NoSeriesCode: Code[20]; Recurring: Boolean)
    var
        FAJournalTemplate: Record "FA Journal Template";
        Exists: Boolean;
    begin
        if FAJournalTemplate.Get(Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        FAJournalTemplate.Validate(Name, Name);
        FAJournalTemplate.Validate(Description, Description);
        FAJournalTemplate.Validate(Recurring, Recurring);

        if Recurring then
            FAJournalTemplate.Validate("Posting No. Series", NoSeriesCode)
        else
            FAJournalTemplate.Validate("No. Series", NoSeriesCode);

        if Exists then
            FAJournalTemplate.Modify(true)
        else
            FAJournalTemplate.Insert(true);
    end;

    procedure InsertFAJournalBatch(JnlTemplateName: Code[10]; Name: Code[10]; Description: Text[50])
    var
        FAJournalBatch: Record "FA Journal Batch";
        Exists: Boolean;
    begin
        if FAJournalBatch.Get(JnlTemplateName, Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        FAJournalBatch.Validate("Journal Template Name", JnlTemplateName);
        FAJournalBatch.SetupNewBatch();
        FAJournalBatch.Validate(Name, Name);
        FAJournalBatch.Validate(Description, Description);

        if Exists then
            FAJournalBatch.Modify(true)
        else
            FAJournalBatch.Insert(true);
    end;

    procedure InsertInsuranceJournalTemplate(Name: Code[10]; Description: Text[80]; NoSeriesCode: Code[20])
    var
        InsuranceJournalTemplate: Record "Insurance Journal Template";
        Exists: Boolean;
    begin
        if InsuranceJournalTemplate.Get(Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        InsuranceJournalTemplate.Validate(Name, Name);
        InsuranceJournalTemplate.Validate(Description, Description);
        InsuranceJournalTemplate.Validate("No. Series", NoSeriesCode);

        if Exists then
            InsuranceJournalTemplate.Modify(true)
        else
            InsuranceJournalTemplate.Insert(true);
    end;

    procedure InsertInsuranceJournalBatch(TemplateName: Code[10]; Name: Code[10]; Description: Text[100])
    var
        InsuranceJournalBatch: Record "Insurance Journal Batch";
        Exists: Boolean;
    begin
        if InsuranceJournalBatch.Get(TemplateName, Name) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        InsuranceJournalBatch.Validate("Journal Template Name", TemplateName);
        InsuranceJournalBatch.SetupNewBatch();
        InsuranceJournalBatch.Validate(Name, Name);
        InsuranceJournalBatch.Validate(Description, Description);

        if Exists then
            InsuranceJournalBatch.Modify(true)
        else
            InsuranceJournalBatch.Insert(true);
    end;

    procedure InsertInsurance(No: Code[20]; Description: Text[100]; EffectiveDate: Date; PolicyNo: Text[30]; AnnualPremium: Decimal; PolicyCoverage: Decimal; InsuranceType: Code[10]; FAClassCode: Code[10]; FASubclassCode: Code[10])
    var
        Insurance: Record Insurance;
        Exists: Boolean;
    begin
        if Insurance.Get(No) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Insurance.Validate("No.", No);
        Insurance.Validate(Description, Description);
        Insurance.Validate("Effective Date", EffectiveDate);
        Insurance.Validate("Policy No.", PolicyNo);
        Insurance.Validate("Annual Premium", AnnualPremium);
        Insurance.Validate("Policy Coverage", PolicyCoverage);
        Insurance.Validate("Insurance Type", InsuranceType);
        Insurance.Validate("FA Class Code", FAClassCode);
        Insurance.Validate("FA Subclass Code", FASubclassCode);

        if Exists then
            Insurance.Modify(true)
        else
            Insurance.Insert(true);
    end;

    procedure InsertInsuranceType(Code: Code[10]; Description: Text[100])
    var
        InsuranceType: Record "Insurance Type";
        Exists: Boolean;
    begin
        if InsuranceType.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        InsuranceType.Validate(Code, Code);
        InsuranceType.Validate(Description, Description);

        if Exists then
            InsuranceType.Modify(true)
        else
            InsuranceType.Insert(true);
    end;

    local procedure GetNextMaintenanceRegistrationLineNo(FANo: Code[20]): Integer
    var
        MaintenanceRegistration: Record "Maintenance Registration";
    begin
        MaintenanceRegistration.SetRange("FA No.", FANo);
        if MaintenanceRegistration.FindLast() then
            exit(MaintenanceRegistration."Line No." + 10000)
        else
            exit(10000);
    end;
}