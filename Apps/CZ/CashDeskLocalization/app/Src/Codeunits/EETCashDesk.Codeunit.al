// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance;

codeunit 31114 "EET Cash Desk CZP" implements "EET Cash Register CZL"
{
    procedure GetCashRegisterName(CashRegisterNo: Code[20]): Text[100]
    var
        CashDeskCZP: Record "Cash Desk CZP";
    begin
        if CashDeskCZP.Get(CashRegisterNo) then
            exit(CashDeskCZP.Name);
    end;

    procedure LookupCashRegisterNo(var CashRegisterNo: Code[20]): Boolean
    var
        CashDeskCZP: Record "Cash Desk CZP";
    begin
        CashDeskCZP."No." := CashRegisterNo;
        if Page.RunModal(0, CashDeskCZP) = Action::LookupOK then begin
            CashRegisterNo := CashDeskCZP."No.";
            exit(true);
        end;
        exit(false);
    end;

    procedure ShowDocument(CashRegisterNo: Code[20]; DocumentNo: Code[20])
    var
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
    begin
        PostedCashDocumentHdrCZP.Get(CashRegisterNo, DocumentNo);
        Page.Run(Page::"Posted Cash Document CZP", PostedCashDocumentHdrCZP);
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Cash Register CZL", 'OnAfterValidateEvent', 'Cash Register No.', false, false)]
    local procedure CheckCashDeskOnAfterValidateCashRegisterNo(var Rec: Record "EET Cash Register CZL"; var xRec: Record "EET Cash Register CZL")
    begin
        if Rec.IsTemporary then
            exit;
        if Rec."Cash Register Type" <> Rec."Cash Register Type"::"Cash Desk" then
            exit;
        if (Rec."Cash Register No." <> xRec."Cash Register No.") and (Rec."Cash Register No." <> '') then
            CheckCashDesk(Rec."Cash Register No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Entry CZL", 'OnBeforeInsertEvent', '', false, false)]
    local procedure CheckCashDeskOnBeforeInsertEETEntry(var Rec: Record "EET Entry CZL")
    begin
        if Rec.IsTemporary then
            exit;
        if Rec."Cash Register Type" <> Rec."Cash Register Type"::"Cash Desk" then
            exit;
        if Rec."Cash Register No." <> '' then
            CheckCashDesk(Rec."Cash Register No.");
    end;

    local procedure CheckCashDesk(CashDeskNo: Code[20])
    var
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";
    begin
        CashDeskManagementCZP.CheckCashDesk(CashDeskNo);
    end;
}
