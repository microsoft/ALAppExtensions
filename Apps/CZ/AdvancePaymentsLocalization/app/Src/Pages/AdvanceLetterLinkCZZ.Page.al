// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

page 31191 "Advance Letter Link CZZ"
{
    Caption = 'Advance Letter Link';
    PageType = List;
    UsageCategory = None;
    SourceTable = "Advance Letter Link Buffer CZZ";
    PopulateAllFields = true;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Advance Letter No."; Rec."Advance Letter No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies advance letter no.';

                    trigger OnValidate()
                    var
                        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
                    begin
                        if Rec."Advance Letter No." = '' then begin
                            Rec.Amount := 0;
                            exit;
                        end;

                        case AdvanceLetterTypeCZZ of
                            AdvanceLetterTypeCZZ::Sales:
                                begin
                                    SalesAdvLetterHeaderCZZ.Get(Rec."Advance Letter No.");
                                    SalesAdvLetterHeaderCZZ.TestField("Bill-to Customer No.", CustLedgerEntry."Customer No.");
                                    SalesAdvLetterHeaderCZZ.TestField(Status, SalesAdvLetterHeaderCZZ.Status::"To Pay");
                                    SalesAdvLetterHeaderCZZ.TestField("Currency Code", CustLedgerEntry."Currency Code");
                                    SalesAdvLetterHeaderCZZ.CalcFields("To Pay");
                                    Rec.Amount := GetPossibleAmount(SalesAdvLetterHeaderCZZ."To Pay");
                                end;
                            AdvanceLetterTypeCZZ::Purchase:
                                begin
                                    PurchAdvLetterHeaderCZZ.Get(Rec."Advance Letter No.");
                                    PurchAdvLetterHeaderCZZ.TestField("Pay-to Vendor No.", VendorLedgerEntry."Vendor No.");
                                    PurchAdvLetterHeaderCZZ.TestField(Status, PurchAdvLetterHeaderCZZ.Status::"To Pay");
                                    PurchAdvLetterHeaderCZZ.TestField("Currency Code", VendorLedgerEntry."Currency Code");
                                    PurchAdvLetterHeaderCZZ.CalcFields("To Pay");
                                    Rec.Amount := GetPossibleAmount(PurchAdvLetterHeaderCZZ."To Pay");
                                end;
                        end;
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
                    begin
                        case AdvanceLetterTypeCZZ of
                            AdvanceLetterTypeCZZ::Sales:
                                begin
                                    SalesAdvLetterHeaderCZZ.FilterGroup(2);
                                    SalesAdvLetterHeaderCZZ.SetRange("Bill-to Customer No.", CustLedgerEntry."Customer No.");
                                    SalesAdvLetterHeaderCZZ.SetRange(Status, SalesAdvLetterHeaderCZZ.Status::"To Pay");
                                    SalesAdvLetterHeaderCZZ.SetRange("Currency Code", CustLedgerEntry."Currency Code");
                                    SalesAdvLetterHeaderCZZ.FilterGroup(0);
                                    if Page.RunModal(0, SalesAdvLetterHeaderCZZ) = Action::LookupOK then begin
                                        Rec.Validate("Advance Letter No.", SalesAdvLetterHeaderCZZ."No.");
                                        SalesAdvLetterHeaderCZZ.TestField("Bill-to Customer No.", CustLedgerEntry."Customer No.");
                                        SalesAdvLetterHeaderCZZ.CalcFields("To Pay");
                                        Rec.Amount := GetPossibleAmount(SalesAdvLetterHeaderCZZ."To Pay");
                                    end;
                                end;
                            AdvanceLetterTypeCZZ::Purchase:
                                begin
                                    PurchAdvLetterHeaderCZZ.FilterGroup(2);
                                    PurchAdvLetterHeaderCZZ.SetRange("Pay-to Vendor No.", VendorLedgerEntry."Vendor No.");
                                    PurchAdvLetterHeaderCZZ.SetRange(Status, PurchAdvLetterHeaderCZZ.Status::"To Pay");
                                    PurchAdvLetterHeaderCZZ.SetRange("Currency Code", VendorLedgerEntry."Currency Code");
                                    PurchAdvLetterHeaderCZZ.FilterGroup(0);
                                    if Page.RunModal(0, PurchAdvLetterHeaderCZZ) = Action::LookupOK then begin
                                        Rec.Validate("Advance Letter No.", PurchAdvLetterHeaderCZZ."No.");
                                        PurchAdvLetterHeaderCZZ.TestField("Pay-to Vendor No.", VendorLedgerEntry."Vendor No.");
                                        PurchAdvLetterHeaderCZZ.CalcFields("To Pay");
                                        Rec.Amount := GetPossibleAmount(PurchAdvLetterHeaderCZZ."To Pay");
                                    end;
                                end;
                        end;
                    end;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies amount.';

                    trigger OnValidate()
                    var
                        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
                        MaxAmount: Decimal;
                        AmountExceededErr: Label 'Amount was exceeded. You can use maximum %1.', Comment = '%1 = Maximum amount';
                    begin
                        if Rec.Amount <> 0 then begin
                            case AdvanceLetterTypeCZZ of
                                AdvanceLetterTypeCZZ::Sales:
                                    begin
                                        SalesAdvLetterHeaderCZZ.Get(Rec."Advance Letter No.");
                                        SalesAdvLetterHeaderCZZ.CalcFields("To Pay");
                                        MaxAmount := GetPossibleAmount(SalesAdvLetterHeaderCZZ."To Pay");
                                    end;
                                AdvanceLetterTypeCZZ::Purchase:
                                    begin
                                        PurchAdvLetterHeaderCZZ.Get(Rec."Advance Letter No.");
                                        PurchAdvLetterHeaderCZZ.CalcFields("To Pay");
                                        MaxAmount := GetPossibleAmount(PurchAdvLetterHeaderCZZ."To Pay");
                                    end;
                            end;

                            if MaxAmount < Rec.Amount then
                                Error(AmountExceededErr, MaxAmount);
                        end;
                    end;
                }
            }
        }
    }

    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        AdvanceLetterTypeCZZ: Enum "Advance Letter Type CZZ";

    procedure SetCVEntry(CVRecordID: RecordId)
    var
        RecordRef: RecordRef;
        NotSupportedErr: Label 'This type is not supported.';
    begin
        RecordRef.Get(CVRecordID);
        case RecordRef.Number of
            Database::"Cust. Ledger Entry":
                begin
                    RecordRef.SetTable(CustLedgerEntry);
                    CustLedgerEntry.CalcFields("Remaining Amount");
                    Rec.FilterGroup(2);
                    Rec.SetRange("Advance Letter Type", Rec."Advance Letter Type"::Sales);
                    Rec.SetRange("CV Ledger Entry No.", CustLedgerEntry."Entry No.");
                    Rec.FilterGroup(0);
                    AdvanceLetterTypeCZZ := AdvanceLetterTypeCZZ::Sales;
                end;
            Database::"Vendor Ledger Entry":
                begin
                    RecordRef.SetTable(VendorLedgerEntry);
                    VendorLedgerEntry.CalcFields("Remaining Amount");
                    Rec.FilterGroup(2);
                    Rec.SetRange("Advance Letter Type", Rec."Advance Letter Type"::Purchase);
                    Rec.SetRange("CV Ledger Entry No.", VendorLedgerEntry."Entry No.");
                    Rec.FilterGroup(0);
                    AdvanceLetterTypeCZZ := AdvanceLetterTypeCZZ::Purchase;
                end;
            else
                Error(NotSupportedErr);
        end;
    end;

    procedure GetLetterLink(var NewAdvanceLetterLinkBufferCZZ: Record "Advance Letter Link Buffer CZZ")
    begin
        if Rec.FindSet() then
            repeat
                NewAdvanceLetterLinkBufferCZZ := Rec;
                NewAdvanceLetterLinkBufferCZZ.Insert();
            until Rec.Next() = 0;
    end;

    local procedure GetPossibleAmount(LetterAmountToPay: Decimal) PossibleAmount: Decimal
    begin
        PossibleAmount := LetterAmountToPay;

        case AdvanceLetterTypeCZZ of
            AdvanceLetterTypeCZZ::Sales:
                if -CustLedgerEntry."Remaining Amount" < PossibleAmount then
                    PossibleAmount := -CustLedgerEntry."Remaining Amount";
            AdvanceLetterTypeCZZ::Purchase:
                if VendorLedgerEntry."Remaining Amount" < PossibleAmount then
                    PossibleAmount := VendorLedgerEntry."Remaining Amount";
        end;
    end;
}
