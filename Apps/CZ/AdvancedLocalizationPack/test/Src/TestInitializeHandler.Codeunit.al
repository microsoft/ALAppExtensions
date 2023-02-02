codeunit 148115 "Test Initialize Handler CZA"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Test Initialize", 'OnBeforeTestSuiteInitialize', '', false, false)]
    local procedure UpdateRecordsOnBeforeTestSuiteInitialize(CallerCodeunitID: Integer)
    begin
        case CallerCodeunitID of
            136500, // "UT Time Sheets"
            136502, // "UT Time Sheets Posting"
            137092, // "SCM Kitting - D3 - Part 1"
            137094, // "SCM Kitting - D3 - Part 2"
            137095, // "SCM Kitting - Reservations"
            137096, // "SCM Kitting - ATO"
            137097, // "SCM Kitting - Undo"
            137098, // "SCM Kitting-D5B-ItemTracking"
            137101, // "SCM Kitting"
            137102, // "SCM Kitting ATO in Whse"
            137104, // "SCM Kitting ATS in Whse/IT BM"
            137105, // "SCM Kitting ATS in Whse/IT IM"
            137106, // "SCM Kitting ATS in Whse/IT WMS"
            137120, // "Non-inventory Item Costing"
            137155, // "SCM Warehouse - Shipping II"
            137262, // "SCM Invt Item Tracking III
            137311, // "SCM Kitting - Printout Reports"
            137312, // "SCM Kitting - Item profit"
            137390, // "SCM Kitting -  Reports"
            137915, // "SCM Assembly Posting"
            137927, // "SCM Assembly Copy"
			137163: // "SCM Orders VI"
                UpdateAssemblySetup();
        end;
    end;

    local procedure UpdateAssemblySetup()
    var
        AssemblySetup: Record "Assembly Setup";
    begin
        AssemblySetup.Get();
        AssemblySetup."Default Gen.Bus.Post. Grp. CZA" := '';
        AssemblySetup.Modify();
    end;
}