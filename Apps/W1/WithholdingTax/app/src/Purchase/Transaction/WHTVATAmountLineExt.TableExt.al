// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
tableextension 6808 "WHT VAT Amount Line Ext" extends "VAT Amount Line"
{
    fields
    {
        field(6784; "WHT Full GST on Prepayment"; Boolean)
        {
            Caption = 'Full GST on Prepayment';
        }
        field(6785; "WHT VAT Realized"; Decimal)
        {
            Caption = 'VAT Realized';
        }
        field(6786; "WHT Amount Paid"; Decimal)
        {
            Caption = 'Amount Paid';
        }
        field(6787; "WHT VAT Base (ACY)"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = GetAdditionalReportingCurrencyCode();
            Caption = 'VAT Base (ACY)';
            Editable = false;
        }
        field(6788; "WHT VAT Amount (ACY)"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = GetAdditionalReportingCurrencyCode();
            Caption = 'VAT Amount (ACY)';

            trigger OnValidate()
            begin
                TestField("VAT %");
                TestField("WHT VAT Base (ACY)");
                if "WHT VAT Amount (ACY)" / "WHT VAT Base (ACY)" < 0 then
                    Error(MustbeNegativeErr, FieldCaption("WHT VAT Amount (ACY)"));
                "WHT VAT Difference (ACY)" := "WHT VAT Amount (ACY)" - "WHT Calc. VAT Amount (ACY)";
            end;
        }
        field(6789; "WHT Amount Including VAT (ACY)"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = GetAdditionalReportingCurrencyCode();
            Caption = 'Amount Including VAT (ACY)';
            Editable = false;
        }
        field(6790; "WHT Amount (ACY)"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = GetAdditionalReportingCurrencyCode();
            Caption = 'Amount (ACY)';
            Editable = false;
        }
        field(6791; "WHT VAT Difference (ACY)"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = GetAdditionalReportingCurrencyCode();
            Caption = 'VAT Difference (ACY)';
            Editable = false;
        }
        field(6792; "WHT Calc. VAT Amount (ACY)"; Decimal)
        {
            AutoFormatType = 1;
            AutoFormatExpression = GetAdditionalReportingCurrencyCode();
            Caption = 'Calculated VAT Amount (ACY)';
            Editable = false;
        }
    }
    local procedure GetAdditionalReportingCurrencyCode(): Code[10]
    begin
        if not GeneralLedgerSetupRead then begin
            GeneralLedgerSetup.Get();
            GeneralLedgerSetupRead := true;
        end;
        exit(GeneralLedgerSetup."Additional Reporting Currency")
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GeneralLedgerSetupRead: Boolean;
        MustbeNegativeErr: Label '%1 must not be negative.', Comment = '%1-Amount';
}