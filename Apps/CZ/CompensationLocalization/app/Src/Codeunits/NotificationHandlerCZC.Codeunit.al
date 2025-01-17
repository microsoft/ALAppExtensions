// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using System.Environment.Configuration;

codeunit 31424 "Notification Handler CZC"
{
    var
        CompensationTxt: Label 'Compensation';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Notification Management", 'OnGetDocumentTypeAndNumber', '', false, false)]
    local procedure GetDocumentTypeAndNumberFromCompensationOnGetDocumentTypeAndNumber(var RecRef: RecordRef; var DocumentType: Text; var DocumentNo: Text; var IsHandled: Boolean)
    var
        FieldRef: FieldRef;
    begin
        if IsHandled then
            exit;

        IsHandled := true;
        case RecRef.Number of
            Database::"Compensation Header CZC":
                begin
                    DocumentType := CompensationTxt;
                    FieldRef := RecRef.Field(5);
                    DocumentNo := Format(FieldRef.Value);
                end;
            else
                IsHandled := false;
        end;
    end;
}
