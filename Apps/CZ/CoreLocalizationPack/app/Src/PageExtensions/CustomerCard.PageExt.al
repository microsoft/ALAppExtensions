pageextension 11704 "Customer Card CZL" extends "Customer Card"
{
    layout
    {
        modify("Registration Number")
        {
            trigger OnDrillDown()
            var
                RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
            begin
                CurrPage.SaveRecord();
                RegistrationLogMgtCZL.AssistEditCustomerRegNo(Rec);
                CurrPage.Update(false);
            end;
        }
        addafter("VAT Registration No.")
        {
#if not CLEAN23
            field("Registration No. CZL"; Rec."Registration No. CZL")
            {
                Caption = 'Registration No. (Obsolete)';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the registration number of customer.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '23.0';
                ObsoleteReason = 'Replaced by standard "Registration Number" field.';

                trigger OnDrillDown()
                var
                    RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
                begin
                    CurrPage.SaveRecord();
                    RegistrationLogMgtCZL.AssistEditCustomerRegNo(Rec);
                    CurrPage.Update(false);
                end;
            }
#endif
            field("Tax Registration No. CZL"; Rec."Tax Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the secondary VAT registration number for the customer.';
                Importance = Additional;
            }
        }
#if not CLEAN21
        addafter("Credit Limit (LCY)")
        {
            field(BalanceOfVendorCZL; BalanceAsVendor)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Balance As Vendor (LCY)';
                Editable = false;
                Enabled = BalanceOfVendorEnabled;
                ToolTip = 'Specifies the vendor''s balance which is connected with certain customer';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'Duplicated field.';
                ObsoleteTag = '21.0';

                trigger OnDrillDown()
                var
                    DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
                    VendorLedgerEntry: Record "Vendor Ledger Entry";
                begin
                    DetailedVendorLedgEntry.SetRange("Vendor No.", Vendor."No.");
                    Rec.CopyFilter("Global Dimension 1 Filter", DetailedVendorLedgEntry."Initial Entry Global Dim. 1");
                    Rec.CopyFilter("Global Dimension 2 Filter", DetailedVendorLedgEntry."Initial Entry Global Dim. 2");
                    Rec.CopyFilter("Currency Filter", DetailedVendorLedgEntry."Currency Code");
                    VendorLedgerEntry.DrillDownOnEntries(DetailedVendorLedgEntry);
                end;
            }
        }
#endif
        addafter(PricesandDiscounts)
        {
            group("Foreign Trade")
            {
                Caption = 'Foreign Trade';

                field("Transaction Type CZL"; Rec."Transaction Type CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default Transaction type for Intrastat reporting purposes.';
                }
                field("Transaction Specification CZL"; Rec."Transaction Specification CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default Transaction specification for Intrastat reporting purposes.';
                }
                field("Transport Method CZL"; Rec."Transport Method CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default Transport Method for Intrastat reporting purposes.';
                }
            }
        }
    }
    actions
    {
        addafter(BackgroundStatement)
        {
            action("Balance Reconciliation CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Balance Reconciliation';
                Image = Balance;
                Promoted = true;
                PromotedCategory = "Report";
                ToolTip = 'Open the report for customer''s balance reconciliation.';

                trigger OnAction()
                begin
                    RunReport(Report::"Cust.- Bal. Reconciliation CZL", Rec."No.");
                end;
            }
        }
    }
#if not CLEAN21
    trigger OnAfterGetCurrRecord()
    begin
        if Vendor.Get(Rec.GetLinkedVendorCZL()) then begin
            Vendor.CalcFields("Balance (LCY)");
            BalanceAsVendor := Vendor."Balance (LCY)";
            BalanceOfVendorEnabled := true;
        end else begin
            BalanceAsVendor := 0;
            BalanceOfVendorEnabled := false;
        end;
    end;

    var
        Vendor: Record Vendor;
        BalanceAsVendor: Decimal;
        [InDataSet]
        BalanceOfVendorEnabled: Boolean;
#endif
}
