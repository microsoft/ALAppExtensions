codeunit 11756 "Registration No. Mgt. CZL"
{
    var
        Cust: Record Customer;
        Vend: Record Vendor;
        Cont: Record Contact;
        RegNoEnteredCustMsg: Label 'This %1 has already been entered for the following customers:\ %2.', Comment = '%1=fieldcaption, %2=customer number list';
        RegNoEnteredVendMsg: Label 'This %1 has already been entered for the following vendors:\ %2.', Comment = '%1=fieldcaption, %2=vendor number list';
        RegNoEnteredContMsg: Label 'This %1 has already been entered for the following contacts:\ %2.', Comment = '%1=fieldcaption, %2=contact number list';
        NumberList: Text[250];
        StopCheck: Boolean;

    procedure CheckRegistrationNo(RegNo: Text[20]; Number: Code[20]; TableID: Option): Boolean
    begin
        if RegNo = '' then
            exit(false);
        CheckDuplicity(RegNo, Number, TableID, false);
        exit(true);
    end;

    procedure CheckTaxRegistrationNo(RegNo: Text[20]; Number: Code[20]; TableID: Option): Boolean
    begin
        if RegNo = '' then
            exit(false);
        CheckDuplicity(RegNo, Number, TableID, true);
        exit(true);
    end;

    local procedure CheckDuplicity(RegNo: Text[20]; Number: Code[20]; TableID: Option; IsTax: Boolean)
    begin
        case TableID of
            DataBase::Customer:
                CheckCustomerDuplicity(RegNo, Number, IsTax);
            DataBase::Vendor:
                CheckVendorDuplicity(RegNo, Number, IsTax);
            DataBase::Contact:
                CheckContactDuplicity(RegNo, Number, IsTax);
        end;
    end;

    local procedure CheckCustomerDuplicity(RegNo: Text[20]; Number: Code[20]; IsTax: Boolean)
    begin
        if not IsTax then
            Cust.SetRange("Registration No. CZL", RegNo)
        else
            Cust.SetRange("Tax Registration No. CZL", RegNo);
        Cust.SetFilter("No.", '<>%1', Number);
        if Cust.FindSet() then
            repeat
                StopCheck := AddToNumberList(Cust."No.");
            until (Cust.Next() = 0) or StopCheck;

        if Cust.Count > 0 then
            Message(RegNoEnteredCustMsg, GetFieldCaption(IsTax), NumberList);
    end;

    local procedure CheckVendorDuplicity(RegNo: Text[20]; Number: Code[20]; IsTax: Boolean)
    begin
        if not IsTax then
            Vend.SetRange("Registration No. CZL", RegNo)
        else
            Vend.SetRange("Tax Registration No. CZL", RegNo);
        Vend.SetFilter("No.", '<>%1', Number);
        if Vend.FindSet() then
            repeat
                StopCheck := AddToNumberList(Vend."No.");
            until (Vend.Next() = 0) or StopCheck;

        if Vend.Count > 0 then
            Message(RegNoEnteredVendMsg, GetFieldCaption(IsTax), NumberList);
    end;

    local procedure CheckContactDuplicity(RegNo: Text[20]; Number: Code[20]; IsTax: Boolean)
    begin
        if not IsTax then
            Cont.SetRange("Registration No. CZL", RegNo)
        else
            Cont.SetRange("Tax Registration No. CZL", RegNo);
        Cont.SetFilter("No.", '<>%1', Number);
        if Cont.FindSet() then
            repeat
                StopCheck := AddToNumberList(Cont."No.");
            until (Cont.Next() = 0) or StopCheck;

        if Cont.Count > 0 then
            Message(RegNoEnteredContMsg, GetFieldCaption(IsTax), NumberList);
    end;

    local procedure AddToNumberList(NewNumber: Code[20]): Boolean
    begin
        if NumberList = '' then
            NumberList := NewNumber
        else
            if StrLen(NumberList) + StrLen(NewNumber) + 5 <= MaxStrLen(NumberList) then
                NumberList += ', ' + NewNumber
            else begin
                NumberList += '...';
                exit(true);
            end;
        exit(false);
    end;

    local procedure GetFieldCaption(IsTax: Boolean): Text
    var
        Contact: Record Contact;
    begin
        if not IsTax then
            exit(Contact.FieldCaption("Registration No. CZL"));
        exit(Contact.FieldCaption("Tax Registration No. CZL"));
    end;
}
