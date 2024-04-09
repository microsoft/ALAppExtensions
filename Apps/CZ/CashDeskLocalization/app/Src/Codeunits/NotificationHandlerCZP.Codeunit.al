// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using System.Environment.Configuration;

codeunit 31422 "Notification Handler CZP"
{
    var
        CashReceiptTxt: Label 'Cash Receipt';
        CashWithdrawalTxt: Label 'Cash Withdrawal';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Management", 'OnGetDocumentTypeAndNumber', '', false, false)]
    local procedure GetDocumentTypeAndNumberFromCashDocumentOnGetDocumentTypeAndNumber(var RecRef: RecordRef; var DocumentType: Text; var DocumentNo: Text; var IsHandled: Boolean)
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        FieldRef: FieldRef;
    begin
        if IsHandled then
            exit;

        IsHandled := true;
        case RecRef.Number of
            Database::"Cash Document Header CZP":
                begin
                    RecRef.SetTable(CashDocumentHeaderCZP);
                    case CashDocumentHeaderCZP."Document Type" of
                        Enum::"Cash Document Type CZP"::Receipt:
                            DocumentType := CashReceiptTxt;
                        Enum::"Cash Document Type CZP"::Withdrawal:
                            DocumentType := CashWithdrawalTxt;
                    end;
                    FieldRef := RecRef.Field(2);
                    DocumentNo := Format(FieldRef.Value);
                end;
            else
                IsHandled := false;
        end;
    end;
}
