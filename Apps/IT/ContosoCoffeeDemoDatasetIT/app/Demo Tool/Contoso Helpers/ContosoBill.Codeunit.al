codeunit 12232 "Contoso Bill"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata Bill = rim;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertBillCode(Code: Code[20]; Description: Text[30]; AllowIssue: Boolean; BankReceipt: Boolean; BillsforCollTempAccNo: Code[20]; TemporaryBillNo: Code[20]; FinalBillNo: Code[20]; ListNo: Code[20]; BillSourceCode: Code[10]; VendorBillNo: Code[20]; VendorBillList: Code[20]; VendBillSourceCode: Code[20])
    var
        Bill: Record Bill;
        Exists: Boolean;
    begin
        if Bill.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Bill.Validate(Code, Code);
        Bill.Validate(Description, Description);
        Bill.Validate("Allow Issue", AllowIssue);
        Bill.Validate("Bank Receipt", BankReceipt);
        Bill.Validate("Bills for Coll. Temp. Acc. No.", BillsforCollTempAccNo);
        Bill.Validate("Temporary Bill No.", TemporaryBillNo);
        Bill.Validate("Final Bill No.", FinalBillNo);
        Bill.Validate("List No.", ListNo);
        Bill.Validate("Bill Source Code", BillSourceCode);
        Bill.Validate("Vendor Bill No.", VendorBillNo);
        Bill.Validate("Vendor Bill List", VendorBillList);
        Bill.Validate("Vend. Bill Source Code", VendBillSourceCode);

        if Exists then
            Bill.Modify(true)
        else
            Bill.Insert(true);
    end;

    var
        OverwriteData: Boolean;
}