// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.DemoTool.Helpers;
using Microsoft.Foundation.Enums;

codeunit 19000 "Create IN GL Accounts"
{
    InherentPermissions = X;
    InherentEntitlements = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create G/L Account", 'OnAfterAddGLAccountsForLocalization', '', false, false)]
    local procedure ModifyGLAccountforIN()
    begin
        ContosoGLAccount.AddAccountForLocalization(TDSReceivableName(), '2450');
        ContosoGLAccount.AddAccountForLocalization(TDSRecContractor194CName(), '2451');
        ContosoGLAccount.AddAccountForLocalization(TDSRecProfessional194JName(), '2452');
        ContosoGLAccount.AddAccountForLocalization(TDSRecRent194IName(), '2453');
        ContosoGLAccount.AddAccountForLocalization(TDSRecInterest194AName(), '2454');
        ContosoGLAccount.AddAccountForLocalization(TDSReceivableTotalName(), '2460');
        ContosoGLAccount.AddAccountForLocalization(GSTReceivableName(), '2490');
        ContosoGLAccount.AddAccountForLocalization(GSTTDSReceivableAccountName(), '2500');
        ContosoGLAccount.AddAccountForLocalization(GSTTCSReceivableAccountName(), '2501');
        ContosoGLAccount.AddAccountForLocalization(IGSTRcvbleAccName(), '2701');
        ContosoGLAccount.AddAccountForLocalization(SGSTRcvbleAccName(), '2702');
        ContosoGLAccount.AddAccountForLocalization(CGSTRcvbleAccName(), '2703');
        ContosoGLAccount.AddAccountForLocalization(IGSTRcvbleAccInterimName(), '2704');
        ContosoGLAccount.AddAccountForLocalization(SGSTRcvbleAccInterimName(), '2705');
        ContosoGLAccount.AddAccountForLocalization(CGSTRcvbleAccInterimName(), '2706');
        ContosoGLAccount.AddAccountForLocalization(GSTRefundAccName(), '2707');
        ContosoGLAccount.AddAccountForLocalization(SGSTRcvblAccInterimDistName(), '2709');
        ContosoGLAccount.AddAccountForLocalization(CGSTRcvblAccInterimDistName(), '2710');
        ContosoGLAccount.AddAccountForLocalization(IGSTRcvblAccInterimDistName(), '2711');
        ContosoGLAccount.AddAccountForLocalization(CGSTRcvblAccDistName(), '2712');
        ContosoGLAccount.AddAccountForLocalization(SGSTRcvblAccDistName(), '2713');
        ContosoGLAccount.AddAccountForLocalization(IGSTRcvblAccDistName(), '2714');
        ContosoGLAccount.AddAccountForLocalization(IGSTCrMismatchAccName(), '2715');
        ContosoGLAccount.AddAccountForLocalization(SGSTCrMismatchAccName(), '2716');
        ContosoGLAccount.AddAccountForLocalization(CGSTCrMismatchAccName(), '2717');
        ContosoGLAccount.AddAccountForLocalization(CESSCrMismatchAccName(), '2718');
        ContosoGLAccount.AddAccountForLocalization(GSTInvoiceRoundingName(), '2719');
        ContosoGLAccount.AddAccountForLocalization(CustomHouseName(), '2720');
        ContosoGLAccount.AddAccountForLocalization(GSTReceivableTotalName(), '2790');
        ContosoGLAccount.AddAccountForLocalization(TDSPayableName(), '5930');
        ContosoGLAccount.AddAccountForLocalization(TDSPayableContractor194CName(), '5931');
        ContosoGLAccount.AddAccountForLocalization(TDSPayableProfessional194JName(), '5932');
        ContosoGLAccount.AddAccountForLocalization(TDSPayableRent194IName(), '5933');
        ContosoGLAccount.AddAccountForLocalization(TDSPayablePayabletoNonResidents195Name(), '5934');
        ContosoGLAccount.AddAccountForLocalization(TDSPayableInterest194AName(), '5935');
        ContosoGLAccount.AddAccountForLocalization(TDSPayableTotalName(), '5940');
        ContosoGLAccount.AddAccountForLocalization(TCSPayableName(), '5970');
        ContosoGLAccount.AddAccountForLocalization(TCSPayableAName(), '5971');
        ContosoGLAccount.AddAccountForLocalization(TCSPayableBName(), '5972');
        ContosoGLAccount.AddAccountForLocalization(TCSPayableCName(), '5973');
        ContosoGLAccount.AddAccountForLocalization(TCSPayableDName(), '5974');
        ContosoGLAccount.AddAccountForLocalization(TCSPayableEName(), '5975');
        ContosoGLAccount.AddAccountForLocalization(TCSPayableFName(), '5976');
        ContosoGLAccount.AddAccountForLocalization(TCSPayableGName(), '5977');
        ContosoGLAccount.AddAccountForLocalization(TCSPayableHName(), '5978');
        ContosoGLAccount.AddAccountForLocalization(TCSPayableIName(), '5979');
        ContosoGLAccount.AddAccountForLocalization(TCSPayableTotalName(), '5980');
        ContosoGLAccount.AddAccountForLocalization(GSTPayableName(), '5980-1');
        ContosoGLAccount.AddAccountForLocalization(IGSTPayableAccName(), '5981');
        ContosoGLAccount.AddAccountForLocalization(SGSTPayableAccName(), '5982');
        ContosoGLAccount.AddAccountForLocalization(CGSTPayableAccName(), '5983');
        ContosoGLAccount.AddAccountForLocalization(IGSTPayableAccInterimName(), '5984');
        ContosoGLAccount.AddAccountForLocalization(SGSTPayableAccInterimName(), '5985');
        ContosoGLAccount.AddAccountForLocalization(CGSTPayableAccInterimName(), '5986');
        ContosoGLAccount.AddAccountForLocalization(GSTExpenseAccName(), '5987');
        ContosoGLAccount.AddAccountForLocalization(GSTTCSPayableAccountName(), '5989');
        ContosoGLAccount.AddAccountForLocalization(GSTReceivableTotalsName(), '5989-1');
        ContosoGLAccount.AddAccountForLocalization(ShipControlAccountName(), '5991');
        ContosoGLAccount.AddAccountForLocalization(ReceiveControlAcountName(), '5992');
        ContosoGLAccount.AddAccountForLocalization(LiquorFeesName(), '6711');
        ContosoGLAccount.AddAccountForLocalization(ServiceContractSaleName(), '6955');
        ContosoGLAccount.AddAccountForLocalization(FreightName(), '8111');
        ContosoGLAccount.AddAccountForLocalization(AuditFeeName(), '8112');
        ContosoGLAccount.AddAccountForLocalization(ProfessionalChargesName(), '8113');
        ContosoGLAccount.AddAccountForLocalization(InsuranceName(), '8114');
        ContosoGLAccount.AddAccountForLocalization(PenaltyChargesName(), '8115');
        ContosoGLAccount.AddAccountForLocalization(AdvocateFeeName(), '8246');
        ContosoGLAccount.AddAccountForLocalization(OtherChargesName(), '8249');

        CreateGLAccountForLocalization();
    end;

    local procedure CreateGLAccountForLocalization()
    var
        GLAccountCategory: Record "G/L Account Category";
        CreatePostingGroups: Codeunit "Create Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        SubCategory: Text[80];
    begin
        SubCategory := Format(GLAccountCategory."Account Category"::Assets, 80);

        ContosoGLAccount.InsertGLAccount(TDSReceivable(), TDSReceivableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TDSRecContractor194C(), TDSRecContractor194CName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TDSRecProfessional194J(), TDSRecProfessional194JName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TDSRecRent194I(), TDSRecRent194IName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TDSRecInterest194A(), TDSRecInterest194AName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TDSReceivableTotal(), TDSReceivableTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, '2450..2460', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GSTReceivable(), GSTReceivableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GSTTDSReceivableAccount(), GSTTDSReceivableAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GSTTCSReceivableAccount(), GSTTCSReceivableAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IGSTRcvbleAcc(), IGSTRcvbleAccName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SGSTRcvbleAcc(), SGSTRcvbleAccName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CGSTRcvbleAcc(), CGSTRcvbleAccName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IGSTRcvbleAccInterim(), IGSTRcvbleAccInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SGSTRcvbleAccInterim(), SGSTRcvbleAccInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CGSTRcvbleAccInterim(), CGSTRcvbleAccInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GSTRefundAcc(), GSTRefundAccName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SGSTRcvblAccInterimDist(), SGSTRcvblAccInterimDistName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CGSTRcvblAccInterimDist(), CGSTRcvblAccInterimDistName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IGSTRcvblAccInterimDist(), IGSTRcvblAccInterimDistName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CGSTRcvblAccDist(), CGSTRcvblAccDistName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SGSTRcvblAccDist(), SGSTRcvblAccDistName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IGSTRcvblAccDist(), IGSTRcvblAccDistName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IGSTCrMismatchAcc(), IGSTCrMismatchAccName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SGSTCrMismatchAcc(), SGSTCrMismatchAccName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CGSTCrMismatchAcc(), CGSTCrMismatchAccName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CESSCrMismatchAcc(), CESSCrMismatchAccName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GSTInvoiceRounding(), GSTInvoiceRoundingName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CustomHouse(), CustomHouseName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GSTReceivableTotal(), GSTReceivableTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Assets, Subcategory, Enum::"G/L Account Type"::"End-Total", '', '', 1, '2490..2790', Enum::"General Posting Type"::" ", '', '', false, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Liabilities, 80);
        ContosoGLAccount.InsertGLAccount(TDSPayable(), TDSPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TDSPayableContractor194C(), TDSPayableContractor194CName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TDSPayableProfessional194J(), TDSPayableProfessional194JName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TDSPayableRent194I(), TDSPayableRent194IName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TDSPayablePayabletoNonResidents195(), TDSPayablePayabletoNonResidents195Name(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TDSPayableInterest194A(), TDSPayableInterest194AName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TDSPayableTotal(), TDSPayableTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, '5930..5940', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TCSPayable(), TCSPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TCSPayableA(), TCSPayableAName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TCSPayableB(), TCSPayableBName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TCSPayableC(), TCSPayableCName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TCSPayableD(), TCSPayableDName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TCSPayableE(), TCSPayableEName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TCSPayableF(), TCSPayableFName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TCSPayableG(), TCSPayableGName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TCSPayableH(), TCSPayableHName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TCSPayableI(), TCSPayableIName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 0, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(TCSPayableTotal(), TCSPayableTotalName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::"End-Total", '', '', 0, '5970..5980', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GSTPayable(), GSTPayableName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::"Begin-Total", '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IGSTPayableAcc(), IGSTPayableAccName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SGSTPayableAcc(), SGSTPayableAccName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CGSTPayableAcc(), CGSTPayableAccName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(IGSTPayableAccInterim(), IGSTPayableAccInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(SGSTPayableAccInterim(), SGSTPayableAccInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(CGSTPayableAccInterim(), CGSTPayableAccInterimName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GSTExpenseAcc(), GSTExpenseAccName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GSTTCSPayableAccount(), GSTTCSPayableAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, '', '', 1, '', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(GSTReceivableTotals(), GSTReceivableTotalsName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::"End-Total", '', '', 1, '5980-1..5989-1', Enum::"General Posting Type"::" ", '', '', false, false, false);
        ContosoGLAccount.InsertGLAccount(ShipControlAccount(), ShipControlAccountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), 1, '', Enum::"General Posting Type"::" ", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), true, false, false);
        ContosoGLAccount.InsertGLAccount(ReceiveControlAcount(), ReceiveControlAcountName(), Enum::"G/L Account Income/Balance"::"Balance Sheet", Enum::"G/L Account Category"::Liabilities, Subcategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), 1, '', Enum::"General Posting Type"::" ", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetIncomeService(), 80);
        ContosoGLAccount.InsertGLAccount(LiquorFees(), LiquorFeesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Subcategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), 1, '', Enum::"General Posting Type"::" ", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), true, false, false);
        ContosoGLAccount.InsertGLAccount(ServiceContractSale(), ServiceContractSaleName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Income, Subcategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), 1, '', Enum::"General Posting Type"::Sale, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), true, false, false);

        SubCategory := Format(GLAccountCategoryMgt.GetUtilitiesExpense(), 80);
        ContosoGLAccount.InsertGLAccount(Freight(), FreightName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Subcategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), 1, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), true, false, false);
        ContosoGLAccount.InsertGLAccount(AuditFee(), AuditFeeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Subcategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), 1, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), true, false, false);
        ContosoGLAccount.InsertGLAccount(ProfessionalCharges(), ProfessionalChargesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Subcategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), 1, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), true, false, false);
        ContosoGLAccount.InsertGLAccount(Insurance(), InsuranceName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Subcategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), 1, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), true, false, false);
        ContosoGLAccount.InsertGLAccount(PenaltyCharges(), PenaltyChargesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Subcategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), 1, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Postage(), CreateGLAccount.PostageName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::" ", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), true, false, false);

        SubCategory := Format(GLAccountCategory."Account Category"::Expense, 80);
        ContosoGLAccount.InsertGLAccount(AdvocateFee(), AdvocateFeeName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Subcategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), 1, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), true, false, false);
        ContosoGLAccount.InsertGLAccount(OtherCharges(), OtherChargesName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, Subcategory, Enum::"G/L Account Type"::Posting, CreatePostingGroups.DomesticPostingGroup(), CreatePostingGroups.ZeroPostingGroup(), 1, '', Enum::"General Posting Type"::Purchase, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), true, false, false);
        ContosoGLAccount.InsertGLAccount(CreateGLAccount.Travel(), CreateGLAccount.TravelName(), Enum::"G/L Account Income/Balance"::"Income Statement", Enum::"G/L Account Category"::Expense, SubCategory, Enum::"G/L Account Type"::Posting, CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), 0, '', Enum::"General Posting Type"::" ", CreateVATPostingGroups.Domestic(), CreateVATPostingGroups.Zero(), true, false, false);
    end;

    procedure UpdateGSTGroupOnGLAccounts(GLAccountNo: Code[20]; GSTGroupCode: Code[10]; HSNSACCode: Code[10])
    var
        GLAccount: Record "G/L Account";
    begin
        if GLAccount.Get(GLAccountNo) then begin
            GLAccount.Validate("GST Group Code", GSTGroupCode);
            GLAccount.Validate("HSN/SAC Code", HSNSACCode);
            GLAccount.Modify(true);
        end;
    end;

    procedure TDSReceivable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TDSReceivableName()));
    end;

    procedure TDSReceivableName(): Text[100]
    begin
        exit(TDSReceivableTok);
    end;

    procedure TDSRecContractor194C(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TDSRecContractor194CName()));
    end;

    procedure TDSRecContractor194CName(): Text[100]
    begin
        exit(TDSRecContractor194CTok);
    end;

    procedure TDSRecProfessional194J(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TDSRecProfessional194JName()));
    end;

    procedure TDSRecProfessional194JName(): Text[100]
    begin
        exit(TDSRecProfessional194JTok);
    end;

    procedure TDSRecRent194I(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TDSRecRent194IName()));
    end;

    procedure TDSRecRent194IName(): Text[100]
    begin
        exit(TDSRecRent194ITok);
    end;

    procedure TDSRecInterest194A(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TDSRecInterest194AName()));
    end;

    procedure TDSRecInterest194AName(): Text[100]
    begin
        exit(TDSRecInterest194ATok);
    end;

    procedure TDSReceivableTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TDSReceivableTotalName()));
    end;

    procedure TDSReceivableTotalName(): Text[100]
    begin
        exit(TDSReceivableTotalTok);
    end;

    procedure GSTReceivable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GSTReceivableName()));
    end;

    procedure GSTReceivableName(): Text[100]
    begin
        exit(GSTReceivableTok);
    end;

    procedure GSTTDSReceivableAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GSTTDSReceivableAccountName()));
    end;

    procedure GSTTDSReceivableAccountName(): Text[100]
    begin
        exit(GSTTDSReceivableAccountTok);
    end;

    procedure GSTTCSReceivableAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GSTTCSReceivableAccountName()));
    end;

    procedure GSTTCSReceivableAccountName(): Text[100]
    begin
        exit(GSTTCSReceivableAccountTok);
    end;

    procedure IGSTRcvbleAcc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IGSTRcvbleAccName()));
    end;

    procedure IGSTRcvbleAccName(): Text[100]
    begin
        exit(IGSTRcvbleAccTok);
    end;

    procedure SGSTRcvbleAcc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SGSTRcvbleAccName()));
    end;

    procedure SGSTRcvbleAccName(): Text[100]
    begin
        exit(SGSTRcvbleAccTok);
    end;

    procedure CGSTRcvbleAcc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CGSTRcvbleAccName()));
    end;

    procedure CGSTRcvbleAccName(): Text[100]
    begin
        exit(CGSTRcvbleAccTok);
    end;

    procedure IGSTRcvbleAccInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IGSTRcvbleAccInterimName()));
    end;

    procedure IGSTRcvbleAccInterimName(): Text[100]
    begin
        exit(IGSTRcvbleAccInterimTok);
    end;

    procedure SGSTRcvbleAccInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SGSTRcvbleAccInterimName()));
    end;

    procedure SGSTRcvbleAccInterimName(): Text[100]
    begin
        exit(SGSTRcvbleAccInterimTok);
    end;

    procedure CGSTRcvbleAccInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CGSTRcvbleAccInterimName()));
    end;

    procedure CGSTRcvbleAccInterimName(): Text[100]
    begin
        exit(CGSTRcvbleAccInterimTok);
    end;

    procedure GSTRefundAcc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GSTRefundAccName()));
    end;

    procedure GSTRefundAccName(): Text[100]
    begin
        exit(GSTRefundAccTok);
    end;

    procedure SGSTRcvblAccInterimDist(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SGSTRcvblAccInterimDistName()));
    end;

    procedure SGSTRcvblAccInterimDistName(): Text[100]
    begin
        exit(SGSTRcvblAccInterimDistTok);
    end;

    procedure CGSTRcvblAccInterimDist(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CGSTRcvblAccInterimDistName()));
    end;

    procedure CGSTRcvblAccInterimDistName(): Text[100]
    begin
        exit(CGSTRcvblAccInterimDistTok);
    end;

    procedure IGSTRcvblAccInterimDist(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IGSTRcvblAccInterimDistName()));
    end;

    procedure IGSTRcvblAccInterimDistName(): Text[100]
    begin
        exit(IGSTRcvblAccInterimDistTok);
    end;

    procedure CGSTRcvblAccDist(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CGSTRcvblAccDistName()));
    end;

    procedure CGSTRcvblAccDistName(): Text[100]
    begin
        exit(CGSTRcvblAccDistTok);
    end;

    procedure SGSTRcvblAccDist(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SGSTRcvblAccDistName()));
    end;

    procedure SGSTRcvblAccDistName(): Text[100]
    begin
        exit(SGSTRcvblAccDistTok);
    end;

    procedure IGSTRcvblAccDist(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IGSTRcvblAccDistName()));
    end;

    procedure IGSTRcvblAccDistName(): Text[100]
    begin
        exit(IGSTRcvblAccDistTok);
    end;

    procedure IGSTCrMismatchAcc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IGSTCrMismatchAccName()));
    end;

    procedure IGSTCrMismatchAccName(): Text[100]
    begin
        exit(IGSTCrMismatchAccTok);
    end;

    procedure SGSTCrMismatchAcc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SGSTCrMismatchAccName()));
    end;

    procedure SGSTCrMismatchAccName(): Text[100]
    begin
        exit(SGSTCrMismatchAccTok);
    end;

    procedure CGSTCrMismatchAcc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CGSTCrMismatchAccName()));
    end;

    procedure CGSTCrMismatchAccName(): Text[100]
    begin
        exit(CGSTCrMismatchAccTok);
    end;

    procedure CESSCrMismatchAcc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CESSCrMismatchAccName()));
    end;

    procedure CESSCrMismatchAccName(): Text[100]
    begin
        exit(CESSCrMismatchAccTok);
    end;

    procedure GSTInvoiceRounding(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GSTInvoiceRoundingName()));
    end;

    procedure GSTInvoiceRoundingName(): Text[100]
    begin
        exit(GSTInvoiceRoundingTok);
    end;

    procedure CustomHouse(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CustomHouseName()));
    end;

    procedure CustomHouseName(): Text[100]
    begin
        exit(CustomHouseTok);
    end;

    procedure GSTReceivableTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GSTReceivableTotalName()));
    end;

    procedure GSTReceivableTotalName(): Text[100]
    begin
        exit(GSTReceivableTotalTok);
    end;

    procedure TDSPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TDSPayableName()));
    end;

    procedure TDSPayableName(): Text[100]
    begin
        exit(TDSPayableTok);
    end;

    procedure TDSPayableContractor194C(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TDSPayableContractor194CName()));
    end;

    procedure TDSPayableContractor194CName(): Text[100]
    begin
        exit(TDSPayableContractor194CTok);
    end;

    procedure TDSPayableProfessional194J(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TDSPayableProfessional194JName()));
    end;

    procedure TDSPayableProfessional194JName(): Text[100]
    begin
        exit(TDSPayableProfessional194JTok);
    end;

    procedure TDSPayableRent194I(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TDSPayableRent194IName()));
    end;

    procedure TDSPayableRent194IName(): Text[100]
    begin
        exit(TDSPayableRent194ITok);
    end;

    procedure TDSPayablePayabletoNonResidents195(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TDSPayablePayabletoNonResidents195Name()));
    end;

    procedure TDSPayablePayabletoNonResidents195Name(): Text[100]
    begin
        exit(TDSPayablePayabletoNonResidents195Tok);
    end;

    procedure TDSPayableInterest194A(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TDSPayableInterest194AName()));
    end;

    procedure TDSPayableInterest194AName(): Text[100]
    begin
        exit(TDSPayableInterest194ATok);
    end;

    procedure TDSPayableTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TDSPayableTotalName()));
    end;

    procedure TDSPayableTotalName(): Text[100]
    begin
        exit(TDSPayableTotalTok);
    end;

    procedure TCSPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TCSPayableName()));
    end;

    procedure TCSPayableName(): Text[100]
    begin
        exit(TCSPayableTok);
    end;

    procedure TCSPayableA(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TCSPayableAName()));
    end;

    procedure TCSPayableAName(): Text[100]
    begin
        exit(TCSPayableATok);
    end;

    procedure TCSPayableB(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TCSPayableBName()));
    end;

    procedure TCSPayableBName(): Text[100]
    begin
        exit(TCSPayableBTok);
    end;

    procedure TCSPayableC(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TCSPayableCName()));
    end;

    procedure TCSPayableCName(): Text[100]
    begin
        exit(TCSPayableCTok);
    end;

    procedure TCSPayableD(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TCSPayableDName()));
    end;

    procedure TCSPayableDName(): Text[100]
    begin
        exit(TCSPayableDTok);
    end;

    procedure TCSPayableE(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TCSPayableEName()));
    end;

    procedure TCSPayableEName(): Text[100]
    begin
        exit(TCSPayableETok);
    end;

    procedure TCSPayableF(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TCSPayableFName()));
    end;

    procedure TCSPayableFName(): Text[100]
    begin
        exit(TCSPayableFTok);
    end;

    procedure TCSPayableG(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TCSPayableGName()));
    end;

    procedure TCSPayableGName(): Text[100]
    begin
        exit(TCSPayableGTok);
    end;

    procedure TCSPayableH(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TCSPayableHName()));
    end;

    procedure TCSPayableHName(): Text[100]
    begin
        exit(TCSPayableHTok);
    end;

    procedure TCSPayableI(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TCSPayableIName()));
    end;

    procedure TCSPayableIName(): Text[100]
    begin
        exit(TCSPayableITok);
    end;

    procedure TCSPayableTotal(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(TCSPayableTotalName()));
    end;

    procedure TCSPayableTotalName(): Text[100]
    begin
        exit(TCSPayableTotalTok);
    end;

    procedure GSTPayable(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GSTPayableName()));
    end;

    procedure GSTPayableName(): Text[100]
    begin
        exit(GSTPayableTok);
    end;

    procedure IGSTPayableAcc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IGSTPayableAccName()));
    end;

    procedure IGSTPayableAccName(): Text[100]
    begin
        exit(IGSTPayableAccTok);
    end;

    procedure SGSTPayableAcc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SGSTPayableAccName()));
    end;

    procedure SGSTPayableAccName(): Text[100]
    begin
        exit(SGSTPayableAccTok);
    end;

    procedure CGSTPayableAcc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CGSTPayableAccName()));
    end;

    procedure CGSTPayableAccName(): Text[100]
    begin
        exit(CGSTPayableAccTok);
    end;

    procedure IGSTPayableAccInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(IGSTPayableAccInterimName()));
    end;

    procedure IGSTPayableAccInterimName(): Text[100]
    begin
        exit(IGSTPayableAccInterimTok);
    end;

    procedure SGSTPayableAccInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(SGSTPayableAccInterimName()));
    end;

    procedure SGSTPayableAccInterimName(): Text[100]
    begin
        exit(SGSTPayableAccInterimTok);
    end;

    procedure CGSTPayableAccInterim(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(CGSTPayableAccInterimName()));
    end;

    procedure CGSTPayableAccInterimName(): Text[100]
    begin
        exit(CGSTPayableAccInterimTok);
    end;

    procedure GSTExpenseAcc(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GSTExpenseAccName()));
    end;

    procedure GSTExpenseAccName(): Text[100]
    begin
        exit(GSTExpenseAccTok);
    end;

    procedure GSTTCSPayableAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GSTTCSPayableAccountName()));
    end;

    procedure GSTTCSPayableAccountName(): Text[100]
    begin
        exit(GSTTCSPayableAccountTok);
    end;

    procedure GSTReceivableTotals(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(GSTReceivableTotalsName()));
    end;

    procedure GSTReceivableTotalsName(): Text[100]
    begin
        exit(GSTReceivableTotalsTok);
    end;

    procedure ShipControlAccount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ShipControlAccountName()));
    end;

    procedure ShipControlAccountName(): Text[100]
    begin
        exit(ShipControlAccountTok);
    end;

    procedure ReceiveControlAcount(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ReceiveControlAcountName()));
    end;

    procedure ReceiveControlAcountName(): Text[100]
    begin
        exit(ReceiveControlAcountTok);
    end;

    procedure LiquorFees(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(LiquorFeesName()));
    end;

    procedure LiquorFeesName(): Text[100]
    begin
        exit(LiquorFeesTok);
    end;

    procedure ServiceContractSale(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ServiceContractSaleName()));
    end;

    procedure ServiceContractSaleName(): Text[100]
    begin
        exit(ServiceContractSaleTok);
    end;

    procedure Freight(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(FreightName()));
    end;

    procedure FreightName(): Text[100]
    begin
        exit(FreightTok);
    end;

    procedure AuditFee(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AuditFeeName()));
    end;

    procedure AuditFeeName(): Text[100]
    begin
        exit(AuditFeeTok);
    end;

    procedure ProfessionalCharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(ProfessionalChargesName()));
    end;

    procedure ProfessionalChargesName(): Text[100]
    begin
        exit(ProfessionalChargesTok);
    end;

    procedure Insurance(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(InsuranceName()));
    end;

    procedure InsuranceName(): Text[100]
    begin
        exit(InsuranceTok);
    end;

    procedure PenaltyCharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(PenaltyChargesName()));
    end;

    procedure PenaltyChargesName(): Text[100]
    begin
        exit(PenaltyChargesTok);
    end;

    procedure AdvocateFee(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(AdvocateFeeName()));
    end;

    procedure AdvocateFeeName(): Text[100]
    begin
        exit(AdvocateFeeTok);
    end;

    procedure OtherCharges(): Code[20]
    begin
        exit(ContosoGLAccount.GetAccountNo(OtherChargesName()));
    end;

    procedure OtherChargesName(): Text[100]
    begin
        exit(OtherChargesTok);
    end;

    var
        ContosoGLAccount: Codeunit "Contoso GL Account";
        TDSReceivableTok: Label 'TDS Receivable', MaxLength = 100;
        TDSRecContractor194CTok: Label 'TDS Rec. Contractor -194C', MaxLength = 100;
        TDSRecProfessional194JTok: Label 'TDS Rec. Professional - 194J', MaxLength = 100;
        TDSRecRent194ITok: Label 'TDS Rec. Rent - 194 I', MaxLength = 100;
        TDSRecInterest194ATok: Label 'TDS Rec. Interest - 194A', MaxLength = 100;
        TDSReceivableTotalTok: Label 'TDS Receivable Total', MaxLength = 100;
        GSTReceivableTok: Label 'GST Receivable', MaxLength = 100;
        GSTTDSReceivableAccountTok: Label 'GST TDS Receivable Account', MaxLength = 100;
        GSTTCSReceivableAccountTok: Label 'GST TCS Receivable Account', MaxLength = 100;
        IGSTRcvbleAccTok: Label 'IGST Rcvble Acc', MaxLength = 100;
        SGSTRcvbleAccTok: Label 'SGST Rcvble Acc', MaxLength = 100;
        CGSTRcvbleAccTok: Label 'CGST  Rcvble Acc', MaxLength = 100;
        IGSTRcvbleAccInterimTok: Label 'IGST Rcvble Acc(Interim)', MaxLength = 100;
        SGSTRcvbleAccInterimTok: Label 'SGST Rcvble Acc(Interim)', MaxLength = 100;
        CGSTRcvbleAccInterimTok: Label 'CGST Rcvble Acc(Interim)', MaxLength = 100;
        GSTRefundAccTok: Label 'GST Refund Acc', MaxLength = 100;
        SGSTRcvblAccInterimDistTok: Label 'SGST Rcvbl Acc. Interim(Dist)', MaxLength = 100;
        CGSTRcvblAccInterimDistTok: Label 'CGST Rcvbl Acc. Interim(Dist)', MaxLength = 100;
        IGSTRcvblAccInterimDistTok: Label 'IGST Rcvbl Acc. Interim(Dist)', MaxLength = 100;
        CGSTRcvblAccDistTok: Label 'CGST Rcvbl Acc. (Dist)', MaxLength = 100;
        SGSTRcvblAccDistTok: Label 'SGST Rcvbl Acc. (Dist)', MaxLength = 100;
        IGSTRcvblAccDistTok: Label 'IGST Rcvbl Acc. (Dist)', MaxLength = 100;
        IGSTCrMismatchAccTok: Label 'IGST Cr. Mismatch Acc.', MaxLength = 100;
        SGSTCrMismatchAccTok: Label 'SGST Cr. Mismatch Acc.', MaxLength = 100;
        CGSTCrMismatchAccTok: Label 'CGST Cr. Mismatch Acc.', MaxLength = 100;
        CESSCrMismatchAccTok: Label 'CESS Cr. Mismatch Acc.', MaxLength = 100;
        GSTInvoiceRoundingTok: Label 'GST Invoice Rounding', MaxLength = 100;
        CustomHouseTok: Label 'Custom House', MaxLength = 100;
        GSTReceivableTotalTok: Label 'GST Receivable, Total', MaxLength = 100;
        TDSPayableTok: Label 'TDS Payable', MaxLength = 100;
        TDSPayableContractor194CTok: Label 'TDS Payable - Contractor - 194C', MaxLength = 100;
        TDSPayableProfessional194JTok: Label 'TDS Payable - Professional - 194J', MaxLength = 100;
        TDSPayableRent194ITok: Label 'TDS Payable - Rent - 194I', MaxLength = 100;
        TDSPayablePayabletoNonResidents195Tok: Label 'TDS Payable - Payable to Non Residents - 195', MaxLength = 100;
        TDSPayableInterest194ATok: Label 'TDS Payable - Interest - 194A', MaxLength = 100;
        TDSPayableTotalTok: Label 'TDS Payable, Total', MaxLength = 100;
        TCSPayableTok: Label 'TCS Payable', MaxLength = 100;
        TCSPayableATok: Label 'TCS Payable-A', MaxLength = 100;
        TCSPayableBTok: Label 'TCS Payable-B', MaxLength = 100;
        TCSPayableCTok: Label 'TCS Payable-C', MaxLength = 100;
        TCSPayableDTok: Label 'TCS Payable-D', MaxLength = 100;
        TCSPayableETok: Label 'TCS Payable-E', MaxLength = 100;
        TCSPayableFTok: Label 'TCS Payable-F', MaxLength = 100;
        TCSPayableGTok: Label 'TCS Payable-G', MaxLength = 100;
        TCSPayableHTok: Label 'TCS Payable-H', MaxLength = 100;
        TCSPayableITok: Label 'TCS Payable-I', MaxLength = 100;
        TCSPayableTotalTok: Label 'TCS Payable, Total', MaxLength = 100;
        GSTPayableTok: Label 'GST Payable', MaxLength = 100;
        IGSTPayableAccTok: Label 'IGST Payable Acc', MaxLength = 100;
        SGSTPayableAccTok: Label 'SGST Payable Acc', MaxLength = 100;
        CGSTPayableAccTok: Label 'CGST Payable Acc', MaxLength = 100;
        IGSTPayableAccInterimTok: Label 'IGST Payable Acc(Interim)', MaxLength = 100;
        SGSTPayableAccInterimTok: Label 'SGST Payable Acc(Interim)', MaxLength = 100;
        CGSTPayableAccInterimTok: Label 'CGST Payable Acc(Interim)', MaxLength = 100;
        GSTExpenseAccTok: Label 'GST Expense Acc', MaxLength = 100;
        GSTTCSPayableAccountTok: Label 'GST TCS Payable Account', MaxLength = 100;
        GSTReceivableTotalsTok: Label 'GST Receivable, Totals', MaxLength = 100;
        ShipControlAccountTok: Label 'Ship Control Account', MaxLength = 100;
        ReceiveControlAcountTok: Label 'Receive Control Acount', MaxLength = 100;
        LiquorFeesTok: Label 'Liquor Fees', MaxLength = 100;
        ServiceContractSaleTok: Label 'Service Contract Sale', MaxLength = 100;
        FreightTok: Label 'Freight', MaxLength = 100;
        AuditFeeTok: Label 'Audit Fee', MaxLength = 100;
        ProfessionalChargesTok: Label 'Professional Charges', MaxLength = 100;
        InsuranceTok: Label 'Insurance', MaxLength = 100;
        PenaltyChargesTok: Label 'Penalty Charges', MaxLength = 100;
        AdvocateFeeTok: Label 'Advocate Fee', MaxLength = 100;
        OtherChargesTok: Label 'Other Charges', MaxLength = 100;
}
