// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

report 10831 "Archive Payment Slips FR"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Archive Payment Slips';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Payment Header"; "Payment Header FR")
        {
            CalcFields = "Archiving Authorized";
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Payment Class";

            trigger OnAfterGetRecord()
            begin
                if "Archiving Authorized" then begin
                    PaymentManagement.ArchiveDocument("Payment Header");
                    ArchivedDocs += 1;
                end;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        case ArchivedDocs of
            0:
                Message(Text002Lbl);
            1:
                Message(Text003Lbl);
            else
                Message(Text001Lbl, ArchivedDocs);
        end;
    end;

    trigger OnPreReport()
    begin
        ArchivedDocs := 0;
    end;

    var
        PaymentManagement: Codeunit "Payment Management FR";
        ArchivedDocs: Integer;
        Text001Lbl: Label '%1 Payment Headers have been archived.', Comment = '%1 = Document';
        Text002Lbl: Label 'There is no Payment Header to archive.';
        Text003Lbl: Label 'One Payment Header has been archived.';
}

