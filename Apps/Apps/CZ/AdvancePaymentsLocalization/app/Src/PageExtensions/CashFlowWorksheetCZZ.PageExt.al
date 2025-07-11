// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.CashFlow.Setup;
using Microsoft.CashFlow.Worksheet;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Projects.Project.Job;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Document;
using Microsoft.Sales.Receivables;
using Microsoft.Service.Document;

pageextension 31194 "Cash Flow Worksheet CZZ" extends "Cash Flow Worksheet"
{
    layout
    {
        modify("Source No.")
        {
            trigger OnLookup(var Text: Text): Boolean
            var
                CashFlowManualExpense: Record "Cash Flow Manual Expense";
                CashFlowManualRevenue: Record "Cash Flow Manual Revenue";
                CustLedgerEntry: Record "Cust. Ledger Entry";
                FixedAsset: Record "Fixed Asset";
                GLAccount: Record "G/L Account";
                Job: Record Job;
                PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
                PurchaseHeader: Record "Purchase Header";
                SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                SalesHeader: Record "Sales Header";
                ServiceHeader: Record "Service Header";
                VendorLedgerEntry: Record "Vendor Ledger Entry";
                PageAction: Action;
            begin
                case Rec."Source Type" of
                    Rec."Source Type"::"Sales Advance Letters CZZ":
                        begin
                            SalesAdvLetterHeaderCZZ."No." := CopyStr(Text, 1, MaxStrLen(SalesAdvLetterHeaderCZZ."No."));
                            PageAction := Page.RunModal(0, SalesAdvLetterHeaderCZZ);
                            Text := SalesAdvLetterHeaderCZZ."No.";
                        end;
                    Rec."Source Type"::"Purchase Advance Letters CZZ":
                        begin
                            PurchAdvLetterHeaderCZZ."No." := CopyStr(Text, 1, MaxStrLen(PurchAdvLetterHeaderCZZ."No."));
                            PageAction := Page.RunModal(0, PurchAdvLetterHeaderCZZ);
                            Text := PurchAdvLetterHeaderCZZ."No.";
                        end;
                    Rec."Source Type"::"Liquid Funds",
                    Rec."Source Type"::"G/L Budget":
                        begin
                            GLAccount."No." := CopyStr(Text, 1, MaxStrLen(GLAccount."No."));
                            PageAction := Page.RunModal(0, GLAccount);
                            Text := GLAccount."No.";
                        end;
                    Rec."Source Type"::Receivables:
                        begin
                            PageAction := Page.RunModal(0, CustLedgerEntry);
                            Text := CustLedgerEntry."Document No.";
                        end;
                    Rec."Source Type"::Payables:
                        begin
                            PageAction := Page.RunModal(0, VendorLedgerEntry);
                            Text := VendorLedgerEntry."Document No.";
                        end;
                    Rec."Source Type"::"Fixed Assets Budget",
                    Rec."Source Type"::"Fixed Assets Disposal":
                        begin
                            FixedAsset."No." := CopyStr(Text, 1, MaxStrLen(FixedAsset."No."));
                            PageAction := Page.RunModal(0, FixedAsset);
                            Text := FixedAsset."No.";
                        end;
                    Rec."Source Type"::"Sales Orders":
                        begin
                            SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
                            SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                            SalesHeader."No." := CopyStr(Text, 1, MaxStrLen(SalesHeader."No."));
                            PageAction := Page.RunModal(0, SalesHeader);
                            Text := SalesHeader."No.";
                        end;
                    Rec."Source Type"::"Purchase Orders":
                        begin
                            PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
                            PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
                            PurchaseHeader."No." := CopyStr(Text, 1, MaxStrLen(PurchaseHeader."No."));
                            PageAction := Page.RunModal(0, PurchaseHeader);
                            Text := PurchaseHeader."No.";
                        end;
                    Rec."Source Type"::"Service Orders":
                        begin
                            ServiceHeader.SetRange("Document Type", ServiceHeader."Document Type"::Order);
                            ServiceHeader."Document Type" := ServiceHeader."Document Type"::Order;
                            ServiceHeader."No." := CopyStr(Text, 1, MaxStrLen(ServiceHeader."No."));
                            PageAction := Page.RunModal(0, ServiceHeader);
                            Text := ServiceHeader."No.";
                        end;
                    Rec."Source Type"::"Cash Flow Manual Expense":
                        begin
                            CashFlowManualExpense.Code := CopyStr(Text, 1, MaxStrLen(CashFlowManualExpense.Code));
                            PageAction := Page.RunModal(0, CashFlowManualExpense);
                            Text := CashFlowManualExpense.Code;
                        end;
                    Rec."Source Type"::"Cash Flow Manual Revenue":
                        begin
                            CashFlowManualRevenue.Code := CopyStr(Text, 1, MaxStrLen(CashFlowManualRevenue.Code));
                            PageAction := Page.RunModal(0, CashFlowManualRevenue);
                            Text := CashFlowManualRevenue.Code;
                        end;
                    Rec."Source Type"::Job:
                        begin
                            Job."No." := CopyStr(Text, 1, MaxStrLen(Job."No."));
                            PageAction := Page.RunModal(0, Job);
                            Text := Job."No.";
                        end;
                end;
                exit(PageAction = Action::LookupOK);
            end;
        }
    }
}
