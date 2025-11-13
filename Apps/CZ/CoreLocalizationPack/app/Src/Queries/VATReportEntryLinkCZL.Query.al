// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.VAT.Ledger;

query 11700 "VAT Report Entry Link CZL"
{
    Caption = 'VAT Report Entry Link';
    Permissions = tabledata "VAT Entry" = r;

    elements
    {
        dataitem(VAT_Report_Entry_Link; "VAT Report Entry Link CZL")
        {
            column(VAT_Report_No; "VAT Report No.")
            {
            }
            dataitem(VAT_Entry; "VAT Entry")
            {
                DataItemLink = "Entry No." = VAT_Report_Entry_Link."VAT Entry No.";
                column(Entry_No; "Entry No.")
                {
                }
                column(Type; Type)
                {
                }
                column(VAT_Bus_Posting_Group; "VAT Bus. Posting Group")
                {
                }
                column(VAT_Prod_Posting_Group; "VAT Prod. Posting Group")
                {
                }
                column(Tax_Jurisdiction_Code; "Tax Jurisdiction Code")
                {
                }
                column(Use_Tax; "Use Tax")
                {
                }
                column(Gen_Bus_Posting_Group; "Gen. Bus. Posting Group")
                {
                }
                column(Gen_Prod_Posting_Group; "Gen. Prod. Posting Group")
                {
                }
                column(EU_3_Party_Trade; "EU 3-Party Trade")
                {
                }
                column(EU_3_Party_Intermed_Role_CZL; "EU 3-Party Intermed. Role CZL")
                {
                }
                column(VAT_Reporting_Date; "VAT Reporting Date")
                {
                }
                column(Posting_Date; "Posting Date")
                {
                }
                column(Closed; Closed)
                {
                }
                column(VAT_Settlement_No_CZL; "VAT Settlement No. CZL")
                {
                }
                column(Base; Base)
                {
                }
                column(Amount; Amount)
                {
                }
                column(Additional_Currency_Base; "Additional-Currency Base")
                {
                }
                column(Additional_Currency_Amount; "Additional-Currency Amount")
                {
                }
                column(Non_Deductible_VAT_Base; "Non-Deductible VAT Base")
                {
                }
                column(Non_Deductible_VAT_Amount; "Non-Deductible VAT Amount")
                {
                }
                column(Non_Deductible_VAT_Base_ACY; "Non-Deductible VAT Base ACY")
                {
                }
                column(Non_Deductible_VAT_Amount_ACY; "Non-Deductible VAT Amount ACY")
                {
                }
                column(Remaining_Unrealized_Amount; "Remaining Unrealized Amount")
                {
                }
                column(Remaining_Unrealized_Base; "Remaining Unrealized Base")
                {
                }
                column(Add_Curr_Rem_Unreal_Amount; "Add.-Curr. Rem. Unreal. Amount")
                {
                }
                column(Add_Curr_Rem_Unreal_Base; "Add.-Curr. Rem. Unreal. Base")
                {
                }
            }
        }
    }

    internal procedure SetVATStmtCalcFilters(VATStatementLine: Record "VAT Statement Line"; VATStmtCalcParametersCZL: Record "VAT Stmt. Calc. Parameters CZL")
    var
        VATEntry: Record "VAT Entry";
    begin
        if VATStmtCalcParametersCZL."VAT Report No. Filter" <> '' then
            SetFilter(VAT_Report_No, VATStmtCalcParametersCZL."VAT Report No. Filter");
        VATEntry.SetVATStmtCalcFilters(VATStatementLine, VATStmtCalcParametersCZL);
        SetFilter(Type, VATEntry.GetFilter(Type));
        SetFilter(VAT_Bus_Posting_Group, VATEntry.GetFilter("VAT Bus. Posting Group"));
        SetFilter(VAT_Prod_Posting_Group, VATEntry.GetFilter("VAT Prod. Posting Group"));
        SetFilter(Tax_Jurisdiction_Code, VATEntry.GetFilter("Tax Jurisdiction Code"));
        SetFilter(Use_Tax, VATEntry.GetFilter("Use Tax"));
        SetFilter(Gen_Bus_Posting_Group, VATEntry.GetFilter("Gen. Bus. Posting Group"));
        SetFilter(Gen_Prod_Posting_Group, VATEntry.GetFilter("Gen. Prod. Posting Group"));
        SetFilter(EU_3_Party_Trade, VATEntry.GetFilter("EU 3-Party Trade"));
        SetFilter(EU_3_Party_Intermed_Role_CZL, VATEntry.GetFilter("EU 3-Party Intermed. Role CZL"));
        SetFilter(VAT_Reporting_Date, VATEntry.GetFilter("VAT Reporting Date"));
        SetFilter(Posting_Date, VATEntry.GetFilter("Posting Date"));
        SetFilter(Closed, VATEntry.GetFilter(Closed));
        SetFilter(VAT_Settlement_No_CZL, VATEntry.GetFilter("VAT Settlement No. CZL"));
    end;

    internal procedure GetAmount(VATStatementLineAmountType: Enum "VAT Statement Line Amount Type"; UseAmtsInAddCurr: Boolean): Decimal
    begin
        case VATStatementLineAmountType of
            VATStatementLineAmountType::Amount:
                exit(ConditionalAdd(Amount, Additional_Currency_Amount, UseAmtsInAddCurr));
            VATStatementLineAmountType::Base:
                exit(ConditionalAdd(Base, Additional_Currency_Base, UseAmtsInAddCurr));
            VATStatementLineAmountType::"Non-Deductible Amount":
                exit(ConditionalAdd(Non_Deductible_VAT_Amount, Non_Deductible_VAT_Amount_ACY, UseAmtsInAddCurr));
            VATStatementLineAmountType::"Non-Deductible Base":
                exit(ConditionalAdd(Non_Deductible_VAT_Base, Non_Deductible_VAT_Base_ACY, UseAmtsInAddCurr));
            VATStatementLineAmountType::"Full Amount":
                exit(ConditionalAdd(Amount + Non_Deductible_VAT_Amount, Additional_Currency_Amount + Non_Deductible_VAT_Amount_ACY, UseAmtsInAddCurr));
            VATStatementLineAmountType::"Full Base":
                exit(ConditionalAdd(Base + Non_Deductible_VAT_Base, Additional_Currency_Base + Non_Deductible_VAT_Base_ACY, UseAmtsInAddCurr));
            VATStatementLineAmountType::"Unrealized Amount":
                exit(ConditionalAdd(Remaining_Unrealized_Amount, Add_Curr_Rem_Unreal_Amount, UseAmtsInAddCurr));
            VATStatementLineAmountType::"Unrealized Base":
                exit(ConditionalAdd(Remaining_Unrealized_Base, Add_Curr_Rem_Unreal_Base, UseAmtsInAddCurr));
        end;
    end;

    internal procedure GetBase(VATStatementLineAmountType: Enum "VAT Statement Line Amount Type"; UseAmtsInAddCurr: Boolean): Decimal
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        if not VATReportSetup.Get() then
            exit(0);
        if not VATReportSetup."Report VAT Base" then
            exit(0);

        case VATStatementLineAmountType of
            VATStatementLineAmountType::Amount:
                exit(ConditionalAdd(Base, Additional_Currency_Base, UseAmtsInAddCurr));
            VATStatementLineAmountType::"Non-Deductible Amount":
                exit(ConditionalAdd(Non_Deductible_VAT_Base, Non_Deductible_VAT_Base_ACY, UseAmtsInAddCurr));
            VATStatementLineAmountType::"Full Amount":
                exit(ConditionalAdd(Base + Non_Deductible_VAT_Base, Additional_Currency_Base + Non_Deductible_VAT_Base_ACY, UseAmtsInAddCurr));
            VATStatementLineAmountType::Base,
            VATStatementLineAmountType::"Non-Deductible Base",
            VATStatementLineAmountType::"Full Base",
            VATStatementLineAmountType::"Unrealized Amount",
            VATStatementLineAmountType::"Unrealized Base":
                exit(0);
        end;
    end;

    local procedure ConditionalAdd(AmountToAdd: Decimal; AddCurrAmountToAdd: Decimal; UseAmtsInAddCurr: Boolean): Decimal
    begin
        if UseAmtsInAddCurr then
            exit(AddCurrAmountToAdd);
        exit(AmountToAdd);
    end;

    internal procedure GetVATEntries(var OutTempVATEntry: Record "VAT Entry" temporary)
    var
        VATEntry: Record "VAT Entry";
    begin
        Open();
        while Read() do begin
            VATEntry.Get(Entry_No);
            OutTempVATEntry.Init();
            OutTempVATEntry := VATEntry;
            OutTempVATEntry.Insert();
        end;
    end;
}