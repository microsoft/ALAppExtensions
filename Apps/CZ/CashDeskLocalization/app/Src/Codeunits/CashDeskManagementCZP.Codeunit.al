// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Account;
#if not CLEAN22
using Microsoft.Finance.ReceivablesPayables;
#endif
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Foundation.Company;
using Microsoft.HumanResources.Employee;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Service.History;
using System.Security.AccessControl;
using System.Security.User;

codeunit 11724 "Cash Desk Management CZP"
{
    var
        CashDeskNotExistErr: Label 'There are no Cash Desk accounts.';
        NotPermToPostErr: Label 'You don''t have permission to post %1.', Comment = '%1 = Cash Document Header TableCaption';
        NotPermToIssueErr: Label 'You don''t have permission to issue %1.', Comment = '%1 = Cash Document Header TableCaption';
        NotPermToCreateErr: Label 'You don''t have permission to create %1.', Comment = '%1 = Cash Document Header TableCaption';
        OneTxt: Label 'one';
        TwoTxt: Label 'two';
        TwoATxt: Label 'two';
        ThreeTxt: Label 'three';
        FourTxt: Label 'four';
        FiveTxt: Label 'five';
        SixTxt: Label 'six';
        SevenTxt: Label 'seven';
        EightTxt: Label 'eight';
        NineTxt: Label 'nine';
        TenTxt: Label 'ten';
        ElevenTxt: Label 'eleven';
        TwelveTxt: Label 'twelve';
        ThirteenTxt: Label 'thirteen';
        FourteenTxt: Label 'fourteen';
        FifteenTxt: Label 'fifteen';
        SixteenTxt: Label 'sixteen';
        SeventeenTxt: Label 'seventeen';
        EighteenTxt: Label 'eighteen';
        NineteenTxt: Label 'nineteen';
        TwentyTxt: Label 'twenty';
        ThirtyTxt: Label 'thirty';
        FortyTxt: Label 'forty';
        FiftyTxt: Label 'fifty';
        SixtyTxt: Label 'sixty';
        SeventyTxt: Label 'seventy';
        EightyTxt: Label 'eighty';
        NinetyTxt: Label 'ninety';
        OneHundredTxt: Label 'hundred';
        TwoHundredTxt: Label 'twohundred';
        ThreeHundredTxt: Label 'threehundred';
        FourHundredTxt: Label 'fourhundred';
        FiveHundredTxt: Label 'fivehundred';
        SixHundredTxt: Label 'sixhundred';
        SevenHundredTxt: Label 'sevenhundred';
        EightHundredTxt: Label 'eighthundred';
        NineHundredTxt: Label 'ninehundred';
        MilionTxt: Label 'million';
        MilionATxt: Label 'million';
        MilionBTxt: Label 'million';
        ThousandTxt: Label 'thousand';
        ThousandATxt: Label 'thousand';
        ThousandBTxt: Label 'thousand';

    procedure CashDocumentSelection(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var CashDeskSelected: Boolean)
    var
        CashDeskCZP: Record "Cash Desk CZP";
        CashDeskFilter: Text;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCashDocumentSelection(CashDocumentHeaderCZP, CashDeskSelected, IsHandled);
        if IsHandled then
            exit;

        CashDeskSelected := true;

        CheckCashDesks();
        CashDeskFilter := GetCashDesksFilter();

        if CashDeskFilter <> '' then begin
            CashDeskCZP.FilterGroup(2);
            CashDeskCZP.SetFilter("No.", CashDeskFilter);
            CashDeskCZP.FilterGroup(0);
        end;
        case CashDeskCZP.Count() of
            0:
                Error(CashDeskNotExistErr);
            1:
                CashDeskCZP.FindFirst();
            else
                CashDeskSelected := Page.RunModal(Page::"Cash Desk List CZP", CashDeskCZP) = Action::LookupOK;
        end;
        if CashDeskSelected then begin
            CashDocumentHeaderCZP.FilterGroup(2);
            CashDocumentHeaderCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
            CashDocumentHeaderCZP.FilterGroup(0);
        end;
    end;

    procedure FromAmountToDescription(FromAmount: Decimal) ToDescription: Text
    var
        ThreeFigure: Decimal;
        DecPlaces: Text[20];
    begin
        if FromAmount = Round(FromAmount, 1) then
            DecPlaces := ''
        else
            DecPlaces := ' + 0' + Format(FromAmount, 0, '<Decimal,3>');

        ThreeFigure := Round(FromAmount / 1000000, 1, '<');
        if ThreeFigure > 1 then begin
            ToDescription := ToDescription + ConvertBy100(ThreeFigure);
            if ThreeFigure > 4 then
                ToDescription := ToDescription + MilionBTxt
            else
                ToDescription := ToDescription + MilionATxt;
        end else
            if ThreeFigure = 1 then
                ToDescription := ToDescription + MilionTxt;
        FromAmount := FromAmount - ThreeFigure * 1000000;

        ThreeFigure := Round(FromAmount / 1000, 1, '<');
        if ThreeFigure > 1 then begin
            ToDescription := ToDescription + ConvertBy100(ThreeFigure);
            if ThreeFigure > 4 then
                ToDescription := ToDescription + ThousandBTxt
            else
                ToDescription := ToDescription + ThousandTxt;
        end else
            if ThreeFigure = 1 then
                ToDescription := ToDescription + ThousandATxt;
        FromAmount := FromAmount - ThreeFigure * 1000;

        ToDescription := ToDescription + ConvertBy100(Round(FromAmount, 1, '<'));

        if StrLen(ToDescription) = StrLen(TwoATxt) then
            if ToDescription = TwoATxt then
                ToDescription := TwoTxt;

        ToDescription := ToDescription + DecPlaces;
        ToDescription := UpperCase(CopyStr(ToDescription, 1, 1)) + CopyStr(ToDescription, 2) + '.';
    end;

    procedure ConvertBy100(Hundred: Integer) ToDescription: Text[250]
    var
        From1To20: array[19] of Text[30];
        From10To90: array[9] of Text[30];
        From100To900: array[9] of Text[30];
        StrNo: Text[3];
        NoPos: Integer;
        i: Integer;
    begin
        From1To20[1] := OneTxt;
        From1To20[2] := TwoATxt;
        From1To20[3] := ThreeTxt;
        From1To20[4] := FourTxt;
        From1To20[5] := FiveTxt;
        From1To20[6] := SixTxt;
        From1To20[7] := SevenTxt;
        From1To20[8] := EightTxt;
        From1To20[9] := NineTxt;
        From1To20[10] := TenTxt;
        From1To20[11] := ElevenTxt;
        From1To20[12] := TwelveTxt;
        From1To20[13] := ThirteenTxt;
        From1To20[14] := FourteenTxt;
        From1To20[15] := FifteenTxt;
        From1To20[16] := SixteenTxt;
        From1To20[17] := SeventeenTxt;
        From1To20[18] := EighteenTxt;
        From1To20[19] := NineteenTxt;

        From10To90[1] := TenTxt;
        From10To90[2] := TwentyTxt;
        From10To90[3] := ThirtyTxt;
        From10To90[4] := FortyTxt;
        From10To90[5] := FiftyTxt;
        From10To90[6] := SixtyTxt;
        From10To90[7] := SeventyTxt;
        From10To90[8] := EightyTxt;
        From10To90[9] := NinetyTxt;

        From100To900[1] := OneHundredTxt;
        From100To900[2] := TwoHundredTxt;
        From100To900[3] := ThreeHundredTxt;
        From100To900[4] := FourHundredTxt;
        From100To900[5] := FiveHundredTxt;
        From100To900[6] := SixHundredTxt;
        From100To900[7] := SevenHundredTxt;
        From100To900[8] := EightHundredTxt;
        From100To900[9] := NineHundredTxt;

        StrNo := CopyStr(SelectStr(1, Format(Hundred)), 1, 3);
        i := StrLen(StrNo);
        if i = 1 then
            StrNo := CopyStr('00' + StrNo, 1, 3);
        if i = 2 then
            StrNo := CopyStr('0' + StrNo, 1, 3);
        for i := 1 to 3 do begin
            Evaluate(NoPos, CopyStr(StrNo, i, 1));
            if (i = 1) and (NoPos <> 0) then
                ToDescription := ToDescription + From100To900[NoPos];
            if (i = 2) and (NoPos <> 0) then
                if NoPos = 1 then begin
                    Evaluate(NoPos, CopyStr(StrNo, i + 1, 1));
                    ToDescription := ToDescription + From1To20[NoPos + 10];
                end else
                    ToDescription := ToDescription + From10To90[NoPos];
            if (i = 3) and (NoPos <> 0) then
                if StrNo[i - 1] <> '1' then
                    ToDescription := ToDescription + From1To20[NoPos];
        end;
    end;

    procedure CreateCashDocumentFromSalesInvoice(SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DummyCashDocumentLineCZP: Record "Cash Document Line CZP";
        CashDeskCZP: Record "Cash Desk CZP";
    begin
        if SalesInvoiceHeader."Cash Document Action CZP" = SalesInvoiceHeader."Cash Document Action CZP"::" " then
            exit;

        SalesInvoiceHeader.CalcFields("Amount Including VAT");
        if SalesInvoiceHeader."Amount Including VAT" = 0 then
            exit;

        CustLedgerEntry.SetCurrentKey("Document No.");
        CustLedgerEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Customer No.", SalesInvoiceHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange(Open, true);
        if CustLedgerEntry.IsEmpty() then
            exit;

        CashDeskCZP.Get(SalesInvoiceHeader."Cash Desk Code CZP");
        CashDeskCZP.TestField("Currency Code", SalesInvoiceHeader."Currency Code");

        CashDocumentHeaderCZP."Cash Desk No." := SalesInvoiceHeader."Cash Desk Code CZP";
        CashDocumentHeaderCZP."Document Type" := CashDocumentHeaderCZP."Document Type"::Receipt;
        CashDocumentHeaderCZP.Insert(true);
        CashDocumentHeaderCZP.CopyFromSalesInvoiceHeader(SalesInvoiceHeader);
        CashDocumentHeaderCZP.Modify(true);

        CreateCashDocumentLine(CashDocumentHeaderCZP,
          DummyCashDocumentLineCZP."Account Type"::Customer.AsInteger(), SalesInvoiceHeader."Bill-to Customer No.",
          DummyCashDocumentLineCZP."Applies-To Doc. Type"::Invoice.AsInteger(), SalesInvoiceHeader."No.");

        RunCashDocumentAction(CashDocumentHeaderCZP, SalesInvoiceHeader."Cash Document Action CZP");
    end;

    procedure CreateCashDocumentFromSalesCrMemo(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DummyCashDocumentLineCZP: Record "Cash Document Line CZP";
        CashDeskCZP: Record "Cash Desk CZP";
    begin
        if SalesCrMemoHeader."Cash Document Action CZP" = SalesCrMemoHeader."Cash Document Action CZP"::" " then
            exit;

        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        if SalesCrMemoHeader."Amount Including VAT" = 0 then
            exit;

        CustLedgerEntry.SetCurrentKey("Document No.");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Customer No.", SalesCrMemoHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange(Open, true);
        if CustLedgerEntry.IsEmpty() then
            exit;

        CashDeskCZP.Get(SalesCrMemoHeader."Cash Desk Code CZP");
        CashDeskCZP.TestField("Currency Code", SalesCrMemoHeader."Currency Code");

        CashDocumentHeaderCZP."Cash Desk No." := SalesCrMemoHeader."Cash Desk Code CZP";
        CashDocumentHeaderCZP."Document Type" := CashDocumentHeaderCZP."Document Type"::Withdrawal;
        CashDocumentHeaderCZP.Insert(true);
        CashDocumentHeaderCZP.CopyFromSalesCrMemoHeader(SalesCrMemoHeader);
        CashDocumentHeaderCZP.Modify(true);

        CreateCashDocumentLine(CashDocumentHeaderCZP,
          DummyCashDocumentLineCZP."Account Type"::Customer.AsInteger(), SalesCrMemoHeader."Bill-to Customer No.",
          DummyCashDocumentLineCZP."Applies-To Doc. Type"::"Credit Memo".AsInteger(), SalesCrMemoHeader."No.");

        RunCashDocumentAction(CashDocumentHeaderCZP, SalesCrMemoHeader."Cash Document Action CZP");
    end;

    procedure CreateCashDocumentFromPurchaseInvoice(PurchInvHeader: Record "Purch. Inv. Header")
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DummyCashDocumentLineCZP: Record "Cash Document Line CZP";
        CashDeskCZP: Record "Cash Desk CZP";
    begin
        if PurchInvHeader."Cash Document Action CZP" = PurchInvHeader."Cash Document Action CZP"::" " then
            exit;

        PurchInvHeader.CalcFields("Amount Including VAT");
        if PurchInvHeader."Amount Including VAT" = 0 then
            exit;

        VendorLedgerEntry.SetCurrentKey("Document No.");
        VendorLedgerEntry.SetRange("Document No.", PurchInvHeader."No.");
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.SetRange("Vendor No.", PurchInvHeader."Buy-from Vendor No.");
        VendorLedgerEntry.SetRange(Open, true);
        if VendorLedgerEntry.IsEmpty() then
            exit;

        CashDeskCZP.Get(PurchInvHeader."Cash Desk Code CZP");
        CashDeskCZP.TestField("Currency Code", PurchInvHeader."Currency Code");

        CashDocumentHeaderCZP."Cash Desk No." := PurchInvHeader."Cash Desk Code CZP";
        CashDocumentHeaderCZP."Document Type" := CashDocumentHeaderCZP."Document Type"::Withdrawal;
        CashDocumentHeaderCZP.Insert(true);
        CashDocumentHeaderCZP.CopyFromPurchInvHeader(PurchInvHeader);
        CashDocumentHeaderCZP.Modify(true);

        CreateCashDocumentLine(CashDocumentHeaderCZP,
          DummyCashDocumentLineCZP."Account Type"::Vendor.AsInteger(), PurchInvHeader."Buy-from Vendor No.",
          DummyCashDocumentLineCZP."Applies-To Doc. Type"::Invoice.AsInteger(), PurchInvHeader."No.");

        RunCashDocumentAction(CashDocumentHeaderCZP, PurchInvHeader."Cash Document Action CZP");
    end;

    procedure CreateCashDocumentFromPurchaseCrMemo(PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DummyCashDocumentLineCZP: Record "Cash Document Line CZP";
        CashDeskCZP: Record "Cash Desk CZP";
    begin
        if PurchCrMemoHdr."Cash Document Action CZP" = PurchCrMemoHdr."Cash Document Action CZP"::" " then
            exit;

        PurchCrMemoHdr.CalcFields("Amount Including VAT");
        if PurchCrMemoHdr."Amount Including VAT" = 0 then
            exit;

        VendorLedgerEntry.SetCurrentKey("Document No.");
        VendorLedgerEntry.SetRange("Document No.", PurchCrMemoHdr."No.");
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::"Credit Memo");
        VendorLedgerEntry.SetRange("Vendor No.", PurchCrMemoHdr."Buy-from Vendor No.");
        VendorLedgerEntry.SetRange(Open, true);
        if VendorLedgerEntry.IsEmpty() then
            exit;

        CashDeskCZP.Get(PurchCrMemoHdr."Cash Desk Code CZP");
        CashDeskCZP.TestField("Currency Code", PurchCrMemoHdr."Currency Code");

        CashDocumentHeaderCZP."Cash Desk No." := PurchCrMemoHdr."Cash Desk Code CZP";
        CashDocumentHeaderCZP."Document Type" := CashDocumentHeaderCZP."Document Type"::Receipt;
        CashDocumentHeaderCZP.Insert(true);
        CashDocumentHeaderCZP.CopyFromPurchCrMemoHeader(PurchCrMemoHdr);
        CashDocumentHeaderCZP.Modify(true);

        CreateCashDocumentLine(CashDocumentHeaderCZP,
          DummyCashDocumentLineCZP."Account Type"::Vendor.AsInteger(), PurchCrMemoHdr."Buy-from Vendor No.",
          DummyCashDocumentLineCZP."Applies-To Doc. Type"::"Credit Memo".AsInteger(), PurchCrMemoHdr."No.");

        RunCashDocumentAction(CashDocumentHeaderCZP, PurchCrMemoHdr."Cash Document Action CZP");
    end;

    procedure CreateCashDocumentFromServiceInvoice(ServiceInvoiceHeader: Record "Service Invoice Header")
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DummyCashDocumentLineCZP: Record "Cash Document Line CZP";
        CashDeskCZP: Record "Cash Desk CZP";
    begin
        if ServiceInvoiceHeader."Cash Document Action CZP" = ServiceInvoiceHeader."Cash Document Action CZP"::" " then
            exit;

        ServiceInvoiceHeader.CalcFields("Amount Including VAT");
        if ServiceInvoiceHeader."Amount Including VAT" = 0 then
            exit;

        CustLedgerEntry.SetCurrentKey("Document No.");
        CustLedgerEntry.SetRange("Document No.", ServiceInvoiceHeader."No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Customer No.", ServiceInvoiceHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange(Open, true);
        if CustLedgerEntry.IsEmpty() then
            exit;

        CashDeskCZP.Get(ServiceInvoiceHeader."Cash Desk Code CZP");
        CashDeskCZP.TestField("Currency Code", ServiceInvoiceHeader."Currency Code");

        CashDocumentHeaderCZP."Cash Desk No." := ServiceInvoiceHeader."Cash Desk Code CZP";
        CashDocumentHeaderCZP."Document Type" := CashDocumentHeaderCZP."Document Type"::Receipt;
        CashDocumentHeaderCZP.Insert(true);
        CashDocumentHeaderCZP.CopyFromServiceInvoiceHeader(ServiceInvoiceHeader);
        CashDocumentHeaderCZP.Modify(true);

        CreateCashDocumentLine(CashDocumentHeaderCZP,
          DummyCashDocumentLineCZP."Account Type"::Customer.AsInteger(), ServiceInvoiceHeader."Bill-to Customer No.",
          DummyCashDocumentLineCZP."Applies-To Doc. Type"::Invoice.AsInteger(), ServiceInvoiceHeader."No.");

        RunCashDocumentAction(CashDocumentHeaderCZP, ServiceInvoiceHeader."Cash Document Action CZP");
    end;

    procedure CreateCashDocumentFromServiceCrMemo(ServiceCrMemoHeader: Record "Service Cr.Memo Header")
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DummyCashDocumentLineCZP: Record "Cash Document Line CZP";
        CashDeskCZP: Record "Cash Desk CZP";
    begin
        if ServiceCrMemoHeader."Cash Document Action CZP" = ServiceCrMemoHeader."Cash Document Action CZP"::" " then
            exit;

        ServiceCrMemoHeader.CalcFields("Amount Including VAT");
        if ServiceCrMemoHeader."Amount Including VAT" = 0 then
            exit;

        CustLedgerEntry.SetCurrentKey("Document No.");
        CustLedgerEntry.SetRange("Document No.", ServiceCrMemoHeader."No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Customer No.", ServiceCrMemoHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange(Open, true);
        if CustLedgerEntry.IsEmpty() then
            exit;

        CashDeskCZP.Get(ServiceCrMemoHeader."Cash Desk Code CZP");
        CashDeskCZP.TestField("Currency Code", ServiceCrMemoHeader."Currency Code");

        CashDocumentHeaderCZP."Cash Desk No." := ServiceCrMemoHeader."Cash Desk Code CZP";
        CashDocumentHeaderCZP."Document Type" := CashDocumentHeaderCZP."Document Type"::Withdrawal;
        CashDocumentHeaderCZP.Insert(true);
        CashDocumentHeaderCZP.CopyFromServiceCrMemoHeader(ServiceCrMemoHeader);
        CashDocumentHeaderCZP.Modify(true);

        CreateCashDocumentLine(CashDocumentHeaderCZP,
          DummyCashDocumentLineCZP."Account Type"::Customer.AsInteger(), ServiceCrMemoHeader."Bill-to Customer No.",
          DummyCashDocumentLineCZP."Applies-To Doc. Type"::"Credit Memo".AsInteger(), ServiceCrMemoHeader."No.");

        RunCashDocumentAction(CashDocumentHeaderCZP, ServiceCrMemoHeader."Cash Document Action CZP");
    end;

    local procedure CreateCashDocumentLine(CashDocumentHeaderCZP: Record "Cash Document Header CZP"; AccountType: Option; AccountNo: Code[20]; AppliesToDocType: Option; AppliesToDocNo: Code[20])
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        CashDocumentLineCZP."Cash Desk No." := CashDocumentHeaderCZP."Cash Desk No.";
        CashDocumentLineCZP."Cash Document No." := CashDocumentHeaderCZP."No.";
        CashDocumentLineCZP."Line No." := 10000;
        CashDocumentLineCZP.Insert(true);

        CashDocumentLineCZP.SetHideValidationDialog(true);
        CashDocumentLineCZP.Validate(CashDocumentLineCZP."Account Type", AccountType);
        CashDocumentLineCZP.Validate(CashDocumentLineCZP."Account No.", AccountNo);
        CashDocumentLineCZP.Validate(CashDocumentLineCZP."Applies-To Doc. Type", AppliesToDocType);
        CashDocumentLineCZP.Validate(CashDocumentLineCZP."Applies-To Doc. No.", AppliesToDocNo);
        CashDocumentLineCZP."Shortcut Dimension 1 Code" := CashDocumentHeaderCZP."Shortcut Dimension 1 Code";
        CashDocumentLineCZP."Shortcut Dimension 2 Code" := CashDocumentHeaderCZP."Shortcut Dimension 2 Code";
        CashDocumentLineCZP."Dimension Set ID" := CashDocumentHeaderCZP."Dimension Set ID";
        CashDocumentLineCZP.Modify(true);
    end;

    local procedure RunCashDocumentAction(CashDocumentHeaderCZP: Record "Cash Document Header CZP"; CashDocumentAction: Enum "Cash Document Action CZP")
    var
        CashDocumentPostPrintCZP: Codeunit "Cash Document-Post + Print CZP";
    begin
        CashDocumentHeaderCZP.SetRecFilter();
        case CashDocumentAction of
            CashDocumentAction::Release:
                Codeunit.Run(Codeunit::"Cash Document-Release CZP", CashDocumentHeaderCZP);
            CashDocumentAction::Post:
                Codeunit.Run(Codeunit::"Cash Document-Post CZP", CashDocumentHeaderCZP);
            CashDocumentAction::"Release and Print":
                Codeunit.Run(Codeunit::"Cash Document-ReleasePrint CZP", CashDocumentHeaderCZP);
            CashDocumentAction::"Post and Print":
                CashDocumentPostPrintCZP.PostWithoutConfirmation(CashDocumentHeaderCZP);
        end;
    end;

    [TryFunction]
    procedure CheckUserRights(CashDeskNo: Code[20]; ActionType: Enum "Cash Document Action CZP")
    begin
        CheckUserRights(CashDeskNo, ActionType, true);
    end;

    [TryFunction]
    procedure CheckUserRights(CashDeskNo: Code[20]; ActionType: Enum "Cash Document Action CZP"; EETTransaction: Boolean)
    var
        CashDeskUserCZP: Record "Cash Desk User CZP";
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDeskCZP: Record "Cash Desk CZP";
        IsHandled: boolean;
    begin
        OnBeforeCheckUserRights(CashDeskNo, ActionType, IsHandled);
        if IsHandled then
            exit;

        if not IsCheckUserRightsEnabled(CashDeskNo, ActionType) then
            exit;

        CashDeskCZP.Get(CashDeskNo);
        CashDeskUserCZP.SetRange("Cash Desk No.", CashDeskNo);
        if CashDeskUserCZP.IsEmpty() then
            exit;
        CashDeskUserCZP.SetRange("User ID", UserId);
        if CashDeskUserCZP.IsEmpty() then
            CashDeskUserCZP.SetRange("User ID", '');
        case ActionType of
            ActionType::Create:
                CashDeskUserCZP.SetRange(Create, true);
            ActionType::Release, ActionType::"Release and Print":
                begin
                    CashDeskUserCZP.SetRange(Issue, true);
                    if (CashDeskCZP."Responsibility ID (Release)" <> '') and (CashDeskCZP."Responsibility ID (Release)" <> UserId) then
                        Error(NotPermToIssueErr, CashDocumentHeaderCZP.TableCaption);
                end;
            ActionType::Post, ActionType::"Post and Print":
                begin
                    CashDeskUserCZP.SetRange(Post, true);
                    if EETTransaction then
                        if CashDeskUserCZP.IsEmpty() then begin
                            CashDeskUserCZP.SetRange(Post);
                            CashDeskUserCZP.SetRange("Post EET Only", true);
                        end;
                    if (CashDeskCZP."Responsibility ID (Post)" <> '') and (CashDeskCZP."Responsibility ID (Post)" <> UserId) then
                        Error(NotPermToPostErr, CashDocumentHeaderCZP.TableCaption);
                end;
        end;
        if CashDeskUserCZP.IsEmpty() then
            case ActionType of
                ActionType::Create:
                    Error(NotPermToCreateErr, CashDocumentHeaderCZP.TableCaption);
                ActionType::Release, ActionType::"Release and Print":
                    Error(NotPermToIssueErr, CashDocumentHeaderCZP.TableCaption);
                ActionType::Post, ActionType::"Post and Print":
                    Error(NotPermToPostErr, CashDocumentHeaderCZP.TableCaption);
            end;
    end;

    local procedure IsCheckUserRightsEnabled(CashDeskNo: Code[20]; ActionType: Enum "Cash Document Action CZP") IsEnabled: Boolean
    begin
        IsEnabled := (CashDeskNo <> '') and (ActionType <> ActionType::" ");
        OnAfterIsCheckUserRightsEnabled(CashDeskNo, ActionType, IsEnabled);
    end;

    procedure CheckCashDesk(CashDeskNo: Code[20])
    begin
        if CashDeskNo = '' then
            exit;
        CheckCurrentUserCashDesks(CashDeskNo);
    end;

    procedure CheckCashDesks()
    begin
        CheckCurrentUserCashDesks('');
    end;

    procedure CheckCurrentUserCashDesks(CashDeskNo: Code[20])
    var
        User: Record User;
        TempCashDeskCZP: Record "Cash Desk CZP" temporary;
        UserCode: Code[50];
        CashFilter: Code[10];
        NotCashDeskUserErr: Label 'User %1 is not Cash Desk User.', Comment = '%1 = USERID';
        NotCashDeskUserOfCashDeskErr: Label 'User %1 is not Cash Desk User of %2.', Comment = '%1 = USERID, %2 = Cash Desk No.';
        NotCashDeskUserInRespCenterErr: Label 'User %1 is not Cash Desk User in set up Responsibility Center %2.', Comment = '%1 = USERID; %2 = Responsibility Center';
        NotCashDeskUserOfCashDeskInRespCenterErr: Label 'User %1 is not Cash Desk User of %2 is set up Responsibility Center %3.', Comment = '%1 = USERID; %2 = Cash Desk No.; %3 = Responsibility Center';
    begin
        if User.IsEmpty() then
            exit;

        UserCode := CopyStr(UserId(), 1, 50);
        GetCashDesksForCashDeskUser(UserCode, TempCashDeskCZP);

        if CashDeskNo <> '' then
            TempCashDeskCZP.SetRange("No.", CashDeskNo);
        if TempCashDeskCZP.IsEmpty() then begin
            if CashDeskNo <> '' then
                Error(NotCashDeskUserOfCashDeskErr, UserCode, CashDeskNo);
            Error(NotCashDeskUserErr, UserCode);
        end;

        CashFilter := GetUserCashResponsibilityFilter(UserCode);
        if CashFilter <> '' then
            TempCashDeskCZP.SetRange("Responsibility Center", CashFilter);
        if TempCashDeskCZP.IsEmpty() then begin
            if CashDeskNo <> '' then
                Error(NotCashDeskUserOfCashDeskInRespCenterErr, UserCode, CashDeskNo, CashFilter);
            Error(NotCashDeskUserInRespCenterErr, UserCode, CashFilter);
        end;
    end;

    procedure GetCashDesksFilter(): Text
    var
        TempCashDeskCZP: Record "Cash Desk CZP" temporary;
    begin
        GetCashDesks(CopyStr(UserId(), 1, 50), TempCashDeskCZP);
        exit(GetCashDesksFilterFromBuffer(TempCashDeskCZP));
    end;

    local procedure GetCashDesks(UserCode: Code[50]; var TempCashDeskCZP: Record "Cash Desk CZP" temporary)
    var
        CashResponsibilityFilter: Code[10];
    begin
        GetCashDesksForCashDeskUser(UserCode, TempCashDeskCZP);
        CashResponsibilityFilter := GetUserCashResponsibilityFilter(UserCode);
        if CashResponsibilityFilter <> '' then
            TempCashDeskCZP.SetRange("Responsibility Center", CashResponsibilityFilter);
    end;

    procedure GetUserCashResponsibilityFilter(UserCode: Code[50]): Code[10]
    var
        CompanyInformation: Record "Company Information";
        UserSetup: Record "User Setup";
        CashUserRespCenter: Code[10];
        HasGotCashUserSetup: Boolean;
    begin
        if not HasGotCashUserSetup then begin
            CompanyInformation.Get();
            CashUserRespCenter := CompanyInformation."Responsibility Center";
            if UserSetup.Get(UserCode) and (UserCode <> '') then
                if UserSetup."Cash Resp. Ctr. Filter CZP" <> '' then
                    CashUserRespCenter := UserSetup."Cash Resp. Ctr. Filter CZP";
            HasGotCashUserSetup := true;
        end;
        exit(CashUserRespCenter);
    end;

    local procedure GetCashDesksForCashDeskUser(UserCode: Code[50]; var TempCashDeskCZP: Record "Cash Desk CZP" temporary)
    var
        CashDeskCZP: Record "Cash Desk CZP";
        CashDeskUserCZP: Record "Cash Desk User CZP";
        CashDeskAllowedToUser: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetCashDesksForCashDeskUser(UserCode, TempCashDeskCZP, IsHandled);
        if IsHandled then
            exit;

        TempCashDeskCZP.Reset();
        TempCashDeskCZP.DeleteAll();

        if CashDeskCZP.FindSet() then
            repeat
                CashDeskUserCZP.Reset();
                CashDeskAllowedToUser := CashDeskUserCZP.IsEmpty();
                CashDeskUserCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
                CashDeskUserCZP.SetRange("User ID", UserCode);
                if not CashDeskAllowedToUser then
                    CashDeskAllowedToUser := not CashDeskUserCZP.IsEmpty();
                if not CashDeskAllowedToUser then begin
                    CashDeskUserCZP.SetRange("User ID");
                    CashDeskAllowedToUser := CashDeskUserCZP.IsEmpty();
                end;
                if CashDeskAllowedToUser then begin
                    TempCashDeskCZP.Init();
                    TempCashDeskCZP := CashDeskCZP;
                    TempCashDeskCZP.Insert();
                end;
            until CashDeskCZP.Next() = 0;
    end;

    local procedure GetCashDesksFilterFromBuffer(var TempCashDeskCZP: Record "Cash Desk CZP" temporary) CashDesksFilter: Text
    begin
        if TempCashDeskCZP.FindSet() then
            repeat
                CashDesksFilter += '|' + TempCashDeskCZP."No.";
            until TempCashDeskCZP.Next() = 0;
        CashDesksFilter := CopyStr(CashDesksFilter, 2);
    end;

    procedure IsEntityBlocked(AccountType: Enum "Cash Document Account Type CZP"; AccountNo: Code[20]): Boolean
    var
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        BankAccount: Record "Bank Account";
        FixedAsset: Record "Fixed Asset";
        Employee: Record Employee;
    begin
        if AccountNo = '' then
            exit(true);
        case AccountType of
            AccountType::"G/L Account":
                if GLAccount.Get(AccountNo) then
                    exit(not GLAccount."Direct Posting" or GLAccount.Blocked);
            AccountType::Customer:
                if Customer.Get(AccountNo) then
                    exit(Customer.Blocked = Customer.Blocked::All);
            AccountType::Vendor:
                if Vendor.Get(AccountNo) then
                    exit(Vendor.Blocked in [Vendor.Blocked::All, Vendor.Blocked::Payment]);
            AccountType::"Bank Account":
                if BankAccount.Get(AccountNo) then
                    exit(BankAccount.Blocked);
            AccountType::"Fixed Asset":
                if FixedAsset.Get(AccountNo) then
                    exit(FixedAsset.Blocked);
            AccountType::Employee:
                if Employee.Get(AccountNo) then
                    exit(Employee.Status = Employee.Status::Terminated);
        end;
        exit(false);
    end;
#if not CLEAN22
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Group Management CZL", 'OnCheckPostingGroupChange', '', false, false)]
#pragma warning restore AL0432
    local procedure OnCheckPostingGroupChange(NewPostingGroup: Code[20]; OldPostingGroup: Code[20]; SourceRecordRef: RecordRef; var CheckedPostingGroup: Option "None",Customer,CustomerInService,Vendor; var CustomerVendorNo: Code[20])
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        if not (SourceRecordRef.Number = Database::"Cash Document Line CZP") then
            exit;

        SourceRecordRef.SetTable(CashDocumentLineCZP);
        case CashDocumentLineCZP."Account Type" of
            CashDocumentLineCZP."Account Type"::Customer:
                begin
                    CheckedPostingGroup := CheckedPostingGroup::Customer;
                    CustomerVendorNo := CashDocumentLineCZP."Account No.";
                end;
            CashDocumentLineCZP."Account Type"::Vendor:
                begin
                    CheckedPostingGroup := CheckedPostingGroup::Vendor;
                    CustomerVendorNo := CashDocumentLineCZP."Account No.";
                end;
        end;
    end;
#endif

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckUserRights(CashDeskNo: Code[20]; ActionType: Enum "Cash Document Action CZP"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsCheckUserRightsEnabled(CashDeskNo: Code[20]; ActionType: Enum "Cash Document Action CZP"; var IsEnabled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCashDocumentSelection(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var CashDeskSelected: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetCashDesksForCashDeskUser(UserCode: Code[50]; var TempCashDeskCZP: Record "Cash Desk CZP" temporary; var IsHandled: Boolean)
    begin
    end;
}
