pageextension 31197 "Cash Flow Avail. Lines CZZ" extends "Cash Flow Availability Lines"
{
    layout
    {
#if not CLEAN19
#pragma warning disable AL0432
        modify(SalesAdvances)
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify(PurchaseAdvances)
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
#pragma warning restore AL0432
#endif
        addafter(Tax)
        {
            field(SalesAdvancesCZZ; Rec."Sales Advances CZZ")
            {
                ApplicationArea = Basic, Suite;
                AutoFormatExpression = FormatExpression();
                AutoFormatType = 11;
                Caption = 'Sales Advances';
                ToolTip = 'Specifies an amount of sales advances';
#if not CLEAN19
                Visible = AdvancePaymentsEnabledCZZ;
#endif

                trigger OnDrillDown()
                begin
                    CashFlowForecast.DrillDownSourceTypeEntries(Enum::"Cash Flow Source Type"::"Sales Advance Letters CZZ");
                end;
            }
            field(PurchaseAdvancesCZZ; Rec."Purchase Advances CZZ")
            {
                ApplicationArea = Basic, Suite;
                AutoFormatExpression = FormatExpression();
                AutoFormatType = 11;
                Caption = 'Purchase Advances';
                ToolTip = 'Specifies an amount of purchase advances';
#if not CLEAN19
                Visible = AdvancePaymentsEnabledCZZ;
#endif

                trigger OnDrillDown()
                begin
                    CashFlowForecast.DrillDownSourceTypeEntries(Enum::"Cash Flow Source Type"::"Purchase Advance Letters CZZ");
                end;
            }
        }
    }
    var
#if not CLEAN19
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
#endif
        MatrixManagementCZZ: Codeunit "Matrix Management";
        RoundingFactorFormatStringCZZ: Text;
#if not CLEAN19
        AdvancePaymentsEnabledCZZ: Boolean;

    trigger OnOpenPage()
    begin
        AdvancePaymentsEnabledCZZ := AdvancePaymentsMgtCZZ.IsEnabled();
    end;
#endif

    local procedure FormatExpression(): Text
    begin
        if RoundingFactorFormatStringCZZ <> '' then
            exit(RoundingFactorFormatStringCZZ);

        RoundingFactorFormatStringCZZ := MatrixManagementCZZ.FormatRoundingFactor(RoundingFactor, false);
    end;
}