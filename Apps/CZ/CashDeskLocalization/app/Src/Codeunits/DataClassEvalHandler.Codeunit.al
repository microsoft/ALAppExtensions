// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using Microsoft.Utilities;
using System.Environment;
using System.Privacy;
using System.Security.User;

codeunit 31056 "Data Class. Eval. Handler CZP"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure ApplyEvaluationClassificationsForPrivacyOnAfterClassifyCountrySpecificTables()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    procedure ApplyEvaluationClassificationsForPrivacy()
    var
        BankAccount: record "Bank Account";
        GeneralLedgerSetup: Record "General Ledger Setup";
        CashDeskCZP: Record "Cash Desk CZP";
        CashDeskUserCZP: Record "Cash Desk User CZP";
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        Company: Record Company;
        PaymentMethod: Record "Payment Method";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        ServiceHeader: Record "Service Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        SourceCodeSetup: Record "Source Code Setup";
        UserSetup: Record "User Setup";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"Cash Desk CZP");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Cash Desk Cue CZP");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Cash Desk Event CZP");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Cash Desk Rep. Selections CZP");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Cash Desk User CZP");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Cash Document Header CZP");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Cash Document Line CZP");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Currency Nominal Value CZP");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Posted Cash Document Hdr. CZP");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Posted Cash Document Line CZP");

        DataClassificationMgt.SetFieldToPersonal(Database::"Cash Desk CZP", CashDeskCZP.FieldNo("Responsibility ID (Release)"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Cash Desk CZP", CashDeskCZP.FieldNo("Responsibility ID (Post)"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Cash Document Header CZP", CashDocumentHeaderCZP.FieldNo("Created ID"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Cash Document Header CZP", CashDocumentHeaderCZP.FieldNo("Released ID"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Cash Desk User CZP", CashDeskUserCZP.FieldNo("User ID"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Posted Cash Document Hdr. CZP", PostedCashDocumentHdrCZP.FieldNo("Created ID"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Posted Cash Document Hdr. CZP", PostedCashDocumentHdrCZP.FieldNo("Released ID"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Posted Cash Document Hdr. CZP", PostedCashDocumentHdrCZP.FieldNo("Posted ID"));

        DataClassificationMgt.SetFieldToNormal(Database::"Bank Account", BankAccount.FieldNo("Account Type CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"General Ledger Setup", GeneralLedgerSetup.FieldNo("Cash Desk Nos. CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"General Ledger Setup", GeneralLedgerSetup.FieldNo("Cash Payment Limit (LCY) CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Payment Method", PaymentMethod.FieldNo("Cash Desk Code CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Payment Method", PaymentMethod.FieldNo("Cash Document Action CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Cash Desk Code CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purchase Header", PurchaseHeader.FieldNo("Cash Document Action CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Cr. Memo Hdr.", PurchCrMemoHdr.FieldNo("Cash Desk Code CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Cr. Memo Hdr.", PurchCrMemoHdr.FieldNo("Cash Document Action CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Header", PurchInvHeader.FieldNo("Cash Desk Code CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Purch. Inv. Header", PurchInvHeader.FieldNo("Cash Document Action CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("Cash Desk Code CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Cr.Memo Header", SalesCrMemoHeader.FieldNo("Cash Document Action CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header", SalesHeader.FieldNo("Cash Desk Code CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Header", SalesHeader.FieldNo("Cash Document Action CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("Cash Desk Code CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Sales Invoice Header", SalesInvoiceHeader.FieldNo("Cash Document Action CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Header", ServiceCrMemoHeader.FieldNo("Cash Desk Code CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Cr.Memo Header", ServiceCrMemoHeader.FieldNo("Cash Document Action CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Header", ServiceHeader.FieldNo("Cash Desk Code CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Header", ServiceHeader.FieldNo("Cash Document Action CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Header", ServiceInvoiceHeader.FieldNo("Cash Desk Code CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Service Invoice Header", ServiceInvoiceHeader.FieldNo("Cash Document Action CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"Source Code Setup", SourceCodeSetup.FieldNo("Cash Desk CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Cash Resp. Ctr. Filter CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Cash Desk Amt. Appr. Limit CZP"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Unlimited Cash Desk Appr. CZP"));
    end;
}
