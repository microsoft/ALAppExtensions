// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

report 31040 "Copy Adv. Letter Document CZZ"
{
    Caption = 'Copy Advance Letter Document';
    ProcessingOnly = true;

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';

                    field(DocumentNo; FromDocNo)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Document No.';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the number of the document that is processed by the report or batch job.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            LookupDocNo();
                        end;

                        trigger OnValidate()
                        begin
                            ValidateDocNo();
                        end;
                    }
                    field(IncludeHeaderAction; IncludeHeader)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Include Header';
                        ToolTip = 'Specifies if you also want to copy the information from the document header. When you copy quotes, if the posting date field of the new document is empty, the work date is used as the posting date of the new document.';

                        trigger OnValidate()
                        begin
                            ValidateIncludeHeader();
                        end;
                    }
                    field(RecalculateLinesAction; RecalculateLines)
                    {
                        ApplicationArea = Suite;
                        Caption = 'Recalculate Lines';
                        ToolTip = 'Specifies that lines are recalculate and inserted on the advance letter document you are creating. The batch job retains the item numbers and item quantities but recalculates the amounts on the lines based on the customer information on the new document header. In this way, the batch job accounts for item prices and discounts that are specifically linked to the customer on the new header.';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if FromDocNo <> '' then
                if not GetDocument() then
                    FromDocNo := '';

            ValidateDocNo();
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if CloseAction = Action::OK then
                if FromDocNo = '' then
                    Error(DocNoNotSerErr)
        end;
    }

    trigger OnPreReport()
    begin
        CopyDocumentMgtCZZ.SetProperties(IncludeHeader, RecalculateLines);
        if IsSales then
            CopyDocumentMgtCZZ.CopyDocument(FromDocNo, SalesAdvLetterHeaderCZZ)
        else
            CopyDocumentMgtCZZ.CopyDocument(FromDocNo, PurchAdvLetterHeaderCZZ);
    end;

    var
        DocNoNotSerErr: Label 'Select a document number to continue, or choose Cancel to close the page.';

    protected var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        FromSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        FromPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        CopyDocumentMgtCZZ: Codeunit "Copy Document Mgt. CZZ";
        FromDocNo: Code[20];
        IncludeHeader: Boolean;
        RecalculateLines: Boolean;
        IsSales: Boolean;

    procedure SetSalesAdvLetterHeader(var NewSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        NewSalesAdvLetterHeaderCZZ.TestField("No.");
        NewSalesAdvLetterHeaderCZZ.TestField(Status, "Advance Letter Doc. Status CZZ"::New);
        SalesAdvLetterHeaderCZZ := NewSalesAdvLetterHeaderCZZ;
        IsSales := true;
    end;

    procedure SetPurchAdvLetterHeader(var NewPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        NewPurchAdvLetterHeaderCZZ.TestField("No.");
        NewPurchAdvLetterHeaderCZZ.TestField(Status, "Advance Letter Doc. Status CZZ"::New);
        PurchAdvLetterHeaderCZZ := NewPurchAdvLetterHeaderCZZ;
        IsSales := false;
    end;

    local procedure GetDocument(): Boolean
    begin
        if IsSales then
            exit(FromSalesAdvLetterHeaderCZZ.Get(FromDocNo));
        exit(FromPurchAdvLetterHeaderCZZ.Get(FromDocNo));
    end;

    local procedure ValidateDocNo()
    begin
        if IsSales then
            ValidateSalesAdvLetterNo()
        else
            ValidatePurchAdvLetterNo();
    end;

    local procedure ValidateSalesAdvLetterNo()
    begin
        if FromDocNo = '' then
            FromSalesAdvLetterHeaderCZZ.Init()
        else
            if FromSalesAdvLetterHeaderCZZ."No." = '' then begin
                FromSalesAdvLetterHeaderCZZ.Init();
                FromSalesAdvLetterHeaderCZZ.Get(FromDocNo);
            end;

        FromSalesAdvLetterHeaderCZZ."No." := '';

        ValidateIncludeHeader();
    end;

    local procedure ValidatePurchAdvLetterNo()
    begin
        if FromDocNo = '' then
            FromPurchAdvLetterHeaderCZZ.Init()
        else
            if FromPurchAdvLetterHeaderCZZ."No." = '' then begin
                FromPurchAdvLetterHeaderCZZ.Init();
                FromPurchAdvLetterHeaderCZZ.Get(FromDocNo);
            end;

        FromPurchAdvLetterHeaderCZZ."No." := '';

        ValidateIncludeHeader();
    end;

    procedure LookupDocNo()
    begin
        if IsSales then
            LookupSalesAdvanceLetterNo()
        else
            LookupPurchAdvanceLetterNo();

        ValidateDocNo();
    end;

    local procedure LookupSalesAdvanceLetterNo()
    begin
        FromSalesAdvLetterHeaderCZZ.FilterGroup := 0;
        FromSalesAdvLetterHeaderCZZ.SetFilter("No.", '<>%1', SalesAdvLetterHeaderCZZ."No.");
        FromSalesAdvLetterHeaderCZZ.FilterGroup := 2;
        FromSalesAdvLetterHeaderCZZ."No." := FromDocNo;
        if Page.RunModal(0, FromSalesAdvLetterHeaderCZZ) = Action::LookupOK then
            FromDocNo := FromSalesAdvLetterHeaderCZZ."No.";
    end;

    local procedure LookupPurchAdvanceLetterNo()
    begin
        FromPurchAdvLetterHeaderCZZ.FilterGroup := 0;
        FromPurchAdvLetterHeaderCZZ.SetFilter("No.", '<>%1', PurchAdvLetterHeaderCZZ."No.");
        FromPurchAdvLetterHeaderCZZ.FilterGroup := 2;
        FromPurchAdvLetterHeaderCZZ."No." := FromDocNo;
        if Page.RunModal(0, FromPurchAdvLetterHeaderCZZ) = Action::LookupOK then
            FromDocNo := FromPurchAdvLetterHeaderCZZ."No.";
    end;

    local procedure ValidateIncludeHeader()
    begin
        RecalculateLines := not IncludeHeader;
    end;

    procedure SetParameters(NewFromDocNo: Code[20]; NewIncludeHeader: Boolean; NewRecalcLines: Boolean)
    begin
        FromDocNo := NewFromDocNo;
        IncludeHeader := NewIncludeHeader;
        RecalculateLines := NewRecalcLines;
    end;
}

