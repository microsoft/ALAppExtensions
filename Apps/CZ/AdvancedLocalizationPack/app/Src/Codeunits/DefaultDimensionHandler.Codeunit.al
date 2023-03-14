codeunit 31392 "Default Dimension Handler CZA"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure TestAutomaticCreateOnAfterValidateNo(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; CurrFieldNo: Integer)
    begin
        if Rec."No." <> '' then
            Rec.TestField(Rec."Automatic Create CZA", false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterValidateEvent', 'Value Posting', false, false)]
    local procedure TestAutomaticCreateOnAfterValidateValuePosting(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; CurrFieldNo: Integer)
    begin
        if not (Rec."Value Posting" in [Rec."Value Posting"::"Code Mandatory", Rec."Value Posting"::"Same Code"]) then
            Rec.TestField(Rec."Automatic Create CZA", false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"DimensionManagement", 'OnBeforeUpdateDefaultDim', '', false, false)]
    local procedure AutoCreateValueOnBeforeUpdateDefaultDim(TableID: Integer; No: Code[20]; var GlobalDim1Code: Code[20]; var GlobalDim2Code: Code[20]; var IsHandled: Boolean);
    var
        DimensionAutoCreateMgt: Codeunit "Dimension Auto.Create Mgt. CZA";
    begin
        DimensionAutoCreateMgt.AutoCreateDimension(TableID, No);
    end;
