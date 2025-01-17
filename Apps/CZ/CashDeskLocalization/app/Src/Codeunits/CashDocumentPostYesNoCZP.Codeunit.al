// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.GeneralLedger.Preview;
using System.Utilities;

codeunit 11727 "Cash Document-Post(Yes/No) CZP"
{
    EventSubscriberInstance = Manual;
    TableNo = "Cash Document Header CZP";

    trigger OnRun()
    begin
        CashDocumentHeaderCZP.Copy(Rec);
        Code();
        Rec := CashDocumentHeaderCZP;
    end;

    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        ConfirmManagement: Codeunit "Confirm Management";
        PostingConfirmQst: Label 'Do you want to post %1 %2?', Comment = '%1 = Cash Document Header TableCaption; %2 = Number of cash documents';

    local procedure Code()
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(PostingConfirmQst, CashDocumentHeaderCZP.TableCaption, CashDocumentHeaderCZP."No."), false) then
            Error('');
        Codeunit.Run(Codeunit::"Cash Document-Post CZP", CashDocumentHeaderCZP);
        Commit();
    end;

    procedure Preview(CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        CashDocumentPostYesNoCZP: Codeunit "Cash Document-Post(Yes/No) CZP";
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
    begin
        BindSubscription(CashDocumentPostYesNoCZP);
        GenJnlPostPreview.Preview(CashDocumentPostYesNoCZP, CashDocumentHeaderCZP);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Preview", 'OnRunPreview', '', false, false)]
    local procedure OnRunPreview(var Result: Boolean; Subscriber: Variant; RecVar: Variant)
    var
        CashDocumentPostCZP: Codeunit "Cash Document-Post CZP";
    begin
        CashDocumentHeaderCZP.Copy(RecVar);
        CashDocumentPostCZP.SetPreviewMode(true);
        Result := CashDocumentPostCZP.Run(CashDocumentHeaderCZP);
    end;
}
