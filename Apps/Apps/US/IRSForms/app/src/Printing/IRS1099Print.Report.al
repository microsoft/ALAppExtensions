// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Company;
using Microsoft.Purchases.Vendor;

report 10032 "IRS 1099 Print"
{
    ApplicationArea = All;
    DefaultRenderingLayout = WordLayout;

    dataset
    {
        dataitem(IRS1099FormDocHeader; "IRS 1099 Form Doc. Header")
        {
            DataItemTableView = sorting("Period No.", "Form No.", "Vendor No.");
            column(Period_No; "Period No.") { }
            column(Vendor_No; "Vendor No.") { }
            column(Form_No; "Form No.") { }
            column(ID; ID) { }
            column(Report_Type; IRS1099FormReportType) { }
            column(Report_Year; ReportYear) { }
            column(Company_Name; CompanyInformation.Name) { }
            column(Company_Address; CompanyInformation.Address + ' ' + CompanyInformation."Address 2") { }
            column(Company_City; CompanyInformation.City) { }
            column(Company_County; CompanyInformation.County) { }
            column(Company_Country; CompanyInformation."Country/Region Code") { }
            column(Company_Post_Code; CompanyInformation."Post Code") { }
            column(Company_FederalID; ProcessCompanyTIN(CompanyInformation."Federal ID No.")) { }
            column(Company_PhoneNo; CompanyInformation."Phone No.") { }

            dataitem(IRS1099ReportLine; "IRS 1099 Report Line")
            {
                DataItemTableView = sorting("Line No.");
                column(Line_No; "Line No.") { }
                column(Line_Name; Name) { }
                column(Line_Value; Value) { }
            }

            dataitem(Vendor; Vendor)
            {
                DataItemLink = "No." = field("Vendor No.");
                DataItemLinkReference = IRS1099FormDocHeader;
                DataItemTableView = sorting("No.");

                column(Vendor_Name; Name) { }
                column(Vendor_Address; Address + ' ' + "Address 2") { }
                column(Vendor_City; City) { }
                column(Vendor_County; County) { }
                column(Vendor_Country; "Country/Region Code") { }
                column(Vendor_Post_Code; "Post Code") { }
                column(Vendor_FederalID; ProcessVendorTIN("Federal ID No.")) { }
                column(Vendor_BankAccountNo; BankAccountNo) { }
                column(Vendor_FATCA_Requirment; FATCARequirementText) { }

                trigger OnAfterGetRecord()
                var
                    VendorBankAccount: Record "Vendor Bank Account";
                begin
                    if Vendor."Preferred Bank Account Code" <> '' then
                        VendorBankAccount.Get(Vendor."No.", Vendor."Preferred Bank Account Code");
                    BankAccountNo := VendorBankAccount."Bank Account No.";
                    if Vendor."FATCA Requirement" then
                        FATCARequirementText := 'Yes'
                    else
                        FATCARequirementText := 'No';
                end;
            }

            dataitem(IRS1099Form; "IRS 1099 Form")
            {
                DataItemLink = "Period No." = field("Period No."), "No." = field("Form No.");
                DataItemTableView = sorting("No.");

                column(FormName; "No.") { }
                column(FormDescription; Description) { }
            }

            dataitem(IRS1099FormInstruction; "IRS 1099 Form Instruction")
            {
                DataItemLink = "Form No." = field("Form No."), "Period No." = field("Period No.");
                DataItemLinkReference = IRS1099FormDocHeader;
                DataItemTableView = sorting("Period No.", "Form No.", "Line No.");

                column(Instruction_Header; Header) { }
                column(Instruction_Description; Description) { }
            }

            trigger OnAfterGetRecord()
            var
                IRS1099DataSet: Codeunit "IRS 1099 Dataset";
            begin
                IRS1099DataSet.Get1099Dataset(IRS1099FormDocHeader, IRS1099ReportLine);
                CompanyInformation.Get();
                IRS1099Form.Get(IRS1099FormDocHeader."Period No.", IRS1099FormDocHeader."Form No.");
                ReportYear := GetReportYear(IRS1099FormDocHeader);
            end;
        }
    }
    requestpage
    {
        ShowFilter = false;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(IRS1099FormReportTypeControl; IRS1099FormReportType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Report Type';
                        NotBlank = true;
                        ToolTip = 'Specifies the type of report to print.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            IRS1099FormReportType := IRS1099FormReportType::"Copy B";
        end;
    }

    rendering
    {
        layout(WordLayout)
        {
            Type = Word;
            Caption = 'IRS 1099 Print (Word)';
            Summary = 'IRS 1099 Default Word Layout';
            LayoutFile = 'src/Printing/IRS 1099 Print.docx';
        }
    }

    var
        CompanyInformation: Record "Company Information";
        IRS1099FormReportType: Enum "IRS 1099 Form Report Type";
        BankAccountNo: Text;
        FATCARequirementText: Text;
        ReportYear: Integer;

    local procedure GetReportYear(IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"): Integer
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
        ReportDate: Date;
    begin
        if IRSReportingPeriod.Get(IRS1099FormDocHeader."Period No.") then;
        ReportDate := IRSReportingPeriod."Starting Date";
        if ReportDate <> 0D then
            exit(Date2DMY(ReportDate, 3));
    end;

    internal procedure SetIRS1099FormReportType(newIRS1099FormReportType: Enum "IRS 1099 Form Report Type")
    begin
        IRS1099FormReportType := newIRS1099FormReportType;
    end;

    local procedure ProcessCompanyTIN(FederalIDNo: Text[30]): Text
    var
        IRSFormsSetup: Record "IRS Forms Setup";
    begin
        IRSFormsSetup.Get();
        if IRSFormsSetup."Protect TIN" = IRSFormsSetup."Protect TIN"::"Protect TIN For Vendors and Company" then
            exit(GetProtectedTIN(FederalIDNo));
        exit(FederalIDNo);
    end;

    local procedure ProcessVendorTIN(FederalIDNo: Text[30]): Text[30]
    var
        IRSFormsSetup: Record "IRS Forms Setup";
    begin
        IRSFormsSetup.Get();
        if IRSFormsSetup."Protect TIN" in [IRSFormsSetup."Protect TIN"::"Protect TIN For Vendors and Company", IRSFormsSetup."Protect TIN"::"Protect TIN For Vendors"] then
            exit(GetProtectedTIN(FederalIDNo));
        exit(FederalIDNo);
    end;

    local procedure GetProtectedTIN(TIN: Text[30]) ProtectedTIN: Text[30]
    begin
        if StrLen(TIN) <= 4 then
            exit(TIN);

        ProtectedTIN := '****-' + CopyStr(TIN, StrLen(TIN) - 3, 4);
    end;
}
