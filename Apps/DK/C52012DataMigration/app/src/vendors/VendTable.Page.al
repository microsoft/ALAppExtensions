// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 1861 "C5 VendTable"
{
    PageType = Card;
    SourceTable = "C5 VendTable";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Vendor Table';
    PromotedActionCategories = 'Related Entities';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Account; Account) { ApplicationArea = All; }
                field(Name; Name) { ApplicationArea = All; }
                field(Address1; Address1) { ApplicationArea = All; }
                field(Address2; Address2) { ApplicationArea = All; }
                field(ZipCity; ZipCity) { ApplicationArea = All; }
                field(Country; Country) { ApplicationArea = All; }
                field(Attention; Attention) { ApplicationArea = All; }
                field(Phone; Phone) { ApplicationArea = All; }
                field(Fax; Fax) { ApplicationArea = All; }
                field(InvoiceAccount; InvoiceAccount) { ApplicationArea = All; }
                field(Group; Group) { ApplicationArea = All; }
                field(FixedDiscPct; FixedDiscPct) { ApplicationArea = All; }
                field(DiscGroup; DiscGroup) { ApplicationArea = All; }
                field(CashDisc; CashDisc) { ApplicationArea = All; }
                field(Approved; Approved) { ApplicationArea = All; }
                field(DEL_ExclDuty; DEL_ExclDuty) { ApplicationArea = All; }
                field(InclVat; InclVat) { ApplicationArea = All; }
                field(Currency; Currency) { ApplicationArea = All; }
                field(Language_; Language_) { ApplicationArea = All; }
                field(Payment; Payment) { ApplicationArea = All; }
                field(Delivery; Delivery) { ApplicationArea = All; }
                field(Interest; Interest) { ApplicationArea = All; }
                field(Blocked; Blocked) { ApplicationArea = All; }
                field(Purchaser; Purchaser) { ApplicationArea = All; }
                field(Vat; Vat) { ApplicationArea = All; }
                field(DEL_StatType; DEL_StatType) { ApplicationArea = All; }
                field(ESRnumber; ESRnumber) { ApplicationArea = All; }
                field(GiroNumber; GiroNumber) { ApplicationArea = All; }
                field(OurAccount; OurAccount) { ApplicationArea = All; }
                field(BankAccount; BankAccount) { ApplicationArea = All; }
                field(VatNumber; VatNumber) { ApplicationArea = All; }
                field(Department; Department) { ApplicationArea = All; }
                field(OnetimeSupplier; OnetimeSupplier) { ApplicationArea = All; }
                field(ImageFile; ImageFile) { ApplicationArea = All; }
                field(Inventory; Inventory) { ApplicationArea = All; }
                field(EDIAddress; EDIAddress) { ApplicationArea = All; }
                field(Balance; Balance) { ApplicationArea = All; }
                field(Balance30; Balance30) { ApplicationArea = All; }
                field(Balance60; Balance60) { ApplicationArea = All; }
                field(Balance90; Balance90) { ApplicationArea = All; }
                field(Balance120; Balance120) { ApplicationArea = All; }
                field(Balance120Plus; Balance120Plus) { ApplicationArea = All; }
                field(AmountDue; AmountDue) { ApplicationArea = All; }
                field(CalculationDate; CalculationDate) { ApplicationArea = All; }
                field(BalanceMax; BalanceMax) { ApplicationArea = All; }
                field(BalanceMST; BalanceMST) { ApplicationArea = All; }
                field(SearchName; SearchName) { ApplicationArea = All; }
                field(DEL_Transport; DEL_Transport) { ApplicationArea = All; }
                field(CashPayment; CashPayment) { ApplicationArea = All; }
                field(PaymentMode; PaymentMode) { ApplicationArea = All; }
                field(PaymSpec; PaymSpec) { ApplicationArea = All; }
                field(Telex; Telex) { ApplicationArea = All; }
                field(PaymId; PaymId) { ApplicationArea = All; }
                field(PurchGroup; PurchGroup) { ApplicationArea = All; }
                field(TradeCode; TradeCode) { ApplicationArea = All; }
                field(TransportCode; TransportCode) { ApplicationArea = All; }
                field(Email; Email) { ApplicationArea = All; }
                field(URL; URL) { ApplicationArea = All; }
                field(CellPhone; CellPhone) { ApplicationArea = All; }
                field(KrakNumber; KrakNumber) { ApplicationArea = All; }
                field(Centre; Centre) { ApplicationArea = All; }
                field(Purpose; Purpose) { ApplicationArea = All; }
                field(LastInvoiceDate; LastInvoiceDate) { ApplicationArea = All; }
                field(LastPaymentDate; LastPaymentDate) { ApplicationArea = All; }
                field(LastInvoiceNumber; LastInvoiceNumber) { ApplicationArea = All; }
                field(XMLImport; XMLImport) { ApplicationArea = All; }
                field(EanNumber; EanNumber) { ApplicationArea = All; }
                field(VatGroup; VatGroup) { ApplicationArea = All; }
                field(CardType; CardType) { ApplicationArea = All; }
                field(StdAccount; StdAccount) { ApplicationArea = All; }
                field(VatNumberType; VatNumberType) { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            group(RelatedEntities)
            {
                Caption = 'Related entities';

                action(C5Purchaser)
                {
                    ApplicationArea = All;
                    Caption = 'Purchaser';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = SalesPerson;
                    RunObject = Page "C5 Employee";
                    RunPageLink = Employee = field (Purchaser);
                    RunPageMode = Edit;
                }

                action(C5Payment)
                {
                    ApplicationArea = All;
                    Caption = 'Payment';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = Payment;
                    RunObject = Page "C5 Payment";
                    RunPageLink = Payment = field (Payment);
                    RunPageMode = Edit;
                }

                action(C5Delivery)
                {
                    ApplicationArea = All;
                    Caption = 'Delivery';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = Delivery;
                    RunObject = Page "C5 Delivery";
                    RunPageLink = Delivery = field (Delivery);
                    RunPageMode = Edit;
                }

                action(C5DiscGroup)
                {
                    ApplicationArea = All;
                    Caption = 'Discount Group';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = Discount;
                    RunObject = Page "C5 VendDiscGroup";
                    RunPageLink = DiscGroup = field (DiscGroup);
                    RunPageMode = Edit;
                }

                action(C5VendGroup)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Group';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = Group;
                    RunObject = Page "C5 VendGroup";
                    RunPageLink = Group = field (Group);
                    RunPageMode = Edit;
                }

                action(C5VendTrans)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Entries';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = EntriesList;
                    RunObject = Page "C5 VendTrans";
                    RunPageLink = Account = field (Account), Open = const (Yes), BudgetCode = const (Actual);
                    RunPageMode = Edit;
                }

                action(C5VendContact)
                {
                    ApplicationArea = All;
                    Caption = 'Contact Persons';
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Image = ContactPerson;
                    RunObject = Page "C5 VendContact";
                    RunPageLink = Account = field (Account);
                    RunPageMode = Edit;
                }
            }
        }
    }
}