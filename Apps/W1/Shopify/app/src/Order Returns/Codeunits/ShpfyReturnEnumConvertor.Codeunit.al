codeunit 30224 "Shpfy Return Enum Convertor"
{
    SingleInstance = true;
    Access = Internal;

    var
        ReturnDeclineReasons: Dictionary of [Text, Enum "Shpfy Return Decline Reason"];
        ReturnStatuses: Dictionary of [Text, Enum "Shpfy Return Status"];
        ReturnReasons: Dictionary of [Text, Enum "Shpfy Return Reason"];

    #region "Shpfy Return Decline Reason"
    local procedure FillInReturnDeclineReasons()
    var
        EnumValues: List of [Integer];
        EnumNames: List of [Text];
        Index: Integer;
    begin
        if ReturnDeclineReasons.Count > 0 then
            exit;

        EnumValues := Enum::"Shpfy Return Decline Reason".Ordinals();
        EnumNames := Enum::"Shpfy Return Decline Reason".Names();
        for Index := 1 to EnumValues.Count do
            ReturnDeclineReasons.Add(EnumNames.Get(Index).Trim().ToUpper().Replace(' ', '_'), Enum::"Shpfy Return Decline Reason".FromInteger(EnumValues.Get(Index)));
    end;

    internal procedure ConvertToReturnDeclineReason(Value: Text): Enum "Shpfy Return Decline Reason"
    begin
        FillInReturnDeclineReasons();
        if ReturnDeclineReasons.ContainsKey(Value) then
            exit(ReturnDeclineReasons.Get(Value));
    end;

    internal procedure ConvertToText(Value: Enum "Shpfy Return Decline Reason"): text
    begin
        exit(Value.Names.Get(Value.Ordinals().IndexOf(Value.AsInteger())).Trim().ToUpper().Replace(' ', '_'));
    end;
    #endregion "Shpfy Return Decline Reason"

    #region "Shpfy Return Status"
    local procedure FillInReturnStatuses()
    var
        EnumValues: List of [Integer];
        EnumNames: List of [Text];
        Index: Integer;
    begin
        if ReturnStatuses.Count > 0 then
            exit;

        EnumValues := Enum::"Shpfy Return Status".Ordinals();
        EnumNames := Enum::"Shpfy Return Status".Names();
        for Index := 1 to EnumValues.Count do
            ReturnStatuses.Add(EnumNames.Get(Index).Trim().ToUpper().Replace(' ', '_'), Enum::"Shpfy Return Status".FromInteger(EnumValues.Get(Index)));
    end;

    internal procedure ConvertToReturnStatus(Value: Text): Enum "Shpfy Return Status"
    begin
        FillInReturnStatuses();
        if ReturnStatuses.ContainsKey(Value) then
            exit(ReturnStatuses.Get(Value));
    end;

    internal procedure ConvertToText(Value: Enum "Shpfy Return Status"): text
    begin
        exit(Value.Names.Get(Value.Ordinals().IndexOf(Value.AsInteger())).Trim().ToUpper().Replace(' ', '_'));
    end;
    #endregion "Shpfy Return Status"

    #region "Shpfy Return Reason"
    local procedure FillInReturnReasons()
    var
        EnumValues: List of [Integer];
        EnumNames: List of [Text];
        Index: Integer;
    begin
        if ReturnReasons.Count > 0 then
            exit;

        EnumValues := Enum::"Shpfy Return Reason".Ordinals();
        EnumNames := Enum::"Shpfy Return Reason".Names();
        for Index := 1 to EnumValues.Count do
            ReturnReasons.Add(EnumNames.Get(Index).Trim().ToUpper().Replace(' ', '_'), Enum::"Shpfy Return Reason".FromInteger(EnumValues.Get(Index)));
    end;

    internal procedure ConvertToReturnReason(Value: Text): Enum "Shpfy Return Reason"
    begin
        FillInReturnReasons();
        if ReturnReasons.ContainsKey(Value) then
            exit(ReturnReasons.Get(Value));
    end;

    internal procedure ConvertToText(Value: Enum "Shpfy Return Reason"): text
    begin
        exit(Value.Names.Get(Value.Ordinals().IndexOf(Value.AsInteger())).Trim().ToUpper().Replace(' ', '_'));
    end;
    #endregion "Shpfy Return Decline Reason"
}