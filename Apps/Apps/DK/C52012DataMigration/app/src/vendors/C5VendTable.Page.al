// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

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
#pragma warning disable AA0218
                field(Account; Rec.Account) { ApplicationArea = All; }
                field(Name; Rec.Name) { ApplicationArea = All; }
                field(Address1; Rec.Address1) { ApplicationArea = All; }
                field(Address2; Rec.Address2) { ApplicationArea = All; }
                field(ZipCity; Rec.ZipCity) { ApplicationArea = All; }
                field(Country; Rec.Country) { ApplicationArea = All; }
                field(Attention; Rec.Attention) { ApplicationArea = All; }
                field(Phone; Rec.Phone) { ApplicationArea = All; }
                field(Fax; Rec.Fax) { ApplicationArea = All; }
                field(InvoiceAccount; Rec.InvoiceAccount) { ApplicationArea = All; }
                field(Group; Rec.Group) { ApplicationArea = All; }
                field(FixedDiscPct; Rec.FixedDiscPct) { ApplicationArea = All; }
                field(DiscGroup; Rec.DiscGroup) { ApplicationArea = All; }
                field(CashDisc; Rec.CashDisc) { ApplicationArea = All; }
                field(Approved; Rec.Approved) { ApplicationArea = All; }
                field(DEL_ExclDuty; Rec.DEL_ExclDuty) { ApplicationArea = All; }
                field(InclVat; Rec.InclVat) { ApplicationArea = All; }
                field(Currency; Rec.Currency) { ApplicationArea = All; }
                field(Language_; Rec.Language_) { ApplicationArea = All; }
                field(Payment; Rec.Payment) { ApplicationArea = All; }
                field(Delivery; Rec.Delivery) { ApplicationArea = All; }
                field(Interest; Rec.Interest) { ApplicationArea = All; }
                field(Blocked; Rec.Blocked) { ApplicationArea = All; }
                field(Purchaser; Rec.Purchaser) { ApplicationArea = All; }
                field(Vat; Rec.Vat) { ApplicationArea = All; }
                field(DEL_StatType; Rec.DEL_StatType) { ApplicationArea = All; }
                field(ESRnumber; Rec.ESRnumber) { ApplicationArea = All; }
                field(GiroNumber; Rec.GiroNumber) { ApplicationArea = All; }
                field(OurAccount; Rec.OurAccount) { ApplicationArea = All; }
                field(BankAccount; Rec.BankAccount) { ApplicationArea = All; }
                field(VatNumber; Rec.VatNumber) { ApplicationArea = All; }
                field(Department; Rec.Department) { ApplicationArea = All; }
                field(OnetimeSupplier; Rec.OnetimeSupplier) { ApplicationArea = All; }
                field(ImageFile; Rec.ImageFile) { ApplicationArea = All; }
                field(Inventory; Rec.Inventory) { ApplicationArea = All; }
                field(EDIAddress; Rec.EDIAddress) { ApplicationArea = All; }
                field(Balance; Rec.Balance) { ApplicationArea = All; }
                field(Balance30; Rec.Balance30) { ApplicationArea = All; }
                field(Balance60; Rec.Balance60) { ApplicationArea = All; }
                field(Balance90; Rec.Balance90) { ApplicationArea = All; }
                field(Balance120; Rec.Balance120) { ApplicationArea = All; }
                field(Balance120Plus; Rec.Balance120Plus) { ApplicationArea = All; }
                field(AmountDue; Rec.AmountDue) { ApplicationArea = All; }
                field(CalculationDate; Rec.CalculationDate) { ApplicationArea = All; }
                field(BalanceMax; Rec.BalanceMax) { ApplicationArea = All; }
                field(BalanceMST; Rec.BalanceMST) { ApplicationArea = All; }
                field(SearchName; Rec.SearchName) { ApplicationArea = All; }
                field(DEL_Transport; Rec.DEL_Transport) { ApplicationArea = All; }
                field(CashPayment; Rec.CashPayment) { ApplicationArea = All; }
                field(PaymentMode; Rec.PaymentMode) { ApplicationArea = All; }
                field(PaymSpec; Rec.PaymSpec) { ApplicationArea = All; }
                field(Telex; Rec.Telex) { ApplicationArea = All; }
                field(PaymId; Rec.PaymId) { ApplicationArea = All; }
                field(PurchGroup; Rec.PurchGroup) { ApplicationArea = All; }
                field(TradeCode; Rec.TradeCode) { ApplicationArea = All; }
                field(TransportCode; Rec.TransportCode) { ApplicationArea = All; }
                field(Email; Rec.Email) { ApplicationArea = All; }
                field(URL; Rec.URL) { ApplicationArea = All; }
                field(CellPhone; Rec.CellPhone) { ApplicationArea = All; }
                field(KrakNumber; Rec.KrakNumber) { ApplicationArea = All; }
                field(Centre; Rec.Centre) { ApplicationArea = All; }
                field(Purpose; Rec.Purpose) { ApplicationArea = All; }
                field(LastInvoiceDate; Rec.LastInvoiceDate) { ApplicationArea = All; }
                field(LastPaymentDate; Rec.LastPaymentDate) { ApplicationArea = All; }
                field(LastInvoiceNumber; Rec.LastInvoiceNumber) { ApplicationArea = All; }
                field(XMLImport; Rec.XMLImport) { ApplicationArea = All; }
                field(EanNumber; Rec.EanNumber) { ApplicationArea = All; }
                field(VatGroup; Rec.VatGroup) { ApplicationArea = All; }
                field(CardType; Rec.CardType) { ApplicationArea = All; }
                field(StdAccount; Rec.StdAccount) { ApplicationArea = All; }
                field(VatNumberType; Rec.VatNumberType) { ApplicationArea = All; }
#pragma warning restore
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
                    RunPageLink = Employee = field(Purchaser);
                    RunPageMode = Edit;
                    ToolTip = 'Open the C5 Employee page.';
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
                    RunPageLink = Payment = field(Payment);
                    RunPageMode = Edit;
                    ToolTip = 'Open the C5 Payment page.';
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
                    RunPageLink = Delivery = field(Delivery);
                    RunPageMode = Edit;
                    ToolTip = 'Open the C5 Delivery page.';
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
                    RunPageLink = DiscGroup = field(DiscGroup);
                    RunPageMode = Edit;
                    ToolTip = 'Open the C5 Vendor Discount Groups page.';
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
                    RunPageLink = Group = field(Group);
                    RunPageMode = Edit;
                    ToolTip = 'Open the C5 Vendor Groups page.';
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
                    RunPageLink = Account = field(Account), Open = const(Yes), BudgetCode = const(Actual);
                    RunPageMode = Edit;
                    ToolTip = 'Open the C5 Vendor Entries page.';
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
                    RunPageLink = Account = field(Account);
                    RunPageMode = Edit;
                    ToolTip = 'Open the C5 Vendor Contact Persons page.';
                }
            }
        }
    }
}
