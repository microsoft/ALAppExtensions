// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.Currency;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Planning;
using Microsoft.Sales.Document;
using Microsoft.Sales.Posting;
using System.Utilities;

report 31012 "Create Sales Adv. Letter CZZ"
{
    Caption = 'Create Sales Advance Letter';
    UsageCategory = None;
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(AdvLetterCode; AdvanceLetterCode)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Advance Letter Code';
                        TableRelation = "Advance Letter Template CZZ" where("Sales/Purchase" = const(Sales));
                        ToolTip = 'Specifies advance letter code.';
                    }
                    field(AdvPer; AdvancePer)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Advance Letter %';
                        ToolTip = 'Specifies advance letter %.';
                        MinValue = 0;
                        MaxValue = 100;
                        DecimalPlaces = 2 : 2;

                        trigger OnValidate()
                        begin
                            AdvanceAmount := Round(TotalAmountInclVAT * AdvancePer / 100, Currency."Amount Rounding Precision");
                        end;
                    }
                    field(AdvAmount; AdvanceAmount)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Advance Letter Amount';
                        ToolTip = 'Specifies advance letter amount.';
                        MinValue = 0;

                        trigger OnValidate()
                        begin
                            if AdvanceAmount > TotalAmountInclVAT then
                                Error(AmountCannotBeGreaterErr, TotalAmountInclVAT);

                            AdvancePer := Round(AdvanceAmount / TotalAmountInclVAT * 100);
                        end;
                    }
                    field(SuggByLine; SuggestByLine)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Suggest by Line';
                        ToolTip = 'Specifies if advance letter will by suggest by line.';
                    }
                }
            }
        }
    }

    var
        Currency: Record Currency;
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        SalesPost: Codeunit "Sales-Post";
        TotalAmountInclVAT: Decimal;
        TotalAmountAdvLetter: Decimal;
        Coef: Decimal;
        AdvLetterCodeEmptyErr: Label 'Advance Letter Code cannot be empty.';
        NothingToSuggestErr: Label 'Nothing to sugget.';
        AmountCannotBeGreaterErr: Label 'Amount cannot be greater than %1.', Comment = '%1 = Amount Including VAT';
        AmountExceedeErr: Label 'Sum of Advance letters exceeded.';
        DifferentBillCustomersErr: Label 'The %1 must be the same in all project tasks. To create a Advance Letter, use the Create Sales Advance Letter for project task function.', Comment = '%1 = field name';
        JobPostingDescriptionTxt: Label 'Project %1', Comment = '%1 = Job No.';

    protected var
        SourceSalesHeader: Record "Sales Header";
        SourceJob: Record Job;
        SourceJobTask: Record "Job Task";
        TempJobPlanningLine: Record "Job Planning Line" temporary;
        TempSalesLine: Record "Sales Line" temporary;
        AdvanceLetterCode: Code[20];
        AdvancePer: Decimal;
        AdvanceAmount: Decimal;
        SuggestByLine: Boolean;
        SourceType: Option SalesOrder,Job,JobTask;

    trigger OnPreReport()
    begin
        if (AdvanceAmount = 0) then
            Error(NothingToSuggestErr);
        if AdvanceLetterCode = '' then
            Error(AdvLetterCodeEmptyErr);

        case SourceType of
            SourceType::SalesOrder:
                SalesAdvLetterHeaderCZZ.SetRange("Order No.", SourceSalesHeader."No.");
            SourceType::Job:
                SalesAdvLetterHeaderCZZ.SetRange("Job No.", SourceJob."No.");
            SourceType::JobTask:
                begin
                    SalesAdvLetterHeaderCZZ.SetRange("Job No.", SourceJobTask."Job No.");
                    SalesAdvLetterHeaderCZZ.SetRange("Job Task No.", SourceJobTask."Job Task No.");
                end;
        end;

        SalesAdvLetterHeaderCZZ.SetAutoCalcFields("Amount Including VAT");
        if SalesAdvLetterHeaderCZZ.FindSet() then
            repeat
                TotalAmountAdvLetter += SalesAdvLetterHeaderCZZ."Amount Including VAT";
            until SalesAdvLetterHeaderCZZ.Next() = 0;

        if TotalAmountAdvLetter + AdvanceAmount > TotalAmountInclVAT then
            Error(AmountExceedeErr);

        AdvanceLetterTemplateCZZ.Get(AdvanceLetterCode);
        Coef := AdvanceAmount / TotalAmountInclVAT;
    end;

    trigger OnPostReport()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        OpenAdvanceLetterQst: Label 'Do you want to open created Advance Letter?';
    begin
        case SourceType of
            SourceType::SalesOrder:
                begin
                    CreateAdvanceLetterHeader(SourceSalesHeader);
                    CreateAdvanceLetterLine(TempSalesLine);
                    CreateAdvanceLetterApplication();
                end;
            SourceType::Job:
                begin
                    CreateAdvanceLetterHeader(SourceJob);
                    CreateAdvanceLetterLine(TempJobPlanningLine);
                end;
            SourceType::JobTask:
                begin
                    CreateAdvanceLetterHeader(SourceJobTask);
                    CreateAdvanceLetterLine(TempJobPlanningLine);
                end;
        end;

        if ConfirmManagement.GetResponseOrDefault(OpenAdvanceLetterQst, false) then
            if GuiAllowed() then
                Page.Run(Page::"Sales Advance Letter CZZ", SalesAdvLetterHeaderCZZ);
    end;

    local procedure CreateAdvanceLetterHeader(SalesHeader: Record "Sales Header")
    begin
        SalesAdvLetterHeaderCZZ.Init();
        SalesAdvLetterHeaderCZZ.Validate("Advance Letter Code", AdvanceLetterCode);
        SalesAdvLetterHeaderCZZ."No." := '';
        SalesAdvLetterHeaderCZZ.Insert(true);
        SalesAdvLetterHeaderCZZ."Bill-to Customer No." := SalesHeader."Bill-to Customer No.";
        SalesAdvLetterHeaderCZZ."Bill-to Name" := SalesHeader."Bill-to Name";
        SalesAdvLetterHeaderCZZ."Bill-to Name 2" := SalesHeader."Bill-to Name 2";
        SalesAdvLetterHeaderCZZ."Bill-to Address" := SalesHeader."Bill-to Address";
        SalesAdvLetterHeaderCZZ."Bill-to Address 2" := SalesHeader."Bill-to Address 2";
        SalesAdvLetterHeaderCZZ."Bill-to City" := SalesHeader."Bill-to City";
        SalesAdvLetterHeaderCZZ."Bill-to Contact" := SalesHeader."Bill-to Contact";
        SalesAdvLetterHeaderCZZ."Bill-to Contact No." := SalesHeader."Bill-to Contact No.";
        SalesAdvLetterHeaderCZZ."Bill-to Country/Region Code" := SalesHeader."Bill-to Country/Region Code";
        SalesAdvLetterHeaderCZZ."Bill-to County" := SalesHeader."Bill-to County";
        SalesAdvLetterHeaderCZZ."Bill-to Post Code" := SalesHeader."Bill-to Post Code";
        SalesAdvLetterHeaderCZZ."Language Code" := SalesHeader."Language Code";
        SalesAdvLetterHeaderCZZ."Format Region" := SalesHeader."Format Region";
        SalesAdvLetterHeaderCZZ."Salesperson Code" := SalesHeader."Salesperson Code";
        SalesAdvLetterHeaderCZZ."Shortcut Dimension 1 Code" := SalesHeader."Shortcut Dimension 1 Code";
        SalesAdvLetterHeaderCZZ."Shortcut Dimension 2 Code" := SalesHeader."Shortcut Dimension 2 Code";
        SalesAdvLetterHeaderCZZ."Dimension Set ID" := SalesHeader."Dimension Set ID";
        SalesAdvLetterHeaderCZZ."VAT Bus. Posting Group" := SalesHeader."VAT Bus. Posting Group";
        SalesAdvLetterHeaderCZZ."Posting Date" := SalesHeader."Posting Date";
        SalesAdvLetterHeaderCZZ."Advance Due Date" := SalesHeader."Due Date";
        SalesAdvLetterHeaderCZZ."Document Date" := SalesHeader."Document Date";
        SalesAdvLetterHeaderCZZ."VAT Date" := SalesHeader."VAT Reporting Date";
        SalesAdvLetterHeaderCZZ."Posting Description" := SalesHeader."Posting Description";
        SalesAdvLetterHeaderCZZ."Payment Method Code" := SalesHeader."Payment Method Code";
        SalesAdvLetterHeaderCZZ."Payment Terms Code" := SalesHeader."Payment Terms Code";
        SalesAdvLetterHeaderCZZ."Registration No." := SalesHeader.GetRegistrationNoTrimmedCZL();
        SalesAdvLetterHeaderCZZ."Tax Registration No." := SalesHeader."Tax Registration No. CZL";
        SalesAdvLetterHeaderCZZ."VAT Registration No." := SalesHeader."VAT Registration No.";
        SalesAdvLetterHeaderCZZ."Order No." := SalesHeader."No.";
        SalesAdvLetterHeaderCZZ."Bank Account Code" := SalesHeader."Bank Account Code CZL";
        SalesAdvLetterHeaderCZZ."Bank Account No." := SalesHeader."Bank Account No. CZL";
        SalesAdvLetterHeaderCZZ."Bank Branch No." := SalesHeader."Bank Branch No. CZL";
        SalesAdvLetterHeaderCZZ."Specific Symbol" := SalesHeader."Specific Symbol CZL";
        SalesAdvLetterHeaderCZZ."Variable Symbol" := SalesHeader."Variable Symbol CZL";
        SalesAdvLetterHeaderCZZ."Constant Symbol" := SalesHeader."Constant Symbol CZL";
        SalesAdvLetterHeaderCZZ.IBAN := SalesHeader."IBAN CZL";
        SalesAdvLetterHeaderCZZ."SWIFT Code" := SalesHeader."SWIFT Code CZL";
        SalesAdvLetterHeaderCZZ."Bank Name" := SalesHeader."Bank Name CZL";
        SalesAdvLetterHeaderCZZ."Transit No." := SalesHeader."Transit No. CZL";
        SalesAdvLetterHeaderCZZ."Responsibility Center" := SalesHeader."Responsibility Center";
        SalesAdvLetterHeaderCZZ."Currency Code" := SalesHeader."Currency Code";
        SalesAdvLetterHeaderCZZ."Currency Factor" := SalesHeader."Currency Factor";
        SalesAdvLetterHeaderCZZ."VAT Country/Region Code" := SalesHeader."VAT Country/Region Code";
        SalesAdvLetterHeaderCZZ."Automatic Post VAT Document" := AdvanceLetterTemplateCZZ."Automatic Post VAT Document";
        OnCreateAdvanceLetterHeaderOnBeforeModifySalesAdvLetterHeaderCZZ(SalesHeader, AdvanceLetterTemplateCZZ, SalesAdvLetterHeaderCZZ);
        SalesAdvLetterHeaderCZZ.Modify(true);
    end;

    local procedure CreateAdvanceLetterHeader(Job: Record Job)
    begin
        SalesAdvLetterHeaderCZZ.Init();
        SalesAdvLetterHeaderCZZ.Validate("Advance Letter Code", AdvanceLetterCode);
        SalesAdvLetterHeaderCZZ."No." := '';
        SalesAdvLetterHeaderCZZ.Insert(true);
        SalesAdvLetterHeaderCZZ.Validate("Bill-to Customer No.", Job."Bill-to Customer No.");
        SalesAdvLetterHeaderCZZ."Bill-to Name" := Job."Bill-to Name";
        SalesAdvLetterHeaderCZZ."Bill-to Name 2" := Job."Bill-to Name 2";
        SalesAdvLetterHeaderCZZ."Bill-to Address" := Job."Bill-to Address";
        SalesAdvLetterHeaderCZZ."Bill-to Address 2" := Job."Bill-to Address 2";
        SalesAdvLetterHeaderCZZ."Bill-to City" := Job."Bill-to City";
        SalesAdvLetterHeaderCZZ."Bill-to Contact" := Job."Bill-to Contact";
        SalesAdvLetterHeaderCZZ."Bill-to Contact No." := Job."Bill-to Contact No.";
        SalesAdvLetterHeaderCZZ."Bill-to Country/Region Code" := Job."Bill-to Country/Region Code";
        SalesAdvLetterHeaderCZZ."Bill-to County" := Job."Bill-to County";
        SalesAdvLetterHeaderCZZ."Bill-to Post Code" := Job."Bill-to Post Code";
        SalesAdvLetterHeaderCZZ."Posting Description" := StrSubstNo(JobPostingDescriptionTxt, Job."No.");
        SalesAdvLetterHeaderCZZ."Payment Method Code" := Job."Payment Method Code";
        SalesAdvLetterHeaderCZZ.Validate("Payment Terms Code", Job."Payment Terms Code");
        SalesAdvLetterHeaderCZZ.Validate("Shortcut Dimension 1 Code", Job."Global Dimension 1 Code");
        SalesAdvLetterHeaderCZZ.Validate("Shortcut Dimension 2 Code", Job."Global Dimension 2 Code");
        SalesAdvLetterHeaderCZZ.Validate("Job No.", Job."No.");
        if Job."Currency Code" <> '' then
            SalesAdvLetterHeaderCZZ.Validate("Currency Code", Job."Currency Code");
        if Job."Invoice Currency Code" <> '' then
            SalesAdvLetterHeaderCZZ.Validate("Currency Code", Job."Invoice Currency Code");
        SalesAdvLetterHeaderCZZ.Modify(true);
    end;

    local procedure CreateAdvanceLetterHeader(JobTask: Record "Job Task")
    begin
        SalesAdvLetterHeaderCZZ.Init();
        SalesAdvLetterHeaderCZZ.Validate("Advance Letter Code", AdvanceLetterCode);
        SalesAdvLetterHeaderCZZ."No." := '';
        SalesAdvLetterHeaderCZZ.Insert(true);
        SalesAdvLetterHeaderCZZ.Validate("Bill-to Customer No.", JobTask.GetBillToCustomer()."No.");
        if JobTask."Bill-to Customer No." <> '' then begin
            SalesAdvLetterHeaderCZZ."Bill-to Customer No." := JobTask."Bill-to Customer No.";
            SalesAdvLetterHeaderCZZ."Bill-to Name" := JobTask."Bill-to Name";
            SalesAdvLetterHeaderCZZ."Bill-to Name 2" := JobTask."Bill-to Name 2";
            SalesAdvLetterHeaderCZZ."Bill-to Address" := JobTask."Bill-to Address";
            SalesAdvLetterHeaderCZZ."Bill-to Address 2" := JobTask."Bill-to Address 2";
            SalesAdvLetterHeaderCZZ."Bill-to City" := JobTask."Bill-to City";
            SalesAdvLetterHeaderCZZ."Bill-to Contact" := JobTask."Bill-to Contact";
            SalesAdvLetterHeaderCZZ."Bill-to Contact No." := JobTask."Bill-to Contact No.";
            SalesAdvLetterHeaderCZZ."Bill-to Country/Region Code" := JobTask."Bill-to Country/Region Code";
            SalesAdvLetterHeaderCZZ."Bill-to County" := JobTask."Bill-to County";
            SalesAdvLetterHeaderCZZ."Bill-to Post Code" := JobTask."Bill-to Post Code";
        end;
        SalesAdvLetterHeaderCZZ."Posting Description" := StrSubstNo(JobPostingDescriptionTxt, JobTask."Job No.");
        SalesAdvLetterHeaderCZZ."Payment Method Code" := JobTask."Payment Method Code";
        SalesAdvLetterHeaderCZZ.Validate("Payment Terms Code", JobTask."Payment Terms Code");
        SalesAdvLetterHeaderCZZ.Validate("Shortcut Dimension 1 Code", JobTask."Global Dimension 1 Code");
        SalesAdvLetterHeaderCZZ.Validate("Shortcut Dimension 2 Code", JobTask."Global Dimension 2 Code");
        SalesAdvLetterHeaderCZZ.Validate("Job No.", JobTask."Job No.");
        SalesAdvLetterHeaderCZZ.Validate("Job Task No.", JobTask."Job Task No.");
        if JobTask.GetCurrencyCode() <> '' then
            SalesAdvLetterHeaderCZZ.Validate("Currency Code", JobTask.GetCurrencyCode());
        if JobTask."Invoice Currency Code" <> '' then
            SalesAdvLetterHeaderCZZ.Validate("Currency Code", JobTask."Invoice Currency Code");
        SalesAdvLetterHeaderCZZ.Modify(true);
    end;

    local procedure CreateAdvanceLetterLine(var SalesLine: Record "Sales Line")
    var
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
    begin
        SalesLine.SetFilter(Type, '>%1', SalesLine.Type::" ");
        SalesLine.SetFilter(Amount, '<>0');
        SalesLine.SetLoadFields(Description, "VAT Bus. Posting Group", "VAT Prod. Posting Group", "Amount Including VAT");
        if SalesLine.FindSet() then
            repeat
                if SuggestByLine then
                    CreateAdvanceLetterLine(
                        SalesLine.Description,
                        SalesLine."VAT Bus. Posting Group",
                        SalesLine."VAT Prod. Posting Group",
                        SalesLine."Amount Including VAT")
                else
                    CreateAdvancePostingBuffer(
                        SalesLine."VAT Bus. Posting Group",
                        SalesLine."VAT Prod. Posting Group",
                        SalesLine."Amount Including VAT",
                        TempAdvancePostingBufferCZZ);
            until SalesLine.Next() = 0;

        if TempAdvancePostingBufferCZZ.FindSet() then
            repeat
                CreateAdvanceLetterLine('',
                    TempAdvancePostingBufferCZZ."VAT Bus. Posting Group",
                    TempAdvancePostingBufferCZZ."VAT Prod. Posting Group",
                    TempAdvancePostingBufferCZZ.Amount);
            until TempAdvancePostingBufferCZZ.Next() = 0;
    end;

    local procedure CreateAdvanceLetterLine(var JobPlanningLine: Record "Job Planning Line")
    var
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        AmountIncludingVAT: Decimal;
    begin
        JobPlanningLine.SetFilter(Type, '<>%1', JobPlanningLine.Type::Text);
        JobPlanningLine.SetFilter("Line Amount", '<>0');
        JobPlanningLine.SetLoadFields("Job No.", "Job Task No.", "Line No.", Type, "No.", Description, "Line Amount");
        if JobPlanningLine.FindSet() then
            repeat
                AmountIncludingVAT :=
                    Round(JobPlanningLine.CalcLineAmountIncludingVAT() * JobPlanningLine.GetInvoiceCurrencyFactor(),
                        Currency."Amount Rounding Precision");
                if SuggestByLine then
                    CreateAdvanceLetterLine(
                        JobPlanningLine.Description,
                        JobPlanningLine.GetVATBusPostingGroup(),
                        JobPlanningLine.GetVATProdPostingGroup(),
                        AmountIncludingVAT)
                else
                    CreateAdvancePostingBuffer(
                        JobPlanningLine.GetVATBusPostingGroup(),
                        JobPlanningLine.GetVATProdPostingGroup(),
                        AmountIncludingVAT,
                        TempAdvancePostingBufferCZZ);
            until JobPlanningLine.Next() = 0;

        if TempAdvancePostingBufferCZZ.FindSet() then
            repeat
                CreateAdvanceLetterLine('',
                    TempAdvancePostingBufferCZZ."VAT Bus. Posting Group",
                    TempAdvancePostingBufferCZZ."VAT Prod. Posting Group",
                    TempAdvancePostingBufferCZZ.Amount);
            until TempAdvancePostingBufferCZZ.Next() = 0;
    end;

    local procedure CreateAdvancePostingBuffer(VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; AmountIncludingVAT: Decimal; var TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary)
    begin
        TempAdvancePostingBufferCZZ.Init();
        TempAdvancePostingBufferCZZ."VAT Bus. Posting Group" := VATBusPostingGroup;
        TempAdvancePostingBufferCZZ."VAT Prod. Posting Group" := VATProdPostingGroup;
        if TempAdvancePostingBufferCZZ.Find() then begin
            TempAdvancePostingBufferCZZ.Amount += AmountIncludingVAT;
            TempAdvancePostingBufferCZZ.Modify();
        end else begin
            TempAdvancePostingBufferCZZ.Amount := AmountIncludingVAT;
            TempAdvancePostingBufferCZZ.Insert();
        end;
    end;

    local procedure CreateAdvanceLetterLine(Description: Text[100]; VATBusPostingGroup: Code[20]; VATProdPostingGroup: Code[20]; AmountIncludingVAT: Decimal)
    begin
        SalesAdvLetterLineCZZ.Init();
        SalesAdvLetterLineCZZ."Document No." := SalesAdvLetterHeaderCZZ."No.";
        SalesAdvLetterLineCZZ."Line No." += 10000;
        SalesAdvLetterLineCZZ.Description := Description;
        SalesAdvLetterLineCZZ."VAT Bus. Posting Group" := VATBusPostingGroup;
        SalesAdvLetterLineCZZ.Validate("VAT Prod. Posting Group", VATProdPostingGroup);
        SalesAdvLetterLineCZZ.SuspendJobRelationCheck(true);
        SalesAdvLetterLineCZZ.Validate("Amount Including VAT", Round(AmountIncludingVAT * Coef, Currency."Amount Rounding Precision"));
        SalesAdvLetterLineCZZ.SuspendJobRelationCheck(false);
        if SalesAdvLetterLineCZZ."Amount Including VAT" <> 0 then
            SalesAdvLetterLineCZZ.Insert(true);
    end;

    local procedure CreateAdvanceLetterApplication()
    begin
        AdvanceLetterApplicationCZZ.Init();
        AdvanceLetterApplicationCZZ."Advance Letter Type" := AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales;
        AdvanceLetterApplicationCZZ."Advance Letter No." := SalesAdvLetterHeaderCZZ."No.";
        AdvanceLetterApplicationCZZ."Document Type" := AdvanceLetterApplicationCZZ."Document Type"::"Sales Order";
        AdvanceLetterApplicationCZZ."Document No." := SourceSalesHeader."No.";
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT", "Amount Including VAT (LCY)");
        AdvanceLetterApplicationCZZ.Amount := SalesAdvLetterHeaderCZZ."Amount Including VAT";
        AdvanceLetterApplicationCZZ."Amount (LCY)" := SalesAdvLetterHeaderCZZ."Amount Including VAT (LCY)";
        AdvanceLetterApplicationCZZ.Insert();
    end;

    procedure SetSalesHeader(var NewSalesHeader: Record "Sales Header")
    begin
        NewSalesHeader.TestField("Document Type", NewSalesHeader."Document Type"::Order);
        SourceSalesHeader := NewSalesHeader;
        SalesPost.GetSalesLines(SourceSalesHeader, TempSalesLine, 0);
        TempSalesLine.CalcSums("Amount Including VAT");
        TotalAmountInclVAT := TempSalesLine."Amount Including VAT";

        AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvanceLetterApplicationCZZ."Document Type"::"Sales Order");
        AdvanceLetterApplicationCZZ.SetRange("Document No.", SourceSalesHeader."No.");
        AdvanceLetterApplicationCZZ.CalcSums(Amount);

        AdvanceAmount := TotalAmountInclVAT - AdvanceLetterApplicationCZZ.Amount;
        if AdvanceAmount > 0 then
            AdvancePer := Round(AdvanceAmount / TotalAmountInclVAT * 100)
        else
            AdvanceAmount := 0;

        InitCurrency(SourceSalesHeader."Currency Code");
        SourceType := SourceType::SalesOrder;
    end;

    procedure SetJob(var NewJob: Record Job)
    begin
        SourceJob := NewJob;
        CheckJobTasks(SourceJob."No.");

        CollectJobPlanningLine(SourceJob."No.");

        AdvanceAmount := TotalAmountInclVAT;
        AdvancePer := 100;

        if SourceJob."Invoice Currency Code" <> '' then
            InitCurrency(SourceJob."Invoice Currency Code")
        else
            InitCurrency(SourceJob."Currency Code");
        SourceType := SourceType::Job;
    end;

    procedure SetJobTask(var NewJobTask: Record "Job Task")
    begin
        SourceJobTask := NewJobTask;

        CollectJobPlanningLine(SourceJobTask."Job No.", SourceJobTask."Job Task No.");

        AdvanceAmount := TotalAmountInclVAT;
        AdvancePer := 100;

        if SourceJobTask."Invoice Currency Code" <> '' then
            InitCurrency(SourceJobTask."Invoice Currency Code")
        else
            InitCurrency(SourceJobTask.GetCurrencyCode());
        SourceType := SourceType::JobTask;
    end;

    local procedure CollectJobPlanningLine(JobNo: Code[20])
    begin
        CollectJobPlanningLine(JobNo, '');
    end;

    local procedure CollectJobPlanningLine(JobNo: Code[20]; JobTaskNo: Code[20])
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        TotalAmountInclVAT := 0;

        JobPlanningLine.SetRange("Job No.", JobNo);
        if JobTaskNo <> '' then
            JobPlanningLine.SetRange("Job Task No.", JobTaskNo);
        JobPlanningLine.SetRange("Contract Line", true);
        JobPlanningLine.SetFilter(Type, '<>%1', JobPlanningLine.Type::Text);
        JobPlanningLine.SetFilter("Line Amount", '<>%1', 0);
        if JobPlanningLine.FindSet() then
            repeat
                JobPlanningLine.CheckVATProdPostingGroup();
                TotalAmountInclVAT +=
                    Round(JobPlanningLine.CalcLineAmountIncludingVAT() * JobPlanningLine.GetInvoiceCurrencyFactor(),
                        Currency."Amount Rounding Precision");

                TempJobPlanningLine.Init();
                TempJobPlanningLine := JobPlanningLine;
                TempJobPlanningLine.Insert();
            until JobPlanningLine.Next() = 0;
    end;

    local procedure CheckJobTasks(JobNo: Code[20])
    var
        JobTask: Record "Job Task";
    begin
        JobTask.SetLoadFields("Bill-to Customer No.", "Invoice Currency Code");
        JobTask.SetRange("Job No.", JobNo);
        JobTask.SetRange("Job Task Type", JobTask."Job Task Type"::Posting);
        if not JobTask.FindFirst() then
            exit;
        JobTask.SetFilter("Bill-to Customer No.", '<>%1', JobTask."Bill-to Customer No.");
        if not JobTask.IsEmpty() then
            Error(DifferentBillCustomersErr, JobTask.FieldCaption("Bill-to Customer No."));
        JobTask.SetRange("Bill-to Customer No.");
        JobTask.SetFilter("Invoice Currency Code", '<>%1', JobTask."Invoice Currency Code");
        if not JobTask.IsEmpty() then
            Error(DifferentBillCustomersErr, JobTask.FieldCaption("Invoice Currency Code"));
    end;

    local procedure InitCurrency(CurrencyCode: Code[10])
    begin
        if CurrencyCode = '' then
            Currency.InitRoundingPrecision()
        else begin
            Currency.Get(CurrencyCode);
            Currency.TestField("Amount Rounding Precision");
        end;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCreateAdvanceLetterHeaderOnBeforeModifySalesAdvLetterHeaderCZZ(SalesHeader: Record "Sales Header"; AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;
}
