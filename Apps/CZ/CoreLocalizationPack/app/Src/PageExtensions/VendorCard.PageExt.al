pageextension 11705 "Vendor Card CZL" extends "Vendor Card"
{
    layout
    {
        addafter("VAT Registration No.")
        {
            field("Registration No. CZL"; Rec."Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the registration number of vendor.';

                trigger OnDrillDown()
                var
                    RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
                begin
                    CurrPage.SaveRecord();
                    RegistrationLogMgtCZL.AssistEditVendorRegNo(Rec);
                    CurrPage.Update(false);
                end;
            }
            field("Tax Registration No. CZL"; Rec."Tax Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the secondary VAT registration number for the vendor.';
                Importance = Additional;
            }
        }
        addafter("Balance (LCY)")
        {
            field(BalanceOfCustomerCYL; BalanceAsCustomer)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Balance As Customer (LCY)';
                Editable = false;
                Enabled = BalanceOfCustomerEnabled;
                ToolTip = 'Specifies the customer''s balance which is connected with certain vendor';

                trigger OnDrillDown()
                var
                    DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
                    CustLedgerEntry: Record "Cust. Ledger Entry";
                begin
                    DetailedCustLedgEntry.SetRange("Customer No.", Customer."No.");
                    Rec.CopyFilter("Global Dimension 1 Filter", DetailedCustLedgEntry."Initial Entry Global Dim. 1");
                    Rec.CopyFilter("Global Dimension 2 Filter", DetailedCustLedgEntry."Initial Entry Global Dim. 2");
                    Rec.CopyFilter("Currency Filter", DetailedCustLedgEntry."Currency Code");
                    CustLedgerEntry.DrillDownOnEntries(DetailedCustLedgEntry);
                end;
            }
        }
        addlast(Invoicing)
        {
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
            field("Last Unreliab. Check Date CZL"; Rec."Last Unreliab. Check Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the date of the last check of unreliability.';
            }
            field("VAT Unreliable Payer CZL"; Rec."VAT Unreliable Payer CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the Vendor is VAT Unreliable Payer.';
            }
            field("Disable Unreliab. Check CZL"; Rec."Disable Unreliab. Check CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies that the check of VAT Unreliable Payer is disabled.';
            }
        }
    }
    actions
    {
        addlast("Ven&dor")
        {
            action(UnreliabilityStatusCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Unreliability Status';
                Image = CustomerRating;
                ToolTip = 'View the VAT payer unreliable entries.';

                trigger OnAction()
                begin
                    Rec.ShowUnreliableEntriesCZL();
                end;
            }
        }
        addlast("F&unctions")
        {
            action(UnreliableVATPaymentCheckCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Unreliable VAT Payment Check';
                Image = ElectronicPayment;
                ToolTip = 'Checks unreliability of the VAT payer.';

                trigger OnAction()
                var
                    UnrelPayerServiceSetupCZL: Record "Unrel. Payer Service Setup CZL";
                    UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
                    UnrelPayerServiceNotSet: Boolean;
                begin
                    if not UnrelPayerServiceSetupCZL.Get() then
                        UnrelPayerServiceNotSet := true
                    else
                        UnrelPayerServiceNotSet := not UnrelPayerServiceSetupCZL.Enabled;
                    if UnrelPayerServiceNotSet then
                        UnreliablePayerMgtCZL.CreateUnrelPayerServiceNotSetNotification();

                    Rec.ImportUnrPayerStatusCZL();
                end;
            }
        }
        addafter("Vendor - Balance to Date")
        {
            action("Balance Reconciliation CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Balance Reconciliation';
                Image = Balance;
                Promoted = true;
                PromotedCategory = "Report";
                ToolTip = 'Open the report for vendor''s balance reconciliation.';

                trigger OnAction()
                var
                    Vendor: Record Vendor;
                begin
                    Vendor.SetRange("No.", Rec."No.");
                    Report.RunModal(Report::"Vendor-Bal. Reconciliation CZL", true, true, Vendor);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if Customer.Get(Rec.GetLinkedCustomerCZL()) then begin
            Customer.CalcFields("Balance (LCY)");
            BalanceAsCustomer := Customer."Balance (LCY)";
            BalanceOfCustomerEnabled := true;
        end else begin
            BalanceAsCustomer := 0;
            BalanceOfCustomerEnabled := false;
        end;
    end;

    var
        Customer: Record Customer;
        BalanceAsCustomer: Decimal;
        [InDataSet]
        BalanceOfCustomerEnabled: Boolean;
}
