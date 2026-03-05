/// <summary>
/// Provides utility functions for creating and managing dimensions, dimension values, and dimension sets in test scenarios.
/// </summary>
codeunit 131001 "Library - Dimension"
{

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibraryDim: Codeunit "Library - Dimension";
        ChangeGlobalDimensions: Codeunit "Change Global Dimensions";

    procedure BlockDimension(var Dimension: Record Dimension)
    begin
        Dimension.Validate(Blocked, true);
        Dimension.Modify(true);
    end;

    procedure BlockDimensionValue(var DimensionValue: Record "Dimension Value")
    begin
        DimensionValue.Validate(Blocked, true);
        DimensionValue.Modify(true);
    end;

    procedure InitGlobalDimChange()
    begin
        ChangeGlobalDimensions.ResetState();
    end;

    procedure RunChangeGlobalDimensions(GlobalDimension1Code: Code[20]; GlobalDimension2Code: Code[20])
    var
        ChangeGlobalDimHeader: Record "Change Global Dim. Header";
    begin
        InitGlobalDimChange();
        ChangeGlobalDimHeader.Get();
        ChangeGlobalDimHeader.Validate("Global Dimension 1 Code", GlobalDimension1Code);
        ChangeGlobalDimHeader.Validate("Global Dimension 2 Code", GlobalDimension2Code);
        ChangeGlobalDimHeader.Modify();
        ChangeGlobalDimensions.StartSequential();
    end;

    procedure RunChangeGlobalDimensionsParallel(GlobalDimension1Code: Code[20]; GlobalDimension2Code: Code[20])
    var
        ChangeGlobalDimHeader: Record "Change Global Dim. Header";
        ChangeGlobalDimLogEntry: Record "Change Global Dim. Log Entry";
        LibraryDimension: Codeunit "Library - Dimension";
    begin
        InitGlobalDimChange();
        ChangeGlobalDimHeader.Get();
        ChangeGlobalDimHeader."Parallel Processing" := true;
        ChangeGlobalDimHeader.Validate("Global Dimension 1 Code", GlobalDimension1Code);
        ChangeGlobalDimHeader.Validate("Global Dimension 2 Code", GlobalDimension2Code);
        ChangeGlobalDimHeader.Modify();
        BindSubscription(LibraryDimension); // to mock taks scheduling and single session
        ChangeGlobalDimensions.Prepare();
        ChangeGlobalDimensions.Start();
        if ChangeGlobalDimensions.FindTablesForScheduling(ChangeGlobalDimLogEntry) then
            repeat
                CODEUNIT.Run(CODEUNIT::"Change Global Dimensions", ChangeGlobalDimLogEntry);
            until ChangeGlobalDimLogEntry.Next() = 0;
        InitGlobalDimChange();
    end;

    procedure CreateDimension(var Dimension: Record Dimension)
    begin
        Dimension.Init();
        Dimension.Validate(
          Code, LibraryUtility.GenerateRandomCode20(Dimension.FieldNo(Code), DATABASE::Dimension));
        Dimension.Insert(true);
    end;

    procedure CreateDimensionCombination(var DimensionCombination: Record "Dimension Combination"; Dimension1Code: Code[20]; Dimension2Code: Code[20])
    begin
        DimensionCombination.Init();
        DimensionCombination.Validate("Dimension 1 Code", Dimension1Code);
        DimensionCombination.Validate("Dimension 2 Code", Dimension2Code);
        DimensionCombination.Insert(true);
    end;

    procedure CreateDimensionValue(var DimensionValue: Record "Dimension Value"; DimensionCode: Code[20])
    begin
        DimensionValue.Init();
        DimensionValue.Validate("Dimension Code", DimensionCode);
        DimensionValue.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(DimensionValue.FieldNo(Code), DATABASE::"Dimension Value"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Dimension Value", DimensionValue.FieldNo(Code))));
        DimensionValue.Insert(true);
    end;

    procedure CreateDimensionValueWithCode(var DimensionValue: Record "Dimension Value"; DimensionValueCode: Code[20]; DimensionCode: Code[20])
    begin
        DimensionValue.Init();
        DimensionValue.Validate("Dimension Code", DimensionCode);
        DimensionValue.Validate(Code,
          CopyStr(DimensionValueCode, 1, LibraryUtility.GetFieldLength(DATABASE::"Dimension Value", DimensionValue.FieldNo(Code))));
        DimensionValue.Insert(true);
    end;

    procedure CreateDimWithDimValue(var DimensionValue: Record "Dimension Value")
    var
        Dimension: Record Dimension;
    begin
        CreateDimension(Dimension);
        CreateDimensionValue(DimensionValue, Dimension.Code);
    end;

    procedure CreateDimValueCombination(var DimensionValueCombination: Record "Dimension Value Combination"; Dimension1Code: Code[20]; Dimension2Code: Code[20]; Dimension1ValueCode: Code[20]; Dimension2ValueCode: Code[20])
    begin
        DimensionValueCombination.Init();
        DimensionValueCombination.Validate("Dimension 1 Code", Dimension1Code);
        DimensionValueCombination.Validate("Dimension 1 Value Code", Dimension1ValueCode);
        DimensionValueCombination.Validate("Dimension 2 Code", Dimension2Code);
        DimensionValueCombination.Validate("Dimension 2 Value Code", Dimension2ValueCode);
        DimensionValueCombination.Insert(true);
    end;

    procedure CreateDefaultDimension(var DefaultDimension: Record "Default Dimension"; TableID: Integer; No: Code[20]; DimensionCode: Code[20]; DimensionValueCode: Code[20])
    begin
        DefaultDimension.Init();
        DefaultDimension.Validate("Table ID", TableID);
        DefaultDimension.Validate("No.", No);
        DefaultDimension.Validate("Dimension Code", DimensionCode);
        DefaultDimension.Validate("Dimension Value Code", DimensionValueCode);
        DefaultDimension.Insert(true);
    end;

    procedure CreateDefaultDimensionPriority(var DefaultDimensionPriority: Record "Default Dimension Priority"; SourceCode: Code[10]; TableID: Integer)
    begin
        DefaultDimensionPriority.Init();
        DefaultDimensionPriority.Validate("Source Code", SourceCode);
        DefaultDimensionPriority.Validate("Table ID", TableID);
        DefaultDimensionPriority.Insert(true);
    end;

    procedure CreateICDimension(var ICDimension: Record "IC Dimension")
    begin
        ICDimension.Init();
        ICDimension.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(ICDimension.FieldNo(Code), DATABASE::"IC Dimension"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"IC Dimension", ICDimension.FieldNo(Code))));
        ICDimension.Insert(true);
    end;

    procedure CreateICDimensionValue(var ICDimensionValue: Record "IC Dimension Value"; ICDimensionCode: Code[20])
    begin
        ICDimensionValue.Init();
        ICDimensionValue.Validate("Dimension Code", ICDimensionCode);
        ICDimensionValue.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(ICDimensionValue.FieldNo(Code), DATABASE::"IC Dimension Value"), 1,
            LibraryUtility.GetFieldLength(DATABASE::"IC Dimension Value", ICDimensionValue.FieldNo(Code))));
        ICDimensionValue.Insert(true);
    end;

    procedure CreateAndMapICDimFromDim(var ICDimension: Record "IC Dimension"; DimensionCode: Code[20])
    begin
        ICDimension.Init();
        ICDimension.Validate(Code, DimensionCode);
        ICDimension.Validate("Map-to Dimension Code", DimensionCode);
        ICDimension.Insert(true);
    end;

    procedure CreateAndMapICDimValueFromDimValue(var ICDimensionValue: Record "IC Dimension Value"; DimensionValueCode: Code[20]; DimensionCode: Code[20])
    begin
        ICDimensionValue.Init();
        ICDimensionValue.Validate("Dimension Code", DimensionCode);
        ICDimensionValue.Validate(Code, DimensionValueCode);
        ICDimensionValue.Validate("Map-to Dimension Code", DimensionCode);
        ICDimensionValue.Validate("Map-to Dimension Value Code", DimensionValueCode);
        ICDimensionValue.Insert(true);
    end;

    procedure CreateServiceContractDimension(var ServiceContractHeader: Record "Service Contract Header"; DimensionCode: Code[20]; DimensionValueCode: Code[20])
    var
        DimSetID: Integer;
    begin
        DimSetID := CreateDimSet(ServiceContractHeader."Dimension Set ID", DimensionCode, DimensionValueCode);
        ServiceContractHeader.Validate("Dimension Set ID", DimSetID);
        ServiceContractHeader.Modify(true);
    end;

    procedure CreateAccTypeDefaultDimension(var DefaultDimension: Record "Default Dimension"; TableID: Integer; DimensionCode: Code[20]; DimensionValueCode: Code[20]; ValuePosting: Enum "Default Dimension Value Posting Type")
    begin
        CreateDefaultDimension(DefaultDimension, TableID, ' ', DimensionCode, DimensionValueCode);
        DefaultDimension.Validate("Value Posting", ValuePosting);
        DefaultDimension.Modify(true);
    end;

    procedure CreateDefaultDimensionCustomer(var DefaultDimension: Record "Default Dimension"; CustomerNo: Code[20]; DimensionCode: Code[20]; DimensionValueCode: Code[20])
    begin
        CreateDefaultDimension(DefaultDimension, DATABASE::Customer, CustomerNo, DimensionCode, DimensionValueCode);
    end;

    procedure CreateDefaultDimensionGLAcc(var DefaultDimension: Record "Default Dimension"; GLAccountNo: Code[20]; DimensionCode: Code[20]; DimensionValueCode: Code[20])
    begin
        CreateDefaultDimension(DefaultDimension, DATABASE::"G/L Account", GLAccountNo, DimensionCode, DimensionValueCode);
    end;

    procedure CreateDefaultDimensionItem(var DefaultDimension: Record "Default Dimension"; ItemNo: Code[20]; DimensionCode: Code[20]; DimensionValueCode: Code[20])
    begin
        CreateDefaultDimension(DefaultDimension, DATABASE::Item, ItemNo, DimensionCode, DimensionValueCode);
    end;

    procedure CreateDefaultDimensionResource(var DefaultDimension: Record "Default Dimension"; ResourceNo: Code[20]; DimensionCode: Code[20]; DimensionValueCode: Code[20])
    begin
        CreateDefaultDimension(DefaultDimension, DATABASE::Resource, ResourceNo, DimensionCode, DimensionValueCode);
    end;

    procedure CreateDefaultDimensionVendor(var DefaultDimension: Record "Default Dimension"; VendorNo: Code[20]; DimensionCode: Code[20]; DimensionValueCode: Code[20])
    begin
        CreateDefaultDimension(DefaultDimension, DATABASE::Vendor, VendorNo, DimensionCode, DimensionValueCode);
    end;

    procedure CreateDefaultDimensionWithNewDimValue(var DefaultDimension: Record "Default Dimension"; TableID: Integer; No: Code[20]; ValuePosting: Enum "Default Dimension Value Posting Type")
    var
        DimValue: Record "Dimension Value";
    begin
        CreateDimWithDimValue(DimValue);
        CreateDefaultDimension(DefaultDimension, TableID, No, DimValue."Dimension Code", DimValue.Code);
        DefaultDimension.Validate("Value Posting", ValuePosting);
        DefaultDimension.Modify(true);
    end;

    procedure CreateSelectedDimension(var SelectedDimension: Record "Selected Dimension"; ObjectType: Option; ObjectID: Integer; AnalysisViewCode: Code[10]; DimensionCode: Text[30])
    begin
        Clear(SelectedDimension);
        SelectedDimension."User ID" := CopyStr(UserId(), 1, MaxStrLen(SelectedDimension."User ID"));
        SelectedDimension.Validate("Object Type", ObjectType);
        SelectedDimension.Validate("Object ID", ObjectID);
        SelectedDimension.Validate("Analysis View Code", AnalysisViewCode);
        SelectedDimension.Validate("Dimension Code", DimensionCode);
        SelectedDimension.Insert(true);
    end;

    procedure CreateDimensionsTemplate(var DimensionsTemplate: Record "Dimensions Template"; TemplateCode: Code[10]; TableID: Integer; DimensionCode: Code[20]; DimensionValueCode: Code[20])
    begin
        DimensionsTemplate.Init();
        DimensionsTemplate.Validate(
          Code,
          CopyStr(
            LibraryUtility.GenerateRandomCode(DimensionsTemplate.FieldNo(Code), DATABASE::"Dimensions Template"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Dimensions Template", DimensionsTemplate.FieldNo(Code))));
        DimensionsTemplate.Validate("Master Record Template Code", TemplateCode);
        DimensionsTemplate.Validate("Dimension Code", DimensionCode);
        DimensionsTemplate.Validate("Dimension Value Code", DimensionValueCode);
        DimensionsTemplate.Validate("Table Id", TableID);
        DimensionsTemplate.SetRange("Master Record Template Code", DimensionsTemplate."Master Record Template Code");
        DimensionsTemplate.Insert(true);
    end;

    procedure EditDimSet(DimSetID: Integer; DimCode: Code[20]; DimValCode: Code[20]): Integer
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimVal: Record "Dimension Value";
        DimMgt: Codeunit DimensionManagement;
        NewDimSetID: Integer;
    begin
        // Edit existing dimension value for the given dimension on document, document line and journal
        // DimSetID: existing dimension set ID on document, document line and journal
        // Return new Dimension Set ID.

        DimMgt.GetDimensionSet(TempDimSetEntry, DimSetID);

        DimVal.Get(DimCode, DimValCode);
        TempDimSetEntry.SetRange("Dimension Code", DimVal."Dimension Code");
        TempDimSetEntry.FindFirst();
        TempDimSetEntry.Validate("Dimension Value Code", DimVal.Code);
        TempDimSetEntry.Validate("Dimension Value ID", DimVal."Dimension Value ID");
        TempDimSetEntry.Modify(true);

        TempDimSetEntry.Reset();
        NewDimSetID := DimMgt.GetDimensionSetID(TempDimSetEntry);
        TempDimSetEntry.DeleteAll();
        exit(NewDimSetID);
    end;

    procedure DeleteDimSet(DimSetID: Integer; DimCode: Code[20]): Integer
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
        NewDimSetID: Integer;
    begin
        // Delete existing dimension and dimension value on document, document line and journal
        // DimSetID: existing dimension set ID on document, document line and journal
        // Return new Dimension Set ID.

        DimMgt.GetDimensionSet(TempDimSetEntry, DimSetID);

        TempDimSetEntry.SetRange("Dimension Code", DimCode);
        TempDimSetEntry.FindFirst();
        TempDimSetEntry.Delete(true);

        TempDimSetEntry.Reset();
        NewDimSetID := DimMgt.GetDimensionSetID(TempDimSetEntry);
        TempDimSetEntry.DeleteAll();
        exit(NewDimSetID);
    end;

    procedure CreateDimSet(DimSetID: Integer; DimCode: Code[20]; DimValCode: Code[20]): Integer
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimVal: Record "Dimension Value";
        DimMgt: Codeunit DimensionManagement;
        NewDimSetID: Integer;
    begin
        // Insert new dimension and dimension value on document, document line and journal
        // DimSetID: existing dimension set ID on document, document line and journal
        // Return new Dimension Set ID.

        DimMgt.GetDimensionSet(TempDimSetEntry, DimSetID);
        DimVal.Get(DimCode, DimValCode);

        TempDimSetEntry.Validate("Dimension Code", DimVal."Dimension Code");
        TempDimSetEntry.Validate("Dimension Value Code", DimValCode);
        TempDimSetEntry.Validate("Dimension Value ID", DimVal."Dimension Value ID");
        TempDimSetEntry.Insert(true);

        NewDimSetID := DimMgt.GetDimensionSetID(TempDimSetEntry);
        TempDimSetEntry.DeleteAll();
        exit(NewDimSetID);
    end;

    procedure FindDefaultDimension(var DefaultDimension: Record "Default Dimension"; TableID: Integer; No: Code[20]): Boolean
    begin
        DefaultDimension.SetRange("Table ID", TableID);
        DefaultDimension.SetRange("No.", No);
        exit(DefaultDimension.FindSet());
    end;

    procedure FindDimension(var Dimension: Record Dimension)
    begin
        Dimension.SetRange(Blocked, false);
        Dimension.FindSet();
    end;

    procedure FindDimensionValue(var DimensionValue: Record "Dimension Value"; DimensionCode: Code[20])
    begin
        DimensionValue.SetRange("Dimension Code", DimensionCode);
        DimensionValue.SetRange(Blocked, false);
        DimensionValue.SetRange("Dimension Value Type", DimensionValue."Dimension Value Type"::Standard);
        DimensionValue.FindSet();
    end;

    procedure FindDifferentDimensionValue(DimensionCode: Code[20]; DimensionValueCode: Code[20]): Code[20]
    var
        DimensionValue: Record "Dimension Value";
    begin
        DimensionValue.SetFilter(Code, '<>%1', DimensionValueCode);
        FindDimensionValue(DimensionValue, DimensionCode);
        exit(DimensionValue.Code);
    end;

    procedure FindDimensionSetEntry(var DimensionSetEntry: Record "Dimension Set Entry"; DimensionSetID: Integer)
    begin
        DimensionSetEntry.SetRange("Dimension Set ID", DimensionSetID);
        DimensionSetEntry.FindSet();
    end;

    procedure GetNextDimensionValue(var DimensionValue: Record "Dimension Value")
    begin
        DimensionValue.Next();
    end;

    [Scope('OnPrem')]
    procedure GetLocalTablesWithDimSetIDValidationIgnored(var CountOfTablesIgnored: Integer)
    begin
        OnGetLocalTablesWithDimSetIDValidationIgnored(CountOfTablesIgnored);
    end;

    procedure ResetDefaultDimensions(TableID: Integer; No: Code[20])
    var
        DefaultDimension: Record "Default Dimension";
    begin
        DefaultDimension.SetRange("Table ID", TableID);
        DefaultDimension.SetRange("No.", No);
        DefaultDimension.DeleteAll();
    end;

    procedure GetGlobalDimCodeValue(DimNo: Integer; var DimValue: Record "Dimension Value")
    var
        Dimension: Record Dimension;
    begin
        if LibraryERM.GetGlobalDimensionCode(DimNo) = '' then begin
            LibraryDim.CreateDimension(Dimension);
            LibraryERM.SetGlobalDimensionCode(DimNo, Dimension.Code);
            LibraryDim.CreateDimensionValue(DimValue, Dimension.Code);
        end else begin
            DimValue.SetRange("Dimension Code", LibraryERM.GetGlobalDimensionCode(DimNo));
            DimValue.SetRange("Dimension Value Type", DimValue."Dimension Value Type"::Standard);
            DimValue.SetRange(Blocked, false);
            DimValue.FindFirst();
        end;
    end;

    procedure VerifyShorcutDimCodesUpdatedOnDimSetIDValidation(var TempAllObj: Record AllObj temporary; "Record": Variant; DimSetIDFieldID: Integer; ShortcutDimCode1FieldID: Integer; ShortcutDimCode2FieldID: Integer; DimSetID: Integer; ExpectedShortcutDimCode1: Code[20]; ExpectedShortcutDimCode2: Code[20])
    var
        RecRef: RecordRef;
        DimSetIDFieldRef: FieldRef;
        ShortcutDim1CodeFieldRef: FieldRef;
        ShortcutDim2CodeFieldRef: FieldRef;
    begin
        RecRef.GetTable(Record);

        TempAllObj."Object Type" := TempAllObj."Object Type"::Table;
        TempAllObj."Object ID" := RecRef.Number;
        TempAllObj.Insert();

        DimSetIDFieldRef := RecRef.Field(DimSetIDFieldID);
        DimSetIDFieldRef.Validate(DimSetID);

        ShortcutDim1CodeFieldRef := RecRef.Field(ShortcutDimCode1FieldID);
        ShortcutDim1CodeFieldRef.TestField(ExpectedShortcutDimCode1);
        ShortcutDim2CodeFieldRef := RecRef.Field(ShortcutDimCode2FieldID);
        ShortcutDim2CodeFieldRef.TestField(ExpectedShortcutDimCode2);
    end;

    [Scope('OnPrem')]
    procedure VerifyShorcutDimCodesUpdatedOnDimSetIDValidationLocal(var TempAllObj: Record AllObj temporary; DimSetID: Integer; GlobalDim1ValueCode: Code[20]; GlobalDim2ValueCode: Code[20])
    begin
        OnVerifyShorcutDimCodesUpdatedOnDimSetIDValidationLocal(TempAllObj, DimSetID, GlobalDim1ValueCode, GlobalDim2ValueCode);
    end;

    [Scope('OnPrem')]
    procedure GetTableNosWithGlobalDimensionCode(var TableBuffer: Record "Integer" temporary)
    begin
        AddTable(TableBuffer, DATABASE::"Salesperson/Purchaser");
        AddTable(TableBuffer, DATABASE::"G/L Account");
        AddTable(TableBuffer, DATABASE::Customer);
        AddTable(TableBuffer, DATABASE::Vendor);
        AddTable(TableBuffer, DATABASE::Item);
        AddTable(TableBuffer, DATABASE::"Resource Group");
        AddTable(TableBuffer, DATABASE::Resource);
        AddTable(TableBuffer, DATABASE::Job);
        AddTable(TableBuffer, DATABASE::"Bank Account");
        AddTable(TableBuffer, DATABASE::"Cash Flow Manual Revenue");
        AddTable(TableBuffer, DATABASE::"Cash Flow Manual Expense");
        AddTable(TableBuffer, DATABASE::Campaign);
        AddTable(TableBuffer, DATABASE::Employee);
        AddTable(TableBuffer, DATABASE::"Fixed Asset");
        AddTable(TableBuffer, DATABASE::Insurance);
        AddTable(TableBuffer, DATABASE::"Responsibility Center");
        AddTable(TableBuffer, DATABASE::"Item Charge");

        OnGetTableNosWithGlobalDimensionCode(TableBuffer);
    end;

    procedure ChunkDimSetFilters(var TempDimensionSetEntry: Record "Dimension Set Entry" temporary): List of [Text]
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        exit(DimensionManagement.ChunkDimSetFilters(TempDimensionSetEntry));
    end;

    procedure AddTable(var TableBuffer: Record "Integer" temporary; TableID: Integer)
    begin
        if not TableBuffer.Get(TableID) then begin
            TableBuffer.Number := TableID;
            TableBuffer.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Change Global Dimensions", 'OnBeforeScheduleTask', '', false, false)]
    local procedure OnBeforeScheduleTask(TableNo: Integer; var DoNotScheduleTask: Boolean; var TaskID: Guid)
    begin
        DoNotScheduleTask := true;
        TaskID := CreateGuid();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Change Global Dimensions", 'OnCountingActiveSessions', '', false, false)]
    local procedure OnCountingActiveSessionsHandler(var IsCurrSessionActiveOnly: Boolean)
    begin
        IsCurrSessionActiveOnly := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetLocalTablesWithDimSetIDValidationIgnored(var CountOfTablesIgnored: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnVerifyShorcutDimCodesUpdatedOnDimSetIDValidationLocal(var TempAllObj: Record AllObj temporary; DimSetID: Integer; GlobalDim1ValueCode: Code[20]; GlobalDim2ValueCode: Code[20])
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnGetTableNosWithGlobalDimensionCode(var TableBuffer: Record "Integer" temporary)
    begin
    end;
}

