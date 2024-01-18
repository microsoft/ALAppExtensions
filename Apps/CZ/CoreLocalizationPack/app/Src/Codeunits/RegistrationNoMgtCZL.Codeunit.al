// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Registration;

using Microsoft.CRM.Contact;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

codeunit 11756 "Registration No. Mgt. CZL"
{
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Contact: Record Contact;
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
            Customer.SetRange("Registration Number", RegNo)
        else
            Customer.SetRange("Tax Registration No. CZL", RegNo);
        Customer.SetFilter("No.", '<>%1', Number);
        if Customer.FindSet() then
            repeat
                StopCheck := AddToNumberList(Customer."No.");
            until (Customer.Next() = 0) or StopCheck;

        if Customer.Count > 0 then
            Message(RegNoEnteredCustMsg, GetFieldCaption(IsTax), NumberList);
    end;

    local procedure CheckVendorDuplicity(RegNo: Text[20]; Number: Code[20]; IsTax: Boolean)
    begin
        if not IsTax then
            Vendor.SetRange("Registration Number", RegNo)
        else
            Vendor.SetRange("Tax Registration No. CZL", RegNo);
        Vendor.SetFilter("No.", '<>%1', Number);
        if Vendor.FindSet() then
            repeat
                StopCheck := AddToNumberList(Vendor."No.");
            until (Vendor.Next() = 0) or StopCheck;

        if Vendor.Count > 0 then
            Message(RegNoEnteredVendMsg, GetFieldCaption(IsTax), NumberList);
    end;

    local procedure CheckContactDuplicity(RegNo: Text[20]; Number: Code[20]; IsTax: Boolean)
    begin
        if not IsTax then
            Contact.SetRange("Registration Number", RegNo)
        else
            Contact.SetRange("Tax Registration No. CZL", RegNo);
        Contact.SetFilter("No.", '<>%1', Number);
        if Contact.FindSet() then
            repeat
                StopCheck := AddToNumberList(Contact."No.");
            until (Contact.Next() = 0) or StopCheck;

        if Contact.Count > 0 then
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
    begin
        if not IsTax then
            exit(Contact.FieldCaption("Registration Number"));
        exit(Contact.FieldCaption("Tax Registration No. CZL"));
    end;
}
