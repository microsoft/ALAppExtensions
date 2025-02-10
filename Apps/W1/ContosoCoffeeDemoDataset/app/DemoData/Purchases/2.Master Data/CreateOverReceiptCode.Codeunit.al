codeunit 5443 "Create Over-Receipt Code"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoOverReceiptCode: Codeunit "Contoso Over Receipt Code";
    begin
        ContosoOverReceiptCode.InsertOverReceiptCode(OverRcpt(), OverRcptLbl, true, 10);
    end;

    procedure OverRcpt(): Code[20]
    begin
        exit(OverRcptTok);
    end;

    var
        OverRcptTok: Label 'OVERRCPT10', MaxLength = 20;
        OverRcptLbl: Label 'Over receipt up to 10% of quantity', MaxLength = 100;
}