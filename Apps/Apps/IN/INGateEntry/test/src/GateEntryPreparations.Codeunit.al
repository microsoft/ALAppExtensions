codeunit 18628 "Gate Entry Preparations"
{
    Subtype = Test;

    var
        GateEntryLibrary: Codeunit "Gate Entry Library";
        VerifyInventorySetupErr: Label 'Inventory Setup not verified';

    [Test]
    procedure VerifyInventorySetupWithGateEntryNos()
    var
        InventorySetup: Record "Inventory Setup";
        InwardGateEntryNo: Code[20];
        OutwardGateEntryNo: Code[20];
    begin
        // [SCENARIO] [375098] [Gate Entry - Preparation]
        // [GIVEN] Create Inward and Outward Gate Entry Nos
        InventorySetup.Get();
        InwardGateEntryNo := GateEntryLibrary.CreateNoSeries();
        OutwardGateEntryNo := GateEntryLibrary.CreateNoSeries();

        // [WHEN] Validated Inward and Outward Gate Entry No in Inventory Setup
        InventorySetup.Validate("Inward Gate Entry Nos.", InwardGateEntryNo);
        InventorySetup.Validate("Outward Gate Entry Nos.", OutwardGateEntryNo);
        InventorySetup.Modify(true);

        // [THEN] Gate Entry Inventory Setup Verified
        VerifyInventorySetupWithGateEntryNo(InventorySetup);
    end;

    local procedure VerifyInventorySetupWithGateEntryNo(InventorySetup: Record "Inventory Setup")
    begin
        if (InventorySetup."Inward Gate Entry Nos." = '') and (InventorySetup."Outward Gate Entry Nos." = '') then
            Error(VerifyInventorySetupErr);
    end;
}