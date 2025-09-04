// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.ReceivablesPayables;

codeunit 11718 "Posting Gr. Change Handler CZP"
{
    var
        PostingGroupChange: Codeunit "Posting Group Change";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Posting Group Change", 'OnAfterChangePostingGroup', '', false, false)]
    local procedure HandleCashDocumentOnAfterChangePostingGroup(SourceRecordRef: RecordRef; NewPostingGroup: Code[20]; OldPostingGroup: Code[20])
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        if SourceRecordRef.Number <> Database::"Cash Document Line CZP" then
            exit;

        SourceRecordRef.SetTable(CashDocumentLineCZP);
        CheckPostingGroupChange(NewPostingGroup, OldPostingGroup, CashDocumentLineCZP);
    end;

    local procedure CheckPostingGroupChange(NewPostingGroup: Code[20]; OldPostingGroup: Code[20]; CashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
        case CashDocumentLineCZP."Account Type" of
            CashDocumentLineCZP."Account Type"::Customer:
                CheckCustomerPostingGroupChangeAndCustomer(NewPostingGroup, OldPostingGroup, CashDocumentLineCZP."Account No.");
            CashDocumentLineCZP."Account Type"::Vendor:
                CheckVendorPostingGroupChangeAndVendor(NewPostingGroup, OldPostingGroup, CashDocumentLineCZP."Account No.");
            CashDocumentLineCZP."Account Type"::Employee:
                CheckEmployeePostingGroupChangeAndEmployee(NewPostingGroup, OldPostingGroup, CashDocumentLineCZP."Account No.");
            else
                CashDocumentLineCZP.FieldError(CashDocumentLineCZP."Account Type");
        end;
    end;

    local procedure CheckCustomerPostingGroupChangeAndCustomer(NewPostingGroup: Code[20]; OldPostingGroup: Code[20]; CustomerNo: Code[20])
    begin
        PostingGroupChange.CheckAllowChangeSalesSetup();
        if not PostingGroupChange.HasCustomerSamePostingGroup(NewPostingGroup, CustomerNo) then
            PostingGroupChange.CheckCustomerPostingGroupSubstSetup(NewPostingGroup, OldPostingGroup);
    end;

    local procedure CheckVendorPostingGroupChangeAndVendor(NewPostingGroup: Code[20]; OldPostingGroup: Code[20]; VendorNo: Code[20])
    begin
        PostingGroupChange.CheckAllowChangePurchaseSetup();
        if not PostingGroupChange.HasVendorSamePostingGroup(NewPostingGroup, VendorNo) then
            PostingGroupChange.CheckVendorPostingGroupSubstSetup(NewPostingGroup, OldPostingGroup);
    end;

    local procedure CheckEmployeePostingGroupChangeAndEmployee(NewPostingGroup: Code[20]; OldPostingGroup: Code[20]; EmployeeNo: Code[20])
    begin
        PostingGroupChange.CheckAllowChangeHRSetup();
        if not PostingGroupChange.HasEmployeeSamePostingGroup(NewPostingGroup, EmployeeNo) then
            PostingGroupChange.CheckEmployeePostingGroupSubstSetup(NewPostingGroup, OldPostingGroup);
    end;
}
