// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSBase;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Sales.Document;
using Microsoft.Utilities;
using System.Privacy;

codeunit 18812 "TCS Data Sensitivity Mgmt."
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", 'OnAfterClassifyCountrySpecificTables', '', false, false)]
    local procedure CreateSenstiviteDataTaxType()
    begin
        ClassifyGLSetup();
        ClassifyTCSNatureofCollection();
        ClassifyGenJournalLine();
        ClassifySalesLine();
        ClassifySalesLineBufferTCSOnPmt();
    end;

    local procedure ClassifyGLSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        TableNo: Integer;
    begin
        TableNo := Database::"General Ledger Setup";
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);
        DataClassificationMgt.SetFieldToPersonal(TableNo, GeneralLedgerSetup.FieldNo("TCS Debit Note No."));
    end;

    local procedure ClassifyTCSNatureofCollection()
    var
        TCSNatureOfCollection: Record "TCS Nature Of Collection";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        TableNo: Integer;
    begin
        TableNo := Database::"TCS Nature Of Collection";
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);
        DataClassificationMgt.SetFieldToPersonal(TableNo, TCSNatureOfCollection.FieldNo("Code"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, TCSNatureOfCollection.FieldNo("Description"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, TCSNatureOfCollection.FieldNo("TCS On Recpt. Of Pmt."));
    end;

    local procedure ClassifyGenJournalLine()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        TableNo: Integer;
    begin
        TableNo := Database::"Gen. Journal Line";
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);
        DataClassificationMgt.SetFieldToPersonal(TableNo, GenJournalLine.FieldNo("TCS Nature of Collection"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, GenJournalLine.FieldNo("Pay TCS"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, GenJournalLine.FieldNo("T.C.A.N. No."));
        DataClassificationMgt.SetFieldToPersonal(TableNo, GenJournalLine.FieldNo("Excl. GST in TCS Base"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, GenJournalLine.FieldNo("TCS On Recpt. Of Pmt. Amount"));
    end;

    local procedure ClassifySalesLine()
    var
        SalesLine: Record "Sales Line";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        TableNo: Integer;
    begin
        TableNo := Database::"Sales Line";
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLine.FieldNo("TCS Nature of Collection"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLine.FieldNo("Assessee Code"));
    end;

    local procedure ClassifySalesLineBufferTCSOnPmt()
    var
        SalesLineBufferTCSOnPmt: Record "Sales Line Buffer TCS On Pmt.";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
        TableNo: Integer;
    begin
        TableNo := Database::"Sales Line Buffer TCS On Pmt.";
        DataClassificationMgt.SetTableFieldsToNormal(TableNo);
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo("Payment Transaction No."));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo("Customer No."));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo("Posted Invoice No."));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo("Type"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo("No."));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo(Description));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo("Description 2"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo("Location Code"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo("Unit of Measure Code"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo(Quantity));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo("Unit Price"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo("Line Amount"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo("Line Discount Amount"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo("Inv. Discount Amount"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo("TCS Nature of Collection"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo("GST Base Amount"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo("Total GST Amount"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo("Posting Date"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo(Amount));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo("User ID"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo("Source Code"));
        DataClassificationMgt.SetFieldToPersonal(TableNo, SalesLineBufferTCSOnPmt.FieldNo(Select));
    end;
}
