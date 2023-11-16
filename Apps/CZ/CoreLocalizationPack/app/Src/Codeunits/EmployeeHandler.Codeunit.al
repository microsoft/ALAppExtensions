// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.HumanResources.Employee;

using Microsoft.Bank;
using Microsoft.Foundation.Company;

codeunit 11750 "Employee Handler CZL"
{
    var
        BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";

    [EventSubscriber(ObjectType::Table, Database::Employee, 'OnAfterModifyEvent', '', false, false)]
    local procedure UpdateCompOfficalCZLOnAfterModify(var Rec: Record Employee; var xRec: Record Employee)
    var
        CompanyOfficialCZL: Record "Company Official CZL";
    begin
        if (Rec."First Name" <> xRec."First Name") or
           (Rec."Middle Name" <> xRec."Middle Name") or
           (Rec."Last Name" <> xRec."Last Name") or
           (Rec.Initials <> xRec.Initials) or
           (Rec."Job Title" <> xRec."Job Title") or
           (Rec."Search Name" <> xRec."Search Name") or
           (Rec.Address <> xRec.Address) or
           (Rec."Address 2" <> xRec."Address 2") or
           (Rec.City <> xRec.City) or
           (Rec."Post Code" <> xRec."Post Code") or
           (Rec.County <> xRec.County) or
           (Rec."Country/Region Code" <> xRec."Country/Region Code") or
           (Rec."Phone No." <> xRec."Phone No.") or
           (Rec."Mobile Phone No." <> xRec."Mobile Phone No.") or
           (Rec."E-Mail" <> xRec."E-Mail") or
           (Rec."Fax No." <> xRec."Fax No.") or
           (Rec."Privacy Blocked" <> xRec."Privacy Blocked")
        then begin
            CompanyOfficialCZL.SetRange("Employee No.", Rec."No.");
            if CompanyOfficialCZL.FindSet() then
                repeat
                    CompanyOfficialCZL."First Name" := Rec."First Name";
                    CompanyOfficialCZL."Middle Name" := Rec."Middle Name";
                    CompanyOfficialCZL."Last Name" := Rec."Last Name";
                    CompanyOfficialCZL.Initials := Rec.Initials;
                    CompanyOfficialCZL."Job Title" := Rec."Job Title";
                    CompanyOfficialCZL."Search Name" := Rec."Search Name";
                    CompanyOfficialCZL.Address := Rec.Address;
                    CompanyOfficialCZL."Address 2" := Rec."Address 2";
                    CompanyOfficialCZL.City := Rec.City;
                    CompanyOfficialCZL."Post Code" := Rec."Post Code";
                    CompanyOfficialCZL.County := Rec.County;
                    CompanyOfficialCZL."Country/Region Code" := Rec."Country/Region Code";
                    CompanyOfficialCZL."Phone No." := Rec."Phone No.";
                    CompanyOfficialCZL."Mobile Phone No." := Rec."Mobile Phone No.";
                    CompanyOfficialCZL."E-Mail" := Rec."E-Mail";
                    CompanyOfficialCZL."Fax No." := Rec."Fax No.";
                    CompanyOfficialCZL."Privacy Blocked" := Rec."Privacy Blocked";
                    CompanyOfficialCZL.Modify(true);
                until CompanyOfficialCZL.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Employee, 'OnAfterDeleteEvent', '', false, false)]
    local procedure UpdateCompOfficalCZLOnAfterDelete(var Rec: Record Employee)
    var
        CompanyOfficialCZL: Record "Company Official CZL";
    begin
        CompanyOfficialCZL.SetRange("Employee No.", Rec."No.");
        CompanyOfficialCZL.ModifyAll("Employee No.", '', true);
    end;

    [EventSubscriber(ObjectType::Table, Database::Employee, 'OnBeforeValidateEvent', 'Bank Account No.', false, false)]
    local procedure CheckCzBankAccountNoOnBeforeBankAccountNoValidate(var Rec: Record Employee)
    begin
        BankOperationsFunctionsCZL.CheckCzBankAccountNo(Rec."Bank Account No.", Rec."Country/Region Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::Employee, 'OnBeforeValidateEvent', 'Country/Region Code', false, false)]
    local procedure CheckCzBankAccountNoOnBeforeCountryRegionCodeValidate(var Rec: Record Employee)
    begin
        BankOperationsFunctionsCZL.CheckCzBankAccountNo(Rec."Bank Account No.", Rec."Country/Region Code");
    end;
}
