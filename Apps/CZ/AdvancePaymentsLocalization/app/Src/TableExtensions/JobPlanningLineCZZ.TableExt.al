// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Planning;
using Microsoft.Projects.Resources.Resource;

tableextension 31062 "Job Planning Line CZZ" extends "Job Planning Line"
{
    var
        GLAccount: Record "G/L Account";
        Item: Record Item;
        JobTask: Record "Job Task";
        Resource: Record Resource;
        VATPostingSetup: Record "VAT Posting Setup";
        VATProdPostingGroupNotSpecifiedErr: Label 'The VAT Prod. Posting Group must be specified in the %1 %2 from the Project Planning Line %3 %4 %5.',
            Comment = '%1 = Type, %2 = No., %3 = Job No., %4 = Job Task No., %5 = Line No.';

    internal procedure CalcLineAmountIncludingVAT(): Decimal
    begin
        GetVATPostingSetup();
        if VATPostingSetup."VAT Calculation Type" = VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT" then
            VATPostingSetup."VAT %" := 0;
        exit(CalcLineAmountIncludingVAT(VATPostingSetup."VAT %"));
    end;

    internal procedure CalcLineAmountIncludingVAT(VATPer: Decimal): Decimal
    begin
        exit("Line Amount" * (100 + VATPer) / 100);
    end;

    internal procedure GetVATBusPostingGroup(): Code[20]
    begin
        GetJobTask();
        exit(JobTask.GetVATBusPostingGroup());
    end;

    internal procedure GetVATProdPostingGroup(): Code[20]
    begin
        case Type of
            Type::"G/L Account":
                begin
                    GetGLAccount();
                    exit(GLAccount."VAT Prod. Posting Group");
                end;
            Type::Item:
                begin
                    GetItem();
                    exit(Item."VAT Prod. Posting Group");
                end;
            Type::Resource:
                begin
                    GetResource();
                    exit(Resource."VAT Prod. Posting Group");
                end;
        end;
    end;

    internal procedure CheckVATProdPostingGroup()
    var
        VATProdPostingGroup: Code[20];
    begin
        VATProdPostingGroup := GetVATProdPostingGroup();
        if VATProdPostingGroup = '' then
            Error(
                ErrorInfo.Create(
                    StrSubstNo(VATProdPostingGroupNotSpecifiedErr, Type, "No.", "Job No.", "Job Task No.", "Line No."),
                    true, Rec, Rec.FieldNo("No.")));
    end;

    internal procedure GetInvoiceCurrencyFactor(): Decimal
    begin
        exit(GetInvoiceCurrencyFactor(WorkDate()));
    end;

    internal procedure GetInvoiceCurrencyFactor(CurrencyDate: Date) CurrencyFactor: Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        GetJobTask();
        CurrencyFactor := 1;
        if JobTask."Invoice Currency Code" <> '' then
            CurrencyFactor := CurrencyExchangeRate.ExchangeRate(CurrencyDate, JobTask."Invoice Currency Code");
    end;

    local procedure GetJobTask()
    begin
        if ("Job No." <> JobTask."Job No.") and ("Job No." <> '') or
           ("Job Task No." <> JobTask."Job Task No.") and ("Job Task No." <> '')
        then
            if not JobTask.Get("Job No.", "Job Task No.") then
                JobTask.Init();
    end;

    local procedure GetVATPostingSetup()
    var
        VATBusPostingGroup: Code[20];
        VATProdPostingGroup: Code[20];
    begin
        VATBusPostingGroup := GetVATBusPostingGroup();
        VATProdPostingGroup := GetVATProdPostingGroup();
        if (VATBusPostingGroup <> VATPostingSetup."VAT Bus. Posting Group") and (VATBusPostingGroup <> '') or
           (VATProdPostingGroup <> VATPostingSetup."VAT Prod. Posting Group") and (VATProdPostingGroup <> '')
        then
            if not VATPostingSetup.Get(VATBusPostingGroup, VATProdPostingGroup) then
                VATPostingSetup.Init();
    end;

    local procedure GetGLAccount()
    begin
        if ("No." <> GLAccount."No.") and ("No." <> '') then
            if not GLAccount.Get("No.") then
                GLAccount.Init();
    end;

    local procedure GetItem()
    begin
        if ("No." <> Item."No.") and ("No." <> '') then
            if not Item.Get("No.") then
                Item.Init();
    end;

    local procedure GetResource()
    begin
        if ("No." <> Resource."No.") and ("No." <> '') then
            if not Resource.Get("No.") then
                Resource.Init();
    end;
}