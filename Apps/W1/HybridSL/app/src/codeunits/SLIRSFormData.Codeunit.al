// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.Finance.VAT.Reporting;

codeunit 47009 "SL IRS Form Data"
{
    Permissions = tabledata "IRS Reporting Period" = RIM,
                tabledata "IRS 1099 Form" = RIM,
                tabledata "IRS 1099 Form Box" = RIM,
                tabledata "IRS 1099 Form Statement Line" = RIM,
                tabledata "IRS 1099 Form Instruction" = RIM;

    var
        IRSFormStatementLineFilterExpressionTxt: Label 'Form Box No.: %1', Comment = '%1 = Form Box No.', Locked = true;

    internal procedure CreateIRSFormsReportingPeriodIfNeeded(ReportingYear: Integer)
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
        PeriodNo: Code[20];
    begin
        PeriodNo := Format(ReportingYear);
        if not IRSReportingPeriod.Get(PeriodNo) then begin
            IRSReportingPeriod.Validate("No.", PeriodNo);
            IRSReportingPeriod.Validate("Starting Date", DMY2Date(1, 1, ReportingYear));
            IRSReportingPeriod.Validate("Ending Date", DMY2Date(31, 12, ReportingYear));
            IRSReportingPeriod.Validate("Description", PeriodNo);
            IRSReportingPeriod.Insert(true);

            PopulateFormsAndBoxes(PeriodNo);
        end;
    end;

    local procedure PopulateFormsAndBoxes(PeriodNo: Code[20])
    begin
        AddForm(PeriodNo, 'MISC', 'Miscellaneous Income');
        AddFormBox(PeriodNo, 'MISC', 'MISC-01', 'Rents', 600);
        AddFormBox(PeriodNo, 'MISC', 'MISC-02', 'Royalties', 10);
        AddFormBox(PeriodNo, 'MISC', 'MISC-03', 'Other Income', 600);
        AddFormBox(PeriodNo, 'MISC', 'MISC-04', 'Federal Income Tax Withheld', 0);
        AddFormBox(PeriodNo, 'MISC', 'MISC-05', 'Fishing Boat Proceeds', 600);
        AddFormBox(PeriodNo, 'MISC', 'MISC-06', 'Medical and Health Care Payments', 600);
        AddFormBox(PeriodNo, 'MISC', 'MISC-07', 'Payer made direct sales totaling $5,000 or more of consumer products to recipient for resale', 5000);
        AddFormBox(PeriodNo, 'MISC', 'MISC-08', 'Substitute Payments in Lieu of Dividends or Interest', 10);
        AddFormBox(PeriodNo, 'MISC', 'MISC-09', 'Crop Insurance Proceeds', 1);
        AddFormBox(PeriodNo, 'MISC', 'MISC-10', 'Gross Proceeds Paid to an Attorney', 0);
        AddFormBox(PeriodNo, 'MISC', 'MISC-11', 'Fish purchased for resale', 600);
        AddFormBox(PeriodNo, 'MISC', 'MISC-12', 'Section 409A deferrals', 600);
        AddFormBox(PeriodNo, 'MISC', 'MISC-14', 'Excess golden parachute payments', 0);
        AddFormBox(PeriodNo, 'MISC', 'MISC-15', 'Nonqualified deferred compensation', 0);
        AddFormStatementLine(PeriodNo, 'MISC', 'MISC-01', 10000, 'Rents');
        AddFormStatementLine(PeriodNo, 'MISC', 'MISC-02', 20000, 'Royalties');
        AddFormStatementLine(PeriodNo, 'MISC', 'MISC-03', 30000, 'Other Income');
        AddFormStatementLine(PeriodNo, 'MISC', 'MISC-04', 40000, 'Federal Income Tax Withheld');
        AddFormStatementLine(PeriodNo, 'MISC', 'MISC-05', 50000, 'Fishing Boat Proceeds');
        AddFormStatementLine(PeriodNo, 'MISC', 'MISC-06', 60000, 'Medical and Health Care Payments');
        AddFormStatementLine(PeriodNo, 'MISC', Enum::"IRS 1099 Print Value Type"::"Yes/No", 'MISC-07', 70000, 'Payer made direct sales totaling $5,000 or more of consumer products to recipient for resale');
        AddFormStatementLine(PeriodNo, 'MISC', 'MISC-08', 80000, 'Substitute Payments in Lieu of Dividends or Interest');
        AddFormStatementLine(PeriodNo, 'MISC', 'MISC-09', 90000, 'Crop Insurance Proceeds');
        AddFormStatementLine(PeriodNo, 'MISC', 'MISC-10', 100000, 'Gross Proceeds Paid to an Attorney');
        AddFormStatementLine(PeriodNo, 'MISC', 'MISC-11', 110000, 'Fish purchased for resale');
        AddFormStatementLine(PeriodNo, 'MISC', 'MISC-12', 120000, 'Section 409A deferrals');
        AddFormStatementLine(PeriodNo, 'MISC', 'MISC-14', 130000, 'Excess golden parachute payments');
        AddFormStatementLine(PeriodNo, 'MISC', 'MISC-15', 140000, 'Nonqualified deferred compensation');

        AddForm(PeriodNo, 'NEC', 'Nonemployee Compensation');
        AddFormBox(PeriodNo, 'NEC', 'NEC-01', 'Nonemployee Compensation', 600);
        AddFormStatementLine(PeriodNo, 'NEC', 'NEC-01', 10000, 'Nonemployee Compensation');

        AddFormInstructionLines(PeriodNo);
    end;

    procedure AddFormInstructionLines(PeriodNo: Code[20])
    begin
        AddNecFormInstructionLines(PeriodNo);
        AddMiscFormInstructionLines(PeriodNo);
    end;

    local procedure AddNecFormInstructionLines(PeriodNo: Code[20])
    var
        IRS1099Form: Record "IRS 1099 Form";
    begin
        if not IRS1099Form.Get(PeriodNo, 'NEC') then
            exit;
        AddFormInstructionLine(PeriodNo, 'NEC', 1, '', 'You received this form instead of Form W-2 because the payer did not consider you an employee and did not withhold income tax or social security and Medicare tax. If you believe you are an employee and cannot get the payer to correct this form, report the amount shown in box 1 on the line for “Wages, salaries, tips, etc.” of Form 1040, 1040-SR, or 1040-NR. You must also complete Form 8919 and attach it to your return. For more information, see Pub. 1779, Independent Contractor or Employee. If you are not an employee but the amount in box 1 is not self-employment (SE) income (for example, it is income from a sporadic activity or a hobby), report the amount shown in box 1 on the “Other income” line (on Schedule 1 (Form 1040)).');
        AddFormInstructionLine(PeriodNo, 'NEC', 2, 'Recipient’s taxpayer identification number (TIN).', 'For your protection, this form may show only the last four digits of your TIN (social security number (SSN), individual taxpayer identification number (ITIN), adoption taxpayer identification number (ATIN), or employer identification number (EIN)). However, the issuer has reported your complete TIN to the IRS.');
        AddFormInstructionLine(PeriodNo, 'NEC', 3, 'Account number.', 'May show an account or other unique number the payer assigned to distinguish your account.');
        AddFormInstructionLine(PeriodNo, 'NEC', 4, 'Box 1.', 'Shows nonemployee compensation. If the amount in this box is SE income, report it on Schedule C or F (Form 1040) if a sole proprietor, or on Form 1065 and Schedule K-1 (Form 1065) if a partnership, and the recipient/partner completes Schedule SE (Form 1040).');
        AddFormInstructionLine(PeriodNo, 'NEC', 5, 'Note:', 'If you are receiving payments on which no income, social security, and Medicare taxes are withheld, you should make estimated tax payments. See Form 1040-ES (or Form 1040-ES (NR)). Individuals must report these amounts as explained in these box 1 instructions. Corporations, fiduciaries, and partnerships must report these amounts on the appropriate line of their tax returns.');
        AddFormInstructionLine(PeriodNo, 'NEC', 6, 'Box 2.', 'If checked, consumer products totaling $5,000 or more were sold to you for resale, on a buy-sell, a deposit-commission, or other basis. Generally, report any income from your sale of these products on Schedule C (Form 1040).');
        AddFormInstructionLine(PeriodNo, 'NEC', 7, 'Box 3.', 'Reserved for future use.');
        AddFormInstructionLine(PeriodNo, 'NEC', 8, 'Box 4.', 'Shows backup withholding. A payer must backup withhold on certain payments if you did not give your TIN to the payer. See Form W-9, Request for Taxpayer Identification Number and Certification, for information on backup withholding. Include this amount on your income tax return as tax withheld.');
        AddFormInstructionLine(PeriodNo, 'NEC', 9, 'Boxes 5-7.', 'State income tax withheld reporting boxes.');
        AddFormInstructionLine(PeriodNo, 'NEC', 10, 'Future developments.', 'For the latest information about developments related to Form 1099-NEC and its instructions, such as legislation enacted after they were published, go to www.irs.gov/Form1099NEC.');
        AddFormInstructionLine(PeriodNo, 'NEC', 11, 'Free File Program.', 'Go to www.irs.gov/FreeFile to see if you qualify for no-cost online federal tax preparation, e-filing, and direct deposit or payment options.');
    end;

    local procedure AddMiscFormInstructionLines(PeriodNo: Code[20])
    var
        IRS1099Form: Record "IRS 1099 Form";
    begin
        if not IRS1099Form.Get(PeriodNo, 'MISC') then
            exit;
        AddFormInstructionLine(PeriodNo, 'MISC', 1, 'Recipient’s taxpayer identification number (TIN).', 'For your protection, this form may show only the last four digits of your TIN (social security number (SSN), individual taxpayer identification number (ITIN), adoption taxpayer identification number (ATIN), or employer identification number (EIN)). However, the issuer has reported your complete TIN to the IRS.');
        AddFormInstructionLine(PeriodNo, 'MISC', 2, 'Account number.', 'May show an account or other unique number the payer assigned to distinguish your account.');
        AddFormInstructionLine(PeriodNo, 'MISC', 3, 'Amounts shown may be subject to self-employment (SE) tax.', 'Individuals should see the Instructions for Schedule SE (Form 1040). Corporations, fiduciaries, or partnerships must report the amounts on the appropriate line of their tax returns.');
        AddFormInstructionLine(PeriodNo, 'MISC', 4, 'Form 1099-MISC incorrect?', 'If this form is incorrect or has been issued in error, contact the payer. If you cannot get this form corrected, attach an explanation to your tax return and report your information correctly.');
        AddFormInstructionLine(PeriodNo, 'MISC', 5, 'Box 1.', 'Report rents from real estate on Schedule E (Form 1040). However, report rents on Schedule C (Form 1040) if you provided significant services to the tenant, sold real estate as a business, or rented personal property as a business. See Pub. 527.');
        AddFormInstructionLine(PeriodNo, 'MISC', 6, 'Box 2.', 'Report royalties from oil, gas, or mineral properties; copyrights; and patents on Schedule E (Form 1040). However, report payments for a working interest as explained in the Schedule E (Form 1040) instructions. For royalties on timber, coal, and iron ore, see Pub. 544.');
        AddFormInstructionLine(PeriodNo, 'MISC', 7, 'Box 3.', 'Generally, report this amount on the “Other income” line of Schedule 1 (Form 1040) and identify the payment. The amount shown may be payments received as the beneficiary of a deceased employee, prizes, awards, taxable damages, Indian gaming profits, or other taxable income. See Pub. 525. If it is trade or business income, report this amount on Schedule C or F (Form 1040).');
        AddFormInstructionLine(PeriodNo, 'MISC', 8, 'Box 4.', 'Shows backup withholding or withholding on Indian gaming profits. Generally, a payer must backup withhold if you did not furnish your TIN. See Form W-9 and Pub. 505 for more information. Report this amount on your income tax return as tax withheld.');
        AddFormInstructionLine(PeriodNo, 'MISC', 9, 'Box 5.', 'Shows the amount paid to you as a fishing boat crew member by the operator, who considers you to be self-employed. Self-employed individuals must report this amount on Schedule C (Form 1040). See Pub. 334.');
        AddFormInstructionLine(PeriodNo, 'MISC', 10, 'Box 6.', 'For individuals, report on Schedule C (Form 1040).');
        AddFormInstructionLine(PeriodNo, 'MISC', 11, 'Box 7.', 'If checked, consumer products totaling $5,000 or more were sold to you for resale, on a buy-sell, a deposit-commission, or other basis. Generally, report any income from your sale of these products on Schedule C (Form 1040).');
        AddFormInstructionLine(PeriodNo, 'MISC', 12, 'Box 8.', 'Shows substitute payments in lieu of dividends or tax-exempt interest received by your broker on your behalf as a result of a loan of your securities. Report on the “Other income” line of Schedule 1 (Form 1040).');
        AddFormInstructionLine(PeriodNo, 'MISC', 13, 'Box 9.', 'Report this amount on Schedule F (Form 1040).');
        AddFormInstructionLine(PeriodNo, 'MISC', 14, 'Box 10.', 'Shows gross proceeds paid to an attorney in connection with legal services. Report only the taxable part as income on your return.');
        AddFormInstructionLine(PeriodNo, 'MISC', 15, 'Box 11.', 'Shows the amount of cash you received for the sale of fish if you are in the trade or business of catching fish.');
        AddFormInstructionLine(PeriodNo, 'MISC', 16, 'Box 12.', 'May show current year deferrals as a nonemployee under a nonqualified deferred compensation (NQDC) plan that is subject to the requirements of section 409A plus any earnings on current and prior year deferrals.');
        AddFormInstructionLine(PeriodNo, 'MISC', 17, 'Box 13.', 'If the FATCA filing requirement box is checked, the payer is reporting on this Form 1099 to satisfy its account reporting requirement under chapter 4 of the Internal Revenue Code. You may also have a filing requirement. See the Instructions for Form 8938.');
        AddFormInstructionLine(PeriodNo, 'MISC', 18, 'Box 14.', 'Shows your total compensation of excess golden parachute payments subject to a 20% excise tax. See your tax return instructions for where to report.');
        AddFormInstructionLine(PeriodNo, 'MISC', 19, 'Box 15.', 'Shows income as a nonemployee under an NQDC plan that does not meet the requirements of section 409A. Any amount included in box 12 that is currently taxable is also included in this box. Report this amount as income on your tax return. This income is also subject to a substantial additional tax to be reported on Form 1040, 1040-SR, or 1040-NR. See the instructions for your tax return.');
        AddFormInstructionLine(PeriodNo, 'MISC', 20, 'Boxes 16-18.', 'Show state or local income tax withheld from the payments.');
        AddFormInstructionLine(PeriodNo, 'MISC', 21, 'Future developments.', 'For the latest information about developments related to Form 1099-MISC and its instructions, such as legislation enacted after they were published, go to www.irs.gov/Form1099MISC.');
        AddFormInstructionLine(PeriodNo, 'MISC', 22, 'Free File Program.', 'Go to www.irs.gov/FreeFile to see if you qualify for no-cost online federal tax preparation, e-filing, and direct deposit or payment options.');
    end;

    local procedure AddForm(PeriodNo: Code[20]; FormNo: Code[20]; Description: Text)
    var
        IRS1099Form: Record "IRS 1099 Form";
    begin
        IRS1099Form.Validate("Period No.", PeriodNo);
        IRS1099Form.Validate("No.", FormNo);
        IRS1099Form.Validate("Description", Description);
        IRS1099Form.Insert(true);
    end;

    local procedure AddFormBox(PeriodNo: Code[20]; FormNo: Code[20]; FormBoxNo: Code[20]; Description: Text; MinimumReportableAmount: Decimal)
    var
        IRS1099FormBox: Record "IRS 1099 Form Box";
    begin
        IRS1099FormBox.Validate("Period No.", PeriodNo);
        IRS1099FormBox.Validate("Form No.", FormNo);
        IRS1099FormBox.Validate("No.", FormBoxNo);
        IRS1099FormBox.Validate("Description", Description);
        IRS1099FormBox.Validate("Minimum Reportable Amount", MinimumReportableAmount);
        IRS1099FormBox.Insert(true);
    end;

    local procedure AddFormStatementLine(PeriodNo: Code[20]; FormNo: Code[20]; FormBoxNo: Code[20]; StatementLineNo: Integer; Description: Text)
    begin
        AddFormStatementLine(PeriodNo, FormNo, Enum::"IRS 1099 Print Value Type"::Amount, FormBoxNo, StatementLineNo, Description);
    end;

    local procedure AddFormStatementLine(PeriodNo: Code[20]; FormNo: Code[20]; Type: Enum "IRS 1099 Print Value Type"; FormBoxNo: Code[20]; StatementLineNo: Integer; Description: Text)
    var
        IRS1099FormStatementLine: Record "IRS 1099 Form Statement Line";
    begin
        IRS1099FormStatementLine.Validate("Period No.", PeriodNo);
        IRS1099FormStatementLine.Validate("Form No.", FormNo);
        IRS1099FormStatementLine.Validate("Line No.", StatementLineNo);
        IRS1099FormStatementLine.Validate("Print Value Type", Type);
        IRS1099FormStatementLine.Validate("Row No.", FormBoxNo);
        IRS1099FormStatementLine.Validate("Description", Description);
        IRS1099FormStatementLine.Validate("Filter Expression", StrSubstNo(IRSFormStatementLineFilterExpressionTxt, FormBoxNo));
        IRS1099FormStatementLine.Insert(true);
    end;

    local procedure AddFormInstructionLine(PeriodNo: Code[20]; FormNo: Code[20]; LineNo: Integer; Header: Text; Description: Text)
    var
        IRS1099FormInstruction: Record "IRS 1099 Form Instruction";
    begin
        IRS1099FormInstruction.Validate("Period No.", PeriodNo);
        IRS1099FormInstruction.Validate("Form No.", FormNo);
        IRS1099FormInstruction.Validate("Line No.", LineNo);
        IRS1099FormInstruction.Validate(Header, Header);
        IRS1099FormInstruction.Validate(Description, Description);
        IRS1099FormInstruction.Insert(true);
    end;
}