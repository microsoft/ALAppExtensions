codeunit 17152 "Contoso AU WHT"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "WHT Posting Setup" = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertWHTPostingSetup(WHTBusinessPostingGroup: Code[20]; WHTProductPostingGroup: Code[20]; WHTPerc: Decimal; PrepaidWHTAccountCode: Code[20]; PayableWHTAccountCode: Code[20]; RevenueType: Code[10]; PurchWHTAdjAccountNo: Code[20]; SalesWHTAdjAccountNo: Code[20]; RealizedWHTType: Option; WHTMinimumInvoiceAmount: Decimal)
    var
        WHTPostingSetup: Record "WHT Posting Setup";
        Exists: Boolean;
    begin
        if WHTPostingSetup.Get(WHTBusinessPostingGroup, WHTProductPostingGroup) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        WHTPostingSetup.Validate("WHT Business Posting Group", WHTBusinessPostingGroup);
        WHTPostingSetup.Validate("WHT Product Posting Group", WHTProductPostingGroup);
        WHTPostingSetup.Validate("WHT %", WHTPerc);
        WHTPostingSetup.Validate("Prepaid WHT Account Code", PrepaidWHTAccountCode);
        WHTPostingSetup.Validate("Payable WHT Account Code", PayableWHTAccountCode);
        WHTPostingSetup.Validate("Revenue Type", RevenueType);
        WHTPostingSetup.Validate("Purch. WHT Adj. Account No.", PurchWHTAdjAccountNo);
        WHTPostingSetup.Validate("Sales WHT Adj. Account No.", SalesWHTAdjAccountNo);
        WHTPostingSetup.Validate("Realized WHT Type", RealizedWHTType);
        WHTPostingSetup.Validate("WHT Minimum Invoice Amount", WHTMinimumInvoiceAmount);

        if Exists then
            WHTPostingSetup.Modify(true)
        else
            WHTPostingSetup.Insert(true);
    end;

    procedure InsertWHTRevenueType(Code: Code[10]; Description: Text[50]; Sequence: Integer)
    var
        WHTRevenueTypes: Record "WHT Revenue Types";
        Exists: Boolean;
    begin
        if WHTRevenueTypes.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        WHTRevenueTypes.Validate(Code, Code);
        WHTRevenueTypes.Validate(Description, Description);
        WHTRevenueTypes.Validate(Sequence, Sequence);

        if Exists then
            WHTRevenueTypes.Modify(true)
        else
            WHTRevenueTypes.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}