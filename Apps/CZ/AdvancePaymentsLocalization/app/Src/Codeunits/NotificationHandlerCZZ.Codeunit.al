// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using System.Environment.Configuration;

codeunit 31421 "Notification Handler CZZ"
{
    var
        SalesAdvanceLetterTxt: Label 'Sales Advance Letter';
        PurchaseAdvanceLetterTxt: Label 'Purchase Advance Letter';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Management", 'OnGetDocumentTypeAndNumber', '', false, false)]
    local procedure GetDocumentTypeAndNumberFromAdvanceLettersOnGetDocumentTypeAndNumber(var RecRef: RecordRef; var DocumentType: Text; var DocumentNo: Text; var IsHandled: Boolean)
    var
        FieldRef: FieldRef;
    begin
        if IsHandled then
            exit;

        IsHandled := true;
        case RecRef.Number of
            Database::"Sales Adv. Letter Header CZZ":
                begin
                    DocumentType := SalesAdvanceLetterTxt;
                    FieldRef := RecRef.Field(1);
                    DocumentNo := Format(FieldRef.Value);
                end;
            Database::"Purch. Adv. Letter Header CZZ":
                begin
                    DocumentType := PurchaseAdvanceLetterTxt;
                    FieldRef := RecRef.Field(1);
                    DocumentNo := Format(FieldRef.Value);
                end;
            else
                IsHandled := false;
        end;
    end;
}
