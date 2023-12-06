// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;
using Microsoft.Utilities;
using System.Environment;
using System.Privacy;
using System.Security.User;

codeunit 31271 "Data Class. Eval. Handler CZC"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure ApplyEvaluationClassificationsForPrivacyOnAfterClassifyCountrySpecificTables()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    procedure ApplyEvaluationClassificationsForPrivacy()
    var
        Company: Record Company;
        CompensationHeaderCZC: Record "Compensation Header CZC";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
        PostedCompensationHeaderCZC: Record "Posted Compensation Header CZC";
        SourceCodeSetup: Record "Source Code Setup";
        UserSetup: Record "User Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"Compensation Header CZC");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Compensation Line CZC");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Compensations Setup CZC");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Compens. Report Selections CZC");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Posted Compensation Header CZC");
        DataClassificationMgt.SetTableFieldsToNormal(Database::"Posted Compensation Line CZC");

        DataClassificationMgt.SetFieldToPersonal(Database::"Compensation Header CZC", CompensationHeaderCZC.FieldNo("User ID"));
        DataClassificationMgt.SetFieldToPersonal(Database::"Posted Compensation Header CZC", PostedCompensationHeaderCZC.FieldNo("User ID"));

        DataClassificationMgt.SetFieldToNormal(Database::"Cust. Ledger Entry", CustLedgerEntry.FieldNo("Compensation CZC"));
        DataClassificationMgt.SetFieldToNormal(Database::"Gen. Journal Line", GenJournalLine.FieldNo("Compensation CZC"));
        DataClassificationMgt.SetFieldToNormal(Database::"Source Code Setup", SourceCodeSetup.FieldNo("Compensation CZC"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Compens. Amt. Appr. Limit CZC"));
        DataClassificationMgt.SetFieldToNormal(Database::"User Setup", UserSetup.FieldNo("Unlimited Compens. Appr. CZC"));
        DataClassificationMgt.SetFieldToNormal(Database::"Vendor Ledger Entry", VendorLedgerEntry.FieldNo("Compensation CZC"));
    end;
}
