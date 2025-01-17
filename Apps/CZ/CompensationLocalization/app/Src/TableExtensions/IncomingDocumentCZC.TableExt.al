// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.EServices.EDocument;

tableextension 31275 "Incoming Document CZC" extends "Incoming Document"
{
    procedure SetCompensationCZC(var CompensationHeaderCZC: Record "Compensation Header CZC")
    begin
        if CompensationHeaderCZC."Incoming Document Entry No." = 0 then
            exit;
        Get(CompensationHeaderCZC."Incoming Document Entry No.");
        TestReadyForProcessing();
        TestIfAlreadyExists();
        "Document Type" := "Document Type"::"Compensation CZC";
        Modify();
        if not DocLinkExists(CompensationHeaderCZC) then
            CompensationHeaderCZC.AddLink(GetURL(), Description);
    end;

    procedure CreateCompensationCZC()
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
    begin
        if "Document Type" <> "Document Type"::"Compensation CZC" then
            TestIfAlreadyExists();

        "Document Type" := "Document Type"::"Compensation CZC";
        TestReadyForProcessing();
        CompensationHeaderCZC.SetRange("Incoming Document Entry No.", "Entry No.");
        if not CompensationHeaderCZC.IsEmpty() then begin
            ShowRecord();
            exit;
        end;
        CompensationHeaderCZC.Reset();
        CompensationHeaderCZC.Init();
        CompensationHeaderCZC.Insert(true);
        if GetURL() <> '' then
            CompensationHeaderCZC.AddLink(GetURL(), Description);
        CompensationHeaderCZC."Incoming Document Entry No." := "Entry No.";
        CompensationHeaderCZC.Modify();
        "Document No." := CompensationHeaderCZC."No.";
        Modify(true);
        Commit();
        ShowRecord();
    end;
}
