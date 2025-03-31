// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Sales.Reminder;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.History;

codeunit 6106 "E-Document Email"
{
    Access = Internal;

    local procedure FindEDocument(DocNo: Code[20]; SourceReference: RecordRef; var EDocument: Record "E-Document"): Boolean
    begin
        case SourceReference.Number() of
            Database::"Sales Invoice Header":
                exit(GetEDocumentForSalesInvoice(DocNo, EDocument));
            Database::"Sales Cr.Memo Header":
                exit(GetEDocumentForSalesCrMemo(DocNo, EDocument));
            Database::"Issued Reminder Header":
                exit(GetEDocumentForIssuedReminder(DocNo, EDocument));
            Database::"Issued Fin. Charge Memo Header":
                exit(GetEDocumentForIssuedFinChargeMemo(DocNo, EDocument));
            else
                exit(false);
        end;
    end;

    local procedure GetEDocumentForIssuedReminder(PostedDocNo: Code[20]; var EDocument: Record "E-Document"): Boolean
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
    begin
        IssuedReminderHeader.Get(PostedDocNo);
        EDocument.SetRange("Document Record ID", IssuedReminderHeader.RecordId());
        exit(EDocument.FindFirst());
    end;

    local procedure GetEDocumentForIssuedFinChargeMemo(PostedDocNo: Code[20]; var EDocument: Record "E-Document"): Boolean
    var
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
    begin
        IssuedFinChargeMemoHeader.Get(PostedDocNo);
        EDocument.SetRange("Document Record ID", IssuedFinChargeMemoHeader.RecordId());
        exit(EDocument.FindFirst());
    end;
}