// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.CRM.BusinessRelation;
using Microsoft.CRM.Contact;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;

page 31276 "Compensation Proposal CZC"
{
    Caption = 'Compensation Proposal';
    InsertAllowed = false;
    PageType = ListPlus;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(Control1)
            {
                ShowCaption = false;
                field(SourceType; CompensationTypeCZC)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Source Type';
                    ToolTip = 'Specifies the source type.';

                    trigger OnValidate()
                    begin
                        SourceTypeOnAfterValidate();
                    end;
                }
                field(SourceNo; SourceNo)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Source No.';
                    ToolTip = 'Specifies the source number.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Customer: Record Customer;
                        Vendor: Record Vendor;
                        Contact: Record Contact;
                    begin
                        case CompensationTypeCZC of
                            CompensationTypeCZC::Customer:
                                if Page.RunModal(0, Customer) = Action::LookupOK then begin
                                    SourceNo := Customer."No.";
                                    ApplyFilters();
                                end;
                            CompensationTypeCZC::Vendor:
                                if Page.RunModal(0, Vendor) = Action::LookupOK then begin
                                    SourceNo := Vendor."No.";
                                    ApplyFilters();
                                end;
                            CompensationTypeCZC::Contact:
                                begin
                                    Contact.SetRange(Type, Contact.Type::Company);
                                    if Page.RunModal(0, Contact) = Action::LookupOK then begin
                                        SourceNo := Contact."No.";
                                        ApplyFilters();
                                    end;
                                end;
                        end;
                        GetSourceName();
                    end;

                    trigger OnValidate()
                    begin
                        SourceNoOnAfterValidate();
                    end;
                }
                field(SourceName; SourceName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Source Name';
                    Editable = false;
                    ToolTip = 'Specifies source name.';
                }
                field(PostingDate; PostingDate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posting Date';
                    Editable = false;
                    ToolTip = 'Specifies compensation posting date.';
                }
            }
            group(Entries)
            {
                ShowCaption = false;
                part(CustLedgEntries; "Compens. Cust. LE Subform CZC")
                {
                    ApplicationArea = Basic, Suite;
                }
                part(VendLedgEntries; "Compens. Vendor LE Subform CZC")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
            group(Balance)
            {
                ShowCaption = false;
                field(TotalBalance; TotalBalance)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total Balance (LCY)';
                    Editable = false;
                    ToolTip = 'Specifies total balance (LCY) of compensation proposal.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RecalculateBalance)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Recalculate Balance';
                Image = Recalculate;
                ShortCutKey = 'Shift+F11';
                ToolTip = 'Recalculates compensation balance.';

                trigger OnAction()
                begin
                    TotalBalance := CurrPage.CustLedgEntries.Page.GetBalance() + CurrPage.VendLedgEntries.Page.GetBalance();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        if AppFilters then begin
            ApplyFilters();
            AppFilters := false;
        end;
    end;

    trigger OnInit()
    begin
        CurrPage.LookupMode := true;
    end;

    trigger OnOpenPage()
    begin
        if SourceNo <> '' then begin
            AppFilters := true;
            GetSourceName();
        end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::LookupOK then
            LookupOKOnPush();
    end;

    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        CompensationsSetupCZC: Record "Compensations Setup CZC";
        CompensationTypeCZC: Enum "Compensation Company Type CZC";
        SourceNo: Code[20];
        PostingDate: Date;
        TotalBalance: Decimal;
        SourceName: Text[100];
        AppFilters: Boolean;

    procedure SetCompensationHeader(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
        CompensationTypeCZC := CompensationHeaderCZC."Company Type";
        SourceNo := CompensationHeaderCZC."Company No.";
        PostingDate := CompensationHeaderCZC."Posting Date";
    end;

    procedure GetLedgEntries(var GetCustLedgerEntry: Record "Cust. Ledger Entry"; var GetVendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
        GetCustLedgerEntry.Copy(CustLedgerEntry);
        GetVendorLedgerEntry.Copy(VendorLedgerEntry);
    end;

    procedure ApplyFilters()
    var
        ContactBusinessRelation: Record "Contact Business Relation";
        FilteredCustLedgerEntry: Record "Cust. Ledger Entry";
        FilteredVendorLedgerEntry: Record "Vendor Ledger Entry";
        Customer: Record Customer;
        Vendor: Record Vendor;
        RecFilter: Text;
    begin
        CompensationsSetupCZC.Get();
        Clear(RecFilter);

        Clear(FilteredCustLedgerEntry);
        FilteredCustLedgerEntry.SetRange(Open, true);
        FilteredCustLedgerEntry.SetRange(Prepayment, false);
        FilteredCustLedgerEntry.SetRange("Compensation Amount (LCY) CZC", 0);
        FilteredCustLedgerEntry.SetRange("On Hold", '');
        FilteredCustLedgerEntry.SetFilter("Posting Date", '<=%1', PostingDate);
        OnApplyFilterOnAfterSetCustLedgerEntryFilter(PostingDate, FilteredCustLedgerEntry);

        Clear(FilteredVendorLedgerEntry);
        FilteredVendorLedgerEntry.SetRange(Open, true);
        FilteredVendorLedgerEntry.SetRange(Prepayment, false);
        FilteredVendorLedgerEntry.SetRange("Compensation Amount (LCY) CZC", 0);
        FilteredVendorLedgerEntry.SetRange("On Hold", '');
        FilteredVendorLedgerEntry.SetFilter("Posting Date", '<=%1', PostingDate);
        OnApplyFilterOnAfterSetVendLedgerEntryFilter(PostingDate, FilteredVendorLedgerEntry);

        case CompensationTypeCZC of
            CompensationTypeCZC::Customer:
                begin
                    case CompensationsSetupCZC."Compensation Proposal Method" of
                        CompensationsSetupCZC."Compensation Proposal Method"::"Registration No.":
                            if SourceNo <> '' then begin
                                Customer.Get(SourceNo);
                                if Customer."Registration Number" <> '' then begin
                                    Vendor.SetRange("Registration Number", Customer."Registration Number");
                                    if Vendor.FindSet(false) then
                                        repeat
                                            if RecFilter = '' then
                                                RecFilter := Vendor."No."
                                            else
                                                RecFilter += '|' + Vendor."No.";
                                        until Vendor.Next() = 0;
                                end;
                            end;
                        CompensationsSetupCZC."Compensation Proposal Method"::"Bussiness Relation":
                            begin
                                Customer."No." := SourceNo;
                                ContactBusinessRelation.SetCurrentKey("Link to Table", "No.");
                                ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                                ContactBusinessRelation.SetRange("No.", SourceNo);
                                if ContactBusinessRelation.FindFirst() then
                                    RecFilter := GetLedgEntryFilterFromCont(ContactBusinessRelation."Link to Table"::Vendor.AsInteger(),
                                                                            ContactBusinessRelation."Contact No.");
                            end;
                    end;
                    if Customer."No." <> '' then
                        FilteredCustLedgerEntry.SetRange("Customer No.", Customer."No.");
                    CurrPage.CustLedgEntries.Page.ApplyFilters(FilteredCustLedgerEntry);

                    if (RecFilter = '') and CompensationsSetupCZC."Show Empty when not Found" then
                        FilteredVendorLedgerEntry.SetRange("Entry No.", 1, -1)
                    else
                        FilteredVendorLedgerEntry.SetFilter("Vendor No.", RecFilter);
                    CurrPage.VendLedgEntries.Page.ApplyFilters(FilteredVendorLedgerEntry);
                end;
            CompensationTypeCZC::Vendor:
                begin
                    case CompensationsSetupCZC."Compensation Proposal Method" of
                        CompensationsSetupCZC."Compensation Proposal Method"::"Registration No.":
                            if SourceNo <> '' then begin
                                Vendor.Get(SourceNo);
                                if Vendor."Registration Number" <> '' then begin
                                    Customer.SetRange("Registration Number", Vendor."Registration Number");
                                    if Customer.FindSet(false) then
                                        repeat
                                            if RecFilter = '' then
                                                RecFilter := Customer."No."
                                            else
                                                RecFilter += '|' + Customer."No.";
                                        until Customer.Next() = 0;
                                end;
                            end;
                        CompensationsSetupCZC."Compensation Proposal Method"::"Bussiness Relation":
                            begin
                                Vendor."No." := SourceNo;
                                ContactBusinessRelation.SetCurrentKey("Link to Table", "No.");
                                ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Vendor);
                                ContactBusinessRelation.SetRange("No.", SourceNo);
                                if ContactBusinessRelation.FindFirst() then
                                    RecFilter := GetLedgEntryFilterFromCont(ContactBusinessRelation."Link to Table"::Customer.AsInteger(),
                                                                            ContactBusinessRelation."Contact No.");
                            end;
                    end;
                    if (RecFilter = '') and CompensationsSetupCZC."Show Empty when not Found" then
                        FilteredCustLedgerEntry.SetRange("Entry No.", 1, -1)
                    else
                        FilteredCustLedgerEntry.SetFilter("Customer No.", RecFilter);
                    CurrPage.CustLedgEntries.Page.ApplyFilters(FilteredCustLedgerEntry);

                    if Vendor."No." <> '' then
                        FilteredVendorLedgerEntry.SetRange("Vendor No.", Vendor."No.");
                    CurrPage.VendLedgEntries.Page.ApplyFilters(FilteredVendorLedgerEntry);
                end;
            CompensationTypeCZC::Contact:
                begin
                    RecFilter := GetLedgEntryFilterFromCont(ContactBusinessRelation."Link to Table"::Customer.AsInteger(), SourceNo);
                    if (RecFilter = '') and CompensationsSetupCZC."Show Empty when not Found" then
                        FilteredCustLedgerEntry.SetRange("Entry No.", 1, -1)
                    else
                        FilteredCustLedgerEntry.SetFilter("Customer No.", RecFilter);
                    CurrPage.CustLedgEntries.Page.ApplyFilters(FilteredCustLedgerEntry);

                    RecFilter := GetLedgEntryFilterFromCont(ContactBusinessRelation."Link to Table"::Vendor.AsInteger(), SourceNo);
                    if (RecFilter = '') and CompensationsSetupCZC."Show Empty when not Found" then
                        FilteredVendorLedgerEntry.SetRange("Entry No.", 1, -1)
                    else
                        FilteredVendorLedgerEntry.SetFilter("Vendor No.", RecFilter);
                    CurrPage.VendLedgEntries.Page.ApplyFilters(FilteredVendorLedgerEntry);
                end;
        end;
    end;

    local procedure GetLedgEntryFilterFromCont(LinkToTable: Option; ContactNo: Code[20]) ValueFilter: Text
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        if ContactNo = '' then begin
            ValueFilter := '';
            exit;
        end;

        ContactBusinessRelation.SetRange("Contact No.", ContactNo);
        ContactBusinessRelation.SetRange("Link to Table", LinkToTable);
        if ContactBusinessRelation.FindSet(false) then
            repeat
                if ValueFilter = '' then
                    ValueFilter := ContactBusinessRelation."No."
                else
                    ValueFilter += '|' + ContactBusinessRelation."No.";
            until ContactBusinessRelation.Next() = 0;
    end;

    local procedure GetSourceName()
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Contact: Record Contact;
    begin
        Clear(SourceName);
        if SourceNo = '' then
            exit;
        case CompensationTypeCZC of
            CompensationTypeCZC::Customer:
                begin
                    Customer.Get(SourceNo);
                    SourceName := Customer.Name;
                end;
            CompensationTypeCZC::Vendor:
                begin
                    Vendor.Get(SourceNo);
                    SourceName := Vendor.Name;
                end;
            CompensationTypeCZC::Contact:
                begin
                    Contact.Get(SourceNo);
                    SourceName := Contact.Name;
                end;
        end;
    end;

    local procedure SourceTypeOnAfterValidate()
    begin
        Clear(SourceNo);
        Clear(SourceName);
        ApplyFilters();
    end;

    local procedure SourceNoOnAfterValidate()
    begin
        GetSourceName();
        ApplyFilters();
    end;

    local procedure LookupOKOnPush()
    begin
        Clear(CustLedgerEntry);
        Clear(VendorLedgerEntry);
        CurrPage.CustLedgEntries.Page.GetEntries(CustLedgerEntry);
        CurrPage.VendLedgEntries.Page.GetEntries(VendorLedgerEntry);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnApplyFilterOnAfterSetCustLedgerEntryFilter(PostingDate: Date; var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnApplyFilterOnAfterSetVendLedgerEntryFilter(PostingDate: Date; var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
    end;
}
