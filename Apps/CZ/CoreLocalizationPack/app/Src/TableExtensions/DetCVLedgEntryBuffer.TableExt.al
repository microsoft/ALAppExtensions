tableextension 11789 "Det. CV Ledg. Entry Buffer CZL" extends "Detailed CV Ledg. Entry Buffer"
{
    fields
    {
        field(11790; "Appl. Across Post. Groups CZL"; Boolean)
        {
            Caption = 'Application Across Posting Groups';
            Editable = false;
            DataClassification = SystemMetadata;
        }
    }

    procedure SetApplAcrossPostGroupsCZL(DifferentPostingGroups: Boolean)
    var
        TempDetailedCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer" temporary;
        ApplAcrossPostGroupsExist: Boolean;
    begin
        TempDetailedCVLedgEntryBuffer.Copy(Rec, true);
        TempDetailedCVLedgEntryBuffer.Reset();
        TempDetailedCVLedgEntryBuffer.SetRange("Entry Type", TempDetailedCVLedgEntryBuffer."Entry Type"::Application);
        if not DifferentPostingGroups then begin
            TempDetailedCVLedgEntryBuffer.SetRange("Appl. Across Post. Groups CZL", true);
            ApplAcrossPostGroupsExist := not TempDetailedCVLedgEntryBuffer.IsEmpty();
        end;
        TempDetailedCVLedgEntryBuffer.SetRange("Appl. Across Post. Groups CZL", false);
        if DifferentPostingGroups or ApplAcrossPostGroupsExist then
            if not TempDetailedCVLedgEntryBuffer.IsEmpty() then
                TempDetailedCVLedgEntryBuffer.ModifyAll("Appl. Across Post. Groups CZL", true);
    end;
}