#if not CLEAN19
#pragma warning disable AL0432

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterValidateEvent', 'Automatic Create CZA', false, false)]
    local procedure TestSetupOnAfterValidateAutoCreateCZA(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; CurrFieldNo: Integer)
    begin
        if (not Rec.IsTemporary) and (CurrFieldNo <> 0) then
            TestSetupFieldsDuplicityCZA(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterValidateEvent', 'Dim. Description Field ID CZA', false, false)]
    local procedure TestSetupAppOnAfterValidateDescrFieldIDCZA(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; CurrFieldNo: Integer)
    begin
        if (not Rec.IsTemporary) and (CurrFieldNo <> 0) then
            TestSetupFieldsDuplicityCZA(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterValidateEvent', 'Dim. Description Update CZA', false, false)]
    local procedure TestSetupAppOnAfterValidateDescrUpdateCZA(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; CurrFieldNo: Integer)
    begin
        if (not Rec.IsTemporary) and (CurrFieldNo <> 0) then
            TestSetupFieldsDuplicityCZA(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterValidateEvent', 'Dim. Description Format CZA', false, false)]
    local procedure TestSetupAppOnAfterValidateDescrFormatCZA(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; CurrFieldNo: Integer)
    begin
        if (not Rec.IsTemporary) and (CurrFieldNo <> 0) then
            TestSetupFieldsDuplicityCZA(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterValidateEvent', 'Auto. Create Value Posting CZA', false, false)]
    local procedure TestSetupAppOnAfterValidateAutoValuePostingCZA(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; CurrFieldNo: Integer)
    begin
        if (not Rec.IsTemporary) and (CurrFieldNo <> 0) then
            TestSetupFieldsDuplicityCZA(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterValidateEvent', 'Automatic Create', false, false)]
    local procedure TestSetupOnAfterValidateAutoCreate(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; CurrFieldNo: Integer)
    begin
        if (not Rec.IsTemporary) and (CurrFieldNo <> 0) then
            TestSetupFieldsDuplicityBaseApp(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterValidateEvent', 'Dimension Description Field ID', false, false)]
    local procedure TestSetupAppOnAfterValidateDescrFieldID(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; CurrFieldNo: Integer)
    begin
        if (not Rec.IsTemporary) and (CurrFieldNo <> 0) then
            TestSetupFieldsDuplicityBaseApp(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterValidateEvent', 'Dimension Description Update', false, false)]
    local procedure TestSetupAppOnAfterValidateDescrUpdate(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; CurrFieldNo: Integer)
    begin
        if (not Rec.IsTemporary) and (CurrFieldNo <> 0) then
            TestSetupFieldsDuplicityBaseApp(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterValidateEvent', 'Dimension Description Format', false, false)]
    local procedure TestSetupAppOnAfterValidateDescrFormat(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; CurrFieldNo: Integer)
    begin
        if (not Rec.IsTemporary) and (CurrFieldNo <> 0) then
            TestSetupFieldsDuplicityBaseApp(Rec, CurrFieldNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterValidateEvent', 'Automatic Cr. Value Posting', false, false)]
    local procedure TestSetupAppOnAfterValidateAutoValuePosting(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; CurrFieldNo: Integer)
    begin
        if (not Rec.IsTemporary) and (CurrFieldNo <> 0) then
            TestSetupFieldsDuplicityBaseApp(Rec, CurrFieldNo);
    end;

    local procedure TestSetupFieldsDuplicityCZA(var DefaultDimension: Record "Default Dimension"; CurrFieldNo: Integer)
    var
        CurrentModuleInfo: ModuleInfo;
        BaseAppDuplicityErr: Label 'You cannot set %1 in %2 if the same field is set in Base Application.', Comment = '%1 = Field Caption, %2 = Application Name';
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);

        case CurrFieldNo of
            DefaultDimension.FieldNo("Automatic Create CZA"):
                if DefaultDimension."Automatic Create CZA" and DefaultDimension."Automatic Create" then
                    Error(BaseAppDuplicityErr, DefaultDimension.FieldCaption("Automatic Create CZA"), CurrentModuleInfo.Name);

            DefaultDimension.FieldNo("Dim. Description Field ID CZA"):
                if (DefaultDimension."Dim. Description Field ID CZA" <> 0) and (DefaultDimension."Dimension Description Field ID" <> 0) then
                    Error(BaseAppDuplicityErr, DefaultDimension.FieldCaption("Dim. Description Field ID CZA"), CurrentModuleInfo.Name);

            DefaultDimension.FieldNo("Dim. Description Update CZA"):
                if (DefaultDimension."Dim. Description Update CZA" <> DefaultDimension."Dim. Description Update CZA"::" ") and
                    (DefaultDimension."Dimension Description Update" <> DefaultDimension."Dimension Description Update"::" ")
                then
                    Error(BaseAppDuplicityErr, DefaultDimension.FieldCaption("Dim. Description Update CZA"), CurrentModuleInfo.Name);

            DefaultDimension.FieldNo("Dim. Description Format CZA"):
                if (DefaultDimension."Dim. Description Format CZA" <> '') and (DefaultDimension."Dimension Description Format" <> '') then
                    Error(BaseAppDuplicityErr, DefaultDimension.FieldCaption("Dim. Description Format CZA"), CurrentModuleInfo.Name);

            DefaultDimension.FieldNo("Auto. Create Value Posting CZA"):
                if (DefaultDimension."Auto. Create Value Posting CZA" <> DefaultDimension."Auto. Create Value Posting CZA"::" ") and
                    (DefaultDimension."Automatic Cr. Value Posting" <> DefaultDimension."Automatic Cr. Value Posting"::" ")
                then
                    Error(BaseAppDuplicityErr, DefaultDimension.FieldCaption("Auto. Create Value Posting CZA"), CurrentModuleInfo.Name);
        end;
    end;

    local procedure TestSetupFieldsDuplicityBaseApp(var DefaultDimension: Record "Default Dimension"; CurrFieldNo: Integer)
    var
        CurrentModuleInfo: ModuleInfo;
        BaseAppDuplicityErr: Label 'You cannot set %1 in Base Application if the same field is set in %2.', Comment = '%1 = Field Caption, %2 = Application Name';
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);

        case CurrFieldNo of
            DefaultDimension.FieldNo("Automatic Create"):
                if DefaultDimension."Automatic Create CZA" and DefaultDimension."Automatic Create" then
                    Error(BaseAppDuplicityErr, DefaultDimension.FieldCaption("Automatic Create"), CurrentModuleInfo.Name);

            DefaultDimension.FieldNo("Dimension Description Field ID"):
                if (DefaultDimension."Dim. Description Field ID CZA" <> 0) and (DefaultDimension."Dimension Description Field ID" <> 0) then
                    Error(BaseAppDuplicityErr, DefaultDimension.FieldCaption("Dimension Description Field ID"), CurrentModuleInfo.Name);

            DefaultDimension.FieldNo("Dimension Description Update"):
                if (DefaultDimension."Dim. Description Update CZA" <> DefaultDimension."Dim. Description Update CZA"::" ") and
                    (DefaultDimension."Dimension Description Update" <> DefaultDimension."Dimension Description Update"::" ")
                then
                    Error(BaseAppDuplicityErr, DefaultDimension.FieldCaption("Dimension Description Update"), CurrentModuleInfo.Name);

            DefaultDimension.FieldNo("Dimension Description Format"):
                if (DefaultDimension."Dim. Description Format CZA" <> '') and (DefaultDimension."Dimension Description Format" <> '') then
                    Error(BaseAppDuplicityErr, DefaultDimension.FieldCaption("Dimension Description Format"), CurrentModuleInfo.Name);

            DefaultDimension.FieldNo("Automatic Cr. Value Posting"):
                if (DefaultDimension."Auto. Create Value Posting CZA" <> DefaultDimension."Auto. Create Value Posting CZA"::" ") and
                    (DefaultDimension."Automatic Cr. Value Posting" <> DefaultDimension."Automatic Cr. Value Posting"::" ")
                then
                    Error(BaseAppDuplicityErr, DefaultDimension.FieldCaption("Automatic Cr. Value Posting"), CurrentModuleInfo.Name);
        end;
    end;
#pragma warning restore AL0432
#endif

    [EventSubscriber(ObjectType::Table, Database::"Default Dimension", 'OnAfterModifyEvent', '', false, false)]
    local procedure AutomaticCreateOnAfterModifyEvent(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension")
    begin
        if Rec."Automatic Create CZA" then
            DimensionAutoUpdateMgtCZA.ForceSetDimChangeSetupRead();
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnAfterInsertEvent', '', false, false)]
    local procedure ItemOnAfterInsertEvent(var Rec: Record Item)
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunItemOnAfterInsertEventDefaultDim() then
            UpdateReferenceIds(Database::Item, Rec."No.")
    end;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterInsertEvent', '', false, false)]
    local procedure CustomerOnAfterInsertEvent(var Rec: Record Customer)
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunCustomerOnAfterInsertEventDefaultDim() then
            UpdateReferenceIds(Database::Customer, Rec."No.")
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnAfterInsertEvent', '', false, false)]
    local procedure VendorOnAfterInsertEvent(var Rec: Record Vendor)
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunVendorOnAfterInsertEventDefaultDim() then
            UpdateReferenceIds(Database::Vendor, Rec."No.")
    end;

    [EventSubscriber(ObjectType::Table, Database::Employee, 'OnAfterInsertEvent', '', false, false)]
    local procedure EmployeeOnAfterInsertEvent(var Rec: Record Employee)
    begin
        if Rec.IsTemporary then
            exit;
        if DimensionAutoUpdateMgtCZA.IsRequestRunEmployeeOnAfterInsertEventDefaultDim() then
            UpdateReferenceIds(Database::Employee, Rec."No.")
    end;

    local procedure UpdateReferenceIds(TableID: Integer; No: Code[20])
    var
        DefaultDimension: Record "Default Dimension";
    begin
        DefaultDimension.SetRange("Table ID", TableID);
        DefaultDimension.SetRange("No.", No);
        if DefaultDimension.FindSet(true) then
            repeat
                DefaultDimension.UpdateReferencedIds()
            until DefaultDimension.Next() = 0;

        case TableID of
            Database::Customer:
                DimensionAutoUpdateMgtCZA.SetRequestRunCustomerOnAfterInsertEvent(false);
            Database::Vendor:
                DimensionAutoUpdateMgtCZA.SetRequestRunVendorOnAfterInsertEvent(false);
            Database::Item:
                DimensionAutoUpdateMgtCZA.SetRequestRunItemOnAfterInsertEvent(false);
            Database::Employee:
                DimensionAutoUpdateMgtCZA.SetRequestRunEmployeeOnAfterInsertEvent(false);
        end;
    end;

    var
        DimensionAutoUpdateMgtCZA: Codeunit "Dimension Auto.Update Mgt. CZA";

}
