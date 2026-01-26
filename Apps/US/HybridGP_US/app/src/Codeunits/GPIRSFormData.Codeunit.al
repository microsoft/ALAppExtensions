namespace Microsoft.DataMigration.GP;

using Microsoft.Finance.VAT.Reporting;

codeunit 42005 "GP IRS Form Data"
{
    Permissions = tabledata "IRS Reporting Period" = RIM,
            tabledata "IRS 1099 Form" = RIM,
            tabledata "IRS 1099 Form Box" = RIM,
            tabledata "IRS 1099 Form Statement Line" = RIM,
            tabledata "IRS 1099 Form Instruction" = RIM;

    var
        IRSFormStatementLineFilterExpressionTxt: Label 'Form Box No.: %1', Comment = '%1 = Form Box No.';

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


    // Copied from internal codeunit 10039 "IRS Forms Data"
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
        AddFormBox(PeriodNo, 'MISC', 'MISC-16', 'State tax withheld', 0);
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
        AddFormStatementLine(PeriodNo, 'MISC', 'MISC-16', 150000, 'State tax withheld');

        AddForm(PeriodNo, 'NEC', 'Nonemployee Compensation');
        AddFormBox(PeriodNo, 'NEC', 'NEC-01', 'Nonemployee Compensation', 600);
        AddFormBox(PeriodNo, 'NEC', 'NEC-02', 'Payer made direct sales totaling $5,000 or more of consumer products to recipient for resale', 5000);
        AddFormBox(PeriodNo, 'NEC', 'NEC-04', 'Federal Income Tax Withheld', 0);
        AddFormStatementLine(PeriodNo, 'NEC', 'NEC-01', 10000, 'Nonemployee Compensation');
        AddFormStatementLine(PeriodNo, 'NEC', Enum::"IRS 1099 Print Value Type"::"Yes/No", 'NEC-02', 20000, 'Payer made direct sales totaling $5,000 or more of consumer products to recipient for resale');
        AddFormStatementLine(PeriodNo, 'NEC', 'NEC-04', 30000, 'Federal Income Tax Withheld');

        AddForm(PeriodNo, 'INT', 'Interest Income');
        AddFormBox(PeriodNo, 'INT', 'INT-01', 'Interest Income', 10);
        AddFormBox(PeriodNo, 'INT', 'INT-02', 'Early withdrawal penalty', -1);
        AddFormBox(PeriodNo, 'INT', 'INT-03', 'Interest on U.S. Savings Bonds and Treas. Obligations', 10);
        AddFormBox(PeriodNo, 'INT', 'INT-04', 'Federal Income Tax Withheld', -1);
        AddFormBox(PeriodNo, 'INT', 'INT-05', 'Investment Expenses', 10);
        AddFormBox(PeriodNo, 'INT', 'INT-06', 'Foreign Tax Paid', -1);
        AddFormBox(PeriodNo, 'INT', 'INT-08', 'Tax-Exempt Interest', 10);
        AddFormBox(PeriodNo, 'INT', 'INT-09', 'Specified Private Activity Bond Interest', 10);
        AddFormBox(PeriodNo, 'INT', 'INT-10', 'Market Discount', 10);
        AddFormBox(PeriodNo, 'INT', 'INT-11', 'Bond Premium', 0.01);
        AddFormBox(PeriodNo, 'INT', 'INT-12', 'Bond Premium on Treasury Obligations', 0.01);
        AddFormBox(PeriodNo, 'INT', 'INT-13', 'Bond Premium on Tax-Exempt Bond', 0.01);
        AddFormStatementLine(PeriodNo, 'INT', 'INT-01', 10000, 'Interest Income');
        AddFormStatementLine(PeriodNo, 'INT', 'INT-02', 20000, 'Early withdrawal penalty');
        AddFormStatementLine(PeriodNo, 'INT', 'INT-03', 30000, 'Interest on U.S. Savings Bonds and Treas. Obligations');
        AddFormStatementLine(PeriodNo, 'INT', 'INT-04', 40000, 'Federal Income Tax Withheld');
        AddFormStatementLine(PeriodNo, 'INT', 'INT-05', 50000, 'Investment Expenses');
        AddFormStatementLine(PeriodNo, 'INT', 'INT-06', 60000, 'Foreign Tax Paid');
        AddFormStatementLine(PeriodNo, 'INT', 'INT-08', 80000, 'Tax-Exempt Interest');
        AddFormStatementLine(PeriodNo, 'INT', 'INT-09', 90000, 'Specified Private Activity Bond Interest');
        AddFormStatementLine(PeriodNo, 'INT', 'INT-10', 100000, 'Market Discount');
        AddFormStatementLine(PeriodNo, 'INT', 'INT-11', 110000, 'Bond Premium');
        AddFormStatementLine(PeriodNo, 'INT', 'INT-12', 120000, 'Bond Premium on Treasury Obligations');
        AddFormStatementLine(PeriodNo, 'INT', 'INT-13', 130000, 'Bond Premium on Tax-Exempt Bond');

        AddForm(PeriodNo, 'DIV', 'Dividends and Distributions');
        AddFormBox(PeriodNo, 'DIV', 'DIV-01-A', 'Total Ordinary Dividends', 10);
        AddFormBox(PeriodNo, 'DIV', 'DIV-01-B', 'Qualified Dividends', 10);
        AddFormBox(PeriodNo, 'DIV', 'DIV-02-A', 'Total capital gain distr.', 0.0);
        AddFormBox(PeriodNo, 'DIV', 'DIV-02-B', 'Unrecap. Sec. 1250 gain', 10.0);
        AddFormBox(PeriodNo, 'DIV', 'DIV-02-C', 'Section 1202 gain', 0.0);
        AddFormBox(PeriodNo, 'DIV', 'DIV-02-D', 'Collectibles (28%) gain', 0.0);
        AddFormBox(PeriodNo, 'DIV', 'DIV-02-E', 'Section 897 ordinary dividends', 0.0);
        AddFormBox(PeriodNo, 'DIV', 'DIV-02-F', 'Section 897 capital gain', 0.0);
        AddFormBox(PeriodNo, 'DIV', 'DIV-03', 'Nondividend distributions', 10.0);
        AddFormBox(PeriodNo, 'DIV', 'DIV-04', 'Federal income tax withheld', -1.0);
        AddFormBox(PeriodNo, 'DIV', 'DIV-05', 'Section 199A dividends', 10.0);
        AddFormBox(PeriodNo, 'DIV', 'DIV-06', 'Investment expenses', 10.0);
        AddFormBox(PeriodNo, 'DIV', 'DIV-07', 'Foreign tax paid', -1.0);
        AddFormBox(PeriodNo, 'DIV', 'DIV-09', 'Cash liquidation distributions', 600.0);
        AddFormBox(PeriodNo, 'DIV', 'DIV-10', 'Noncash liquidation distributions', 600.0);
        AddFormBox(PeriodNo, 'DIV', 'DIV-12', 'Exempt-interest dividends', 0.0);
        AddFormBox(PeriodNo, 'DIV', 'DIV-13', 'Specified private activity bond interest dividends', 0.0);
        AddFormStatementLine(PeriodNo, 'DIV', 'DIV-01-A', 10000, 'Total Ordinary Dividends');
        AddFormStatementLine(PeriodNo, 'DIV', 'DIV-01-B', 20000, 'Qualified Dividends');
        AddFormStatementLine(PeriodNo, 'DIV', 'DIV-02-A', 30000, 'Total capital gain distr.');
        AddFormStatementLine(PeriodNo, 'DIV', 'DIV-02-B', 40000, 'Unrecap. Sec. 1250 gain');
        AddFormStatementLine(PeriodNo, 'DIV', 'DIV-02-C', 50000, 'Section 1202 gain');
        AddFormStatementLine(PeriodNo, 'DIV', 'DIV-02-D', 60000, 'Collectibles (28%) gain');
        AddFormStatementLine(PeriodNo, 'DIV', 'DIV-02-E', 70000, 'Section 897 ordinary dividends');
        AddFormStatementLine(PeriodNo, 'DIV', 'DIV-02-F', 80000, 'Section 897 capital gain');
        AddFormStatementLine(PeriodNo, 'DIV', 'DIV-03', 90000, 'Nondividend distributions');
        AddFormStatementLine(PeriodNo, 'DIV', 'DIV-04', 100000, 'Federal income tax withheld');
        AddFormStatementLine(PeriodNo, 'DIV', 'DIV-05', 110000, 'Section 199A dividends');
        AddFormStatementLine(PeriodNo, 'DIV', 'DIV-06', 120000, 'Investment expenses');
        AddFormStatementLine(PeriodNo, 'DIV', 'DIV-07', 130000, 'Foreign Tax Paid');
        AddFormStatementLine(PeriodNo, 'DIV', 'DIV-09', 140000, 'Cash liquidation distributions');
        AddFormStatementLine(PeriodNo, 'DIV', 'DIV-10', 150000, 'Noncash liquidation distributions');
        AddFormStatementLine(PeriodNo, 'DIV', 'DIV-12', 160000, 'Exempt-interest dividends');
        AddFormStatementLine(PeriodNo, 'DIV', 'DIV-13', 170000, 'Specified private activity bond interest dividends');

        AddFormInstructionLines(PeriodNo);
    end;

    local procedure AddFormInstructionLines(PeriodNo: Code[20])
    begin
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

        AddFormInstructionLine(PeriodNo, 'INT', 1, '', 'The information provided may be different for covered and noncovered securities. For a description of covered securities, see the Instructions for Form 8949. For a taxable covered security acquired at a premium, unless you notified the payer in writing in accordance with Regulations section 1.6045-1(n)(5) that you did not want to amortize the premium under section 171, or for a tax-exempt covered security acquired at a premium, your payer must generally report either (1) a net amount of interest that reflects the offset of the amount of interest paid to you by the amount of premium amortization allocable to the payment(s), or (2) a gross amount for both the interest paid to you and the premium amortization allocable to the payment(s). If you did notify your payer that you did not want to amortize the premium on a taxable covered security, then your payer will only report the gross amount of interest paid to you. For a noncovered security acquired at a premium, your payer is only required to report the gross amount of interest paid to you.');
        AddFormInstructionLine(PeriodNo, 'INT', 2, 'Recipient’s taxpayer identification number (TIN).', 'For your protection, this form may show only the last four digits of your TIN (social security number (SSN), individual taxpayer identification number (ITIN), adoption taxpayer identification number (ATIN), or employer identification number (EIN)). However, the issuer has reported your complete TIN to the IRS.');
        AddFormInstructionLine(PeriodNo, 'INT', 3, 'FATCA filing requirement.', 'If the FATCA filing requirement box is checked, the payer is reporting on this Form 1099 to satisfy its chapter 4 account reporting requirement. You may also have a filing requirement. See the Instructions for Form 8938.');
        AddFormInstructionLine(PeriodNo, 'INT', 4, 'Account number.', 'May show an account or other unique number the payer assigned to distinguish your account.');
        AddFormInstructionLine(PeriodNo, 'INT', 5, 'Box 1.', 'Shows taxable interest paid to you during the calendar year by the payer. This does not include interest shown in box 3. May also show the total amount of the credits from clean renewable energy bonds, new clean renewable energy bonds, qualified energy conservation bonds, qualified zone academy bonds, qualified school construction bonds, and build America bonds that must be included in your interest income. These amounts were treated as paid to you during the calendar year on the credit allowance dates (March 15, June 15, September 15, and December 15). For more information, see Form 8912. See the instructions above for a taxable covered security acquired at a premium.');
        AddFormInstructionLine(PeriodNo, 'INT', 6, 'Box 2.', 'Shows interest or principal forfeited because of early withdrawal of time savings. You may deduct this amount to figure your adjusted gross income on your income tax return. See the Instructions for Form 1040 to see where to take the deduction.');
        AddFormInstructionLine(PeriodNo, 'INT', 7, 'Box 3.', 'Shows interest on U.S. Savings Bonds, Treasury bills, Treasury bonds, and Treasury notes. This may or may not all be taxable. See Pub. 550. This interest is exempt from state and local income taxes. This interest is not included in box 1. See the instructions above for a taxable covered security acquired at a premium.');
        AddFormInstructionLine(PeriodNo, 'INT', 8, 'Box 4.', 'Shows backup withholding. Generally, a payer must backup withhold if you did not furnish your TIN or you did not furnish the correct TIN to the payer. See Form W-9. Include this amount on your income tax return as tax withheld.');
        AddFormInstructionLine(PeriodNo, 'INT', 9, 'Box 5.', 'Any amount shown is your share of investment expenses of a single-class REMIC. This amount is included in box 1. Note: This amount is not deductible.');
        AddFormInstructionLine(PeriodNo, 'INT', 10, 'Box 6.', 'Shows foreign tax paid. You may be able to claim this tax as a deduction or a credit on your Form 1040 or 1040-SR. See your tax return instructions.');
        AddFormInstructionLine(PeriodNo, 'INT', 11, 'Box 7.', 'Shows the country or U.S. possession to which the foreign tax was paid.');
        AddFormInstructionLine(PeriodNo, 'INT', 12, 'Box 8.', 'Shows tax-exempt interest paid to you during the calendar year by the payer. See how to report this amount in the Instructions for Form 1040. This amount may be subject to backup withholding. See Box 4 above. See the instructions above for a tax-exempt covered security acquired at a premium.');
        AddFormInstructionLine(PeriodNo, 'INT', 13, 'Box 9.', 'Shows tax-exempt interest subject to the alternative minimum tax. This amount is included in box 8. See the Instructions for Form 6251. See the instructions above for a tax-exempt covered security acquired at a premium.');
        AddFormInstructionLine(PeriodNo, 'INT', 14, 'Box 10.', 'For a taxable or tax-exempt covered security, if you made an election under section 1278(b) to include market discount in income as it accrues and you notified your payer of the election in writing in accordance with Regulations section 1.6045-1(n)(5), shows the market discount that accrued on the debt instrument during the year while held by you, unless it was reported on Form 1099-OID. For a taxable or tax-exempt covered security acquired on or after January 1, 2015, accrued market discount will be calculated on a constant yield basis unless you notified your payer in writing in accordance with Regulations section 1.6045-1(n)(5) that you did not want to make a constant yield election for market discount under section 1276(b). Report the accrued market discount on your income tax return as directed in the Instructions for Form 1040. Market discount on a tax-exempt security is includible in taxable income as interest income.');
        AddFormInstructionLine(PeriodNo, 'INT', 15, 'Box 11.', 'For a taxable covered security (other than a U.S. Treasury obligation), shows the amount of premium amortization allocable to the interest payment(s), unless you notified the payer in writing in accordance with Regulations section 1.6045-1(n)(5) that you did not want to amortize bond premium under section 171. If an amount is reported in this box, see the Instructions for Schedule B (Form 1040) to determine the net amount of interest includible in income on Form 1040 or 1040-SR with respect to the security. If an amount is not reported in this box for a taxable covered security acquired at a premium and the payer is reporting premium amortization, the payer has reported a net amount of interest in box 1. If the amount in box 11 is greater than the amount of interest paid on the covered security, see Regulations section 1.171-2(a)(4).');
        AddFormInstructionLine(PeriodNo, 'INT', 16, 'Box 12.', 'For a U.S. Treasury obligation that is a covered security, shows the amount of premium amortization allocable to the interest payment(s), unless you notified the payer in writing in accordance with Regulations section 1.6045-1(n)(5) that you did not want to amortize bond premium under section 171. If an amount is reported in this box, see the Instructions for Schedule B (Form 1040) to determine the net amount of interest includible in income on Form 1040 or 1040-SR with respect to the U.S. Treasury obligation. If an amount is not reported in this box for a U.S. Treasury obligation that is a covered security acquired at a premium and the payer is reporting premium amortization, the payer has reported a net amount of interest in box 3. If the amount in box 12 is greater than the amount of interest paid on the U.S. Treasury obligation, see Regulations section 1.171-2(a)(4).');
        AddFormInstructionLine(PeriodNo, 'INT', 17, 'Box 13.', 'For a tax-exempt covered security, shows the amount of premium amortization allocable to the interest payment(s). If an amount is reported in this box, see Pub. 550 to determine the net amount of tax-exempt interest reportable on Form 1040 or 1040-SR. If an amount is not reported in this box for a tax-exempt covered security acquired at a premium, the payer has reported a net amount of interest in box 8 or 9, whichever is applicable. If the amount in box 13 is greater than the amount of interest paid on the tax-exempt covered security, the excess is a nondeductible loss. See Regulations section 1.171-2(a)(4)(ii).');
        AddFormInstructionLine(PeriodNo, 'INT', 18, 'Box 14.', 'Shows CUSIP number(s) for tax-exempt bond(s) on which tax-exempt interest was paid, or tax credit bond(s) on which taxable interest was paid or tax credit was allowed, to you during the calendar year. If blank, no CUSIP number was issued for the bond(s).');
        AddFormInstructionLine(PeriodNo, 'INT', 19, 'Boxes 15-17.', 'State tax withheld reporting boxes.');
        AddFormInstructionLine(PeriodNo, 'INT', 20, 'Nominees.', 'If this form includes amounts belonging to another person(s), you are considered a nominee recipient. Complete a Form 1099-INT for each of the other owners showing the income allocable to each. File Copy A of the form with the IRS. Furnish Copy B to each owner. List yourself as the “payer” and the other owner(s) as the “recipient.” File Form(s) 1099-INT with Form 1096 with the Internal Revenue Service Center for your area. On Form 1096, list yourself as the “filer.” A spouse is not required to file a nominee return to show amounts owned by the other spouse');
        AddFormInstructionLine(PeriodNo, 'INT', 21, 'Future developments.', 'For the latest information about developments related to Form 1099-INT and its instructions, such as legislation enacted after they were published, go to www.irs.gov/Form1099INT.');
        AddFormInstructionLine(PeriodNo, 'INT', 22, 'Free File Program.', 'Go to www.irs.gov/FreeFile to see if you qualify for no-cost online federal tax preparation, e-filing, and direct deposit or payment options.');

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

        AddFormInstructionLine(PeriodNo, 'DIV', 1, 'Recipient’s taxpayer identification number (TIN).', 'For your protection, this form may show only the last four digits of your TIN (SSN, ITIN, ATIN, or EIN). However, the issuer has reported your complete TIN to the IRS.');
        AddFormInstructionLine(PeriodNo, 'DIV', 2, 'Account number.', 'May show an account or other unique number the payer assigned to distinguish your account.');
        AddFormInstructionLine(PeriodNo, 'DIV', 3, 'Box 1a.', 'Shows total ordinary dividends that are taxable. Include this amount on the “Ordinary dividends” line of Form 1040 or 1040-SR. Also report it on Schedule B (Form 1040), if required.');
        AddFormInstructionLine(PeriodNo, 'DIV', 4, 'Box 1b.', 'Shows the portion of the amount in box 1a that may be eligible for reduced capital gains rates. See the Instructions for Form 1040 for how to determine this amount and where to report. The amount shown may be dividends a corporation paid directly to you as a participant (or beneficiary of a participant) in an employee stock ownership plan (ESOP). Report it as a dividend on your Form 1040 or 1040-SR but treat it as a plan distribution, not as investment income, for any other purpose.');
        AddFormInstructionLine(PeriodNo, 'DIV', 5, 'Box 2a.', 'Shows total capital gain distributions from a regulated investment company (RIC) or real estate investment trust (REIT). See How To Report in the Instructions for Schedule D (Form 1040). But, if no amount is shown in boxes 2b, 2c, 2d, and 2f and your only capital gains and losses are capital gain distributions, you may be able to report the amounts shown in box 2a on your Form 1040 or 1040-SR rather than Schedule D. See the Instructions for Form 1040.');
        AddFormInstructionLine(PeriodNo, 'DIV', 6, 'Box 2b.', 'Shows the portion of the amount in box 2a that is unrecaptured section 1250 gain from certain depreciable real property. See the Unrecaptured Section 1250 Gain Worksheet in the Instructions for Schedule D (Form 1040).');
        AddFormInstructionLine(PeriodNo, 'DIV', 7, 'Box 2c.', 'Shows the portion of the amount in box 2a that is section 1202 gain from certain small business stock that may be subject to an exclusion. See the Schedule D (Form 1040) instructions.');
        AddFormInstructionLine(PeriodNo, 'DIV', 8, 'Box 2d.', 'Shows the portion of the amount in box 2a that is 28% rate gain from sales or exchanges of collectibles. If required, use this amount when completing the 28% Rate Gain Worksheet in the Instructions for Schedule D (Form 1040).');
        AddFormInstructionLine(PeriodNo, 'DIV', 9, 'Box 2e.', 'Shows the portion of the amount in box 1a that is section 897 gain attributable to disposition of U.S. real property interests (USRPI).');
        AddFormInstructionLine(PeriodNo, 'DIV', 10, 'Box 2f.', 'Shows the portion of the amount in box 2a that is section 897 gain attributable to disposition of USRPI.');
        AddFormInstructionLine(PeriodNo, 'DIV', 11, 'Note:', 'Boxes 2e and 2f apply only to foreign persons and entities whose income maintains its character when passed through or distributed to its direct or indirect foreign owners or beneficiaries. It is generally treated as effectively connected to a trade or business within the United States. See the instructions for your tax return.');
        AddFormInstructionLine(PeriodNo, 'DIV', 12, 'Box 3.', 'Shows a return of capital. To the extent of your cost (or other basis) in the stock, the distribution reduces your basis and is not taxable. Any amount received in excess of your basis is taxable to you as capital gain. See Pub. 550.');
        AddFormInstructionLine(PeriodNo, 'DIV', 13, 'Box 4.', 'Shows backup withholding. A payer must backup withhold on certain payments if you did not give your TIN to the payer. See Form W-9 for information on backup withholding. Include this amount on your income tax return as tax withheld.');
        AddFormInstructionLine(PeriodNo, 'DIV', 14, 'Box 5.', 'Shows the portion of the amount in box 1a that may be eligible for the 20% qualified business income deduction under section 199A. See the instructions for Form 8995 and Form 8995-A.');
        AddFormInstructionLine(PeriodNo, 'DIV', 15, 'Box 6.', 'Shows your share of expenses of a nonpublicly offered RIC, generally a nonpublicly offered mutual fund. This amount is included in box 1a.');
        AddFormInstructionLine(PeriodNo, 'DIV', 16, 'Box 7.', 'Shows the foreign tax that you may be able to claim as a deduction or a credit on Form 1040 or 1040-SR. See the Instructions for Form 1040.');
        AddFormInstructionLine(PeriodNo, 'DIV', 17, 'Box 8.', 'This box should be left blank if a RIC reported the foreign tax shown in box 7.');
        AddFormInstructionLine(PeriodNo, 'DIV', 18, 'Boxes 9 and 10.', 'Show cash and noncash liquidation distributions.');
        AddFormInstructionLine(PeriodNo, 'DIV', 19, 'Box 11.', 'If the FATCA filing requirement box is checked, the payer is reporting on this Form 1099 to satisfy its account reporting requirement under chapter 4 of the Internal Revenue Code. You may also have a filing requirement. See the Instructions for Form 8938.');
        AddFormInstructionLine(PeriodNo, 'DIV', 20, 'Box 12.', 'Shows exempt-interest dividends from a mutual fund or other RIC paid to you during the calendar year. See the Instructions for Form 1040 for where to report. This amount may be subject to backup withholding. See Box 4 above.');
        AddFormInstructionLine(PeriodNo, 'DIV', 21, 'Box 13.', 'Shows exempt-interest dividends subject to the alternative minimum tax. This amount is included in box 12. See the Instructions for Form 6251.');
        AddFormInstructionLine(PeriodNo, 'DIV', 22, 'Boxes 14-16.', 'State income tax withheld reporting boxes.');
        AddFormInstructionLine(PeriodNo, 'DIV', 23, 'Nominees.', 'If this form includes amounts belonging to another person, you are considered a nominee recipient. You must file Form 1099-DIV (with a Form 1096) with the IRS for each of the other owners to show their share of the income, and you must furnish a Form 1099-DIV to each. A spouse is not required to file a nominee return to show amounts owned by the other spouse. See the current General Instructions for Certain Information Returns.');
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