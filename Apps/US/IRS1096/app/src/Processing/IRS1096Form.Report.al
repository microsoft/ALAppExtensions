// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Company;
using Microsoft.HumanResources.Employee;

report 10020 "IRS 1096 Form"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Processing/IRS1096Form.rdlc';

    dataset
    {
        dataitem(Header; "IRS 1096 Form Header")
        {
            DataItemTableView = SORTING("No.");
            column(CompanyFullName; CompanyFullName)
            {
            }
            column(CompanyFullAddress; CompanyFullAddress)
            {
            }
            column(CompanyAddressDetails; CompanyAddressDetails)
            {
            }
            column(ContactName; ContactName)
            {
            }
            column(ContactPhoneNumber; ContactPhoneNumber)
            {
            }
            column(ContactEmail; ContactEmail)
            {
            }
            column(ContactFaxNumber; ContactFaxNumber)
            {
            }
            column(IdentificationNumber; IdentificationNumber)
            {
            }
            column(SocialSecurityNumber; SocialSecurityNumber)
            {
            }
            column(MISCCode; MISCCode)
            {
            }
            column(DIVCode; DIVCode)
            {
            }
            column(INTCode; INTCode)
            {
            }
            column(NECCode; NECCode)
            {
            }
            column(TotalNumberOfForms; GetNumber(Header."Total Number Of Forms"))
            {
            }
            column(TotalAmount; GetAmount(Header."Total Amount To Report"))
            {
            }
            column(PageGroupNo; PageGroupNo)
            {
            }

            trigger OnAfterGetRecord()
            begin
                MISCCode := '';
                INTCode := '';
                DIVCode := '';
                NECCode := '';

                CompanyInfo.Get();
                if TestPrint then begin
                    CompanyFullName := 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
                    CompanyFullAddress := 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
                    CompanyAddressDetails := 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
                    ContactName := 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
                    ContactPhoneNumber := 'XXXXXXXXXXXXXX';
                    ContactEmail := 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
                    ContactFaxNumber := 'XXXXXXXXXXXXXXX';
                    IdentificationNumber := 'XXXXXXXXXX';
                    SocialSecurityNumber := 'XXXXXXXXX';
                    MISCCode := 'X';
                    INTCode := 'X';
                    DIVCode := 'X';
                    NECCode := 'X';
                end else begin
                    CompanyFullName := CompanyInfo.Name;
                    if (CompanyInfo."Name 2" <> '') and (StrLen(CompanyFullName) < MaxStrLen(CompanyFullName)) then
                        CompanyFullName += ' ' + CompanyInfo."Name 2";
                    CompanyFullAddress := CompanyInfo.Address;
                    if CompanyInfo."Address 2" <> '' then
                        CompanyFullAddress += ' ' + CompanyInfo."Address 2";
                    CompanyAddressDetails := CompanyInfo.City;
                    if CompanyInfo.County <> '' then begin
                        if CompanyAddressDetails <> '' then
                            CompanyAddressDetails += ', ';
                        CompanyAddressDetails += CompanyInfo.County;
                    end;
                    if CompanyInfo."Post Code" <> '' then begin
                        if CompanyAddressDetails <> '' then
                            CompanyAddressDetails += ', ';
                        CompanyAddressDetails += CompanyInfo."Post Code";
                    end;
                    CompanyFullName := CopyStr(CompanyFullName, 1, 47);
                    CompanyFullAddress := CopyStr(CompanyFullAddress, 1, 47);
                    CompanyAddressDetails := CopyStr(CompanyAddressDetails, 1, 47);
                    case Header."IRS Code" of
                        'MISC':
                            MISCCode := 'X';
                        'DIV':
                            DIVCode := 'X';
                        'NEC':
                            NECCode := 'X';
                        'INT':
                            INTCode := 'X';
                    end;
                end;

                PageGroupNo += 1;
            end;

            trigger OnPreDataItem()
            begin
                PageGroupNo := 0;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(TestPrint; TestPrint)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Test Print';
                        ToolTip = 'Specifies if you want to print the 1096 form on blank paper before you print them on dedicated forms.';
                    }
                }
                group(ContractGroup)
                {
                    Caption = 'Person to contact';
                    field(ContactName; ContactName)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Name of person to contact';
                        ToolTip = 'Specifies a name of the person to contact.';
                    }
                    field(ContactPhoneNumber; ContactPhoneNumber)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Telephone number';
                        ToolTip = 'Specifies a telephone number of the person to contact.';
                    }
                    field(ContactEmail; ContactEmail)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Email address';
                        ToolTip = 'Specifies an e-mail of the person to contact.';
                    }
                    field(ContactFaxNumber; ContactFaxNumber)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Fax number';
                        ToolTip = 'Specifies an fax number of the person to contact.';
                    }
                    field(IdentificationNumber; IdentificationNumber)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Employer identification number';
                        ToolTip = 'Specifies an employer identification number.';
                    }
                    field(SocialSecurityNumber; SocialSecurityNumber)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Social security number';
                        ToolTip = 'Specifies a social security number.';
                    }
                }
            }
        }
        trigger OnOpenPage()
        var
            Employee: Record Employee;
        begin
            CompanyInfo.Get();
            if IdentificationNumber = '' then
                IdentificationNumber := CompanyInfo."EIN Number";
            if ContactName = '' then
                if Employee.get(CompanyInfo."IRS Contact No.") then
                    ContactName := CopyStr(Employee.FullName(), 1, MaxStrLen(ContactName));
        end;
    }

    var
        CompanyInfo: Record "Company Information";
        CompanyFullName: Text;
        CompanyFullAddress: Text;
        CompanyAddressDetails: Text;
        ContactName: Text[47];
        ContactPhoneNumber: Text[14];
        ContactEmail: Text;
        ContactFaxNumber: Text[15];
        IdentificationNumber: Text[10];
        SocialSecurityNumber: Text[9];
        TestPrint: Boolean;
        MISCCode: Code[1];
        DIVCode: Code[1];
        INTCode: Code[1];
        NECCode: Code[1];
        PageGroupNo: Integer;

    local procedure GetNumber(InputInteger: Integer): Integer
    begin
        if TestPrint then
            exit(9999999);
        exit(InputInteger);
    end;

    local procedure GetAmount(InputAmount: Decimal): Decimal
    begin
        if TestPrint then
            exit(9999999.99);
        exit(InputAmount);
    end;
}

