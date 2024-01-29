// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.Security.AccessControl;
using System.Utilities;

codeunit 31357 "Issue Bank Statement CZB"
{
    Permissions = tabledata "Iss. Bank Statement Header CZB" = im,
                  tabledata "Iss. Bank Statement Line CZB" = im;
    TableNo = "Bank Statement Header CZB";

    trigger OnRun()
    var
        BankStatementLineCZB: Record "Bank Statement Line CZB";
        IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB";
        IssBankStatementLineCZB: Record "Iss. Bank Statement Line CZB";
        BankAccount: Record "Bank Account";
        User: Record User;
        NoSeriesManagement: Codeunit NoSeriesManagement;
        RecordLinkManagement: Codeunit "Record Link Management";
    begin
        OnBeforeIssueBankStatement(Rec);
        Rec.TestField("Bank Account No.");
        Rec.TestField("Document Date");
        Rec.TestField("External Document No.");
        BankAccount.Get(Rec."Bank Account No.");
        BankAccount.TestField(Blocked, false);

        IssBankStatementHeaderCZB.SetRange(IssBankStatementHeaderCZB."Bank Account No.", Rec."Bank Account No.");
        IssBankStatementHeaderCZB.SetRange(IssBankStatementHeaderCZB."External Document No.", Rec."External Document No.");
        if BankAccount."Check Ext. No. Curr. Year CZB" then
            IssBankStatementHeaderCZB.SetRange(IssBankStatementHeaderCZB."Document Date", CalcDate('<CY>-<1Y>+<1D>', Rec."Document Date"),
              CalcDate('<CY>', Rec."Document Date"));
        if not IssBankStatementHeaderCZB.IsEmpty() then begin
            IssBankStatementHeaderCZB.FindFirst();
            Error(AlreadyExistErr, IssBankStatementHeaderCZB.FieldCaption(IssBankStatementHeaderCZB."External Document No."), IssBankStatementHeaderCZB.TableCaption, IssBankStatementHeaderCZB.FieldCaption(IssBankStatementHeaderCZB."No."), IssBankStatementHeaderCZB."No.");
        end;
        IssBankStatementHeaderCZB.Reset();

        BankStatementLineCZB.LockTable();
        if BankStatementLineCZB.FindLast() then;

        BankStatementLineCZB.SetRange("Bank Statement No.", Rec."No.");
        if not BankStatementLineCZB.FindSet() then
            Error(NothingToIssueErr);
        repeat
            BankStatementLineCZB.TestField(Amount);
        until BankStatementLineCZB.Next() = 0;

        // insert header
        IssBankStatementHeaderCZB.Init();
        IssBankStatementHeaderCZB.TransferFields(Rec);
        BankAccount.TestField("Issued Bank Statement Nos. CZB");
        if (BankAccount."Issued Bank Statement Nos. CZB" <> Rec."No. Series") and (Rec."No. Series" <> '') then
            IssBankStatementHeaderCZB."No." := NoSeriesManagement.GetNextNo(BankAccount."Issued Bank Statement Nos. CZB", Rec."Document Date", true);
        if IssBankStatementHeaderCZB."No." = '' then
            IssBankStatementHeaderCZB."No." := Rec."No.";

        Rec."Last Issuing No." := IssBankStatementHeaderCZB."No.";

        IssBankStatementHeaderCZB."Pre-Assigned No. Series" := Rec."No. Series";
        IssBankStatementHeaderCZB."Pre-Assigned No." := Rec."No.";
        if User.Get(IssBankStatementHeaderCZB.SystemModifiedBy) then
            IssBankStatementHeaderCZB."Pre-Assigned User ID" := User."User Name";
        IssBankStatementHeaderCZB.Insert();
        OnAfterIssuedBankStatementHeaderInsert(IssBankStatementHeaderCZB, Rec);
        RecordLinkManagement.CopyLinks(Rec, IssBankStatementHeaderCZB);

        // insert lines
        if BankStatementLineCZB.FindSet() then
            repeat
                IssBankStatementLineCZB.Init();
                IssBankStatementLineCZB.TransferFields(BankStatementLineCZB);
                IssBankStatementLineCZB."Bank Statement No." := IssBankStatementHeaderCZB."No.";
                IssBankStatementLineCZB.Insert();
                OnAfterIssuedBankStatementLineInsert(IssBankStatementLineCZB, BankStatementLineCZB);
            until BankStatementLineCZB.Next() = 0;

        // delete non issued bank statement
        if Rec.HasLinks() then
            Rec.DeleteLinks();
        Rec.Delete(true);
    end;

    var
        ErrorText: array[1000] of Text;
        AlreadyExistErr: Label 'The %1 field allready exist in table %2, field %3 = %4.', Comment = '%1 = External Document No. FieldCaption; %2 = Issue Bank Stmt Header TableCaption; %3 = No. FieldSaption; %4 = No.';
        NothingToIssueErr: Label 'There is nothing to issue.';
        CustVendIsBlockedErr: Label '%1 %2 is Blocked.', Comment = '%1 = TableCaption; %2 = No.';
        PrivacyBlockedErr: Label '%1 %2 is blocked for privacy.', Comment = '%1 = TableCaption; %2 = No.';

    procedure CheckBankStatementLine(IssBankStatementLineCZB: Record "Iss. Bank Statement Line CZB"; CauseError: Boolean; AddError: Boolean) ReturnValue: Boolean
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        ReturnValue := true;
        if IssBankStatementLineCZB."No." <> '' then
            case IssBankStatementLineCZB.Type of
                IssBankStatementLineCZB.Type::Customer:
                    begin
                        Customer.Get(IssBankStatementLineCZB."No.");
                        if Customer."Privacy Blocked" then begin
                            if CauseError then
                                Customer.FieldError("Privacy Blocked");
                            ReturnValue := false;
                            if AddError then
                                AddErrorText(StrSubstNo(PrivacyBlockedErr, Customer.TableCaption, Customer."No."));
                        end;
                        if Customer.Blocked in [Customer.Blocked::All] then begin
                            if CauseError then
                                Customer.FieldError(Blocked);
                            ReturnValue := false;
                            if AddError then
                                AddErrorText(StrSubstNo(CustVendIsBlockedErr, Customer.TableCaption, Customer."No."));
                        end;
                    end;
                IssBankStatementLineCZB.Type::Vendor:
                    begin
                        Vendor.Get(IssBankStatementLineCZB."No.");
                        if Vendor."Privacy Blocked" then begin
                            if CauseError then
                                Vendor.FieldError("Privacy Blocked");
                            ReturnValue := false;
                            if AddError then
                                AddErrorText(StrSubstNo(PrivacyBlockedErr, Vendor.TableCaption, Vendor."No."));
                        end;

                        if Vendor.Blocked in [Vendor.Blocked::All] then begin
                            if CauseError then
                                Vendor.FieldError(Blocked);
                            ReturnValue := false;
                            if AddError then
                                AddErrorText(StrSubstNo(CustVendIsBlockedErr, Vendor.TableCaption, Vendor."No."));
                        end;
                    end;
            end;
    end;

    local procedure AddErrorText(NewText: Text)
    begin
        ErrorText[CompressArray(ErrorText) + 1] := NewText;
    end;

    procedure ReturnError(var ErrorText2: Text; NumberNo: Integer)
    begin
        ErrorText2 := ErrorText[NumberNo];
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIssueBankStatement(var BankStatementHeaderCZB: Record "Bank Statement Header CZB")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIssuedBankStatementHeaderInsert(var IssBankStatementHeaderCZB: Record "Iss. Bank Statement Header CZB"; var BankStatementHeaderCZB: Record "Bank Statement Header CZB")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIssuedBankStatementLineInsert(var IssBankStatementLineCZB: Record "Iss. Bank Statement Line CZB"; var BankStatementLineCZB: Record "Bank Statement Line CZB")
    begin
    end;
}
