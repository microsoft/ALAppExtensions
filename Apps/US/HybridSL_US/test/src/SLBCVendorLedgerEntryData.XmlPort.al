// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Purchases.Payables;

xmlport 147661 "SL BC Vendor Ledger Entry Data"
{
    Caption = 'BC Vendor Ledger Entry data for import/export';
    Direction = Both;
    FieldSeparator = ',';
    RecordSeparator = '<CR><LF>';
    Format = VariableText;

    schema
    {
        textelement(root)
        {
            tableelement(VendorLedgerEntry; "Vendor Ledger Entry")
            {
                AutoSave = false;
                XmlName = 'BCVendorLedgerEntry';
                UseTemporary = true;

                textelement("EntryNo")
                {
                }
                textelement("VendorNo")
                {
                }
                textelement("PostingDate")
                {
                }
                textelement("DocumentType")
                {
                }
                textelement("DocumentNo")
                {
                }
                textelement("Description")
                {
                }
                textelement("VendorName")
                {
                }
                textelement("IRS1099SubjectForReporting")
                {
                }
                textelement("IRS1099ReportingPeriod")
                {
                }
                textelement("IRS1099FormNo")
                {
                }
                textelement("IRS1099FormBoxNo")
                {
                }
                textelement("IRS1099ReportingAmount")
                {
                }

                trigger OnPreXmlItem()
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;
                end;

                trigger OnBeforeInsertRecord()
                begin
                    if CaptionRow then begin
                        CaptionRow := false;
                        currXMLport.Skip();
                    end;

                    Evaluate(TempVendorLedgerEntry."Entry No.", "EntryNo");
                    TempVendorLedgerEntry."Vendor No." := "VendorNo";
                    Evaluate(TempVendorLedgerEntry."Posting Date", "PostingDate", 9);
                    Evaluate(TempVendorLedgerEntry."Document Type", "DocumentType");
                    TempVendorLedgerEntry."Document No." := "DocumentNo";
                    TempVendorLedgerEntry.Description := "Description";
                    TempVendorLedgerEntry."Vendor Name" := "VendorName";
                    Evaluate(TempVendorLedgerEntry."IRS 1099 Subject For Reporting", "IRS1099SubjectForReporting", 9);
                    Evaluate(TempVendorLedgerEntry."IRS 1099 Reporting Period", "IRS1099ReportingPeriod", 9);
                    TempVendorLedgerEntry."IRS 1099 Form No." := "IRS1099FormNo";
                    TempVendorLedgerEntry."IRS 1099 Form Box No." := "IRS1099FormBoxNo";
                    Evaluate(TempVendorLedgerEntry."IRS 1099 Reporting Amount", "IRS1099ReportingAmount", 9);
                    TempVendorLedgerEntry.Insert(false);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        CaptionRow := true;
    end;

    procedure GetExpectedVendorLedgerEntries(var NewTempVendorLedgerEntry: Record "Vendor Ledger Entry" temporary)
    begin
        if TempVendorLedgerEntry.FindSet() then begin
            repeat
                NewTempVendorLedgerEntry.Copy(TempVendorLedgerEntry);
                NewTempVendorLedgerEntry.Insert();
            until TempVendorLedgerEntry.Next() = 0;
        end;
    end;

    var
        CaptionRow: Boolean;
        TempVendorLedgerEntry: Record "Vendor Ledger Entry" temporary;
}
