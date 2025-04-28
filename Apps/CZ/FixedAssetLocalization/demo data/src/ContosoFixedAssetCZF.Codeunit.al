#pragma warning disable AA0247
codeunit 31216 "Contoso Fixed Asset CZF"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "FA Extended Posting Group CZF" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertFAExtendedPostingGroup(GroupCode: Code[20]; FAExtendedPostigType: Enum "FA Extended Posting Type CZF"; Code: Code[20]; BookValAccOnDispGain: Code[20]; BookValAccOnDispLoss: Code[20]; SalesAccOnDispGain: Code[20]; SalesAccOnDispLoss: Code[20]; MaintenanceExpenseAccount: Code[20])
    var
        FAExtendedPosingGroupCZF: Record "FA Extended Posting Group CZF";
        Exists: Boolean;
    begin
        if FAExtendedPosingGroupCZF.Get(GroupCode, FAExtendedPostigType, Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        FAExtendedPosingGroupCZF.Validate("FA Posting Group Code", GroupCode);
        FAExtendedPosingGroupCZF.Validate("FA Posting Type", FAExtendedPostigType);
        FAExtendedPosingGroupCZF.Validate(Code, Code);
        FAExtendedPosingGroupCZF.Validate("Book Val. Acc. on Disp. (Gain)", BookValAccOnDispGain);
        FAExtendedPosingGroupCZF.Validate("Book Val. Acc. on Disp. (Loss)", BookValAccOnDispLoss);
        FAExtendedPosingGroupCZF.Validate("Sales Acc. on Disp. (Gain)", SalesAccOnDispGain);
        FAExtendedPosingGroupCZF.Validate("Sales Acc. on Disp. (Loss)", SalesAccOnDispLoss);
        FAExtendedPosingGroupCZF.Validate("Maintenance Expense Account", MaintenanceExpenseAccount);

        if Exists then
            FAExtendedPosingGroupCZF.Modify(true)
        else
            FAExtendedPosingGroupCZF.Insert(true);
    end;
}
