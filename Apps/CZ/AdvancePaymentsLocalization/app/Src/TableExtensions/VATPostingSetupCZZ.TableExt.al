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
    }

    var
        PostingSetupMgtCZZ: Codeunit PostingSetupManagement;

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
        OnBeforeGetPurchAdvLetterAccountCZZ(Rec, AccountNo, IsHandled);
        if IsHandled then
            exit(AccountNo);

        if "Purch. Adv.Letter VAT Acc. CZZ" = '' then
            PostingSetupMgtCZZ.LogVATPostingSetupFieldError(Rec, FieldNo("Purch. Adv.Letter VAT Acc. CZZ"));

        exit("Purch. Adv.Letter VAT Acc. CZZ");
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
}
