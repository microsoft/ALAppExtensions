codeunit 139599 "Library - AAC"
{
    // [FEATURE] [Automatic Account Codes] [Library]
    var
        LibraryUtility: Codeunit "Library - Utility";

    procedure CreateAutomaticAccountHeader(var AutomaticAccountHeader: Record "Automatic Account Header")
    begin
        AutomaticAccountHeader.Init();
        AutomaticAccountHeader.Validate(
          "No.", LibraryUtility.GenerateRandomCode(AutomaticAccountHeader.FieldNo("No."), DATABASE::"Automatic Account Header"));
        AutomaticAccountHeader.Validate(Description,
           LibraryUtility.GenerateRandomCode(AutomaticAccountHeader.FieldNo(Description), DATABASE::"Automatic Account Header"));
        AutomaticAccountHeader.Insert(true);
    end;

    procedure CreateAutomaticAccountLine(var AutomaticAccountLine: Record "Automatic Account Line"; AutomaticAccNo: Code[10])
    var
        RecordRef: RecordRef;
    begin
        AutomaticAccountLine.Init();
        AutomaticAccountLine.Validate("Automatic Acc. No.", AutomaticAccNo);
        RecordRef.GetTable(AutomaticAccountLine);
        AutomaticAccountLine.Validate("Line No.", LibraryUtility.GetNewLineNo(RecordRef, AutomaticAccountLine.FieldNo("Line No.")));
        AutomaticAccountLine.Insert(true);
    end;

}