// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.VAT.Setup;

tableextension 31000 "VAT Posting Setup CZZ" extends "VAT Posting Setup"
{
    fields
    {
        field(31010; "Sales Adv. Letter Account CZZ"; Code[20])
        {
            Caption = 'Sales Advance Letter Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Sales Adv. Letter Account CZZ");
            end;
        }
        field(31013; "Sales Adv. Letter VAT Acc. CZZ"; Code[20])
        {
            Caption = 'Sales Advance Letter VAT Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Sales Adv. Letter VAT Acc. CZZ");
            end;
        }
        field(31020; "Purch. Adv. Letter Account CZZ"; Code[20])
        {
            Caption = 'Purchase Advance Letter Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Purch. Adv. Letter Account CZZ");
            end;
        }
        field(31023; "Purch. Adv.Letter VAT Acc. CZZ"; Code[20])
        {
            Caption = 'Purchase Advance Letter VAT Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            begin
                CheckGLAcc("Purch. Adv.Letter VAT Acc. CZZ");
            end;
        }
        field(31030; "P.Adv.Letter ND VAT Acc. CZZ"; Code[20])
        {
            Caption = 'Purchase Advance Letter Non-Deductible VAT Account';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;
            ToolTip = 'Specifies purchase advance letter non-deductible VAT account for posting the part of the VAT that will not be applied to the purchase advance (temporary account).';

            trigger OnValidate()
            begin
                TestNotSalesTax(CopyStr(FieldCaption("P.Adv.Letter ND VAT Acc. CZZ"), 1, 100));
                CheckGLAcc("P.Adv.Letter ND VAT Acc. CZZ");
            end;
        }
    }

    var
        PostingSetupMgtCZZ: Codeunit PostingSetupManagement;
        NonDeductibleVATNotAllowedTitleLbl: Label 'Non-deductible VAT is not allowed.';
        NonDeductibleVATNotAllowedErr: Label 'Non-deductible VAT is not allowed for the combination of VAT posting groups %1 %2.';
        ShowVATPostingSetupCardLbl: Label 'Show VAT Posting Setup Card';

    procedure GetSalesAdvLetterAccountCZZ(): Code[20]
    var
        AccountNo: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        AccountNo := '';
        OnBeforeGetSalesAdvLetterAccountCZZ(Rec, AccountNo, IsHandled);
        if IsHandled then
            exit(AccountNo);

        if "Sales Adv. Letter Account CZZ" = '' then
            PostingSetupMgtCZZ.LogVATPostingSetupFieldError(Rec, FieldNo("Sales Adv. Letter Account CZZ"));

        exit("Sales Adv. Letter Account CZZ");
    end;

    procedure GetSalesAdvLetterVATAccountCZZ(): Code[20]
    var
        AccountNo: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        AccountNo := '';
        OnBeforeGetSalesAdvLetterVATAccountCZZ(Rec, AccountNo, IsHandled);
        if IsHandled then
            exit(AccountNo);

        if "Sales Adv. Letter VAT Acc. CZZ" = '' then
            PostingSetupMgtCZZ.LogVATPostingSetupFieldError(Rec, FieldNo("Sales Adv. Letter VAT Acc. CZZ"));

        exit("Sales Adv. Letter VAT Acc. CZZ");
    end;

    procedure GetPurchAdvLetterAccountCZZ(): Code[20]
    var
        AccountNo: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        AccountNo := '';
        OnBeforeGetPurchAdvLetterAccountCZZ(Rec, AccountNo, IsHandled);
        if IsHandled then
            exit(AccountNo);

        if "Purch. Adv. Letter Account CZZ" = '' then
            PostingSetupMgtCZZ.LogVATPostingSetupFieldError(Rec, FieldNo("Purch. Adv. Letter Account CZZ"));

        exit("Purch. Adv. Letter Account CZZ");
    end;

    procedure GetPurchAdvLetterVATAccountCZZ(): Code[20]
    var
        AccountNo: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        AccountNo := '';
        OnBeforeGetPurchAdvLetterVATAccountCZZ(Rec, AccountNo, IsHandled);
        if IsHandled then
            exit(AccountNo);

        if "Purch. Adv.Letter VAT Acc. CZZ" = '' then
            PostingSetupMgtCZZ.LogVATPostingSetupFieldError(Rec, FieldNo("Purch. Adv.Letter VAT Acc. CZZ"));

        exit("Purch. Adv.Letter VAT Acc. CZZ");
    end;

    procedure GetPurchAdvLetterNDVATAccountCZZ(): Code[20]
    var
        AccountNo: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        AccountNo := '';
        OnBeforeGetPurchAdvLetterNDVATAccountCZZ(Rec, AccountNo, IsHandled);
        if IsHandled then
            exit(AccountNo);

        if "P.Adv.Letter ND VAT Acc. CZZ" = '' then
            PostingSetupMgtCZZ.LogVATPostingSetupFieldError(Rec, FieldNo("P.Adv.Letter ND VAT Acc. CZZ"));

        exit("P.Adv.Letter ND VAT Acc. CZZ");
    end;

    internal procedure IsNonDeductibleVATAllowed() IsAllowed: Boolean
    begin
        IsAllowed :=
            "Allow Non-Deductible VAT" in [
                "Allow Non-Deductible VAT Type"::Allow,
                "Allow Non-Deductible VAT Type"::"Do Not Apply CZL"];
        OnIsAllowedNonDeductibleVAT(Rec, IsAllowed);
    end;

    internal procedure IsNonDeductibleVATAllowed(VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20]): Boolean
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetLoadFields("VAT Bus. Posting Group", "VAT Prod. Posting Group");
        if VATPostingSetup.Get(VATBusPostingGroup, VATProdPostingGroup) then
            exit(VATPostingSetup.IsNonDeductibleVATAllowed());
    end;

    internal procedure CheckNonDeductibleVATAllowed()
    begin
        if not IsNonDeductibleVATAllowed() then
            Error(GetNonDeductibleVATNotAllowedErrorInfo("VAT Bus. Posting Group", "VAT Prod. Posting Group"));
    end;

    internal procedure CheckNonDeductibleVATAllowed(VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        VATPostingSetup.SetLoadFields("VAT Bus. Posting Group", "VAT Prod. Posting Group");
        if VATPostingSetup.Get(VATBusPostingGroup, VATProdPostingGroup) then
            VATPostingSetup.CheckNonDeductibleVATAllowed();
    end;

    local procedure GetNonDeductibleVATNotAllowedErrorInfo(VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20]): ErrorInfo
    var
        NonDeductibleVATNotAllowedErrorInfo: ErrorInfo;
    begin
        NonDeductibleVATNotAllowedErrorInfo.ErrorType := ErrorType::Client;
        NonDeductibleVATNotAllowedErrorInfo.Verbosity := Verbosity::Warning;
        NonDeductibleVATNotAllowedErrorInfo.Collectible := true;
        NonDeductibleVATNotAllowedErrorInfo.Title := NonDeductibleVATNotAllowedTitleLbl;
        NonDeductibleVATNotAllowedErrorInfo.Message := StrSubstNo(NonDeductibleVATNotAllowedErr, VATBusPostingGroup, VATProdPostingGroup);
        NonDeductibleVATNotAllowedErrorInfo.RecordId := Rec.RecordId;
        NonDeductibleVATNotAllowedErrorInfo.FieldNo := Rec.FieldNo("Allow Non-Deductible VAT");
        NonDeductibleVATNotAllowedErrorInfo.TableId := Database::"VAT Posting Setup";
        NonDeductibleVATNotAllowedErrorInfo.PageNo := Page::"VAT Posting Setup Card";
        NonDeductibleVATNotAllowedErrorInfo.AddNavigationAction(ShowVATPostingSetupCardLbl);
        exit(NonDeductibleVATNotAllowedErrorInfo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetSalesAdvLetterAccountCZZ(var VATPostingSetup: Record "VAT Posting Setup"; var AccountNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetSalesAdvLetterVATAccountCZZ(var VATPostingSetup: Record "VAT Posting Setup"; var AccountNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPurchAdvLetterAccountCZZ(var VATPostingSetup: Record "VAT Posting Setup"; var AccountNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPurchAdvLetterVATAccountCZZ(var VATPostingSetup: Record "VAT Posting Setup"; var AccountNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPurchAdvLetterNDVATAccountCZZ(var VATPostingSetup: Record "VAT Posting Setup"; var AccountNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsAllowedNonDeductibleVAT(var VATPostingSetup: Record "VAT Posting Setup"; var IsAllowed: Boolean)
    begin
    end;
}
