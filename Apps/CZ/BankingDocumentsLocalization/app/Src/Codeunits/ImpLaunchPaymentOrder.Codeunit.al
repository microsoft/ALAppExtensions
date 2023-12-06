// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Setup;
using System.IO;
using System.Utilities;

codeunit 31365 "Imp. Launch Payment Order CZB"
{
    TableNo = "Payment Order Header CZB";

    trigger OnRun()
    var
        PaymentOrderHeaderCZB: Record "Payment Order Header CZB";
        BankAccount: Record "Bank Account";
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        PaymentOrderHeaderCZB.Copy(Rec);

        BankAccount.Get(Rec."Bank Account No.");
        BankExportImportSetup.Get(BankAccount."Payment Import Format CZB");
        BankExportImportSetup.TestField(Direction, BankExportImportSetup.Direction::Import);

        if BankExportImportSetup."Processing Report ID CZB" > 0 then
            RunProcessingReport(BankExportImportSetup, PaymentOrderHeaderCZB);

        if BankExportImportSetup."Processing XMLport ID" > 0 then
            RunProcessingXMLPort(BankExportImportSetup, PaymentOrderHeaderCZB);

        if BankExportImportSetup."Data Exch. Def. Code" <> '' then
            Error(NotSupportedErr,
              BankExportImportSetup.FieldCaption("Data Exch. Def. Code"), BankExportImportSetup.TableCaption);
    end;

    var
        WindowTitleTxt: Label 'Import';
        NotSupportedErr: Label 'The %1 from %2 is not supported for import Payment Orders.', Comment = '%1 = FieldCaption, %2 = TableCaption';

    local procedure RunProcessingReport(BankExportImportSetup: Record "Bank Export/Import Setup"; PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    var
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
    begin
        PaymentOrderLineCZB.SetRange("Payment Order No.", PaymentOrderHeaderCZB."No.");
        Report.RunModal(BankExportImportSetup."Processing Report ID CZB", false, false, PaymentOrderLineCZB);
    end;

    local procedure RunProcessingXMLPort(BankExportImportSetup: Record "Bank Export/Import Setup"; PaymentOrderHeaderCZB: Record "Payment Order Header CZB")
    var
        PaymentOrderLineCZB: Record "Payment Order Line CZB";
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        InStream: InStream;
    begin
        TempBlob.CreateInStream(InStream);
        FileManagement.BLOBImportWithFilter(
          TempBlob, WindowTitleTxt, '', BankExportImportSetup.GetFilterTextCZB(), BankExportImportSetup."Default File Type CZB");
        PaymentOrderLineCZB.Init();
        PaymentOrderLineCZB.SetRange("Payment Order No.", PaymentOrderHeaderCZB."No.");
        if TempBlob.HasValue() then
            Xmlport.Import(BankExportImportSetup."Processing XMLport ID", InStream, PaymentOrderLineCZB);
    end;
}
