namespace Microsoft.SubscriptionBilling;

using System.IO;

codeunit 139888 "Generic Import Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    Access = Internal;

    local procedure Reset()
    begin
        ClearAll();
        UsageBasedBTestLibrary.ResetUsageBasedRecords();
    end;

    procedure CreateGenericImportSettings(SupplierNo: Code[20])
    begin
        GenericImportSettings.Init();
        GenericImportSettings."Usage Data Supplier No." := SupplierNo;
        GenericImportSettings.Insert(true);
    end;

    [Test]
    procedure ExpectErrorWhenDataExchangeDefinitionIsNotGenericImportForGenericImportSettings()
    var
        DataExchDef: Record "Data Exch. Def";
        SupplierNo: Code[20];
        DataExchDefType: Enum "Data Exchange Definition Type";
        Ordinal: Integer;
        ListOfOrdinals: List of [Integer];
    begin
        //[GIVEN] Error for validating "Data Exchange Definition" for "Data Exchange Definition Type" different than "Generic Import"
        Reset();
        SupplierNo := CopyStr(LibraryRandom.RandText(20), 1, MaxStrLen(SupplierNo));
        CreateGenericImportSettings(SupplierNo);

        ListOfOrdinals := "Data Exchange Definition Type".Ordinals();
        foreach Ordinal in ListOfOrdinals do begin
            DataExchDefType := "Data Exchange Definition Type".FromInteger(Ordinal);
            CreateDataExchangeDef(DataExchDef, DataExchDefType);
            if DataExchDefType = "Data Exchange Definition Type"::"Generic Import" then
                GenericImportSettings.Validate("Data Exchange Definition", DataExchDef.Code)
            else
                asserterror GenericImportSettings.Validate("Data Exchange Definition", DataExchDef.Code);
        end;
    end;

    [Test]
    procedure TestIfRelatedDataIsDeletedOnDeleteUsageDataImport()
    begin
        Reset();
        j := LibraryRandom.RandIntInRange(2, 10);
        for i := 1 to j do begin
            CreateSimpleUsageDataImport();
            CreateSimpleUsageDataBlob();
            CreateSimpleUsageDataGenericImport();
        end;

        UsageDataImport.Reset();
        UsageDataImport.FindSet();
        repeat
            UsageDataBlob.Reset();
            UsageDataBlob.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
            UsageDataBlob.FindFirst();
            UsageDataGenericImport.Reset();
            UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
            UsageDataGenericImport.FindFirst();
            UsageDataImport.Delete(true);
            // Commit before asserterror to keep data
            Commit();
            asserterror UsageDataBlob.FindFirst();
            asserterror UsageDataGenericImport.FindFirst();
        until UsageDataImport.Next() = 0;
    end;


    [Test]
    procedure TestIfRelatedDataIsDeletedOnActionDeleteUsageDataBillingLines()
    begin
        Reset();
        CreateSimpleUsageDataImport();
        CreateSimpleUsageDataGenericImport();
        CreateSimpleUsageDataBilling();

        UsageDataBilling.Reset();
        UsageDataBilling.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataBilling.FindFirst();
        UsageDataGenericImport.Reset();
        UsageDataGenericImport.SetRange("Usage Data Import Entry No.", UsageDataImport."Entry No.");
        UsageDataImport.DeleteUsageDataBillingLines();

        asserterror UsageDataBilling.FindFirst();
        asserterror UsageDataGenericImport.FindFirst();
    end;

    local procedure CreateDataExchangeDef(var DataExchDef: Record "Data Exch. Def"; DataExchDefType: Enum "Data Exchange Definition Type")
    begin
        LibraryPaymentFormat.CreateDataExchDef(DataExchDef, 0, 0, 0, 0, 0, 0);
        DataExchDef.Validate(Type, DataExchDefType);
        DataExchDef.Modify(false);
    end;

    local procedure CreateSimpleUsageDataImport()
    begin
        UsageDataImport.Init();
        UsageDataImport."Entry No." := 0;
        UsageDataImport.Insert(true);
    end;

    local procedure CreateSimpleUsageDataBlob()
    begin
        j := LibraryRandom.RandIntInRange(1, 10);
        for i := 0 to j do begin
            UsageDataBlob.Init();
            UsageDataBlob."Entry No." := 0;
            UsageDataBlob."Usage Data Import Entry No." := UsageDataImport."Entry No.";
            UsageDataBlob.Insert(true);
        end;
    end;

    local procedure CreateSimpleUsageDataGenericImport()
    begin
        j := LibraryRandom.RandIntInRange(1, 10);
        for i := 0 to j do begin
            UsageDataGenericImport.Init();
            UsageDataGenericImport."Entry No." := 0;
            UsageDataGenericImport."Usage Data Import Entry No." := UsageDataImport."Entry No.";
            UsageDataGenericImport.Insert(true);
        end;
    end;

    local procedure CreateSimpleUsageDataBilling()
    begin
        j := LibraryRandom.RandIntInRange(1, 10);
        for i := 0 to j do begin
            UsageDataBilling.Init();
            UsageDataBilling."Entry No." := 0;
            UsageDataBilling."Usage Data Import Entry No." := UsageDataImport."Entry No.";
            UsageDataBilling.Insert(true);
        end;
    end;

    var
        GenericImportSettings: Record "Generic Import Settings";
        UsageDataImport: Record "Usage Data Import";
        UsageDataBlob: Record "Usage Data Blob";
        UsageDataGenericImport: Record "Usage Data Generic Import";
        UsageDataBilling: Record "Usage Data Billing";
        LibraryPaymentFormat: Codeunit "Library - Payment Format";
        LibraryRandom: Codeunit "Library - Random";
        UsageBasedBTestLibrary: Codeunit "Usage Based B. Test Library";
        i: Integer;
        j: Integer;
}
