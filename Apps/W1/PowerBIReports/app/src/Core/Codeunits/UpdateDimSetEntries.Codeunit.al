namespace Microsoft.PowerBIReports;

codeunit 36952 "Update Dim. Set Entries"
{
    Access = Internal;

    var
        PBIDimensionSetEntry: Record "Dimension Set Entry";
        PBISetup: Record "PowerBI Reports Setup";
        PBIDimensionSets: Query "Dimension Sets";

    trigger OnRun()
    var
        LastModifiedDateTime: DateTime;
    begin
        PBISetup.Get();
        LastModifiedDateTime := PBISetup."Last Dim. Set Entry Date-Time";

        PBIDimensionSetEntry.Reset();
        if not PBIDimensionSetEntry.IsEmpty() then  // skip setting Last Updated on the first run when the app is installed from scatch. 
            PBIDimensionSets.SetFilter(SystemModifiedAt, '>=%1', LastModifiedDateTime);

        if PBIDimensionSets.Open() then begin
            while PBIDimensionSets.Read() do begin

                if PBIDimensionSets.SystemModifiedAt > LastModifiedDateTime then
                    LastModifiedDateTime := PBIDimensionSets.SystemModifiedAt;

                PBIDimensionSetEntry.Init();
                PBIDimensionSetEntry."Dimension Set ID" := PBIDimensionSets.Dimension_Set_ID;
                PBIDimensionSetEntry."Value Count" := PBIDimensionSets.Value_Count;
                PBIDimensionSetEntry."Dimension 1 Value Code" := PBIDimensionSets.Dimension_1_Value_Code;
                PBIDimensionSetEntry."Dimension 1 Value Name" := PBIDimensionSets.Dimension_1_Value_Name;
                PBIDimensionSetEntry."Dimension 2 Value Code" := PBIDimensionSets.Dimension_2_Value_Code;
                PBIDimensionSetEntry."Dimension 2 Value Name" := PBIDimensionSets.Dimension_2_Value_Name;
                PBIDimensionSetEntry."Dimension 3 Value Code" := PBIDimensionSets.Dimension_3_Value_Code;
                PBIDimensionSetEntry."Dimension 3 Value Name" := PBIDimensionSets.Dimension_3_Value_Name;
                PBIDimensionSetEntry."Dimension 4 Value Code" := PBIDimensionSets.Dimension_4_Value_Code;
                PBIDimensionSetEntry."Dimension 4 Value Name" := PBIDimensionSets.Dimension_4_Value_Name;
                PBIDimensionSetEntry."Dimension 5 Value Code" := PBIDimensionSets.Dimension_5_Value_Code;
                PBIDimensionSetEntry."Dimension 5 Value Name" := PBIDimensionSets.Dimension_5_Value_Name;
                PBIDimensionSetEntry."Dimension 6 Value Code" := PBIDimensionSets.Dimension_6_Value_Code;
                PBIDimensionSetEntry."Dimension 6 Value Name" := PBIDimensionSets.Dimension_6_Value_Name;
                PBIDimensionSetEntry."Dimension 7 Value Code" := PBIDimensionSets.Dimension_7_Value_Code;
                PBIDimensionSetEntry."Dimension 7 Value Name" := PBIDimensionSets.Dimension_7_Value_Name;
                PBIDimensionSetEntry."Dimension 8 Value Code" := PBIDimensionSets.Dimension_8_Value_Code;
                PBIDimensionSetEntry."Dimension 8 Value Name" := PBIDimensionSets.Dimension_8_Value_Name;
                if not PBIDimensionSetEntry.Insert() then
                    PBIDimensionSetEntry.Modify();

            end;
            PBISetup."Last Dim. Set Entry Date-Time" := LastModifiedDateTime;
            PBISetup.Modify();
        end;
    end;
}

